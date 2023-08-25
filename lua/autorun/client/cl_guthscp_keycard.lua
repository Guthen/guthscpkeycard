--  this addon is made from my unfinished gamemode scpsitebreach : https://github.com/Guthen/SCP-Site-Breach

net.Receive( "GuthSCP:SetBottomMessage", function()
    local msg = net.ReadString()
    hook.Add( "HUDPaint", "GuthSCP:BottomMessage", function()
        draw.SimpleText( msg, "ChatFont", ScrW() / 2, ScrH() / 1.2, color_white, TEXT_ALIGN_CENTER )
    end )

    timer.Create( "GuthSCP:SetBottomMessage", 3, 1, function()
        hook.Remove( "HUDPaint", "GuthSCP:BottomMessage" )
    end )
end )

--  draw door lvl that you aiming
local convar = CreateClientConVar( "guthscp_hud_lvl", "1", nil, nil, "Whenever you want to see the LVL of the door you're looking at on your screen" )
local dist_sqr = 156 ^ 2
hook.Add( "HUDPaint", "GuthSCP:HUDPaint", function()
    if not convar:GetBool() then return end

    local ply = LocalPlayer()
    if not IsValid( ply ) or not ply:Alive() then return end

    local ent = ply:GetEyeTrace().Entity
    if not IsValid( ent ) then return end
    if ent:GetPos():DistToSqr( ply:GetPos() ) > dist_sqr then return end

    local lvl = ent:GetNWInt( "GuthSCP:LVL", -1 )
    if lvl > -1 and GuthSCP.keycardAvailableClass[ ent:GetClass() ] then
        draw.SimpleText( ent:GetNWString( "GuthSCP:Title", "" ), "DermaDefaultBold", ScrW() / 2, ScrH() / 2 - 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( "LVL: " .. lvl, "DermaDefault", ScrW() / 2, ScrH() / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
end )