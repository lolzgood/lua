local venom = {} 

venom.Enable = Menu.AddOptionBool({ "Hero Specific", "Venomancer" }, "Включить", false) 
venom.Gale = Menu.AddOptionBool({ "Hero Specific", "Venomancer" }, "Использовать Venomous Gale в комбо", false) 
Menu.AddOptionIcon(venom.Gale, "panorama/images/spellicons/venomancer_venomous_gale_png.vtex_c") 
venom.Ward = Menu.AddOptionBool({"Hero Specific", "Venomancer" }, "Использовать Plague Ward в комбо", false)
Menu.AddOptionIcon(venom.Ward, "panorama/images/spellicons/venomancer_plague_ward_png.vtex_c") 
venom.Ult = Menu.AddOptionBool({ "Hero Specific", "Venomancer" }, "Использовать Poison Nova в комбо", false)
Menu.AddOptionIcon(venom.Ult, "panorama/images/spellicons/venomancer_poison_nova_png.vtex_c") 
venom.Blink = Menu.AddOptionBool({ "Hero Specific", "Venomancer" }, "Использовать Blink Dagger в комбо", false) 
Menu.AddOptionIcon(venom.Blink, "panorama/images/items/blink_png.vtex_c") 
venom.Solar = Menu.AddOptionBool({ "Hero Specific", "Venomancer" }, "Использовать Solar Crest/Medallion Of Courage в комбо", false) 
Menu.AddOptionIcon(venom.Solar, "panorama/images/items/solar_crest_png.vtex_c") 
venom.Orchid = Menu.AddOptionBool({ "Hero Specific", "Venomancer" }, "Использовать Orchid в комбо", false) 
Menu.AddOptionIcon(venom.Orchid, "panorama/images/items/orchid_png.vtex_c") 
venom.Shivas = Menu.AddOptionBool({ "Hero Specific", "Venomancer" }, "Использовать Shivas Guard в комбо", false) 
Menu.AddOptionIcon(venom.Shivas, "panorama/images/items/shivas_guard_png.vtex_c") 
venom.Bloothorn = Menu.AddOptionBool({ "Hero Specific", "Venomancer" }, "Использовать Bloodthorn в комбо", false) 
Menu.AddOptionIcon(venom.Bloothorn, "panorama/images/items/bloodthorn_png.vtex_c") 
venom.Bkb = Menu.AddOptionBool({ "Hero Specific", "Venomancer" }, "Использовать Black King Bar в комбо", false) 
Menu.AddOptionIcon(venom.Bkb, "panorama/images/items/black_king_bar_png.vtex_c") 
venom.Nullifier = Menu.AddOptionBool({ "Hero Specific", "Venomancer" }, "Использовать Nullifier в комбо", false) 
Menu.AddOptionIcon(venom.Nullifier, "panorama/images/items/nullifier_png.vtex_c") 
venom.Defuse = Menu.AddOptionBool({ "Hero Specific", "Venomancer" }, "Использовать Diffusal Blade в комбо", false) 
Menu.AddOptionIcon(venom.Defuse, "panorama/images/items/diffusal_blade_png.vtex_c") 
venom.Key = Menu.AddKeyOption({ "Hero Specific", "Venomancer" }, "Кнопка для комбо", Enum.ButtonCode.KEY_F) 
venom.NearestTarget = Menu.AddOptionSlider({"Hero Specific", "Venomancer"}, "Радиус поиска цели около курсора", 200, 800, 100) 
venom.optionIcon = Menu.AddOptionIcon({ "Hero Specific","Venomancer"}, "panorama/images/heroes/icons/npc_dota_hero_venomancer_png.vtex_c") 


venom.lastTick = 0 
local sleep_after_cast 
local sleep_after_attack 

function venom.OnUpdate() 
me = Heroes.GetLocal() 
if not Menu.IsEnabled(venom.Enable) or not Engine.IsInGame() or not Heroes.GetLocal() then return end 

if NPC.GetUnitName(me) ~= "npc_dota_hero_venomancer" then return end 
if not Entity.IsAlive(me) or NPC.IsStunned(me) or NPC.IsSilenced(me) then return end 
if Menu.IsEnabled(venom.Enable) then 
enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(me), Enum.TeamType.TEAM_ENEMY) 
if enemy and enemy ~= 0 then 
venom.Combo(me, enemy) 
return end 
end 
end 

function venom.Combo() 
target = nil 
myTeam = Entity.GetTeamNum(me) 
enemy = Input.GetNearestHeroToCursor(myTeam, Enum.TeamType.TEAM_ENEMY) 
player = Players.GetLocal() 
mana = NPC.GetMana(me) 
ult = NPC.GetAbility(me, "venomancer_poison_nova") 
bkb = NPC.GetItem(me, "item_black_king_bar") 
orchid = NPC.GetItem(me, "item_orchid") 
bloodthorn = NPC.GetItem(me, "item_bloodthorn", true) 
nullifier = NPC.GetItem(me, "item_nullifier") 
blink = NPC.GetItem(me, "item_blink") 
gale = NPC.GetAbility(me, "venomancer_venomous_gale") 
ward = NPC.GetAbility(me, "venomancer_plague_ward") 
cursor_pos = Input.GetWorldCursorPos() 
shiva = NPC.GetItem(me, "item_shivas_guard")
blink_range = 1200 
mypos = Entity.GetAbsOrigin(me) 
enemy_origin = Entity.GetAbsOrigin(enemy) 
aim = (mypos - enemy_origin):Length2D() 
cursor_pos = Input.GetWorldCursorPos() 
defuse = NPC.GetItem(me,"item_diffusal_blade")
medal = NPC.GetItem(me, "item_medallion_of_courage")
if not medal then
        medal = NPC.GetItem(myHero, "item_solar_crest")
    end

if Menu.IsKeyDown(venom.Key) then 
if venom.SleepReady(0.6) then 
if (cursor_pos - enemy_origin):Length2D() > Menu.GetValue(venom.NearestTarget) then enemy = nil return end 
if NPC.IsPositionInRange(me, Entity.GetAbsOrigin(enemy), blink_range) then 
if Menu.IsEnabled(venom.Blink) and blink and Ability.IsReady(blink) then
Ability.CastPosition(blink, Entity.GetAbsOrigin(enemy)) end 
if Menu.IsEnabled(venom.Shivas) and shiva and Ability.IsReady(shiva, mana) then Ability.CastNoTarget (shiva) end
if Menu.IsEnabled(venom.Solar) and medal and Ability.IsReady(medal) then Ability.CastTarget(medal, enemy) end 
if Menu.IsEnabled(venom.Ult) and ult and Ability.IsCastable(ult, mana) and Ability.IsReady(ult) then Ability.CastNoTarget(ult) end 
if Menu.IsEnabled(venom.Bkb) and bkb and Ability.IsCastable(bkb, mana) and Ability.IsReady(bkb) then Ability.CastNoTarget(bkb) end
if Menu.IsEnabled(venom.Orchid) and orchid and Ability.IsCastable(orchid, mana) and Ability.IsReady(orchid) then Ability.CastTarget(orchid, enemy) end 
if Menu.IsEnabled(venom.Nullifier) and nullifier and Ability.IsCastable(nullifier, mana) and Ability.IsReady(nullifier) then Ability.CastTarget(nullifier, enemy) end 
if Menu.IsEnabled(venom.Bloothorn) and bloodthorn and Ability.IsCastable(bloodthorn, mana) and Ability.IsReady(bloodthorn) then Ability.CastTarget(bloodthorn, enemy, true) end 
if Menu.IsEnabled(venom.Gale) and gale and Ability.IsCastable(gale, mana) and Ability.IsReady(gale) then Ability.CastPosition(gale, Entity.GetAbsOrigin(enemy)) end 
if Menu.IsEnabled(venom.Ward) and ward and Ability.IsCastable(ward, mana) and Ability.IsReady(ward) then Ability.CastPosition(ward, Entity.GetAbsOrigin(enemy), true) end 
if Menu.IsEnabled(venom.Defuse) and defuse and Ability.IsReady(defuse) then Ability.CastTarget(defuse, enemy) end
Player.AttackTarget(player, me, enemy) 
end 
if venom.SleepReady(0.6, sleep_after_cast, sleep_after_attack) then 
Player.AttackTarget(Players.GetLocal(), me, enemy, false) 
sleep_after_attack = os.clock() 
venom.lastTick = os.clock() 
sleep_after_cast = os.clock() 

return 
end 
end 
end 

end 

function venom.SleepReady(sleep, lastTick) 
if (os.clock() - venom.lastTick) >= sleep then 
return true 
end 

return false 
end 

return venom