--// Services
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local RunService = game:GetService("RunService")

--// Remotes
local ragdollRemote = RS:WaitForChild("Remotes"):WaitForChild("Ragdoll")

--// Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "My Game Control Panel",
    LoadingTitle = "Loading UI",
    LoadingSubtitle = "By Developer",
    ConfigurationSaving = {
       Enabled = false,
    }
})

--// GENERAL TAB
local GeneralTab = Window:CreateTab("General", 4483362458)

-- Anti Ragdoll
local antiRagdoll = false
GeneralTab:CreateToggle({
    Name = "Anti-Ragdoll",
    CurrentValue = false,
    Callback = function(Value)
        antiRagdoll = Value
    end,
})

RunService.Heartbeat:Connect(function()
    if antiRagdoll then
        local args = {"off"}
        ragdollRemote:FireServer(unpack(args))
    end
end)

-- Auto Collect Function
local function autoCollect(itemName)
    local obj = WS.Bombs:FindFirstChild(itemName)
    if obj then
        obj.CanCollide = false
        obj.Transparency = 1
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            obj.CFrame = player.Character.HumanoidRootPart.CFrame
        end
    end
end

-- Auto Collect Magic Shield
local autoMagicShield = false
GeneralTab:CreateToggle({
    Name = "Auto Collect Magic Shield",
    CurrentValue = false,
    Callback = function(Value)
        autoMagicShield = Value
    end,
})

RunService.Heartbeat:Connect(function()
    if autoMagicShield then
        autoCollect("MagicShield")
    end
end)
-- Auto Collect Event Coin
local autoCoinEvent = false
GeneralTab:CreateToggle({
    Name = "Auto Collect Event Coin",
    CurrentValue = false,
    Callback = function(Value)
        autoCoinEvent = Value
    end,
})

RunService.Heartbeat:Connect(function()
    if autoCoinEvent then
        autoCollect("Coin_event")
    end
end)

-- Auto Collect Silver Coin
local autoCoinSilver = false
GeneralTab:CreateToggle({
    Name = "Auto Collect Silver Coin",
    CurrentValue = false,
    Callback = function(Value)
        autoCoinSilver = Value
    end,
})

RunService.Heartbeat:Connect(function()
    if autoCoinSilver then
        autoCollect("Coin_silver")
    end
end)

-- Auto Collect Copper Coin
local autoCoinCopper = false
GeneralTab:CreateToggle({
    Name = "Auto Collect Copper Coin",
    CurrentValue = false,
    Callback = function(Value)
        autoCoinCopper = Value
    end,
})

RunService.Heartbeat:Connect(function()
    if autoCoinCopper then
        autoCollect("Coin_copper")
    end
end)

-- Auto Collect Golden Coin
local autoCoinGold = false
GeneralTab:CreateToggle({
    Name = "Auto Collect Golden Coin",
    CurrentValue = false,
    Callback = function(Value)
        autoCoinGold = Value
    end,
})
-- Auto Collect Heart
local autoHeart = false
GeneralTab:CreateToggle({
    Name = "Auto Collect Heart",
    CurrentValue = false,
    Callback = function(Value)
        autoHeart = Value
    end,
})
-- Auto Collect Fire Shield
local autoFireShield = false
GeneralTab:CreateToggle({
    Name = "Auto Collect Fire Shield",
    CurrentValue = false,
    Callback = function(Value)
        autoFireShield = Value
    end,
})

RunService.Heartbeat:Connect(function()
    if autoFireShield then
        autoCollect("FireShield")
    end
end)

RunService.Heartbeat:Connect(function()
    if autoHeart then
        autoCollect("HeartPickup")
    end
end)

RunService.Heartbeat:Connect(function()
    if autoCoinGold then
        autoCollect("Coin_gold")
    end
end)

-- Auto Collect Pizza
local autoPizza = false
GeneralTab:CreateToggle({
    Name = "Auto Collect Pizza",
    CurrentValue = false,
    Callback = function(Value)
        autoPizza = Value
    end,
})

RunService.Heartbeat:Connect(function()
    if autoPizza then
        autoCollect("Pizza")
    end
end)

-- Auto Collect Charge Soda
local autoSoda = false
GeneralTab:CreateToggle({
    Name = "Auto Collect Charge Soda",
    CurrentValue = false,
    Callback = function(Value)
        autoSoda = Value
    end,
})

RunService.Heartbeat:Connect(function()
    if autoSoda then
        autoCollect("ChargeSoda")
    end
end)

--// EVENT TAB
local EventTab = Window:CreateTab("Event", 4483362458)

-- Auto Collect Candy
local autoCandy = false
EventTab:CreateToggle({
    Name = "Auto Collect Halloween Candy",
    CurrentValue = false,
    Callback = function(Value)
        autoCandy = Value
    end,
})

RunService.Heartbeat:Connect(function()
    if autoCandy then
        autoCollect("HalloweenCandy")
    end
end)
-- Auto Collect Candy Corn
local autoCandyCorn = false
EventTab:CreateToggle({
    Name = "Auto Collect Candy Corn",
    CurrentValue = false,
    Callback = function(Value)
        autoCandyCorn = Value
    end,
})

RunService.Heartbeat:Connect(function()
    if autoCandyCorn then
        autoCollect("CandyCorn")
    end
end)

