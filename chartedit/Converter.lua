local class = require("class")
local table_util = require("table_util")

local Layer = require("chartedit.Layer")
local Point = require("chartedit.Point")
local eInterval = require("chartedit.Interval")
local eVisualPoint = require("chartedit.VisualPoint")
local eNotes = require("chartedit.Notes")
local eVisual = require("chartedit.Visual")

local IntervalLayer = require("ncdk2.layers.IntervalLayer")
local nInterval = require("ncdk2.to.Interval")
local nVisualPoint = require("ncdk2.visual.VisualPoint")
local nVisual = require("ncdk2.visual.Visual")
local IntervalPoint = require("ncdk2.tp.IntervalPoint")
local Chart = require("ncdk2.Chart")

---@class chartedit.Converter
---@operator call: chartedit.Converter
local Converter = class()

---@param _chart ncdk2.Chart
---@return {[string]: chartedit.Layer}
---@return chartedit.Notes
function Converter:load(_chart)
	---@type {[string]: chartedit.Layer}
	local layers = {}

	local notes = eNotes()
	local function on_vp_remove(vp) notes:removeAll(vp) end

	---@type {[ncdk2.VisualPoint]: chartedit.VisualPoint}
	local vp_map = {}
	for name, _layer in pairs(_chart.layers) do
		if IntervalLayer * _layer then
			---@cast _layer ncdk2.IntervalLayer
			layers[name] = self:loadLayer(_layer, vp_map)
			for _, visual in pairs(layers[name].visuals) do
				visual.on_remove = on_vp_remove
			end
		end
	end

	for _, _note in _chart.notes:iter() do
		local note = _note:clone()
		local vp = vp_map[_note.visualPoint  --[[@as ncdk2.VisualPoint]]]
		if vp then
			note.visualPoint = vp
			notes:addNote(note, note.column)
		end
	end

	return layers, notes
end

---@param _layer ncdk2.IntervalLayer
---@param vp_map {[ncdk2.VisualPoint]: chartedit.VisualPoint}
---@return chartedit.Layer
function Converter:loadLayer(_layer, vp_map)
	local layer = Layer()

	---@type ncdk2.IntervalPoint[]
	local _ps = _layer:getPointList()

	---@type {[ncdk2.Interval]: chartedit.Interval}
	local ivl_map = {}
	---@type chartedit.Interval[]
	local ivls = {}
	for _, p in ipairs(_ps) do
		local _ivl = p._interval
		if _ivl then
			local beats = _ivl.next and _ivl.next.point.time:floor() - p.time:floor() or 1
			local ivl = eInterval(_ivl.offset, beats)
			ivl_map[_ivl] = ivl
			table.insert(ivls, ivl)
		end
	end
	table_util.to_linked(ivls)

	---@type {[ncdk2.IntervalPoint]: chartedit.Point}
	local p_map = {}
	---@type chartedit.Point[]
	local ps = {}
	local tree = layer.points.points_tree
	for i, _p in ipairs(_ps) do
		local ivl = ivl_map[_p.interval]
		local p = Point(ivl, _p.time - _p.interval.point.time:floor())
		if _p._interval then
			p._interval = ivl_map[_p._interval]
			p._interval.point = p
		end
		p._measure = _p._measure
		p.measure = _p.measure
		p_map[_p] = p
		tree:insert(p)
		ps[i] = p
	end
	table_util.to_linked(ps)

	for name, _visual in pairs(_layer.visuals) do
		local visual = eVisual()
		---@type chartedit.VisualPoint[]
		local vps = {}
		local _vps = _visual.points
		for i = #_vps, 1, -1 do
			local _vp = _vps[i]
			local p = p_map[_vp.point --[[@as ncdk2.IntervalPoint]]]
			local vp = eVisualPoint(p)
			vp._velocity = _vp._velocity
			vp._expand = _vp._expand
			visual.p2vp[p] = vp
			vp_map[_vp] = vp
			vps[i] = vp
		end
		visual.head = table_util.to_linked(vps)
		layer.visuals[name] = visual
	end

	return layer
end

---@param _layers {[string]: chartedit.Layer}
---@param _notes chartedit.Notes
---@return ncdk2.Chart
function Converter:save(_layers, _notes)
	local chart = Chart()

	---@type {[chartedit.VisualPoint]: ncdk2.VisualPoint}
	local vp_map = {}
	for name, _layer in pairs(_layers) do
		chart.layers[name] = self:saveLayer(_layer, vp_map)
	end

	local notes = chart.notes
	for _note, column in _notes:iter() do
		local note = _note:clone()
		local vp = vp_map[_note.visualPoint  --[[@as chartedit.VisualPoint]]]
		if vp then
			note.visualPoint = vp
			note.column = column
			notes:insert(note)
		end
	end

	return chart
end

---@param _layer chartedit.Layer
---@param vp_map {[chartedit.VisualPoint]: ncdk2.VisualPoint}
---@return ncdk2.IntervalLayer
function Converter:saveLayer(_layer, vp_map)
	local layer = IntervalLayer()

	local first_point = _layer.points:getFirstPoint()
	if not first_point then
		return layer
	end

	---@type {[chartedit.Interval]: ncdk2.Interval}
	local ivl_map = {}
	---@type {[chartedit.Interval]: number}
	local ivl_beats = {}
	local ivl_total_beats = -first_point.time:ceil() + 1
	local ivls = table_util.to_array(first_point.interval)
	for _, _ivl in ipairs(ivls) do
		ivl_map[_ivl] = nInterval(_ivl.offset)
		ivl_beats[_ivl] = ivl_total_beats
		ivl_total_beats = ivl_total_beats + _ivl.beats
	end

	---@type {[chartedit.Point]: ncdk2.IntervalPoint}
	local p_map = {}
	local _ps = table_util.to_array(first_point)
	for _, _p in ipairs(_ps) do
		local p = IntervalPoint(_p.time + ivl_beats[_p.interval])
		if _p._interval then
			p._interval = ivl_map[_p._interval]
		end
		p._measure = _p._measure
		p.measure = _p.measure
		p_map[_p] = p
		layer.points[tostring(p)] = p
	end

	for name, _visual in pairs(_layer.visuals) do
		local visual = nVisual()
		---@type ncdk2.VisualPoint[]
		local vps = {}
		---@type {[ncdk2.Point]: ncdk2.VisualPoint}
		local p2vp = {}
		local _vps = table_util.to_array(_visual.head)
		for i, _vp in ipairs(_vps) do
			local p = p_map[_vp.point]
			local vp = nVisualPoint(p)
			vp._velocity = _vp._velocity
			vp._expand = _vp._expand
			vp.compare_index = i
			vp_map[_vp] = vp
			vps[i] = vp
			p2vp[p] = vp
		end
		visual.points = vps
		visual.p2vp = p2vp
		layer.visuals[name] = visual
	end

	layer:compute()

	return layer
end

return Converter
