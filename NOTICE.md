# Third-party components

| Component | Where | Origin | Terms |
|---|---|---|---|
| Phantasy Star II disassembly (`PSII_Disasm/`) | the whole directory, minus the translation edits | lory90 (lorenzo), "Phantasy Star II Disassembly for Mega Drive/Genesis", distributed by Phantasy Star Cave (`pscave.com/dow/disassemblies/PSII_Disasm.zip`) | the author's own terms in `PSII_Disasm/README.txt`; no formal license, non-commercial |
| Macro Assembler AS (`PSII_Disasm/AS/win32/asw.exe`, `p2bin.exe`, `ps2p2bin.exe`) | `PSII_Disasm/AS/` | Alfred Arnold, http://john.ccac.rwth-aachen.de:8000/as/ | AS's own free-software license; the message catalogues and DLLs beside it are part of that distribution |
| Centred field camera (`centered_camera` in `PSII_Disasm/ps2.options.asm`) | the four scroll thresholds at `loc_3956` in `PSII_Disasm/ps2.asm` | EvilJagaGenius, who found the thresholds and the centring values | used with credit |
| `fixheader.exe` | `PSII_Disasm/` | ships with the disassembly | as the disassembly |
| Generic Mega Drive tools (`tools/md/`) | `bps.py`, `smd.py`, `bin2smd.py`, `expand.py`, `emu68k.py`, `m68k.py`, `blastem_*.py`, `winshot.py`, `webpatch.py`, `patcher_template.html`, `png.py`, `pngread.py`, `tiles.py` | the `mdtools` export of the Phantasy Star IV retranslation (same author) | MIT (`tools/md/LICENSE`) |

Not included, but used by the tooling: BlastEm 0.6.2 (GPL), Floating IPS (GPL).

Phantasy Star II is copyright SEGA. This repository contains no ROM image.
