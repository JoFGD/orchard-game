-- script operating the continual dropping of fruit from various player's trees; fruit starts as a flower and becomes a fruit

local repStor = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TreeGroup = game.Workspace.TreeGroup

local Btimelim = 10 -- arbitrary number for time limit between each fruit production


RunService.Heartbeat:Connect(function()
	for _,dropper in pairs(CollectionService:GetTagged("Dropper")) do -- for loop running through all instances tagged to drop fruit
		if not CollectionService:HasTag(dropper, "taken") and dropper.Parent.Parent.Parent.Parent.Name == "TreeGroup" and CollectionService:HasTag(dropper.Parent.Parent:FindFirstChild("Tree"), "Watered") then
			-- if the dropper doesn't already have fruit, is a descendant of TreeGroup, and is watered
      dropper:SetAttribute("timeval", tick()) -- dropper has attribute containing current time to make future comparisons (time limit)
			CollectionService:AddTag(dropper, "taken") -- dropper is now taken
			
			local FruitTree = dropper.Parent.Parent
			local FruitGroup = FruitTree.FruitFolder
			local textval = FruitTree.Tree.textval
			local newSFruit1 = repStor.Fruit:FindFirstChild("S"..textval.Value):Clone()
			
			newSFruit1.Parent = dropper -- flower is added to tree
			newSFruit1.CFrame = dropper.CFrame
			newSFruit1.Anchored = true		
		end
		if dropper:GetAttribute("timeval") ~= 0 and tick() - dropper:GetAttribute("timeval") > Btimelim and dropper.Parent.Parent.Parent.Parent.Name == "TreeGroup" then	
			-- if dropper has a time value set, the time elapsed is greater than the time limit set and the dropper is a descendant of TreeGroup
      local FruitTree = dropper.Parent.Parent
			local FruitGroup = FruitTree.FruitFolder
			local textval = FruitTree.Tree.textval
			dropper:FindFirstChild("S"..textval.Value):Destroy() -- flower destroyed
			local newFruit1 = repStor.Fruit:FindFirstChild("B"..textval.Value):Clone() -- fully grown fruit added
			newFruit1.Name = textval.Value
			newFruit1.Parent = dropper
			newFruit1.CFrame = dropper.CFrame
			newFruit1.Anchored = true
			
			dropper:SetAttribute("timeval", 0) -- time value reset
		end	
	end
end)
