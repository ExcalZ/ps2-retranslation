# Handoff: PS II field party menu and healing popup

Written 2026-10-02 for Claude. Read `AGENTS.md`, `work/STATUS.md`, `docs/pipeline.md`, and `work/glossary.md` first. The user asked for a PS IV-style field menu: roster on the right, Meseta aligned with the left menu, four main entries with the old Strength renamed Status and the old Status entry removed, Status > Status/Order > character > stats > Techniques, and an amber combat-style number just left of the target's HP when healed on the field.

## Current implementation

- `PSII_Disasm/ext/partymenu.asm` is new. `party_menu_ps4 = 1` in `ps2.options.asm`. It queues a right-side name roster, Meseta, and a shorter four-row main menu. `BattleBox_Record` selects replacement layout records only during initial field-menu opening. Meseta's X record changes from `$04` to `$02`. The main entries are Items, Techs, Status, Equip. Status reuses the old Status/Order choice, the old Strength character/stats/techniques stages, and the existing Order routine.
- `work/script.json` and `tools/gentext.py` generate four menu labels as VWF runs against `PM_MenuArt`. The original fixed art remains in place for option-0 stock builds. The fifth old row stays blank in the source data, and the replacement art has four rows.
- The old technique-picker check in `Win_MenuItemChar` now recognizes main-menu index 1 instead of 2 when the new option is on. This was necessary for B to back out correctly. `tools/ps2emu.py` expects three initial windows in the 1 MB translated ROM and one in the 768 KB stock ROM. `work/scripts/menus2.py` and `work/scripts/techwin.py` use the new menu indices.
- `PSII_Disasm/ext/fieldheal.asm` is new. `field_heal_popups = 1` in `ps2.options.asm`. Hooks cover Monomate/Dimate/Trimate, Star Mist, Moon Dew, RES family, SAR family, SAK, and NASAK. The stored number is the actual capped HP increase; zero is suppressed. Four field slots use `$FFFF8F28` onward; digit/frame tiles reserve VRAM `$23A-$25D`, with the field VWF pool starting at `$25E`. The popup uses palette 0/color 3, observed as amber `$0AAE` in 118 audited playable field states. Four horizontal HP fields in `MenuCharStats` have popup sprite X values `$A6/$DA/$10E/$142`, Y `$13E`. See the new file for comments and exact hooks.
- `docs/pipeline.md` has a row for `party_menu_ps4`. Add a row and short description for `field_heal_popups` after final review. `work/STATUS.md` has not yet been updated for this feature.

## Verification completed

- Final integrated `python tools/sourcebuild.py ps2en.bin`: 0 errors, 0 warnings. `PSII_Disasm/ps2.log` absent.
- `python tools/checkbuild.py`: **nothing moved**.
- `python tools/linecheck.py`: **0 problems**.
- `python tools/gentext.py --check`: rewrites nothing.
- `python tools/test_text.py`: passed.
- `python tools/checkstock.py`: stock reproduction byte-identical to Rev A. It required `sandbox_permissions=require_escalated` because its temporary build cannot write under normal sandboxing.
- `python work/scripts/partymenu.py ps2en.bin`: passed opening, Status/Order, character, stats, Techniques, Order, and bounded backout.
- `python work/scripts/menus2.py ps2en.bin`: status, tech, and equip paths passed, each with VWF overflow 0.
- A bounded ad hoc BlastEm menu path gave Rolf a Monomate, with HP 5/30. After Items > Rolf > Monomate > Use > Rolf and two script confirmations, HP became 25 and the field slot at `$FFFF8F28` contained `0029 8014 00A6 013E`: 20 actual healing in amber at the first HP coordinate.
- A bounded Star Mist path with Rolf 5/30 and Nei 7/20 healed them to 30 and 20. The first two field slots held amber amounts 25 and 13 at X `$A6` and `$DA`.

## Remaining work

1. Independently inspect all new field-heal hooks and fixed-size replacements in `ps2.asm` and `ext/fieldheal.asm`. The subagent implementation is uncommitted and needs primary review. In particular, verify SAR/SAK/NASAK loop behavior, Moon Dew/revival, sprite tile upload timing, and reset on map changes. `checkbuild` proves offsets, not behavior.
2. Add a permanent bounded field-heal emulator scenario. Test capped direct healing, Star Mist with one full-HP member (no zero popup), one technique heal and revival if feasible. The immediately preceding ad hoc RES technique test was interrupted before producing output; no conclusion was reached.
3. Visual verification is still missing. Fresh `em.shot` captures showed the Codex UI instead of BlastEm. `ps2emu.save_state` failed to create `quicksave.state`, even after a foreground attempt. Existing older screenshots such as `work/analysis/menus2/tech0.png` were used to derive the HP coordinates. The files under `work/analysis/partymenu/` from the failed capture attempt show Codex UI and should not be treated as evidence.
4. Add documentation for field popups and an entry in `work/STATUS.md`. Rerun the required build/check sequence after any fix.
5. The worktree was already extensively dirty before this task: translation, engine, generator, and JSON changes were present. Do not discard or wholesale stage them. Nothing from this task has been committed.

## Build rule

Always run `python tools/sourcebuild.py ps2en.bin` with generation, then `checkbuild.py`, `linecheck.py`, and `gentext.py --check`. Run `checkstock.py` and `test_text.py` before committing. Never test a ROM if `PSII_Disasm/ps2.log` exists.
