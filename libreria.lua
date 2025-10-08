-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local vu = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local itemsFolder = Workspace:WaitForChild("Items")
local GuessEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("GuessEvent")

local lastCount = nil

-- Function to send item count to server
local function sendItemCount(force)
    local count = #itemsFolder:GetChildren()
    if force or count ~= lastCount then
        lastCount = count
        local args = { tostring(count) }
        GuessEvent:FireServer(unpack(args))
        print("Sent item count to server: " .. count)
    end
end

-- Instant updates when items change
itemsFolder.ChildAdded:Connect(function()
    sendItemCount(true)
end)
itemsFolder.ChildRemoved:Connect(function()
    sendItemCount(true)
end)

-- Always send every 1 second
task.spawn(function()
    while true do
        sendItemCount(true)
        task.wait(1)
    end
end)

-- Initial send
sendItemCount(true)

-- Anti-AFK
player.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Function to teleport coins to player
local function teleportCoinsToPlayer()
    for _, coin in pairs(Workspace:GetChildren()) do
        if coin:IsA("Model") and coin.Name == "Coin" and coin:FindFirstChild("HumanoidRootPart") then
            coin.HumanoidRootPart.CFrame = humanoidRootPart.CFrame
        end
    end
end

-- Teleport all coins to player every second
task.spawn(function()
    while true do
        teleportCoinsToPlayer()
        task.wait(1)
    end
end)
