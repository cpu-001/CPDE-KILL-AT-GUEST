extends RefCounted
class_name Mission

var id: String
var type: String
var target: int
var progress: int = 0
var completed: bool = false

func setup(_id: String, _type: String, _target: int):
	id = _id
	type = _type
	target = _target
