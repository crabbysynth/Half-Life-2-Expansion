AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.BloodColor = "Yellow"
ENT.CustomBlood_Particle = {"vj_hl_blood_yellow"}
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(12,12,15), Vector(-12,-12,0))
	self:SetMaterial("models/hl_resurgence/hl2b/headcrab_fast/allinonebacup2")
end