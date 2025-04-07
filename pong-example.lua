-- pong-example.lua
-- Copy this code into the ScriptDevil input and click 'run' to see a working pong example

local gameFrame = CreateFrame("Frame", "PongGame", UIParent)
gameFrame:SetSize(400, 300)
gameFrame:SetPoint("CENTER")
gameFrame:EnableMouse(true)
gameFrame:SetMovable(true)
gameFrame:RegisterForDrag("LeftButton")
gameFrame:SetScript("OnDragStart", gameFrame.StartMoving)
gameFrame:SetScript("OnDragStop", gameFrame.StopMovingOrSizing)

local bg = gameFrame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetColorTexture(0, 0, 0, 0.8)

local border = gameFrame:CreateTexture(nil, "BORDER")
border:SetPoint("TOPLEFT", -2, 2)
border:SetPoint("BOTTOMRIGHT", 2, -2)
border:SetColorTexture(1, 1, 1, 0.3)

local title = gameFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -10)
title:SetText("WoW Pong - Click to Start/Pause")

local scoreText = gameFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
scoreText:SetPoint("TOP", 0, -30)
scoreText:SetText("0 - 0")

local leftPaddle = gameFrame:CreateTexture(nil, "ARTWORK")
leftPaddle:SetSize(10, 60)
leftPaddle:SetPoint("LEFT", 20, 0)
leftPaddle:SetColorTexture(1, 1, 1, 1)

local rightPaddle = gameFrame:CreateTexture(nil, "ARTWORK")
rightPaddle:SetSize(10, 60)
rightPaddle:SetPoint("RIGHT", -20, 0)
rightPaddle:SetColorTexture(1, 1, 1, 1)

local ball = gameFrame:CreateTexture(nil, "ARTWORK")
ball:SetSize(10, 10)
ball:SetPoint("CENTER")
ball:SetColorTexture(1, 1, 1, 1)

local gameRunning = false
local playerScore = 0
local aiScore = 0
local ballSpeedX = 3
local ballSpeedY = 2
local paddleSpeed = 5
local ballPositionX = 0
local ballPositionY = 0
local aiDifficulty = 0.7

gameFrame:SetScript("OnMouseDown", function()
    gameRunning = not gameRunning
end)

local timeSinceLastUpdate = 0
gameFrame:SetScript("OnUpdate", function(self, elapsed)
    if not gameRunning then return end
    
    timeSinceLastUpdate = timeSinceLastUpdate + elapsed
    if timeSinceLastUpdate < 0.016 then return end -- ~60fps
    timeSinceLastUpdate = 0
    
    ballPositionX = ballPositionX + ballSpeedX
    ballPositionY = ballPositionY + ballSpeedY
    ball:SetPoint("CENTER", ballPositionX, ballPositionY)
    
    local ballLeft, ballBottom, ballWidth, ballHeight = ball:GetRect()
    local leftLeft, leftBottom, leftWidth, leftHeight = leftPaddle:GetRect()
    local rightLeft, rightBottom, rightWidth, rightHeight = rightPaddle:GetRect()
    
    if ballPositionY > 130 or ballPositionY < -130 then
        ballSpeedY = -ballSpeedY
    end
    
    if ballPositionX < -170 and ballPositionX > -180 and 
       ballPositionY > (leftPaddle:GetTop() - gameFrame:GetTop() - 30) and 
       ballPositionY < (leftPaddle:GetBottom() - gameFrame:GetBottom() + 30) then
        ballSpeedX = -ballSpeedX
        ballSpeedX = ballSpeedX * 1.05
        if ballSpeedY < 0 then
            ballSpeedY = ballSpeedY * 1.05
        else
            ballSpeedY = ballSpeedY * 1.05
        end
    end
    
    if ballPositionX > 170 and ballPositionX < 180 and 
       ballPositionY > (rightPaddle:GetTop() - gameFrame:GetTop() - 30) and 
       ballPositionY < (rightPaddle:GetBottom() - gameFrame:GetBottom() + 30) then
        ballSpeedX = -ballSpeedX
        ballSpeedX = ballSpeedX * 1.05
        if ballSpeedY < 0 then
            ballSpeedY = ballSpeedY * 1.05
        else
            ballSpeedY = ballSpeedY * 1.05
        end
    end
    
    if ballPositionX < -200 then
        aiScore = aiScore + 1
        scoreText:SetText(playerScore .. " - " .. aiScore)
        ballPositionX = 0
        ballPositionY = 0
        ballSpeedX = 3
        ballSpeedY = 2
    elseif ballPositionX > 200 then
        playerScore = playerScore + 1
        scoreText:SetText(playerScore .. " - " .. aiScore)
        ballPositionX = 0
        ballPositionY = 0
        ballSpeedX = -3
        ballSpeedY = 2
    end
    
    local _, my = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    my = my / scale
    local _, y = gameFrame:GetCenter()
    local paddleY = my - y
    if paddleY > 120 then paddleY = 120 end
    if paddleY < -120 then paddleY = -120 end
    leftPaddle:SetPoint("LEFT", 20, paddleY)
    
    if math.random() < aiDifficulty then
        local aiTarget = ballPositionY
        local _, rightY = rightPaddle:GetCenter()
        rightY = rightY - y
        if rightY < aiTarget - 10 then
            rightY = rightY + paddleSpeed
        elseif rightY > aiTarget + 10 then
            rightY = rightY - paddleSpeed
        end
        if rightY > 120 then rightY = 120 end
        if rightY < -120 then rightY = -120 end
        rightPaddle:SetPoint("RIGHT", -20, rightY)
    end
end)

local closeButton = CreateFrame("Button", nil, gameFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", -5, -5)
closeButton:SetScript("OnClick", function() 
    gameFrame:Hide()
end)

print("Pong game created! Move your mouse up and down to control the left paddle.")
print("Click inside the game to start or pause.")

gameFrame:Show()
