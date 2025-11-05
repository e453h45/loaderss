local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Tu Script De Halloween",
    LoadingTitle = "CaraleMoS",
    LoadingSubtitle = "By TuNombre",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "CaralemosConfig"
    }
})

local Tab = Window:CreateTab("Auto", 8952342453)

local autoCash = false
local cashLoopActive = false

Tab:CreateToggle({
    Name = "auto cashbutton v2.5 (más estable)",
    CurrentValue = false,
    Flag = "AutoCashButtonV25",
    Callback = function(enabled)
        autoCash = enabled
        cashLoopActive = enabled
        if autoCash then
            local player = game.Players.LocalPlayer
            local candiesFolder = workspace:WaitForChild("CashGemsButtons_Folder")
            local function getChar()
                local character = player.Character or player.CharacterAdded:Wait()
                local hrp = character:WaitForChild("HumanoidRootPart")
                local humanoid = character:FindFirstChildWhichIsA("Humanoid")
                return hrp, humanoid
            end
            -- Loop: Teleport, luego mata y repite al respawnear
            task.spawn(function()
                while cashLoopActive do
                    local hrp, humanoid = getChar()
                    -- Teleporta todos los botones al jugador (una vez por ciclo)
                    for i = 1, 500 do
                        local button = candiesFolder:FindFirstChild("CashGemsButton_" .. i)
                        if button and button:IsA("BasePart") then
                            button.CFrame = hrp.CFrame * CFrame.new(0, 3, 0)
                        end
                    end
                    -- Mata al jugador (pone vida a 0)
                    if humanoid then
                        humanoid.Health = 0
                    end
                    -- Espera respawn antes de repetir: 
                    repeat
                        hrp, humanoid = getChar()
                        task.wait(0.1)
                    until humanoid and humanoid.Health > 0
                end
            end)
        else
            cashLoopActive = false
        end
    end,
})

-- Ejemplo: el toggle de auto recolectar caralemos
local autoRecolectar = false
local recolectarConnection

Tab:CreateToggle({
    Name = "auto recolectar caralemos (no afecta al gameplay en nada)",
    CurrentValue = false,
    Flag = "AutoRecolectarCaralemos",
    Callback = function(enabled)
        autoRecolectar = enabled
        if autoRecolectar then
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            local candiesFolder = workspace:WaitForChild("HALLOWEEN"):WaitForChild("Candys")
            local runService = game:GetService("RunService")

            recolectarConnection = runService.RenderStepped:Connect(function()
                for _, candy in pairs(candiesFolder:GetChildren()) do
                    local touchPart = candy:FindFirstChild("Candy")
                    if touchPart and touchPart:IsA("BasePart") then
                        firetouchinterest(hrp, touchPart, 0)
                        firetouchinterest(hrp, touchPart, 1)
                    end
                end
            end)
        else
            if recolectarConnection then
                recolectarConnection:Disconnect()
                recolectarConnection = nil
            end
        end
    end,
})

Rayfield:LoadConfiguration()
