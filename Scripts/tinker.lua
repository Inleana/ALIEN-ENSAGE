--<<Download texture https://mega.co.nz/#!8AZiFAbY!kMdEz0Fezz6cRzpVPrsNJTuUd4RFwHqDSI3cOV51U34 and unpack to nyanui/other>>

require("libs.ScriptConfig")
require("libs.Utils")
require("libs.TargetFind")
require("libs.Animations")
require("libs.Skillshot")

local config = ScriptConfig.new()
config:SetParameter("Hotkey", "32", config.TYPE_HOTKEY)
config:SetParameter("AUTOBLINK", true)
config:Load()

local play = false local myhero = nil local victim = nil local start = false local resettime = nil local sleep = 0
local rate = client.screenSize.x/1600 local rec = {}
rec[1] = drawMgr:CreateRect(70*rate,26*rate,270*rate,60*rate,0xFFFFFF30,drawMgr:GetTextureId("NyanUI/other/CM_status_1")) rec[1].visible = false
rec[2] = drawMgr:CreateText(175*rate,52*rate,0xFFFFFF90,"Target :",drawMgr:CreateFont("manabarsFont","Arial",18*rate,700)) rec[2].visible = false
rec[3] = drawMgr:CreateRect(220*rate,54*rate,16*rate,16*rate,0xFFFFFF30) rec[3].visible = false

function Main(tick)
	if not PlayingGame() then return end
	local me = entityList:GetMyHero()
	local ID = me.classId if ID ~= myhero then return end

	if victim and victim.visible then
		if not rec[i] then
			rec[3].textureId = drawMgr:GetTextureId("NyanUI/miniheroes/"..victim.name:gsub("npc_dota_hero_",""))
		end
	else
		rec[3].textureId = drawMgr:GetTextureId("NyanUI/spellicons/doom_bringer_empty1")
	end

	local attackRange = me.attackRange	

	if IsKeyDown(config.Hotkey) and not client.chat then	
		if Animations.CanMove(me) or not start or (victim and GetDistance2D(victim,me) > attackRange+50) then
			start = true
			local lowestHP = targetFind:GetLowestEHP(3000, phys)
			if lowestHP and (not victim or victim.creep or GetDistance2D(me,victim) > 600 or not victim.alive or lowestHP.health < victim.health) and SleepCheck("victim") then			
				victim = lowestHP
				Sleep(250,"victim")
			end
			if victim and GetDistance2D(victim,me) > attackRange+200 and victim.visible then
				local closest = targetFind:GetClosestToMouse(me,2000)
				if closest and (not victim or closest.handle ~= victim.handle) then 
					victim = closest
				end
			end
		end
		if not Animations.CanMove(me) and victim and GetDistance2D(me,victim) <= 2000 then
			if tick > sleep and SleepCheck("123") then
				if victim.hero and not Animations.isAttacking(me) then
					local Q = me:GetAbility(1)
					local W = me:GetAbility(2)
					local R = me:GetAbility(4)
					local blink = me:FindItem("item_blink")
					local sheep = me:FindItem("item_sheepstick")
					local ethereal = me:FindItem("item_ethereal_blade")
					local dagon = me:FindDagon()
					local sphere = me:FindItem("item_sphere")
					local soulring = me:FindItem("item_soul_ring")
					local distance = GetDistance2D(victim,me)
					local rearm = me:DoesHaveModifier("modifier_tinker_rearm")
					local slowed = victim:DoesHaveModifier("modifier_item_ethereal_blade_ethereal")
					if not rearm then
						if blink and blink:CanBeCasted() and me:CanCast() and distance > attackRange and distance <= 1199 and config.AUTOBLINK then
							local CP = blink:FindCastPoint()
							local delay = ((500-Animations.getDuration(R)*1000)+CP*1000+client.latency+me:GetTurnTime(victim)*1000)
							local speed = blink:GetSpecialData("blink_range")
							local xyz = SkillShot.SkillShotXYZ(me,victim,delay,speed)
							if xyz then
								me:CastAbility(blink,xyz)
								Sleep(CP*1000+me:GetTurnTime(victim)*1000, "casting")
							end
						end
						if sheep and sheep:CanBeCasted() and me:CanCast() and distance <= sheep.castRange then
							me:CastAbility(sheep, victim)
							Sleep(sheep:FindCastPoint()*1000+me:GetTurnTime(victim)*1000, "123")
						end
						if Q and Q:CanBeCasted() and me:CanCast() and distance <= Q.castRange then
							me:CastAbility(Q,victim)
							Sleep(Q:FindCastPoint()*1000+me:GetTurnTime(victim)*1000, "123")
						end
						if W and W:CanBeCasted() and me:CanCast() and distance <= W.castRange then
							me:CastAbility(W)
							Sleep(W:FindCastPoint()*1000+me:GetTurnTime(victim)*1000, "123")
						end
						if ethereal and ethereal:CanBeCasted() and me:CanCast() and distance <= ethereal.castRange then
							me:CastAbility(ethereal, victim)
							Sleep(ethereal:FindCastPoint()*1000+me:GetTurnTime(victim)*1000, "123")
						end
						if dagon and dagon:CanBeCasted() and me:CanCast() and distance <= dagon.castRange then
							me:CastAbility(dagon, victim)
							Sleep(dagon:FindCastPoint()*1000+me:GetTurnTime(victim)*1000, "123")
						end
						if soulring and soulring:CanBeCasted() and me:CanCast() then
							me:CastAbility(soulring)
							Sleep(client.latency, "123")
						end
						if dagon and not ethereal and not sheep and R and R:CanBeCasted() and me:CanCast() then
							if dagon.cd ~= 0 and W.cd ~= 0 then
								me:CastAbility(R)
								Sleep(1100+client.latency, "123")
							end
						end
						if dagon and ethereal and not sheep and R and R:CanBeCasted() and me:CanCast() then
							if dagon.cd ~= 0 and ethereal.cd ~= 0 and W.cd ~= 0 then
								me:CastAbility(R)
								Sleep(1100+client.latency, "123")
							end
						end
						if dagon and ethereal and sheep and R and R:CanBeCasted() and me:CanCast() then
							if dagon.cd ~= 0 and W.cd ~= 0 and ethereal.cd ~= 0 and sheep.cd ~= 0 and W.cd ~= 0 then
								me:CastAbility(R)
								Sleep(1100+client.latency, "123")
							end
						end
					end
					if not rearm and not slowed then
						me:Attack(victim)
						sleep = tick + 100
					end
				end
			end
		end
	elseif victim then
			if not resettime then
			resettime = client.gameTime
		elseif (client.gameTime - resettime) >= 6 then
			victim = nil		
		end
		start = false
	end 
end

function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if me.classId ~= CDOTA_Unit_Hero_Tinker then 
			script:Disable() 
		else
			play = true
			victim = nil
			start = false
			resettime = nil
			myhero = me.classId
			rec[1].w = 90*rate + 30*0*rate + 65*rate rec[1].visible = true
			rec[2].x = 30*rate + 90*rate + 30*0*rate + 65*rate - 95*rate rec[2].visible = true
			rec[3].x = 80*rate + 90*rate + 30*0*rate + 65*rate - 50*rate rec[3].visible = true
			script:RegisterEvent(EVENT_FRAME, Main)
			script:UnregisterEvent(Load)
		end
	end	
end

function Close()
	myhero = nil
	victim = nil
	start = false
	resettime = nil
	rec[1].visible = false
	rec[2].visible = false
	rec[3].visible = false
	if play then
		script:UnregisterEvent(Main)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_CLOSE,Close)
script:RegisterEvent(EVENT_TICK,Load)