extends Object
class_name ArrayUtils


static func unique(array: Array) -> Array:
	var result := []
	
	for item in array:
		if not item in result:
			result.append(item)
	
	return result
