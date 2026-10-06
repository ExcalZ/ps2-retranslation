"""The work RAM of a BlastEm 0.6.2 .state of Phantasy Star II, found by the save's copy of
the copyright string ($FFC6A0, "SEGA MEGA DRIVE "), which every game in progress holds.

    from stateram import state_ram; ram = state_ram(path); ram.word(0xFFFFDE04)
"""
KEY = b'SEGA MEGA DRIVE '


class StateRAM:
    def __init__(self, data, base):
        self.data, self.base = data, base

    def read(self, addr, n):
        a = (addr & 0xFFFF) + self.base
        return self.data[a:a + n]

    def word(self, addr):
        return int.from_bytes(self.read(addr, 2), 'big')


def state_ram(path):
    data = open(path, 'rb').read()
    i = data.find(KEY)
    if i < 0:
        raise ValueError('no game RAM found in %s' % path)
    return StateRAM(data, i - 0xC6A0)
