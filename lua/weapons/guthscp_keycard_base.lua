SWEP.PrintName = "SCP - Keycard Base"
SWEP.Category = "GuthSCP"
SWEP.Author	= "Guthen"
SWEP.Instructions = "You have no clearance level because this a base weapon, you noob."

SWEP.Spawnable = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight	= 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom	= false

SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/weapons/v_grenade.mdl"
SWEP.WorldModel	= "models/weapons/w_grenade.mdl"

SWEP.HoldType = "slam"

SWEP.UseHands = false
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false

SWEP.GuthSCPLVL = 0

SWEP.HolstingTime = 0

--  swep construction kit
local model = "models/props/scp/keycard/keycard.mdl"
SWEP.VElements = {
	["keycard"] = { 
		type = "Model", 
		model = model, 
		bone = "ValveBiped.Bip01_R_Finger0", 
		rel = "", 

		--  here is what you want to edit
		pos = Vector(4, -1, -0.519), 
		angle = Angle(-8.183, -10.52, -99.351), 
		size = Vector(0.625, 0.625, 0.625), 
		--  end of will

		color = Color(255, 255, 255, 255), 
		surpresslightning = false, 
		material = "", 
		skin = 4, 
		bodygroup = {}
	}
}
SWEP.WElements = {
	["keycard"] = {
		type = "Model", 
		model = model, 
		bone = "ValveBiped.Bip01_R_Hand", 
		rel = "", 

		--  here is what you want to edit
		pos = Vector( 4.5, 4, -1.558 ), 
		angle = Angle( -3.507, -92.338, -59.611 ), 
		size = Vector( 0.755, 0.755, 0.755 ), 
		--  end of will

		color = Color( 255, 255, 255, 255 ), 
		surpresslightning = false, 
		material = "", 
		skin = 4, 
		bodygroup = {}
	}
}
SWEP.ViewModelBoneMods = {
	["ValveBiped.Grenade_body"] = { scale = Vector( 0.009, 0.009, 0.009 ), pos = Vector( 0, 0, 0 ), angle = Angle( 0, 0, 0 ) }
}

--  main functions
function SWEP:PrimaryAttack() 
	if CLIENT then return end
	
	self:SetNextPrimaryFire( CurTime() + guthscp.configs.guthscpkeycard.use_cooldown )

	--  interact with entities (+use)
	if SERVER then
		local ply = self:GetOwner()
		local ent = ply:GetUseEntity()

		if not IsValid( ent ) then return end
		if hook.Run( "PlayerUse", ply, ent ) == false then return end

		ent:Use( ply, ply )
		return
	end
end

local convar_drop
if SERVER then
	convar_drop = CreateConVar( "guthen_scp_keycard_secondary_drop", "1", { FCVAR_ARCHIVE, FCVAR_LUA_SERVER }, "Enables the keycard's SWEPs to be dropped on right click" )

	--  setup correct model & skin of dropped entity using /drop 
	hook.Add( "onDarkRPWeaponDropped", "guthscpkeycard:dropmodel", function( ply, ent, weapon )
		if not ( weapon.Base == "guthscp_keycard_base" ) then return end
		
		ent:SetModel( weapon.GuthSCPRenderer.world_model.model )
		ent:SetSkin( weapon.GuthSCPRenderer.world_model.skin )
	end )
end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	
	--  drop weapon
	if convar_drop:GetBool() then
		self:GetOwner():DropWeapon()
	end
end

function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
end

function SWEP:Holster( new_weapon )
	if self.ViewModel == "models/weapons/v_grenade.mdl" then return true end --  don't engage animation on default keycards
	if self.HolstingDone then --  holsting once animation done
		self.HolstingDone = false
		return true 
	end
	if self.HolstingTime > CurTime() then return false end --  don't holster while animation playing

	self:SendWeaponAnim( ACT_VM_HOLSTER )
	self.HolstingTime = CurTime() + self:SequenceDuration( self:SelectWeightedSequence( ACT_VM_HOLSTER ) )
	self.HolstingWeapon = new_weapon

	self:ClearBonePositions()
	return false
end

if CLIENT then
	--  for unknown reasons, setting a skin on the view model reset at the next frame, so here we go..
	function SWEP:PreDrawViewModel( vm, weapon, ply )
		if self.GuthSCPRenderer.view_model.swep_ck.enabled then return end
		vm:SetSkin( self.GuthSCPRenderer.view_model.skin )
	end
end

--[[
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378


	DESCRIPTION:
		This script is meant for experienced scripters
		that KNOW WHAT THEY ARE DOING. Don't come to me
		with basic Lua questions.

		Just copy into your SWEP or SWEP base of choice
		and merge with your own code.

		The SWEP.VElements, SWEP.WElements and
		SWEP.ViewModelBoneMods tables are all optional
		and only have to be visible to the client.

--
	Global utility code
--

-- Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
-- Does not copy entities of course, only copies their reference.
-- warning: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop --]]
local function table_FullCopy( tab )

	if (!tab) then return nil end

	local res = {}
	for k, v in pairs( tab ) do
		if (type(v) == "table") then
			res[k] = table_FullCopy(v) // recursion ho!
		elseif (type(v) == "Vector") then
			res[k] = Vector(v.x, v.y, v.z)
		elseif (type(v) == "Angle") then
			res[k] = Angle(v.p, v.y, v.r)
		else
			res[k] = v
		end
	end

	return res

end

function SWEP:Initialize()
	--  ensure renderer setup
	self.GuthSCPRenderer = self.GuthSCPRenderer or {
		world_model = {},
		view_model = {},
	}

	self.GuthSCPRenderer.world_model.model = self.GuthSCPRenderer.world_model.model or model
	self.GuthSCPRenderer.world_model.skin = self.GuthSCPRenderer.world_model.skin or self.GuthSCPLVL - 1
	self.GuthSCPRenderer.world_model.swep_ck = self.GuthSCPRenderer.world_model.swep_ck or {
		enabled = true,
	}

	self.GuthSCPRenderer.view_model.model = self.GuthSCPRenderer.view_model.model or model
	self.GuthSCPRenderer.view_model.skin = self.GuthSCPRenderer.view_model.skin or self.GuthSCPLVL - 1
	self.GuthSCPRenderer.view_model.swep_ck = self.GuthSCPRenderer.view_model.swep_ck or {
		enabled = true,
	}

	--  skin
	self:SetSkin( self.GuthSCPRenderer.world_model.skin )
	
	--  view model
	if self.GuthSCPRenderer.view_model.swep_ck.enabled then
		table.Merge( self.VElements["keycard"], self.GuthSCPRenderer.view_model.swep_ck or {} )
		
		--  auto-skin
		self.VElements["keycard"].skin = self.GuthSCPRenderer.view_model.skin or self.VElements["keycard"].skin or self.GuthSCPLVL - 1
		self.VElements["keycard"].model = self.GuthSCPRenderer.view_model.model or self.VElements["keycard"].skin
		
		--  SWEP:CK code
		if CLIENT then
			self.VElements = table_FullCopy( self.VElements )
			self:CreateModels( self.VElements )
		end
	else
		self.ViewModel = self.GuthSCPRenderer.view_model.model
	end
	self.UseHands = self.GuthSCPRenderer.view_model.use_hands
	
	--  world model
	if self.GuthSCPRenderer.world_model.swep_ck.enabled then
		table.Merge( self.WElements["keycard"], self.GuthSCPRenderer.world_model.swep_ck or {} )
		
		--  auto-skin
		self.WElements["keycard"].skin = self.GuthSCPRenderer.world_model.skin or self.WElements["keycard"].skin or self.GuthSCPLVL - 1
		self.WElements["keycard"].model = self.GuthSCPRenderer.world_model.model or self.VElements["keycard"].skin
		
		--  SWEP:CK code
		if CLIENT then
			self.WElements = table_FullCopy( self.WElements )
			self:CreateModels( self.WElements )
		end
	else
		self.WorldModel = self.GuthSCPRenderer.world_model.model
	end
	
	if CLIENT then
		if not self.GuthSCPRenderer.world_model.swep_ck.enabled and not self.GuthSCPRenderer.view_model.swep_ck.enabled then return end
		self.ViewModelBoneMods = table_FullCopy( self.ViewModelBoneMods )

		// init view model bone build function
		if IsValid( self:GetOwner() ) then
			local vm = self:GetOwner():GetViewModel()
			if IsValid( vm ) then
				self:ResetBonePositions( vm )

				// Init viewmodel visibility
				if ( self.ShowViewModel == nil or self.ShowViewModel ) then
					vm:SetColor( color_white )
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor( Color( 255, 255, 255, 1 ) )
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial( "Debug/hsv" )
				end
			end
		end

	end
end

function SWEP:OnRemove()
	self:ClearBonePositions()
end

function SWEP:ClearBonePositions()
	if CLIENT and IsValid( self:GetOwner() ) then
		local vm = self:GetOwner():GetViewModel()
		if IsValid( vm ) then
			self:ResetBonePositions( vm )
		end
	end
end

if CLIENT then
	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn( vm )
		if not self.GuthSCPRenderer.view_model.swep_ck.enabled then return end

		if (!self.VElements) then return end

		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then

			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end

		end

		for k, name in ipairs( self.vRenderOrder ) do

			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end

			local model = v.modelEnt
			local sprite = v.spriteMaterial

			if (!v.bone) then continue end

			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )

			if (!pos) then continue end

			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )

				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end

				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end

				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end

				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end

			elseif (v.type == "Sprite" and sprite) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)

			elseif (v.type == "Quad" and v.draw_func) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end

		end

	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel( flags )
		if not self.GuthSCPRenderer.world_model.swep_ck.enabled then 
			self:DrawModel( flags )
			return
		end

		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel( flags )
		end

		if (!self.WElements) then return end

		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end

		if (IsValid(self:GetOwner())) then
			bone_ent = self:GetOwner()
		else
			// when the weapon is dropped
			bone_ent = self
		end

		for k, name in pairs( self.wRenderOrder ) do

			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end

			local pos, ang

			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end

			if (!pos) then continue end

			local model = v.modelEnt
			local sprite = v.spriteMaterial

			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )

				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end

				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end

				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end

				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end

			elseif (v.type == "Sprite" and sprite) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)

			elseif (v.type == "Quad" and v.draw_func) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end

		end

	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )

		local bone, pos, ang
		if (tab.rel and tab.rel != "") then

			local v = basetab[tab.rel]

			if (!v) then return end

			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )

			if (!pos) then return end

			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

		else

			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end

			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end

			if (IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() and
				ent == self:GetOwner():GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end

		end

		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		-- Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then

				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end

			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite)
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then

				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)

			end
		end

	end

	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)

		if self.ViewModelBoneMods then

			if (!vm:GetBoneCount()) then return end

			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = {
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end

				loopthrough = allbones
			end
			// !! ----------- !! //

			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end

				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end

				s = s * ms
				// !! ----------- !! //

				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end

	end

	function SWEP:ResetBonePositions(vm)

		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end

	end

end
