tool
extends Node2D

export var initLoadTextures = PoolStringArray()
export var initLoadOverTextures = PoolStringArray()
export var initLoadUnderTextures = PoolStringArray()
var _mainTextures = []
var _overTextures = []
var _underTextures = []
export var mainTexId:int = -1 setget _setMainTex
export var overTexId:int = -1 setget _setOverTex
export var underTexId:int = -1 setget _setUnderTex
#Dictionaries to find the id of a variant's name
var _variantLookup_main:Dictionary = {}
var _variantLookup_over:Dictionary = {}
var _variantLookup_under:Dictionary = {}
### Extended Node2D (EXN) properties START ###
#Allows finer control (skewing) of the matrix used to transform nodes.
#Do not use a Node2D's rotation, position and scale properties
export var exnSkew = Vector2(0,0) setget _setSkew#:Vector2
# x scale and y skew
var workX= Vector2(0,0)#:Vector2
#x skew and y scale
var workY= Vector2(0,0)#:Vector2
export var exnScale = Vector2(1,1) setget _setScale
export var exnPos = Vector2(0,0) setget _setPos
#export var exnRot = 0.0 setget _setRot
export var _tr = Transform2D() setget _setTr#:Transform2D
### Extended Node2D (EXN) properties END ###
onready var _mainSprite = $Main
onready var _overSprite = $Overlay
onready var _underSprite = $Underlay
#var _spritesInUse = Array().resize(3)
enum layers {UNDER = -1, MAIN, OVER }

### Masking properties START ###

### Masking properties END ###
#onready var AnimPlayer = $AnimationPlayer
#Flag to indicate if the transform needs to be recalculated
var recalcTransform = false
var _validateOK = false
signal sig_spriteSceneChanged(emitter, layer, spriteNode)


func _ready():
	_variantLookup_main["None"] = -1
	_variantLookup_over["None"] = -1
	_variantLookup_under["None"] = -1
	_tr = self.transform
	_loadTextures(initLoadTextures, _mainTextures, _variantLookup_main)
	_loadTextures(initLoadOverTextures, _overTextures, _variantLookup_over)
	_loadTextures(initLoadUnderTextures, _underTextures, _variantLookup_under)
	_validateOK = true
	_setMainTex(mainTexId)
	_setOverTex(overTexId)
	_setUnderTex(underTexId)

### Animation related START ###

### Animation related END ###

### Texture related START ###
func _loadTextures(texPathList, textureList, lookupDict:Dictionary):
	for texPath in texPathList:
		var tex = load(texPath)
		if tex:
			var charSprite = tex.instance()
			if not charSprite.variantName in lookupDict.keys():
				lookupDict[charSprite.variantName] = textureList.size()
				textureList.append(charSprite)

# To be called by animations to control what variant to use.
func setVariantByName(layer, variantName):
	if layer == MAIN:
		_setMainTexByVariant(variantName)
	elif layer == OVER:
		_setOverTexByVariant(variantName)
	elif layer == UNDER:
		_setUnderTexByVariant(variantName)

func _setMainTexByVariant(variantName):
	if _variantLookup_main.has(variantName):
		mainTexId = _variantLookup_main[variantName]
		_setTexture(mainTexId, _mainTextures, _mainSprite)
	else:
		# Instead of using -1 should have another value used to 
		# indicate that the texture couldn't be loaded
		mainTexId = -1
	emit_signal("sig_spriteSceneChanged", self, MAIN, _mainSprite)

func _setMainTex(texId):
	#if mainTexId != texId:
	mainTexId = _validateTexId(texId, _mainTextures)
	_setTexture(mainTexId, _mainTextures, _mainSprite)
	emit_signal("sig_spriteSceneChanged", self, MAIN, _mainSprite)

func _setOverTexByVariant(variantName):
	if _variantLookup_over.has(variantName):
		overTexId = _variantLookup_over[variantName]
		_setTexture(overTexId, _overTextures, _overSprite)
	else:
		overTexId = -1
	emit_signal("sig_spriteSceneChanged", self, OVER, _overSprite)

func _setOverTex(texId):
	#if overTexId != texId:
	overTexId = _validateTexId(texId, _overTextures)
	_setTexture(overTexId, _overTextures, _overSprite)
	emit_signal("sig_spriteSceneChanged", self, OVER, _overSprite)
	
func _setUnderTexByVariant(variantName):
	if _variantLookup_under.has(variantName):
		underTexId = _variantLookup_under[variantName]
		_setTexture(underTexId, _overTextures, _overSprite)
	else:
		underTexId = -1
	emit_signal("sig_spriteSceneChanged", self, UNDER, _underSprite)	

func _setUnderTex(texId):
	#vv is commented due to conflicts with node ready order
	#if underTexId != texId:
	underTexId = _validateTexId(texId, _underTextures)
	_setTexture(underTexId, _underTextures, _underSprite)
	emit_signal("sig_spriteSceneChanged", self, UNDER, _underSprite)
	
func _validateTexId(texId, textureList):
	if !_validateOK:
		return texId
	if texId < -1:
		texId = -1
	elif texId >= textureList.size():
		texId = textureList.size() - 1
	return texId;
	
func _setTexture(texId, textureList, sprite):
	if sprite:
		#for x in range(sprite.get_child_count()-1, -1, -1):
		#	sprite.remove_child(sprite.get_child(x))
		
		#For post-May 3.1 git builds
		for child in sprite.get_children():
			sprite.remove_child(child)
		
		if texId > -1:
			sprite.add_child(textureList[texId])

func get_textures_in_use(layer):
	var textures = null
	if layer == MAIN and _mainSprite:
		textures = _mainSprite.get_used_textures_list()
	elif layer == OVER and _overSprite:
		textures = _overSprite.get_used_textures_list()
	elif layer == UNDER and _underSprite:
		textures = _underSprite.get_used_textures_list()
	return textures
	
### Texture related END ###

func setAnimPlayPosition(time):
	$AnimationPlayer.seek(time, true)

### Transform related START ###
func _setPos(posVector2):
	exnPos = posVector2
	position = posVector2
	recalcTransform = true
	
func _setSkew(skewVector2):
	exnSkew = skewVector2
	#rotation = skewVector2.x
	#exnRot = exnSkew.x
	recalcTransform = true

func _setScale(scaleVector2):
	exnScale = scaleVector2
	scale = scaleVector2
	recalcTransform = true
	
#func _setRot(rotDegrees):
#	exnRot = rotDegrees
#	exnSkew = Vector2(rotDegrees, rotDegrees)
#	#rotation = rotDegrees
#	recalcTransform = true
### Transform Related END ###

func setVisibility(visibility):
	if _underSprite:
		_underSprite.visible = visibility
	if _overSprite:
		_overSprite.visible = visibility
	if _mainSprite:
		_mainSprite.visible = visibility

func _process(delta):
	#_tr = self.transform
	if recalcTransform:
		#var oldPos = _tr.get_origin()
		var skewX_rad =  deg2rad(exnSkew.x)
		var skewY_rad =  deg2rad(exnSkew.y)
		#a
		workX.x = cos(skewY_rad) * exnScale.x
		#b
		workX.y = sin(skewY_rad) * exnScale.x
		#c
		workY.x = -sin(skewX_rad) * exnScale.y
		#d
		workY.y = cos(skewX_rad) * exnScale.y
		self.transform = Transform2D(workX, workY, exnPos)
		recalcTransform = false


func _setTr(tr):
	transform = tr