-- skyfork ahhhdrop

-- At the start of the script (replace the original declaration)
local rightarmalign = {
    SetVelocity = function() end,
    SetCFrame = function() end
}

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

-- getAllHats() now inside HatdropCallback()

-- thanks chatgpt, i was too lazy to do this by myself (skyfork)
function HatdropCallback(Character, callback)
    local fph = workspace.FallenPartsDestroyHeight
    local hrp = Character:WaitForChild("HumanoidRootPart")
    local humanoid = Character:WaitForChild("Humanoid")
    local torso = Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("Torso")
    local start = hrp.CFrame

    local campart = Instance.new("Part", Character)
    campart.Transparency = 1
    campart.CanCollide = false
    campart.Size = Vector3.one
    campart.Position = start.Position
    campart.Anchored = true

    local function updatestate(hat, state)
        if sethiddenproperty then
            sethiddenproperty(hat, "BackendAccoutrementState", state)
        elseif setscriptable then
            setscriptable(hat, "BackendAccoutrementState", true)
            hat.BackendAccoutrementState = state
        else
            local success = pcall(function()
                hat.BackendAccoutrementState = state
            end)
            if not success then
                error("executor not supported, sorry!")
            end
        end
    end

    -- ORIGINAL getAllHats STRUCTURE
    local allhats = {}
    local foundmeshids = {}

    for _, v in pairs(Character:GetChildren()) do
        if not v:IsA("Accessory") then continue end
        if not v:FindFirstChild("Handle") then continue end

        local mesh = v.Handle:FindFirstChildOfClass("SpecialMesh")
        if mesh then
            local isMatch, category = findMeshID(filterMeshID(mesh.MeshId))
            local tag = "meshid:"..filterMeshID(mesh.MeshId)
            if foundmeshids[tag] then isMatch = false else foundmeshids[tag] = true end

            if isMatch then
                table.insert(allhats, {v, category, tag})
            else
                local isName, category2 = findHatName(v.Name)
                if isName then
                    table.insert(allhats, {v, category2, v.Name})
                end
            end
        else
            local isName, category2 = findHatName(v.Name)
            if isName then
                table.insert(allhats, {v, category2, v.Name})
            end
        end
    end

    local locks = {}
    for _, hat in pairs(allhats) do
        local acc = hat[1]
        table.insert(locks, acc.Changed:Connect(function(p)
            if p == "BackendAccoutrementState" then
                updatestate(acc, 0)
            end
        end))
        updatestate(acc, 2)
    end

    workspace.FallenPartsDestroyHeight = 0/0

    local function play(id, speed, prio, weight)
        local Anim = Instance.new("Animation")
        Anim.AnimationId = "https" .. tostring(math.random(1000000, 9999999)) .. "=" .. tostring(id)
        local track = humanoid:LoadAnimation(Anim)
        track.Priority = prio
        track:Play()
        track:AdjustSpeed(speed)
        track:AdjustWeight(weight)
        return track
    end

    local r6fall = 180436148
    local r15fall = 507767968

    local dropcf = CFrame.new(hrp.Position.x, fph - 0.25, hrp.Position.z)
    if humanoid.RigType == Enum.HumanoidRigType.R15 then
        dropcf = dropcf * CFrame.Angles(math.rad(20), 0, 0)
        humanoid:ChangeState(16)
        play(r15fall, 1, 5, 1).TimePosition = 0.1
    else
        play(r6fall, 1, 5, 1).TimePosition = 0.1
    end

    spawn(function()
        while hrp.Parent ~= nil do
            hrp.CFrame = dropcf
            hrp.Velocity = Vector3.new(0, 25, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
            game:GetService("RunService").Heartbeat:Wait()
        end
    end)

    task.wait(0.25)
    humanoid:ChangeState(15)
    if torso then
    	torso.AncestryChanged:Wait()
    end

    for _, v in pairs(locks) do v:Disconnect() end
    for _, hat in pairs(allhats) do updatestate(hat[1], 4) end

    spawn(function()
        game.Players.LocalPlayer.CharacterAdded:Wait():WaitForChild("HumanoidRootPart", 10).CFrame = start
        workspace.FallenPartsDestroyHeight = fph
    end)

    local dropped = false
    repeat
        local foundhandle = false
        for _, hat in pairs(allhats) do
            if hat[1]:FindFirstChild("Handle") then
                foundhandle = true
                if hat[1].Handle.CanCollide then
                    dropped = true
                    break
                end
            end
        end
        if not foundhandle then break end
        task.wait()
    until game.Players.LocalPlayer.Character ~= Character or dropped

    if dropped then
        print("dropped")
        workspace.CurrentCamera.CameraSubject = campart
        for _, hat in pairs(allhats) do
            local acc = hat[1]
            if acc:IsA("Accessory") and acc:FindFirstChild("Handle") and acc.Handle.CanCollide then
                spawn(function()
                    for _ = 1, 10 do
                        acc.Handle.CFrame = start
                        acc.Handle.Velocity = Vector3.new(0, 50, 0)
                        task.wait()
                    end
                end)
            end
        end
    else
        print("It failed, your executor is sooo awful")
    end

    callback(allhats)
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

HatdropCallback(Player.Character, function(allhats)
    for i,v in pairs(allhats) do
        if not v[1]:FindFirstChild("Handle") then continue end
        if v[2]=="headhats" then v[1].Handle.Transparency = options.HeadHatTransparency or 1 end

        local align = Align(v[1].Handle,parts[v[2]],((v[2]=="headhats")and getgenv()[v[2]][(v[3])]) or CFrame.identity)
        rightarmalign = v[2]=="right" and align or rightarmalign
    end
end)

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
