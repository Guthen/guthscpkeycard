if not guthscp then return end

--  base
SWEP.Base = "guthscp_keycard_base"

--  main informations
SWEP.PrintName = "SCP - Master Card"
SWEP.Category = "GuthSCP"
SWEP.Author	= "Guthen"
SWEP.Instructions = ""

SWEP.Spawnable = true

local instructions = {
    "Yay, free money! wait.. do you have the password?",
    "I wonder if this card works with SCP-294..",
    "Do you really think money is useful in this facility?",
    "Money can't directly open doors, are you mad to keep this?",
}

function SWEP:Initialize()
    baseclass.Get( self.Base ).Initialize( self )

    self.Instructions = table.Random( instructions )
end

--  keycard lvl
SWEP.GuthSCPLVL = 0

--  renderer settings (comment code below using '--[[' (at the beginning) and ']]--' (at the end) if you don't want to use custom models)
SWEP.GuthSCPRenderer = {
    --  World Model is a 3D model shown either in 3rd person or when looking to an other player 
    world_model = {
        --model = "models/keycard/card_v1/card_snowseazon.mdl", --  model path
        skin = 12, --  skin index  --  1000shells is Skin 1
        --  SWEP:Construction Kit's renderer allow to render additional models without these models being weapon models
        --[[ swep_ck = {
            enabled = true, 

            --  commenting options below will revert the values to base weapon values
            bone = "ValveBiped.Bip01_R_Hand", --  bone attachment
            pos = Vector( 4, 3, -1.558 ), 
		    angle = Angle( 290, 0, 0 ), 
		    size = Vector( 0.755, 0.755, 0.755 ), 

            --  optionals options (to uncomment)
            --rel = "",
            --color = Color( 255, 255, 255, 255 ), 
            --surpresslightning = false, 
            --material = "", 
            --bodygroup = {}
        }, ]]
    },
    --  View Model is a 3D model specially made to be use with a weapon which is shown in 1st person 
    view_model = {
        --model = "models/1000shells/scp/keycards/v_keycard.mdl",
        skin = 12, --  skin index  --  1000shells is Skin 6
        use_hands = true, --  if hands should be drawn
        --  SWEP:Construction Kit's renderer allow to render additional models without these models being weapon models
        --[[ swep_ck = {
            enabled = true, --  disable this if you're using a view model (e.g.: 1000shells)

            --  commenting options below will revert the values to base weapon values
            bone = "ValveBiped.Bip01_R_Finger0", --  bone attachment
            pos = Vector( 4, -1, -0.519 ),
            angle = Angle( -8.183, -10.52, -99.351 ),
            size = Vector( 0.625, 0.625, 0.625 ),

            --  optionals options (to uncomment)
            --rel = "",
            --color = Color( 255, 255, 255, 255 ), 
            --surpresslightning = false, 
            --material = "", 
            --bodygroup = {}
        }, ]]
    },
}

--  add to spawnmenu
if CLIENT and guthscp then
    guthscp.spawnmenu.add_weapon( SWEP, "Keycards" )
end