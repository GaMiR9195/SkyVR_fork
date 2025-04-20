-- Skyfork Hatdrop Script

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

-- Player and Character References
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Torso = Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("Torso")

-- Global Options
local options = getgenv().options or {
    headscale = 1,
    lefthandrotoffset = Vector3.new(0, 0, 0),
    righthandrotoffset = Vector3.new(0, 0, 0),
    controllerRotationOffset = Vector3.new(0, 0, 0),
    thirdPersonButtonToggle = Enum.KeyCode.F,
    leftToyBind = Enum.KeyCode.G,
    rightToyBind = Enum.KeyCode.H,
    HeadHatTransparency = 1,
}

-- Create Part Function
local function createPart(size, name)
    local part = Instance.new("Part")
    part.Size = size
    part.Name = name
    part.Transparency = 1
    part.CanCollide = false
    part.Anchored = true
    part.Parent = Workspace
    return part
end

-- Parts for Alignment
local leftHandPart = createPart(Vector3.new(2, 1, 1), "LeftHandPart")
local rightHandPart = createPart(Vector3.new(2, 1, 1), "RightHandPart")
local headPart = createPart(Vector3.new(1, 1, 1), "HeadPart")
local leftToyPart = createPart(Vector3.new(1, 1, 1), "LeftToyPart")
local rightToyPart = createPart(Vector3.new(1, 1, 1), "RightToyPart")

local parts = {
    left = leftHandPart,
    right = rightHandPart,
    headhats = headPart,
    leftToy = leftToyPart,
    rightToy = rightToyPart,
}

-- Align Function
local function Align(part1, part0, cf)
    local connection
    connection = RunService.PostSimulation:Connect(function()
        if not part1:IsDescendantOf(Workspace) then
            connection:Disconnect()
            return
        end
        part1.CFrame = part0.CFrame * cf
        part1.Velocity = Vector3.new(0, 0, 0)
    end)
    return {
        SetCFrame = function(_, newCf)
            cf = newCf
        end,
    }
end

-- Hat Drop Function
local function HatdropCallback(character, callback)
    character:WaitForChild("Humanoid")
    character:WaitForChild("HumanoidRootPart")
    task.wait(0.4)

    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://35154961"
    local track = character.Humanoid:LoadAnimation(animation)
    track:Play()
    track.TimePosition = 3.24
    track:AdjustSpeed(0)

    local locks = {}
    for _, accessory in pairs(character:GetChildren()) do
        if accessory:IsA("Accessory") then
            table.insert(locks, accessory.Changed:Connect(function(property)
                if property == "BackendAccoutrementState" then
                    sethiddenproperty(accessory, "BackendAccoutrementState", 0)
                end
            end))
            sethiddenproperty(accessory, "BackendAccoutrementState", 2)
        end
    end

    local dropCF = CFrame.new(HumanoidRootPart.Position.X, Workspace.FallenPartsDestroyHeight + 0.25, HumanoidRootPart.Position.Z)
    local connection
    connection = RunService.PostSimulation:Connect(function()
        if not character:FindFirstChild("HumanoidRootPart") then
            connection:Disconnect()
            return
        end
        HumanoidRootPart.Velocity = Vector3.new(0, 0, 25)
        HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
        HumanoidRootPart.CFrame = dropCF * (Torso and CFrame.Angles(math.rad(90), 0, 0) or CFrame.new())
    end)

    task.wait(0.35)
    callback(character:GetChildren())
    character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    Torso.AncestryChanged:Wait()

    for _, lock in pairs(locks) do
        lock:Disconnect()
    end
    for _, accessory in pairs(character:GetChildren()) do
        if accessory:IsA("Accessory") then
            sethiddenproperty(accessory, "BackendAccoutrementState", 4)
        end
    end
end

-- Camera and Input Handling
local camera = Workspace.CurrentCamera
StarterGui:SetCore("VREnableControllerModels", false)

local thirdPerson = false
local leftToyEnabled = false
local rightToyEnabled = false
local leftToyPosition = CFrame.new(1.15, 0, 0) * CFrame.Angles(0, math.rad(180), 0)
local rightToyPosition = CFrame.new(1.15, 0, 0)

UserInputService.UserCFrameChanged:Connect(function(part, move)
    camera.CameraType = Enum.CameraType.Scriptable
    camera.HeadScale = options.headscale
    if part == Enum.UserCFrame.Head then
        headPart.CFrame = camera.CFrame * (CFrame.new(move.Position * (camera.HeadScale - 1)) * move)
    elseif part == Enum.UserCFrame.LeftHand then
        leftHandPart.CFrame = camera.CFrame * (CFrame.new(move.Position * (camera.HeadScale - 1)) * move * CFrame.Angles(math.rad(options.lefthandrotoffset.X), math.rad(options.lefthandrotoffset.Y), math.rad(options.lefthandrotoffset.Z)))
        if leftToyEnabled then
            leftToyPart.CFrame = leftHandPart.CFrame * leftToyPosition
        end
    elseif part == Enum.UserCFrame.RightHand then
        rightHandPart.CFrame = camera.CFrame * (CFrame.new(move.Position * (camera.HeadScale - 1)) * move * CFrame.Angles(math.rad(options.righthandrotoffset.X), math.rad(options.righthandrotoffset.Y), math.rad(options.righthandrotoffset.Z)))
        if rightToyEnabled then
            rightToyPart.CFrame = rightHandPart.CFrame * rightToyPosition
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode ==
::contentReference[oaicite:0]{index=0}
 
