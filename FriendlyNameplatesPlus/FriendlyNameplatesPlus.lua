local addonName, FNP = ... 

local f = CreateFrame("Frame")

local defaults = {
    enabled = true,
    showInWorld = true,
    showInDelves = true,
    showInInstance = false,
    showInCity = false,
    debugEnabled = false,
}

local function Debug(msg)
    if FriendlyNameplatesPlusDB and FriendlyNameplatesPlusDB.debugEnabled then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00FNP:|r " .. msg)
    end
end

local function InitDB()
    if not FriendlyNameplatesPlusDB then
        FriendlyNameplatesPlusDB = {}
    end

    for k, v in pairs(defaults) do
        if FriendlyNameplatesPlusDB[k] == nil then
            FriendlyNameplatesPlusDB[k] = v
        end
    end

    Debug("DB initialized")
end

local function IsPlayerInCity()
    return IsResting()
end

-- Optimized SetFriendlyPlates
local function SetFriendlyPlates(state, inDelve)
    Debug("Trying to set plates to: " .. tostring(state))

    if InCombatLockdown() then
        Debug("Blocked by combat")
        FNP.pendingState = {state = state, inDelve = inDelve}
        return
    end

    local desired = state and "1" or "0"
    local current = GetCVar("nameplateShowFriendlyPlayers")

    if current ~= desired then
        SetCVar("nameplateShowFriendlyPlayers", desired)
        Debug("CVar 'nameplateShowFriendlyPlayers' set to: " .. desired)
    else
        Debug("CVar already correct: " .. desired)
    end

    -- Set minions only if we are in a Delve
    local current_minion = GetCVar("nameplateShowFriendlyPlayerMinions")
    local desired_minion = "0"

    if inDelve then
        desired_minion = "1"
    end

    if current_minion ~= desired_minion then
        SetCVar("nameplateShowFriendlyPlayerMinions", desired_minion)
        Debug("CVar 'nameplateShowFriendlyPlayerMinions' set to " .. desired_minion)
    else
        Debug("Minion CVar already correct: " .. desired_minion)
    end
end

-- EvaluateState unchanged
local function EvaluateState()
    Debug("Evaluating state...")

    if not FriendlyNameplatesPlusDB.enabled then
        Debug("Addon disabled")
        return
    end

    local inCity = IsPlayerInCity()
    local _, instanceType = GetInstanceInfo()

    Debug("InstanceType: " .. tostring(instanceType))
    Debug("City: " .. tostring(inCity))

    local shouldShow = false
    local inDelve = false

    if instanceType == "scenario" then
        shouldShow = FriendlyNameplatesPlusDB.showInDelves
        inDelve = true
        Debug("Delve detected (scenario)")

    elseif inCity then
        shouldShow = FriendlyNameplatesPlusDB.showInCity
        Debug("City rule")

    elseif instanceType == "party" or instanceType == "raid" or instanceType == "pvp" then
        shouldShow = FriendlyNameplatesPlusDB.showInInstance
        Debug("Other instance / raid / BG rule")

    else
        shouldShow = FriendlyNameplatesPlusDB.showInWorld
        Debug("World rule")
    end

    Debug("Final decision: " .. tostring(shouldShow))
    SetFriendlyPlates(shouldShow, inDelve)
end

-- Event handling unchanged
f:SetScript("OnEvent", function(self, event, ...)
    Debug("Event: " .. event)

    if event == "ADDON_LOADED" then
        local name = ...
        if name == addonName then
            InitDB()
            EvaluateState()
        end

    elseif event == "PLAYER_ENTERING_WORLD"
        or event == "ZONE_CHANGED_NEW_AREA"
        or event == "UPDATE_EXHAUSTION" then
        EvaluateState()

    elseif event == "PLAYER_REGEN_ENABLED" then
    if FNP.pendingState ~= nil then
        Debug("Applying pending state")
        SetFriendlyPlates(FNP.pendingState.state, FNP.pendingState.inDelve)
        FNP.pendingState = nil
        else
            EvaluateState()
        end
    end
end)

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("UPDATE_EXHAUSTION")

-- Slash command print functions
local function PrintHelp()
    print("|cff00ff00FriendlyNameplatesPlus commands:|r")
    print("|cffffff00/fnp help|r - Show this help")
    print("|cffffff00/fnp show|r - Show current values")
    print("|cffffff00/fnp zone|r - Show zone evaluation rule")
    print("|cffffff00/fnp enable <true/false>|r - Set addon automation flag")
    print("|cffffff00/fnp world <true/false>|r - Set world flag")
    print("|cffffff00/fnp city <true/false>|r - Set city flag")
    print("|cffffff00/fnp delves <true/false>|r - Set delves flag")
    print("|cffffff00/fnp instance <true/false>|r - Set instance flag")
    print("|cffffff00/fnp debug <true/false>|r - Set debug flag")
end
 
local function PrintCurrentSettings()
    print("|cff00ff00FriendlyNameplatesPlus current settings:|r")
    print("|cffffff00enabled:|r", FriendlyNameplatesPlusDB.enabled)
    print("|cffffff00showInWorld:|r", FriendlyNameplatesPlusDB.showInWorld)
    print("|cffffff00showInCity:|r", FriendlyNameplatesPlusDB.showInCity)
    print("|cffffff00showInDelves:|r", FriendlyNameplatesPlusDB.showInDelves)
    print("|cffffff00showInInstance:|r", FriendlyNameplatesPlusDB.showInInstance)
    print("|cffffff00debugEnabled:|r", FriendlyNameplatesPlusDB.debugEnabled )
end

local function GetCurrentRule()
    if not FriendlyNameplatesPlusDB.enabled then
        return DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00FNP:|r Addon disabled")
    end

    local mapID = C_Map.GetBestMapForUnit("player")
    local mapInfo = C_Map.GetMapInfo(mapID) or {}
    local zoneName = mapInfo.name or "Unknown"
    local inCity = IsPlayerInCity()
    local _, instanceType = GetInstanceInfo()
    local msg

    if instanceType == "scenario" then
        msg = "Delve/Scenario rule"
    elseif inCity then
        msg = "City rule"
    elseif instanceType == "party" or instanceType == "raid" or instanceType == "pvp" then
        msg = "Instance rule"
    else
        msg = "World rule"
    end

    local current = (GetCVar("nameplateShowFriendlyPlayers") == "1") and "true" or "false" 

    -- zone name and map ID & current rule
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00FNP:|r " .. "Zone: " .. zoneName .. " (" .. tostring(mapID) .. ") | " .. msg)

    -- current flag
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00FNP:|r Show Nameplates (" .. current .. ")")
end


-- Slash commands
-- Helper: convert string to boolean
local function to_bool(str)
    str = str and str:lower()
    if str == "true" or str == "1" then
        return true
    elseif str == "false" or str == "0" then
        return false
    end
    return nil
end

-- Map slash names to DB keys
local validFlags = {
    enabled = "enabled",
    world = "showInWorld",
    city = "showInCity",
    delves = "showInDelves",
    instance = "showInInstance",
    debug = "debugEnabled",
}

SlashCmdList["SMART_FRIENDLY_PLATES"] = function(msg)
    msg = msg:lower():trim() -- remove extra spaces

    if msg == "" then
        print("|cff00ff00FriendlyNameplatesPlus:|r Use |cffffff00/fnp help|r to show available commands")
        PrintCurrentSettings()
        return
    end

    if msg == "help" then
        PrintHelp()
        return
    end

    if msg == "show" then
        PrintCurrentSettings()
        return
    end

    if msg == "zone" then
        GetCurrentRule()
        return
    end

    -- Parse command and value
    local key, val = msg:match("(%S+)%s*(%S*)")
    local boolVal = to_bool(val)

    if key and boolVal ~= nil then
        local dbKey = validFlags[key]
        if dbKey then
            FriendlyNameplatesPlusDB[dbKey] = boolVal
            print("|cff00ff00FriendlyNameplatesPlus:|r", key, "set to", boolVal)
            EvaluateState() -- immediately re-evaluate
        else
            print("|cff00ff00FriendlyNameplatesPlus:|r Unknown flag: " .. key)
            PrintHelp()
        end
    else
        PrintHelp()
    end
end

-- Register slash
SLASH_SMART_FRIENDLY_PLATES1 = "/fnp"