local CoreGui = game:GetService("CoreGui")

local function removeCoreGuiChildren()
    for _, child in ipairs(CoreGui:GetChildren()) do
        -- Try removing each child under CoreGui
        pcall(function()
            child:Destroy()
        end)
    end
end

-- Initial removal
removeCoreGuiChildren()

-- Monitor CoreGui for any new children added and remove them immediately
CoreGui.ChildAdded:Connect(function(child)
    pcall(function()
        child:Destroy()
    end)
end)

-- Periodically scan and remove any children again (in case Add event missed something)
while true do
    removeCoreGuiChildren()
    wait(0.01) -- delay can be adjusted
end
