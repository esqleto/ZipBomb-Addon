SWEP.PrintName = 'WinRar Gun'
SWEP.Author = "esqleto"
SWEP.Instructions = "A basic gun"

SWEP.Spawnable = true
SWEP.AdminOnly = false 

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Pistol"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/cstrike/w_pist_deagle.mdl"

SWEP.UseHands = true
SWEP.ShootSound = Sound("weapons/grenade_launcher1.wav")

function SWEP:PrimaryAttack(ply)
    self:SetNextPrimaryFire(CurTime() + 0.1)
    self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:ThrowObj( "models/prop/astolfomaker/winrar/winrar.mdl" )
    


end

function SWEP:SecondaryAttack()

end

function SWEP:ThrowObj(model_file)
    local owner = self:GetOwner()
    
    if (not owner:IsValid()) then return end
    
    self:EmitSound(self.ShootSound)

    if (CLIENT) then return end

    local ent = ents.Create("prop_physics")

    if (not ent:IsValid()) then return end

    ent:SetModel(model_file)

    local aimvec = owner:GetAimVector()
    local pos = aimvec * 16
    pos:Add(owner:EyePos())

    ent:SetPos(pos)

    ent:SetAngles(owner:EyeAngles())
    ent:Spawn()

    local phys = ent:GetPhysicsObject()
    if (not phys:IsValid()) then ent:Remove() return end

    aimvec:Mul(100000)
    aimvec:Add(VectorRand(-10, 10))
    phys:ApplyForceCenter(aimvec)

    cleanup.Add(owner, "props", ent)

    undo.Create("Thrown_Obj")
        undo.AddEntity(ent)
        undo.SetPlayer(owner)
    undo.Finish()

    timer.Simple(10, function() 
        ent:Remove()
    end)

end
