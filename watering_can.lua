--a remote function is fired from the client to initiate watering function (making plots in-game have watered quality and change their aesthetic).

local CollectionService = game:GetService("CollectionService")
local repStor = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local WateringEvent = repStor:WaitForChild("Remotes"):WaitForChild("WateringEvent")

local Plots = game.Workspace.Plots
local Trees = game.Workspace.TreeGroup

local Tweenfo = TweenInfo.new(
	1,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.In,
	0,
	false,
	0
)

local newTween

local function getLocalPlayerBodyPosition(player) 
	local character = player.Character or player.CharacterAdded:Wait()
	return character:WaitForChild('HumanoidRootPart').Position
end

local function WaterAction(player, WateringCan, IsPlot, Target) --function which contains the code creating all aesthetics
	local str = Instance.new("StringValue") -- initiate animation which has been predefined in the 
	str.Value = "Water" 
	str.Name = "toolanim"
	str.Parent = WateringCan
	
	if player.Character:FindFirstChild("WateringCan") then -- if WateringCan found enable particle emitter
		player.Character.WateringCan.ParticlePart.ParticleEmitter.Enabled = true
	end
	
	if IsPlot then --if the part found is a plot then tween the color from brown to darker brown
		newTween = TweenService:Create(Target, Tweenfo, {Color = Color3.fromRGB(95, 94, 98)})
		newTween:Play()
		newTween.Completed:Wait()
	else
		wait(1)
	end

	if player.Character:FindFirstChild("WateringCan") then -- if WateringCan tool is found, disable emitter
		player.Character.WateringCan.ParticlePart.ParticleEmitter.Enabled = false
	else -- else player must have unequipped tool, disable from backpack
		player.Backpack.WateringCan.ParticlePart.ParticleEmitter.Enabled = false
	end
end

WateringEvent.OnServerInvoke = 
	function(player, mouseTarget, WateringCan) -- function invoked from client
	print("Watering Function Invoked!")
		player.Character.Humanoid.WalkSpeed = 0
		if (getLocalPlayerBodyPosition(player) - mouseTarget.Position).magnitude <= 20  and player.General.WaterAvailable.Value > 0 then -- if character is less than 20 studs from target and player has enough water in watering can
			if mouseTarget:FindFirstChild("Tree") or CollectionService:HasTag(mouseTarget, "TreeGrow") or CollectionService:HasTag(mouseTarget, "PlotPart") or mouseTarget.Name == "Tree" then -- if the target is waterable
				if not CollectionService:HasTag(mouseTarget, "Watered") then -- if it has not already been watered
					if mouseTarget:FindFirstChild("Tree") or CollectionService:HasTag(mouseTarget, "TreeGrow") or mouseTarget.Name == "Tree" then -- if target is a tree
						player.General.WaterAvailable.Value -= 1 -- reduce watering can volume by 1
						if CollectionService:HasTag(mouseTarget, "TreeGrow") then -- if tree is a sapling (growing)
							local plot = Plots[player.Name.."'s Plot"][mouseTarget.Name]
							WaterAction(player, WateringCan, true, plot)
							CollectionService:AddTag(plot, "Watered") -- add watered quality to the plot and tree
							CollectionService:AddTag(mouseTarget, "Watered")
							plot:SetAttribute("WaterTime", tick()) -- add time at which it was watered as an attribute which will be compared against current time until time elapsed is more than the minimum time between waters, watered attribute is removed
							mouseTarget:SetAttribute("WaterTime", tick())	
						else -- if the target tree is a fully grown tree
							local plot = Plots[player.Name.."'s Plot"][mouseTarget.Parent.Name]
							WaterAction(player, WateringCan, true, plot)
							CollectionService:AddTag(plot, "Watered")
							CollectionService:AddTag(mouseTarget, "Watered")
							plot:SetAttribute("WaterTime", tick())
							mouseTarget:SetAttribute("WaterTime", tick())	
						end
						print("Tree Watered!")
					else -- if the target is a plot
						local Tree = Trees[player.Name.."'s Trees"]:FindFirstChild(mouseTarget.Name)
						CollectionService:AddTag(mouseTarget, "Watered")
						mouseTarget:SetAttribute("WaterTime", tick())
						if Tree then -- if tree is associated with watered plot then also add tag and attribute to tree
							CollectionService:AddTag(Tree, "Watered")
							Tree:SetAttribute("WaterTime", tick())
						end	
						player.General.WaterAvailable.Value -= 1
						WaterAction(player, WateringCan, true, mouseTarget)
					end
				else
					player.General.WaterAvailable.Value -= 1
					WaterAction(player, WateringCan, false)
					print("Tree Already Watered!")
				end
			else
				player.General.WaterAvailable.Value -= 1
				WaterAction(player, WateringCan, false)
				print("Tree Missed: Not Tree or Plot!")
			end
		else
			player.General.WaterAvailable.Value -= 1
			WaterAction(player, WateringCan, false)
			print("Tree Missed: Not Close Enough!")
		end
		player.Character.Humanoid.WalkSpeed = 20
end
