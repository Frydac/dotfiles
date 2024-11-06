local Stack = {}
Stack.__index = Stack

function Stack.new()
	local self = setmetatable({}, Stack)

	self._stack = {}

	return self
end

-- Check if the stack is empty
function Stack:empty()
	return #self._stack == 0
end

-- Put a new value onto the stack
function Stack:push(value)
	table.insert(self._stack, value)
end

-- Take a value off the stack and return it
function Stack:pop()
	if self:empty() then
		return nil
	end

	return table.remove(self._stack, #self._stack)
end

-- Look at current value
function Stack:top()
    return self._stack[#self._stack]
end

function Stack:print()
    print(vim.inspect(self._stack))
end

return Stack


-- Example:
-- local s = Stack.new()
-- s:push(1)
-- s:push(2)
-- s:push(3)
-- print(s:pop()) -- 3
-- print(s:pop()) -- 2
-- print(s:pop()) -- 1
-- print(s:pop()) -- nil
