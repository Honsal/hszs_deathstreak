local DS_DMGUP = "dsDmgUp"
local DS_ARMORUP = "dsArmorUp"
local DS_SPEEDUP = "dsSpeedUp"
local DS_ATK_SPEEDUP = "dsAtkSpeedUp"
local DS_HEALTHUP = "dsHealthUp"

local DS_LIMIT_BARRICADEDAMAGE = 300
local DS_LIMIT_DAMAGE = 120
-- local DS_LIMIT_DISTANCE = 3600

ZombieClassTable = ZombieClassTable or {}

local DeathStreakEffect = function(name, value)
	return {name, value}
end

local DSE = DeathStreakEffect

G_DSE = DSE

local InsertEffect = function(pl, dse)
	for i, v in pairs(pl.zs_deathstreak.effect) do
		if !istable(v) or table.Count(v) == 0 then
			continue
		end
		if v[1] == dse[1] then
			pl.zs_deathstreak.effect[i][2] = dse[2]
			return
		end
	end
	
	table.insert(pl.zs_deathstreak.effect, dse)
end

G_InsEft = InsertEffect

local AddEffect = function(pl)
	local count = pl.zs_deathstreak.count
	-- PrintMessage(3, "DTSCount: " .. count)
	
	if count == 3 then
		InsertEffect(pl, DSE(DS_DMGUP, 0.15))
	elseif count == 5 then
		InsertEffect(pl, DSE(DS_DMGUP, 0.25))
		InsertEffect(pl, DSE(DS_ARMORUP, 1))
	elseif count == 7 then
		InsertEffect(pl, DSE(DS_DMGUP, 0.50))
		InsertEffect(pl, DSE(DS_ARMORUP, 2))
		InsertEffect(pl, DSE(DS_SPEEDUP, 0.15))
	elseif count == 9 then
		InsertEffect(pl, DSE(DS_ARMORUP, 4))
		InsertEffect(pl, DSE(DS_SPEEDUP, 0.25))
		InsertEffect(pl, DSE(DS_ATK_SPEEDUP, 0.10))
		InsertEffect(pl, DSE(DS_HEALTHUP, 0.10))
	elseif count == 11 then
		InsertEffect(pl, DSE(DS_ATK_SPEEDUP, 0.25))
		InsertEffect(pl, DSE(DS_HEALTHUP, 0.20))
	elseif count == 13 then
		InsertEffect(pl, DSE(DS_ARMORUP, 6))
		InsertEffect(pl, DSE(DS_HEALTHUP, 0.55))
	elseif count == 15 then
		InsertEffect(pl, DSE(DS_DMGUP, 0.75))
		InsertEffect(pl, DSE(DS_ARMORUP, 8))
		InsertEffect(pl, DSE(DS_SPEEDUP, 0.45))
		InsertEffect(pl, DSE(DS_ATK_SPEEDUP, 0.40))
		InsertEffect(pl, DSE(DS_HEALTHUP, 0.60))
	end
end

G_AddEffectZSDS = AddEffect

local SetWpnAtkSpd = function(wep, mul)
	if wep.Primary and wep.Primary.Delay then
		wep.Primary.Delay = wep.Primary.Delay * mul
	end
	
	if wep.Secondary and wep.Secondary.Delay then
		wep.Secondary.Delay = wep.Secondary.Delay * mul
	end
	
	if wep.MeleeDelay then
		wep.MeleeDelay = wep.MeleeDelay * mul
	end
end

local ResetDeathStreak = function(pl)
	if !pl.zs_deathstreak then
		pl.zs_deathstreak = {}
		pl.zs_deathstreak.count = 0
		pl.zs_deathstreak.damage = 0
		pl.zs_deathstreak.barricadeDamage =0
		pl.zs_deathstreak.effect = {}
		pl.zs_deathstreak.spawn = 0
	else
		pl.zs_deathstreak.count = 0
		pl.zs_deathstreak.damage = 0
		pl.zs_deathstreak.barricadeDamage = 0
		pl.zs_deathstreak.effect = {}
		pl.zs_deathstreak.spawn = 0
		pl:ResetSpeed()
		if pl:Team() == TEAM_ZOMBIE then
			pl:GetZombieClassTable().Health = ZombieClassTable[pl:GetZombieClass()].Health
			pl:SetMaxHealth(pl:GetZombieClassTable().Health)
		end
		local wep = pl:GetActiveWeapon()
		if IsValid(wep) then
			local stored = weapons.GetStored(wep:GetClass())
			if istable(stored) then
				if wep.Primary and wep.Primary.Delay then
					wep.Primary.Delay = stored.Primary.Delay or weapons.GetStored(stored.Base).Primary.Delay
				end
				
				if wep.Secondary and wep.Secondary.Delay then
					wep.Secondary.Delay = stored.Secondary.Delay or weapons.GetStored(stored.Base).Secondary.Delay
				end
				
				if wep.MeleeDelay then
					wep.MeleeDelay = stored.MeleeDelay or weapons.GetStored(stored.Base).MeleeDelay
				end
				
				if wep.WalkSpeed then
					wep.WalkSpeed = stored.WalkSpeed or weapons.GetStored(stored.Base).WalkSpeed
				end
			end
		end		
	end
end

local ResetDeathstreak = ResetDeathStreak

local ResetDeathstreakAll = function()
	if !ZombieClassTable or #ZombieClassTable == 0 then
		ZombieClassTable = table.Copy(GAMEMODE.ZombieClasses)
	else
		local meta = FindMetaTable("Player")
		GAMEMODE.ZombieClasses = table.Copy(ZombieClassTable)
		local ZombieClasses = table.Copy(GAMEMODE.ZombieClasses)
		meta.GetZombieClassTable = function(self)
			return ZombieClasses[self:GetZombieClass()]
		end
	end
	
	for _, v in pairs(player.GetAll()) do
		ResetDeathStreak(v)
	end
end
hook.Add("InitPostEntity", "zs_deathstreak.ResetDeathstreak", ResetDeathstreakAll)
hook.Add("RestartRound", "zs_deathstreak.ResetDeathstreak", ResetDeathstreakAll)

G_ResetDeathStreakAll = function()
	if !ZombieClassTable or #ZombieClassTable == 0 then
		ZombieClassTable = table.Copy(GAMEMODE.ZombieClasses)
	else
		local meta = FindMetaTable("Player")
		GAMEMODE.ZombieClasses = table.Copy(ZombieClassTable)
		local ZombieClasses = table.Copy(GAMEMODE.ZombieClasses)
		meta.GetZombieClassTable = function(self)
			return ZombieClasses[self:GetZombieClass()]
		end
	end
	
	for _, v in pairs(player.GetAll()) do
		ResetDeathStreak(v)
	end
end

G_ResetDeathStreak = function(pl)
	if pl.zs_deathstreak then
		if pl.zs_deathstreak then
			pl.zs_deathstreak = {}
			pl.zs_deathstreak.count = 0
			pl.zs_deathstreak.damage = 0
			pl.zs_deathstreak.barricadeDamage = 0
			pl.zs_deathstreak.effect = {}
			pl.zs_deathstreak.spawn = 0
		end
	end
end

local ProcessDeathstreak = function(pl)
	if !IsValid(pl) or !pl:IsPlayer() or pl:Team() ~= TEAM_UNDEAD then
		return
	end
	
	if !pl.zs_deathstreak or (pl.zs_deathstreak.effect and !istable(pl.zs_deathstreak.effect)) or pl:GetZombieClassTable().Boss then
		ResetDeathStreak(pl)
	end

	local count = pl.zs_deathstreak.count
	local effect = pl.zs_deathstreak.effect
	
	pl.zs_deathstreak.spawn = CurTime()
	
	if pl.zs_deathstreak.count < 9 then
		local mul = 1
		local numundead = team.NumPlayers(TEAM_UNDEAD)
		if GAMEMODE.OutnumberedHealthBonus >= numundead then
			mul = 2
		end
		pl:GetZombieClassTable().Health = ZombieClassTable[pl:GetZombieClass()].Health * mul
	end
	
	for i, v in pairs(pl.zs_deathstreak.effect) do
		if !istable(v) then
			continue
		end
		local name, value = v[1], v[2]
		if name == DS_SPEEDUP then
			local mul = 1 + v[2]
			local spd = pl:GetZombieClassTable().Speed
			pl:SetSpeed(spd * mul)
			local wep = pl:GetActiveWeapon()
			if wep and IsValid(wep) then
				if wep.WalkSpeed then
					wep.WalkSpeed = wep.WalkSpeed * mul
				end
			end
		elseif name == DS_ATK_SPEEDUP then
			local mul = 1 - v[2]
			local wep = pl:GetActiveWeapon()
			if !wep or !IsValid(wep) then
				timer.Simple(1, function()
					if !wep or !IsValid(wep) then
						SetWpnAtkSpd(wep, mul)
						return
					end
					
				end)
			else
				SetWpnAtkSpd(wep, mul)
			end
		elseif name == DS_HEALTHUP then
			local mul = 1 + v[2]
			local numundead = team.NumPlayers(TEAM_UNDEAD)
			if GAMEMODE.OutnumberedHealthBonus >= numundead then
				mul = mul + 1
			end
			local originalHealth = ZombieClassTable[pl:GetZombieClass()].Health
			pl:GetZombieClassTable().Health = originalHealth * mul
			pl:SetMaxHealth(originalHealth * mul)
			pl:SetHealth(pl:GetMaxHealth())
		end
	end
end

local PlayerDeathHandler = function(pl, attacker, inflictor, dmginfo, headshot, suicide)	
	if !pl.zs_deathstreak then
		ResetDeathStreak(pl)
	end
	
	pl.zs_deathstreak.count = pl.zs_deathstreak.count + 1
	AddEffect(pl)
end
hook.Add("HumanKilledZombie", "zs_deathstreak.PlayerDeathHandler", PlayerDeathHandler)

local ZombieKilledHuman = function(pl, attacker, inflictor, dmginfo, headshot, suicide)
	if attacker.zs_deathstreak then
		ResetDeathStreak(attacker)
	end
end
hook.Add("ZombieKilledHuman", "zs_deathstreak.PlayerDeathHandler", ZombieKilledHuman)


local PlayerSpawnHandler = function(pl)
	if !IsValid(pl) or !pl:IsPlayer() or pl:Team() ~= TEAM_ZOMBIE then
		return
	end
	
	if pl.zs_deathstreak then
		timer.Simple(1, function()
			ProcessDeathstreak(pl)
		end)
	else
		pl.zs_deathstreak = pl.zs_deathstreak or {}
		pl.zs_deathstreak.count = pl.zs_deathstreak.count or 0
		pl.zs_deathstreak.damage = pl.zs_deathstreak.damage or 0
		pl.zs_deathstreak.barricadeDamage = pl.zs_deathstreak.barricadeDamage or 0
		pl.zs_deathstreak.effect = pl.zs_deathstreak.effect or {}
	end
end
hook.Add("PlayerSpawn", "zs_deathstreak.PlayerSpawnHandler", PlayerSpawnHandler)

local TakeDamageHandler = function(ent, dmginfo)
	local attacker = dmginfo:GetAttacker()
	
	if IsValid(ent) and !ent:IsPlayer() and ent:IsNailed() and IsValid(attacker) and attacker:IsPlayer() and attacker:Team() == TEAM_ZOMBIE then
		attacker.zs_deathstreak.barricadeDamage = attacker.zs_deathstreak.barricadeDamage + dmginfo:GetDamage()
		if attacker.zs_deathstreak.barricadeDamage >= DS_LIMIT_BARRICADEDAMAGE then
			ResetDeathstreak(attacker)
		end
	end
	
	if !IsValid(ent) or !ent:IsPlayer() or !IsValid(attacker) or !attacker:IsPlayer() then
		return
	end
	
	if ent:Team() == TEAM_HUMAN and attacker:Team() == TEAM_ZOMBIE then
		if attacker.zs_deathstreak.count > 0 then
			local prevDmg = attacker.zs_deathstreak.damage or 0
			attacker.zs_deathstreak.damage = prevDmg + (dmginfo:GetDamage() or 0)

			if attacker.zs_deathstreak.damage >= DS_LIMIT_DAMAGE then
				ResetDeathstreak(attacker)
			end
		end
		if attacker.zs_deathstreak and attacker.zs_deathstreak.effect then
			local ef = attacker.zs_deathstreak.effect
			local dmgmul = 1
			for i, v in pairs(ef) do
				if istable(v) and v[1] == DS_DMGUP then
					dmgmul = 1 + v[2]
				end
			end
			
			dmginfo:ScaleDamage(dmgmul)
		end
	end
	
	if ent:Team() == TEAM_ZOMBIE and attacker:Team() == TEAM_HUMAN then
		if ent.zs_deathstreak then
			if istable(ent.zs_deathstreak.effect) and table.Count(ent.zs_deathstreak.effect) > 0 then
				local ef = ent.zs_deathstreak.effect
				local minus = 0
				for i, v in pairs(ef) do
					if istable(v) and v[1] == DS_ARMORUP then
						minus = v[2]
					end
				end
				
				local infl = dmginfo:GetInflictor()
				if infl:IsPlayer() then
					infl = infl:GetActiveWeapon()
				end
				
				if infl and infl ~= NULL and IsValid(infl) then
					if infl.ArmorThrough then
						minus = math.max(0, minus - infl.ArmorThrough)
					end
					
					if infl.ArmorThroughRate then
						minus = math.max(0, minus * (1 - infl.ArmorThroughRate))
					end
				end
				
				dmginfo:SetDamage(dmginfo:GetDamage() - minus)
			end		
		end
	end
end
hook.Add("EntityTakeDamage", "zs_deathstreak.TakeDamageHandler", TakeDamageHandler)

local stop_dist_check = CreateConVar("hszs_deathstreak_stop_dist_check", "0")
local crDistanceCheck = coroutine.create(function()
	while(!stop_dist_check:GetBool()) do
		coroutine.yield()
		
		local zombies = {}
		for _, v in pairs(team.GetPlayers(TEAM_ZOMBIE)) do
			coroutine.yield()
			if (IsValid(v) and v.zs_deathstreak and v.zs_deathstreak.count > 0) then
				table.insert(zombies, v)
			end
		end
		
		-- local spawnpoints = ents.FindByClass("info_player_undead")
		-- spawnpoints = table.Add(spawnpoints, ents.FindByClass("info_player_zombie"))
		-- spawnpoints = table.Add(spawnpoints, ents.FindByClass("info_player_rebel"))
		
		for _, z in pairs(zombies) do
			coroutine.yield()
			if (IsValid(z)) then
				-- local valid = false
				-- for _, v in pairs(spawnpoints) do
					-- if math.sqrt((z:GetPos() - v:GetPos()):LengthSqr()) <= DS_LIMIT_DISTANCE + (z:GetPremium() and DS_LIMIT_DISTANCE * 0.1 or 0) then
						-- valid = true
						-- break
					-- end
					
					-- coroutine.yield()
				-- end
				-- if !valid then
					-- ResetDeathstreak(z)
				-- end
				
				if (!z.zs_deathstreak.spawn) then
					z.zs_deathstreak.spawn = 0
				end
				
				if (z.zs_deathstreak and z.zs_deathstreak.count >= 1 and z.zs_deathstreak.spawn + (30 + (z.deathstreakTimeAdder or 0)) <= CurTime() and z.zs_deathstreak.spawn ~= 0) then
					ResetDeathstreak(z)
				end
			end
		end
	end
end)

local lastDistCheck = 0
local DistanceCheck = function()
	coroutine.resume(crDistanceCheck)
	
	-- if lastDistCheck + 1 <= CurTime() then
		-- local zombies = {}
		-- for _, v in pairs(team.GetPlayers(TEAM_ZOMBIE)) do
			-- if v.zs_deathstreak and v.zs_deathstreak.count > 0 then
				-- table.insert(zombies, v)
			-- end
		-- end
		
		-- local spawnpoints = ents.FindByClass("info_player_undead")
		-- spawnpoints = table.Add(spawnpoints, ents.FindByClass("info_player_zombie"))
		-- spawnpoints = table.Add(spawnpoints, ents.FindByClass("info_player_rebel"))
		
		-- for _, z in pairs(zombies) do
			-- local valid = false
			-- for _, v in pairs(spawnpoints) do
				-- if z:GetPos():Distance(v:GetPos()) <= DS_LIMIT_DISTANCE + (z:GetPremium() and DS_LIMIT_DISTANCE * 0.1 or 0) then
					-- valid = true
					-- break
				-- end
			-- end
			-- if !valid then
				-- ResetDeathstreak(z)
			-- end
			
			-- if !z.zs_deathstreak.spawn then
				-- z.zs_deathstreak.spawn = 0
			-- end
			
			-- if z.zs_deathstreak and z.zs_deathstreak.count >= 1 and z.zs_deathstreak.spawn + 30 <= CurTime() and z.zs_deathstreak.spawn ~= 0 then
				-- ResetDeathstreak(z)
			-- end
		-- end
	-- end
end
hook.Add("Think", "zs_deathstreak.DistanceCheck", DistanceCheck)