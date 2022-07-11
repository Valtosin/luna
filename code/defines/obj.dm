/obj
	//var/datum/module/mod		//not used
	var/m_amt = 0	// metal
	var/g_amt = 0	// glass

	var/origin_tech = null	//Used by R&D to determine what research bonuses it grants.
	var/reliability = 100	//Used by SOME devices to determine how reliable they are.
	var/crit_fail = 0
	var/unacidable = 0 //universal "unacidabliness" var, here so you can use it in any obj.
	animate_movement = 2

	var/throwforce = 1
	var/list/attack_verb = list() //Used in attackby() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]"
	var/in_use = 0 // If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!
	var/damtype = "brute"
	var/force = 0

	var/global/tagcnum = 0
	var/explosionstrength = 0
	var/spawnchance = null 	//If this is defined, this is the percent chance that this object will spawn.  Checked in New().  Intended to be defined on the map, for some randomness in item placement.

	var/list/NetworkNumber = list( )
	var/list/Networks = list( )

	proc
		handle_internal_lifeform(mob/lifeform_inside_me, breath_request)
			//Return: (NONSTANDARD)
			//		null if object handles breathing logic for lifeform
			//		datum/air_group to tell lifeform to process using that breath return
			//DEFAULT: Take air from turf to give to have mob process
			if(breath_request>0)
				return remove_air(breath_request)
			else
				return null

		initialize()

	New()
		src.tag = "obj[++tagcnum]"
		if(spawnchance)
			if(prob(100-spawnchance))
				del src

/obj/proc/interact(mob/user)
	return

/obj/proc/update_icon()
	return



/obj/item/policetaperoll
	name = "police tape roll"
	desc = "A roll of police tape used to block off crime scenes from the public."
	icon = 'icons/policetape.dmi'
	icon_state = "rollstart"
	flags = FPRINT
	var/tapestartx = 0
	var/tapestarty = 0
	var/tapestartz = 0
	var/tapeendx = 0
	var/tapeendy = 0
	var/tapeendz = 0

/obj/item/policetape
	name = "police tape"
	desc = "A length of police tape.  Do not cross."
	icon = 'icons/policetape.dmi'
	anchored = 1
	density = 1
	throwpass = 1
	req_access = list(access_security)

/obj/blob
	icon = 'blob.dmi'
	icon_state = "bloba0"
	var/health = 30
	density = 1
	opacity = 0
	anchored = 1

/obj/blob/idle
	name = "blob"
	desc = "it looks... frightened"
	icon_state = "blobidle0"

/obj/mark
	var/mark = ""
	icon = 'mark.dmi'
	icon_state = "blank"
	anchored = 1
	layer = 99
	mouse_opacity = 0

/obj/bhole
	name = "black hole"
	icon = 'objects.dmi'
	desc = "FUCK FUCK FUCK AAAHHH"
	icon_state = "bhole2"
	opacity = 0
	density = 0
	anchored = 1
	var/datum/effect/system/harmless_smoke_spread/smoke




/obj/beam
	name = "beam"

/obj/beam/a_laser
	name = "a laser"
	icon = 'projectiles.dmi'
	icon_state = "laser"
	density = 1
	var/yo = null
	var/xo = null
	var/current = null
	var/life = 50.0
	anchored = 1.0
	flags = 0
	pass_flags = PASSTABLE

/obj/beam/i_beam
	name = "i beam"
	icon = 'projectiles.dmi'
	icon_state = "ibeam"
	var/obj/beam/i_beam/next = null
	var/obj/item/device/infra/master = null
	var/limit = null
	var/visible = 0.0
	var/left = null
	anchored = 1.0
	flags = 0
	pass_flags = PASSTABLE

/obj/begin
	name = "begin"
	icon = 'stationobjs.dmi'
	icon_state = "begin"
	anchored = 1.0

/obj/datacore
	name = "datacore"
	var/list/medical = list(  )
	var/list/general = list(  )
	var/list/security = list(  )

/obj/equip_e
	name = "equip e"
	var/mob/source = null
	var/s_loc = null
	var/t_loc = null
	var/obj/item/item = null
	var/place = null

/obj/equip_e/human
	name = "human"
	var/mob/living/carbon/human/target = null

/obj/equip_e/monkey
	name = "monkey"
	var/mob/living/carbon/monkey/target = null

/obj/item
	name = "item"
	icon = 'items.dmi'
	var/icon_old = null
	var/abstract = 0.0
	var/item_state = null
	throwforce = 10
	var/r_speed = 1.0
	var/health = null
	var/burn_point = null
	var/burning = null
	var/hitsound = null
	var/w_class = 3
	var/slot_flags = 0
	var/icon/blood_overlay = null
	flags = FPRINT
	pass_flags = PASSTABLE
	pressure_resistance = 50
	var/slowdown = 0
	var/canremove = 1
	var/flags_inv
	var/armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	var/list/allowed = null //suit storage stuff.
	var/obj/item/master = null

/obj/item/proc/IsShield()
	return 0

/obj/item/device
	icon = 'device.dmi'

/obj/item/device/detective_scanner
	name = "Scanner"
	desc = "Used to scan objects for DNA and fingerprints"
	icon_state = "forensic0"
	var/amount = 20.0
	var/printing = 0.0
	w_class = 2.0
	item_state = "electronic"
	flags = FPRINT | CONDUCT | USEDELAY | NOHIT
	slot_flags = SLOT_BELT


/obj/item/device/infra
	name = "Infrared Beam (Security)"
	desc = "Emits a visible or invisible beam and is triggered when the beam is interrupted."
	icon_state = "infrared0"
	var/obj/beam/i_beam/first = null
	var/state = 0.0
	var/visible = 0.0
	flags = FPRINT | CONDUCT
	w_class = 2.0
	item_state = "electronic"
	m_amt = 150

/obj/item/device/infra_sensor
	name = "Infrared Sensor"
	desc = "Scans for infrared beams in the vicinity."
	icon_state = "infra_sensor"
	var/passive = 1.0
	flags = FPRINT | CONDUCT
	item_state = "electronic"
	m_amt = 150

/obj/item/device/t_scanner
	name = "T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	icon_state = "t-ray0"
	var/on = 0
	flags = FPRINT
	slot_flags = SLOT_BELT
	w_class = 2
	item_state = "electronic"
	origin_tech = "magnets=2;engineering=2"
	m_amt = 150

/obj/item/device/multitool
	name = "multitool"
	icon_state = "multitool"
	flags = FPRINT | CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	origin_tech = "magnets=1;engineering=1"
	desc = "You can use this on airlocks or APCs to try to hack them without cutting wires."
	m_amt = 50
	g_amt = 20

// So far, its functionality is found only in code/game/machinery/doors/airlock.dm
/obj/item/device/hacktool
	name = "hacktool"
	icon_state = "hacktool"
	origin_tech = "magnets=2;engineering=5;syndicate=3"
	flags = FPRINT | CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	desc = "An item of dubious origins, with wires and antennas protruding out of it."
	m_amt = 60
	g_amt = 20

/obj/item/device/prox_sensor
	name = "Proximity Sensor"
	icon_state = "motion0"
	var/state = 0.0
	var/timing = 0.0
	var/time = null
	flags = FPRINT | CONDUCT
	w_class = 2.0
	item_state = "electronic"
	m_amt = 300


/obj/item/device/timer
	name = "timer"
	icon_state = "timer0"
	item_state = "electronic"
	var/timing = 0.0
	var/time = null
	flags = FPRINT | CONDUCT
	w_class = 2.0
	m_amt = 100


/obj/effect/landmark
	name = "landmark"
	icon = 'screen1.dmi'
	icon_state = "x2"
	anchored = 1.0

/obj/effect/landmark/tunderdome

/obj/effect/landmark/derelict
	name = "Derelict Info Node"

	nodamage
		name = "no damage"
		icon_state = "blocked"

	noblast
		name = "no blast"
		icon_state = "blocked"

	o2crate
		name = "internals crate"
	o2canister
		name = "air/o2 canister"
	metal
		name = "metal spawn"
	glass
		name = "glass spawn"
	superpacman
		name = "SuperPacman spawn"
	supplycrate
		name = "supply crate spawn"


/obj/effect/landmark/alterations
	name = "alterations"
	nopath
		invisibility = 101
		name = "Bot No-Path"

/obj/list_container
	name = "list container"

/obj/list_container/mobl
	name = "mobl"
	var/master = null

	var/list/container = list(  )

/obj/manifest
	name = "manifest"
	icon = 'screen1.dmi'
	icon_state = "x"

/obj/effect/mine
	name = "Mine"
	desc = "I Better stay away from that thing."
	density = 1
	anchored = 1
	layer = 3
	icon = 'weapons.dmi'
	icon_state = "uglymine"
	var/triggerproc = "explode" //name of the proc thats called when the mine is triggered
	var/triggered = 0

/obj/effect/mine/dnascramble
	name = "Radiation Mine"
	icon_state = "uglymine"
	triggerproc = "triggerrad"

/obj/effect/mine/plasma
	name = "Plasma Mine"
	icon_state = "uglymine"
	triggerproc = "triggerplasma"

/obj/effect/mine/kick
	name = "Kick Mine"
	icon_state = "uglymine"
	triggerproc = "triggerkick"

/obj/effect/mine/n2o
	name = "N2O Mine"
	icon_state = "uglymine"
	triggerproc = "triggern2o"

/obj/effect/mine/stun
	name = "Stun Mine"
	icon_state = "uglymine"
	triggerproc = "triggerstun"

/obj/overlay
	name = "overlays"

/obj/projection
	name = "Projection"
	anchored = 1.0

/obj/effect/screen
	name = "screen"
	icon = 'screen1.dmi'
	layer = 20
	plane = -1
	//anchored = 1
	var/id = 0
	var/obj/master

/obj/effect/screen/close
	name = "close"
	master = null

/obj/effect/screen/grab
	name = "grab"
	master = null

/obj/effect/screen/storage
	name = "storage"
	master = null

/obj/effect/screen/zone_sel
	name = "Damage Zone"
	icon = 'zone_sel.dmi'
	icon_state = "blank"
	var/selecting = "chest"
	screen_loc = "EAST+1,NORTH"

/obj/shut_controller
	name = "shut controller"
	var/moving = null
	var/list/parts = list(  )

/obj/effect/landmark/start
	name = "start"
	icon = 'screen1.dmi'
	icon_state = "x"
	anchored = 1.0

/obj/effect/deskclutter
	name = "desk clutter"
	icon = 'items.dmi'
	icon_state = "deskclutter"
	desc = "Some clutter that has accumalated over the years..."
	anchored = 1

/obj/item/mouse_drag_pointer = MOUSE_ACTIVE_POINTER