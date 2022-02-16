--  this addon is made from my unfinished gamemode scpsitebreach : https://github.com/Guthen/SCP-Site-Breach

GuthSCP = GuthSCP or {}

--  entity class which we can set lvl
GuthSCP.keycardAvailableClass = 
{
    ["func_button"] = true,
    ["class C_BaseEntity"] = true,
}

--  cooldown in seconds before using an accredidated door/button again
GuthSCP.useCooldown = .8

--  get max keycard level
GuthSCP.keycardSweps = {}
GuthSCP.maxKeycardLevel = 0
GuthSCP.maxKeycardLevelBit = 1

function GuthSCP.registerKeycardSWEP( swep, level )
    if not level then
        assert( isnumber( swep.GuthSCPLVL ), "The field 'GuthSCPLVL' of this SWEP must be a number" )
    else
        swep.GuthSCPLVL = level
    end

    GuthSCP.keycardSweps[#GuthSCP.keycardSweps + 1] = swep
    GuthSCP.maxKeycardLevel = math.max( GuthSCP.maxKeycardLevel or 0, swep.GuthSCPLVL )
    GuthSCP.maxKeycardLevelBit = math.ceil( math.log( GuthSCP.maxKeycardLevel + 1, 2 ) )

    --  hot reload
    timer.Simple( 0, function()
        for i, v in ipairs( ents.FindByClass( swep.Folder:gsub( "weapons/", "" ) ) ) do
            v:Initialize()
        end
    end )
end

hook.Add( "StartCommand", "GuthSCP:HolsterAnimation", function( ply, ucmd )
    local weapon = ply:GetActiveWeapon()
    if not IsValid( weapon ) or not ( weapon.Base == "guthscp_keycard_base" ) then return end
    if not IsValid( weapon.HolstingWeapon ) or weapon.HolstingTime == 0 or weapon.HolstingTime > CurTime() then return end 

    weapon.HolstingDone = true
    weapon.HolstingTime = 0
    ucmd:SelectWeapon( weapon.HolstingWeapon )
    weapon.HolstingWeapon = NULL
end )

--  concommands
concommand.Add( "guthscp_save_keycards", function( ply )
    if CLIENT then 
        net.Start( "GuthSCP:Do" )
            net.WriteBool( true )
        net.SendToServer()
        return
    end

    GuthSCP.save()
end )


concommand.Add( "guthscp_load_keycards", function( ply )
    if CLIENT then 
        net.Start( "GuthSCP:Do" )
            net.WriteBool( false )
        net.SendToServer()
        return
    end

    GuthSCP.load()
end )
