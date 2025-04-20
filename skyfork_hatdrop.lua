function HatdropCallback(Character, callback)
    local fph = workspace.FallenPartsDestroyHeight
    local hrp = Character:WaitForChild("HumanoidRootPart")
    local torso = Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("Torso")
    local startCF = hrp.CFrame

    local campart = Instance.new("Part", Character)
    campart.Transparency = 1
    campart.CanCollide = false
    campart.Size = Vector3.one
    campart.Position = startCF.Position
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
                warn("Executor not supported!")
            end
        end
    end

    local allhats = {}
    for _, hat in ipairs(Character:GetChildren()) do
        if hat:IsA("Accessory") then
            table.insert(allhats, hat)
        end
    end

    local locks = {}
    for _, hat in ipairs(allhats) do
        table.insert(locks, hat.Changed:Connect(function(prop)
            if prop == "BackendAccoutrementState" then
                updatestate(hat, 0)
            end
        end))
        updatestate(hat, 2)
    end

    workspace.FallenPartsDestroyHeight = 0 / 0

    local r6fall = 180436148
    local r15fall = 507767968

    local dropcf = CFrame.new(hrp.Position.X, fph - 0.25, hrp.Position.Z)
    if Character.Humanoid.RigType == Enum.HumanoidRigType.R15 then
        dropcf = dropcf * CFrame.Angles(math.rad(20), 0, 0)
        Character.Humanoid:ChangeState(16)
        local r15 = Instance.new("Animation")
        r15.AnimationId = "rbxassetid://" .. r15fall
        local track = Character.Humanoid:LoadAnimation(r15)
        track:Play()
        track.TimePosition = 0.1
    else
        local r6 = Instance.new("Animation")
        r6.AnimationId = "rbxassetid://" .. r6fall
        local track = Character.Humanoid:LoadAnimation(r6)
        track:Play()
        track.TimePosition = 0.1
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

    for _, conn in ipairs(locks) do
        conn:Disconnect()
    end
    for _, hat in ipairs(allhats) do
        updatestate(hat, 4)
    end

    spawn(function()
        game.Players.LocalPlayer.CharacterAdded:Wait():WaitForChild("HumanoidRootPart", 10).CFrame = startCF
        workspace.FallenPartsDestroyHeight = fph
    end)

    callback(getAllHats(Character))
end
