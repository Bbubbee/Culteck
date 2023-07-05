extends TextureButton

var deckSize = INF

func _ready():
	# $'../../' = Playspace (script)
	scale *= $'../../'.CARDSIZE/size

# Called when deck is pressed
# Draw a card
func _gui_input(event):
	if Input.is_action_just_released("leftclick"):
		if deckSize > 0: 
			deckSize = $'../../'.drawCard() 
			if deckSize == 0:
				disabled = true 
