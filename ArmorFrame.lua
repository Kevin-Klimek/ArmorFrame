playerArp = 0
sunderCount = 0
debuffArp = 0
totalArp = 0
DEBUG = true

-- what type of frame to use?
ArmorFrame = CreateFrame("button", "ArmorFrame", UIParent)
ArmorFrame:RegisterEvent("ADDON_LOADED")
ArmorFrame:RegisterEvent("COMBAT_RATING_UPDATE")
ArmorFrame:RegisterEvent("UNIT_AURA")
-- aDF:RegisterEvent("PLAYER_TARGET_CHANGED")
-- aDF:RegisterEvent("RAID_ROSTER_UPDATE")  -- show/hide if not in raid

--[[    Events to register:
        enemy target change -> update enemy debuffs, arp count
        enemy aura change   -> update enemy debuffs, arp count
        gear change         -> update arp count     (combatratingchange event?)
        buff change (trink) -> update arp count     (combatratingchange event?)
--]] 
-- COMBAT_RATING_UPDATE
-- UNIT_STATS:player, UnitStat("player")
-- https://wago.io/BkARo1QAm

-- CharacterStatsTbcFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
-- CharacterStatsTbcFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
-- CharacterStatsTbcFrame:RegisterEvent("UNIT_AURA");
-- CharacterStatsTbcFrame:RegisterEvent("PLAYER_DAMAGE_DONE_MODS");
-- CharacterStatsTbcFrame:RegisterEvent("SKILL_LINES_CHANGED");
-- CharacterStatsTbcFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
-- CharacterStatsTbcFrame:RegisterEvent("UNIT_DAMAGE");
-- CharacterStatsTbcFrame:RegisterEvent("UNIT_ATTACK_SPEED");
-- CharacterStatsTbcFrame:RegisterEvent("UNIT_RANGEDDAMAGE");
-- CharacterStatsTbcFrame:RegisterEvent("UNIT_ATTACK");
-- CharacterStatsTbcFrame:RegisterEvent("UNIT_RESISTANCES");
-- CharacterStatsTbcFrame:RegisterEvent("UNIT_STATS");
-- CharacterStatsTbcFrame:RegisterEvent("UNIT_MAXHEALTH");
-- CharacterStatsTbcFrame:RegisterEvent("UNIT_ATTACK_POWER");
-- CharacterStatsTbcFrame:RegisterEvent("UNIT_RANGED_ATTACK_POWER");
-- CharacterStatsTbcFrame:RegisterEvent("COMBAT_RATING_UPDATE");


--local playerArp = GetArmorPenetration() -- returns player arp
local function DEBUG_print_arp_table()
    if(DEBUG) then print("Player ARP: "..playerArp..", Debuff ARP: "..(520 * sunderCount)..", Total ARP: "..totalArp) end
end

local function get_player_arp()
    --return GetArmorPenetration()
    return GetSpellCritChance(5)    -- https://wowwiki-archive.fandom.com/wiki/API_GetCombatRating
end

local function set_player_arp(val)
    playerArp = val;
    totalArp = playerArp + debuffArp;
end

-- Updates player arp and redraws frame if player armor pen has updated OR force is true
local function update_player_arp(force)
    local currentPlayerArp = get_player_arp()
    if(force or currentPlayerArp ~= playerArp) then
        set_player_arp(currentPlayerArp)
        DEBUG_print_arp_table()
        -- update frame with new vals
    end
end

-- Updates arp debuffs and redraws frame if debuffs have changed. Flushes debuffs if targetChange is true
local function update_debuffs(targetChange)
    local changed = false
    -- on target change, clear all stored debuffs and rebuild
    if(targetChange) then
        sunderCount = 0
        changed = true
    end

    -- name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId  = UnitAura("target", "Arcane Intellect")
    local name, rank, icon , count = AuraUtil.FindAuraByName("Winter's Chill", "target") -- Sunder Armor
    if(name) then
        print("name: "..name.." rank: "..rank.." icon: "..icon.." count: "..count)
    else
        print("name: Winter's Chill, count: 0")
    end
end

-- Handles events 
local function event_handler(self, event, ...)
    if(event == "ADDON_LOADED") then
        local arg1 = ...
        if (arg1 == "ArmorFrame") then
            -- load frame, player arp (which redraws frame)
            update_player_arp(true)
        end
    elseif(event == "COMBAT_RATING_UPDATE") then
        update_player_arp(false)
    elseif(event == "UNIT_AURA") then
        local arg1 = ...
        if(arg1 == "player") then
            update_player_arp(false)
        elseif(arg1 == "target") then
            if(DEBUG) then print("ArmorFrame handling event: Target gained/lost buffs") end
            -- target debuff scan, update frame. same as target change
            update_debuffs(false) -- update_debuffs(true) on target change event
        end
    end
end

ArmorFrame:SetScript("OnEvent", event_handler)
-- Armor frame window interaction:
-- ArmorFrame:SetScript("OnEnter") --display tooltip        also many gui applications
-- ArmorFrame:SetScript("OnLeave") --hide tooltip           also many gui applications
-- ArmorFrame:SetScript("OnMouseDown") -- link  in chat     also many gui applications

-- Handles slash commands from the in game chat
local function slash_handler(cmd)
    if(cmd == nil or cmd == "") then
        -- print usage
        DEFAULT_CHAT_FRAME:AddMessage("ArmorFrame:")
        DEFAULT_CHAT_FRAME:AddMessage("type /af show to show frame")
        DEFAULT_CHAT_FRAME:AddMessage("type /af hide to hide frame")
        DEFAULT_CHAT_FRAME:AddMessage("type /af options to show ArmorFrame options")
    else
        if(cmd == "show") then
            DEFAULT_CHAT_FRAME:AddMessage("Showing frame")
            DEBUG = true                                            -- use show to show debugging info
            ArmorFrame:Show()
        elseif(cmd == "hide") then
            DEFAULT_CHAT_FRAME:AddMessage("Hiding frame")
            DEBUG = false                                           -- use hide to hide debugging info
            ArmorFrame:Hide()
        elseif(cmd == "options") then
            DEFAULT_CHAT_FRAME:AddMessage("Displaying options -- IN PROG")
        elseif(cmd == "test") then
            -- display test output
            DEFAULT_CHAT_FRAME:AddMessage("Player ARP: "..playerArp)
        else
            DEFAULT_CHAT_FRAME:AddMessage("Unrecognizable command: "..cmd)
        end
    end
end

SLASH_ARMOR1 = "/armorframe"
SLASH_ARMOR2 = "/af"
SlashCmdList["ARMOR"] = slash_handler