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
LEVEL_X = 0xFFFFC644


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
    def __init__(self, rom, port=1234, lst=LST, sram=None):
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
        return path


SCREEN_TITLE, SCREEN_FIELD = 0x400, 0xC00
WINID_MESSAGE, WINID_MESSAGE_BIG = 0x08, 0x1C
CONTROLS_LOCKED = 0xFFFFFFF0


def boot_to_field(em, name='AAAA'):
    """Power-on -> title -> NEW GAME (no saves) -> name the hero -> through the opening, the
    Commander and Nei, until the player walks Paseo (screen $0C00, no window). About 5,000
    frames; state-driven where it matters."""
    while em.word(GAME_SCREEN) != SCREEN_TITLE:
        em.frames(10)
    em.frames(60)
    em.press('S', release=60)
    for _ in range(8):              # the data check, NEW GAME, the naming prompt
        em.press('C', hold=2, release=40)
    for _ in name:
        em.press('C', hold=2, release=12)   # the cursor starts on A
    for b in 'DDDRRC':             # down to ADV/RUB/END, right to END
        em.press(b, hold=2, release=12)
    while True:
        em.press('C', hold=2, release=24)
        if em.word(GAME_SCREEN) != SCREEN_FIELD or em.word(WINDOW_ACTIVE):
            continue
        # scenes pause with no window open too: the field is where the hero walks
        for _ in range(3):                   # close the player menu a C may have opened
            if em.word(WINDOW_INDEX) == 0:
                break
            em.press('B', hold=2, release=20)
        x = em.word(LEVEL_X)
        em.pad = BUTTON['R']; em.frames(16); em.pad = 0; em.frames(8)
        if em.word(LEVEL_X) != x:
            em.pad = BUTTON['L']; em.frames(16); em.pad = 0; em.frames(30)
            return


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
