extends Node2D

enum {
	InHand,
	InPlay,
	InMouse,
	FocusInHand,
	MoveDrawnCardToHand,
	ReOrganiseHand
}

const CARDBASE = preload("res://Cards/card_base.tscn")
const PLAYERHAND = preload("res://Cards/player_hand.gd")
const CARDSIZE = Vector2(125, 175)

var cardSelected = []
@onready var deckSize = PLAYERHAND.cardList.size() 

# An oval where the cards will position
@onready var viewportSize = Vector2(get_viewport().size) 
@onready var centreCardOval = viewportSize * Vector2(0.50, 1.25)  # Center of oval: h=50%, w=30% of viewport
@onready var hor_rad = viewportSize.x * 0.45
@onready var ver_rad = viewportSize.y * 0.40
# Angling cards on oval 
var angle = 0
var ovalAngleVector = Vector2() 
var cardSpread = 0.2
var numberCardsHand = 0
var cardNumber = 0


func drawCard():
	var newCard = CARDBASE.instantiate()
	
	# Chooses random card from hand 
	var randNum = randi() % deckSize
	cardSelected = PLAYERHAND.cardList[randNum]
	newCard.cardName = cardSelected
	
	newCard.scale *= CARDSIZE/newCard.size
	# Angle card on oval
	angle = PI/2 + cardSpread*(float(numberCardsHand)/2 - numberCardsHand)
	# Move card from deck to hand 
	ovalAngleVector = Vector2(hor_rad*cos(angle), - ver_rad*sin(angle))
	newCard.startPos = $Deck.position - CARDSIZE/2
	newCard.targetPos = centreCardOval + ovalAngleVector - CARDSIZE
	newCard.cardPos = newCard.targetPos
	# Rotate card each card as it follows the curve 
	newCard.startRot = 0
	newCard.targetRot = (PI/2 - angle)/4
	
	# Check all cards in hand: 
	# Either draws the card OR reorganises hand
	cardNumber = 0
	for card in $Cards.get_children():
		# Angle card on oval
		angle = PI/2 + cardSpread*(float(numberCardsHand)/2 - cardNumber)
		# Move card
		ovalAngleVector = Vector2(hor_rad*cos(angle), - ver_rad*sin(angle))
		card.targetPos = centreCardOval + ovalAngleVector - CARDSIZE
		# Rotate card each card as it follows the curve 
		card.startRot = card.rotation
		card.targetRot = (PI/2 - angle)/4
		
		cardNumber += 1 
		
		if card.state == InHand: 
			card.startPos = card.position
			card.state = ReOrganiseHand
		elif card.state == MoveDrawnCardToHand:
			card.startPos = card.targetPos - ( (card.targetPos - card.position)/(1-card.t) )
	
	$Cards.add_child(newCard) 
	newCard.state = MoveDrawnCardToHand
	angle += 0.2 
	numberCardsHand += 1 
	PLAYERHAND.cardList.erase(cardSelected)
	deckSize -= 1 
	return deckSize 

