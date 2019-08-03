extends "res://addons/gut/test.gd"

var _partFactory:CharacterPartFactory
var _headwear:PackedScene = preload("res://Char Parts/Headwear.tscn")
func before_all():
	_partFactory = CharacterPartFactory.new()
	
func after_all():
	_partFactory.free()
	
func test_partRegistration():
	gut.p("Testing that registration will fail when given an invalid packed scene")
	var bad_part:PackedScene = load("res://Testing/unit/test_CharParts/InvalidCharPart.tscn")
	assert_false(_partFactory.registerPart(bad_part))
	gut.p("Registrating valid character part")
	assert_true(_partFactory.registerPart(_headwear))
	gut.p("Testing that an instance of a part can be created")
	assert_not_null(_partFactory.createPart("Headwear"))
	gut.p("Making sure that re-registrating a part is not allowed")
	assert_false(_partFactory.registerPart(_headwear))
	
func test_partExtending():
	_partFactory.free()
	_partFactory = CharacterPartFactory.new()
	_partFactory.registerPart(_headwear)
	var headwear_extra = load("res://Testing/unit/test_CharParts/Sprite_Headwear-Test.tscn").instance()
	assert_false(_partFactory.addSpriteToPart(headwear_extra, "Headwear"))
	gut.p("Make sure duplicate instances are not allowed")
	assert_false(_partFactory.addSpriteToPart(headwear_extra, "Headwear"))
	var headwear_extra_dup = load("res://Testing/unit/test_CharParts/Sprite_Headwear-Test.tscn").instance()
	assert_false(_partFactory.addSpriteToPart(headwear_extra_dup, "Headwear"))
	gut.p("Ensure that duplicated instances have the newly added sprite")
	var dup_headwear:CharacterPart = _partFactory.createPart("Headwear")
	assert_eq(dup_headwear._mainTextures[0].name, headwear_extra.name)
	assert_ne(dup_headwear._mainTextures[0], headwear_extra)
	
func test_partCreationMT():
	var th1:Thread = Thread.new()
	var th2:Thread = Thread.new()