local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")

local Emit = {}

Emit._index = Emit

function Emit.new(pos, typ)
	local emitter = {}
	setmetatable(emitter, Emit)
	
	local Current = ServerStorage:FindFirstChild(typ)
	Current.Position = pos
	Current.Enabled = true
	Current:SetAttribute("Time", tick())
	
	CollectionService:AddTag(Current, "emitter")
	
	emitter["Current"] = Current
	
	return emitter
end

function Emit:change(typ)
	Emit.new(self.Position, typ)
	self:Destroy()
end


return Emit
