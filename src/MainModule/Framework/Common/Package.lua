--// Package module wrapper

--// So basically here's the interesting design idea I had
--// To prevent malicious packages from being able to affect the game in a monumental way
--// I thought of the ability to sandbox packages, unless otherwise specified by the end user
--// So it would use a custom environment so that the package could only edit what it needs to
--// And the packages "intents" would allow it to exit the sandbox only when necessary


local Package = {}
Package.__index = Package

function Package.new(Table)
	local WrappedPackage = {
		Name = Table.name,
		Type = Table.type,

		Intents = Table.intents,
		Load    = Table.load
	}

    return setmetatable(WrappedPackage, Package)
end

function Package:SetEnvironment(Environment)
	self.Environment = Environment
end

function Package:GetEnvironment()
	return self.Environment
end

return Package