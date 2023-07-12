extends Node

func hello_sync(text):
	print("Hello sync " + text)
	await get_tree().create_timer(2).timeout


func hello_async(text):
	print("Hello async " + text)

