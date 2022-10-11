local guthscpkeycard = guthscp.modules.guthscpkeycard
local config = guthscp.configs.guthscpkeycard


util.AddNetworkString( "guthscpkeycard:config" )
util.AddNetworkString( "guthscpkeycard:io" )

--  functions
function guthscpkeycard.save( ply )
	--  serialize
	local data = {}
	for k, _ in pairs( config.keycard_available_classes ) do
		for _, v in ipairs( ents.FindByClass( k ) ) do -- add data to a table
			if v:GetNWInt( "guthscpkeycard:level", 0 ) <= 0 then continue end

			--  save entity
			data[#data + 1] = { 
				mapID = v:MapCreationID(), 
				lvl = v:GetNWInt( "guthscpkeycard:level", 0 ),
				title = v:GetNWString( "guthscpkeycard:title", nil ),
			}
		end
	end
	
	--  check data
	if #data == 0 then 
		return false, "keycards accesses not found" 
	end

	--  save to file
	guthscp.data.save_to_json( guthscpkeycard.path, data, true )

	guthscpkeycard:info( "all keycards have been saved (%d entities) %s", #data, ply and "by " .. ply:Name() or "" )
	return true, #data
end

function guthscpkeycard.load( ply )
	local accesses = guthscp.data.load_from_json( guthscpkeycard.path )
	if not accesses then return false, "file not found or corrupted" end

	--  de-serialize
	for i, v in ipairs( accesses ) do
		local ent = ents.GetMapCreatedEntity( v.mapID )
		if not IsValid( ent ) then continue end

		ent:SetNWString( "guthscpkeycard:title", v.title )
		ent:SetNWInt( "guthscpkeycard:level", v.lvl > 0 and v.lvl or nil ) --  get nil if 0 or lvl
	end

	guthscpkeycard:info( "all keycards have been loaded (%d entities) %s", #accesses, ply and "by " .. ply:Name() or "" )
	return true, #accesses
end
hook.Add( "PostCleanupMap", "guthscpkeycard:load", function()
	guthscpkeycard.load()
end )
hook.Add( "InitPostEntity", "guthscpkeycard:load", function()
	guthscpkeycard.load()
end )

net.Receive( "guthscpkeycard:io", function( len, ply )
	if not ply:IsSuperAdmin() then 
		ply:ChatPrint( "You are not allowed to either load or save keycards. (superadmin access needed)" )
		return MODULE:warning( "%q is not allowed to load or save keycards", ply:GetName() ) 
	end

	local is_save = net.ReadBool()
	if is_save then
		--  save to file
		local success, message = guthscpkeycard.save( ply ) 
		if success then
			ply:ChatPrint( ( "You successfully saved %d keycards accesses to file." ):format( message ) )
		else
			ply:ChatPrint( "You failed to save keycards : " .. message )
		end
	else 
		--  load from file
		local success, message = guthscpkeycard.load( ply ) 
		if success then
			ply:ChatPrint( ( "You successfully load %d keycards accesses from file." ):format( message ) )
		else
			ply:ChatPrint( "You failed to load keycards : " .. message )
		end
	end
end )

--  control access
hook.Add( "PlayerUse", "guthscpkeycard:access", function( ply, ent )
	if not IsValid( ent ) or not IsValid( ply ) then return end  --  are they valid?
	if not config.keycard_available_classes[ent:GetClass()] then return end  --  it is a keycard compatible entity class?
	if ply.guthscp_last_use_time and ply.guthscp_last_use_time > CurTime() then return false end  --  check cooldown

	--  check entity level
	local ent_level = ent:GetNWInt( "guthscpkeycard:level", 0 )
	if ent_level <= 0 then return end  --  no level :(

	--  get active weapon
	local active_weapon = ply:GetActiveWeapon()
	if not IsValid( active_weapon ) then return end
	
	--  get weapon level
	local ply_level = 0
	local weapon = NULL
	if not active_weapon.GuthSCPLVL or active_weapon.GuthSCPLVL == 0 then
		if not config.use_only_active_keycard then
			--  get higher level in inventory
			for i, v in ipairs( ply:GetWeapons() ) do
				if not v.GuthSCPLVL or ply_level >= v.GuthSCPLVL then continue end
				
				weapon = v
				ply_level = v.GuthSCPLVL
			end
		end
	else
		--  get active weapon
		weapon = active_weapon
		ply_level = weapon.GuthSCPLVL
	end
	
	--  set cooldown
	ply.guthscp_last_use_time = CurTime() + config.use_cooldown
	
	--  play weapon animation
	if weapon == active_weapon and weapon.Base == "guthscp_keycard_base" then
		weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	end
	
	--  refuse access
	if ply_level == 0 then
		--  not a level weapon
		ply:EmitSound( config.sound_denied )
		guthscp.player_message( ply, config.translation_no_keycard )

		return false
	elseif ply_level < ent_level then
		--  no suffisant clearance
		ply:EmitSound( config.sound_denied )
		guthscp.player_message( 
			ply, 
			guthscp.helpers.format_message( 
				config.translation_insufficient_clearance, 
				{
					level = ent_level,
				} 
			) 
		)

		return false
	end

	--  good, he has passed all conditions, what haxor he is
	ply:EmitSound( config.sound_accepted )
	guthscp.player_message( ply, config.translation_accepted )

	return true
end )

--  config
net.Receive( "guthscpkeycard:config", function( len, ply )
	if not ply:IsSuperAdmin() then return end

	local title, access = net.ReadString(), net.ReadUInt( guthscpkeycard.max_keycard_level_bit )
	if not title and not access then return end

	ply:SetNWString( "guthscpkeycard:config_title", title or ply:GetNWString( "guthscpkeycard:config_title", "" ) )
	ply:SetNWInt( "guthscpkeycard:config_level", math.Clamp( access or ply:GetNWInt( "guthscpkeycard:config_level", 1 ), 1, guthscpkeycard.max_keycard_level ) )

	--  set level to configurator
	local weapon = ply:GetWeapon( "guthscp_keycards_config" )
	if IsValid( weapon ) then
		weapon.GuthSCPLVL = ply:GetNWInt( "guthscpkeycard:config_level", 1 )
	end
end )