extends MarginContainer

@onready var cardDatabase = preload("res://Assets/Cards/CardsDatabase.gd")
@onready var cardDatabaseTemp = cardDatabase.new() 
var cardName = 'Hawberk'
@onready var cardInfo = cardDatabaseTemp.DATA[cardDatabaseTemp.get(cardName)] 
@onready var cardImg = str("res://Assets/Cards/", cardInfo[0], "/", cardName,".jpg")

enum {
	InHand,
	InPlay,
	InMouse,
	FocusInHand,
	MoveDrawnCardToHand,
	ReOrganiseHand
}
var state = InHand

# For moving card to hand
var startPos = 1
var targetPos = 1
var t = 0 
var drawTime = 0.75
var organiseTime = 1

# For rotating card from deck to hand 
var startRot = 0
var targetRot = 0

# Flipping card horizontally as it moves to hand 
@onready var originalScale = scale

# For zooming into card
var setup = true
var startScale = Vector2() 
var cardPos = Vector2() 
var zoominSize = 1.75 
var zoominTime = 0.2 

var reorganiseNeighbours = true
var numberCardsHand = 0 
var cardNum = 0


func _physics_process(delta):
	match state: 
		InHand:
			pass
		InPlay:
			pass
		InMouse:
			pass
		FocusInHand:
			if setup: 
				setupHand()

			if t <= 1: 
				# Move card to position
				position = startPos.lerp(targetPos, t) 
				# Rotate card as it moves to position
				rotation = startRot*(1-t) + targetRot*t
				# Zoom into hovered card 
				scale = startScale*(1-t) + originalScale*zoominSize*t
				
				t += delta/float(zoominTime)
				
				if reorganiseNeighbours:
					reorganiseNeighbours = false
				
			else: 
				position = targetPos
				rotation = targetRot
				scale = originalScale*zoominSize 

		MoveDrawnCardToHand:
			if t <= 1: 
				# Move card to hand
				position = startPos.lerp(targetPos, t) 
				# Rotate card as it moves to hand 
				rotation = startRot * (1-t) + targetRot * t
				# Flips card horizontally (inverse scale.x) 
				scale.x = originalScale.x * abs((2*t - 1))
				if $CardBack.visible: 
					if t >= 0.5:
						$CardBack.visible = false 

				t += delta/float(drawTime)

			else:  # Finished moving card to hand
				position = targetPos
				rotation = targetRot
				state = InHand
				t = 0 
				
		ReOrganiseHand:
			if setup: 
				setupHand()
				
			if t <= 1: 
				# Move card to proper position 
				position = startPos.lerp(targetPos, t) 
				# Rotate card as it moves to position 
				rotation = startRot*(1-t) + targetRot*t
				# Zoom into hovered card 
				scale = startScale*(1-t) + originalScale*t
				
				t += delta/float(organiseTime)
			else: 
				position = targetPos
				rotation = targetRot
				scale = originalScale
				state = InHand


# As far as I know it's used for zooming in and out 
func setupHand():
	startPos = position 
	startRot = rotation
	startScale = scale
	t = 0
	setup = false 


func _ready():
	configureTextures()
	updateCardInfo()


func configureTextures(): 
	var cardSize = size
	$Border.scale = cardSize/$Border.texture.get_size() 
	$Card.texture = load(cardImg) 
	$Card.scale = cardSize/$Card.texture.get_size() 
	$CardBack.scale = cardSize/$CardBack.texture.get_size()
	$Focus.scale = cardSize/$Focus.size


# Get card information from database and display it on the card
func updateCardInfo():
	pass
	var cardName = str(cardInfo[1])  
	var cost = str(cardInfo[2])
	var health = str(cardInfo[3])
	var attack = str(cardInfo[4])
	var effect = str(cardInfo[5])

	$Bars/TopBar/Name/CenterContainer/Name.text = cardName
	$Bars/TopBar/Cost/CenterContainer/Cost.text = cost
	$Bars/Effect/Type/CenterContainer/Effect.text = effect
	$Bars/BottomBar/Attack/CenterContainer/Attack.text = attack
	$Bars/BottomBar/Health/CenterContainer/Health.text = health 


func _on_focus_mouse_entered():
	match state:
		InHand, ReOrganiseHand: 
			setup = true
#			targetRot = 0
#			targetPos = cardPos
#			targetPos.y = get_viewport().size.y - $'../../'.CARDSIZE.y*zoominSize
			state = FocusInHand


func _on_focus_mouse_exited():
	match state: 
		FocusInHand: 
			setup = true
#			targetPos = cardPos
			state = ReOrganiseHand
