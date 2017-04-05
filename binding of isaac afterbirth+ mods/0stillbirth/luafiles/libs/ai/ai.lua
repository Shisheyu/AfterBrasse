local clone
clone = function(o) 
	local ret = {}
	if type(o)=="table" then 
		for k,v in pairs(o) do 
			-- functions get linked through the metatable
			if type(v) ~= "function" then
				if type(v) == "table" then
					v = clone(v)
				end
				ret[k] = v
			end
		end
	end
	setmetatable(ret, { __index = o})
	return ret
end

local AI = {}

AI.prototype = {
	defaultAction = nil,
	currentAction = nil,
	_initFuncs = {},
	_preUpdateFuncs = {},
	_updateFuncs = {},
	_postUpdateFuncs = {},
	_actions = {},
	_events = {}
}

function AI.prototype:init(fn)
	self._initFuncs[#(self._initFuncs)+1] = fn
end
function AI.prototype:onPreUpdate(fn)
	self._preUpdateFuncs[#(self._preUpdateFuncs)+1] = fn
end
function AI.prototype:onUpdate(fn)
	self._updateFuncs[#(self._updateFuncs)+1] = fn
end
function AI.prototype:onPostUpdate(fn)
	self._postUpdateFuncs[#(self._postUpdateFuncs)+1] = fn
end
function AI.prototype:addAction(action)
	if action.default then
		self.defaultAction = action
	end
	if not action.name then
		action.name = action.animationName
	end
	if action.cooldown ~= nil then
		action.currentCooldown = action.cooldown
	end
	if action.duration ~= nil then
		action.currentDuration = action.duration
	end
	self._actions[action.name] = action
end
function AI.prototype:setAction(actionName)
	local action = self._actions[actionName]
	if not action then
		Isaac.DebugString("Error @ setAction('"..actionName.."'): action not defined")
	end
	if self.currentAction and self.currentAction.leave then
		self.currentAction.leave(self, self.npc, self.currentAction)
	end
	self.currentAction = action
	if action.animationName then
		self.npc:GetSprite():Play(action.animationName, false)
	end
	if action.enter then
		action.enter(self, self.npc, self.currentAction)
	end
	if action.cooldown then
		action.currentCooldown = action.cooldown
	end
	if action.duration then
		action.currentDuration = action.duration
	end
end
function AI.prototype:trySetAction(actionName)
	local action = self._actions[actionName]
	if not action then
		Isaac.DebugString("Error @ trySetAction('"..actionName.."'): action not defined")
	end
	if action.currentCooldown < 0 and ((not action.condition) or action.condition(self, self.npc, action)) then
		self:setAction(actionName)
	end
end
function AI.prototype:onEvent(evtName, fn)
	self._events[evtName] = fn
end
function AI.prototype:triggerEvent(evtName)
	self._events[evtName](self, self.npc)
end
function AI.prototype:update()
	local npc = self.npc
	local sprite = npc:GetSprite()
	local dt = npc.FrameCount - self._frameCount
	self._frameCount = npc.FrameCount

	for _,fn in pairs(self._preUpdateFuncs) do
		fn(self, npc)
	end

	for _,fn in pairs(self._updateFuncs) do
		fn(self, npc)
	end

	for _,action in pairs(self._actions) do
		if action.cooldown then
			action.currentCooldown = action.currentCooldown - dt
		end
	end

	for evtName,_ in pairs(self._events) do
		if sprite:IsEventTriggered(evtName) then
			self:triggerEvent(evtName)
		end
	end

	if self.currentAction then
		local action = self.currentAction
		if action.update then
			action.update(self, npc, action)
		end
		if action.duration then
			action.currentDuration = action.currentDuration - dt
			if action.currentDuration < 0 then
				if action.leave then
					action.leave(self, npc, action)
				end
				if ((not self.currentAction) or self.currentAction == action) and self.defaultAction then
					self:setAction(self.defaultAction.name)
				end
			end
		end
	end

	for _,fn in pairs(self._postUpdateFuncs) do
		fn(self, npc)
	end
end

function AI.new(npc, customAIs)
	local ai = {}
	setmetatable(ai, {__index = clone(AI.prototype)})
	ai.npc = npc
	ai._frameCount = npc.FrameCount
	if type(customAIs) ~= table then
		customAIs = {customAIs}
	end
	for _,c in pairs(customAIs) do
		c(ai)
	end
	for _,fn in pairs(ai._initFuncs) do
		fn(ai, npc)
	end
	return ai
end

return AI