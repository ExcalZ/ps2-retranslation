================================================================================

  PHANTASY STAR II
  English Retranslation

  Version @VERSION@
  Release Date: @DATE@

  Author: Excalibur_Z
  Platform: Sega Genesis / Mega Drive

================================================================================


--------------------------------------------------------------------------------
  1. ABOUT THIS PATCH
--------------------------------------------------------------------------------

This patch is a new English translation of Phantasy Star II, made from the
Japanese script rather than from the 1989 US localization. It is an
unofficial fan project and is not affiliated with or endorsed by SEGA.

The 1989 release had to fit its English into a dialogue window of short,
fixed-width lines, a 255-byte limit per message and names of four or five
capital letters. Much of the original writing was cut or paraphrased to fit.
This patch rebuilds the text engine so that the game can carry a translation
of the Japanese script in full.

  WHAT IS TRANSLATED

  Dialogue ............ all of it, translated anew from the Japanese
  Narration ........... the prologue, the story narration and the ending
  Examine / shop text . translated
  Character profiles .. restored from the Japanese (birth dates included)
  Menus / system text . retranslated, in mixed case
  Names ............... items, techniques, enemies, places, jobs and the
                        soundtrack titles at their full length

  NAMES

Names follow the Japanese game. Where SEGA has since printed an official
English spelling, that spelling is used; names shared with Phantasy Star IV
are spelled as in the Phantasy Star IV retranslation; otherwise the katakana
is transliterated directly. Some of the changes players will notice first:

  Party:       Rolf -> Eusis (the default; you name him)
               Rudo -> Rudger          Amy  -> Anne
               Hugh -> Huey            Anna -> Amia
               Kain -> Kainz           Shir -> Silka
               Nei keeps her name.

  World:       Algo -> Algol           Mota -> Motavia
               Palm -> Palma           Dezo -> Dezolis
               Climatrol -> AMeDAS     Dark Force -> Dark Falz
               Alis -> Alisa           Lassic -> LaShiec
               Neifirst -> Nei-First   Ustvestia -> Avancino
               Teim -> Tiem

  Techniques:  Foi/Gifoi/Nafoi -> Foie/Gifoie/Nafoie
               Gra -> Gravt, Tsu -> Grants, Res -> Resta, Sar -> Saresta,
               Rever -> Reverser, Ryuka -> Ryuker, Musik -> Musica,
               and so on.

  Items:       Telepipe / Escapipe / Hidapipe -> Travel / Lost / Shinobi's
               Ocarina, Star Mist -> Star Atomizer, Moon Dew -> Moon
               Atomizer, and the Japanese armor names (Laconia Harnisch,
               Ceramic Fibrilla, Carbon Ärmel ...).

  WHAT CHANGED UNDER THE HOOD

  - Proportional (variable-width) text in the dialogue windows and in
    every menu window, in ordinary mixed-case English.
  - No length limit on a message: the script is stored apart from the
    original data and expanded one page at a time. This also removes the
    original game's text buffer overrun in Lutz's long speech (the music
    freeze).
  - Item, technique, enemy and place names at their full length, and
    party names of up to six letters.
  - Menus in the style of Phantasy Star IV: a field menu with the party
    beside it, a status screen with portraits, an Equip screen that
    compares Attack, Defense and Agility, and weapon and armor shops that
    mark who can equip the highlighted item and show the comparison when
    you choose who will carry it.
  - Battle commands in the style of Phantasy Star IV: Auto-Combat,
    Command, Macro and Retreat. Eight macros (A-H) can be set from the
    field menu and are saved with the game. The battle technique list
    shows each technique's TP cost.
  - Damage and healing numbers over their targets, and a wider battle
    message box that can show two lines.
  - Options on the Start button while on the field: Battle Speed and
    Message Speed, 1 (fast) to 5 (slow), and Damage Flash On/Off (the
    red flash when the party is hit), saved with the game.
  - The title menu offers Continue first when there is a saved game.
  - The field camera keeps the party centred (EvilJagaGenius).
  - FlamePurge's Phantasy Star II Improvement v4.5, without its script:
    lory1990's bug fixes (hit rate and damage formulas, SHINB, running
    from bosses, the Jet Scooter, the Central Tower storage glitch and
    more), faster walking, faster battle flashes, the Improvement's
    rebalance of equipment, shops, chests and techniques, and the Gaira
    radar's planet names. Of its two optional addenda, double rewards
    is not included, and no red flash is the Damage Flash option.
  - A search-and-walk trick that skipped random encounters is closed.

  SAVED GAMES

Battery saves from the original game load in this version. The new
settings start at their defaults and the macro slots start empty.

  HOW IT WAS MADE

This translation was produced by a single author working with the AI
assistant Claude (Anthropic), which was used for script extraction, the
work on the disassembly, the variable-width text engines and the tooling
around them. Every line of the translation was reviewed by the author. The
build was exercised in an emulator through scripted scenarios covering the
field, shops, buildings, battle, status, equipment and technique screens,
checked by automated tests that hold every line to its window's width, and
verified over a full playthrough.


--------------------------------------------------------------------------------
  2. REQUIRED ROM
--------------------------------------------------------------------------------

Either US/European release of the cartridge works.

  Game:          Phantasy Star II (USA, Europe)
  Serial:        GM 00005501-02  (Rev A, (C)SEGA 1990.JAN)
  Size:          @SRC_SIZE@ bytes  (768 KB / 6 Mbit)
  Header:        none - plain headerless .bin / .md / .gen dump

  CRC32:         @SRC_CRC32@
  MD5:           @SRC_MD5@
  SHA-1:         @SRC_SHA1@

  or the first release:

  Serial:        GM 00005501-01  ((C)SEGA 1989.JUN)
  Size:          @R01_SIZE@ bytes

  CRC32:         @R01_CRC32@
  MD5:           @R01_MD5@
  SHA-1:         @R01_SHA1@

The two releases differ in 16 bytes (the header's date and revision, and the
order of two names in one list). Patcher.html accepts either and converts
the first release to Rev A before patching. With a conventional patcher,
use the patch file that matches your ROM (section 3).

The patch applies to these exact ROMs only. If your file has a different
size or checksum, the patching tool will refuse it. Interleaved .smd dumps
(786,944 bytes, with a 512-byte header) contain the same ROM in a different
byte order; Patcher.html handles them directly, other patchers need a plain
binary.

No ROM is included with this patch and none will be provided. You must
supply your own copy of the game.


--------------------------------------------------------------------------------
  3. HOW TO PATCH
--------------------------------------------------------------------------------

  EASIEST WAY: Patcher.html

    1. Open Patcher.html from this archive in any web browser.
       It works offline; nothing is uploaded anywhere.
    2. Drop your Phantasy Star II ROM onto the page, or click to choose
       it. Plain .bin / .md / .gen dumps AND interleaved .smd dumps of
       either release are accepted.
    3. The page checks that your ROM is a supported one, applies the
       patch and offers the result for saving - as a plain .bin or as
       an interleaved .smd, whichever your emulator or flash cart
       expects. Both hold the same game. Never overwrite your original
       ROM.

  WITH A CONVENTIONAL PATCHER

  Patch format:  BPS
  Patch files:   @PATCH@        for Rev A (CRC32 @SRC_CRC32@)
                 @PATCH01@  for the first release (CRC32 @R01_CRC32@)

  Both produce the same patched ROM.

  Recommended tool: Floating IPS (Flips)
                    https://www.romhacking.net/utilities/1040/

    1. Open Flips and choose "Apply Patch".
    2. Select the patch file for your ROM's release from this archive.
    3. Select your unmodified Phantasy Star II ROM as a plain binary
       (.bin / .md / .gen). Flips cannot convert .smd files - use
       Patcher.html for those.
    4. Save the result under a new file name.

  Alternatively, use an online BPS patcher such as the one on
  ROMhacking.net.

  BPS patches store a checksum of the source ROM. If the tool reports a
  mismatch, your ROM is not the expected release - see section 2.


--------------------------------------------------------------------------------
  4. VERIFYING THE RESULT
--------------------------------------------------------------------------------

  After patching, the file should match these values:

  Plain binary (.bin / .md / .gen):
  Size:          @OUT_SIZE@ bytes  (1 MB / 8 Mbit)
  CRC32:         @OUT_CRC32@
  MD5:           @OUT_MD5@
  SHA-1:         @OUT_SHA1@

  Interleaved .smd, as saved by Patcher.html:
  Size:          @SMD_SIZE@ bytes
  CRC32:         @SMD_CRC32@
  MD5:           @SMD_MD5@
  SHA-1:         @SMD_SHA1@

  The patched ROM is 1 MB, a quarter larger than the original: the new
  script, fonts and name tables follow the original data, which stays
  where SEGA put it. The Genesis maps the whole megabyte directly, so no
  mapper or bank switching is involved; the ROM end address in the header
  is set to @ROMEND@ accordingly.

  The internal Genesis checksum has been recalculated and is valid
  (@MDCHK@), so the patched ROM passes the console's own integrity check.

  The SRAM configuration is unchanged (8 KB at 0x200001-0x203FFF), so
  battery saves work exactly as in the original game.


--------------------------------------------------------------------------------
  5. TESTED ON
--------------------------------------------------------------------------------

  Emulator:      BlastEm 0.6.2

  This release has not been tested on real hardware. The image is a plain
  1 MB binary with the game's original SRAM mapping, which flash carts
  that run Phantasy Star II should accept, but this is unverified.
  Reports from EverDrive / Mega SG / Mega Everdrive owners are welcome.


--------------------------------------------------------------------------------
  6. KNOWN ISSUES
--------------------------------------------------------------------------------

  None known at release.

  Please report text bugs with a savestate or a description of where the
  passage appears, and any other problem with the emulator savestate and a
  note of what was on screen.


--------------------------------------------------------------------------------
  7. CREDITS
--------------------------------------------------------------------------------

  Translation, hacking, testing ......... Excalibur_Z
  Translation and technical support ..... Claude (Anthropic)

  Built on lory90's Phantasy Star II disassembly, distributed by
  Phantasy Star Cave, without which none of the engine work would have
  been practical.

  Phantasy Star II Improvement v4.5 ..... FlamePurge (the hack and its
                                          rebalance), lory1990 (the bug
                                          fixes, fast walking, the radar
                                          art), veo (fast battles),
                                          Fauntleroy (Van Leader);
                                          included at FlamePurge's
                                          invitation
  Centred field camera .................. EvilJagaGenius

  Tools ................................. AS macro assembler, BlastEm,
                                          custom Python tooling

  The original SEGA staff credits are preserved in full. No developer
  has been removed from or replaced in the in-game credit roll.

  Thanks to the ROMhacking.net community and Phantasy Star Cave for the
  documentation and utilities that made this project possible.


--------------------------------------------------------------------------------
  8. LEGAL
--------------------------------------------------------------------------------

  Phantasy Star II is copyright SEGA.
  This is an unofficial, non-commercial fan translation distributed as a
  patch file only. It contains no copyrighted game data.

  The patch may be freely redistributed as long as this readme is
  included and no fee is charged. Do not distribute pre-patched ROMs.


--------------------------------------------------------------------------------
  9. CONTACT
--------------------------------------------------------------------------------

  Discord ........... @Excalibur_Z
  Twitter ........... @ExcalZGaming


--------------------------------------------------------------------------------
  10. CHANGELOG
--------------------------------------------------------------------------------

  v@VERSION@  -  @DATE@
    - Fixed the title menu: with no saved game it showed garbage tiles
      instead of Start a New Game.
    - New Damage Flash toggle in the Start menu's Options.

  v1.0  -  07.10.2026  -  Initial release


================================================================================
