local LAIO = {}
local Wrap = require("scripts.WrapUtility")
LAIO.optionHeroSF = Menu.AddOptionBool({"Полезные", "Windranger"}, "Включить", false)
LAIO.optionHeroSFEulCombo = Menu.AddOptionBool({"Полезные", "Windranger"}, "Авто Shackleshot", false)
LAIO.optionActiveButton = Menu.AddKeyOption({"Полезные", "Windranger"}, "Кнопка", Enum.ButtonCode.KEY_D)
LAIO.optionHeroSFDrawReqDMG = Menu.AddOptionBool({"Полезные", "Windranger"}, "Показатель нанесенного урона за shackleshot + focus fire", false)
LAIO.skywrathFont = Renderer.LoadFont("Tahoma", 16, Enum.FontWeight.EXTRABOLD)
LAIO.Gametime = 0
function LAIO.OnDraw()
	if not Menu.IsEnabled(LAIO.optionHeroSF) then return end
	local myHero = Heroes.GetLocal()
        	if not myHero then return end
			
	if not Wrap.EIsAlive(myHero) then return end
	if NPC.GetUnitName(myHero) == "npc_dota_hero_windrunner" then
		LAIO.SFComboDrawRequiemDamage(myHero)
	end
end

function LAIO.getComboTarget(myHero)

	if not myHero then return end

	local targetingRange = 400
	local mousePos = Input.GetWorldCursorPos()

	local enemyTable = Wrap.HInRadius(mousePos, targetingRange, Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
		if #enemyTable < 1 then return end

	local nearestTarget = nil
	local distance = 99999

	for i, v in ipairs(enemyTable) do
		if v and Entity.IsHero(v) then
			if LAIO.targetChecker(v) ~= nil then
				local enemyDist = (Entity.GetAbsOrigin(v) - mousePos):Length2D()
				if enemyDist < distance then
					nearestTarget = v
					distance = enemyDist
				end
			end
		end
	end

	return nearestTarget or nil

end

function LAIO.OnUpdate()

	local LockedTarget = nil
	if not Menu.IsEnabled(LAIO.optionHeroSF) then return end
	if GameRules.GetGameState() < 4 then return end
	if GameRules.GetGameState() > 5 then return end
	local myHero = Heroes.GetLocal()
	local myUnitName = nil
	if not myHero then return end
	if not Wrap.EIsAlive(myHero) then return end
	if myUnitName == nil then
		myUnitName = NPC.GetUnitName(myHero)
	end
	if LAIO.Gametime == 0 then LAIO.Gametime = GameRules.GetGameTime() end 
	local enemy = LAIO.getComboTarget(myHero)
	if Menu.IsKeyDown(LAIO.optionActiveButton) then
		if enemy then
			LockedTarget = enemy
		else
			LockedTarget = nil
		end
	else
		LockedTarget = nil
	end
	if LockedTarget ~= nil then
		if not Wrap.EIsAlive(LockedTarget) then
			LAIO.LockedTarget = nil
		elseif Entity.IsDormant(LockedTarget) then
			LockedTarget = nil
		elseif not NPC.IsEntityInRange(myHero, LockedTarget, 1000) then
			LockedTarget = nil
		end
	end
	
	local comboTarget
		if LockedTarget ~= nil then
			comboTarget = LockedTarget
		else
			if not Menu.IsKeyDown(LAIO.optionHeroSFEulCombo ) then
				comboTarget = enemy
			end
		end
	if myUnitName == "npc_dota_hero_windrunner" and comboTarget then
	    if Menu.IsEnabled(LAIO.optionHeroSFEulCombo) then 
		    if Menu.IsKeyDown(LAIO.optionActiveButton) then 
		        LAIO.SFCombo(myHero, comboTarget)
		    end
	    end
	end
end


function LAIO.heroCanCastSpells(myHero, enemy)

	if not myHero then return false end
	if not Wrap.EIsAlive(myHero) then return false end

	if NPC.IsSilenced(myHero) then return false end 
	if NPC.IsStunned(myHero) then return false end
	if NPC.HasModifier(myHero, "modifier_bashed") then return false end
	if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_INVULNERABLE) then return false end	
	if NPC.HasModifier(myHero, "modifier_eul_cyclone") then return false end
	if NPC.HasModifier(myHero, "modifier_obsidian_destroyer_astral_imprisonment_prison") then return false end
	if NPC.HasModifier(myHero, "modifier_shadow_demon_disruption") then return false end	
	if NPC.HasModifier(myHero, "modifier_invoker_tornado") then return false end
	if NPC.HasState(myHero, Enum.ModifierState.MODIFIER_STATE_HEXED) then return false end
	if NPC.HasModifier(myHero, "modifier_legion_commander_duel") then return false end
	if NPC.HasModifier(myHero, "modifier_axe_berserkers_call") then return false end
	if NPC.HasModifier(myHero, "modifier_winter_wyvern_winters_curse") then return false end
	if NPC.HasModifier(myHero, "modifier_bane_fiends_grip") then return false end
	if NPC.HasModifier(myHero, "modifier_bane_nightmare") then return false end
	if NPC.HasModifier(myHero, "modifier_faceless_void_chronosphere_freeze") then return false end
	if NPC.HasModifier(myHero, "modifier_enigma_black_hole_pull") then return false end
	if NPC.HasModifier(myHero, "modifier_magnataur_reverse_polarity") then return false end
	if NPC.HasModifier(myHero, "modifier_pudge_dismember") then return false end
	if NPC.HasModifier(myHero, "modifier_shadow_shaman_shackles") then return false end
	if NPC.HasModifier(myHero, "modifier_techies_stasis_trap_stunned") then return false end
	if NPC.HasModifier(myHero, "modifier_storm_spirit_electric_vortex_pull") then return false end
	if NPC.HasModifier(myHero, "modifier_tidehunter_ravage") then return false end
	if NPC.HasModifier(myHero, "modifier_windrunner_shackle_shot") then return false end
	if NPC.HasModifier(myHero, "modifier_item_nullifier_mute") then return false end

	if enemy then
		if NPC.HasModifier(enemy, "modifier_item_aeon_disk_buff") then return false end
	end

	return true	

end
	
	
function LAIO.SFCombo(myHero, enemy)
	if not Menu.IsEnabled(LAIO.optionHeroSF) then return end
	local shakle = NPC.GetAbilityByIndex(myHero, 0)
	local ff = NPC.GetAbilityByIndex(myHero, 5)
	local lvlff = Ability.GetLevel(ff)
	local lvlshakle = Ability.GetLevel(shakle)
	local myMana = NPC.GetMana(myHero)
	local blink = NPC.GetItem(myHero, "item_blink", true)
	if enemy then
	    local pos = Entity.GetAbsOrigin(enemy)
		local pos1 = Entity.GetAbsOrigin(myHero)
		local tree = Trees.InRadius(pos, 500)
		local finded = false
		for key,value in ipairs(tree) do
		    if value ~= nil then 
			    if Tree.IsActive(value) then
					local posTree = Entity.GetAbsOrigin(value)
					local X = tonumber(string.format("%.1f", (posTree:GetX()-pos:GetX())/(pos1:GetX()-pos:GetX())))
					local Y = tonumber(string.format("%.1f", (posTree:GetY()-pos:GetY())/(pos1:GetY()-pos:GetY())))
					if X < 0 and Y < 0 and math.abs(X-Y) < 0.5 then finded = true end
				end
			end
		end
		local enemys = Entity.GetUnitsInRadius(myHero, 550 ,Enum.TeamType.TEAM_ENEMY)
		for key,value in ipairs(enemys) do
		    if value ~= nil then 
			    if value and Entity.IsAlive(value) and NPC.IsVisible(value) then
					local posTree = Entity.GetAbsOrigin(value)
					local X = tonumber(string.format("%.1f", (posTree:GetX()-pos:GetX())/(pos1:GetX()-pos:GetX())))
					local Y = tonumber(string.format("%.1f", (posTree:GetY()-pos:GetY())/(pos1:GetY()-pos:GetY())))
					if X < 0 and Y < 0 and math.abs(X-Y) < 0.5 then finded = true end
				end
			end
		end
		if finded == true then 
		    if shakle and Ability.IsCastable(shakle, myMana) and LAIO.Gametime < GameRules.GetGameTime()+0.1 then 
		        Ability.CastTarget(shakle, enemy) 
				LAIO.Gametime = GameRules.GetGameTime()
	     	end
		end
		    end
		end 
function LAIO.targetChecker(genericEnemyEntity)

	local myHero = Heroes.GetLocal()
		if not myHero then return end

	if genericEnemyEntity and not Entity.IsDormant(genericEnemyEntity) and not NPC.IsIllusion(genericEnemyEntity) and Entity.GetHealth(genericEnemyEntity) > 0 then
	return genericEnemyEntity
	end	
end
function LAIO.SFComboDrawRequiemDamage(myHero)

	if not myHero then return end
	if not Menu.IsEnabled(LAIO.optionHeroSFDrawReqDMG) then return end

	local enemy = LAIO.targetChecker(Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY))
		if not enemy then return end

	local pos = Entity.GetAbsOrigin(enemy)
	local posY = NPC.GetHealthBarOffset(enemy)
		pos:SetZ(pos:GetZ() + posY)
			
	local x, y, visible = Renderer.WorldToScreen(pos)

	local shakle = NPC.GetAbilityByIndex(myHero, 0)
	local ff = NPC.GetAbilityByIndex(myHero, 5)
	local myMana = NPC.GetMana(myHero)
	local lvlff = Ability.GetLevel(ff)
	local lvlshakle = Ability.GetLevel(shakle)
	
	if lvlff == 0 or lvlshakle == 0 then return end
	
	local aghanims = NPC.GetItem(myHero, "item_ultimate_scepter", true)
	
	local aps = NPC.GetIncreasedAttackSpeed(myHero) + 4.5
	if not Ability.IsReady(ff) then 
	aps = aps - 4.5
	end
	aps = aps /1.5 
	
	local damage = (NPC.GetTrueDamage(myHero) + NPC.GetTrueMaximumDamage(myHero))/2
	
	if aghanims and lvlff ~= 0 then 
	    if lvlff == 1 then
		    damage = damage * 0.7
		elseif lvlff == 2 then
		    damage = damage * 0.85
		else
		damage = damage * 1
		end
	else
	    if lvlff == 1 then
		    damage = damage * 0.5
		elseif lvlff == 2 then
		    damage = damage * 0.6
		else
		damage = damage * 0.7
		end
	end
	
	local dps = 0
	
	local timer = 2 + 0.6 * (lvlshakle-1)
	dps = tonumber(string.format("%.1f", damage * aps)) * timer
	if visible then
		if Entity.GetHealth(enemy) > dps then
			Renderer.SetDrawColor(255,102,102,255)
		else
			Renderer.SetDrawColor(50,205,50,255)
		end
		Renderer.DrawText(LAIO.skywrathFont, x-40, y-70, "Урон: " .. math.floor(dps), 0)
	end
end

return LAIO
