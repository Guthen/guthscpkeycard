if not guthscp then return end

local guthscpkeycard = guthscp.modules.guthscpkeycard
local config = guthscp.configs.guthscpkeycard


TOOL.Category = "guthscp"
TOOL.Name = "#tool.guthscp_keycard_configurator.name"

TOOL.ClientConVar = {
	level = 1,
	title = "",
}

--  languages
if CLIENT then
	--  information
	TOOL.Information = {
		{ 
			name = "left",
		},
		{
			name = "right",
		},
		{
			name = "reload",
		},
	}

	--  language
	language.Add( "tool.guthscp_keycard_configurator.name", "Keycard Configurator" )
	language.Add( "tool.guthscp_keycard_configurator.desc", "Set the accesses of doors & buttons through the entire facility." )
	language.Add( "tool.guthscp_keycard_configurator.left", "Set to selected Level & Title" )
	language.Add( "tool.guthscp_keycard_configurator.right", "Erase data" )
	language.Add( "tool.guthscp_keycard_configurator.reload", "Copy data" )

	language.Add( "tool.guthscp_keycard_configurator.level", "Level" )
	language.Add( "tool.guthscp_keycard_configurator.title", "Title" )
	language.Add( "tool.guthscp_keycard_configurator.io", "Data Management" )
	language.Add( "tool.guthscp_keycard_configurator.save", "Save Data" )
	language.Add( "tool.guthscp_keycard_configurator.load", "Load Data" )

	--  context panel
	local convars_default = TOOL:BuildConVarList()
	function TOOL.BuildCPanel( cpanel ) 
		cpanel:AddControl( "Header", { Description = "#tool.guthscp_keycard_configurator.desc" } )

		--  presets
		cpanel:AddControl( "ComboBox", { 
			MenuButton = 1, 
			Folder = "button", 
			Options = { 
				["#preset.default"] = ConVarsDefault 
			}, 
			CVars = table.GetKeys( convars_default ) 
		} )

		--  level
		cpanel:AddControl( "Slider", { 
			Label = "#tool.guthscp_keycard_configurator.level", 
			Command = "guthscp_keycard_configurator_level", 
			Min = 1, 
			Max = guthscp.modules.guthscpkeycard.max_keycard_level 
		} )
		--  title
		cpanel:AddControl( "TextBox", { 
			Label = "#tool.guthscp_keycard_configurator.title", 
			Command = "guthscp_keycard_configurator_title", 
			MaxLenth = "32" 
		} )

		--  save & load
		cpanel:AddControl( "Label", { 
			Text = "#tool.guthscp_keycard_configurator.io",
		} )
		cpanel:AddControl( "Button", { 
			Label = "#tool.guthscp_keycard_configurator.save", 
			Command = "guthscp_keycards_save",
		} )
		cpanel:AddControl( "Button", { 
			Label = "#tool.guthscp_keycard_configurator.load", 
			Command = "guthscp_keycards_load",
		} )
	end

	local color_red = Color( 255, 0, 0 )
	function TOOL:DrawHUD()
		local x, y = ScrW() / 2, ScrH() * .75

		--  get tool trace
		local tr = util.GetPlayerTrace( LocalPlayer() )
		tr.mask = toolmask
		local trace = util.TraceLine( tr )
		local ent = trace.Entity

		if IsValid( ent ) then
			local text_info = nil
			local can_be_used = config.keycard_available_classes[ent:GetClass()]

			--  alert from FPP prohibition 
			if FPP and not FPP.canTouchEnt( ent, "Toolgun" ) then
				text_info = "Falco's Prop Protection prevent you from editing this entity, please enable 'Admins can use tool on blocked entities' in its 'Toolgun options'!"
			end
			
			--  alert from unused class
			if not text_info and not can_be_used then
				local concat = ""
				
				for class in pairs( config.keycard_available_classes ) do
					concat = concat .. ( "'%s'" ):format( class ) .. ( next( config.keycard_available_classes, class ) and ", " or "" )
				end

				text_info = "The target entity class must be one of these: " .. concat
			end

			--  draw entity
			draw.SimpleText( "Target: " .. tostring( ent ), "Trebuchet24", x, y, can_be_used and color_white or color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			
			--  draw additional info
			if text_info then
				draw.SimpleText( text_info, "DermaDefaultBold", x, y + 30, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
		else
			draw.SimpleText( "Target: none", "Trebuchet24", x, y, color_red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
end

--  add access
function TOOL:LeftClick( tr )
	local ply = self:GetOwner()
	
	--  check compatible entity
	local ent = tr.Entity  --  TOOL's TraceResult don't care about world entities
	if not IsValid( ent ) or not config.keycard_available_classes[ent:GetClass()] then return false end
	
	if SERVER then
		--  setup data
		local level, title = self:GetClientNumber( "level", 1 ), self:GetClientInfo( "title" )
		ent:SetNWInt( "guthscpkeycard:level", level )
		ent:SetNWString( "guthscpkeycard:title", title )
	
		--  notify
		ply:ChatPrint( "The looked entity has been set on LVL " .. level )
	end
	
	return true
end

--  remove access
function TOOL:RightClick( tr )
	local ply = self:GetOwner()

	--  check compatible entity
	local ent = ply:GetEyeTrace().Entity
	if not IsValid( ent ) or not config.keycard_available_classes[ent:GetClass()] then return false end

	if SERVER then
		--  erase data
		ent:SetNWInt( "guthscpkeycard:level", 0 )
		ent:SetNWString( "guthscpkeycard:title", "" )

		--  notify
		ply:ChatPrint( "The looked entity's data has been erased!" )
	end

	return true
end

--  copy data
function TOOL:Reload( tr ) 
	local ply = self:GetOwner()
	if not IsFirstTimePredicted() then return true end

	--  check compatible entity
	local ent = ply:GetEyeTrace().Entity
	if not IsValid( ent ) or not config.keycard_available_classes[ent:GetClass()] then return false end

	if CLIENT then
		--  get data
		local level = ent:GetNWInt( "guthscpkeycard:level", 0 )
		local title = ent:GetNWString( "guthscpkeycard:title", "" )

		--  apply data
		GetConVar( self:GetMode() .. "_level" ):SetInt( level )
		GetConVar( self:GetMode() .. "_title" ):SetString( title )

		--  notify
		ply:ChatPrint( "The looked entity's data has been copied to your settings!" )
	end

	return true
end