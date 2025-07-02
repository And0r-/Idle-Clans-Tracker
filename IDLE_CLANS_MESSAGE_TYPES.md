# Idle Clans - Message Types Documentation

Diese Dokumentation beschreibt alle bekannten Message-Typen aus den Clan-Logs der Idle Clans API.

Basierend auf der Analyse von **6419 Messages** aus **26 aktiven Clans** (Stand: Juli 2025).

## Notation

- `{spieler}` = Spielername (z.B. "Obstii", "KaynersMajic")
- `{clan}` = Clan-Name (z.B. "RosaEinhorn", "EllisDon")
- `{number}` = Numerischer Wert
- `{item}` = Item/Gegenstand-Name
- `{boss}` = Boss-Name
- `{skill}` = Skill-Name (z.B. "combat", "skilling")
- `{modifier}` = Modifier-Typ (z.B. "LootRolls", "AttackSpeed")

---

## 1. CLAN MEMBERSHIP CHANGES 👥

### 1.1 Member Joined
**Pattern:** `{spieler} has joined the clan: {clan}`

**Beispiele:**
- `Pentakilo2 has joined the clan: EllisDon`
- `swoogiebear has joined the clan: EllisDon`
- `Ikerai has joined the clan: IdlePumpkin`

### 1.2 Member Left
**Pattern:** `{spieler} left the clan: {clan}`

**Beispiele:**
- `Keane2703 left the clan: EllisDon`
- `xTofu left the clan: TeamStillNotaBot`
- `Queen left the clan: Dundee`

### 1.3 Member Kicked
**Pattern:** `{spieler} has kicked {spieler} from the clan.`

**Beispiele:**
- `Obstii has kicked Erzwoddler from the clan.`
- `CombatG has kicked Alemi from the clan.`
- `K2LPIE has kicked WilliamCz from the clan.`

---

## 2. RANK CHANGES ⬆️⬇️

### 2.1 Promotion
**Pattern:** `{spieler} has promoted {spieler}`

**Beispiele:**
- `CombatG has promoted Wowizzy`
- `xboxmw33 has promoted xboxmw3`
- `WowizzyAlt1 has promoted WowizzyAlt`

### 2.2 Demotion
**Pattern:** `{spieler} has demoted {spieler}.`

**Beispiele:**
- `Ozarkz has demoted WowizzyAlt1.`

---

## 3. TRANSACTIONS 💰

### 3.1 Donations (Added Items)
**Pattern:** `{spieler} added {number}x {item}.`

**Beispiele:**
- `Dubzixi added 376558x Gold.`
- `Pentakilo2 added 1x Raw salmon.`
- `xboxmw3 added 1x Otherworldly gemstone.`
- `Ragnaroek added 2617026x Gold.`

### 3.2 Withdrawals
**Pattern:** `{spieler} withdrew {number}x {item}.`

**Beispiele:**
- `lemoniscooI withdrew 1x Outstanding crafting needle.`
- `CombatG withdrew 1029x Steel arrow.`
- `KaynersMajic withdrew 628771x Gold.`
- `mrcollins withdrew 994964x Gold.`

---

## 4. VAULT PERMISSIONS 🔐

### 4.1 Vault Access Granted
**Pattern:** `{spieler} gave vault access to {spieler}.`

**Beispiele:**
- `Nonamerr gave vault access to Nonameiii.`
- `Wildwolf59 gave vault access to Ikerai.`
- `WowizzyAlt gave vault access to WowizzyAlt1.`

---

## 5. CLAN MANAGEMENT ⚙️

### 5.1 Language Setting
**Pattern:** `{spieler} set the clan's primary language to {language}`

**Beispiele:**
- `Nion set the clan's primary language to Spanish`

### 5.2 Recruitment State
**Pattern:** `{spieler} set the clan's recruitment state to {state}`

**States:** `True`, `False`

**Beispiele:**
- `Nion set the clan's recruitment state to True`
- `Wowizzy set the clan's recruitment state to False`

### 5.3 Level Requirements
**Pattern:** `{spieler} set the clan's total level requirement to {number}`

**Beispiele:**
- `VettigeDas set the clan's total level requirement to 100`
- `dundeehitman set the clan's total level requirement to 500`
- `Notsweatn set the clan's total level requirement to 1750`

### 5.4 Recruitment Message
**Pattern:** `{spieler} updated the clan's recruitment message.`

**Beispiele:**
- `VettigeDas updated the clan's recruitment message.`
- `Swazema updated the clan's recruitment message.`

---

## 6. BOSS MODIFIERS 🐉

### 6.1 Boss Modifier Purchase
**Pattern:** `Purchased modifier {modifier} for boss {boss}. Tier: {number}`

**Bekannte Modifier:**
- `LootRolls`
- `AttackSpeed`

**Bekannte Bosse:**
- `MalignantSpider`
- `SkeletonWarrior`
- `OtherWorldlyGolem`

**Tier-Range:** 1-4

**Beispiele:**
- `Purchased modifier LootRolls for boss MalignantSpider. Tier: 2`
- `Purchased modifier AttackSpeed for boss SkeletonWarrior. Tier: 1`
- `Purchased modifier AttackSpeed for boss OtherWorldlyGolem. Tier: 4`

---

## 7. CLAN UPGRADES 🔧

### 7.1 Upgrade Purchase
**Pattern:** `{spieler} bought the upgrade {upgrade_name}`

**Bekannte Upgrades:**
- `More crafting`
- `Line the turkeys up`
- `Turkey chasers`
- `Potioneering`
- `Gatherers`
- `More gathering`

**Beispiele:**
- `Kerle bought the upgrade More crafting`
- `Grimaxe bought the upgrade Line the turkeys up`
- `BlackDee bought the upgrade Potioneering`

---

## 8. EVENTS 🎮 (ENTFERNT)

**Pattern:** `{spieler} has started a {event_type} event with {number} participant.`

**Bekannte Event-Typen:**
- `CombatBigExpDaily`
- `Gathering`
- `[weitere Event-Typen...]`

**Hinweis:** Event-Nachrichten wurden aus der Analyse entfernt, da sie sehr häufig sind (4472 von 6419 Messages) und für Discord-Benachrichtigungen irrelevant.

---

## 9. QUESTS 🗡️ (ENTFERNT)

**Pattern:** `{spieler} completed a {quest_type} quest!`

**Bekannte Quest-Typen:**
- `combat`
- `skilling`

**Hinweis:** Quest-Nachrichten wurden aus der Analyse entfernt (759 Messages), da sie sehr häufig sind und für Discord-Benachrichtigungen irrelevant.

---

## DISCORD INTEGRATION EMPFEHLUNGEN 🔔

### ✅ INCLUDE Keywords (für Benachrichtigungen)

**Clan-Mitgliedschaft:**
- `has joined the clan:` - Neue Mitglieder
- `left the clan:` - Mitglieder verlassen
- `has kicked` - Mitglieder gekickt

**Rang-Änderungen:**
- `has promoted` - Beförderungen
- `has demoted` - Degradierungen

### ❌ EXCLUDE Keywords (Spam verhindern)

**Häufige Aktivitäten:**
- `added` - Spenden (sehr häufig)
- `withdrew` - Abhebungen (sehr häufig)
- `completed a` - Quests (bereits entfernt)
- `has started a` - Events (bereits entfernt)
- `Purchased modifier` - Boss-Modifier (häufig)
- `bought the upgrade` - Clan-Upgrades
- `gave vault access` - Vault-Berechtigungen

---

## STATISTIKEN

**Datengrundlage:**
- 26 aktive Clans analysiert
- 6419 ursprüngliche Messages
- 4472 Event-Messages entfernt
- 759 Quest-Messages entfernt
- 1188 Messages für weitere Analyse

**Häufigste Message-Typen (geschätzt):**
1. Events (~70% der ursprünglichen Messages)
2. Quests (~12% der ursprünglichen Messages)
3. Transaktionen (added/withdrew) (~15% der verbleibenden Messages)
4. Clan-Mitgliedschaft-Änderungen (~2% der verbleibenden Messages)

---

---

## FINALE STATISTIKEN (NACH VOLLSTÄNDIGER ANALYSE)

**Datengrundlage:**
- 26 aktive Clans analysiert
- 6419 ursprüngliche Messages

**Gefilterte Message-Typen:**
- 4472 Event-Messages entfernt (`has started a .* event with .* participant`)
- 759 Quest-Messages entfernt (`completed a .* quest!`)
- 28 Boss-Modifier entfernt (`Purchased modifier .* for boss .* Tier:`)
- 495 Transaktionen entfernt (`added/withdrew`)

**Verbleibende 264 Discord-relevante Messages:**
- ✅ 71 Clan-Beitritte (`has joined the clan:`)
- ✅ 57 Clan-Austritte (`left the clan:`)
- ✅ 50 Kicks (`has kicked .* from the clan`)
- ✅ 37 Beförderungen (`has promoted`)
- ✅ 2 Degradierungen (`has demoted`)
- ✅ 19 Clan-Einstellungen (`set the clan's`)
- ✅ 13 Vault-Berechtigungen (`gave vault access`)
- ✅ 8 Upgrade-Käufe (`bought the upgrade`)
- ✅ 7 Recruitment-Messages (`updated the clan's recruitment message`)

**Verifizierte Upgrade-Typen:**
- `Gatherers` (1x)
- `Line the turkeys up` (2x)
- `More crafting` (1x)
- `More gathering` (1x)
- `Potioneering` (1x)
- `Turkey chasers` (2x)

**Verifizierte Clan-Settings:**
- `primary language to {language}` (Spanisch bestätigt)
- `recruitment state to {True/False}`
- `total level requirement to {0-1750}`

---

**Erstellt:** Juli 2025  
**Basis:** 6419 Messages aus 26 aktiven Clans  
**Analysiert:** 264 Discord-relevante Messages  
**Status:** ✅ Vollständig verifiziert und dokumentiert