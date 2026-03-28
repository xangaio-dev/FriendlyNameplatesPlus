# FriendlyNameplatesPlus v12.0.2

**Automatically shows or hides friendly nameplates based on your location, instance type, or special scenarios in World of Warcraft.**  
FriendlyNameplatesPlus dynamically adjusts the visibility of friendly player and minion nameplates according to your settings and current map/instance.

---

## Features

- Show/hide friendly nameplates automatically **in the world**
- Show/hide friendly nameplates **in cities**
- Show/hide friendly nameplates **in delves (scenarios/dungeons)**
- Show/hide friendly nameplates **in instances (party, raid, PvP)**
- Optional display of friendly **player minions** in delves
- Fully configurable via **slash commands**
- Per-character saved settings

---

## Installation

1. Download the `FriendlyNameplatesPlus` folder and place it in your `World of Warcraft/_retail_/Interface/AddOns/` directory.
2. Ensure the folder contains:
   - `FriendlyNameplatesPlus.lua`
   - `FriendlyNameplatesPlus.toc`
3. Reload UI or restart the game.

---

## Slash Commands

| Command                      | Description                                                 |
| ---------------------------- | ----------------------------------------------------------- |
| `/fnp help`                  | Show available commands                                     |
| `/fnp show`                  | Display current addon settings                              |
| `/fnp zone`                  | Evaluate current zone and apply rules (debug mode optional) |
| `/fnp enable <true/false>`   | Enable or disable automation                                |
| `/fnp world <true/false>`    | Enable/disable nameplates in the world                      |
| `/fnp city <true/false>`     | Enable/disable nameplates in cities                         |
| `/fnp delves <true/false>`   | Enable/disable nameplates in delves/scenarios               |
| `/fnp instance <true/false>` | Enable/disable nameplates in instances (party/raid/PvP)     |
| `/fnp debug <true/false>`    | Enable/disable debug messages in chat                       |

---

## Default Settings

| Setting        | Default |
| -------------- | ------- |
| Enabled        | true    |
| ShowInWorld    | true    |
| ShowInCity     | false   |
| ShowInDelves   | true    |
| ShowInInstance | false   |
| DebugEnabled   | false   |

---

## Behavior Rules
1. World: Shown when outside instances/cities/delves if showInWorld is true.
2. City: Automatically detects capital cities using map IDs; controlled via showInCity.
3. Delves (Scenarios/Dungeons): Friendly minions are optionally shown if showInDelves is true.
4. Instances (Party, Raid, PvP): Visibility controlled via showInInstance.
5. Combat Safety: Changes are blocked in combat and applied afterward automatically.

---

## Release Notes
**v12.0.2** 
- Fixed an issue where friendly nameplates were not updating correctly after leaving combat

**v12.0.1**  
- Replaced map-based city detection with IsResting() for reliable, maintenance-free behavior across all hubs
- Removed dependence on map IDs and C_Map.IsCityMap
- Added UPDATE_EXHAUSTION event trigger to detect changes in rested status.
- Improved debug safety and code readability 

**v12.0.0**  
- ✅ Compatible with **Midnight Expansion**  
- Dynamic city detection and map-based visibility
- Pending state system ensures changes are safe during combat
- Fully configurable slash commands `/fnp`
- Debug mode for troubleshooting

---
