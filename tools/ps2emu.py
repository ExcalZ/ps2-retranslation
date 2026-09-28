"""Drive Phantasy Star II under BlastEm 0.6.2 through its GDB stub.

    from ps2emu import PS2
    with PS2("ps2en.bin") as em:      # boots from power-on
        em.frames(120)
        em.press("S")
        em.shot("work/analysis/title.png")

A frame is one hit of the breakpoint on JoypadRead's `move.b d0, d1` (right after
`not.b d0`) for the first pad (a0 = joypad_held); the wanted pad state is written into d0
there, so the emulator window never sees the keyboard. Bits are the game's own:
U D L R = 0-3, B 4, C 5, A 6, Start 7.

BlastEm keeps backup RAM per ROM file name, so the emulator runs a copy of the ROM
(work/states/harness/harness-<name>) whose save file is removed first: a scenario never
meets the user's own saved games and never overwrites them.

BlastEm is looked for beside this repository and then in ../ps4-translate/ (BLASTEM
overrides).
"""
import os
import shutil
import socket
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(HERE, 'md'))
import blastem_drive   # noqa: E402
import winshot         # noqa: E402

BUTTON = blastem_drive.BUTTON
_CANDIDATES = [os.environ.get('BLASTEM', ''),
               os.path.join(ROOT, 'blastem-win32-0.6.2', 'blastem.exe'),
               os.path.join(os.path.dirname(ROOT), 'ps4-translate', 'blastem-win32-0.6.2', 'blastem.exe')]
BLASTEM = next((p for p in _CANDIDATES if p and os.path.exists(p)), _CANDIDATES[1])
LST = os.path.join(ROOT, 'PSII_Disasm', 'ps2.lst')
STATES = os.path.join(ROOT, 'work', 'states')
ANALYSIS = os.path.join(ROOT, 'work', 'analysis')

# RAM (ps2.constants.asm)
GAME_SCREEN = 0xFFFFF600
JOYPAD_HELD = 0xFFFFF602
SCRIPT_ID = 0xFFFFCD00
WINDOW_ACTIVE = 0xFFFFCD10
TEXT_POINTER = 0xFFFFCD12
TEXT_BUFFER = 0xFFFFCD40
WINDOW_INDEX = 0xFFFFDE10
LEVEL_INDEX = 0xFFFFC640
LEVEL_X = 0xFFFFC644         # the position saved at a map transition
PLAYER_X = 0xFFFFE40A        # the player object's live position


def listing_address(label, after=None, lst=LST):
    return blastem_drive.listing_address(lst, label, after)


def harness_rom(rom, sram=None):
    d = os.path.join(STATES, 'harness')
    os.makedirs(d, exist_ok=True)
    copy = os.path.join(d, 'harness-' + os.path.basename(rom))
    if not os.path.exists(copy) or open(copy, 'rb').read() != open(rom, 'rb').read():
        shutil.copyfile(rom, copy)
    save_dir = os.path.join(os.environ.get('LOCALAPPDATA', ''), 'blastem',
                            os.path.splitext(os.path.basename(copy))[0])
    save = os.path.join(save_dir, 'save.sram')
    if os.path.exists(save):
        os.remove(save)
    if sram:
        os.makedirs(save_dir, exist_ok=True)
        shutil.copyfile(sram, save)
    return copy


class PS2(blastem_drive.BlastEm):
    def __init__(self, rom, port=1234, lst=LST, sram=None, fast=True):
        self.rom = harness_rom(os.path.abspath(rom), sram)
        self.lst = lst
        self.pad = 0
        self.frame = 0
        self.bps = set()
        self.log = None
        self.proc = subprocess.Popen([BLASTEM, self.rom, '-D'], cwd=os.path.dirname(BLASTEM),
                                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        self.sock = None
        for _ in range(100):
            try:
                self.sock = socket.create_connection(('127.0.0.1', port), timeout=1)
                break
            except OSError:
                time.sleep(0.1)
        if not self.sock:
            self.proc.kill()
            raise RuntimeError("BlastEm's GDB stub did not answer")
        self.sock.settimeout(60)
        self.buf = b''
        self.pad_bp = listing_address('JoypadRead', r'move\.b\s+d0,\s*d1', lst)
        self.breakpoint(self.pad_bp)
        if fast:
            self.fast()              # 400%: the scenarios count frames, not seconds

    def step_frame(self, hook=None):
        while True:
            pc = self.cont()
            if pc == self.pad_bp:
                if self.regs()['a'][0] == JOYPAD_HELD:
                    self.setreg(0, self.pad)
                    self.frame += 1
                    return
                self.setreg(0, 0)
                continue
            if hook:
                hook(pc)

    def ram(self, addr, n):
        return self.read(addr, n)

    def long(self, addr):
        return int.from_bytes(self.read(addr, 4), 'big')

    def quit_saving(self, timeout=10):
        """Let BlastEm exit on its own so it writes the cartridge SRAM (a kill does not):
        clear the breakpoints, let it run, and close its window. Killed after `timeout`
        seconds if it has not gone."""
        import ctypes
        for addr in list(self.bps) + [self.pad_bp]:
            self.unbreak(addr)
        self._send('c')
        user32 = ctypes.windll.user32
        user32.PostMessageW.argtypes = [ctypes.c_void_p, ctypes.c_uint, ctypes.c_size_t, ctypes.c_ssize_t]
        for h in winshot.windows_of_pid(self.proc.pid):
            user32.PostMessageW(h, 0x0010, 0, 0)          # WM_CLOSE
        try:
            self.proc.wait(timeout)
        except subprocess.TimeoutExpired:
            self.proc.kill()
            raise RuntimeError('BlastEm did not exit; killed (no SRAM written)')

    def fast(self, key='4'):
        """BlastEm's speed key (default.cfg: 4 = ui.set_speed.4, 400%), posted to its window
        so the keyboard focus is never taken. BlastEm reads it when it next runs."""
        import ctypes
        user32 = ctypes.windll.user32
        user32.PostMessageW.argtypes = [ctypes.c_void_p, ctypes.c_uint, ctypes.c_size_t, ctypes.c_ssize_t]
        vk = ord(key)
        scan = user32.MapVirtualKeyW(vk, 0)
        for _ in range(50):
            hw = winshot.windows_of_pid(self.proc.pid)
            if hw:
                break
            self.frames(2)
        for h in hw:     # WM_KEYDOWN, WM_KEYUP with the scancode SDL reads from lParam
            user32.PostMessageW(h, 0x0100, vk, 1 | (scan << 16))
            user32.PostMessageW(h, 0x0101, vk, 1 | (scan << 16) | (3 << 30))
        self.frames(4)

    def shot(self, path):
        hw = winshot.windows_of_pid(self.proc.pid)
        if not hw:
            raise RuntimeError('no BlastEm window')
        if not getattr(self, '_topmost', False):
            import ctypes
            swp = ctypes.windll.user32.SetWindowPos
            swp.argtypes = [ctypes.c_void_p] * 2 + [ctypes.c_int] * 4 + [ctypes.c_uint]
            for h in hw:   # HWND_TOPMOST; NOSIZE | NOMOVE | NOACTIVATE | ASYNCWINDOWPOS
                swp(h, ctypes.c_void_p(-1), 0, 0, 0, 0, 0x0001 | 0x0002 | 0x0010 | 0x4000)
            self._topmost = True
            self.frames(2)
        os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
        winshot.capture(self.proc.pid, path)
        if _blank_png(path):
            # BlastEm's window paints white while stopped in the stub on some desktops:
            # draw the screen from a savestate instead (VRAM, CRAM, the VDP registers)
            import ps2screen
            state = os.path.splitext(path)[0] + '.state'
            save_state(self, state)
            ps2screen.render(state, path)
            os.remove(state)
            os.remove(os.path.splitext(state)[0] + '.ram')
        return path


def _blank_png(path):
    import pngread
    try:
        w, h, px = pngread.read(path)
    except Exception:
        return True
    first = px[h // 2][w // 2]
    return all(px[y][x] == first for y in range(0, h, 37) for x in range(0, w, 41))


SCREEN_TITLE, SCREEN_FIELD = 0x400, 0xC00
WINID_MESSAGE, WINID_MESSAGE_BIG = 0x08, 0x1C
CONTROLS_LOCKED = 0xFFFFFFF0
DEMO_FLAG = 0xFFFFF750          # a scene is playing (scripted input)


GRID = ['ABCDEFGHI', 'JKLMNOPQR', 'STUVWXYZ']   # the naming window's letters; row 3 is ADV RUB END


NAME_CURSOR = 0xFFFFDE50    # the naming window's cursor: index into InputCharacterMap


def wait_for_naming(em, tries=40):
    """Press C through the messages before the naming window (the data check, NEW GAME,
    the prompt) until the window takes input: before every C, a right press is tried,
    and when it moves the cursor off A the window is open (a left press brings it back)
    and no C is pressed into it. Raises if it never opens - a scenario must not go on
    pressing buttons into a screen it has lost track of."""
    em.write(NAME_CURSOR, bytes(2))
    for _ in range(tries):
        em.press('R', hold=2, release=10)
        if em.word(NAME_CURSOR) == 2:
            em.press('L', hold=2, release=10)
            if em.word(NAME_CURSOR) == 0:
                return
        em.press('C', hold=2, release=40)
    raise RuntimeError('the naming window never took input')


def _cursor_to(em, target, tries=40):
    """Move the naming cursor to InputCharacterMap index `target` (a row is 17 bytes,
    letters two apart; row 3 is ADV $33, RUB $39, END $3F), checking after every press -
    a press can be dropped."""
    for _ in range(tries):
        cur = em.word(NAME_CURSOR)
        if cur == target:
            return
        if cur // 17 != target // 17:
            b = 'D' if target // 17 > cur // 17 else 'U'
        else:
            b = 'R' if target > cur else 'L'
        em.press(b, hold=2, release=10)
    raise RuntimeError('the naming cursor stays at $%02X, wanted $%02X' % (em.word(NAME_CURSOR), target))


WINDOW_DEPTH = 0xFFFFDE04   # windows up (the constants call it current_active_objects_num)


def open_menu(em, tries=4):
    """From the field with no window up: C until the field menu is the one window up."""
    for _ in range(tries):
        if em.word(WINDOW_DEPTH) == 1:
            return
        if em.word(WINDOW_DEPTH):
            raise RuntimeError('a window is up already (%d)' % em.word(WINDOW_DEPTH))
        em.press('C', hold=2, release=45)
    if em.word(WINDOW_DEPTH) != 1:
        raise RuntimeError('the menu never opened')


def close_windows(em, tries=10):
    """B until no window is up."""
    for _ in range(tries):
        if not em.word(WINDOW_DEPTH):
            em.frames(30)
            return
        em.press('B', hold=2, release=30)
    raise RuntimeError('the windows never closed (%d up)' % em.word(WINDOW_DEPTH))


def pick(em, index, tries=20, settle=40):
    """Move a list window's cursor (the byte at $DE50, the list's last index at $DE51; a
    list remembers it between openings) to entry `index` with Up/Down, checking after every
    press, then press C."""
    for _ in range(tries):
        cur = em.read(NAME_CURSOR, 1)[0]
        if cur == index:
            em.press('C', hold=2, release=settle)
            return
        em.press('D' if index > cur else 'U', hold=2, release=12)
    raise RuntimeError('the list cursor stays at %d, wanted %d' % (em.read(NAME_CURSOR, 1)[0], index))


def run_steps(em, steps, out, prefix='', film=24):
    """A scenario's steps, a screenshot after each (out/<prefix><k>.png) and a line of state:
    a number picks that list entry (cursor, then C); 'w' waits a second; one of U D L R A B
    C S presses that button; 'f' films - `film` shots 8 frames apart (<prefix><k>_<n>.png)."""
    for k, s in enumerate(steps, 1):
        if s == 'f':
            for n in range(film):
                em.frames(8)
                em.shot(os.path.join(out, '%s%d_%02d.png' % (prefix, k, n)))
            continue
        if s == 'w':
            em.frames(60)
        elif s.isalpha():
            em.press(s, hold=2, release=40)
        else:
            pick(em, int(s))
        em.shot(os.path.join(out, '%s%d.png' % (prefix, k)))
        print('%-2s depth %d cursor %s overflow %d' % (s, em.word(WINDOW_DEPTH), list(em.read(NAME_CURSOR, 2)),
                                                      em.word(0xFFFF8E30)), flush=True)


def type_name(em, name):
    """Enter `name` in the naming window (the cursor starts on A) and choose END. Checks
    what was stored (letters after the first become lower case with long_names) and
    raises on a mismatch instead of pressing on."""
    wait_for_naming(em)
    for ch in name.upper():
        r = next(i for i, g in enumerate(GRID) if ch in g)
        _cursor_to(em, r * 17 + GRID[r].index(ch) * 2)
        em.press('C', hold=2, release=12)
    _cursor_to(em, 0x3F)                    # END: row 3 ($33) + 12 (ADV +0, RUB +6)
    typed = bytes(em.read(0xFFFFC63C, 4) + em.read(0xFFFFC630, 2))
    em.press('C', hold=2, release=12)
    import ps2text
    got = ps2text.decode_us(typed.split(b'\xc4')[0].rstrip(b'\x00'))
    if got.upper() != name.upper():
        raise RuntimeError('typed %r, the window holds %r' % (name, got))
    return got


def boot_to_field(em, name='AAAA', max_presses=160):
    """Power-on -> title -> NEW GAME (no saves) -> name the hero -> through the opening, the
    Commander and Nei, until the player walks Paseo (screen $0C00, no window). About 5,000
    frames; state-driven where it matters."""
    while em.word(GAME_SCREEN) != SCREEN_TITLE:
        em.frames(10)
    em.frames(60)
    em.press('S', release=60)
    type_name(em, name)             # through the data check, NEW GAME and the prompt
    # the opening, the Commander, the walk home and Nei's scene are scripted (demo_flag);
    # the field is the first screen $0C00 with no scene and no window. Bounded: the loop
    # never presses on into a screen it does not recognise.
    for _ in range(max_presses):
        if em.word(GAME_SCREEN) == SCREEN_FIELD and not em.word(DEMO_FLAG) \
                and not em.word(WINDOW_ACTIVE) and not em.word(WINDOW_INDEX):
            break
        em.press('C', hold=2, release=24)
    else:
        raise RuntimeError('the field never came (screen %04X, demo %d)'
                           % (em.word(GAME_SCREEN), em.word(DEMO_FLAG)))
    em.frames(30)
    x = em.word(PLAYER_X)            # and the hero walks
    em.pad = BUTTON['R']; em.frames(16); em.pad = 0; em.frames(8)
    if em.word(PLAYER_X) == x:
        raise RuntimeError('the hero does not walk on the field')
    em.pad = BUTTON['L']; em.frames(16); em.pad = 0; em.frames(30)


STATE_DIR = os.path.join(os.environ.get('LOCALAPPDATA', ''), 'blastem')


def save_state(em, path):
    """Press BlastEm's save-state key (the backtick) in its window and copy the quicksave it
    writes to `path` (with the work RAM beside it as .ram). The .state holds VRAM, CRAM,
    VSRAM and the VDP registers, which the stub cannot read (tools/vramaudit.py)."""
    import ctypes
    d = os.path.join(STATE_DIR, os.path.splitext(os.path.basename(em.rom))[0])
    q = os.path.join(d, 'quicksave.state')
    if os.path.exists(q):
        os.remove(q)
    for h in winshot.windows_of_pid(em.proc.pid):
        ctypes.windll.user32.PostMessageW(h, 0x100, 0xC0, 0x00290001)
        ctypes.windll.user32.PostMessageW(h, 0x101, 0xC0, 0xC0290001)
    for _ in range(120):
        em.frames(1)
        if os.path.exists(q):
            break
    em.frames(5)
    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    shutil.copy(q, path)
    open(os.path.splitext(path)[0] + '.ram', 'wb').write(em.read(0xFF0000, 0x10000))
    return path


def show_message(em, script_id, window=WINID_MESSAGE_BIG):
    """Open a script window on the field showing `script_id`, as an event would."""
    em.write(WINDOW_INDEX, window.to_bytes(2, 'big'))
    em.write(SCRIPT_ID, script_id.to_bytes(2, 'big'))


if __name__ == '__main__':
    rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'ps2en.bin')
    with PS2(rom) as em:
        for k in range(12):
            em.frames(60)
            print(em.frame, 'screen %04X' % em.word(GAME_SCREEN))
        print(em.shot(os.path.join(ANALYSIS, 'boot.png')))
