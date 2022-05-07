return function(...) 
	local Calling, LineNumber, FunctionName = debug.info(2, "sln")

	for _, Message in ipairs({...}) do 
		warn(
			string.format("{ Server : %s : ERROR }:", tostring(Calling)), 
			Message,
			string.format("{ Function %s : Line %d }", (FunctionName or "Unknown"), LineNumber)
		) 
	end 
end