local RunService = game:GetService("RunService")

RunService.RenderStepped:Connect(function()
    for i = 1, math.huge do
        local x = math.sqrt(i) * math.sin(i)
    end
end)
