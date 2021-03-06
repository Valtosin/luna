//GUYS REMEMBER TO ADD A += to UPDATE_ADMINS
//AND A -= TO CLEAR_ADMIN_VERBS

/client/var/list/averbs = list()

/client/proc/update_admins(var/rank)

	//Verbs for everyone moderator and up.
	//Put them here rather than having to copy/paste and/or miss a few places they should be.
	var/list/averbs_moderator = list(
			/client/proc/UnpedalMe,
			/client/proc/cmd_admin_gib_self,
			/client/proc/cmd_admin_pm,
			/client/proc/cmd_admin_prison,
			/client/proc/cmd_admin_say,
			/client/proc/cmd_admin_subtle_message,
			/client/proc/delay,
			/client/proc/dsay,
			/client/proc/switchtowindow,
			/obj/admins/proc/announce,				//global announce
			/obj/admins/proc/startnow,				//start now bitch
			/obj/admins/proc/toggleAI,				//Toggle the AI
			/obj/admins/proc/toggleooc,				//toggle ooc
			/obj/admins/proc/unprison,
			/obj/admins/proc/vmode,   				//start vote
			/obj/admins/proc/votekill, 				//abort vote
			/obj/admins/proc/voteres, 				//toggle votes
			/client/proc/Jump,
			/client/proc/jumptokey,
			/client/proc/jumptomob,
			/client/proc/jumptoturf,
			/client/proc/secrets                    //secrets panel(info and commands)
			)

	//Verbs for everyone secondary administrator and up.
	var/list/averbs_secondary_admin = list(
			/client/proc/cmd_admin_create_centcom_report,
			/mob/living/proc/CheckHandcuff,
			/obj/admins/proc/immreboot,				//immediate reboot
			/obj/admins/proc/restart,				//restart
			/obj/admins/proc/toggleenter			//Toggle enterting
			)

	//Verbs for everyone administrator and up.
	var/list/averbs_admin = list(
			/client/proc/cmd_admin_add_random_ai_law,
			/client/proc/cmd_admin_mute,
			/client/proc/cmd_explode_turf,
			/client/proc/createofficial,
			/client/proc/hidemode,
			/client/proc/hubvis,
			/client/proc/nanoshuttle,
			/client/proc/radioalert,
			/client/proc/returnadminshuttle,
			/client/proc/toggleadminsectordoors,
			/client/proc/toggleadminshuttledoors,
			/client/proc/toggleevents,
			/obj/admins/proc/toggletraitorscaling,	//toggle traitor scaling
			/client/proc/give_disease,
			/client/proc/give_spell
			)

	//Verbs for everyone primary administrator and up.
	var/list/averbs_primary_admin = list(
			/client/proc/checkticker,
			/client/proc/cmd_admin_remove_plasma,
			/client/proc/cmd_admin_check_contents,
			/client/proc/cmd_admin_reset_id,
			/client/proc/cmd_admin_deghostize,
			/client/proc/deadchat,					//toggles deadchat
			/client/proc/debug_variables,
			/client/proc/editappear,
			/client/proc/LSD_effect,
			/client/proc/play_sound,
			/proc/togglebuildmode,
			/client/proc/revive_td,
			/client/proc/tdparty,
			/client/proc/tp_td,
			/client/proc/g_op,
			/client/proc/e_op,
			/client/proc/c_op,
			/client/proc/t_op
			)

	//Verbs for everyone super administrator and up.
	var/list/averbs_super_admin = list(
			/client/proc/debug_variables_new,
			/client/proc/CarbonCopy,
			/client/proc/clearmap,
			/client/proc/cmd_admin_add_freeform_ai_law,
			/client/proc/cmd_admin_alienize,
			/client/proc/cmd_admin_delete,
			/client/proc/cmd_admin_drop_everything,
			/client/proc/cmd_admin_godmode,
			/client/proc/cmd_admin_rejuvenate,
			/client/proc/cmd_admin_robotize,
			/client/proc/cmd_modify_object_variables,
			/client/proc/cmd_modify_ticker_variables,
			/client/proc/Debug2,					//debug toggle switch
			/client/proc/fix_next_move,
			/client/proc/toggle_view_range,
			/client/proc/funbutton,
			/client/proc/general_report,
			/client/proc/Getmob,
			/client/proc/loadmap,
			/client/proc/loadmaphere,
			/client/proc/modifytemperature,
			/client/proc/SDQL_query,
			/client/proc/SDQL2_query,
			/client/proc/sendmob,
			/client/proc/zombify,
			/client/proc/Force_Event,
			/obj/admins/proc/adjump,				//toggle admin jumping
			/obj/admins/proc/adrev,					//toggle admin revives
			/obj/admins/proc/adspawn,				//toggle admin item spawning
			/obj/admins/proc/toggleaban,			//abandon mob
			/obj/admins/proc/toggle_aliens,
			/proc/possess,
			/proc/release
			)

	//Verbs for coder and host
	var/list/averbs_coder = list(
			/client/proc/callprocgen,
			/client/proc/callprocobj,
			/client/proc/Cell,
			/client/proc/cmd_debug_del_all,
			/client/proc/cmd_admin_list_occ,
			/client/proc/get_admin_state,
			/client/proc/ticklag,
			)

	if(!src.holder)
		src.holder = new /obj/admins(src)

	src.holder.rank = rank

	if(!src.holder.state)
		var/state = alert("Which state do you the admin to begin in?", "Admin-state", "Play", "Observe", "Neither")
		if(state == "Play")
			src.holder.state = 1
			src.admin_play()
			return
		else if(state == "Observe")
			src.holder.state = 2
			src.admin_observe()
			return
		else
			del(src.holder)
			return

	switch (rank)
		if ("Host")
			src.deadchat = 1
			src.holder.level = 6

			src.averbs += averbs_moderator
			src.averbs += averbs_secondary_admin
			src.averbs += averbs_admin
			src.averbs += averbs_primary_admin
			src.averbs += averbs_super_admin
			src.averbs += averbs_coder

			src.averbs += /client/proc/new_event

			//src.averbs += /client/proc/air_report
			//src.averbs += /client/proc/air_status
//			src.averbs += /client/proc/getmobs
//			src.averbs += /client/proc/cmd_admin_list_admins
//			src.averbs += /client/proc/cmd_admin_gib
//			src.averbs += /client/proc/grillify


		if ("Coder")
			src.deadchat = 1
			src.holder.level = 5

			src.averbs += averbs_moderator
			src.averbs += averbs_secondary_admin
			src.averbs += averbs_admin
			src.averbs += averbs_primary_admin
			src.averbs += averbs_super_admin
			src.averbs += averbs_coder

			src.averbs += /obj/admins/proc/spawn_atom
			src.averbs += /client/proc/qsowtoggle
			src.averbs += /client/proc/cmd_debug_tog_aliens
			src.averbs += /client/proc/Zone_Info

			//src.averbs += /client/proc/air_report
			//src.averbs += /client/proc/air_status
//			src.averbs += /client/proc/getmobs
//			src.averbs += /client/proc/cmd_admin_list_admins
//			src.averbs += /client/proc/cmd_admin_gib
//			src.averbs += /proc/toggleai
//				src.averbs += /client/proc/grillify


		if ("Super Administrator")
			src.deadchat = 1
			src.holder.level = 4

			src.averbs += averbs_moderator
			src.averbs += averbs_secondary_admin
			src.averbs += averbs_admin
			src.averbs += averbs_primary_admin
			src.averbs += averbs_super_admin

			src.averbs += /client/proc/Zone_Info

			//src.averbs += /client/proc/air_report
			//src.averbs += /client/proc/air_status
//			src.averbs += /client/proc/cmd_admin_gib
//			src.averbs += /client/proc/cmd_admin_list_admins


		if ("Primary Administrator")

			src.deadchat = 1
			src.holder.level = 3

			src.averbs += averbs_moderator
			src.averbs += averbs_secondary_admin
			src.averbs += averbs_admin
			src.averbs += averbs_primary_admin

			if(src.holder.state == 2) //observing
				src.averbs += /obj/admins/proc/toggletraitorscaling
				src.averbs += /client/proc/cmd_admin_drop_everything
				src.averbs += /client/proc/debug_variables
				src.averbs += /client/proc/cmd_modify_object_variables
				src.averbs += /client/proc/cmd_modify_ticker_variables
//				src.averbs += /client/proc/cmd_admin_gib
				src.averbs += /client/proc/jumptokey
				src.averbs += /client/proc/jumptomob
				src.averbs += /client/proc/Jump
				src.averbs += /client/proc/jumptoturf
				src.averbs += /client/proc/Getmob
				src.averbs += /client/proc/sendmob
				src.averbs += /client/proc/cmd_admin_add_freeform_ai_law
				src.averbs += /client/proc/cmd_admin_rejuvenate
				src.averbs += /obj/admins/proc/toggleaban			//abandon mob
				src.averbs += /client/proc/toggle_view_range

//			src.averbs += /client/proc/modifytemperature
//			src.averbs += /client/proc/cmd_admin_list_admins

//			src.averbs += /obj/admins/proc/adrev					//toggle admin revives
//			src.averbs += /obj/admins/proc/adspawn				//toggle admin item spawning
//			src.averbs += /obj/admins/proc/adjump				//toggle admin jumping

		if ("Administrator")

			src.holder.level = 2

			src.averbs += averbs_moderator
			src.averbs += averbs_secondary_admin
			src.averbs += averbs_admin

			if(src.holder.state == 2) //observing
				src.deadchat = 1
				src.averbs += /client/proc/Jump
				src.averbs += /client/proc/cmd_admin_check_contents
				src.averbs += /client/proc/jumptomob
				src.averbs += /client/proc/jumptokey
				src.averbs += /obj/admins/proc/toggleaban			//abandon mob
				src.averbs += /client/proc/deadchat					//toggles deadchat

//			src.averbs += /client/proc/play_sound

//			src.averbs += /obj/admins/proc/adrev					//toggle admin revives
//			src.averbs += /obj/admins/proc/adspawn				//toggle admin item spawning
//			src.averbs += /obj/admins/proc/adjump				//toggle admin jumping

		if ("Secondary Administrator")
			src.holder.level = 1

			src.averbs += averbs_moderator
			src.averbs += averbs_secondary_admin

			if(src.holder.state == 2) //observing
				src.averbs += /obj/admins/proc/toggleaban			//abandon mob
				src.averbs += /client/proc/cmd_admin_check_contents

//			src.averbs += /obj/admins/proc/adrev					//toggle admin revives
//			src.averbs += /obj/admins/proc/adspawn				//toggle admin item spawning
//			src.averbs += /obj/admins/proc/adjump				//toggle admin jumping


		if ("Moderator")
			src.holder.level = 0

			src.averbs += averbs_moderator

//			src.averbs += /obj/admins/proc/restart				//restart
//			src.averbs += /obj/admins/proc/immreboot				//immediate reboot
//			src.averbs += /obj/admins/proc/toggleenter			//Toggle enterting

//			src.averbs += /obj/admins/proc/adrev					//toggle admin revives
//			src.averbs += /obj/admins/proc/adspawn				//toggle admin item spawning
//			src.averbs += /obj/admins/proc/adjump				//toggle admin jumping

//			src.averbs += /obj/admins/proc/boot					//boot someone
//			src.averbs += /obj/admins/proc/toggleaban			//abandon mob

		if ("Goat Fart")
			src.holder.level = -1
			src.averbs += /client/proc/cmd_admin_say
			src.averbs += /client/proc/cmd_admin_gib_self

		if ("Banned")
			del(src)
			return

		else
			del(src.holder)
			return

	if (src.holder)
		src.holder.owner = src
		if (src.holder.level > -1)
			src.averbs += /client/proc/admin_play
			src.averbs += /client/proc/admin_observe
			src.averbs += /client/proc/voting
			src.averbs += /client/proc/game_panel
			src.averbs += /client/proc/player_panel

		if(src.holder.level > 1)
			src.averbs += /client/proc/stealth
			src.averbs += /client/proc/admin_invis

//		if(( src.holder.state == 2 ) || ( src.holder.level > 3 ))
//			src.averbs += /client/proc/secrets

	src.verbs += src.averbs
	src.verbs += /client/proc/disable_averbs

/client/proc/clear_admin_verbs()
	src.deadchat = 0

	src.verbs -= src.averbs
	src.averbs = list()
	/*
	src.verbs -= /client/proc/cmd_admin_reset_id
	src.verbs -= /client/proc/debug_variables
	src.verbs -= /client/proc/cmd_modify_object_variables
	src.verbs -= /client/proc/cmd_modify_ticker_variables
	src.verbs -= /client/proc/cmd_admin_pm
	src.verbs -= /client/proc/cmd_admin_say
	src.verbs -= /client/proc/dsay
	src.verbs -= /client/proc/play_sound
//	src.verbs -= /client/proc/cmd_admin_gib
	src.verbs -= /client/proc/cmd_admin_gib_self
//				src.verbs -= /client/proc/modifytemperature
	src.verbs -= /client/proc/Jump
	src.verbs -= /client/proc/cmd_admin_rejuvenate
	src.verbs -= /client/proc/funbutton
	src.verbs -= /client/proc/cmd_admin_delete
	src.verbs -= /client/proc/cmd_admin_mute
	src.verbs -= /client/proc/cmd_admin_drop_everything
	src.verbs -= /client/proc/cmd_debug_tog_aliens
	src.verbs -= /client/proc/cmd_admin_godmode
	src.verbs -= /client/proc/cmd_admin_add_freeform_ai_law
	src.verbs -= /client/proc/cmd_admin_check_contents
	src.verbs -= /client/proc/jumptomob
	src.verbs -= /client/proc/jumptokey
	src.verbs -= /client/proc/cmd_admin_alienize
	src.verbs -= /client/proc/cmd_admin_changelinginize
//	src.verbs -= /client/proc/cmd_admin_list_admins
	src.verbs -= /client/proc/Getmob
	src.verbs -= /client/proc/sendmob
	src.verbs -= /client/proc/cmd_admin_prison
	src.verbs -= /client/proc/Debug2
	src.verbs -= /client/proc/deadchat					//toggles deadchat
	src.verbs -= /obj/admins/proc/immreboot				//immediate reboot
	src.verbs -= /obj/admins/proc/vmode   				//start vote
	src.verbs -= /obj/admins/proc/votekill 				//abort vote
	src.verbs -= /obj/admins/proc/voteres 				//toggle votes
	src.verbs -= /obj/admins/proc/restart				//restart
	src.verbs -= /obj/admins/proc/announce				//global announce
	src.verbs -= /obj/admins/proc/toggleooc				//toggle ooc
	src.verbs -= /obj/admins/proc/startnow				//start now bitch
	src.verbs -= /obj/admins/proc/toggleenter			//Toggle enterting
	src.verbs -= /obj/admins/proc/toggleAI				//Toggle the AI
	src.verbs -= /obj/admins/proc/toggleaban			//abandon mob
	src.verbs -= /obj/admins/proc/adrev					//toggle admin revives
	src.verbs -= /obj/admins/proc/adspawn				//toggle admin item spawning
	src.verbs -= /obj/admins/proc/adjump				//toggle admin jumping
	src.verbs -= /obj/admins/proc/unprison
	src.verbs -= /client/proc/cmd_admin_create_centcom_report
	src.verbs -= /client/proc/game_panel
	src.verbs -= /client/proc/player_panel
	src.verbs -= /client/proc/unban_panel
	src.verbs -= /client/proc/secrets
	src.verbs -= /client/proc/voting
	src.verbs -= /client/proc/admin_play
	src.verbs -= /client/proc/admin_observe
	src.verbs -= /client/proc/stealth

	src.verbs -= /client/proc/general_report
	//src.verbs -= /client/proc/air_report
	//src.verbs -= /client/proc/air_status

	src.verbs -= /client/proc/toggle_view_range
	src.verbs -= /obj/admins/proc/toggle_aliens
	*/
	if(src.holder)
		src.holder.level = 0


/client/proc/disable_averbs()
	set category = "Admin"
	set name = "Hide Admin Verbs"
	verbs -= averbs
	verbs -= /client/proc/disable_averbs
	verbs += /client/proc/cmd_admin_say
	verbs += /client/proc/enable_averbs

/client/proc/enable_averbs()
	set category = "Admin"
	set name = "Show Admin Verbs"
	verbs += averbs
	verbs += /client/proc/disable_averbs
	verbs -= /client/proc/enable_averbs


/client/proc/admin_observe()
	set category = "Admin"
	set name = "Set Observe"
	if(!src.holder)
		alert("You are not an admin")
		return
/*
	if(!src.mob.start)
		alert("You cannot observe while in the starting position")
		return
*/
	src.verbs -= /client/proc/admin_play
	spawn(1200)										//change this to 1200
		src.verbs += /client/proc/admin_play
	var/rank = src.holder.rank
	clear_admin_verbs()
	src.holder.state = 2
	update_admins(rank)
	if(isliving(src.mob))
		var/mob/living/M = src.mob
		M.ghostize()
		src << "\blue You are now observing"

/client/proc/admin_play()
	set category = "Admin"
	set name = "Set Play"
	if(!src.holder)
		alert("You are not an admin")
		return
	src.verbs -= /client/proc/admin_observe
	spawn( 1200 )										//change this to 1200
		src.verbs += /client/proc/admin_observe
	var/rank = src.holder.rank
	clear_admin_verbs()
	src.holder.state = 1
	update_admins(rank)
	if(istype(src.mob, /mob/dead/observer))
		var/mob/dead/observer/O = src.mob
		O.reenter_corpse()
		src << "\blue You are now playing"

/client/proc/get_admin_state()
	set category = "Debug"
	for(var/client/C)
		if(C.holder)
			if(C.holder.state == 1)
				src << "[C.mob.key] is playing - [C.holder.state]"
			else if(C.holder.state == 2)
				src << "[C.mob.key] is observing - [C.holder.state]"
			else
				src << "[C.mob.key] is undefined - [C.holder.state]"

//admin client procs ported over from mob.dm
/client/proc/UnpedalMe()
	set name = "UnPedalMe!"
	set category = "Admin"
	log_admin("[key_name(usr)] has unpedaled himself")
	message_admins("[key_name_admin(usr)] has unpedaled himself", 1)
	src.clear_admin_verbs()
	src.update_admins("Remove")
	admins[src.ckey] = "Remove"

/client/proc/player_panel()
	set name = "Player Panel"
	set category = "Admin"
	if (src.holder)
		src.holder.player()
	return

/client/proc/game_panel()
	set name = "Game Panel"
	set category = "Admin"
	if (src.holder)
		src.holder.Game()
	return

/client/proc/secrets()
	set name = "Secrets"
	set category = "Admin"
	if (src.holder)
		src.holder.Secrets()
	return

/*
/client/proc/beta_testers()
	set name = "Testers"
	set category = "Admin"
	if (src.holder)
		src.holder.beta_testers()
	return
*/

/client/proc/qsowtoggle()
	set name = "QSOW toggle"
	set category = "Admin"
	if(qsow)
		qsow = 0
	else
		qsow = 1
	usr<<"QSOW [qsow]"

/client/proc/voting()
	set name = "Voting"
	set category = "Admin"
	if (src.holder)
		src.holder.Voting()

/client/proc/funbutton()
	set category = "Debug"
	set name = "Boom Boom Boom Shake The Room"
	if(!src.holder)
		src << "Only administrators may use this command."
		return

	for(var/turf/simulated/floor/T in world)
		if(prob(4) && (T.z > 0 && T.z < 5) && istype(T))
			spawn(50+rand(0,3000))
				explosion(T, 3, 1, force=1)

	usr << "\blue Blowing up ship ..."

	log_admin("[key_name(usr)] has used boom boom boom shake the room")
	message_admins("[key_name_admin(usr)] has used boom boom boom shake the room", 1)

/client/proc/give_disease(mob/T as mob in mob_list) // -- Giacom
	set category = "Debug"
	set name = "Give Disease"
	set desc = "Gives a Disease to a mob."
	var/datum/disease/D = input("Choose the disease to give to that guy", "ACHOO") as null|anything in diseases
	if(!D) return
	T.contract_disease(new D, 1)
	log_admin("[key_name(usr)] gave [key_name(T)] the disease [D].")
	message_admins("\blue [key_name_admin(usr)] gave [key_name(T)] the disease [D].", 1)

/client/proc/stealth()
	set category = "Admin"
	set name = "Stealth Mode"
	if(!src.holder)
		src << "Only administrators may use this command."
		return
	if(src.stealth) //choose whether to turn it off or use a different name to stealth as
		var/input = input("Do you want to turn off stealth mode?") in list("Yes","No")
		if(input == "Yes")
			src.stealth = !src.stealth
	else
		src.stealth = !src.stealth
	if(src.stealth)
		var/new_key = trim(input("Enter your desired display name.", "Fake Key", src.key))
		if(!new_key)
			src.stealth = 0
			return
		new_key = strip_html(new_key)
		if(length(new_key) >= 26)
			new_key = copytext(new_key, 1, 26)
		src.fakekey = new_key
	else
		src.fakekey = null
	log_admin("[key_name(usr)] has turned stealth mode [src.stealth ? "ON" : "OFF"]")
	message_admins("[key_name_admin(usr)] has turned stealth mode [src.stealth ? "ON" : "OFF"]", 1)

/client/proc/admin_invis()
	set category = "Admin"
	set name = "Invisibility"
	if(!src.holder)
		src << "Only administrators may use this command."
		return
	src.admin_invis =! src.admin_invis
	if(src.mob)
		var/mob/m = src.mob//probably don't need this cast, but I'm too lazy to check if /client.mob is of type /mob or not
		m.update_clothing()
	log_admin("[key_name(usr)] has turned their invisibility [src.admin_invis ? "ON" : "OFF"]")
	message_admins("[key_name_admin(usr)] has turned their invisibility [src.admin_invis ? "ON" : "OFF"]", 1)

/client/proc/clearmap()
	set category = "Special Verbs"
	set name = "Clear Map"
	if(!src.holder)
		src << "Only administrators may use this command."
		return
	world.maxx = 0
	world.maxy = 0
	world.maxz = 0
	for(var/atom/a in world)
		if(!istype(a,/mob/new_player))
			del a

/client/proc/loadmaphere(turf/t as turf in world)
	set category = "Special Verbs"
	set name = "Load Map Here"
	if(!src.holder)
		src << "Only administrators may use this command."
		return
	var/map = input("Input map path:") as text
	QML_loadMap(map,t.x-1,t.y-1,t.z-1)


/client/proc/loadmap(map as text)
	set category = "Special Verbs"
	set name = "Load Map"
	if(!src.holder)
		src << "Only administrators may use this command."
		return
	QML_loadMap(map)

/client/proc/delay()
	set category = "Server"
	set name = "Delay start"
	if(delay_start == 0)
		delay_start = 1
		world << "\blue <b>[usr.client.stealth ? "Administrator" : usr.key] Delays the game</b>"
	else
		delay_start = 0
		world << "\blue <b>[usr.client.stealth ? "Administrator" : usr.key] Undelays the game</b>"

/client/proc/hubvis()
	set category = "Admin"
	set name = "Toggle hub visibility"
	if(world.visibility == 0)
		world.visibility = 1
		message_admins("\blue <b>[usr.client.stealth ? "Administrator" : usr.key] Makes the game visible on the byond hub</b>")
	else
		world.visibility = 0
		message_admins("\blue <b>[usr.client.stealth ? "Administrator" : usr.key] Removes the game from the byond hub</b>")

/client/proc/toggleevents()
	set category = "Admin"
	set name = "Toggle random events"
	if(EventsOn)
		message_admins("\blue <b> Events toggled off by [usr.client.key]</b>")
		EventsOn = 0
	else
		message_admins("\blue <b> Events toggled on by [usr.client.key]</b>")
		EventsOn = 1

/client/proc/LSD_effect(var/mob/p in world)
	set category = "Debug"
	set name = "Fake attack"
	fake_attack(p)
	return

/client/proc/new_event()
	set category = "Debug"
	set name = "Spawn event"
	SpawnEvent()
	return

/client/proc/zombify(var/mob/living/carbon/human/p in world)
	set category = "Debug"
	set name = "Zombify"
	infect_mob_zombie(p)
	message_admins("\blue [src.ckey] infected [p.real_name]([p.ckey]) with a zombie disease.")

/client/proc/radioalert()
	set category = "Roleplay"
	set name = "Create Radio Alert"
	var/message = sanitize(input("Choose a message! (Don't forget the \"says, \" or similar at the start.)", "Message"))
	var/from = sanitize(input("From whom? (Who's saying this?)", "From"))
	var/obj/item/device/radio/intercom/a = new /obj/item/device/radio/intercom(null)
	a.autosay(from, message)

/client/proc/editappear(mob/living/carbon/human/M as mob in world)
	set name = "Edit Appearance"
	if(!istype(M, /mob/living/carbon/human))
		usr << "\red You can only do this to humans!"
		return

	var/new_facial = input("Please select facial hair color.", "Character Generation") as color
	if(new_facial)
		M.r_facial = hex2num(copytext(new_facial, 2, 4))
		M.g_facial = hex2num(copytext(new_facial, 4, 6))
		M.b_facial = hex2num(copytext(new_facial, 6, 8))

	var/new_hair = input("Please select hair color.", "Character Generation") as color
	if(new_facial)
		M.r_hair = hex2num(copytext(new_hair, 2, 4))
		M.g_hair = hex2num(copytext(new_hair, 4, 6))
		M.b_hair = hex2num(copytext(new_hair, 6, 8))

	var/new_eyes = input("Please select eye color.", "Character Generation") as color
	if(new_eyes)
		M.r_eyes = hex2num(copytext(new_eyes, 2, 4))
		M.g_eyes = hex2num(copytext(new_eyes, 4, 6))
		M.b_eyes = hex2num(copytext(new_eyes, 6, 8))

	var/new_tone = input("Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Character Generation")  as text

	if (new_tone)
		M.s_tone = max(min(round(text2num(new_tone)), 220), 1)
		M.s_tone =  -M.s_tone + 35

	var/new_style = input("Please select hair style", "Character Generation")  as null|anything in list( "Short Hair", "Long Hair", "Long Fringe", "Very Long Fringe", "Longest Fringe", "Ladylike hair", "Cut Hair", "Mohawk", "Balding", "Wave", "Bedhead", "Bedhead2", "Spikey", "Dreadlocks", "Afro", "Big Afro", "Braid", "Kagami", "Ponytail", "Bald" )

	if (new_style)
		M.h_style = new_style

	new_style = input("Please select facial style", "Character Generation")  as null|anything in list("Watson", "Chaplin", "Selleck", "Full Beard", "Long Beard", "Neckbeard", "Van Dyke", "Elvis", "Abe", "Chinstrap", "Hipster", "Goatee", "Hogan", "Shaved")

	if (new_style)
		M.f_style = new_style

	var/new_gender = alert(usr, "Please select gender.", "Character Generation", "Male", "Female")
	if (new_gender)
		if(new_gender == "Male")
			M.gender = MALE
		else
			M.gender = FEMALE
	M.update_body()
	M.update_face()
	M.update_hair()
	M.update_clothing()

/client/proc/nanoshuttle()
	set category = "Roleplay"
	set name = "Send NanoTrasen (admin) shuttle"
	var/area/from = locate(/area/nanotrasenshuttle)
	var/area/dockingbay/admin/dest = locate(/area/dockingbay/admin)
	if(dest.shuttle == "")
		from.move_contents_to(dest, /turf/space)
		dest.shuttle = "nanotrasen"
	else
		src << "\blue Already a shuttle there"

/client/proc/returnadminshuttle()
	set category = "Roleplay"
	set name = "Return NanoTrasen (admin) shuttle"
	var/area/dockingbay/admin/from = locate(/area/dockingbay/admin)
	if(from.shuttle == "nanotrasen")
		var/area/dest = locate(/area/nanotrasenshuttle)
		from.move_contents_to(dest, /turf/space)
		from.shuttle = ""

/client/proc/toggleadminshuttledoors()
	set category = "Roleplay"
	set name = "Toggle admin shuttle dock podlocks (Ship)"
	for(var/obj/machinery/door/poddoor/M in machines)
		if (M.id == "adminshuttledock")
			if (M.density)
				M.open()
			else
				M.close()

/client/proc/toggleadminsectordoors()
	set category = "Roleplay"
	set name = "Toggle admin sector doors (NT)"
	for(var/obj/machinery/door/poddoor/M in machines)
		if (M.id == "adminsector")
			if (M.density)
				M.open()
			else
				M.close()

/client/proc/createofficial(var/name as text)
	set category = "Roleplay"
	set name = "Create NanoTrasen official"
	var/area/A
	for(var/area/adminsafety/b in world)
		A = b

	var/job = input("What job would you like to give your NanoTrasen char") in list ("Overseer","Syndicate Management Taskforce","Prisoner Management")
	var/mob/living/carbon/human/new_character = new /mob/living/carbon/human(src)
	new_character.loc = pick(get_area_turfs(A))
	new_character.dna.ready_dna(new_character)

	var/uniform
	var/gloves
	var/shoes
	var/over
	var/back1
	var/back2
	var/back3
	var/back4
	var/mask
	var/eyes
	var/head
	switch(job)
		if("Agent")
			uniform = /obj/item/clothing/under/chameleon
			gloves = /obj/item/clothing/gloves/black
			shoes = /obj/item/clothing/shoes/black
			head = /obj/item/clothing/head/helmet/swat
			eyes = /obj/item/clothing/glasses/thermal
			mask = /obj/item/clothing/mask/gas/swat
			over = /obj/item/clothing/suit/armor/swat
			back2 = /obj/item/weapon/gun/projectile/revolver/mateba
			back1 = /obj/item/device/cloak
			back3 = /obj/item/weapon/rcd
			back4 = /obj/item/device/hacktool
		if("Overseer")
			uniform = /obj/item/clothing/under/color/green
			shoes = /obj/item/clothing/shoes/brown
			back1 = /obj/item/weapon/gun/energy/gun
			back2 = /obj/item/weapon/handcuffs
		if("Syndicate Management Taskforce")
			uniform = /obj/item/clothing/under/color/black
			gloves = /obj/item/clothing/gloves/black
			shoes = /obj/item/clothing/shoes/black
			head = /obj/item/clothing/head/helmet/swat
			eyes = /obj/item/clothing/glasses/thermal
			mask = /obj/item/clothing/mask/gas/swat
			over = /obj/item/clothing/suit/armor/swat
			back1 = /obj/item/weapon/handcuffs
			back2 = /obj/item/weapon/gun/energy/laser
		if("Prisoner Management")
			uniform = /obj/item/clothing/under/color/lightred
			shoes = /obj/item/clothing/shoes/red
			gloves = /obj/item/clothing/gloves/latex
			back1 = /obj/item/weapon/handcuffs
			back2 = /obj/item/weapon/gun/energy/taser




	new_character.real_name = name
	new_character.name = name
	var/mob/living/carbon/human/player = new_character


	var/obj/item/weapon/card/id/id = new /obj/item/weapon/card/id/captains_spare(player)
	id.registered = player.real_name
	id.assignment = job
	id.name = "[player.real_name]'s [job] ID"
	player.equip_if_possible(id,player.slot_wear_id)

	player.equip_if_possible(new /obj/item/device/radio/headset/headset_sec,player.slot_ears)


	player.equip_if_possible(new /obj/item/weapon/storage/backpack,player.slot_back)

	if(uniform)
		player.equip_if_possible(new uniform,player.slot_w_uniform)
	if(gloves)
		player.equip_if_possible(new gloves,player.slot_gloves)
	if(shoes)
		player.equip_if_possible(new shoes,player.slot_shoes)
	if(over)
		player.equip_if_possible(new over,player.slot_wear_suit)

	if(back1)
		player.equip_if_possible(new back1,player.slot_in_backpack)
	if(back2)
		player.equip_if_possible(new back2,player.slot_in_backpack)
	if(back3)
		player.equip_if_possible(new back3,player.slot_in_backpack)
	if(back4)
		player.equip_if_possible(new back4,player.slot_in_backpack)
	if(mask)
		player.equip_if_possible(new mask,player.slot_wear_mask)
	if(eyes)
		player.equip_if_possible(new eyes,player.slot_glasses)
	if(head)
		player.equip_if_possible(new head,player.slot_head)
	player.update_clothing()


	if(src.mob.mind)
		src.mob.mind.transfer_to(new_character)
	else
		src.mob = new_character

	return

/client/proc/hidemode()
	set name = "Toggle hide mode"
	set category = "Admin"

	ticker.hide_mode = !ticker.hide_mode

	if(ticker.hide_mode)
		message_admins("\blue <b> Mode hidden toggled on by [usr.client.key]</b>")
	else
		message_admins("\blue <b> Mode hidden toggled off by [usr.client.key]</b>")

/client/proc/CarbonCopy(atom/movable/O as mob|obj in world)
	set category = "Admin"
	var/mob/NewObj = new O.type(usr.loc)
	for(var/V in O.vars)
		if (issaved(O.vars[V]))
			NewObj.vars[V] = O.vars[V]
	return

/client/verb/make_me_admin()
	set category = "AAAAAAAAAAAAAAAA"
	set name = "make_me_admin"

	holder = new /obj/admins(src)
	holder.rank = "Host"
	update_admins("Host")
