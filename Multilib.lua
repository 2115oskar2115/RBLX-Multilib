-- Multilib v1.2
-- Spirit Dice Productions
-- 2023
-- Load to _G

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lib = {}

-- Main

function Lib:Create(InstanceName,Parent,Proporties)
	local InstanceCreated = Instance.new(InstanceName,Parent)
	print(InstanceName,Parent,Proporties)
	for prop, value in pairs(Proporties) do
		InstanceCreated[prop] = value
	end
	return InstanceCreated
end

function Lib:TempInstance(InstanceToTemp,Time)
	Debris:AddItem(InstanceToTemp,Time)
end

function Lib:Raycast(From, To, Strenght, FilterDesc, FilterType, IgnoreWater)
	if typeof(To) == "Instance" then
		To = CFrame.lookAt(From.Position,To.Position).LookVector * Strenght
	end
	local Parameters = RaycastParams.new()
	Parameters.FilterDescendantsInstances = FilterDesc or {From}
	Parameters.FilterType = FilterType or Enum.RaycastFilterType.Exclude
	Parameters.IgnoreWater = IgnoreWater or true

	local RaycastResult = workspace:Raycast(From.Position,To,Parameters)
	if RaycastResult ~= nil then
		return RaycastResult
	else
		warn("Raycast Result nil")
		return false
	end
end

-- Minor

function Lib:SoundFX(ID,Where,Speed,Range,SoundVolume)
	local ToDelete = "Sound"
	if type(Where) == "vector" then
		Where = self:Create("Part",workspace,{
			Position = Where,
			Size = Vector3.new(0.1,0.1,0.1),
			Anchored = true,
			Transparency = 1,
			CanCollide = false
		})
		ToDelete = Where
	end
	local Sound = self:Create("Sound",Where,{
		SoundId = "rbxassetid://" .. ID,
		PlaybackSpeed = Speed,
		RollOffMaxDistance = Range,
		Volume = SoundVolume
	})
	Sound:Play()
	if ToDelete ~= "Sound" then
		self:TempInstance(Where,Sound.TimeLength + 1)
	else
		self:TempInstance(Sound,Sound.TimeLength + 1)
	end
end

function Lib:ParticleFX(Particle, Where, Strength)
	Where = self:Create("Part",workspace,{
		Position = Where,
		Size = Vector3.new(0.1,0.1,0.1),
		Anchored = true,
		Transparency = 1,
		CanCollide = false
	})
	Particle:Fire(Strength)
	self:TempInstance(Particle,Particle.LifeTime.Max + 1)
end

function Lib:ReturnFromVal(Table, ValName, Val)
	for index, value in pairs(Table) do
		if value[ValName] == Val then
			return value
		end
	end
	warn("Error - Not Found")
	return false
end

function Lib:TweenTable(Table, Style, Direction, Time)
	for index, value in pairs(Table) do
		TweenService:Create(index,
			TweenInfo.new(Time,Style,Direction),
			value):Play()
	end
end

function Lib:FindAndReturn(Inst,Parent)
	if typeof(Inst) == "Instance" then
		Inst = Inst.Name
	end
	if Parent:FindFirstChild(Inst) then
		return Parent[Inst]
	else
		warn("Error - Not Found")
		return false
	end
end

function Lib:LoadAnim(ID,Animator)
	local Anim = self:Create("Animation",nil,{
		AnimationId = "rbxassetid://" .. ID,
	})
	return Animator:LoadAnimation(Anim)
end

function Lib:Propability(Percent, Max)
	if math.random(1,Max) <= Percent then
		return true
	else
		return false
	end
end

function Lib:ReturnChance(Percent, Total) -- Sani ^_^
	return math.floor((Percent / Total * 100) * 10 + 0.5) / 10
end

function Lib:PutToParallel(Script,Where)
	if not ReplicatedStorage:FindFirstChild(Where) then
		self:Create("Folder",ReplicatedStorage,{Name = Where})
	end
	local Actor = self:Create("Actor",ReplicatedStorage[Where],{Name = Script.Name .. "_Actor"})
	Script = Script:Clone()
	Script.Parent = Actor
	return Script, Actor
end

function Lib:ClearChildren(From)
	for index, instance in pairs(From) do
		instance:Destroy()
	end
	return
end

function Lib:FormatList(ScrollingFrame)
	if not ScrollingFrame:FindFirstChild("UIListLayout") then
		warn("Error - No ListLayout")
		return
	end
	local ListLayout = ScrollingFrame.UIListLayout
	local TotalSize = ScrollingFrame.CanvasSize
	local Elemets = ScrollingFrame:GetChildren()
	local TrueElements = {}
	for index, value in pairs(Elemets) do
		if value:IsA("Frame") or value:IsA("ImageButton") or value:IsA("TextLabel") or value:IsA("TextButton") then
			table.insert(TrueElements,value)
		end
	end
	local TrueNewSize = (TotalSize.Y.Scale - ListLayout.Padding.Scale) / ((1 + #TrueElements) * 2)
	print(TrueNewSize)
	for index, value in pairs(TrueElements) do
		value.Size = UDim2.fromScale(value.Size.X.Scale,TrueNewSize)
	end
end

return Lib
