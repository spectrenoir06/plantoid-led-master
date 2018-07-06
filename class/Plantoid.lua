local class    = require('lib.middleclass')
local Segment = require('class.Segment')

local Plantoid = class('Plantoid')

function Plantoid:initialize(data, socket)
	self.segments = {}
	for k,v in pairs(data.remotes) do
		self.segments[k] = Segment:new(v, socket)
	end
	self.parts = data.parts
end

function Plantoid:setPixel(index_led, color, part_name, part_number)
	local part = self.parts[part_name][part_number]
	self.segments[part.remote]:setPixel(index_led + part.off, color)
end

function Plantoid:setAllPixel(color, part_name, part_number)
	local size = self:getPartSize(part_name, part_number)
	for i=0, size-1 do
		self:setPixel(i, color, part_name, part_number)
	end
end

function Plantoid:getPartSize(part_name, part_number)
	return self.parts[part_name][part_number].size
end

function Plantoid:show(part_name, part_number)
	if part_name then
		if part_number then
			self.segments[self.parts[part_name][part_number].remote]:show()
		else
			local to_update = {}
			for k,v in ipairs(self.parts[part_name]) do
				to_update[v.remote] = self.segments[v.remote]
			end
			for k,v in pairs(to_update) do
				v:show()
			end
		end
	else
		for k,v in pairs(self.segments) do
			v:show()
		end
	end
end

function Plantoid:off()
	for k,v in pairs(self.segments) do
		v:off()
	end
end

return Plantoid
