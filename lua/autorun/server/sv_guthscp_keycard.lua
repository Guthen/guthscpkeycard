--  this addon is made from my unfinished gamemode scpsitebreach : https://github.com/Guthen/SCP-Site-Breach

util.AddNetworkString( "GuthSCP:SetBottomMessage" )
util.AddNetworkString( "GuthSCP:SetConfig" )
util.AddNetworkString( "GuthSCP:Do" )

local Player = FindMetaTable( "Player" )

function Player:setBottomMessage( msg )
    net.Start( "GuthSCP:SetBottomMessage" )
        net.WriteString( msg )
    net.Send( self )
end

--  functions
function GuthSCP.save( ply )
    --  create directory
    file.CreateDir( "guth_scp/" .. game.GetMap() )

    --  make data
    local accesses = {}
    for k, _ in pairs( GuthSCP.keycardAvailableClass ) do
        for _, v in ipairs( ents.FindByClass( k ) ) do -- add data to a table
            if v:GetNWInt( "GuthSCP:LVL", 0 ) <= 0 then continue end

            --  save entity
            accesses[#accesses + 1] = { 
                mapID = v:MapCreationID(), 
                lvl = v:GetNWInt( "GuthSCP:LVL", 0 ),
                title = v:GetNWString( "GuthSCP:Title" ),
            }
        end
    end
    if #accesses == 0 then return false, "No keycards accesses found" end

    --  save to file
    file.Write( "guth_scp/" .. game.GetMap() .. "/keycards.txt", util.TableToJSON( accesses ) ) -- save table to json

    print( ( "GuthSCP - All Keycards have been saved (%d entities) %s" ):format( #accesses, ply and "by " .. ply:Name() or "" ) )
    return true, #accesses
end

function GuthSCP.load( ply )
    if not file.Exists( "guth_scp/" .. game.GetMap() .. "/keycards.txt", "DATA" ) then --  create dir if not exists
        print( "GuthSCP - File doesn't exists : load failed" )
        return false, "File doesn't exists"
    end

    --  read content
    local json = file.Read( "guth_scp/" .. game.GetMap() .. "/keycards.txt", "DATA" ) --  read data
    if not json then return false, "No content found" end

    local accesses = util.JSONToTable( json )
    if not accesses then return false, "Invalid JSON content found" end

    --  set the entities lvl
    for i, v in ipairs( accesses ) do
        local ent = ents.GetMapCreatedEntity( v.mapID )
        if not IsValid( ent ) then continue end

        ent:SetNWString( "GuthSCP:Title", v.title )
        ent:SetNWInt( "GuthSCP:LVL", v.lvl > 0 and v.lvl or nil ) --  get nil if 0 or lvl
    end

    print( ( "GuthSCP - All Keycards have been loaded (%d entities) %s" ):format( #accesses, ply and "by " .. ply:Name() or "" ) )
    return true, #accesses
end

net.Receive( "GuthSCP:Do", function( len, ply )
    if not IsValid( ply ) or not ply:IsSuperAdmin() then 
        ply:ChatPrint( "You are not allowed to either load or save keycards. (superadmin access needed)" )
        return print( "GuthSCP - " .. ply:Name() .. " is not allowed to load or save keycards." ) 
    end

    local is_save = net.ReadBool()
    --  save to file
    if is_save then
        local success, message = GuthSCP.save( ply ) 
        if success then
            ply:ChatPrint( ( "You successfully saved %d keycards accesses to file." ):format( message ) )
        else
            ply:ChatPrint( "You failed to save keycards : " .. message )
        end
    --  load from file
    else 
        local success, message = GuthSCP.load( ply ) 
        if success then
            ply:ChatPrint( ( "You successfully load %d keycards accesses from file." ):format( message ) )
        else
            ply:ChatPrint( "You failed to load keycards : " .. message )
        end
    end
end )

--  hooks
hook.Add( "PlayerUse", "GuthSCP:PlayerUse", function( ply, ent )
    if not IsValid( ent ) or not IsValid( ply ) then return end  --  are they valid?
    if not GuthSCP.keycardAvailableClass[ent:GetClass()] then return end  --  it is a keycard compatible entity class?
    if ply.guthscp_last_use_time and ply.guthscp_last_use_time > CurTime() then return false end  --  check cooldown

    local ent_level = ent:GetNWInt( "GuthSCP:LVL", 0 )
    if ent_level <= 0 then return end  --  no level :(

    --  get player accreditation
    local weapon = ply:GetActiveWeapon()
    if not IsValid( weapon ) then return end
    local ply_level = weapon.GuthSCPLVL
        
    --  use cooldown
    ply.guthscp_last_use_time = CurTime() + GuthSCP.useCooldown


    --  refuse access
    if not ply_level then
        --  not a level weapon
        ply:EmitSound( "guthen_scp/interact/KeycardUse2.ogg" )
        ply:setBottomMessage( "You don't have any keycard to pass !" )

        return false
    elseif ply_level < ent_level then
        --  no suffisant clearance
        ply:EmitSound( "guthen_scp/interact/KeycardUse2.ogg" )
        ply:setBottomMessage( "You need a keycard LVL " .. ent_level .. " to trigger the doors !" )

        return false
    end

    --  good, he has passed all conditions, what haxor he is
    ply:EmitSound( "guthen_scp/interact/KeycardUse1.ogg" )
    ply:setBottomMessage( "The doors are moving !" )
    return true
end )

hook.Add( "PostCleanupMap", "GuthSCP:PostCleanupMap", function()
    RunConsoleCommand( "guthscp_load_keycards" )
end )

hook.Add( "PlayerInitialSpawn", "GuthSCP:PlayerInitialSpawn", function()
    RunConsoleCommand( "guthscp_load_keycards" )
    hook.Remove( "PlayerInitialSpawn", "GuthSCP:PlayerInitialSpawn" )
end )

--  config

net.Receive( "GuthSCP:SetConfig", function( len, ply )
    local title, access = net.ReadString(), net.ReadUInt( GuthSCP.maxKeycardLevelBit )
    if not title and not access then return end

    ply:SetNWString( "GuthSCP:ButtonTitle", title or ply:GetNWString( "GuthSCP:ButtonTitle", "" ) )
    ply:SetNWInt( "GuthSCP:CurAccess", math.Clamp( access or ply:GetNWInt( "GuthSCP:CurAccess", 1 ), 1, GuthSCP.maxKeycardLevel ) )

    --  set level to configurator
    local weapon = ply:GetWeapon( "guthscp_keycards_config" )
    if IsValid( weapon ) then
        weapon.GuthSCPLVL = ply:GetNWInt( "GuthSCP:CurAccess", 1 )
    end
end )