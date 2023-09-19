# [GuthSCP] Keycard

## Steam Workshop
![Steam Views](https://img.shields.io/steam/views/3034740776?color=red&style=for-the-badge)
![Steam Downloads](https://img.shields.io/steam/downloads/3034740776?color=red&style=for-the-badge)
![Steam Favorites](https://img.shields.io/steam/favorites/3034740776?color=red&style=for-the-badge)

This addon is available on the Workshop [here](https://steamcommunity.com/sharedfiles/filedetails/?id=3034740776)!

## Features
+ Containing **7 SWEPs** including **6 keycards** (levels 1, 2, 3, 4, 5 and Omni) and a Master Card (absolutely useless)
+ **Restrict certains areas** of your map for specific accreditations
+ **Keycard Configurator** tool to set levels on buttons across the map
+ Keycards data is **automatically loaded** on **start-up** or after **a map cleanup**
+ Configurable in-game with [[GuthSCP] Base](https://steamcommunity.com/sharedfiles/filedetails/?id=3034737316) (`guthscp_menu` in your console)
    + **Custom Behaviours**: dropping keycards with RMB, auto-use highest keycard in inventory
    + **Translations** texts
    + **Sound** paths
    + *and more..*
+ **Requires a Sandbox-based gamemode** (e.g. Sandbox, DarkRP) for tool use 

## Commands
+ `guthscp_keycards_save` (server & client): Save the map data to a file, you must **save after setting up accreditations to make the changes persistent**
+ `guthscp_keycards_load` (server & client): Load the map data from a file, not needed since it's already loaded automatically

## Extra Add-ons
• ~~[[SCP] Hacking Device by zgredinzyyy](https://steamcommunity.com/sharedfiles/filedetails/?id=2019852698)~~ *(not compatible yet)*

## Known Issues
### "I can open an accredidated door without a keycard!" 
Some addons ─ which use the **PlayerUse** hook poorly ─ conflict with my addon. This [Piano](https://steamcommunity.com/sharedfiles/filedetails/?id=796397853) addon is one of those, enable the work-around `Fix 'Playable Piano' conflicting the 'PlayerUse' hook` in the `Base` configuration page (`guthscp_menu` in your game's console).

## Legal Terms
This addon is licensed under [Creative Commons Sharealike 3.0](https://creativecommons.org/licenses/by-sa/3.0/) and is based on content of [SCP Foundation](http://scp-wiki.wikidot.com/) and [SCP:Containment Breach](https://www.scpcbgame.com/).

If you create something derived from this, please credit me (you can also tell me about what you've done).

***Enjoy !***