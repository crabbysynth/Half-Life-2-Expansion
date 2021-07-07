AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/vj_hlr/hl2b/combine_assassin.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 65
ENT.HullType = HULL_HUMAN
ENT.MaxJumpLegalDistance = VJ_Set(520,620)
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_COMBINE"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Red" -- The blood type, this will determine what it should use (decal, particle, etc.)

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDamage = 10
ENT.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1} -- Melee Attack Animations
ENT.MeleeAttackDistance = 55 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 90 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = false

ENT.Weapon_NoSpawnMenu = true -- If set to true, the NPC weapon setting in the spawnmenu will not be applied for this SNPC
ENT.DisableWeaponFiringGesture = true -- If set to true, it will disable the weapon firing gestures
ENT.MoveRandomlyWhenShooting = false -- Should it move randomly when shooting?

ENT.HasCallForHelpAnimation = false -- if true, it will play the call for help animation

ENT.AnimTbl_ShootWhileMovingRun = {ACT_SPRINT} -- Animations it will play when shooting while running | NOTE: Weapon may translate the animation that they see fit!
ENT.AnimTbl_ShootWhileMovingWalk = {ACT_RUN} -- Animations it will play when shooting while walking | NOTE: Weapon may translate the animation that they see fit!

ENT.DisableFootStepSoundTimer = true -- If set to true, it will disable the time system for the footstep sound code, allowing you to use other ways like model events
ENT.AnimTbl_TakingCover = {ACT_IDLE_ANGRY} -- The animation it plays when hiding in a covered position, leave empty to let the base decide
ENT.AnimTbl_AlertFriendsOnDeath = {ACT_IDLE_ANGRY} -- Animations it plays when an ally dies that also has AlertFriendsOnDeath set to true

ENT.HasItemDropsOnDeath = false -- Should it drop items on death?
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_BeforeMeleeAttack = {"npc/metropolice/pain1.wav","npc/metropolice/pain2.wav","npc/metropolice/pain3.wav","npc/metropolice/pain4.wav"}
ENT.SoundTbl_Pain = {"npc/combine_soldier/pain1.wav","npc/combine_soldier/pain2.wav","npc/combine_soldier/pain3.wav"}
ENT.SoundTbl_Death = {"npc/combine_soldier/die1.wav","npc/combine_soldier/die2.wav","npc/combine_soldier/die3.wav"}

ENT.GeneralSoundPitch1 = 120
ENT.GeneralSoundPitch2 = 120

ENT.Assassin_NextJumpT = 0
ENT.Assassin_OffGround = false
ENT.Assassin_CloakLevel = 1
ENT.Assassin_NextDodgeT = CurTime()
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnSetupWeaponHoldTypeAnims(hType)
	self.WeaponAnimTranslations[ACT_RANGE_ATTACK1] 					= ACT_RANGE_ATTACK1
	self.WeaponAnimTranslations[ACT_GESTURE_RANGE_ATTACK1] 			= ACT_RANGE_ATTACK1
	self.WeaponAnimTranslations[ACT_RANGE_ATTACK1_LOW] 				= ACT_RANGE_ATTACK1
	self.WeaponAnimTranslations[ACT_RELOAD] 						= ACT_IDLE_ANGRY
	self.WeaponAnimTranslations[ACT_COVER_LOW] 						= ACT_IDLE_ANGRY
	self.WeaponAnimTranslations[ACT_RELOAD_LOW] 					= ACT_IDLE_ANGRY
	
	self.WeaponAnimTranslations[ACT_IDLE] 							= ACT_IDLE
	self.WeaponAnimTranslations[ACT_IDLE_ANGRY] 					= ACT_IDLE_ANGRY
	
	self.WeaponAnimTranslations[ACT_WALK] 							= ACT_WALK
	self.WeaponAnimTranslations[ACT_WALK_AIM] 						= ACT_WALK
	self.WeaponAnimTranslations[ACT_WALK_CROUCH] 					= ACT_WALK
	self.WeaponAnimTranslations[ACT_WALK_CROUCH_AIM] 				= ACT_WALK
	
	self.WeaponAnimTranslations[ACT_RUN] 							= ACT_RUN
	self.WeaponAnimTranslations[ACT_RUN_AIM] 						= ACT_RUN
	self.WeaponAnimTranslations[ACT_RUN_CROUCH] 					= ACT_RUN
	self.WeaponAnimTranslations[ACT_RUN_CROUCH_AIM] 				= ACT_RUN
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(13,13,60),Vector(-13,-13,0))
	self:SetRenderMode(RENDERMODE_TRANSADD)

	self:Give("weapon_vj_hlr_dualpistol")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnPlayCreateSound(sdData, sdFile)
	if VJ_HasValue(self.SoundTbl_BeforeMeleeAttack,sdFile) then return end
	VJ_EmitSound(self, "npc/combine_soldier/vo/on"..math.random(1,2)..".wav")
	timer.Simple(SoundDuration(sdFile), function() if IsValid(self) && sdData:IsPlaying() then VJ_EmitSound(self,"npc/combine_soldier/vo/off"..math.random(1,3)..".wav") end end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key, activator, caller, data)
	if key == "Foot" then
		VJ_EmitSound(self,"npc/footsteps/hardboot_generic2.wav",72,100)
		VJ_EmitSound(self,{"npc/stalker/stalker_footstep_left1.wav","npc/stalker/stalker_footstep_left2.wav","npc/stalker/stalker_footstep_right1.wav","npc/stalker/stalker_footstep_right2.wav"},75)
	end
	if key == "left" or key == "right" then
		local wep = self:GetActiveWeapon()
		if IsValid(wep) then
			wep.CurrentMuzzle = key
		end
	end
	if string.StartWith(key,"melee") then
		self:MeleeAttackCode()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	if IsValid(self:GetActiveWeapon()) then
		self:GetActiveWeapon():SetClip1(999)
	end

	if self.Dead == true then return end
	-- local cloaklvl = math.Clamp(self.Assassin_CloakLevel *255,40,255)
	-- self:SetColor(Color(255,255,255,math.Clamp(self.Assassin_CloakLevel * 255, 40, 255)))
	-- self.Assassin_CloakLevel = math.Clamp(self.Assassin_CloakLevel + 0.05, 0, 1)
	-- if cloaklvl <= 220 then -- Yete asorme tsadz e, ere vor mouys NPC-nere chi desnen iren!
		-- self:AddFlags(FL_NOTARGET)
		-- self:DrawShadow(false)
	-- else
		-- self:DrawShadow(true)
		-- self:RemoveFlags(FL_NOTARGET)
	-- end

	-- if self.Assassin_OffGround == true && self:GetVelocity().z == 0 then
		-- self.Assassin_OffGround = false
		-- self:VJ_ACT_PLAYACTIVITY(ACT_LAND,true,false,false)
	-- end
	if IsValid(self:GetEnemy()) && self.VJ_IsBeingControlled == false && CurTime() > self.Assassin_NextDodgeT && !self:IsMoving() && self:GetPos():Distance(self:GetEnemy():GetPos()) < 2200 then
		self:Dodge()
	end
	-- if IsValid(self:GetEnemy()) && self.DoingWeaponAttack_Standing == true && self.VJ_IsBeingControlled == false && CurTime() > self.Assassin_NextJumpT && !self:IsMoving() && self:GetPos():Distance(self:GetEnemy():GetPos()) < 1400 then
		-- self:StopMoving()
		-- self:SetGroundEntity(NULL)
		-- if math.random(1,2) == 1 then
			-- self:SetLocalVelocity(((self:GetPos() + self:GetRight()*100) - (self:GetPos() + self:OBBCenter())):GetNormal()*200 +self:GetForward()*1 +self:GetUp()*600 + self:GetRight()*1)
		-- else
			-- self:SetLocalVelocity(((self:GetPos() + self:GetRight()*-100) - (self:GetPos() + self:OBBCenter())):GetNormal()*200 +self:GetForward()*1 +self:GetUp()*600 + self:GetRight()*1)
		-- end
		-- self:VJ_ACT_PLAYACTIVITY(ACT_JUMP,true,false,true,0,{},function(vsched)
			-- self.Assassin_OffGround = true
			-- self:VJ_ACT_PLAYACTIVITY(ACT_GLIDE,true,false,true)
		-- end)
		-- self.Assassin_NextJumpT = CurTime() + 8
	-- end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Dodge()
	if CurTime() > self.Assassin_NextDodgeT && self:IsOnGround() then
		local checkdist = self:VJ_CheckAllFourSides(400)
		local randmove = {}
		if checkdist.Backward == true then randmove[#randmove+1] = "Backward" end
		if checkdist.Right == true then randmove[#randmove+1] = "Right" end
		if checkdist.Left == true then randmove[#randmove+1] = "Left" end
		if checkdist.Forward == true then randmove[#randmove+1] = "Forward" end
		local pickmove = VJ_PICK(randmove)
		local anim = "flipback"
		if pickmove == "Right" then anim = "FlipRight" end
		if pickmove == "Left" then anim = "FlipLeft" end
		if pickmove == "Forward" then anim = "FlipForwardB" end
		if type(pickmove) == "table" && #pickmove == 4 then
			anim = VJ_PICK({"flipback","FlipRight","FlipLeft","FlipForwardB"})
		end
		if pickmove == "Backward" or pickmove == "Right" or pickmove == "Left" then
			self:VJ_ACT_PLAYACTIVITY(anim,true,false,false)
			self.Assassin_NextDodgeT = CurTime() +math.Rand(2,6)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnFireBullet(ent, data)
	self.Assassin_CloakLevel = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnIsAbleToShootWeapon()
	if self.Assassin_OffGround == true then return false end
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_OnBleed(dmginfo, hitgroup)
	self:Dodge()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDeath_BeforeCorpseSpawned(dmginfo, hitgroup)
	self:SetBodygroup(1,1)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDropWeapon_AfterWeaponSpawned(dmginfo, hitgroup, wepEnt)
	wepEnt:Remove()
	for i = 1,2 do
		local att = self:GetAttachment(2 +i)
		local pistol = ents.Create("weapon_vj_9mmpistol")
		pistol:SetPos(att.Pos)
		pistol:SetAngles(att.Ang)
		pistol:Spawn()
	end
end