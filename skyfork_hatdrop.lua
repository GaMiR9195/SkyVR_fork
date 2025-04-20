local function updatestate(hat, state)
	if sethiddenproperty then
		sethiddenproperty(hat, "BackendAccoutrementState", state)
	elseif setscriptable then
		setscriptable(hat, "BackendAccoutrementState", true)
		hat.BackendAccoutrementState = state
	else
		pcall(function()
			hat.BackendAccoutrementState = state
		end)
	end
end

local function performHatDrop(character, callback)
	local fph = workspace.FallenPartsDestroyHeight
	local hrp = character:WaitForChild("HumanoidRootPart")
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")

	local allhats = {}
	for _, acc in pairs(character:GetChildren()) do
		if acc:IsA("Accessory") then
			table.insert(allhats, acc)
		end
	end

	local locks = {}
	for _, hat in pairs(allhats) do
		table.insert(locks, hat.Changed:Connect(function(p)
			if p == "BackendAccoutrementState" then
				updatestate(hat, 0)
			end
		end))
		updatestate(hat, 2)
	end

	workspace.FallenPartsDestroyHeight = 0/0
	local dropcf = CFrame.new(hrp.Position.X, fph - .25, hrp.Position.Z)
	if character.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		dropcf *= CFrame.Angles(math.rad(20), 0, 0)
		character.Humanoid:ChangeState(16)
		local r15fall = 507767968
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. tostring(r15fall)
		local track = character.Humanoid:LoadAnimation(anim)
		track.Priority = Enum.AnimationPriority.Action
		track:Play()
		track:AdjustSpeed(1)
		track.TimePosition = .1
	else
		local r6fall = 180436148
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. tostring(r6fall)
		local track = character.Humanoid:LoadAnimation(anim)
		track.Priority = Enum.AnimationPriority.Action
		track:Play()
		track:AdjustSpeed(1)
		track.TimePosition = .1
	end

	spawn(function()
		while hrp.Parent do
			hrp.CFrame = dropcf
			hrp.Velocity = Vector3.new(0, 25, 0)
			hrp.RotVelocity = Vector3.new(0, 0, 0)
			game:GetService("RunService").Heartbeat:Wait()
		end
	end)

	task.wait(0.25)
	character.Humanoid:ChangeState(15)
	torso.AncestryChanged:Wait()

	for _, con in pairs(locks) do
		con:Disconnect()
	end
	for _, hat in pairs(allhats) do
		updatestate(hat, 4)
	end

	-- Get all hats and handle them
	local function getAllHats(c)
		local list = {}
		local foundmeshids = {}
		for i, v in pairs(c:GetChildren()) do
			if not v:IsA("Accessory") then continue end
			if not v.Handle:FindFirstChildOfClass("SpecialMesh") then continue end
			local meshId = filterMeshID(v.Handle:FindFirstChildOfClass("SpecialMesh").MeshId)
			local found, type = findMeshID(meshId)
			if foundmeshids["meshid:"..meshId] then
				found = false
			else
				foundmeshids["meshid:"..meshId] = true
			end
			if found then
				table.insert(list, {v, type, "meshid:"..meshId})
			else
				local named, type = findHatName(v.Name)
				if named then
					table.insert(list, {v, type, v.Name})
				end
			end
		end
		return list
	end

	local allhats = getAllHats(character)
	callback(allhats)
end

-- The rest of the script

local function createpart(size, name, h)
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

local lefthandpart = createpart(Vector3.new(2,1,1), "moveRH", true)
local righthandpart = createpart(Vector3.new(2,1,1), "moveRH", true)
local headpart = createpart(Vector3.new(1,1,1), "moveH", false)
local lefttoypart = createpart(Vector3.new(1,1,1), "LToy", true)
local righttoypart = createpart(Vector3.new(1,1,1), "RToy", true)
local thirdperson = false
local lefttoyenable = false
local righttoyenable = false
local lfirst = true
local rfirst = true
local ltoypos = CFrame.new(1.15,0,0) * CFrame.Angles(0,math.rad(180),0)
local rtoypos = CFrame.new(1.15,0,0) * CFrame.Angles(0,math.rad(0),0)
local parts = {
	left = lefthandpart,
	right = righthandpart,
	headhats = headpart,
	leftToy = lefttoypart,
	rightToy = righttoypart,
}

function _isnetworkowner(Part)
	return Part.ReceiveAge == 0
end

game.Workspace.FallenPartsDestroyHeight = 0/0

function filterMeshID(id)
	return (string.find(id,'assetdelivery') ~= nil and string.match(string.sub(id,37, #id), "%d+")) or string.match(id, "%d+")
end

function findMeshID(id)
	for i, v in pairs(getgenv().headhats) do
		if i == "meshid:" .. id then return true, "headhats" end
	end
	if getgenv().right == "meshid:" .. id then return true, "right" end
	if getgenv().left == "meshid:" .. id then return true, "left" end
	if options.leftToy == "meshid:" .. id then return true, "leftToy" end
	if options.rightToy == "meshid:" .. id then return true, "rightToy" end
	return false
end

function findHatName(id)
	for i, v in pairs(getgenv().headhats) do
		if i == id then return true, "headhats" end
	end
	if getgenv().right == id then return true, "right" end
	if getgenv().left == id then return true, "left" end
	if options.leftToy == id then return true, "leftToy" end
	if options.rightToy == id then return true, "rightToy" end
	return false
end

function Align(Part1, Part0, cf, isflingpart)
	local up = isflingpart
	local con
	con = ps:Connect(function()
		if up ~= nil then up = not up end
		if not Part1:IsDescendantOf(workspace) then con:Disconnect() return end
		if not _isnetworkowner(Part1) then return end
		Part1.CanCollide = false
		Part1.CFrame = Part0.CFrame * cf
		Part1.Velocity = velocity or Vector3.new(20, 20, 20)
	end)

	return {
		SetVelocity = function(self, v) velocity = v end,
		SetCFrame = function(self, v) cf = v end,
	}
end

game:GetService("StarterGui"):SetCore("VREnableControllerModels", false)

local rightarmalign = nil
getgenv().con5 = input.UserCFrameChanged:connect(function(part, move)
	cam.CameraType = "Scriptable"
	cam.HeadScale = options.headscale
	if part == Enum.UserCFrame.Head then
		headpart.CFrame = cam.CFrame * (CFrame.new(move.p * (cam.HeadScale - 1)) * move)
	elseif part == Enum.UserCFrame.LeftHand then
		lefthandpart.CFrame = cam.CFrame * (CFrame.new(move.p * (cam.HeadScale - 1)) * move * CFrame.Angles(math.rad(options.lefthandrotoffset.X), math.rad(options.lefthandrotoffset.Y), math.rad(options.lefthandrotoffset.Z)))
		if lefttoyenable then
			lefttoypart.CFrame = lefthandpart.CFrame * ltoypos
		end
	elseif part == Enum.UserCFrame.RightHand then
		righthandpart.CFrame = cam.CFrame * (CFrame.new(move.p * (cam.HeadScale - 1)) * move * CFrame.Angles(math.rad(options.righthandrotoffset.X), math.rad(options.righthandrotoffset.Y), math.rad(options.righthandrotoffset.Z)))
		if righttoyenable then
			righttoypart.CFrame = righthandpart.CFrame * rtoypos
		end
	end
end)

getgenv().conn = Player.CharacterAdded:Connect(function(Character)
	performHatDrop(Character, function(allhats)
		for i, v in pairs(allhats) do
			if not v[1]:FindFirstChild("Handle") then continue end
			if v[2] == "headhats" then v[1].Handle.Transparency = options.HeadHatTransparency or 1 end

			local align = Align(v[1].Handle, parts[v[2]], ((v[2] == "headhats") and getgenv()[v[2]][v[3]]) or CFrame.identity)
			rightarmalign = v[2] == "right" and align or rightarmalign
		end
	end)
end)
