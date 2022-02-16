# Patch Notes

## ViewModel Update & Cooldown Fix
### 07/02/2022
+ **FIX** : Sound spam while holding **USE** key on keycard accesses buttons : involves the addition of a **0.8s cooldown** (configurable) on player using a configured doors/buttons

### 09/02/2022
+ **MAJOR ADD** : Improved renderer configuration on each SWEP, allowing usage of **ViewModels and WorldModels** instead of being restricted by **SWEP:Construction Kit** renderer
+ **ADD** : LMB now simulate a USE key
+ **ADD** : LMB SWEP ViewModel Animation (**ACT_VM_PRIMARYATTACK**)
+ **MINOR REFACTORING** : Renamed and localized `table.FullCopy` function from **SWEP:CK** code to `table_FullCopy`

### 10/02/2022
+ **ADD** : SWEP ViewModel **Holster & Equip Animations** (**ACT_VM_DRAW** & **ACT_VM_HOLSTER**)
+ **ADD** : Add **Save & Load buttons** on Configuration SWEP's menu 
+ **ADD** : Add **Confirmation Messages** on **Save & Load** for admin players

### 16/02/2022
+ **FIX** : Applying levels `+7` with the SWEP `guthscp_keycards_config` were truncated by the network optimization
+ **FIX** : Set the current level applied by the SWEP `guthscp_keycards_config` to it