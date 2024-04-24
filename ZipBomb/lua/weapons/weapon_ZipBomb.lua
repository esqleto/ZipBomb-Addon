SWEP.PrintName = 'ZipBomb'
SWEP.Author = "esqleto"
SWEP.Instructions = "A basic gun"

SWEP.Spawnable = true
SWEP.AdminOnly = false 

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "Pistol"
SWEP.ViewModelFOV = 100

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.ViewModel = "models/weapons/c_medkit.mdl"
SWEP.WorldModel = "models/weapons/w_medkit.mdl"

SWEP.UseHands = true
SWEP.ShootSound = Sound("weapons/slam/throw.wav") 

function SWEP:PrimaryAttack(ply)
    self:SetNextPrimaryFire(CurTime() + 3)
    self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:ThrowObj()

    


end

function SWEP:SecondaryAttack()

end

function SWEP:ThrowObj()
    local owner = self:GetOwner()
    if (not owner:IsValid()) then return end
    
    self:EmitSound(self.ShootSound)

    if (CLIENT) then return end

    local ent = ents.Create("prop_physics")

    if (not ent:IsValid()) then return end

    ent:SetModel("models/prop/astolfomaker/winrar/winrar.mdl") 

    local aimvec = owner:GetAimVector()
    local pos = aimvec * 16
    pos:Add(owner:EyePos())

    ent:SetPos(pos)

    ent:SetAngles(owner:EyeAngles())
    ent:Spawn()

    local phys = ent:GetPhysicsObject()
    if (not phys:IsValid()) then ent:Remove() return end

    aimvec:Mul(4000)
    aimvec:Add(VectorRand(-10, 10))
    phys:ApplyForceCenter(aimvec)

    timer.Simple(2, function() 
    
    local vortex = ents.Create( 'ent_zipboom' )
    vortex:SetPos(ent:GetPos())
    ent:Remove()
    vortex:Spawn()
    vortex:SetOwner( self.Owner )

    end)


    cleanup.Add(owner, "props", ent)

    timer.Simple(2, function() 
        owner:StripWeapon("weapon_ZipBomb")
    end)
    
end