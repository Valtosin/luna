/world/proc/load_mode()
	var/text = file2text("data/mode.txt")
	if (text)
		var/list/lines = dd_text2list(text, "\n")
		if (lines[1])
			master_mode = lines[1]
			check_diary()
			diary << "Saved mode is '[master_mode]'"

/world/proc/save_mode(var/the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	F << the_mode

/world/proc/load_motd()
	join_motd = file2text("config/motd.txt")

/world/proc/load_rules()
	rules = file2text("config/rules.html")
	if (!rules)
		rules = "<html><head><title>Rules</title><body>There are no rules! Go nuts!</body></html>"

/world/proc/convert_ranks(var/nym as num)
	switch(nym)
		if(0) return 0
		if(1) return "Moderator"
		if(2) return "Administrator"
		if(3) return "Primary Administrator"
		if(4) return "Super Administrator"
		if(5) return "Coder"
		if(6) return "Host"
		else  return 0

/world/proc/load_testers()
	var/text = file2text("config/testers.txt")
	if (!text)
		check_diary()
		diary << "Failed to load config/testers.txt\n"
	else
		var/list/lines = dd_text2list(text, "\n")
		for(var/line in lines)
			if (!line)
				continue

			if (copytext(line, 1, 2) == ";")
				continue

			var/pos = findtext(line, " - ", 1, null)
			if (pos)
				var/m_key = copytext(line, 1, pos)
				var/a_lev = copytext(line, pos + 3, length(line) + 1)
				admins[m_key] = a_lev


/world/proc/load_configuration()
	config = new /datum/configuration()
	config.load("config/config.txt")
	// apply some settings from config..
	abandon_allowed = config.respawn

/world/New()
	src.load_configuration()

	if (config && config.server_name != null && config.server_suffix && world.port > 0)
		// dumb and hardcoded but I don't care~
		config.server_name += " #[(world.port % 1000) / 100]"

	. = ..()

	master_controller = new /datum/controller/game_controller()
	spawn(-1) master_controller.setup()
	return

/world/Reboot(var/reason)

	world << "\red <B>Rebooting! (This may take a while, just hang on unless you receive an error message!)</B>"

	spawn(0)
		for(var/client/C)
			C << link("byond://[world.internet_address]:[world.port]")

	..(reason)

/atom/proc/check_eye(user as mob)
	if (istype(user, /mob/living/silicon/ai))
		return 1
	return

/atom/proc/on_reagent_change()
	return

/atom/proc/Bumped(AM as mob|obj)
	return

/atom/movable/Bump(var/atom/A as mob|obj|turf|area, yes)
	spawn( 0 )
		if ((A && yes))
			A.last_bumped = world.timeofday
			A.Bumped(src)
		return
	..()
	return

// **** Note in 40.93.4, split into obj/mob/turf point verbs, no area

/atom/verb/point()
	set name = "Point"
	set category = "IC"

	set src in oview()

	if (!usr || !isturf(usr.loc))
		return
	else if (usr.stat != 0 || usr.restrained())
		return

	var/tile = get_turf(src)
	if (!tile)
		return

	var/P = new /obj/effect/decal/point(tile)
	spawn (20)
		del(P)

	usr.visible_message("<b>[usr]</b> points to [src]")

/proc/heartbeat()
	spawn(0)
		while (1)
			sleep(100 * tick_multiplier)
			world.Export("http://127.0.0.1:31337")