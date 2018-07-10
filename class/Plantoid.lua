local class    = require('lib.middleclass')
local Segment = require('class.Segment')

local Plantoid = class('Plantoid')

function Plantoid:initialize(data, socket)
	self.segments = {}
	self.name = data.name
	for k,v in pairs(data.remotes) do
		self.segments[k] = Segment:new(v, socket)
	end
	self.parts = data.parts
end

function Plantoid:getPartSize(part_name, part_number)
	return self.parts[part_name][part_number].size
end


function Plantoid:setPixel(index_led, color, part_name, part_number)
	-- assert(io.read("*number"), "invalid input")
	assert(self.parts[part_name], "invalid part_name: '"..(part_name or "").."'")
	assert(self.parts[part_name][part_number], "invalid part_number: '"..(part_name or "").."'")
	assert(color, "invalid color")
	index_led = math.floor(index_led)

	local part = self.parts[part_name][part_number]
	if index_led >= 0 and index_led < part.size then
		if part.invert then
			index_led = part.size - index_led
		end
		self.segments[part.remote]:setPixel(index_led + part.off, color)
	end
end

function Plantoid:setLerp(off, color1, color2, size, part_name, part_number)
	local part = self.parts[part_name][part_number]
	off = off or 0
	size = size or part.size - off
	local c = {
		color1[1],
		color1[2],
		color1[3],
		color1[4] or 0,
	}

	local ir = (color2[1] - color1[1]) / (size-1)
	local ig = (color2[2] - color1[2]) / (size-1)
	local ib = (color2[3] - color1[3]) / (size-1)
	local iw = ((color2[4] or 0) - (color1[4] or 0)) / (size-1)
	for i=0, size-1 do
		self:setPixel(i + off,
			{
				math.floor(c[1]+.5),
				math.floor(c[2]+.5),
				math.floor(c[3]+.5),
				math.floor(c[4]+.5)
			},
			part_name,
			part_number
		);
		c[1] = c[1] + ir
		c[2] = c[2] + ig
		c[3] = c[3] + ib
		c[4] = c[4] + iw
	end
end

function Plantoid:setLerpBright(off, bright1, bright2, size, part_name, part_number)
	local part = self.parts[part_name][part_number]

	local ib = (bright2 - bright1) / size
	bright1 = bright1 + ib

	for i=0, size-1 do
		local color = self:getPixel(i + off, part_name, part_number)
		if color then
			color[1] = math.max(math.ceil(color[1] * bright1), 0)
			color[2] = math.max(math.ceil(color[2] * bright1), 0)
			color[3] = math.max(math.ceil(color[3] * bright1), 0)
			bright1 = bright1 + ib
		end
	end
end

function Plantoid:getPixel(index_led, part_name, part_number)
	local part = self.parts[part_name][part_number]
	if index_led >= 0 and index_led < part.size then
		if part.invert then
			index_led = part.size - index_led
		end
		return self.segments[part.remote].data[index_led + part.off + 1]
	end
end

function Plantoid:setAllPixel(color, part_name, part_number)
	local len = self:getPartSize(part_name, part_number)
	for i=0, len-1 do
		self:setPixel(i, color, part_name, part_number)
	end
end

function Plantoid:sendLerp(off, color1, color2, size, part_name, part_number)
	local part = self.parts[part_name][part_number]
	self:setLerp(off, color1, color2, size, part_name, part_number)
	self.segments[part.remote]:sendLerp(off + part.off, color1, color2, size or part.size)
end

function Plantoid:sendPixels(off, color, size, part_name, part_number)
	local part = self.parts[part_name][part_number]
	self.segments[part.remote]:sendPixels(off + part.off, color, size or part.size)
end

function Plantoid:sendAll(update, part_name, part_number)
	if part_name then
		if part_number then
			self.segments[self.parts[part_name][part_number].remote]:sendAll(update)
		else
			local to_update = {}
			for k,v in ipairs(self.parts[part_name]) do
				to_update[v.remote] = self.segments[v.remote]
			end
			for k,v in pairs(to_update) do
				v:sendAll(update)
			end
		end
	else
		for k,v in pairs(self.segments) do
			v:sendAll(update)
		end
	end
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

function Plantoid:clear(part_name, part_number)
	if part_name then
		if part_number then
			local part = self.parts[part_name][part_number]
			self.segments[part.remote]:clear(part.off, part.size)
		else
			for k,v in ipairs(self.parts[part_name]) do
				self.segments[v.remote]:clear(v.off, v.size)
			end
		end
	else
		for k,v in pairs(self.segments) do
			v:clear()
		end
	end
end

function Plantoid:off()
	for k,v in pairs(self.segments) do
		v:off()
	end
end

return Plantoid
