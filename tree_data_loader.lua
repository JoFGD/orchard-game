--load the data from database about tree locations in relation to the player's plot, data is organised as a grid/matrix

local CollectionService = game:GetService("CollectionService")

local repStor = game:GetService("ReplicatedStorage")
local TutorialEvent = repStor.Remotes.TutorialEvent
local StartCamEvent = repStor.Remotes.StartCamEvent

local ServerStorage = game:GetService("ServerStorage")

local ServerScriptService = game:GetService("ServerScriptService")
local ProfileCache = require(ServerScriptService.ProfileCacher)
local Values = require(ServerStorage.Modules.Values)

local Cams = game.Workspace.Cams.StartCams
local Plots = game.Workspace.Plots
local Regions = game.Workspace.Regions

local plotReg

StartCamEvent.OnServerEvent:Connect(function(plr, Next)
	if Values.PlayerPlots["Plot"..tostring(Next).."Region"] == nil then
		local playerProfile = ProfileCache[plr] -- table containing player data
		if playerProfile ~= nil then -- if player data exists
			plotReg = game.Workspace.Plots["Plot"..tostring(Next)] -- chosen plot = the plot number associated with the one chosen by the player on entry to the game
			local PlayerTrees = Instance.new("Folder") -- create a group for the player's trees to be put into
			PlayerTrees.Name = plr.Name.."'s".." Trees"
			PlayerTrees.Parent = game.Workspace.TreeGroup
			
			CollectionService:AddTag(game.Workspace.Regions:FindFirstChild("PlotRegion"..tostring(Next)), plr.Name) -- associate the region with the player using tags
			
			Cams:FindFirstChild(tostring(Next)).PlayerText.Value = plr.Name -- allocate the cam facing the plot to the player so subsequent players can't choose this plot
			Values.PlayerPlots["Plot"..tostring(Next).."Region"] = tostring(plr.Name)
			CollectionService:AddTag(Cams:FindFirstChild(tostring(Next)),tostring(plr.Name))
			
			Plots["Plot"..tostring(Next)].Name = plr.Name.."'s Plot" -- associate the plot with the player
			plotReg.NameSign.SurfaceGui.TextLabel.Text = plr.Name.."'s Orchard" -- text for the visible UI sign in front of player orchard
			
			for _,partplot in pairs(plotReg:GetChildren()) do
				CollectionService:AddTag(partplot, tostring(plr.Name)) -- associate all plots in region to player
			end
		
			for _,treepos in pairs(playerProfile.Data.Grid) do -- for loop going through the grid saved in player data
				if treepos["StrucName"] ~= nil then -- if a structure exists at a point in the grid
					local plot = game.Workspace.Plots:FindFirstChild(plr.Name.."'s Plot")[treepos["Name"]] -- find the plot position associated with the grid position of the structure
					local Tree = repStor.Structures:FindFirstChild(treepos["StrucName"]):Clone() -- clone structure of correct type into the correct grid position
					Tree.Name = treepos["Name"]
					Tree.Parent = PlayerTrees
					if Tree:FindFirstChild("Tree") then -- tree position depending on if sapling or not
						Tree.PrimaryPart = Tree:FindFirstChild("Tree")
						Tree:PivotTo(CFrame.new(plot.Position.x, plot.Position.y + Tree.Tree.Size.y/2, plot.Position.z))
					else
						Tree.CFrame = CFrame.new(plot.Position.x, plot.Position.y + Tree.Size.y/2, plot.Position.z)
						CollectionService:AddTag(Tree, "TreeGrow") -- if tree is a sapling add tag to continue tree growth
					end
				end
			end
			
			if playerProfile.Data.TutorialCompleted == false then -- if the player has not yet completed the game tutorial then start tutorial now
				TutorialEvent:FireClient(plr)
			end
		end
	end
end)
