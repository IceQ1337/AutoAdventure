-- Copyright (c) 2020 IceQ1337 (https://github.com/IceQ1337)

local _, AutoAdventure = ...
local dump = DevTools_Dump

-- UI Globals
local MissionFrame = {} 
local MissionTab = {}
local MissionPage = {}

-- Adventure/Garrison Globals
local GarrisonType = Enum.GarrisonType.Type_9_0
local GarrisonFollowerType = Enum.GarrisonFollowerType.FollowerType_9_0
-- To-Do: Save C_Garrison functions in local functions

-- Event Frame & Setup
-----------------------------------------------------

local EventFrame = CreateFrame("Frame")
EventFrame:SetScript("OnEvent", function(self, event, ...)
	local arg1, arg2, arg3, arg4, arg5 = ...

	if event == "ADDON_LOADED" then
		if arg1 == "AutoAdventure" then
			--print("[Auto Adventure] ADDON_LOADED")
		elseif arg1 == "Blizzard_GarrisonUI" then
			MissionFrame = CovenantMissionFrame
			MissionTab = CovenantMissionFrame.MissionTab
			MissionPage = CovenantMissionFrame.MissionTab.MissionPage

			MissionFrame:HookScript("OnShow", MissionFrameOpen)

			EventFrame:UnregisterEvent("ADDON_LOADED")
		elseif arg1 == "GARRISON_MISSION_STARTED" then
			AutoAdventure:initializeMissions() -- We could also just close the MissionFrame because we recalculate when it gets opened again
		end
	end
end)

function MissionFrameOpen(self)
	MissionPage:HookScript("OnShow", MissionPageOpen)
	AutoAdventure:initializeMissions()
end

function MissionPageOpen(self)
	-- To-Do: Add (but hide) a button to insert result if exists
end

function AutoAdventure:registerEvents()
	EventFrame:RegisterEvent("ADDON_LOADED");
	EventFrame:RegisterEvent("GARRISON_MISSION_STARTED");
end

function AutoAdventure:setup()
	AutoAdventure:registerEvents()
end

AutoAdventure:setup()

-- Main Logic
-----------------------------------------------------

function AutoAdventure:initializeMissions()
	local hasAdventures = C_Garrison.HasAdventures()
	if hasAdventures then

		local Followers = C_Garrison.GetFollowers(GarrisonFollowerType) -- https://wow.gamepedia.com/API_C_Garrison.GetFollowers
		local AutoTroops = C_Garrison.GetAutoTroops(GarrisonFollowerType) -- https://wow.gamepedia.com/API_C_Garrison.GetAutoTroops
		local AvailableFollowers = Followers

		local MissionList = MissionTab.MissionList
		local Missions = MissionList.combinedMissions
		local AvailableMissions = {}

		if Missions then
			local MissionCount = #Missions
			for missionIndex, missionData in ipairs(Missions) do
				if missionData.followers and #missionData.followers > 0 then
					for missionFollowerIndex, missionFollowerData in ipairs(missionData.followers) do
						for followerIndex, followerData in ipairs(Followers) do
							local FollowerAutoCombatStatsInfo = C_Garrison.GetFollowerAutoCombatStats(followerData.followerID)

							-- Followers on active missions or with low health are considered "not available"
							if followerData.followerID == missionFollowerData or FollowerAutoCombatStatsInfo.currentHealth < 100 then
								table.remove(AvailableFollowers, followerIndex)
							end
						end
					end
				end

				if missionData.followerTypeID == GarrisonFollowerType and not missionData.inProgress and not missionData.completed and missionData.canStart then
					table.insert(AvailableMissions, missionData)
				end
			end

			AutoAdventure:calculateMissions(AvailableFollowers, AvailableMissions, AutoTroops)
		end
	end
end

function AutoAdventure:calculateMissions(AvailableFollowers, AvailableMissions, AutoTroops)
	if AvailableFollowers and #AvailableFollowers > 0 then
		print(string.format("Available Followers: %s", tostring(#AvailableFollowers)))

		local CalculatedMissions = {}
		
		for missionIndex, missionData in ipairs(AvailableMissions) do			
			--print(string.format("Calculating Mission: %s", tostring(missionData.missionID)))

			local missionDeploymentInfo = C_Garrison.GetMissionDeploymentInfo(missionData.missionID)
			local enemyEncounterInfo = missionDeploymentInfo.enemies -- https://wow.gamepedia.com/Struct_GarrisonEnemyEncounterInfo

			-- To-Do: Implement a decent auto battle logic with AvailableFollowers and AutoTroops based on raw values (no spells)

			-- Get simple board overview
			local EnemyBoard = {}
			local MaxBoardIndex = 0

			for enemyEncounterIndex, enemyEncounter in ipairs(enemyEncounterInfo) do
				if enemyEncounter.boardIndex > MaxBoardIndex then
					MaxBoardIndex = enemyEncounter.boardIndex
				end

				table.insert(EnemyBoard, {
					boardIndex = enemyEncounter.boardIndex,
					health = enemyEncounter.health,
					attack = enemyEncounter.attack,
					spellInfo = enemyEncounter.autoCombatSpells -- To-Do: Use this instead of raw values
				})

				--print(string.format("Index: %s - Name: %s", tostring(enemyEncounter.boardIndex), tostring(enemyEncounter.name)))
			end

			-- Enemy Board Index is always 5 to 12 ( 8 enemies )
			-- Position/Index seems to not be always the same depending on how many enemies there are in total

			-- https://wow.gamepedia.com/Struct_FollowerAutoCombatStatsInfo
			-- https://wow.gamepedia.com/Struct_AutoCombatSpellInfo

			local BoardStrategy = {} -- To-Do: Save boardIndex & followerID here
			for i = 1, 5 do -- We have 5 spots available on the board
				-- Follower Loop
				-- Evaluate followers first, because we could have an option to always use only one follower or force a win with all we got
				-- If we evaluate raw values, just get the followers ( 1 or all ) in there
				for followerIndex, followerData in ipairs(AvailableFollowers) do
					local FollowerAutoCombatStatsInfo = C_Garrison.GetFollowerAutoCombatStats(followerData.followerID)
					
				end

				-- Troop Loop
				-- If we evaluate raw values, just use the troop with highest health/attack ratio in every spot
				for autoTroopIndex, autoTroopData in ipairs(AutoTroops) do
					local FollowerAutoCombatStatsInfo = autoTroopData.autoCombatStats

				end
			end

			-- At this point, we should have calculated the best board based on raw values
			-- To-Do: Show the button to insert results
		end
	else
		print("No Follower Available!")
	end
end