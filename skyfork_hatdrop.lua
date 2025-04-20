local function createpart(size, name,h)
	local Part = Instance.new("Part")
	Part.Parent = workspace
	Part.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
	Part.Size = size
	Part.Transparency = 1
	Part.CanCollide = false
	Part.Anchored = true
	Part.Name = name
	return Part
end
local ps = game:GetService("RunService").PostSimulation
local input = game:GetService("UserInputService")
local fpdh = game.Workspace.FallenPartsDestroyHeight
local Player = game.Players.LocalPlayer
local options = getgenv().options

local lefthandpart = createpart(Vector3.new(2,1,1), "moveRH",true)
local righthandpart = createpart(Vector3.new(2,1,1), "moveRH",true)
local headpart = createpart(Vector3.new(1,1,1), "moveH",false)
local lefttoypart = createpart(Vector3.new(1,1,1), "LToy",true)
local righttoypart =  createpart(Vector3.new(1,1,1), "RToy",true)
local thirdperson = false
local lefttoyenable = false
local righttoyenable = false
local lfirst = true
local rfirst = true
local ltoypos = CFrame.new(1.15,0,0) * CFrame.Angles(0,math.rad(180),0)
local rtoypos = CFrame.new(1.15,0,0) * CFrame.Angles(0,math.rad(0),0)
local parts = {
    left=lefthandpart,
    right=righthandpart,
    headhats=headpart,
    leftToy=lefttoypart,
    rightToy=righttoypart,
}
function _isnetworkowner(Part)
	return Part.ReceiveAge == 0
end

game.Workspace.FallenPartsDestroyHeight=0/0

function filterMeshID(id)
	return (string.find(id,'assetdelivery')~=nil and string.match(string.sub(id,37,#id),"%d+")) or string.match(id,"%d+")
end

function findMeshID(id)
    for i,v in pairs(getgenv().headhats) do
        if i=="meshid:"..id then return true,"headhats" end
    end
    if getgenv().right=="meshid:"..id then return true,"right" end
    if getgenv().left=="meshid:"..id then return true,"left" end
    if options.leftToy=="meshid:"..id then return true,"leftToy" end
    if options.rightToy=="meshid:"..id then return true,"rightToy" end
    return false
end

function findHatName(id)
    for i,v in pairs(getgenv().headhats) do
        if i==id then return true,"headhats" end
    end
    if getgenv().right==id then return true,"right" end
    if getgenv().left==id then return true,"left" end
    if options.leftToy==id then return true,"leftToy" end
    if options.rightToy==id then return true,"rightToy" end
    return false
end

function Align(Part1,Part0,cf,isflingpart) 
    local up = isflingpart
    local con;con=ps:Connect(function()
        if up~=nil then up=not up end
        if not Part1:IsDescendantOf(workspace) then con:Disconnect() return end
        if not _isnetworkowner(Part1) then return end
        Part1.CanCollide=false
        Part1.CFrame=Part0.CFrame*cf
        Part1.Velocity = velocity or Vector3.new(20,20,20)
    end)

    return {SetVelocity = function(self,v) velocity=v end,SetCFrame = function(self,v) cf=v end,}
end

function getAllHats(Character)
    local allhats = {}
    local foundmeshids = {}
    for i,v in pairs(Character:GetChildren()) do
        if not v:IsA"Accessory" then continue end
        if not v.Handle:FindFirstChildOfClass("SpecialMesh") then continue end
        
        local is,d = findMeshID(filterMeshID(v.Handle:FindFirstChildOfClass("SpecialMesh").MeshId))
	    if foundmeshids["meshid:"..filterMeshID(v.Handle:FindFirstChildOfClass("SpecialMesh").MeshId)] then is = false else foundmeshids["meshid:"..filterMeshID(v.Handle:FindFirstChildOfClass("SpecialMesh").MeshId)] = true end
	
        if is then
            table.insert(allhats,{v,d,"meshid:"..filterMeshID(v.Handle:FindFirstChildOfClass("SpecialMesh").MeshId)})
        else
            local is,d = findHatName(v.Name)
	    if not is then continue end
            table.insert(allhats,{v,d,v.Name})
        end
    end
    return allhats
end

function HatdropCallback(Character, callback)
    Character:WaitForChild("Humanoid")
    Character:WaitForChild("HumanoidRootPart")
	task.wait(0.4)
    local AnimationInstance = Instance.new("Animation");AnimationInstance.AnimationId = "rbxassetid://35154961"
	workspace.FallenPartsDestroyHeight = 0/0
    local hrp = Character.HumanoidRootPart
    local startCF = Character.HumanoidRootPart.CFrame
	local torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("LowerTorso")
    local Track = Character.Humanoid.Animator:LoadAnimation(AnimationInstance)
    Track:Play()
    Track.TimePosition = 3.24
    Track:AdjustSpeed(0)
    local locks = {}
    for i,v in pairs(Character.Humanoid:GetAccessories()) do
        table.insert(locks,v.Changed:Connect(function(p)
            if p == "BackendAccoutrementState" then
                sethiddenproperty(v,"BackendAccoutrementState",0)
            end
        end))
        sethiddenproperty(v,"BackendAccoutrementState",2)
    end
    local c;c=game:GetService("RunService").PostSimulation:Connect(function()
        if(not Character:FindFirstChild("HumanoidRootPart"))then c:Disconnect()return;end
        
        hrp.Velocity = Vector3.new(0,0,25)
        hrp.RotVelocity = Vector3.new(0,0,0)
        hrp.CFrame = CFrame.new(startCF.X,fpdh+.25,startCF.Z) * (Character:FindFirstChild("Torso") and CFrame.Angles(math.rad(90),0,0) or CFrame.new())
    end)
    task.wait(.35)
    callback(getAllHats(Character))
    Character.Humanoid:ChangeState(15)
	torso.AncestryChanged:Wait()
    for i,v in pairs(locks) do
        v:Disconnect()
    end
    for i,v in pairs(Character.Humanoid:GetAccessories()) do
        sethiddenproperty(v,"BackendAccoutrementState",4)
    end
end


local cam = workspace.CurrentCamera

game:GetService("StarterGui"):SetCore("VREnableControllerModels", false)
local rightarmalign = nil
getgenv().con5 = input.UserCFrameChanged:connect(function(part,move)
    cam.CameraType = "Scriptable"
	cam.HeadScale = options.headscale
    if part == Enum.UserCFrame.Head then
        headpart.CFrame = cam.CFrame*(CFrame.new(move.p*(cam.HeadScale-1))*move)
        --thirdpersonpart.CFrame = cam.CFrame * (CFrame.new(move.p*(cam.HeadScale-1))*move) * CFrame.new(0,0,-10) * CFrame.Angles(math.rad(180),0,math.rad(180))
    elseif part == Enum.UserCFrame.LeftHand then
        lefthandpart.CFrame = cam.CFrame*(CFrame.new(move.p*(cam.HeadScale-1))*move*CFrame.Angles(math.rad(options.lefthandrotoffset.X),math.rad(options.lefthandrotoffset.Y),math.rad(options.lefthandrotoffset.Z)))
        if lefttoyenable then
            lefttoypart.CFrame = lefthandpart.CFrame * ltoypos
        end
    elseif part == Enum.UserCFrame.RightHand then
        righthandpart.CFrame = cam.CFrame*(CFrame.new(move.p*(cam.HeadScale-1))*move*CFrame.Angles(math.rad(options.righthandrotoffset.X),math.rad(options.righthandrotoffset.Y),math.rad(options.righthandrotoffset.Z)))
        if righttoyenable then
            righttoypart.CFrame = righthandpart.CFrame * rtoypos
        end
    end
end)

getgenv().con4 = input.InputBegan:connect(function(key)
	if key.KeyCode == options.thirdPersonButtonToggle then
		thirdperson = not thirdperson -- disabled?
	end
	if key.KeyCode == Enum.KeyCode.ButtonR1 then
		R1down = true
	end
    if key.KeyCode == options.leftToyBind then
		if not lfirst then
			ltoypos = lefttoypart.CFrame:ToObjectSpace(lefthandpart.CFrame):Inverse()
		end
		lfirst = false
        lefttoyenable = not lefttoyenable
    end
	if key.KeyCode == options.rightToyBind then
		if not rfirst then
			rtoypos = righttoypart.CFrame:ToObjectSpace(righthandpart.CFrame):Inverse()
		end
		rfirst = false
        righttoyenable = not righttoyenable
    end
    if key.KeyCode == Enum.KeyCode.ButtonR2 and rightarmalign~=nil then
        R2down = true
    end
end)

getgenv().con3 = input.InputEnded:connect(function(key)
	if key.KeyCode == Enum.KeyCode.ButtonR1 then
		R1down = false
	end
    if key.KeyCode == Enum.KeyCode.ButtonR2 and rightarmalign~=nil then
        R2down = false
    end
end)
local negitive = true
getgenv().con2 = game:GetService("RunService").RenderStepped:connect(function()
	-- righthandpart.CFrame*CFrame.Angles(-math.rad(options.righthandrotoffset.X),-math.rad(options.righthandrotoffset.Y),math.rad(180-options.righthandrotoffset.X))
	if R1down then
		cam.CFrame = cam.CFrame:Lerp(cam.CoordinateFrame + (righthandpart.CFrame * CFrame.Angles(math.rad(options.righthandrotoffset.X),math.rad(options.righthandrotoffset.Y),math.rad(options.righthandrotoffset.Z)):Inverse() * CFrame.Angles(math.rad(options.controllerRotationOffset.X),math.rad(options.controllerRotationOffset.Y),math.rad(options.controllerRotationOffset.Z))).LookVector * cam.HeadScale/2, 0.5)
	end
    if R2down then
        negitive=not negitive
        rightarmalign:SetVelocity(Vector3.new(0,0,-99999999))
        rightarmalign:SetCFrame(CFrame.Angles(math.rad(options.righthandrotoffset.X),math.rad(options.righthandrotoffset.Y),math.rad(options.righthandrotoffset.Z)):Inverse()*CFrame.new(0,0,8*(negitive and -1 or 1)))
    else
        rightarmalign:SetVelocity(Vector3.new(20,20,20))
        rightarmalign:SetCFrame(CFrame.new(0,0,0))
    end
end)

function HatdropCallback(Character, callback)
    Character:WaitForChild("Humanoid")
    Character:WaitForChild("HumanoidRootPart")
    local Humanoid = Character.Humanoid
    local HRP = Character.HumanoidRootPart
    local torso = Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("Torso")
    local start = HRP.CFrame
    local fph = workspace.FallenPartsDestroyHeight

    local function updatestate(hat,state)
        if sethiddenproperty then
            sethiddenproperty(hat,"BackendAccoutrementState",state)
        elseif setscriptable then
            setscriptable(hat,"BackendAccoutrementState",true)
            hat.BackendAccoutrementState = state
        else
            local success = pcall(function()
                hat.BackendAccoutrementState = state
            end)
            if not success then
                warn("executor not supported, skipping hat")
            end
        end
    end

    -- Create transparent camera anchor
    local campart = Instance.new("Part", Character)
    campart.Transparency = 1
    campart.CanCollide = false
    campart.Size = Vector3.one
    campart.Position = start.Position
    campart.Anchored = true

    local allhats = {}
    for _, acc in ipairs(Character:GetChildren()) do
        if acc:IsA("Accessory") then
            table.insert(allhats, acc)
        end
    end

    local locks = {}
    for _, acc in ipairs(allhats) do
        table.insert(locks, acc.Changed:Connect(function(prop)
            if prop == "BackendAccoutrementState" then
                updatestate(acc, 0)
            end
        end))
        updatestate(acc, 2)
    end

    workspace.FallenPartsDestroyHeight = 0/0

    -- Choose animation based on rig
    local animId = Humanoid.RigType == Enum.HumanoidRigType.R15 and 507767968 or 180436148
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. tostring(animId)
    local track = Humanoid:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    track:AdjustSpeed(1)
    track.TimePosition = .1

    -- Simulate drop
    local dropCF = CFrame.new(HRP.Position.X, 0/0 - .25, HRP.Position.Z)
    if Humanoid.RigType == Enum.HumanoidRigType.R15 then
        dropCF = dropCF * CFrame.Angles(math.rad(20),0,0)
        Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
    end

    local c
    c = game:GetService("RunService").Heartbeat:Connect(function()
        if not HRP:IsDescendantOf(workspace) then c:Disconnect() return end
        HRP.CFrame = dropCF
        HRP.Velocity = Vector3.new(0,25,0)
        HRP.RotVelocity = Vector3.new(0,0,0)
    end)

    task.wait(.25)
    Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    if torso then torso.AncestryChanged:Wait() end

    for _, con in ipairs(locks) do con:Disconnect() end
    for _, acc in ipairs(allhats) do
        updatestate(acc, 4)
    end

    -- Apply optional hat bounce
    local dropped = false
    for _, hat in ipairs(allhats) do
        if hat:FindFirstChild("Handle") and hat.Handle.CanCollide then
            dropped = true
            spawn(function()
                for _ = 1, 10 do
                    hat.Handle.CFrame = start
                    hat.Handle.Velocity = Vector3.new(0, 50, 0)
                    task.wait()
                end
            end)
        end
    end

    if dropped then
        workspace.CurrentCamera.CameraSubject = campart
    end

    -- Reset on respawn
    spawn(function()
        local newChar = game.Players.LocalPlayer.CharacterAdded:Wait()
        newChar:WaitForChild("HumanoidRootPart",10).CFrame = start
        workspace.FallenPartsDestroyHeight = fph
    end)

    -- Now call original callback
    if callback then callback(getAllHats(Character)) end
end

getgenv().conn = Player.CharacterAdded:Connect(function(Character)
    HatdropCallback(Player.Character, function(allhats)
        for i,v in pairs(allhats) do
            if not v[1]:FindFirstChild("Handle") then continue end
            if v[2]=="headhats" then v[1].Handle.Transparency = options.HeadHatTransparency or 1 end

            local align = Align(v[1].Handle,parts[v[2]],((v[2]=="headhats")and getgenv()[v[2]][(v[3])]) or CFrame.identity)
            rightarmalign = v[2]=="right" and align or rightarmalign
        end
    end)
end)