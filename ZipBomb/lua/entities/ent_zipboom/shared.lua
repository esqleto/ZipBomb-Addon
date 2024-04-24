AddCSLuaFile()

-- this is just taken from this addon: https://steamcommunity.com/sharedfiles/filedetails/?id=2853437641. 
--Download their addon since they acctually know what they are doing.

DEFINE_BASECLASS( 'base_anim' )

ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  ''        
ENT.Author			                 =  ''
ENT.Contact			                 =  ''

ENT.Range                       	 = 500
ENT.MaxItems						 = 6
ENT.MaxMass 						 = 400


game.AddParticles( 'particles/xen_portal.pcf' )
game.AddParticles( 'particles/xengrenade_vortex.pcf' )

PrecacheParticleSystem( 'xengrenade_vortex' )
PrecacheParticleSystem( 'xen_striderbuster_attach' )
PrecacheParticleSystem( 'xen_stasis_arc_01_main' )
PrecacheParticleSystem( 'xen_electrical_arc_01' )

local XenGrenade_Collapse = Sound( 'XenGrenade_Collapse' )
local XenGrenade_Schlorp = Sound( 'XenGrenade_Schlorp' )

function ENT:Initialize()

    if SERVER then
		
        self:SetModel( 'models/hunter/blocks/cube1x1x1.mdl' )
	    self:SetSolid( SOLID_NONE )
	    self:SetMoveType( MOVETYPE_NONE )
	    self:SetUseType( ONOFF_USE )
		 
		local pos = self:GetPos()
		self.pull = 0
		self.StopPull = false
		
		self.Mass = 0
		self.Items = util.JSONToTable( file.Read( 'entropyzero2_xengrenades/itemlist.txt', 'DATA' ) ) or {}
		
		self:EmitSound( XenGrenade_Collapse )
		
		timer.Simple( 4, function()
			
			local winrarball = ents.Create('prop_physics')
			winrarball:SetModel("models/prop/astolfomaker/winrar/winrar.mdl")
			winrarball:SetPos(pos)
			winrarball:Spawn()

			self:Remove()

		end)
		
	end
	 
	 if CLIENT then
		
		ParticleEffect( 'xen_striderbuster_attach', self:GetPos(), Angle( 0, 0, 0 ), self )
		ParticleEffect( 'xengrenade_vortex', self:GetPos(), Angle( 0, 0, 0 ), self )
		
		timer.Simple( 3.7, function()
		
			if IsValid( self ) then
			
				ParticleEffect( 'xen_striderbuster_attach', self:GetPos(), Angle( 0, 0, 0 ), self )
				
			end
			
		end)
	
	 end
	
end

function ENT:FindSpawnPoints( icount )
	
	local RandomPoint
	local RandomTable = {}
	
	for i = 1, icount do
	
		repeat
		
			RandomPoint = VectorRand( -100, 100 )
			RandomPoint.z = 0
			RandomPoint = self:GetPos() + RandomPoint
			
		until util.IsInWorld( RandomPoint )
		
		table.insert( RandomTable, RandomPoint )
	
	end

	return RandomTable
	
end

function ENT:Think()

    if SERVER then
		
		if not self:IsValid() then return end
		
		if self.StopPull then return end
		
		local pos = self:GetPos()



		for k, v in pairs( ents.FindInSphere( pos, GetConVar( 'xengrenade_radius' ):GetInt() ) ) do
			
			if v:IsValid() or v:IsPlayer() then

				local i = 0

				while i < v:GetPhysicsObjectCount() do

					phys = v:GetPhysicsObjectNum(i)

					if ( phys:IsValid() ) then

						local mass = phys:GetMass()
						local F_ang = self.pull
						local dist = ( pos - v:GetPos() ):Length()
						local relation = math.Clamp( ( self.Range - dist ) / self.Range, 0, 1 )
						local F_dir = ( v:GetPos() - pos ):GetNormal() * self.pull

						phys:AddAngleVelocity( Vector( F_ang, F_ang, F_ang ) * relation )
						phys:AddVelocity( F_dir )

					end

					if (v:IsPlayer()) then

						v:SetMoveType( MOVETYPE_WALK )

						local mass = phys:GetMass()
						local F_ang = self.pull
						local dist = ( pos - v:GetPos() ):Length()
						local relation = math.Clamp( ( self.Range - dist ) / self.Range, 0, 1 )
						local F_dir = ( v:GetPos() - pos ):GetNormal() * self.pull	

						v:SetVelocity( F_dir )		

					end

				i = i + 1

				end

			end
			
			if v:IsNPC() then
			
				local dmg = DamageInfo()
				dmg:SetDamage( 1000 )
				dmg:SetDamageType( DMG_GENERIC )
				dmg:SetAttacker( self.Owner )
				dmg:SetDamageForce( self:GetPos() * Vector( -1, -1, -1) )
				v:TakeDamageInfo( dmg )
			
			end

		end

		for k, v in pairs( ents.FindInSphere( pos, 100 ) ) do

			if ( v:IsValid() and ( v:GetClass() == 'prop_physics' or v:GetClass() == 'prop_ragdoll' ) ) or ( v:IsPlayer() and v:Alive() ) or (v:IsVehicle()) then

				local i = 0

				while i < v:GetPhysicsObjectCount() do

					phys = v:GetPhysicsObjectNum( i )

					if ( phys:IsValid() and not v:IsPlayer() ) then
						
						local mass = phys:GetMass()
						self.Mass = self.Mass + mass
						
						ParticleEffect( 'xen_electrical_arc_01', ( v:GetPos() + v:GetUp() * 20 ), Angle( 0, 0, 0 ) )
						self:EmitSound( XenGrenade_Schlorp )
						v:Remove()

					end

					if v:IsNPC()then

						local dmg = DamageInfo()
						dmg:SetDamage( 1000 )
						dmg:SetDamageType( DMG_GENERIC )
						dmg:SetAttacker( self.Owner )
						v:TakeDamageInfo( dmg )

					end
						
					if v:IsPlayer() then
						
						v:TakeDamage(5)
						 
						
						self.Mass = self.Mass + GetConVar( 'xengrenade_maxmass' ):GetInt()

						local plyRagdoll = v:GetRagdollEntity()
							
						if IsValid( plyRagdoll ) then
							
							ParticleEffect( 'xen_electrical_arc_01', plyRagdoll:GetPos(), Angle( 0, 0, 0 ), plyRagdoll )
							self:EmitSound( XenGrenade_Schlorp )
							plyRagdoll:Remove()
							
							for i, ply in ipairs( player.GetAll() ) do
								ply:ChatPrint( v:Nick() .. " was compressed!" )
							end	
						end

					end
				
				i = i + 1

				end

			end

		end

		self.pull = self.pull - 25 --pull

		self:NextThink( CurTime() + 0.1 )

		return true

	end

end

function ENT:Draw()
	
	return false

end