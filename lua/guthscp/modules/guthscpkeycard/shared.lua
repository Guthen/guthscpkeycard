local guthscpkeycard = guthscp.modules.guthscpkeycard


--  auto-filled variables
guthscpkeycard.keycard_sweps = guthscpkeycard.keycard_sweps or {}
guthscpkeycard.max_keycard_level = guthscpkeycard.max_keycard_level or 0
guthscpkeycard.NET_KEYCARD_LEVEL_UBITS = guthscpkeycard.NET_KEYCARD_LEVEL_UBITS or 1

--  get max keycard level
function guthscpkeycard.register_keycard_swep( swep, level )
	if not level then
		assert( isnumber( swep.GuthSCPLVL ), "The field 'GuthSCPLVL' of this SWEP must be a number" )
	else
		swep.GuthSCPLVL = level
	end

	--  register swep
	if not table.HasValue( guthscpkeycard.keycard_sweps, swep ) then
		guthscpkeycard.keycard_sweps[#guthscpkeycard.keycard_sweps + 1] = swep
		guthscpkeycard.max_keycard_level = math.max( guthscpkeycard.max_keycard_level or 0, swep.GuthSCPLVL )
		guthscpkeycard.NET_KEYCARD_LEVEL_UBITS = guthscp.helpers.number_of_ubits( guthscpkeycard.max_keycard_level )
	end

	--  add to spawnmenu
	if CLIENT then
		guthscp.spawnmenu.add_weapon( swep, "Keycards" )
	end

	--  hot reload
	if SERVER then
		timer.Simple( 0, function()
			for i, v in ipairs( ents.FindByClass( swep.Folder:gsub( "weapons/", "" ) ) ) do
				local ply = v:GetOwner()
				if not IsValid( ply ) then continue end

				local class = v:GetClass()
				ply:StripWeapon( class )
				ply:Give( class )
				ply:SelectWeapon( class )
			end
		end )
	end
end

function guthscpkeycard.get_entity_level( ent )
	return ent:GetNWInt( "guthscpkeycard:level", -1 )
end

function guthscpkeycard.get_entity_title( ent )
	return ent:GetNWString( "guthscpkeycard:title", "" )
end

--  holst weapon when animation is finished
hook.Add( "StartCommand", "guthscpkeycard:holst_animated_weapon", function( ply, ucmd )
	if not guthscp.configs.guthscpkeycard.custom_holster_system then return end

	local weapon = ply:GetActiveWeapon()
	if not IsValid( weapon ) or weapon.Base ~= "guthscp_keycard_base" then return end
	if not IsValid( weapon.HolstingWeapon ) or weapon.HolstingTime == 0 or weapon.HolstingTime > CurTime() then return end

	weapon.HolstingDone = true
	weapon.HolstingTime = 0
	ucmd:SelectWeapon( weapon.HolstingWeapon )
	weapon.HolstingWeapon = NULL
end )

--  concommands
concommand.Add( "guthscp_keycards_save", function( ply )
	if CLIENT then
		net.Start( "guthscpkeycard:io" )
			net.WriteBool( true )
		net.SendToServer()
		return
	end

	guthscpkeycard.save()
end )

concommand.Add( "guthscp_keycards_load", function( ply )
	if CLIENT then
		net.Start( "guthscpkeycard:io" )
			net.WriteBool( false )
		net.SendToServer()
		return
	end

	guthscpkeycard.load()
end )
