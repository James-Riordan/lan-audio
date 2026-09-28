"""Independent test-only v2 wire oracle using Python struct and integer words.

No production Zig encoder generates expected bytes. Pure, bounded validation;
finite words remain integers so Python float conversion cannot canonicalize bits.
Exceptions describe invalid protocol data, not authorization or device capability.
"""
import struct

HEADER = struct.Struct('>4sBBHII16sQII')
PROFILE = struct.Struct('>IHHII')
MAX_RECORD = 8240
STREAM = bytes(range(1, 17))
WORDS = (0, 0x80000000, 1, 0x80000001, 0x007fffff, 0x807fffff,
         0x00800000, 0x80800000, 0x3f800000, 0xbf800000, 0x7f7fffff, 0xff7fffff)

def record(kind, position=0, frames=0, body=b'', stream=STREAM):
    """Construct independently; intentionally permits invalid bodies for tests."""
    return HEADER.pack(b'JCR2', 2, kind, 48, len(body), 0, stream, position, frames, 0) + body

def profile(kind=1, rate=48000, maximum=1024, stream=STREAM):
    return record(kind, body=PROFILE.pack(rate, 2, 1, maximum, 0), stream=stream)

def samples(position, frames):
    return b''.join(struct.pack('<I', WORDS[(position * 2 + i) % len(WORDS)]) for i in range(frames * 2))

def decode(data):
    """Return independent field dictionary, or ValueError for exactly-one-record rejection."""
    if not 48 <= len(data) <= MAX_RECORD:
        raise ValueError('record extent')
    magic, version, kind, header, body_size, flags, stream, position, frames, reserved = HEADER.unpack_from(data)
    if magic != b'JCR2' or version != 2 or header != 48 or flags or reserved or kind not in range(1, 6):
        raise ValueError('header')
    if not any(stream) or len(data) != 48 + body_size:
        raise ValueError('identity/extent')
    body = data[48:]
    if kind in (1, 2):
        if position or frames or len(body) != 16:
            raise ValueError('profile extent')
        rate, channels, representation, maximum, zero = PROFILE.unpack(body)
        if rate not in (44100, 48000, 96000) or channels != 2 or representation != 1 or not 1 <= maximum <= 1024 or zero:
            raise ValueError('profile')
    elif kind == 3:
        if not 1 <= frames <= 1024 or body_size != frames * 8 or position + frames > (1 << 64) - 1:
            raise ValueError('audio extent/frontier')
        # IEEE-754 all-ones exponent, irrespective of sign and fraction.
        if any((word >> 23) & 255 == 255 for (word,) in struct.iter_unpack('<I', body)):
            raise ValueError('nonfinite')
    elif frames or body:
        raise ValueError('control extent')
    return dict(kind=kind, stream=stream, position=position, frames=frames, body=body)
