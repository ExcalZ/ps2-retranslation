# Phantasy Star II Improvement v4.5 in the retranslation

FlamePurge's *Phantasy Star II Improvement* v4.5 (2024-10-21; `PSII_Improvement_v45.zip`
in the project root, not tracked) is an IPS against Rev A (CRC32 `904FA047`) built from
lory1990's disassembly with code inserted, so almost every byte after `$28F` moves. It was
read back into this source (2026-09-29) by aligning the patched ROM with the stock one
(a byte-level histogram diff), discarding the moved pointers and branch offsets, and
disassembling what was left against the stock listing. Its readme and changelog name the
changes; each one below was matched to the bytes that make it.

Everything but its script and name changes is in, behind six options in
`PSII_Disasm/ps2.options.asm`. Data changes are `if option / new / else / stock / endif`
around the stock lines; code that the Improvement grew is a same-size hook in `ps2.asm`
calling `PSII_Disasm/ext/improvement.asm`. Nothing in the stock image moves
(`checkbuild.py`), every option at 0 still builds Rev A (`checkstock.py`), and every
changed data table was compared with the Improvement's ROM byte for byte (the item and
technique records apart from their names).

Credits: FlamePurge (the Improvement and its rebalance), lory1990 (the bug fixes, fast
walking, the Silka stealing change, the radar art), veo (fast battles, no red flashes),
EvilJagaGenius (the centred camera, already `centered_camera` here), Fauntleroy (Van
Leader in the dams).

## `improvement_fixes` - lory1990's bug fixes

| fix | where | how |
|---|---|---|
| DEXTRTY counts in the hit rate | `CalculateHitRate` | `lsl.w #8` -> `lsl.l #8`: the stock kept only the low word |
| the ATTACK formula with a large ATTACK-DEFENSE gap | `CalculateAttackDamage` | `lsr.w #8` -> `lsr.l #8` after the `mulu` |
| the same for an enemy's physical attack | `loc_2AA8` | `lsr.w #8` -> `lsr.l #8` |
| LUCK in evading techniques | `loc_2C28` | hook `Fix_TechSuccessRate`: `d0`'s high word is cleared before the `divu` |
| SHINB escapes from biomonsters and evil creatures | `TechAction_Shinb` | hook `Fix_ShinbEscape`: `a1` points at the enemy (`enemy_stat_buffer`) when `loc_27AA` tests its type |
| TOADER's Agility Down | `loc_30A4` | subtracts from AGILITY (`$14`), not DEFENSE (`$1E`) |
| no automatic physical attack after paralysis | `loc_1C1C` | the skipped turn toggles the hand word (`2(a5)`, as `CommandUsed_Attack`), not the target (`4(a5)`) |
| no running from bosses | `Run_EventIndex_TryRun` | hook `Fix_TryRunRandom`: with an escape rate of 0 the roll is 1, so a random 0 no longer escapes |
| the first battle command cursor | `ObjRRCB_Init` | hook `Fix_BattleCursorInit`: clears the list cursor `$DE50` |
| B+C together over NEXT (items, techniques, equipment) | `loc_F9BA`, `loc_FF80`, `loc_10192`, `loc_10222` | `andi.b #$10 / beq` -> `andi.b #$20 / bne`: C wins |
| NPCs start facing down, with the right frame | 11 NPC inits (`loc_3BD8` ... `loc_48CC`) | `move.w 4(a0), $2A(a0)` (the high word of the mappings pointer) -> `move.w #3, $2A(a0)` |
| the lineup animates only when it moves | `ObjFlwngChar_Main` | replaced whole by `Fix_FollowerMain` (also fast walking's spacing) |
| PUSH START BUTTON shows at once | `ObjPSB_Init` | the check for a held button is `nop`ped |
| the prologue takes Start | `loc_381A` | the demo input keeps bit 15 of `joypad_held` instead of overwriting it |
| the prologue after the ending shows the dams closed, the rivers empty | `loc_785C` (end of the credits) | hook `Fix_ClearEventFlags`: clears `$C700-$C7FF` |
| a map load is no step towards a battle | `LevelScreen` | hook `Fix_LevelScreenInit`: clears the moved flag `$CB0A` |
| the Jet Scooter: the camera and alignment on getting off | `loc_D9C6` | hook `Fix_ScooterDisembark`: the leader takes the scooter's position and direction first |
| the Jet Scooter at the dock (one object slot for two scooters; the Improvement's changelog also lists "no control during the flood cutscene") | `LoadSpritesInLevel` | hook `Fix_LevelSpriteSlots`: on the world map the first entry of `SpriteData_MotaWorldMap` (a scooter at the dock) and object slot 0 are skipped; the Improvement deleted the entry, we skip it (the data stays) |
| the Central Tower storage inventory glitch | `loc_C1EA` | hook `Fix_StorageReturn`: coming back from the list, the character's inventory is checked again |
| the Kueri inventor says "what can I work on?" after the gum | `loc_C8CA`, `loc_C948` | hooks `Fix_InventorGreeting`, `Fix_InventorGum`: giving the gum counts in `$C720`; at 2 the visit shows `$0B08` and ends |
| the Paseo old man no longer says part of Lutz's speech | `loc_E6B0` table | `$94` -> `$96`: message `1696` (the lake) instead of `1694` |
| Rolf alone in Rearrange: "Nothing happens." | `loc_A48A` | `$0927` ("Shir is coming back") -> `$0004` |
| SAR, SAK, NASAK and ANTI make a sound on the field | four ends of the field technique routines | hooks `Fix_FieldHealSound` (`SXFID_Healed`, as RES), `Fix_FieldAntiSound` (`SXFID_PoisonCured`) |
| Menobe's tile collision | `loc_54F24+$129`, `loc_552B2+$184`, `loc_5558E+$9D` (the three floors' layouts) | one byte each |
| the Mechoman/Sonomech/Attmech missile frame | `Battle_MechomanMap` | the doubled `loc_97E94` entry -> `loc_97EAA` |
| "DIRECTOR" in the credits | `EndingCredits_Script` | two bytes |

## `fast_walking` - lory1990

| change | where |
|---|---|
| 2 pixels a frame, 8 frames a tile | the four speeds in `loc_382A`-`CharSprites_ChkMoveRight`, the frame count at `loc_38FC` |
| the map scrolls 2 pixels a frame | the four `$F724`/`$F726` steps in `loc_3956` (the thresholds there are `centered_camera`'s, and the same as the Improvement's) |
| the followers trail by 8 frames of the position history, not 16 | `Fix_FollowerMain` |
| the Gaira alarm timer halved (`$708` -> `$384`) | `loc_DF38` |

Checked in BlastEm (`work/scripts/improvement.py`): the leader moves 14 px in its first 8
frames (stock 7) and 64 px in 32, and Nei stops one tile behind in both builds.

## `fast_battles` - veo

A damaged ally or enemy flashes once: the hurt timer at `loc_3308` is `$10`, not `$30`.

## `improvement_rebalance` - FlamePurge

Item names below are the translation's (`work/script.json`), with the US name where the
two differ a lot; the technique names are the US ones, as in FlamePurge's readme.

* **New items in old slots** (the records keep their stock names; the names shown are
  `work/script.json`'s):
  * `$44` Heilsam Boots (HIRZABOOTS) -> **Cyber Vest**: Nei's armor, 4300 meseta, +10
    ATK, +29 DEF; in a Roron chest (was a Ceramic Claw).
  * `$5D` Whip -> **Silver Claw**: Nei's claw, 6200 meseta, +59 ATK, +7 DEF, the Ceramic
    Claw's sound and sprites; in a Climatrol chest (was a Glass Vest, FIBERVEST).
  * `$6E` Bowgun -> **Wave Shot**: Huey's and Kainz's two-handed gun, 45000 meseta, 67
    fixed damage (`WeaponProp_BowGun`).
* **Equipment rights** (the item records): Nei may also wear the Snow Crown, Nei Crown,
  Crysta Field (CRYSTCAPE), Nei Field (NEICAPE), Green Sleeves and Sincerity Sleeves (TRUTH
  SLVS); Huey the Crysta Chest and Laconia Chest; Kainz the Vulcan; Eusis the Shotgun. The
  Laconia Helm goes from Rudger and Huey to Eusis and Kainz; the Long Boots from Amia to
  Anne and Silka.
* **Laconia Dagger**: +45 ATK, +7 DEF (stock +4, +22, which looks swapped).
* **Shops** (`StoreEquipItemArray`): Paseo weapons sell the Shotgun instead of the Bowgun;
  Zema weapons the Silent Shot instead of the Whip; Aukba armor the Knife Boots and Long
  Boots instead of the Espadrilles (SANDALS) and Heilsam Boots; Zosa weapons the Laser Claw
  instead of the Boomerang; Ryuon armor the Jewel Ribbon instead of the Ribbon; Ryuon
  weapons the Wave Shot instead of the Knife.
* **Chests**: Skure's extra Magic Hat (MAGIC CAP) is a Laconia Shield; the two new items
  as above.
* **Starting gear**: Nei holds a Steel Claw; Rudger a Sonic Gun (one-handed) instead of a
  Bowgun in both hands.
* **Fire Staff**, used as an item, casts GIFOI (was FOI).
* **FANBI**: 6 TP (was 2); its power byte `$0A` -> `$1F` (the readme: drains 30 HP, was 10).
* **Techniques** (the per-character lists and the learn bytes of the level tables):
  Eusis learns ZAN at 5 and GIFOI at 7 (swapped) and ANTI at 18; Nei RES 1, ANTI 8, SAK
  16, NASAK 20, SHIFT 24, GIRES 28, SAR 32, GISAR 44; Anne GRA at 5 (not FOI), GIGRA at
  31; Huey RIMIT 2, DORAN 3, GEN 3, SAGEN 5, SHINB 5, SHIZA 6, RES 7, FOI 9, GIFOI 11,
  GIRES 13, VOL 15, SAR 17, GRA 18, SAVOL 22, NAFOI 27, GIGRA 30; Amia no FOI, ZAN at 4,
  GIZAN at 16; Kainz no FOI; Silka FOI 1, RYUKA 6, HINAS 6, RES 8, ZAN 11, GIFOI 15, GRA
  18, GIZAN 22, GIRES 25, GIGRA 28, NAZAN 33, NAGRA 36 (FlamePurge's readme; the tables
  match his ROM byte for byte).
* **Default battle command**: Attack for everyone (Anne, Huey and Silka defaulted to
  Defend).
* **Van Leader** (`VANLEADR`, enemy `$59`, unused in the stock game) in the Green and
  Blue Dams: the formations Van x2 -> Van + Van Leader, and Heavy Soldier + Van -> Heavy
  Soldier + Van Leader.
* **Silka does not steal on Dezolis** (`ProcessStealItem`, hook `Fix_StealOnMotavia`;
  lory1990); she must still be level 10 for the Visiphone.

## `radar_names`

The Gaira radar portrait (`RadarPortraitArt`) spells the planets MOTABIA, PARMA and
DEZOLIS. The Improvement redraws them MOTAVIA, PALMA and DEZORIS (lory1990's art). The
glossary has Motavia, Palma and **Dezolis**, so `art/radar_portrait_names.bin` takes the
Improvement's two tiles for Motavia and Palma (tiles 16, 47) and keeps the stock DEZOLIS
(tiles 11, 12). It is the Improvement's compressed stream with the stock encoding of those
two tiles, 2 bytes shorter, padded to the stock 1232 bytes.

## The addenda (options at 0, as the Improvement ships them)

* `double_rewards` (Doubler addendum): the addendum doubles every enemy record's EXP and
  meseta. Here a hook where `loc_8D4` copies the record to RAM (`Fix_DoubleRewards`)
  doubles both; the largest EXP, `$36F5`, still fits the word.
* `no_red_flash` (veo): the flash when the party is hurt writes the battle backdrop colour
  (`$200`) instead of red (`$E000E`).
* The Original Names addendum is names and dialogue only: not taken (the translation has
  the Japanese names already).

The addenda also turn off the checksum test (`$225`) so they can stack; this build fixes
the header checksum instead.

## Not taken, and why

* **The script**: every dialogue change (the Improvement's own edit of the 1989 text). Two
  of lory1990's fixes live only there - the Uzo Mountain and underground-spring examine
  texts (`171F`, `1720`), cut off in the stock data - and the translation already has them
  in full. `120B` ("has gone insane" -> "Dexterity decreases!") is also a script edit.
* **Names and labels**: the proper-case items, enemies, techniques, menus and profiles,
  "Right" for RGHT, "Give"/"Toss", "Mother Brain" in the Library, the Harnisch/Mail and
  Tunic/Field armor names, the Original Names addendum: the translation's own tables do
  all of this from the Japanese. Only the three new items needed names; Amia's profile
  now says she fights with "slicers and knives" (the Japanese says whips, and the Whip is
  gone; the Improvement wrote "a slasher or knife").
* **The window layout that goes with its labels**: the moved window art offsets, and the
  strength menu's character list one cell to the left (`PtrWin_StrngCharList` `$4586` ->
  `$4584`, its cursor x `$A0` -> `$98`).
* **The naming screen** (lowercase letters, "-" and ".", lory1990's fix for reaching
  them): the Improvement widens the grid to 18 columns of upper and lower case.
  `long_names` already writes the letters after the first in lower case from the stock
  capitals grid. Taking the grid would mean dropping that; left for the owner.
* **The Lutz split** (`$1690` queued with `$1693`): `paged_text_buffer` already fixes the
  music freeze.
* **The final boss's "destruction"** (`$1816` queued with `$1817`): tied to the
  Improvement's split of those two messages; in the translation `1816` runs on into
  `1817` as it should.
* **The camera**: already `centered_camera` (same values).

## Not yet seen in the emulator

The fast walking is. The others are byte-identical to the Improvement or its code moved
into a hook, and every check passes, but nobody has watched: the first battle cursor,
SHINB against a biomonster, Toader, B+C over NEXT, the Jet Scooter getting on and off,
the Central Tower storage, the Kueri inventor after the gum, the field SAR/SAK sounds,
Menobe, the Mechoman missile, the post-game prologue, the radar, Van Leader, the new items
in shops and chests.
