"""Phantasy Star II tile-art compression (DecompressArt, $5E9C in the US ROM).

Per 8x8 tile (32 bytes):
    byte  n         0: 32 literal bytes follow; negative ($80-$FF): end of the stream
    n x   [value][mask:32]   each set bit (MSB = byte 0) fills that byte with `value`
    then one literal byte for every byte no mask covered

    decompress(data, off) -> (bytes, end_offset)
    compress(tiles_bytes) -> bytes
"""


def decompress(data, off):
    p = off
    out = bytearray()
    while True:
        n = data[p]
        p += 1
        if n & 0x80:
            return bytes(out), p
        tile = bytearray(32)
        covered = 0
        for _ in range(n):
            value = data[p]
            mask = int.from_bytes(data[p + 1:p + 5], 'big')
            p += 5
            covered |= mask
            for i in range(32):
                if mask & (0x80000000 >> i):
                    tile[i] = value
        if covered != 0xFFFFFFFF:
            for i in range(32):
                if not covered & (0x80000000 >> i):
                    tile[i] = data[p]
                    p += 1
        out += tile


def compress(raw):
    """Greedy: every byte value that occurs at least twice in a tile gets a group
    when that saves space (group = 5 bytes, saves `count` literals)."""
    assert len(raw) % 32 == 0
    out = bytearray()
    for t in range(0, len(raw), 32):
        tile = raw[t:t + 32]
        counts = {}
        for b in tile:
            counts[b] = counts.get(b, 0) + 1
        groups = [v for v, c in sorted(counts.items(), key=lambda kv: -kv[1]) if c > 5][:127]
        out.append(len(groups))
        covered = 0
        for v in groups:
            mask = 0
            for i, b in enumerate(tile):
                if b == v:
                    mask |= 0x80000000 >> i
            covered |= mask
            out.append(v)
            out += mask.to_bytes(4, 'big')
        for i, b in enumerate(tile):
            if not covered & (0x80000000 >> i):
                out.append(b)
    out.append(0xFF)
    return bytes(out)
