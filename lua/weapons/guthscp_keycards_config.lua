SWEP.PrintName			    = "SCP - Keycard Config"
SWEP.Category				= "GuthSCP"
SWEP.Author			        = "Guthen"
SWEP.Instructions		    = "Left click to set an access from a button. Right click to remove an access from a button. Reload to change the access level."

SWEP.Spawnable              = true
SWEP.AdminOnly              = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		    = "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		    = "none"

SWEP.Weight	                = 5
SWEP.AutoSwitchTo		    = false
SWEP.AutoSwitchFrom		    = false

SWEP.Slot			        = 1
SWEP.SlotPos			    = 2
SWEP.DrawAmmo			    = false
SWEP.DrawCrosshair		    = true

SWEP.ViewModel			    = "models/weapons/c_stunstick.mdl"
SWEP.WorldModel			    = "models/weapons/w_stunbaton.mdl"

--SWEP.GuthSCPLVL       = 5   --  see at end of file
SWEP.canReload = true

function SWEP:PrimaryAttack() -- add access
    if CLIENT then return end

    local ply = self:GetOwner()
    if not IsValid( ply ) or not ply:Alive() then return end

    self.Weapon:SetNextPrimaryFire( CurTime() + 1 )

    local ent = ply:GetEyeTrace().Entity
    if not IsValid( ent ) or not GuthSCP.keycardAvailableClass[ent:GetClass()] then return end

    ent:SetNWInt( "GuthSCP:LVL", ply:GetNWInt( "GuthSCP:CurAccess", 1 ) ) -- set
    ent:SetNWString( "GuthSCP:Title", ply:GetNWString( "GuthSCP:ButtonTitle", "" ) )

    if SERVER then -- SERVER only because CLIENT spam chat
        ply:ChatPrint( "GuthSCP - The target has been set on LVL " .. ent:GetNWInt( "GuthSCP:LVL", 0 ) )
    end
end

function SWEP:SecondaryAttack() -- remove access
    if CLIENT then return end

    local ply = self:GetOwner()
    if not IsValid( ply ) or not ply:Alive() then return end

    self.Weapon:SetNextSecondaryFire( CurTime() + 1 )

    local ent = ply:GetEyeTrace().Entity
    if not IsValid( ent ) or not GuthSCP.keycardAvailableClass[ent:GetClass()] then return end

    ent:SetNWInt( "GuthSCP:LVL", 0 ) -- erased
    ent:SetNWString( "GuthSCP:Title", "" )

    if SERVER then -- SERVER only because CLIENT spam chat
        ply:ChatPrint( "GuthSCP - The target's LVL has been erased !" )
    end
end

function SWEP:Reload()
    if not CLIENT then return end
    if not self.canReload then return end

    local ply = self:GetOwner()
    if not IsValid( ply ) or not ply:Alive() then return end

    --  variables
    local w, h = ScrW() * .2, ScrH() * .15
    local left_margin = 15

    --  frame
    local frame = vgui.Create( "DFrame" )
    frame:SetSize( w, h )
    frame:DockPadding( left_margin, left_margin * 2, 0, left_margin * .75 )
    frame:Center()
    frame:SetTitle( "GuthSCP - Configuration" )
    frame:MakePopup()

    --  settings label
    local settings_label = frame:Add( "DLabel" )
    settings_label:Dock( TOP )
    settings_label:SetText( "Settings" )

    --  title textentry
    local text_panel = frame:Add( "DPanel" )
    text_panel:Dock( TOP )
    text_panel:DockMargin( left_margin, 0, 0, 0 )
    text_panel.Paint = function() end

    local title_label = text_panel:Add( "DLabel" )
    title_label:Dock( LEFT )
    title_label:SetText( "Button Title:" )
    
    local title_entry = text_panel:Add( "DTextEntry" )
    title_entry:Dock( FILL )
    title_entry:DockMargin( left_margin * 2, 0, left_margin * 2, 0 )
    title_entry:SetValue( ply:GetNWString( "GuthSCP:ButtonTitle" ) )
    title_entry:SetPlaceholderText( "Title of the button (optional)" )

    --  accreditation slider
    local access_slider = frame:Add( "DNumSlider" )
    access_slider:Dock( TOP )
    access_slider:DockMargin( left_margin, 0, 0, 0 )
    access_slider:SetText( "Accreditation ID:" )
    access_slider:SetMinMax( 0, GuthSCP.maxKeycardLevel )
    access_slider:SetDecimals( 0 )
    access_slider:SetValue( ply:GetNWInt( "GuthSCP:CurAccess", 1 ) )

    --  apply button
    local apply_button = frame:Add( "DButton" )
    apply_button:Dock( TOP )
    apply_button:DockMargin( 0, left_margin * .5, left_margin, 0 )
    apply_button:SetText( "Apply" )
    function apply_button:DoClick()
        net.Start( "GuthSCP:SetConfig" )
            net.WriteString( title_entry:GetValue() )
            net.WriteUInt( access_slider.TextArea:GetValue(), GuthSCP.maxKeycardLevelBit ) --  textarea provides the shown value on slider instead of clamped one
        net.SendToServer()
    end

    --  file system buttons
    local filesystem_label = frame:Add( "DLabel" )
    filesystem_label:Dock( TOP )
    filesystem_label:DockMargin( 0, 15, 0, 0 )
    filesystem_label:SetText( "File System" )

    local save_button = frame:Add( "DButton" )
    save_button:Dock( TOP )
    save_button:DockMargin( 0, left_margin * .5, left_margin, 0 )
    save_button:SetText( "Save keycards accesses" )
    function save_button:DoClick()
        net.Start( "GuthSCP:Do" )
            net.WriteBool( true )
        net.SendToServer()
    end

    local load_button = frame:Add( "DButton" )
    load_button:Dock( TOP )
    load_button:DockMargin( 0, left_margin * .5, left_margin, 0 )
    load_button:SetText( "Load keycards accesses" )
    function load_button:DoClick()
        net.Start( "GuthSCP:Do" )
            net.WriteBool( false )
        net.SendToServer()
    end

    --  adjust frame size
    frame:InvalidateLayout( true )
    frame:SizeToChildren( false, true )

    --  handle reload timer
    self.canReload = false
    timer.Simple( .2, function() 
        if not IsValid( self ) then return end
        self.canReload = true 
    end )
end

function SWEP:DrawHUD()
    local ply = self:GetOwner()
    if not IsValid( ply ) or not ply:Alive() then return end

    draw.SimpleText( "Current Title: " .. ply:GetNWString( "GuthSCP:ButtonTitle", "nil" ), "DermaDefault", ScrW() / 2 + 50, ScrH() / 2 - 15, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
    draw.SimpleText( "Current LVL: " .. ply:GetNWInt( "GuthSCP:CurAccess", 1 ), "DermaDefault", ScrW() / 2 + 50, ScrH() / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

    local trg = ply:GetEyeTrace().Entity
    if not IsValid( trg ) then return end
    if not GuthSCP.keycardAvailableClass[ trg:GetClass() ] then return end

    draw.SimpleText( "Target Class: " .. trg:GetClass() or "nil", "DermaDefault", ScrW() / 2 + 50, ScrH() / 2 + 15, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
    draw.SimpleText( "Target LVL: " .. trg:GetNWInt( "GuthSCP:LVL", -1 ), "DermaDefault", ScrW() / 2 + 50, ScrH() / 2 + 30, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
end

GuthSCP.registerKeycardSWEP( SWEP, 5 )