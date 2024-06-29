local class = require("class")
local table_util = require("table_util")

local Layer = require("chartedit.Layer")
local Point = require("chartedit.Point")
local Interval = require("chartedit.Interval")
local VisualPoint = require("chartedit.VisualPoint")

local IntervalLayer = require("ncdk2.layers.IntervalLayer")
local NcdkInterval = require("ncdk2.to.Interval")
local NcdkVisualPoint = require("ncdk2.visual.VisualPoint")
local IntervalPoint = require("ncdk2.tp.IntervalPoint")

local NoteCloner = require("ncdk2.notes.NoteCloner")

---@class chartedit.Converter
---@operator call: chartedit.Converter
local Converter = class()

---@param _layer ncdk2.IntervalLayer
---@return chartedit.Layer
function Converter:load(_layer)
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
			local ivl = Interval(_ivl.offset, beats)
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
		p_map[_p] = p
		tree:insert(p)
		ps[i] = p
	end
	table_util.to_linked(ps)

	---@type {[ncdk2.VisualPoint]: chartedit.VisualPoint}
	local vp_map = {}
	---@type chartedit.VisualPoint[]
	local vps = {}
	local _vps = _layer.visual.points
	for i = #_vps, 1, -1 do
		local _vp = _vps[i]
		local p = p_map[_vp.point --[[@as ncdk2.IntervalPoint]]]
		local vp = VisualPoint(p)
		vp._velocity = _vp._velocity
		vp._expand = _vp._expand
		layer.visual.p2vp[p] = vp
		vp_map[_vp] = vp
		vps[i] = vp
	end
	layer.visual.head = table_util.to_linked(vps)

	local note_cloner = NoteCloner()

	local lnotes = layer.notes
	for column, notes in _layer.notes:iter() do
		for _, _note in ipairs(notes) do
			local note = note_cloner:clone(_note)
			local vp = vp_map[_note.visualPoint  --[[@as ncdk2.VisualPoint]]]
			note:new(vp)
			lnotes:addNote(note, column)
		end
	end

	note_cloner:assignStartEnd()

	return layer
end

---@param _layer chartedit.Layer
---@return ncdk2.IntervalLayer
function Converter:save(_layer)
	local layer = IntervalLayer()
	local vp_head = _layer.visual.head
	if not vp_head then
		return layer
	end

	---@type {[chartedit.Interval]: ncdk2.Interval}
	local ivl_map = {}
	---@type {[chartedit.Interval]: number}
	local ivl_beats = {}
	local ivl_total_beats = -vp_head.point.time:ceil() + 1
	local ivls = table_util.to_array(vp_head.point.interval)
	for _, _ivl in ipairs(ivls) do
		ivl_map[_ivl] = NcdkInterval(_ivl.offset)
		ivl_beats[_ivl] = ivl_total_beats
		ivl_total_beats = ivl_total_beats + _ivl.beats
	end

	---@type {[chartedit.Point]: ncdk2.IntervalPoint}
	local p_map = {}
	local _ps = table_util.to_array(vp_head.point)
	for _, _p in ipairs(_ps) do
		local p = IntervalPoint(_p.time + ivl_beats[_p.interval])
		if _p._interval then
			p._interval = ivl_map[_p._interval]
		end
		p_map[_p] = p
		layer.points[tostring(p)] = p
	end

	---@type {[chartedit.VisualPoint]: ncdk2.VisualPoint}
	local vp_map = {}
	---@type ncdk2.VisualPoint[]
	local vps = {}
	---@type {[ncdk2.Point]: ncdk2.VisualPoint}
	local p2vp = {}
	local _vps = table_util.to_array(vp_head)
	for i, _vp in ipairs(_vps) do
		local p = p_map[_vp.point]
		local vp = NcdkVisualPoint(p)
		vp._velocity = _vp._velocity
		vp._expand = _vp._expand
		vp_map[_vp] = vp
		vps[i] = vp
		p2vp[p] = vp
	end
	layer.visual.points = vps
	layer.visual.p2vp = p2vp

	local note_cloner = NoteCloner()

	for _note, column in _layer.notes:iter() do
		local note = note_cloner:clone(_note)
		local vp = vp_map[_note.visualPoint  --[[@as chartedit.VisualPoint]]]
		note:new(vp)
		layer.notes:insert(note, column)
	end

	note_cloner:assignStartEnd()

	layer:compute()

	return layer
end

return Converter
