-- ░▒▓███████▓▒░░▒▓██████▓▒░░▒▓███████▓▒░░▒▓█▓▒░▒▓███████▓▒░▒▓████████▓▒░▒▓███████▓▒░░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░        
-- ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░  ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░        
-- ░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░  ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░       ░▒▓█▓▒▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░        
--  ░▒▓██████▓▒░░▒▓█▓▒░      ░▒▓███████▓▒░░▒▓█▓▒░▒▓███████▓▒░  ░▒▓█▓▒░  ░▒▓█▓▒░░▒▓█▓▒░▒▓██████▓▒░  ░▒▓█▓▒▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░        
--        ░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░        ░▒▓█▓▒░  ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░        ░▒▓█▓▓█▓▒░ ░▒▓█▓▒░▒▓█▓▒░        
--        ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░        ░▒▓█▓▒░  ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░        ░▒▓█▓▓█▓▒░ ░▒▓█▓▒░▒▓█▓▒░        
-- ░▒▓███████▓▒░ ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░        ░▒▓█▓▒░  ░▒▓███████▓▒░░▒▓████████▓▒░  ░▒▓██▓▒░  ░▒▓█▓▒░▒▓████████▓▒░ 

-- An addon for writing, testing, and running Lua scripts inside WoW

-- by d05dev 
-- Twitter - @d05dev
-- Github - https://www.github.com/d05dev

local addonName, SD = ...
SD.version = "1.15.6"

ScriptDevilDB = ScriptDevilDB or {
    scripts = {},
    options = {
        fontSize = 12,
        frameWidth = 600,
        frameHeight = 400,
        autoIndent = true,
        showLineNumbers = true
    }
}

function SD:CreateMainFrame()
    local frame = CreateFrame("Frame", "ScriptDevilFrame", UIParent)
    if BackdropTemplateMixin then
        Mixin(frame, BackdropTemplateMixin)
    end
    frame:SetFrameStrata("HIGH")
    frame:SetWidth(ScriptDevilDB.options.frameWidth)
    frame:SetHeight(ScriptDevilDB.options.frameHeight)
    frame:SetPoint("CENTER")
    
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -15)
    title:SetText("ScriptDevil v" .. SD.version)
    
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)
    
    local scrollFrame = CreateFrame("ScrollFrame", "ScriptDevilScrollFrame", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 20, -50)
    scrollFrame:SetPoint("BOTTOMRIGHT", -40, 60)

    local editBox = CreateFrame("EditBox", "ScriptDevilEditBox", scrollFrame, "BackdropTemplate")
    editBox:SetMultiLine(true)
    editBox:SetFontObject(ChatFontNormal)
    editBox:SetWidth(scrollFrame:GetWidth() - 20)
    editBox:SetHeight(200)
    editBox:SetAutoFocus(false)
    editBox:SetScript("OnEscapePressed", function() editBox:ClearFocus() end)
    editBox:SetTextInsets(8, 8, 8, 8)
    scrollFrame:SetScrollChild(editBox)

    local sfBackdrop = CreateFrame("Frame", "ScrollFrameBackdrop", scrollFrame, "BackdropTemplate")
    sfBackdrop:SetAllPoints(scrollFrame)
    sfBackdrop:SetBackdrop({
      bgFile = "Interface/Tooltips/UI-Tooltip-Background",
      edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
      edgeSize = 16,
      tile = true,
      tileSize = 16, 
      insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    sfBackdrop:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    sfBackdrop:SetFrameLevel(scrollFrame:GetFrameLevel() - 1)
    
    local dropdown = CreateFrame("Frame", "ScriptDevilDropdown", frame, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", 15, -15)
    
    local runButton = CreateFrame("Button", "ScriptDevilRunButton", frame, "UIPanelButtonTemplate")
    runButton:SetPoint("BOTTOMLEFT", 20, 20)
    runButton:SetSize(80, 22)
    runButton:SetText("Run")
    runButton:SetScript("OnClick", function() SD:RunScript() end)
    
    local saveButton = CreateFrame("Button", "ScriptDevilSaveButton", frame, "UIPanelButtonTemplate")
    saveButton:SetPoint("LEFT", runButton, "RIGHT", 10, 0)
    saveButton:SetSize(80, 22)
    saveButton:SetText("Save")
    saveButton:SetScript("OnClick", function() SD:SaveScript() end)
    
    local newButton = CreateFrame("Button", "ScriptDevilNewButton", frame, "UIPanelButtonTemplate")
    newButton:SetPoint("LEFT", saveButton, "RIGHT", 10, 0)
    newButton:SetSize(80, 22)
    newButton:SetText("New")
    newButton:SetScript("OnClick", function() SD:NewScript() end)
    
    local deleteButton = CreateFrame("Button", "ScriptDevilDeleteButton", frame, "UIPanelButtonTemplate")
    deleteButton:SetPoint("LEFT", newButton, "RIGHT", 10, 0)
    deleteButton:SetSize(80, 22)
    deleteButton:SetText("Delete")
    deleteButton:SetScript("OnClick", function() SD:DeleteScript() end)
    
    local clearButton = CreateFrame("Button", "ScriptDevilClearButton", frame, "UIPanelButtonTemplate")
    clearButton:SetPoint("BOTTOMRIGHT", -20, 20)
    clearButton:SetSize(100, 22)
    clearButton:SetText("Clear Output")
    clearButton:SetScript("OnClick", function() 
        SD.outputText:SetText("")
        SD.outputFrame:Hide()
    end)
    
    local outputFrame = CreateFrame("Frame", "ScriptDevilOutputFrame", frame)
    if BackdropTemplateMixin then
        Mixin(outputFrame, BackdropTemplateMixin)
    end
    outputFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    outputFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.7)
    outputFrame:SetWidth(frame:GetWidth() - 40)
    outputFrame:SetHeight(100)
    outputFrame:SetPoint("BOTTOM", frame, "BOTTOM", 0, -120)
    outputFrame:Hide()
    
    local outputText = outputFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    outputText:SetPoint("TOPLEFT", 10, -10)
    outputText:SetPoint("BOTTOMRIGHT", -10, 10)
    outputText:SetJustifyH("LEFT")
    outputText:SetJustifyV("TOP")
    outputText:SetText("")
    
    
    SD.frame = frame
    SD.editBox = editBox
    SD.dropdown = dropdown
    SD.outputFrame = outputFrame
    SD.outputText = outputText
    SD.clearButton = clearButton
    SD.currentScript = nil
    
    SD:UpdateScriptDropdown()
    
    return frame
end

function SD:RunScript()
    local code = SD.editBox:GetText()
    
    local env = {
        print = function(...)
            local args = {...}
            local output = ""
            for i = 1, #args do
                output = output .. tostring(args[i]) .. " "
            end
            SD.outputText:SetText(output)
            SD.outputFrame:Show()
            SD.clearButton:Show()
            _G.print(...)
        end
    }
    
    for k, v in pairs(_G) do
        env[k] = v
    end
    
    setmetatable(env, { __index = _G })
    
    SD.outputFrame:Show()
    local func, errorMsg = loadstring(code)
    if not func then
        SD.outputText:SetText("Error: " .. (errorMsg or "Unknown error"))
        return
    end
    
    setfenv(func, env)
    local success, result = pcall(func)
    if not success then
        SD.outputText:SetText("Runtime Error: " .. (result or "Unknown error"))
    elseif result ~= nil then
        SD.outputText:SetText("Result: " .. tostring(result))
    end
end

function SD:SaveScript()
    local scriptName = SD.currentScript
    
    if not scriptName then
        StaticPopup_Show("SCRIPT_DEVIL_SAVE")
        return
    end
    
    ScriptDevilDB.scripts[scriptName] = SD.editBox:GetText()
    print("Script '" .. scriptName .. "' saved.")
end

StaticPopupDialogs["SCRIPT_DEVIL_SAVE"] = {
    text = "Enter script name:",
    button1 = "Save",
    button2 = "Cancel",
    hasEditBox = 1,
    maxLetters = 32,
    OnAccept = function(self)
        local scriptName = self.editBox:GetText()
        if scriptName and scriptName ~= "" then
            ScriptDevilDB.scripts[scriptName] = SD.editBox:GetText()
            SD.currentScript = scriptName
            SD:UpdateScriptDropdown()
            print("Script '" .. scriptName .. "' saved.")
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function SD:NewScript()
    SD.editBox:SetText("")
    SD.currentScript = nil
    SD.outputFrame:Hide()
    UIDropDownMenu_SetText(SD.dropdown, "New Script")
end

function SD:DeleteScript()
    if not SD.currentScript then return end
    
    StaticPopupDialogs["SCRIPT_DEVIL_DELETE"] = {
        text = "Delete script '" .. SD.currentScript .. "'?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            ScriptDevilDB.scripts[SD.currentScript] = nil
            SD:NewScript()
            SD:UpdateScriptDropdown()
            print("Script deleted.")
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    
    StaticPopup_Show("SCRIPT_DEVIL_DELETE")
end

function SD:LoadScript(scriptName)
    SD.currentScript = scriptName
    SD.editBox:SetText(ScriptDevilDB.scripts[scriptName] or "")
    SD.outputFrame:Hide()
    UIDropDownMenu_SetText(SD.dropdown, scriptName)
end

function SD:UpdateScriptDropdown()
    UIDropDownMenu_Initialize(SD.dropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        
        for scriptName, _ in pairs(ScriptDevilDB.scripts) do
            info.text = scriptName
            info.func = function() SD:LoadScript(scriptName) end
            info.checked = (SD.currentScript == scriptName)
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    
    if SD.currentScript then
        UIDropDownMenu_SetText(SD.dropdown, SD.currentScript)
    else
        UIDropDownMenu_SetText(SD.dropdown, "New Script")
    end
end

SLASH_SCRIPTDEVIL1 = "/scriptdevil"
SLASH_SCRIPTDEVIL2 = "/sd"
SlashCmdList["SCRIPTDEVIL"] = function(msg)
    if not SD.frame then
        SD:CreateMainFrame()
    end
    
    if SD.frame:IsShown() then
        SD.frame:Hide()
    else
        SD.frame:Show()
    end
end

local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        print("ScriptDevil v" .. SD.version .. " loaded. Type /sd to open.")
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", OnEvent)
