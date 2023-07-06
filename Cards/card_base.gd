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
var organiseTime = 0.5

# For rotating card from deck to hand 
var startRot = 0
var targetRot = 0

# Cards pos/rot in hand (position in hand changes - might be problem) 
var cardPos = Vector2() 
var cardRot = 0

# Flipping card horizontally as it moves to hand 
@onready var originalScale = scale

# For zooming into card
var setup = true
var startScale = Vector2() 
var zoominSize = 1.70 
var zoominTime = 0.1

# For moving and reorganising neighbours when a card is zoomed in
var reorganiseNeighbours = true
var numberCardsHand = 0 
var cardNum = 0
var neighbourCard
var moveNeighbourCardCheck = false


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
				setupCard()

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
					numberCardsHand = $'../../'.numberCardsHand - 1
					# Reorganise 2 before and 2 after
					if cardNum - 1 >= 0:
						moveNeighbourCard(cardNum-1, true, 1)
					if cardNum - 2 >= 0:
						moveNeighbourCard(cardNum-2, true, 0.25)
					if cardNum + 1 <= numberCardsHand:
						moveNeighbourCard(cardNum+1, false, 1)
					if cardNum + 2 <= numberCardsHand:
						moveNeighbourCard(cardNum+2, false, 0.25)
				
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
				setupCard()
				
			if moveNeighbourCardCheck: 
				moveNeighbourCardCheck = false 
				
			if t <= 1: 
				# Move card to proper position 
				position = startPos.lerp(targetPos, t) 
				# Rotate card as it moves to position 
				rotation = startRot*(1-t) + targetRot*t
				# Zoom into hovered card 
				scale = startScale*(1-t) + originalScale*t
				
				t += delta/float(organiseTime) 
				
				# SOMEHOW this code ensures the neighbours return to their 
				# original position after you stop focusing a card. SOMEHOW! 
				if reorganiseNeighbours == false:
					reorganiseNeighbours = true  
					# Reset neighbours 2 before and 2 after
					if cardNum - 1 >= 0:
						resetCard(cardNum-1)
					if cardNum - 2 >= 0:
						resetCard(cardNum-2)
					if cardNum + 1 <= numberCardsHand:
						resetCard(cardNum+1)
					if cardNum + 2 <= numberCardsHand:
						resetCard(cardNum+2)

			else: 
				position = targetPos
				rotation = targetRot
				scale = originalScale
				state = InHand


func moveNeighbourCard(cardNum: int, left: bool, spreadFactor: float):
	neighbourCard = $'../'.get_child(cardNum)
	if left:
		neighbourCard.targetPos = neighbourCard.cardPos - spreadFactor*Vector2(65, 0)
	else:
		neighbourCard.targetPos = neighbourCard.cardPos + spreadFactor*Vector2(65, 0)
		
	neighbourCard.setup = true
	neighbourCard.state = ReOrganiseHand
	neighbourCard.moveNeighbourCardCheck = true 


# After you stop focusing (zoom) on a card, this returns the neighbours 
# to their original position. SOMEHOW! I DONT GEDDIT 
func resetCard(cardNum):
	if neighbourCard.moveNeighbourCardCheck == false:
		neighbourCard = $'../'.get_child(cardNum)
		
		# LOOPS if neighbour card is not being focused -> keep reorganising hand
		# (aka keep neighbour away from focused card, aka keep it where it is) 
		# If it is being focused, break out of the loop
		if neighbourCard.state != FocusInHand:
			neighbourCard.state = ReOrganiseHand
			neighbourCard.targetPos = neighbourCard.cardPos
			neighbourCard.setup = true


# This is typically called when a card needs to be moved
# Resets time t, and sets it's current pos/rot/sca as the start
# The target pos/rot/sca is set whenever setup is changed to true
func setupCard():
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
			targetRot = 0
			targetPos = cardPos
			targetPos.y = get_viewport().size.y - $'../../'.CARDSIZE.y*zoominSize
			state = FocusInHand


func _on_focus_mouse_exited():
	match state: 
		FocusInHand: 
			setup = true
			targetPos = cardPos
			targetRot = cardRot
			state = ReOrganiseHand
