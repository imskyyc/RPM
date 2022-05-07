return function(...) 
	local Calling, LineNumber, FunctionName = debug.info(2, "sln")

	for _, Message in ipairs({...}) do 
		print(
			string.format("{ Server : %s : INFO }:", tostring(Calling)), 
			Message,
			string.format("{ Function %s : Line %d }", (FunctionName or "Unknown"), LineNumber)
		) 
	end 
end