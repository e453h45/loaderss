--[[
    GAME CONTROL PANEL - OPTIMIZED VERSION
    
    IMPROVEMENTS:
    - Modular organization with clear sections
    - Optimized collection system to prevent lag
    - Separate Anti Bombs and Anti Explosions toggles
    - Reduced Heartbeat connections for better performance
    - Proper connection management to prevent memory leaks
    - Better variable scoping and naming conventions
]]

--// ============================================
--// SERVICES
--// ============================================
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

--// ============================================
--// REMOTES
--// ============================================
local RemotesRoot = RS:FindFirstChild("Remotes")
local ragdollRemote = RemotesRoot and RemotesRoot:FindFirstChild("Ragdoll")
local skillRemote = RemotesRoot and RemotesRoot:FindFirstChild("skillUse")
local resetRemote = RS:FindFirstChild("ResetBindLobby")

--// ============================================
--// RAYFIELD UI SETUP
--// ============================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Game Control Panel",
    LoadingTitle = "Loading UI",
    LoadingSubtitle = "Optimized Version",
    ConfigurationSaving = {
        Enabled = false,
    }
})

--// ============================================
--// UTILITY FUNCTIONS
--// ============================================

-- Get random point inside a part (XZ plane only)
local function getRandomXZPointInPart(part)
    if not part or not part.Size then 
        return part.CFrame 
    end
    local sx, sz = part.Size.X, part.Size.Z
    local rx = (math.random() - 0.5) * sx
    local rz = (math.random() - 0.5) * sz
    return part.CFrame * CFrame.new(rx, 0, rz)
end

-- Teleport object to player
local function teleportToPlayer(obj)
    local character = player.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    pcall(function()
        if obj:IsA("BasePart") then
            obj.CanCollide = false
            obj.Transparency = 1
            obj.CFrame = hrp.CFrame
        else
            local targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if targetPart then
                targetPart.CanCollide = false
                targetPart.Transparency = 1
                if obj.PrimaryPart then
                    obj:SetPrimaryPartCFrame(hrp.CFrame)
                else
                    targetPart.CFrame = hrp.CFrame
                end
            end
        end
    end)
end

--// ============================================
--// GENERAL TAB
--// ============================================
local GeneralTab = Window:CreateTab("General", 4483362458)

-- Auto Win Feature
local autoWin = false
local winConnection = nil

local function SetAutoWin(enable)
    autoWin = enable
    
    if autoWin then
        winConnection = RunService.Heartbeat:Connect(function()
            if not autoWin then return end
            
            local ceiling = WS:FindFirstChild("Ceiling")
            local character = player.Character
            
            if ceiling and character then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = getRandomXZPointInPart(ceiling)
                end
            end
            
            -- Fire NotThere remote
            local notThereRemote = RS:FindFirstChild("NotThere")
            if notThereRemote then
                pcall(function()
                    notThereRemote:FireServer(false)
                end)
            end
            
            task.wait(0.001) -- Small delay to prevent overwhelming the server
        end)
    else
        if winConnection then
            winConnection:Disconnect()
            winConnection = nil
        end
    end
end

GeneralTab:CreateToggle({
    Name = "Auto Win (te pueden grabar)",
    CurrentValue = false,
    Callback = SetAutoWin,
})

--// ============================================
--// COLLECTABLES SYSTEM
--// ============================================

-- Collectable items configuration
local collectableItems = {
    -- Items in Workspace.Bombs
    bombs = {
        {name = "MagicShield", toggle = false},
        {name = "Coin_event", toggle = false},
        {name = "Coin_silver", toggle = false},
        {name = "Coin_copper", toggle = false},
        {name = "Coin_gold", toggle = false},
        {name = "HeartPickup", toggle = false},
        {name = "FireShield", toggle = false},
        {name = "PizzaBox", toggle = false},
        {name = "ChargeSoda", toggle = false},
        {name = "Gem", toggle = false},
    },
    -- Items in Workspace root (Lobby)
    lobby = {
        {name = "Coin_copper", toggle = false},
        {name = "Coin_silver", toggle = false},
        {name = "Coin_golden", toggle = false},
        {name = "Coin_gold", toggle = false},
    }
}

-- Collect item from Workspace.Bombs
local function collectFromBombs(itemName)
    local bombsFolder = WS:FindFirstChild("Bombs")
    if not bombsFolder then return end
    
    local obj = bombsFolder:FindFirstChild(itemName)
    if obj then
        teleportToPlayer(obj)
    end
end

-- Collect item from Workspace root
local function collectFromWorkspace(itemName)
    local obj = WS:FindFirstChild(itemName)
    if obj then
        teleportToPlayer(obj)
    end
end

-- Create toggles for bomb items
for _, item in ipairs(collectableItems.bombs) do
    local itemName = item.name
    local displayName = itemName:gsub("_", " "):gsub("(%a)([%w_']*)", function(f, r) return f:upper()..r end)
    
    GeneralTab:CreateToggle({
        Name = "Auto Collect " .. displayName,
        CurrentValue = false,
        Callback = function(value)
            item.toggle = value
        end,
    })
end

-- Create toggle for lobby coins
local autoLobbyCoins = false
GeneralTab:CreateToggle({
    Name = "Auto Collect Lobby Coins",
    CurrentValue = false,
    Callback = function(value)
        autoLobbyCoins = value
    end,
})

-- Single Heartbeat connection for all collectables (OPTIMIZED)
local collectConnection = RunService.Heartbeat:Connect(function()
    -- Collect items from Bombs folder
    for _, item in ipairs(collectableItems.bombs) do
        if item.toggle then
            collectFromBombs(item.name)
        end
    end
    
    -- Collect lobby coins
    if autoLobbyCoins then
        for _, item in ipairs(collectableItems.lobby) do
            collectFromWorkspace(item.name)
        end
    end
end)

local FunTab = Window:CreateTab("Fun", 4483362458)

-- Randomize Ability Button
FunTab:CreateButton({
    Name = "Randomize Ability",
    Callback = function()
        if skillRemote then
            pcall(function()
                skillRemote:FireServer(66, 0, "skillScript")
            end)
        end
    end,
})

-- Auto Use Skill
local autoSkill = false
local autoSkillConnection = nil

local function SetAutoSkill(enable)
    autoSkill = enable
    
    if autoSkill then
        autoSkillConnection = task.spawn(function()
            while autoSkill do
                if skillRemote then
                    pcall(function()
                        skillRemote:FireServer(58, 300, "skillScript")
                    end)
                end
                task.wait(1) -- Wait 1 second between skill uses
            end
        end)
    else
        if autoSkillConnection then
            task.cancel(autoSkillConnection)
            autoSkillConnection = nil
        end
    end
end

FunTab:CreateToggle({
    Name = "Auto Use Skill",
    CurrentValue = false,
    Callback = SetAutoSkill,
})

-- Auto Spam ChargeFx
local autoChargeFx = false
local chargeFxConnection = nil

local function SetAutoChargeFx(enable)
    autoChargeFx = enable
    
    if autoChargeFx then
        chargeFxConnection = task.spawn(function()
            while autoChargeFx do
                local character = player.Character
                if character then
                    pcall(function()
                        local soundContainer = character:FindFirstChild("Sound")
                        if soundContainer then
                            local chargeFx = soundContainer:FindFirstChild("ChargeFx")
                            if chargeFx and chargeFx.FireServer then
                                chargeFx:FireServer()
                            end
                        end
                    end)
                end
                task.wait(0.2) -- Spam interval
            end
        end)
    else
        if chargeFxConnection then
            task.cancel(chargeFxConnection)
            chargeFxConnection = nil
        end
    end
end

FunTab:CreateToggle({
    Name = "Auto Spam ChargeFx",
    CurrentValue = false,
    Callback = SetAutoChargeFx,
})

-- Spam Reset
local spamReset = false
local spamResetConnection = nil

local function SetSpamReset(enable)
    spamReset = enable
    
    if spamReset then
        spamResetConnection = task.spawn(function()
            while spamReset do
                if resetRemote then
                    pcall(function()
                        resetRemote:FireServer()
                    end)
                end
                task.wait(0.1)
            end
        end)
    else
        if spamResetConnection then
            task.cancel(spamResetConnection)
            spamResetConnection = nil
        end
    end
end

FunTab:CreateToggle({
    Name = "Spam Reset (funny)",
    CurrentValue = false,
    Callback = SetSpamReset,
})
--// VENTAJAS TAB (ADVANTAGES)
local VentajasTab = Window:CreateTab("Ventajas", 4483362458)

--// ANTI BOMBS/EXPLOSIONS (modo hardblock frame a frame)
local antiHardBlock = false
local hardBlockConnection = nil

local FoldersToDestroy = {"Bombs", "Explosions", "Projectiles", "Traps"}
local ClassesToDestroy = {"Explosion", "RocketProjectile", "TrapPart", "Fireball"}
local NamesToDestroy = {"Bomb", "Mine", "Trap", "Missile", "Bazooka", "Grenade", "Projectile"}

local function SetAntiHardBlock(enable)
    antiHardBlock = enable

    if antiHardBlock then
        hardBlockConnection = RunService.Heartbeat:Connect(function()
            if not antiHardBlock then return end
            -- Carpetas peligrosas
            for _, folderName in ipairs(FoldersToDestroy) do
                local folder = workspace:FindFirstChild(folderName)
                if folder then
                    for _, obj in ipairs(folder:GetChildren()) do
                        pcall(function() obj:Destroy() end)
                    end
                end
            end
            -- Instancias peligrosas por clase/nombre
            for _, obj in ipairs(workspace:GetChildren()) do
                for _, c in ipairs(ClassesToDestroy) do
                    if obj.ClassName == c or obj:IsA(c) then
                        pcall(function() obj:Destroy() end)
                    end
                end
                for _, dangerous in ipairs(NamesToDestroy) do
                    if obj.Name:lower():find(dangerous:lower()) then
                        pcall(function() obj:Destroy() end)
                    end
                end
            end
        end)
        print("[Ventajas] Anti Bombs/Explosions HARDBLOCK ON")
    else
        if hardBlockConnection then
            hardBlockConnection:Disconnect()
            hardBlockConnection = nil
        end
        print("[Ventajas] Anti Bombs/Explosions HARDBLOCK OFF")
    end
end

VentajasTab:CreateToggle({
    Name = "Anti Bombs & Explosions (HARDBLOCK)",
    CurrentValue = false,
    Callback = SetAntiHardBlock,
})
--// ============================================
--// CLEANUP ON SCRIPT UNLOAD
--// ============================================
game:GetService("Players").PlayerRemoving:Connect(function(plr)
    if plr == player then
        -- Disconnect all connections to prevent memory leaks
        if winConnection then winConnection:Disconnect() end
        if collectConnection then collectConnection:Disconnect() end
        if eventConnection then eventConnection:Disconnect() end
        if bombsConnection then bombsConnection:Disconnect() end
        if bombsChildConnection then bombsChildConnection:Disconnect() end
        if explosionsConnection then explosionsConnection:Disconnect() end
        if explosionsChildConnection then explosionsChildConnection:Disconnect() end
        if workspaceExplosionConnection then workspaceExplosionConnection:Disconnect() end
        if ragdollConnection then ragdollConnection:Disconnect() end
    end
end)
local Tab = Window:CreateTab("Collect")

--// BADGE: Single function for all badges
local function collectAllBadges()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    local bgg = workspace:FindFirstChild("GBB")
    if bgg and bgg:FindFirstChild("TouchInterest") then
        firetouchinterest(hrp, bgg, 0)
        firetouchinterest(hrp, bgg, 1)
    end

    local lobby2 = workspace:FindFirstChild("lobby2")
    if lobby2 then
        local fresh = lobby2:FindFirstChild("FreshAirBadge")
        if fresh and fresh:FindFirstChild("TouchInterest") then
            firetouchinterest(hrp, fresh, 0)
            firetouchinterest(hrp, fresh, 1)
        end
        local view = lobby2:FindFirstChild("ViewBadge")
        if view and view:FindFirstChild("TouchInterest") then
            firetouchinterest(hrp, view, 0)
            firetouchinterest(hrp, view, 1)
        end
    end
end

--// AUTOFARM COLLECTORS (all ON by default)
local autoBanana, autoShield, autoPizza, autoHeart = false, false, false, false
local bananaConnection, shieldConnection, pizzaConnection, heartConnection

function startAutoBanana()
    if autoBanana or bananaConnection then return end
    autoBanana = true
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local bananaFolder = workspace:WaitForChild("bananas"):WaitForChild("bananas")
    local runService = game:GetService("RunService")
    bananaConnection = runService.RenderStepped:Connect(function()
        for _, banana in ipairs(bananaFolder:GetChildren()) do
            if banana:IsA("BasePart") and banana:FindFirstChild("TouchInterest") then
                firetouchinterest(hrp, banana, 0)
                firetouchinterest(hrp, banana, 1)
            end
        end
    end)
end
function stopAutoBanana()
    autoBanana = false
    if bananaConnection then
        bananaConnection:Disconnect()
        bananaConnection = nil
    end
end

function startAutoShield()
    if autoShield or shieldConnection then return end
    autoShield = true
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local shieldFolder = workspace:WaitForChild("Bombs"):WaitForChild("CrystalShield")
    local runService = game:GetService("RunService")
    shieldConnection = runService.RenderStepped:Connect(function()
        for _, shield in ipairs(shieldFolder:GetChildren()) do
            local hitbox = shield:FindFirstChild("Hitbox")
            if hitbox and hitbox:IsA("BasePart") and hitbox:FindFirstChild("TouchInterest") then
                firetouchinterest(hrp, hitbox, 0)
                firetouchinterest(hrp, hitbox, 1)
            end
        end
    end)
end
function stopAutoShield()
    autoShield = false
    if shieldConnection then
        shieldConnection:Disconnect()
        shieldConnection = nil
    end
end

function startAutoPizza()
    if autoPizza or pizzaConnection then return end
    autoPizza = true
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local pizzaPart = workspace:FindFirstChild("Bombs") and workspace.Bombs:FindFirstChild("Pizza")
    local runService = game:GetService("RunService")
    pizzaConnection = runService.RenderStepped:Connect(function()
        if pizzaPart and pizzaPart:IsA("BasePart") and pizzaPart:FindFirstChild("TouchInterest") then
            firetouchinterest(hrp, pizzaPart, 0)
            firetouchinterest(hrp, pizzaPart, 1)
        end
    end)
end
function stopAutoPizza()
    autoPizza = false
    if pizzaConnection then
        pizzaConnection:Disconnect()
        pizzaConnection = nil
    end
end

function startAutoHeart()
    if autoHeart or heartConnection then return end
    autoHeart = true
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local heartFolder = workspace:FindFirstChild("Bombs"):FindFirstChild("HeartPickup")
    local runService = game:GetService("RunService")
    heartConnection = runService.RenderStepped:Connect(function()
        for _, heart in ipairs(heartFolder:GetChildren()) do
            local hitbox = heart:FindFirstChild("Hitbox")
            if hitbox and hitbox:IsA("BasePart") and hitbox:FindFirstChild("TouchInterest") then
                firetouchinterest(hrp, hitbox, 0)
                firetouchinterest(hrp, hitbox, 1)
            end
        end
    end)
end
function stopAutoHeart()
    autoHeart = false
    if heartConnection then
        heartConnection:Disconnect()
        heartConnection = nil
    end
end

-- SINGLE BADGE BUTTON
Tab:CreateButton({ 
    Name = "auto conseguir 4 badges random",
    Callback = collectAllBadges 
})

-- AUTOFARM TOGGLES (all ON by default)
Tab:CreateToggle({
    Name = "Auto Collect Bananas",
    CurrentValue = true,
    Callback = function(enabled) if enabled then startAutoBanana() else stopAutoBanana() end end,
})
Tab:CreateToggle({
    Name = "Auto Collect Crystal Shields",
    CurrentValue = true,
    Callback = function(enabled) if enabled then startAutoShield() else stopAutoShield() end end,
})
Tab:CreateToggle({
    Name = "Auto Collect Pizza",
    CurrentValue = true,
    Callback = function(enabled) if enabled then startAutoPizza() else stopAutoPizza() end end,
})
Tab:CreateToggle({
    Name = "Auto Collect HeartPickup",
    CurrentValue = true,
    Callback = function(enabled) if enabled then startAutoHeart() else stopAutoHeart() end end,
})

-- Immediately enable autofarms
task.defer(startAutoBanana)
task.defer(startAutoShield)
task.defer(startAutoPizza)
task.defer(startAutoHeart)
-- Immediately enable everything when GUI appears
task.defer(getBggBadge)
task.defer(getFreshAirBadge)
task.defer(getViewBadge)
task.defer(startAutoBanana)
--// ============================================
--// END OF SCRIPT
--// ============================================
print("✓ Game Control Panel loaded successfully (Optimized Version)")
