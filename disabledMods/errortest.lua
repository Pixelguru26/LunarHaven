local mod = {}

function mod.load()
	print("hi! erroring.")
	error("is this or isn't this what you expected?",1)
end

return mod