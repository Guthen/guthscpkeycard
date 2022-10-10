local MODULE = {
	name = "Keycard",
	author = "Guthen",
	version = "2.0.0",
	description = [[Control the accesses of the facility through accreditation keycards.]],
	icon = "icon16/vcard.png",
	version_url = "https://raw.githubusercontent.com/Guthen/guthscpkeycard/update-to-guthscpbase-remaster/lua/guthscp/modules/guthscpkeycard/main.lua",
	dependencies = {
		base = "2.0.0",
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
			{
				type = "Category",
				name = "General",
			},
			{
				type = "CheckBox",
				name = "Use only Active Keycard",
				id = "use_only_active_keycard",
				desc = "If checked, only the active keycard weapon is used. Otherwise, the active keycard will be used in priority but, if any, the higher keycard in the inventory will be used.",
				default = true,
			},
			{
				type = "NumWang",
				name = "Use Cooldown",
				id = "use_cooldown",
				desc = "Cooldown in seconds before being able to use an accredidated door/button again",
				default = .8,
				decimals = 2,
			},
			{
				type = "TextEntry[]",
				name = "Keycard Available Classes",
				id ="keycard_available_classes",
				desc = "Set of entity classes which an accreditation level can be set",
				default = {
					["func_button"] = true,
					["class C_BaseEntity"] = true,
				},
				value = function( v, k )
					if isnumber( k ) then
						return v
					end

					return k
				end,
			},
			--  sounds
			{
				type = "Category",
				name = "Sounds",
			},
			{
				type = "TextEntry",
				name = "Accepted",
				id ="sound_accepted",
				desc = "Sound played on the player whose access was accepted",
				default = "guthen_scp/interact/KeycardUse1.ogg",
			},
			{
				type = "TextEntry",
				name = "Denied",
				id = "sound_denied",
				desc = "Sound played on the player whose access was denied",
				default = "guthen_scp/interact/KeycardUse2.ogg",
			},
			guthscp.config.create_apply_button(),
			guthscp.config.create_reset_button(),
		},
		parse = function( form )
			if #form.keycard_available_classes > 0 then
				form.keycard_available_classes = guthscp.table.create_set( form.keycard_available_classes )
			end
		end,
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
			url = "https://steamcommunity.com/sharedfiles/filedetails/?id=1781514401"
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
	self.path = self.id .. "/" .. game.GetMap() .. ".json"

	--  porting old save file 
	local map_name = game.GetMap()
	local path = "guth_scp/" .. map_name .. "/keycards.txt"
	if file.Exists( path, "DATA" ) then 
		guthscp.data.move_file( path, self.path )
	end
end

guthscp.module.hot_reload( "guthscpkeycard" )
return MODULE
