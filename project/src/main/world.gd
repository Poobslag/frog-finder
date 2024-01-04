class_name World
extends Object
## Information about a world, such as its music, intermissions and levels.

## Title to show on the main menu.
##
## Each title should have exactly two question marks, otherwise players will be incentivized to scroll around to the
## world with the most question marks to find an extra frog.
##
## Only certain letters are allowed in titles. Illegal letters will log a warning and show up as a blank space.
var title: String

## List of intermission dances.
##
## The first dance in the list is mandatory, and the frogs will always perform it. The other dances are optional, and
## frogs might randomly perform it or not perform it. Frogs will never perform a dance not in the list.
var dances: Array[String]

var frog_songs: Array[String]

## IntermissionTweak scene which modifies the intermission in some ways
var intermission_tweak_scene: PackedScene
var intermission_tweak_name: String

## Levels for each mission.
##
## Each mission is comprised of one or more levels and mission adjustments. Most worlds includes two training missions
## 'x-1' and 'x-2' which teaches you to play two levels, then a final mission which includes a combination of missions.
## Each level includes an optional difficulty adjustment suffix between '--' and '++', so that players can be exposed
## to easier versions of levels while they are learning the rules. The general pattern goes like this:
##
## 	x-1: (easy new level A) (old level B)
## 	x-2: (easy new level C) (old level D)
## 	x-3: (level A) (level C) (very hard level B) (very hard level D) (very easy level E)
##
## To summarize, players are trained on easy versions of levels. Then they're tested on the normal versions of those
## levels. They are also tested on very hard versions of levels they've played in the past, and they are tested on very
## easy versions of levels they've never seen before.
var missions: Array[Array]

var shark_song: String

func from_json_dict(json: Dictionary) -> void:
	title = json.get("title", "")
	dances.assign(json.get("dances", []))
	frog_songs.assign(json.get("frog_songs", []))
	intermission_tweak_name = json.get("intermission_tweak", "")
	missions.assign(json.get("missions", []))
	shark_song = json.get("shark_song", "")
	
	if intermission_tweak_name:
		intermission_tweak_scene = load(intermission_tweak_name)
