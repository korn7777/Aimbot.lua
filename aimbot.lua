
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "07",
    Icon = 107244319001465,
    LoadingTitle = "รอหน่อยอร่อยเเน่วัยรุ่นeiei",
    LoadingSubtitle = "by มาร์คปากเหม็น",
    ConfigurationSaving = { 
        Enabled = true,
        FolderName = "MarkPakMhenHub", 
        FileName = "AimbotESPConfig" 
    },
    KeySystem = false,
})

local MainTab = Window:CreateTab("Aimbot", "crosshair")
local ESPTab = Window:CreateTab("ESP", "flame")
local MiscTab = Window:CreateTab("Misc", "orbit")

local AimbotEnabled = false
local TeamCheckEnabled = false
local WallCheckEnabled = false

local FOVEnabled = false
local FOVRadius = 120
local FOVThickness = 1
local FOVColor = Color3.fromRGB(255, 255, 255)
local FOVRainbow = false

local ESPSettings = {
    Enabled = false,
    Name = false,
    Distance = false,
    HealthBar = false,
    HealthText = false,
    Box = false,
    BoxType = "Corner",
    BoxThickness = 1,
    BoxRainbow = false,
    Highlight = false,
    FillColor = Color3.fromRGB(255, 0, 0),
    FillRainbow = false,
    OutlineColor = Color3.fromRGB(255, 255, 255),
    OutlineRainbow = false,
    FillTransparency = 0.5,
    Tracer = false,
    TracerPosition = "Center",
    TracerThickness = 1,
    TracerRainbow = false,
    Skeleton = false,
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    SkeletonRainbow = false,
    SkeletonThickness = 1,
    HeadDot = false,
    HeadDotColor = Color3.fromRGB(255, 255, 255),
    HeadDotRainbow = false,
    TeamCheck = false,
    AliveCheck = true,
    MaxDistance = 1000,
}

local ESPGuiParts = {}
local Highlights = {}

local function GetRainbowColor()
    local hue = tick() % 5 / 5
    return Color3.fromHSV(hue, 1, 1)
end

local MainESPGui = Instance.new("ScreenGui")
MainESPGui.Name = "iOS_Supported_ESP_Gui"
MainESPGui.IgnoreGuiInset = true
MainESPGui.ResetOnSpawn = false
pcall(function() MainESPGui.Parent = CoreGui end)
if not MainESPGui.Parent then MainESPGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local FOVFrame = Instance.new("Frame")
FOVFrame.Name = "CircleFrame"
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Visible = false
FOVFrame.Parent = MainESPGui

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 1
FOVStroke.Color = Color3.fromRGB(255, 255, 255)
FOVStroke.Parent = FOVFrame

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVFrame

local function IsVisible(part, character)
    if not WallCheckEnabled then return true end
    local localChar = LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("Head") then return true end
    
    local origin = localChar.Head.Position
    local direction = (part.Position - origin)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {localChar, character}
    raycastParams.IgnoreWater = true
    
    local result = workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

local function CreatePlayerESPGui(player)
    if player == LocalPlayer then return end
    
    local boxFrame = Instance.new("Frame")
    boxFrame.BackgroundTransparency = 1
    boxFrame.Visible = false
    boxFrame.Parent = MainESPGui
    
    local boxStroke = Instance.new("UIStroke")
    boxStroke.Thickness = 1
    boxStroke.Color = Color3.fromRGB(255, 255, 255)
    boxStroke.Parent = boxFrame
    
    local tracerLine = Instance.new("Frame")
    tracerLine.AnchorPoint = Vector2.new(0.5, 0.5)
    tracerLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tracerLine.BorderSizePixel = 0
    tracerLine.Visible = false
    tracerLine.Parent = MainESPGui
    
    local healthBarBack = Instance.new("Frame")
    healthBarBack.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    healthBarBack.BorderSizePixel = 0
    healthBarBack.Visible = false
    healthBarBack.Parent = MainESPGui
    
    local healthBarFill = Instance.new("Frame")
    healthBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBarFill.BorderSizePixel = 0
    healthBarFill.Size = UDim2.fromScale(1, 1)
    healthBarFill.Parent = healthBarBack
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextStrokeTransparency = 0.2
    infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoLabel.Font = Enum.Font.GothamBold
    infoLabel.TextSize = 14
    infoLabel.Visible = false
    infoLabel.Parent = MainESPGui
    
    local headDotGui = Instance.new("BillboardGui")
    headDotGui.Size = UDim2.fromOffset(8, 8)
    headDotGui.AlwaysOnTop = true
    headDotGui.Enabled = false
    
    local headDotFrame = Instance.new("Frame")
    headDotFrame.Name = "DotFrame"
    headDotFrame.Size = UDim2.fromScale(1, 1)
    headDotFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    headDotFrame.BorderSizePixel = 0
    headDotFrame.Parent = headDotGui
    
    local headCorner = Instance.new("UICorner")
    headCorner.CornerRadius = UDim.new(1, 0)
    headCorner.Parent = headDotFrame

    local skeletonFrames = {}
    for i = 1, 5 do
        local skelLine = Instance.new("Frame")
        skelLine.AnchorPoint = Vector2.new(0.5, 0.5)
        skelLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        skelLine.BorderSizePixel = 0
        skelLine.Visible = false
        skelLine.Parent = MainESPGui
        table.insert(skeletonFrames, skelLine)
    end

    local highlight = Instance.new("Highlight")
    Highlights[player] = highlight

    ESPGuiParts[player] = {
        Box = boxFrame,
        BoxStroke = boxStroke,
        Tracer = tracerLine,
        HealthBack = healthBarBack,
        HealthFill = healthBarFill,
        Text = infoLabel,
        HeadDotGui = headDotGui,
        HeadDotFrame = headDotFrame,
        Skeleton = skeletonFrames
    }
end

local function RemovePlayerESPGui(player)
    if ESPGuiParts[player] then
        if ESPGuiParts[player].Skeleton then
            for _, line in ipairs(ESPGuiParts[player].Skeleton) do
                pcall(function() line:Destroy() end)
            end
        end
        for _, guiObj in pairs(ESPGuiParts[player]) do
            if type(guiObj) ~= "table" then
                pcall(function() guiObj:Destroy() end)
            end
        end
        ESPGuiParts[player] = nil
    end
    if Highlights[player] then Highlights[player]:Destroy(); Highlights[player] = nil end
end

local function DrawUILine(frame, p1, p2, thickness, color)
    local distance = (p2 - p1).Magnitude
    local center = (p1 + p2) / 2
    local angle = math.deg(math.atan2(p2.Y - p1.Y, p2.X - p1.X))

    frame.Size = UDim2.fromOffset(distance, thickness)
    frame.Position = UDim2.fromOffset(center.X, center.Y)
    frame.Rotation = angle
    frame.BackgroundColor3 = color
    frame.Visible = true
end

RunService.RenderStepped:Connect(function()
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    if FOVEnabled then
        local diameter = FOVRadius * 2
        FOVFrame.Size = UDim2.fromOffset(diameter, diameter)
        FOVFrame.Position = UDim2.fromOffset(ScreenCenter.X, ScreenCenter.Y)
        FOVStroke.Thickness = FOVThickness
        FOVStroke.Color = FOVRainbow and GetRainbowColor() or FOVColor
        FOVFrame.Visible = true
    else
        FOVFrame.Visible = false
    end

if AimbotEnabled then
    local targetPart = nil
    local shortestDist = FOVRadius
    
    local viewport = Camera.ViewportSize
    local ScreenCenter = Vector2.new(viewport.X / 2, viewport.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local passTeam = not TeamCheckEnabled or player.Team ~= LocalPlayer.Team
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local headPart = player.Character:FindFirstChild("Head")

            if passTeam and humanoid and humanoid.Health > 0 and headPart then
                local pos, onScreen = Camera:WorldToScreenPoint(headPart.Position)
                
                if onScreen then
                    local screenPos = Vector2.new(pos.X, pos.Y)
                    local dist = (screenPos - ScreenCenter).Magnitude
                    
                    if dist < shortestDist then
                        if IsVisible(headPart, player.Character) then
                            shortestDist = dist
                            targetPart = headPart
                        end
                    end
                end
            end
        end
    end

    if targetPart then
    
        local targetCharacter = targetPart.Parent
        local rootPart = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
        local velocity = rootPart and rootPart.Velocity or Vector3.new(0, 0, 0)
        
        local predictedPosition = targetPart.Position + (velocity * 0.05)
        local camPos = Camera.CFrame.Position
        Camera.CFrame = CFrame.lookAt(camPos, predictedPosition)
    end
end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not ESPGuiParts[player] then CreatePlayerESPGui(player) end
            local esp = ESPGuiParts[player]
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local head = char and char:FindFirstChild("Head")
            
            if ESPSettings.Enabled and char and root and hum and esp then
                local passTeam = not ESPSettings.TeamCheck or player.Team ~= LocalPlayer.Team
                local passAlive = not ESPSettings.AliveCheck or hum.Health > 0
                local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                local dist = (root.Position - Camera.CFrame.Position).Magnitude

                if passTeam and passAlive and dist <= ESPSettings.MaxDistance and onScreen then
                    local cf = root.CFrame
                    local topPos = Camera:WorldToViewportPoint((cf + Vector3.new(0, 3, 0)).Position)
                    local bottomPos = Camera:WorldToViewportPoint((cf - Vector3.new(0, 3, 0)).Position)
                    
                    local screenSize = math.abs(bottomPos.Y - topPos.Y)
                    local boxWidth = screenSize * 0.55
                    local boxPos = Vector2.new(topPos.X - boxWidth / 2, topPos.Y)

                    if ESPSettings.Box then
                        esp.Box.Size = UDim2.fromOffset(boxWidth, screenSize)
                        esp.Box.Position = UDim2.fromOffset(boxPos.X, boxPos.Y)
                        esp.BoxStroke.Thickness = ESPSettings.BoxThickness
                        esp.BoxStroke.Color = ESPSettings.BoxRainbow and GetRainbowColor() or Color3.fromRGB(255, 255, 255)
                        esp.Box.Visible = true
                    else
                        esp.Box.Visible = false
                    end

                    if ESPSettings.Name or ESPSettings.Distance or ESPSettings.HealthText then
                        local textStr = ""
                        if ESPSettings.Name then textStr = textStr .. player.Name .. " " end
                        if ESPSettings.Distance then textStr = textStr .. "[" .. math.floor(dist) .. "m] " end
                        if ESPSettings.HealthText then textStr = textStr .. "-" .. math.floor(hum.Health) .. "HP" end
                        esp.Text.Text = textStr
                        esp.Text.Size = UDim2.fromOffset(200, 20)
                        esp.Text.Position = UDim2.fromOffset(boxPos.X + (boxWidth / 2) - 100, boxPos.Y - 22)
                        esp.Text.Visible = true
                    else
                        esp.Text.Visible = false
                    end

                    if ESPSettings.HealthBar then
                        local hpPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        esp.HealthBack.Size = UDim2.fromOffset(4, screenSize)
                        esp.HealthBack.Position = UDim2.fromOffset(boxPos.X - 7, boxPos.Y)
                        esp.HealthFill.Size = UDim2.fromScale(1, hpPct)
                        esp.HealthFill.Position = UDim2.fromScale(0, 1 - hpPct)
                        esp.HealthBack.Visible = true
                    else
                        esp.HealthBack.Visible = false
                    end

                    if ESPSettings.Tracer then
                        local originPoint
                        if ESPSettings.TracerPosition == "Top" then
                            originPoint = Vector2.new(Camera.ViewportSize.X / 2, 0)
                        elseif ESPSettings.TracerPosition == "Bottom" then
                            originPoint = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        elseif ESPSettings.TracerPosition == "Mouse" then
                            originPoint = UserInputService:GetMouseLocation()
                        else
                            originPoint = ScreenCenter
                        end
                        local targetPoint = Vector2.new(rootPos.X, rootPos.Y)
                        local tracerColor = ESPSettings.TracerRainbow and GetRainbowColor() or Color3.fromRGB(255, 255, 255)
                        DrawUILine(esp.Tracer, originPoint, targetPoint, ESPSettings.TracerThickness, tracerColor)
                    else
                        esp.Tracer.Visible = false
                    end

                    if ESPSettings.HeadDot and head then
                        esp.HeadDotGui.Adornee = head
                        esp.HeadDotGui.Parent = head
                        esp.HeadDotFrame.BackgroundColor3 = ESPSettings.HeadDotRainbow and GetRainbowColor() or ESPSettings.HeadDotColor
                        esp.HeadDotGui.Enabled = true
                    else
                        esp.HeadDotGui.Enabled = false
                    end

                    if ESPSettings.Skeleton and head and char:FindFirstChild("UpperTorso") then
                        local torsoPart = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                        local lHand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
                        local rHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
                        local lFoot = char:FindFirstChild("LeftFoot") or char:FindFirstChild("Left Leg")
                        local rFoot = char:FindFirstChild("RightFoot") or char:FindFirstChild("Right Leg")

                        local headP = Camera:WorldToViewportPoint(head.Position)
                        local torsoP = torsoPart and Camera:WorldToViewportPoint(torsoPart.Position)
                        local lHandP = lHand and Camera:WorldToViewportPoint(lHand.Position)
                        local rHandP = rHand and Camera:WorldToViewportPoint(rHand.Position)
                        local lFootP = lFoot and Camera:WorldToViewportPoint(lFoot.Position)
                        local rFootP = rFoot and Camera:WorldToViewportPoint(rFoot.Position)

                        local pairsList = {
                            {headP, torsoP, 1},
                            {torsoP, lHandP, 2},
                            {torsoP, rHandP, 3},
                            {torsoP, lFootP, 4},
                            {torsoP, rFootP, 5}
                        }

                        local skelColor = ESPSettings.SkeletonRainbow and GetRainbowColor() or ESPSettings.SkeletonColor
                        for _, pData in ipairs(pairsList) do
                            local p1, p2, index = pData[1], pData[2], pData[3]
                            if p1 and p2 and esp.Skeleton[index] then
                                DrawUILine(esp.Skeleton[index], Vector2.new(p1.X, p1.Y), Vector2.new(p2.X, p2.Y), ESPSettings.SkeletonThickness, skelColor)
                            elseif esp.Skeleton[index] then
                                esp.Skeleton[index].Visible = false
                            end
                        end
                    else
                        for _, line in ipairs(esp.Skeleton) do line.Visible = false end
                    end

                    if Highlights[player] then
                        Highlights[player].Parent = ESPSettings.Highlight and char or nil
                        Highlights[player].Enabled = ESPSettings.Highlight
                        Highlights[player].FillColor = ESPSettings.FillRainbow and GetRainbowColor() or ESPSettings.FillColor
                        Highlights[player].OutlineColor = ESPSettings.OutlineRainbow and GetRainbowColor() or ESPSettings.OutlineColor
                        Highlights[player].FillTransparency = ESPSettings.FillTransparency
                        Highlights[player].OutlineTransparency = 0
                    end
                else
                    esp.Box.Visible = false
                    esp.Text.Visible = false
                    esp.HealthBack.Visible = false
                    esp.Tracer.Visible = false
                    esp.HeadDotGui.Enabled = false
                    for _, line in ipairs(esp.Skeleton) do line.Visible = false end
                    if Highlights[player] then Highlights[player].Enabled = false end
                end
            elseif esp then
                esp.Box.Visible = false
                esp.Text.Visible = false
                esp.HealthBack.Visible = false
                esp.Tracer.Visible = false
                esp.HeadDotGui.Enabled = false
                for _, line in ipairs(esp.Skeleton) do line.Visible = false end
                if Highlights[player] then Highlights[player].Enabled = false end
            end
        end
    end
end)

Players.PlayerAdded:Connect(CreatePlayerESPGui)
Players.PlayerRemoving:Connect(RemovePlayerESPGui)

-- UI Setup (Rayfield)
MainTab:CreateSection("ตั้งค่าการล็อค")
MainTab:CreateToggle({ Name = "Aimbot", CurrentValue = false, Flag = "AimbotToggle", Callback = function(v) AimbotEnabled = v end })
MainTab:CreateToggle({ Name = "เช็คทีม", CurrentValue = false, Flag = "TeamCheckToggle", Callback = function(v) TeamCheckEnabled = v end })
MainTab:CreateToggle({ Name = "ไม่ล็อคทะลุกำแพง", CurrentValue = false, Flag = "WallCheckToggle", Callback = function(v) WallCheckEnabled = v end })

MainTab:CreateSection("ตั้งค่าวงล็อค FOV")
MainTab:CreateToggle({ Name = "วงกลม FOV", CurrentValue = false, Flag = "FOVToggle", Callback = function(v) FOVEnabled = v end })
MainTab:CreateToggle({ Name = "วงกลม FOV Rainbow", CurrentValue = false, Flag = "FOVRainbowToggle", Callback = function(v) FOVRainbow = v end })
MainTab:CreateSlider({ Name = "ขนาดรัศมี FOV", Range = {20, 1299}, Increment = 1, CurrentValue = 120, Flag = "FOVSlider", Callback = function(v) FOVRadius = v end })
MainTab:CreateSlider({ Name = "ความหนาวงกลม", Range = {1, 5}, Increment = 1, CurrentValue = 1, Flag = "FOVThicknessSlider", Callback = function(v) FOVThickness = v end })
MainTab:CreateColorPicker({ Name = "สีของวงกลม FOV", Color = Color3.fromRGB(255, 255, 255), Flag = "FOVColorPicker", Callback = function(v) FOVColor = v end })

ESPTab:CreateSection("ESP")
ESPTab:CreateToggle({ Name = "เปิด ปิด ESP ทั้งหมด", CurrentValue = false, Flag = "ESPEnabledToggle", Callback = function(v) ESPSettings.Enabled = v end })

ESPTab:CreateSection("เมนู EPSต่างๆ")
ESPTab:CreateToggle({ Name = "ชื่อผู้เล่น", CurrentValue = false, Flag = "ESPNameToggle", Callback = function(v) ESPSettings.Name = v end })
ESPTab:CreateToggle({ Name = "ระยะห่าง", CurrentValue = false, Flag = "ESPDistanceToggle", Callback = function(v) ESPSettings.Distance = v end })
ESPTab:CreateToggle({ Name = "แถบเลือด", CurrentValue = false, Flag = "ESPHealthBarToggle", Callback = function(v) ESPSettings.HealthBar = v end })
ESPTab:CreateToggle({ Name = "ตัวเลขHP", CurrentValue = false, Flag = "ESPHealthTextToggle", Callback = function(v) ESPSettings.HealthText = v end })
ESPTab:CreateToggle({ Name = "จุดตรงหัว", CurrentValue = false, Flag = "ESPHeadDotToggle", Callback = function(v) ESPSettings.HeadDot = v end })
ESPTab:CreateToggle({ Name = "จุดตรงหัว Rainbow", CurrentValue = false, Flag = "ESPHeadDotRainbowToggle", Callback = function(v) ESPSettings.HeadDotRainbow = v end })
ESPTab:CreateColorPicker({ Name = "สีจุดตรงหัว", Color = Color3.fromRGB(255, 255, 255), Flag = "ESPHeadDotColorPick", Callback = function(c) ESPSettings.HeadDotColor = c end })

local CustomInfoParts = {}
local CustomInfoEnabled = false
local CustomInfoSize = 13
local CustomInfoColor = Color3.fromRGB(255, 255, 255)

local function UpdateCustomInfos()
    local activePlayers = {}
    
    if ESPSettings and ESPSettings.Enabled and CustomInfoEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local passTeam = not ESPSettings.TeamCheck or player.Team ~= LocalPlayer.Team
                local char = player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local head = char and char:FindFirstChild("Head")
                local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                
                if passTeam and char and head and hum and hum.Health > 0 then
                    activePlayers[player] = true
                    
                    local gui = CustomInfoParts[player]
                    if not gui or gui.Adornee ~= head then
                        if gui then gui:Destroy() end
                        
                        gui = Instance.new("BillboardGui")
                        gui.Name = "CustomPlayerInfo"
                        gui.Adornee = head
                        gui.Size = UDim2.fromOffset(200, 60)
                        gui.StudsOffset = Vector3.new(0, 2.5, 0)
                        gui.AlwaysOnTop = true
                        gui.Parent = head
                        
                        local label = Instance.new("TextLabel")
                        label.Name = "InfoLabel"
                        label.Size = UDim2.fromScale(1, 1)
                        label.BackgroundTransparency = 1
                        label.TextStrokeTransparency = 0.2
                        label.Font = Enum.Font.GothamBold
                        label.Parent = gui
                        
                        CustomInfoParts[player] = gui
                    end
                    
                    local label = gui:FindFirstChild("InfoLabel")
                    if label then
                        label.TextSize = CustomInfoSize
                        label.TextColor3 = CustomInfoColor
                        
                        local myChar = LocalPlayer.Character
                        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                        local distance = 0
                        if myRoot and rootPart then
                            distance = (myRoot.Position - rootPart.Position).Magnitude
                        end
                        
                        label.Text = string.format(
                            "%s\nHP%d|M%d",
                            player.DisplayName,
                            math.floor(hum.Health),
                            math.floor(distance)
                        )
                    end
                    gui.Enabled = true
                end
            end
        end
    end
    
    for player, gui in pairs(CustomInfoParts) do
        if not activePlayers[player] or not player:IsDescendantOf(Players) then
            if gui then gui:Destroy() end
            CustomInfoParts[player] = nil
        end
    end
end

RunService.RenderStepped:Connect(function()
    UpdateCustomInfos()
end)

ESPTab:CreateSection("แสดงชื่อค่าHPเมตร[เเก้บางเครื่องใช้ข้างบนไม่ได้]")

ESPTab:CreateToggle({ 
    Name = "แสดง ชื่อค่าhpเมตร", 
    CurrentValue = false, 
    Flag = "HPK1",
    Callback = function(v) 
        CustomInfoEnabled = v 
    end 
})

ESPTab:CreateSlider({
    Name = "ขนาดแสดง ชื่อค่าhpเมตร",
    Range = {10, 24},
    Increment = 1,
    CurrentValue = 13,
    Flag = "HPK2",
    Callback = function(v)
        CustomInfoSize = v
    end,
})

ESPTab:CreateColorPicker({
    Name = "สีแสดง ชื่อค่าhpเมตร",
    Color = Color3.fromRGB(255, 255, 255),
    Flag = "HPK3",
    Callback = function(c)
        CustomInfoColor = c
    end,
})

ESPTab:CreateSection("ตั้งค่ากรอบ")
ESPTab:CreateToggle({ Name = "กรอบรอบตัวผู้เล่น", CurrentValue = false, Flag = "ESPBoxToggle", Callback = function(v) ESPSettings.Box = v end })
ESPTab:CreateToggle({ Name = "กรอบ Rainbow", CurrentValue = false, Flag = "ESPBoxRainbowToggle", Callback = function(v) ESPSettings.BoxRainbow = v end })
ESPTab:CreateDropdown({
    Name = "รูปแบบกล่อง",
    Options = {"Corner", "Full"},
    CurrentOption = "Corner",
    Flag = "ESPBoxTypeDropdown",
    Callback = function(Option)
        ESPSettings.BoxType = type(Option) == "table" and Option[1] or Option
    end,
})
ESPTab:CreateSlider({ Name = "ความหนากรอบ", Range = {1, 5}, Increment = 1, Flag = "ESPBoxThicknessSlider", CurrentValue = 1, Callback = function(v) ESPSettings.BoxThickness = v end })

ESPTab:CreateSection("ตั้งค่าเส้นลาก")
ESPTab:CreateToggle({ Name = "เส้นลาก", CurrentValue = false, Flag = "ESPTracerToggle", Callback = function(v) ESPSettings.Tracer = v end })
ESPTab:CreateToggle({ Name = "ส้นลาก Rainbow", CurrentValue = false, Flag = "ESPTracerRainbowToggle", Callback = function(v) ESPSettings.TracerRainbow = v end })
ESPTab:CreateDropdown({
    Name = "ตำแหน่งต้นทางเส้นลาก",
    Options = {"Top", "Center", "Bottom", "Mouse"},
    CurrentOption = "Center",
    Flag = "ESPTracerPosDropdown",
    Callback = function(Option)
        ESPSettings.TracerPosition = type(Option) == "table" and Option[1] or Option
    end,
})
ESPTab:CreateSlider({ Name = "ความหนาเส้นลาก", Range = {1, 5}, Increment = 1, CurrentValue = 1, Flag = "ESPTracerThicknessSlider", Callback = function(v) ESPSettings.TracerThickness = v end })

ESPTab:CreateSection("ตั้งค่าโครงกระดูก")
ESPTab:CreateToggle({ Name = "โครงกระดูก", CurrentValue = false, Flag = "ESPSkeletonToggle", Callback = function(v) ESPSettings.Skeleton = v end })
ESPTab:CreateToggle({ Name = "โครงกระดูก Rainbow", CurrentValue = false, Flag = "ESPSkeletonRainbowToggle", Callback = function(v) ESPSettings.SkeletonRainbow = v end })
ESPTab:CreateSlider({ Name = "ความหนาโครงกระดูก", Range = {1, 5}, Increment = 1, Flag = "ESPSkeleton11", CurrentValue = 1,  Callback = function(v) ESPSettings.SkeletonThickness = v end })
ESPTab:CreateColorPicker({ Name = "สีโครงกระดูก", Color = Color3.fromRGB(255, 255, 255), Flag = "ESPSkeleton22", Callback = function(v) ESPSettings.SkeletonColor = v end })

ESPTab:CreateSection("ตั้งค่าเรืองแสง")
ESPTab:CreateToggle({ Name = "เรืองแสงตัวละคร", CurrentValue = false, Flag = "ESPHighlightToggle", Callback = function(v) ESPSettings.Highlight = v end })
ESPTab:CreateToggle({ Name = "เรืองแสงตัวละครด้านใน Rainbow", CurrentValue = false, Flag = "ESPHighlightFillRainbow", Callback = function(v) ESPSettings.FillRainbow = v end })
ESPTab:CreateColorPicker({ Name = "สีเรืองแสงด้านใน", Color = Color3.fromRGB(255, 0, 0), Flag = "ESPFillColorPicker", Callback = function(v) ESPSettings.FillColor = v end })
ESPTab:CreateToggle({ Name = "เรืองแสงขอบตัวละคร Rainbow", CurrentValue = false, Flag = "ESPHighlightOutlineRainbow", Callback = function(v) ESPSettings.OutlineRainbow = v end })
ESPTab:CreateColorPicker({ Name = "สีเส้นขอบเรืองแสง", Color = Color3.fromRGB(255, 255, 255), Flag = "ESPOutlineColorPicker", Callback = function(v) ESPSettings.OutlineColor = v end })
ESPTab:CreateSlider({ Name = "ความโปร่งแสงเรืองแสง", Range = {0, 1}, Increment = 0.1, CurrentValue = 0.5, Flag = "ESPFillTransSlider", Callback = function(v) ESPSettings.FillTransparency = v end })

local HitboxEnabled = false
local HitboxParts = {}
local HitboxSizeMultiplier = 1.2
local HitboxColor = Color3.fromRGB(255, 255, 0)
local HitboxRainbow = false

local function UpdateHitboxes()
    local activePlayers = {}
    
    if HitboxEnabled and ESPSettings.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local passTeam = not ESPSettings.TeamCheck or player.Team ~= LocalPlayer.Team
                local char = player.Character
                
                if passTeam and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
                    activePlayers[player] = true
                    local rootPart = char.HumanoidRootPart
                    
                    local box = HitboxParts[player]
                    if not box or not box.Parent then
                        box = Instance.new("Part")
                        box.Name = "PlayerHitbox"
                        box.Anchored = true
                        box.CanCollide = false
                        box.Transparency = 0.4 
                        box.CastShadow = false 
                        box.Material = Enum.Material.Neon 
                        box.Parent = workspace
                        HitboxParts[player] = box
                    end
                    
                    local baseSize = Vector3.new(2 * HitboxSizeMultiplier, 5 * HitboxSizeMultiplier, 2 * HitboxSizeMultiplier)
                    box.Size = baseSize
                    box.Color = HitboxRainbow and GetRainbowColor() or HitboxColor
                    box.CFrame = rootPart.CFrame * CFrame.new(0, -0.5, 0)
                end
            end
        end
    end

    for player, box in pairs(HitboxParts) do
        if not activePlayers[player] or not player:IsDescendantOf(Players) then
            if box then box:Destroy() end
            HitboxParts[player] = nil
        end
    end
end

RunService.RenderStepped:Connect(function()
    UpdateHitboxes()
end)

ESPTab:CreateToggle({
   Name = "กล่องนํ้าเเข็ง",
   CurrentValue = false,
   Flag = "HitboxToggle",
   Callback = function(Value)
      HitboxEnabled = Value
      if not Value then
         for _, box in pairs(HitboxParts) do
            if box then box:Destroy() end
         end
         HitboxParts = {}
      end
   end,
})

ESPTab:CreateToggle({
   Name = "กล่องน้ำแข็ง Rainbow",
   CurrentValue = false,
   Flag = "HitboxRainbowToggle",
   Callback = function(Value)
      HitboxRainbow = Value
   end,
})

ESPTab:CreateSlider({
   Name = "ขนาดกล่องนํ้าเเข็ง",
   Range = {1, 3}, 
   Increment = 0.1,
   CurrentValue = 1.2,
   Flag = "HitboxSizeSlider",
   Callback = function(Value)
      HitboxSizeMultiplier = Value
   end,
})

ESPTab:CreateColorPicker({
   Name = "สีกล่องนํ้าเเข็ง",
   Color = Color3.fromRGB(255, 255, 0),
   Flag = "HitboxColorPicker",
   Callback = function(Value)
      HitboxColor = Value
      for _, box in pairs(HitboxParts) do
         if box and not HitboxRainbow then box.Color = Value end
      end
   end,
})

ESPTab:CreateSection("ตัวกรอง")
ESPTab:CreateToggle({ Name = "ไม่แสดงทีมเดียวกัน", CurrentValue = false, Flag = "ESPTeamCheckToggle", Callback = function(v) ESPSettings.TeamCheck = v end })
ESPTab:CreateToggle({ Name = "แสดงเฉพาะคนมีชีวิต", CurrentValue = true, Flag = "ESPAliveCheckToggle", Callback = function(v) ESPSettings.AliveCheck = v end })
ESPTab:CreateSlider({ Name = "จำกัดระยะทาง", Range = {100, 5000}, Increment = 50, CurrentValue = 1000, Flag = "ESPMaxDistSlider", Callback = function(v) ESPSettings.MaxDistance = v end })

MiscTab:CreateSection("FPS")

local SmoothFPSBoostEnabled = false
local ConnectionDescendant = nil

local function ApplySmoothToPart(obj)
    if obj:IsA("BasePart") then
        local character = LocalPlayer.Character
        if not (character and obj:IsDescendantOf(character)) then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
            obj.CastShadow = false
        end
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        local character = LocalPlayer.Character
        if not (character and obj:IsDescendantOf(character)) then
            obj.Transparency = 1
        end
    end
end

local function ApplySmoothMode(state)
    if state then
        for _, obj in ipairs(workspace:GetDescendants()) do
            ApplySmoothToPart(obj)
        end
        
        if not ConnectionDescendant then
            ConnectionDescendant = workspace.DescendantAdded:Connect(function(obj)
                if SmoothFPSBoostEnabled then
                    task.wait()
                    ApplySmoothToPart(obj)
                end
            end)
        end
    else
        if ConnectionDescendant then
            ConnectionDescendant:Disconnect()
            ConnectionDescendant = nil
        end
    end
end

MiscTab:CreateToggle({
   Name = "ภาพดินนํ้ามัน",
   CurrentValue = false,
   Flag = "SmoothModeToggle",
   Callback = function(Value)
      SmoothFPSBoostEnabled = Value
      ApplySmoothMode(Value)
   end,
})

MiscTab:CreateToggle({
   Name = "แสดงค่า FPS Ping",
   CurrentValue = false,
   Flag = "FPS_Ping_Toggle",
   Callback = function(Value)
      local existingGui = game.CoreGui:FindFirstChild("FPS_Ping_Display")
      
      if Value then
         if not existingGui then
            local ScreenGui = Instance.new("ScreenGui")
            ScreenGui.Name = "FPS_Ping_Display"
            ScreenGui.Parent = game.CoreGui
            
            local DragFrame = Instance.new("Frame")
            DragFrame.Name = "DragFrame"
            DragFrame.Parent = ScreenGui
            DragFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            DragFrame.BackgroundTransparency = 0.4
            DragFrame.Position = UDim2.new(0, 20, 0, 100)
            DragFrame.Size = UDim2.new(0, 130, 0, 26)
            DragFrame.Active = true
            DragFrame.Draggable = true
            
            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(0, 6)
            UICorner.Parent = DragFrame

            local UIStroke = Instance.new("UIStroke")
            UIStroke.Color = Color3.fromRGB(0, 120, 255)
            UIStroke.Thickness = 1.5
            UIStroke.Parent = DragFrame
            
            local TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "InfoText"
            TextLabel.Parent = DragFrame
            TextLabel.BackgroundTransparency = 1
            TextLabel.Size = UDim2.new(1, 0, 1, 0)
            TextLabel.Font = Enum.Font.GothamBold
            TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.TextSize = 11
            TextLabel.Text = "FPS: 0 | Ping: 0 ms"

            task.spawn(function()
               local RunService = game:GetService("RunService")
               local Stats = game:GetService("Stats")
               local lastTick = tick()
               local frameCount = 0
               local currentFPS = 0

               while ScreenGui.Parent do
                  frameCount = frameCount + 1
                  local now = tick()
                  if now - lastTick >= 1 then
                     currentFPS = math.floor(frameCount / (now - lastTick))
                     frameCount = 0
                     lastTick = now
                  end

                  local pingVal = 0
                  pcall(function()
                     pingVal = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                  end)

                  TextLabel.Text = string.format("FPS: %d | Ping: %d ms", currentFPS, pingVal)
                  RunService.RenderStepped:Wait()
               end
            end)
         end
      else
         if existingGui then
            existingGui:Destroy()
         end
      end
   end,
})

local WalkSpeedEnabled = false
local CustomWalkSpeed = 16

RunService.RenderStepped:Connect(function()
    if WalkSpeedEnabled then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = CustomWalkSpeed
        end
    end
end)

MiscTab:CreateSection("ระบบตัวละคร")

MiscTab:CreateToggle({
   Name = "วิ่งเร็ว",
   CurrentValue = false,
   Flag = "WalkSpeedToggle",
   Callback = function(Value)
      WalkSpeedEnabled = Value
      if not Value then
         local character = Players.LocalPlayer.Character
         if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = 16
         end
      end
   end,
})

MiscTab:CreateSlider({
   Name = "ความเร็ววิ่ง",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 16,
   Flag = "WalkSpeedSlider",
   Callback = function(Value)
      CustomWalkSpeed = Value
   end,
})

local JumpPowerEnabled = false
local CustomJumpPower = 50

RunService.RenderStepped:Connect(function()
    if JumpPowerEnabled then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.JumpPower = CustomJumpPower
        end
    end
end)

MiscTab:CreateToggle({
   Name = "กระโดดสูง",
   CurrentValue = false,
   Flag = "JumpPowerToggle",
   Callback = function(Value)
      JumpPowerEnabled = Value
      if not Value then
         local character = Players.LocalPlayer.Character
         if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.JumpPower = 50
         end
      end
   end,
})

MiscTab:CreateSlider({
   Name = "กระโดดสูง",
   Range = {50, 200}, 
   Increment = 5,
   CurrentValue = 50,
   Flag = "JumpPowerSlider",
   Callback = function(Value)
      CustomJumpPower = Value
   end,
})

local InfiniteJumpEnabled = false
UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

MiscTab:CreateToggle({
   Name = "กระโดดไม่จำกัด",
   CurrentValue = false,
   Flag = "InfiniteJumpToggle",
   Callback = function(Value)
      InfiniteJumpEnabled = Value
   end,
})

local NoclipEnabled = false
RunService.Stepped:Connect(function()
    if NoclipEnabled then
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

MiscTab:CreateToggle({
   Name = "ทะลุทุกอย่าง",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value)
      NoclipEnabled = Value
      if not Value then
         local character = LocalPlayer.Character
         if character then
             for _, part in ipairs(character:GetDescendants()) do
                 if part:IsA("BasePart") then
                     part.CanCollide = true
                 end
             end
         end
      end
   end,
})

local SpinEnabled = false
local SpinSpeed = 50

RunService.RenderStepped:Connect(function(dt)
    if SpinEnabled then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart
            rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(SpinSpeed * dt * 60), 0)
        end
    end
end)

MiscTab:CreateToggle({
   Name = "หมุน360",
   CurrentValue = false,
   Flag = "SpinToggle",
   Callback = function(Value)
      SpinEnabled = Value
   end,
})

MiscTab:CreateSlider({
   Name = "ความเร็วหมุน",
   Range = {10, 200},
   Increment = 5,
   CurrentValue = 50,
   Flag = "SpinSpeedSlider",
   Callback = function(Value)
      SpinSpeed = Value
   end,
})

local InstantPromptEnabled = false

local function ModifyPrompt(prompt)
    if prompt:IsA("ProximityPrompt") then
        if InstantPromptEnabled then
            if not prompt:GetAttribute("OriginalHoldDuration") then
                prompt:SetAttribute("OriginalHoldDuration", prompt.HoldDuration)
            end
            prompt.HoldDuration = 0 
        else
            local orig = prompt:GetAttribute("OriginalHoldDuration")
            if orig then
                prompt.HoldDuration = orig
            end
        end
    end
end

local function ToggleInstantPrompt(state)
    InstantPromptEnabled = state
    for _, obj in ipairs(workspace:GetDescendants()) do
        ModifyPrompt(obj)
    end
end

workspace.DescendantAdded:Connect(function(obj)
    if InstantPromptEnabled then
        ModifyPrompt(obj)
    end
end)

MiscTab:CreateToggle({
   Name = "โนคูลดาว",
   CurrentValue = false,
   Flag = "InstantPromptToggle",
   Callback = function(Value)
      ToggleInstantPrompt(Value)
   end,
})

Rayfield:LoadConfiguration()

Rayfield:Notify({ Title = "by มาร์คปากเหม็น", Content = "ขอให้ยิงเด็กกระโปกให้สนุก", Duration = 5 })

task.spawn(function()
    local function ChangeButtonText(parent)
        for _, v in ipairs(parent:GetDescendants()) do
            if v:IsA("TextLabel") and v.Text == "Show Rayfield" then
                v.Text = "07"
            end
        end
    end

    pcall(function() ChangeButtonText(CoreGui) end)
    pcall(function() ChangeButtonText(LocalPlayer.PlayerGui) end)

    CoreGui.DescendantAdded:Connect(function(v)
        if v:IsA("TextLabel") and v.Text == "Show Rayfield" then
            v.Text = "07"
        end
    end)
end)
