"""The Options window (field_options): Start on the field, the two settings, and what
they do. Bounded; every step checks RAM before going on.

    python work/scripts/options.py [rom] [--no-battle]

1. Start opens the window (ID $75, one window up); right/left change Battle Speed,
   down then left/right Message Speed, clamped at 1 and 5, then Damage Flash On/Off;
   the bytes $C696/$C697/$C69A;
   B closes it, Start opens and closes it without pausing.
2. Start with a message up still pauses (and Start again resumes).
3. Message Speed: frames to type one message at 1, 3 and 5.
4. Battle Speed: a forced fight at 1, 2 (the stock pace) and 5 - the pop-up life and
   the frames from one actor's start to the next; a battle box's hold at 1 and 5.
Screenshots: work/analysis/options/.
"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(ROOT, 'tools'))
import ps2emu  # noqa: E402
import ps2screen  # noqa: E402
from ps2emu import PS2, ANALYSIS, GAME_SCREEN, TEXT_POINTER, WINDOW_ACTIVE, WINDOW_INDEX, WINDOW_DEPTH  # noqa: E402

rom = next((a for a in sys.argv[1:] if a.endswith('.bin')), os.path.join(ROOT, 'ps2en.bin'))
battle = '--no-battle' not in sys.argv
out = os.path.join(ANALYSIS, 'options')
os.makedirs(out, exist_ok=True)

WIN_SAVED = 0xFFFFDE54
CURSOR = 0xFFFFDE50
PAUSED = 0xFFFFF63A
OPT_BATTLE = 0xFFFFC696
OPT_MESSAGE = 0xFFFFC697
OPT_FLASH = 0xFFFFC69A
WINID_OPTIONS = 0x75
WINID_MESSAGE = 0x08
BUSY = 0xFFFFCC06
ACTOR = 0xFFFFCC90
POP_SLOTS = 0xFFFF8F00
SCREEN_BATTLE = 0x14
SCREEN_LEVEL = 0x0C


def settings(em):
    b, m = em.read(OPT_BATTLE, 2)
    return (b ^ 1) + 1, (m ^ 2) + 1


def screen(em, name):
    state = os.path.join(out, name + '.state')
    ps2emu.save_state(em, state)
    ps2screen.render(state, os.path.join(out, name + '.png'))


def wait_for(em, cond, what, tries=60, step=5):
    for _ in range(tries):
        if cond():
            return
        em.frames(step)
    raise RuntimeError('timed out waiting for ' + what)


def open_options(em):
    if em.word(WINDOW_DEPTH) or em.word(WINDOW_INDEX):
        raise RuntimeError('a window is up already')
    em.press('S', release=4)
    wait_for(em, lambda: em.word(WIN_SAVED) == WINID_OPTIONS and em.word(WINDOW_DEPTH) == 1
             and em.word(WINDOW_INDEX) == 0, 'the Options window')
    em.frames(10)
    if em.word(PAUSED):
        raise RuntimeError('Start paused the game instead')


def close_with(em, button):
    em.press(button, release=4)
    wait_for(em, lambda: em.word(WINDOW_DEPTH) == 0 and em.word(WINDOW_INDEX) == 0, 'the window to close')
    em.frames(10)
    if em.word(PAUSED):
        raise RuntimeError('closing with %s paused the game' % button)


def press_checked(em, button, want, settle=6):
    em.press(button, release=settle)
    got = settings(em)
    if got != want:
        raise RuntimeError('after %s: settings %s, wanted %s' % (button, got, want))


def close_message(em):
    """C through the message's pages, then close its window as an event would ($8001):
    a message forced on the field has no event to close it."""
    for _ in range(10):
        if not em.word(WINDOW_ACTIVE):
            break
        em.press('C', release=20)
    else:
        raise RuntimeError('the message never ended')
    if em.word(WINDOW_DEPTH):
        em.write(WIN_SAVED, bytes(2))
        em.write(WINDOW_INDEX, (0x8001).to_bytes(2, 'big'))
    wait_for(em, lambda: em.word(WINDOW_DEPTH) == 0 and em.word(WINDOW_INDEX) == 0, 'the message to close')
    em.frames(20)


def type_frames(em, sid):
    """Frames from a message window opening to its first page typed out."""
    ps2emu.show_message(em, sid, WINID_MESSAGE)
    wait_for(em, lambda: em.word(WINDOW_ACTIVE), 'the message', step=1, tries=120)
    n = 0
    while n < 2000:
        p = em.long(TEXT_POINTER) & 0xFFFFFF
        if em.read(0xFF0000 | (p & 0xFFFF), 1)[0] >= 0xC3:
            break
        em.frames(1)
        n += 1
    else:
        raise RuntimeError('the message never finished typing')
    close_message(em)
    return n


def set_battle(em, speed):
    em.write(OPT_BATTLE, bytes([(speed - 1) ^ 1]))


def box_hold(em, speed, sid=0x122A):
    """A battle box forced in the command phase at Battle Speed `speed`: its hold."""
    set_battle(em, speed)
    em.write(0xFFFFCB00, (1).to_bytes(2, 'big'))
    em.write(GAME_SCREEN, bytes([SCREEN_BATTLE]))
    em.frames(330)
    wait_for(em, lambda: not em.word(WINDOW_INDEX) and not em.word(WINDOW_ACTIVE), 'the battle windows')
    em.write(WINDOW_INDEX, (0x65).to_bytes(2, 'big'))
    em.write(0xFFFFCD00, sid.to_bytes(2, 'big'))
    wait_for(em, lambda: em.word(WINDOW_ACTIVE), 'the battle box', step=1, tries=120)
    return em.word(0xFFFFCF92), em.word(0xFFFFCD22)


def fight(em, speed, formation=1, limit=1500):
    """A forced fight at Battle Speed `speed`: per actor, the frame it starts; the
    first pop-up's life."""
    set_battle(em, speed)
    em.write(0xFFFFCB00, formation.to_bytes(2, 'big'))
    em.write(GAME_SCREEN, bytes([SCREEN_BATTLE]))
    em.frames(330)
    em.press('C', release=0)              # FIGHT
    starts, life, last = [], 0, (0, 0)
    for f in range(limit):
        em.frames(1)
        cur = (em.word(BUSY), em.word(ACTOR))
        if cur[0] and not last[0]:
            starts.append(f)
        last = cur
        for k in range(9):
            t = em.word(POP_SLOTS + 8 * k) & 0x7FFF
            life = max(life, t)
        if len(starts) >= 6 or em.byte(GAME_SCREEN) != SCREEN_BATTLE:
            break
    em.shot(os.path.join(out, 'battle_speed%d.png' % speed))
    return starts, life


with PS2(rom) as em:
    ps2emu.boot_to_field(em)
    if settings(em) != (2, 3):
        raise RuntimeError('new game settings %s, wanted (2, 3)' % (settings(em),))

    # 1. the window
    open_options(em)
    em.shot(os.path.join(out, 'open.png'))
    press_checked(em, 'L', (1, 3))
    press_checked(em, 'L', (1, 3))
    press_checked(em, 'R', (2, 3))
    press_checked(em, 'R', (3, 3))
    for _ in range(4):
        em.press('R', release=6)
    if settings(em) != (5, 3):
        raise RuntimeError('Battle Speed does not stop at 5: %s' % (settings(em),))
    em.press('D', release=8)
    if em.read(CURSOR, 1)[0] != 1:
        raise RuntimeError('the cursor did not move to Message Speed')
    press_checked(em, 'L', (5, 2))
    press_checked(em, 'L', (5, 1))
    press_checked(em, 'L', (5, 1))
    em.shot(os.path.join(out, 'b5_m1.png'))
    press_checked(em, 'R', (5, 2))
    em.press('D', release=8)
    if em.read(CURSOR, 1)[0] != 2 or em.byte(OPT_FLASH) != 0:
        raise RuntimeError('Damage Flash did not start On at the third row')
    screen(em, 'flash_on')
    em.press('R', release=8)
    if em.byte(OPT_FLASH) != 1:
        raise RuntimeError('Damage Flash did not turn Off')
    screen(em, 'flash_off')
    em.press('R', release=8)
    if em.byte(OPT_FLASH) != 1:
        raise RuntimeError('Damage Flash went past Off')
    em.press('L', release=8)
    if em.byte(OPT_FLASH) != 0:
        raise RuntimeError('Damage Flash did not turn On')
    em.press('L', release=8)
    if em.byte(OPT_FLASH) != 0:
        raise RuntimeError('Damage Flash went past On')
    em.press('R', release=8)
    close_with(em, 'B')
    open_options(em)
    em.shot(os.path.join(out, 'reopened.png'))
    if settings(em) != (5, 2) or em.byte(OPT_FLASH) != 1:
        raise RuntimeError('the settings changed on reopening')
    close_with(em, 'S')
    open_options(em)
    close_with(em, 'C')
    print('window: ok, settings', settings(em))

    # 2. Start with a message up still pauses
    ps2emu.show_message(em, 0x23, WINID_MESSAGE)
    wait_for(em, lambda: em.word(WINDOW_ACTIVE), 'the message', step=1, tries=120)
    em.frames(20)
    em.press('S', release=10)
    if not em.word(PAUSED) or em.word(WIN_SAVED) == WINID_OPTIONS:
        raise RuntimeError('Start over a message did not pause')
    em.press('S', release=10)
    if em.word(PAUSED):
        raise RuntimeError('Start did not resume')
    close_message(em)
    print('pause over a message: ok')

    # 3. Message Speed
    times = {}
    for speed in (1, 3, 5):
        em.write(OPT_MESSAGE, bytes([(speed - 1) ^ 2]))
        times[speed] = type_frames(em, 0x23)
    print('message typed in frames: %s' % times)
    if not (times[1] < times[3] < times[5]):
        raise RuntimeError('Message Speed does not order the typing')

    print('window and message speed: ok')

# 4. Battle Speed, a fresh session per fight
if battle:
    holds = {}
    for speed in (1, 5):
        with PS2(rom) as em:
            ps2emu.boot_to_field(em)
            holds[speed] = box_hold(em, speed)
    print('battle box hold (BattleBox_Time, $CD22): %s' % holds)
    if holds[1][0] != 90 or holds[5][0] != 240:      # 122A has two lines: stock 120
        raise RuntimeError('battle box hold %s, wanted 90 at 1 and 240 at 5' % holds)
    res = {}
    for speed in (1, 2, 5):
        with PS2(rom) as em:
            ps2emu.boot_to_field(em)
            res[speed] = fight(em, speed)
        gaps = [b - a for a, b in zip(res[speed][0], res[speed][0][1:])]
        print('battle speed %d: actors start at %s (gaps %s), pop-up life %d'
              % (speed, res[speed][0], gaps, res[speed][1]))
    want = {1: 30, 2: 45, 5: 90}
    for speed, life in want.items():
        if not life - 2 <= res[speed][1] <= life:
            raise RuntimeError('pop-up life %d at %d, wanted %d' % (res[speed][1], speed, life))
    if not res[1][0][-1] < res[2][0][-1] < res[5][0][-1]:
        raise RuntimeError('Battle Speed does not order the fight')
print('ok')
