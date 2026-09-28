# Glossary and naming decisions

Decision (2026-09-23, the user): **the Japanese names throughout**, as in the Phantasy Star III
retranslation. The 1989 US names are listed for reference only; never reintroduce them in
`en`. When a name is not in this table yet, read the katakana in the `jp` field and add a
row here before using it.

Romanization follows SEGA's later official spellings where they exist (Phantasy Star
Generation:2, the Phantasy Star Portable / Online references, the Sega Ages releases),
otherwise the plain reading of the katakana.

## The party

| JP | this translation | US 1989 | full name in the JP script |
|---|---|---|---|
| ユーシス | Eusis (default; the player names him) | Rolf | - |
| ネイ | Nei | Nei | - |
| ルドガー | Rudger | Rudo | ルドガー・シュタイナー Rudger Steiner |
| アンヌ | Anne | Amy | アンヌ・サガ Anne Saga |
| ヒューイ | Huey | Hugh | ヒューイ・リーン Huey Lean |
| アーミア | Amia | Anna | アーミア・アミルスキー Amia Amirsky |
| カインズ | Kains | Kain | カインズ・ジ・アン Kains Ji An |
| シルカ | Shilka | Shir | シルカ・レビニア Shilka Levinia |

**Engine constraint:** the party-name field is four letters (`CharNameLength`, the RAM
names at `character_names`, the save data, the naming screen). Rudger, Kains, Shilka and
Eusis do not fit. Using them needs the name-length extension planned in `STATUS.md`;
until then the `charnames` table cannot hold them, while dialogue that names a party member
literally can already use the full names.

## Worlds and places

| JP | this translation | US 1989 |
|---|---|---|
| アルゴル | Algol | Algo |
| モタビア | Motavia | Mota |
| パルマ | Palma | Palm |
| デゾリス | Dezolis | Dezo |
| パセオ | Paseo | Paseo |
| ガイラ | Gaila | Gaila |
| ニド (のタワー) | Nido (Tower) | Nido |
| セントラルタワー | Central Tower | Central Tower |
| クローン・ラボ | Clone Lab | Clone Labs |
| テレポート・サービス | Teleport Service | Teleport Station |
| ドームファーム | Dome Farm | - |
| ライブラリ | Library | Library |
| アリマ (アリマーヤ?) | check the JP | Arima |
| オプタノ | Optano | Oputa |
| ゼマ | Zema | Zema |
| シュレーン | Shure? - check | Skure |

## Systems and things

| JP | this translation | US 1989 |
|---|---|---|
| マザーブレイン | Mother Brain | Mother Brain |
| バイオシステム | Biosystem | Biosystems lab |
| バイオモンスター | biomonster | monster |
| バイオハザード | biohazard | Biohazard |
| アメダス | AMeDAS - decide: the JP borrows the name of Japan's weather-observation network | Climatrol |
| システムレコーダー | System Recorder | recorder |
| データメモリー | Data Memory | data memory |
| ネイソード | Nei Sword | Neisword |
| マルエラツリー / マルエラガム / マルエラリーブ | Maruera tree / gum / leaf | Maruera |
| ジェットスクーター | Jet Scooter | Jet Scooter |
| プラズマリング | Plasma Ring | plasma rings |
| テクニック | technique | technique |
| メセタ | meseta | meseta |
| セキュリティシステム | security system | security system |
| ダム (グリーン, イエロー, レッド, ブルー) | the Green / Yellow / Red / Blue Dam | dam |

## People

| JP | this translation | US 1989 |
|---|---|---|
| アリサ | Alisa | Alis |
| ルツ | Lutz | Lutz |
| ダークファルス | Dark Falz | Dark Force |
| ネイ・ファースト | Nei First | Neifirst |
| ダラム | Darum | Darum |
| ティム | Tiem - check official | Teim |
| タイラー | Tyler | Tyler |
| ウスタビア? / ウステビア | check the JP | Ustvestia |
| ミャウ | Myau | Myau |
| タイロン | Tyrone? - check | - |
| ラシーク | Lashiec | Lassic |
| モタビアン / デゾリアン | Motavian / Dezolian | Motavian / Dezorian |

## Techniques (the JP names; 5-letter field today)

フォイエ Foie, ギフォイエ Gifoie, ナフォイエ Nafoie, ザン Zan, ギザン Gizan, ナザン Nazan,
グラブト Gra?, ... - fill in from `script.json` (`techs`). The technique records hold five
letters; the full names need a display-name table like the PS III retranslation's
`TechniqueNameData`.

## Style

* The Motavians end their sentences in ズラ and say オラ for "I": a rural dialect. Render
  it as a consistent light dialect, not the US "I'se glad ta see ya" caricature.
* Speaker labels follow the JP: quoted speech 「…」 becomes "…"; narration is plain.
* The Commander (そうとく) addresses the hero as ～くん: warm, senior; keep it in tone,
  not as an honorific.
