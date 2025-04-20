function HatdropCallback(Character, callback)
    local fph = workspace.FallenPartsDestroyHeight
    local plr = game.Players.LocalPlayer
    local hrp = Character:WaitForChild("HumanoidRootPart")
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

    local allhats = {}
    for i,v in pairs(Character:GetChildren()) do
        if v:IsA("Accessory") then
            table.insert(allhats, v)
        end
    end

    local locks = {}
    for i,v in pairs(allhats) do
        table.insert(locks, v.Changed:Connect(function(p)
            if p == "BackendAccoutrementState" then
                updatestate(v, 0)
            end
        end))
        updatestate(v, 2)
    end

    workspace.FallenPartsDestroyHeight = 0/0

    local function play(id, speed, prio, weight)
        local Anim = Instance.new("Animation")
        Anim.AnimationId = "rbxassetid://" .. tostring(id)
        local track = Character.Humanoid:LoadAnimation(Anim)
        track.Priority = prio
        track:Play()
        track:AdjustSpeed(speed)
        track:AdjustWeight(weight)
        return track
    end

    local r6fall = 180436148
    local r15fall = 507767968

    local dropcf = CFrame.new(hrp.Position.x, fph - .25, hrp.Position.z)
    if Character.Humanoid.RigType == Enum.HumanoidRigType.R15 then
        dropcf = dropcf * CFrame.Angles(math.rad(20), 0, 0)
        Character.Humanoid:ChangeState(16)
        play(r15fall, 1, 5, 1).TimePosition = .1
    else
        play(r6fall, 1, 5, 1).TimePosition = .1
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
    Character.Humanoid:ChangeState(15)
    torso.AncestryChanged:Wait()

    for i,v in pairs(locks) do
        v:Disconnect()
    end
    for i,v in pairs(allhats) do
        updatestate(v, 4)
    end

    spawn(function()
        plr.CharacterAdded:Wait():WaitForChild("HumanoidRootPart", 10).CFrame = start
        workspace.FallenPartsDestroyHeight = fph
    end)

    local dropped = false
    repeat
        local foundhandle = false
        for i,v in pairs(allhats) do
            if v:FindFirstChild("Handle") then
                foundhandle = true
                if v.Handle.CanCollide then
                    dropped = true
                    break
                end
            end
        end
        if not foundhandle then
            break
        end
        task.wait()
    until plr.Character ~= Character or dropped

    if dropped then
        print("dropped")
        workspace.CurrentCamera.CameraSubject = campart
        for i,v in pairs(Character:GetChildren()) do
            if v:IsA("Accessory") and v:FindFirstChild("Handle") and v.Handle.CanCollide then
                spawn(function()
                    for i = 1, 10 do
                        v.Handle.CFrame = start
                        v.Handle.Velocity = Vector3.new(0, 50, 0)
                        task.wait()
                    end
                end)
            end
        end
    else
        print("failed to drop")
    end

    -- Send collected hat info to callback (keep integration)
    callback(getAllHats(Character))
end
