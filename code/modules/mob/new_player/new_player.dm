mob/new_player/proc/forcestart()
	set name = "forcestart"
	set hidden = 1
	ready = 1
mob/new_player
	anchored = 1

	var/datum/preferences/preferences
	var/ready = 0

	invisibility = 101

	density = 0
	stat = 2
	canmove = 0

	anchored = 1	//  don't get pushed around
	var/sound/startup = null

	Login()
		..()
		src.verbs += /mob/new_player/proc/forcestart
		if(!preferences)
			preferences = new

		if(!mind)
			mind = new
			mind.key = key
			mind.current = src
		spawn(25)
			new_player_panel()
		//src << "<b>We now have <a href='http://whoopshop.com/index.php/topic,1632.0.html'>guidelines</a>. Read them before playing or fear the wrath of the banhammer!"
		var/starting_loc = pick(newplayer_start)
		loc = starting_loc
		sight |= SEE_TURFS
		var/list/watch_locations = list()
		for(var/obj/effect/landmark/landmark in world)
			if(landmark.tag == "landmark*new_player")
				watch_locations += landmark.loc

		if(watch_locations.len>0)
			loc = pick(watch_locations)

		preferences.ShowChoices(src)

		startup = sound('intro.wma', volume = 50)
		spawn(25)
			src << startup

	//	src << sound('main.ogg', 0, 0, 0, 35)


	Logout()
		ready = 0
		..()
		return

	verb
		new_player_panel()
			set src = usr

			var/output = "<HR><B>New Player Options</B><BR><HR>"
			var/readiness
			if(ready) readiness = "<B>READY</B>"
			else readiness = "<B>NOT READY</B>"
			output += "STATUS: [readiness]<br>"
			output += "<br><a href='byond://?src=\ref[src];show_preferences=1'>Setup Character</A><BR><BR>"
			//if(istester(key))
			if(!ticker || ticker.current_state <= GAME_STATE_PREGAME)
				if(!ready)
					output += "<a href='byond://?src=\ref[src];ready=1'>Declare Ready</A><BR>"
				else
					output += "<a href='byond://?src=\ref[src];ready=0'>Undeclare Ready</A><BR>"
			else
				output += "<a href='byond://?src=\ref[src];manifest=1'>View the Crew Manifest</A><BR><BR>"
				output += "<a href='byond://?src=\ref[src];late_join=1'>Join Game!</A><BR>"

			output += "<BR><a href='byond://?src=\ref[src];observe=1'>Observe</A><BR>"

			if(!ticker || ticker.current_state <= GAME_STATE_PREGAME)
				src << browse(output,"window=playersetup;size=250x233;can_close=0")
			else
				src << browse(output,"window=playersetup;size=250x233;can_close=0") // Adding the "View the Crew Manifest" option to the size of the window
				// A nice interface makes for an appealing game :D
	Stat()
		..()

		statpanel("Lobby")
		if(client.statpanel=="Lobby" && ticker)
			if(ticker.hide_mode)
				stat("Game Mode:", "Secret")
			else
				stat("Game Mode:", "[master_mode]")

			if(ticker.current_state == GAME_STATE_PREGAME)
				stat(null, null)
				for(var/mob/new_player/player in world)
					stat(player.key, player.ready ? "(Playing)" : null)
				stat(null, null)

				stat("Time To Start:", ticker.pregame_timeleft)


	Topic(href, href_list[])
		if(href_list["show_preferences"])
			preferences.ShowChoices(src)
			return 1
		if(href_list["closemotd"])
			src << browse(null,"window=motd;")
		if(href_list["ready"])
			if(!ready)
				if(alert(src,"Are you sure want to be ready? This will lock-in your preferences.","Player Setup","Yes","No") == "Yes")
					ready = 1
			else if(ready)
				if(alert(src,"Are you dont want to be ready? This will un-lock your preferences.","Player Setup","Yes","No") == "Yes")
					ready = 0

		if(href_list["observe"])
			if(alert(src,"Are you sure you wish to observe? You will not be able to play this round!","Player Setup","Yes","No") == "Yes")
				var/mob/dead/observer/observer = new()

				close_spawn_windows()
				startup.status = SOUND_PAUSED
				src << startup
				var/obj/O = locate("landmark*Observer-Start")
				src << "\blue Now teleporting."
				observer.loc = O.loc
				observer.key = key
				if(preferences.be_random_name)
					preferences.randomize_name()
				observer.name = preferences.real_name
				observer.real_name = observer.name


				del(src)
				return 1

		if(href_list["late_join"])
			//LateChoices()
			if (!enter_allowed)
				usr << "\blue There is an administrative lock on entering the game!"
				return
			startup.status = SOUND_PAUSED
			src << startup
			AttemptLateSpawn("Unassigned", -1)

		if(href_list["manifest"])
			ViewManifest()

/*		if(href_list["SelectedJob"])
			if (!enter_allowed)
				usr << "\blue There is an administrative lock on entering the game!"
				return

			startup.status = SOUND_PAUSED
			src << startup

			switch(href_list["SelectedJob"])
				if ("1")
					AttemptLateSpawn("Captain", captainMax)
				if ("2")
					AttemptLateSpawn("Head of Security", hosMax)
				if ("3")
					AttemptLateSpawn("Head of Personnel", hopMax)
				if ("4")
					AttemptLateSpawn("Engineer", engineerMax)
				if ("5")
					AttemptLateSpawn("Barman", barmanMax)
				if ("6")
					AttemptLateSpawn("Scientist", scientistMax)
				if ("7")
					AttemptLateSpawn("Chemist", chemistMax)
				if ("8")
					AttemptLateSpawn("Geneticist", geneticistMax)
				if ("9")
					AttemptLateSpawn("Security Officer", securityMax)
				if ("10")
					AttemptLateSpawn("Medical Doctor", doctorMax)
				if ("11")
					AttemptLateSpawn("Atmospheric Technician", atmosMax)
				if ("12")
					AttemptLateSpawn("Detective", detectiveMax)
				if ("13")
					AttemptLateSpawn("Counselor", CounselorMax)
				if ("14")
					AttemptLateSpawn("Janitor", janitorMax)
				if ("15")
					AttemptLateSpawn("Clown", clownMax)
				if ("16")
					AttemptLateSpawn("Chef", chefMax)
				if ("17")
					AttemptLateSpawn("Roboticist", roboticsMax)
				if ("18")
					AttemptLateSpawn("Unassigned", -1)
				if ("19")
					AttemptLateSpawn("Quartermaster", cargoMax)
				if ("20")
					AttemptLateSpawn("Research Director", directorMax)
				if ("21")
					AttemptLateSpawn("Chief Engineer", chiefMax)
//				if ("22")
//					AttemptLateSpawn("Hydroponist", hydroponicsMax)
*/

		if(!ready && href_list["preferences"])
			preferences.process_link(src, href_list)
		else if(!href_list["late_join"])
			new_player_panel()

	proc/IsJobavailable(rank, maxAllowed)
		if((countJob(rank) < maxAllowed || maxAllowed == -1))
			return 1
		else
			return 0

	proc/AttemptLateSpawn(rank, maxAllowed)
		if(IsJobavailable(rank, maxAllowed))
			var/mob/living/carbon/human/character = create_character()

			character.Equip_Rank(rank, joined_late=1)

			//add to manifest
			for(var/datum/data/record/t in data_core.general)
				if((t.fields["name"] == character.real_name) && (t.fields["rank"] == "Unassigned"))
					t.fields["rank"] = rank

			if (ticker.current_state == GAME_STATE_PLAYING)
				if(rank == "Unassigned")
					radioalert("Arrivals Notice", "[character.real_name] has arrived on the ship.")	//unassigneds are not special
				else
					radioalert("Arrivals Notice", "[character.real_name], the [rank] has arrived on the ship..")	//oh no engineers

				/*for (var/mob/living/silicon/ai/A in world) // Use this if we want to revert to the AI announcing new arrivals
					if (!A.stat)
						A.say("[character.real_name] has signed up as [rank].")*/

			var/starting_loc = pick(latejoin)
			character.loc = starting_loc
			ticker.mode.latespawn(character)
			del(src)

		else
			src << alert("[rank] is not available. Please try another.")

	proc/create_character()
		startup.status = SOUND_PAUSED
		src << startup
		var/mob/living/carbon/human/new_character = new(loc)

		close_spawn_windows()

		ticker.minds += mind	//Strumpet - Add new players' minds to the ticker list to be used for traitor objectives.

		preferences.copy_to(new_character)
		new_character.dna.ready_dna(new_character)

		mind.transfer_to(new_character)


		return new_character

	proc/ViewManifest()
		var/dat = "<html><body>"
		dat += "<h4>Crew Manifest</h4>"
		for (var/datum/data/record/t in data_core.general)
			dat += "[t.fields["name"]] - [t.fields["rank"]]<br>"
		dat += "<br>"

		src << browse(dat, "window=manifest;size=300x420;can_close=1")

	Move()
		return 0


	proc/close_spawn_windows()
		src << browse(null, "window=latechoices") //closes late choices window
		src << browse(null, "window=playersetup") //closes the player setup window
		src << browse(null, "window=manifest") //closes the crew manifest window

/*
/obj/begin/verb/enter()
	log_game("[usr.key] entered as [usr.real_name]")

	if (ticker)
		for (var/mob/living/silicon/ai/A in world)
			if (!A.stat)
				A.say("[usr.real_name] has arrived on the station!")
				break

		usr << "<B>Game mode is [master_mode].</B>"

	var/mob/living/carbon/human/H = usr

//find spawn points for normal game modes

	if(!(ticker && ticker.mode.name == "ctf"))
		var/list/L = list()
		var/area/A = locate(/area/arrival/start)
		for(var/turf/T in A)
			L += T

		while(!L.len)
			usr << "\blue <B>You were unable to enter because the arrival shuttle has been destroyed! The game will reattempt to spawn you in 30 seconds!</B>"
			sleep(300)
			for(var/turf/T in A)
				L += T
		H << "\blue Now teleporting."
		H.loc = pick(L)

//for capture the flag

	else if(ticker && ticker.mode.name == "ctf")
		if(H.client.team == "Red")
			var/obj/R = locate("landmark*Red-Spawn")
			H << "\blue Now teleporting."
			H.loc = R.loc
		else if(H.client.team == "Green")
			var/obj/G = locate("landmark*Green-Spawn")
			H << "\blue Now teleporting."
			H.loc = G.loc

//error check

	else
		usr << "Invalid start please report this to the admins"

//add to manifest

	if(ticker)
		//add to manifest
		var/datum/data/record/G = new /datum/data/record(  )
		var/datum/data/record/M = new /datum/data/record(  )
		var/datum/data/record/S = new /datum/data/record(  )
		var/obj/item/weapon/card/id/C = H.wear_id
		if (C)
			G.fields["rank"] = C.assignment
		else
			G.fields["rank"] = "Unassigned"
		G.fields["name"] = H.real_name
		G.fields["id"] = text("[]", add_zero(num2hex(rand(1, 1.6777215E7)), 6))
		M.fields["name"] = G.fields["name"]
		M.fields["id"] = G.fields["id"]
		S.fields["name"] = G.fields["name"]
		S.fields["id"] = G.fields["id"]
		if (H.gender == "female")
			G.fields["sex"] = "Female"
		else
			G.fields["sex"] = "Male"
		G.fields["age"] = text("[]", H.age)
		G.fields["fingerprint"] = text("[]", md5(H.dna.uni_identity))
		G.fields["p_stat"] = "Active"
		G.fields["m_stat"] = "Stable"
		M.fields["b_type"] = text("[]", H.b_type)
		M.fields["mi_dis"] = "None"
		M.fields["mi_dis_d"] = "No minor disabilities have been declared."
		M.fields["ma_dis"] = "None"
		M.fields["ma_dis_d"] = "No major disabilities have been diagnosed."
		M.fields["alg"] = "None"
		M.fields["alg_d"] = "No allergies have been detected in this patient."
		M.fields["cdi"] = "None"
		M.fields["cdi_d"] = "No diseases have been diagnosed at the moment."
		M.fields["notes"] = "No notes."
		S.fields["criminal"] = "None"
		S.fields["mi_crim"] = "None"
		S.fields["mi_crim_d"] = "No minor crime convictions."
		S.fields["ma_crim"] = "None"
		S.fields["ma_crim_d"] = "No minor crime convictions."
		S.fields["notes"] = "No notes."
		for(var/obj/datacore/D in world)
			D.general += G
			D.medical += M
			D.security += S
//DNA!
		reg_dna[H.dna.unique_enzymes] = H.real_name
//Other Stuff
		if(ticker.mode.name == "Sandbox")
			H.CanBuild()

*/
/*
	say(var/message)
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

		if (!message)
			return

		log_say("[key] : [message]")

		if (muted)
			return

		. = say_dead(message)
*/