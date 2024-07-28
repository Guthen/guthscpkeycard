local MODULE = {
	name = "Keycard",
	author = "Guthen",
	version = "2.1.3",
	description = [[Control the accesses of the facility through accreditation keycards.]],
	icon = "icon16/vcard.png",
	version_url = "https://raw.githubusercontent.com/Guthen/guthscpkeycard/master/lua/guthscp/modules/guthscpkeycard/main.lua",
	dependencies = {
		base = "2.2.0",
	},
	requires = {
		["shared.lua"] = guthscp.REALMS.SHARED,
		["server.lua"] = guthscp.REALMS.SERVER,
		["client.lua"] = guthscp.REALMS.CLIENT,
	},
}

MODULE.menu = {
	--  config
	config = {
		form = {
			"General",
			{
				type = "Bool",
				name = "Droppable Keycards",
				id = "droppable_keycards",
				desc = "If checked, keycards can be dropped with a right click while holding them",
				default = true,
			},
			{
				type = "Bool",
				name = "Use only Selected Keycard",
				id = "use_only_selected_keycard",
				desc = "If checked, only the selected keycard weapon is used. Otherwise, the selected keycard will still be used in priority but, if any, the higher keycard in the inventory will be used.",
				default = true,
			},
			{
				type = "Bool",
				name = "Custom Holster System",
				id = "custom_holster_system",
				desc = "If checked, the custom holstering system is enabled. When switching weapons from keycards, it'll play their holster animations (if possible) and wait for the animation to finish before switching to the next weapon. Disabling it may resolve problems where the keycards can NOT be switched from.",
				default = true,
			},
			{
				type = "Number",
				name = "Use Cooldown",
				id = "use_cooldown",
				desc = "Cooldown in seconds before being able to use an accredidated door/button again",
				default = .8,
				decimals = 2,
			},
			{
				type = "String[]",
				name = "Keycard Available Classes",
				id = "keycard_available_classes",
				desc = "Set of entity classes which an accreditation level can be set. You should avoid touching it. Moreover, the game classes are not synced properly, for instance, a 'func_button' entity can return a 'class C_BaseEntity' client-side (which is the only reason why it's in this list by default). Furthermore, the game's raycast can NOT return the same entity server & client sides, for example, looking at a door will return a 'func_door' entity client-side but a 'prop_dynamic' entity server-side.\nThat's why you shouldn't lose your time with this option.",
				default = {
					["func_button"] = true,
					["class C_BaseEntity"] = true,
					["func_rot_button"] = true,
				},
				is_set = true,
			},
			--  translations
			"Translations",
			{
				type = "String",
				name = "Accepted",
				id = "translation_accepted",
				desc = "Text shown to the player whose access was accepted",
				default = "The doors are moving!",
			},
			{
				type = "String",
				name = "No Keycard",
				id = "translation_no_keycard",
				desc = "Text shown to the player whose access was denied because he doesn't have a keycard",
				default = "You don't have any keycard to pass!",
			},
			{
				type = "String",
				name = "Insufficient Clearance",
				id = "translation_insufficient_clearance",
				desc = "Text shown to the player whose access was denied because he doesn't have a sufficient clearance keycard. Available arguments: '{level}'",
				default = "You need a keycard LVL {level} to trigger the doors!",
			},
			{
				type = "String",
				name = "HUD Level",
				id = "translation_hud_level",
				desc = "Text shown when hovering the cursor on a door access. Available arguments: '{level}'",
				default = "LEVEL: {level}",
			},
			--  sounds
			"Sounds",
			{
				type = "String",
				name = "Accepted",
				id = "sound_accepted",
				desc = "Sound played on the player whose access was accepted",
				default = "guthen_scp/interact/KeycardUse1.ogg",
			},
			{
				type = "String",
				name = "Denied",
				id = "sound_denied",
				desc = "Sound played on the player whose access was denied",
				default = "guthen_scp/interact/KeycardUse2.ogg",
			},
		},
	},
	--  details
	details = {
		{
			text = "CC-BY-SA",
			icon = "icon16/page_white_key.png",
		},
		"Wiki",
		{
			text = "Read Me",
			icon = "icon16/information.png",
			url = "https://github.com/Guthen/guthscpkeycard/blob/master/README.md",
		},
		"Social",
		{
			text = "Github",
			icon = "guthscp/icons/github.png",
			url = "https://github.com/Guthen/guthscpkeycard",
		},
		{
			text = "Steam",
			icon = "guthscp/icons/steam.png",
			url = "https://steamcommunity.com/sharedfiles/filedetails/?id=3034740776"
		},
		{
			text = "Discord",
			icon = "guthscp/icons/discord.png",
			url = "https://discord.gg/Yh5TWvPwhx",
		},
		{
			text = "Ko-fi",
			icon = "guthscp/icons/kofi.png",
			url = "https://ko-fi.com/vyrkx",
		},
	},
}

function MODULE:init()
	local map_name = game.GetMap()
	self.path = self.id .. "/" .. map_name .. ".json"

	--  porting old save file 
	local path = "guth_scp/" .. map_name .. "/keycards.txt"
	if file.Exists( path, "DATA" ) then
		guthscp.data.move_file( path, self.path )
	end

	--  warn for old version
	timer.Simple( 0, function()
		if GuthSCP and GuthSCP.registerKeycardSWEP then
			local text = "The old version of this addon is currently running on this server. Please, delete the '[SCP] Keycard System by Guthen' addon to avoid any possible conflicts."
			self:add_error( text )
			self:error( text )
		end
	end )
end

guthscp.module.hot_reload( "guthscpkeycard" )
return MODULE
