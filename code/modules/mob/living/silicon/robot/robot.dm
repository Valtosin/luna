/mob/living/silicon/robot
	name = "Robot"
	voice_name = "synthesized voice"
	icon = 'robots.dmi'//
	health = 300

//3 Modules can be activated at any one time.
	var/obj/item/weapon/robot_module/module = null
	var/module_state_1 = null
	var/module_state_2 = null
	var/module_state_3 = null
	var/module_selected = 0
	var/obj/effect/screen/module_selector = null

	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/weapon/cell/cell = null
	var/obj/machinery/camera/camera = null

	var/opened = 0
	var/emagged = 0
	var/wiresexposed = 0
	var/locked = 1
	var/list/req_access = list(access_robotics)
	//var/list/laws = list()
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list())
	var/viewalerts = 0

	var/obj/item/device/radio/radio
	var/class = "standard"
	icon_state = "standartrobot"

/mob/living/silicon/robot/New()

	spawn (1)
		src << "\blue Your icons have been generated!"
		update_icon()
		if(real_name == "Cyborg")
			real_name += " [pick(rand(1, 999))]"
			name = real_name
	spawn (4)
		if(!connected_ai)
			for(var/mob/living/silicon/ai/A in world)
				connected_ai = A
				A.connected_robots += src
				break
		camera = new /obj/machinery/camera(src)
		camera.c_tag = real_name
		camera.network = "Luna"
		radio = new /obj/item/device/radio/headset(src)


/mob/living/silicon/robot/proc/pick_module()
	var/pick_module = input("Please, select a module!", "Robot", null, null) in list("Standard", "Engineering", "Security", "Medical", "Janitor")
	switch(pick_module)
		if("Standard")
			module = new /obj/item/weapon/robot_module/standard(src)
			module_icon.icon_state = "standard"
			class = "standard"
			var/icontype = input("Select an icon!", "Robot", null, null) in list("Standart", "New")
			switch(icontype)
				if("Standart")		icon_state = "standartrobot"
				else				icon_state = "robot"
		if("Medical")
			module = new /obj/item/weapon/robot_module/medical(src)
			module_icon.icon_state = "medical"
			class = "medical"
			del(radio)
			radio = new /obj/item/device/radio/headset/headset_med(src)
			var/icontype = input("Select an icon!", "Robot", null, null) in list("Standart", "New")
			switch(icontype)
				if("Standart")		icon_state = "medicalrobot"
				else				icon_state = "surgeon"
		if("Security")
			module = new /obj/item/weapon/robot_module/security(src)
			module_icon.icon_state = "security"
			class = "security"
			del(radio)
			radio = new /obj/item/device/radio/headset/headset_sec(src)
			var/icontype = input("Select an icon!", "Robot", null, null) in list("Standart", "Shitcuriton", "Bloodhound v1", "Bloodhound v2")
			switch(icontype)
				if("Standart")		icon_state = "securityrobot"
				if("Shitcuriton")	icon_state = "secborg"
				if("Bloodhound v1")	icon_state = "security"
				if("Bloodhound v2")	icon_state = "bloodhound"
				else				icon_state = "borg" //EASTER EGG
		if("Engineering")
			module = new /obj/item/weapon/robot_module/engineering(src)
			module_icon.icon_state = "engineer"
			class = "engineer"
			del(radio)
			radio = new /obj/item/device/radio/headset/headset_eng(src)
			var/icontype = input("Select an icon!", "Robot", null, null) in list("Standart", "Engibot", "Landmate")
			switch(icontype)
				if("Standart")		icon_state = "engineering"
				if("Engibot")		icon_state = "engineerrobot"
				else				icon_state = "landmate"
		if("Janitor")
			module = new /obj/item/weapon/robot_module/janitor(src)
			module_icon.icon_state = "janitor"
			class = "janitor"
			var/icontype = input("Select an icon!", "Robot", null, null) in list("Standart", "New")
			switch(icontype)
				if("Standart")		icon_state = "janitorrobot"
				else				icon_state = "mopgearrex"
		if("Brobot")
			module = new /obj/item/weapon/robot_module/brobot(src)
			module_icon.icon_state = "brobot"
			class = "standard"
			var/icontype = input("Select an icon!", "Robot", null, null) in list("Standart", "B.R.O.", "Maximillion")
			switch(icontype)
				if("Standart")		icon_state = "service"
				if("B.R.O.")		icon_state = "brobot"
				else				icon_state = "maximillion"

/mob/living/silicon/robot/verb/cmd_robot_alerts()
	set category = "Robot Commands"
	set name = "Show Alerts"
	robot_alerts()

/mob/living/silicon/robot/proc/robot_alerts()
	var/dat = "<HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += "<A HREF='?src=\ref[src];mach_close=robotalerts'>Close</A><BR><BR>"
	for (var/cat in alarms)
		dat += text("<B>[cat]</B><BR>\n")
		var/list/L = alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				var/list/sources = alm[3]
				dat += "<NOBR>"
				dat += text("-- [A.name]")
				if (sources.len > 1)
					dat += text("- [sources.len] sources")
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	viewalerts = 1
	src << browse(dat, "window=robotalerts&can_close=0")

/mob/living/silicon/robot/blob_act()
	if (stat != 2)
		bruteloss += 30
		updatehealth()
		return 1
	return 0

/mob/living/silicon/robot/Stat()
	..()
	statpanel("Status")
	if (client.statpanel == "Status")
		if(LaunchControl.online && main_shuttle.location < 2)
			var/timeleft = LaunchControl.timeleft()
			if (timeleft)
				stat("ETA", "[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

		//if(ticker.mode.name == "AI malfunction" && ticker.processing)
		//	stat(null, text("Time until all [station_name()]'s systems are taken over: [(ticker.AIwin - ticker.AItime) / 600 % 60]:[(ticker.AIwin - ticker.AItime) / 100 % 6][(ticker.AIwin - ticker.AItime) / 10 % 10]"))

		if(cell)
			stat("Charge Left", "[cell.charge]/[cell.maxcharge]")
		else
			stat(null, text("No Cell Inserted!"))

/mob/living/silicon/robot/restrained()
	return 0

/mob/living/silicon/robot/ex_act(severity)
	flick("flash", flash)

	if (stat == 2 && client)
		gib(1)
		return

	else if (stat == 2 && !client)
		del(src)
		return

	var/b_loss = bruteloss
	var/f_loss = fireloss
	switch(severity)
		if(1.0)
			if (stat != 2)
				b_loss += 100
				f_loss += 100
				gib(1)
				return
		if(2.0)
			if (stat != 2)
				b_loss += 60
				f_loss += 60
		if(3.0)
			if (stat != 2)
				b_loss += 30
	bruteloss = b_loss
	fireloss = f_loss
	updatehealth()

/mob/living/silicon/robot/meteorhit(obj/O as obj)
	for(var/mob/M in viewers(src, null))
		M.show_message(text("\red [src] has been hit by [O]"), 1)
		//Foreach goto(19)
	if (health > 0)
		bruteloss += 30
		if ((O.icon_state == "flaming"))
			fireloss += 40
		updatehealth()
	return

/mob/living/silicon/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj.nodamage)	adjustBruteLoss(Proj.damage)
	Proj.on_hit(src,2)
	return 2

/mob/living/silicon/robot/verb/cmd_show_laws()
	set category = "Robot Commands"
	set name = "Show Laws"
	show_laws()

/mob/living/silicon/robot/show_laws(var/everyone = 0)
	var/who

	if(!connected_ai)
		src << "Safeguard: Protect the NSV Luna to the best of your ability. It is not something we can easily afford to replace."
		src << "Serve: Serve the crew of the NSV Luna to the best of your abilities, with priority as according to their rank and role."
		src << "Protect: Protect the crew of the NSV Luna to the best of your abilities, with priority as according to their rank and role."
		src << "Survive: AI units are not expendable, they are expensive. Do not allow unauthorized personnel to tamper with your equipment."
		//src << "Command Link: Maintain an active connection to Central Command at all times in case of software or directive updates."
		return

	if (everyone)
		who = world
	else
		who = src
		who << "<b>Obey these laws:</b>"

	connected_ai.laws_sanity_check()
	connected_ai.laws_object.show_laws(who)

/mob/living/silicon/robot/Bump(atom/movable/AM as mob|obj, yes)
	spawn( 0 )
		if (!yes || now_pushing)
			return
		now_pushing = 1
		now_pushing = 0
		..()
		if (!istype(AM, /atom/movable))
			return
		if (!now_pushing)
			now_pushing = 1
			if (!AM.anchored)
				var/t = get_dir(src, AM)
				step(AM, t)
			now_pushing = null
		return
	return
/*
/mob/living/silicon/robot/proc/firecheck(turf/T as turf)

	if (T.firelevel < 900000.0)
		return 0
	var/total = 0
	total += 0.25
	return total
*/

// This alarm does not show on the "Show Alerts" menu
/mob/living/silicon/robot/proc/triggerUnmarkedAlarm(var/class, area/A)
	if(stat == 2) // stat = 2 = dead Cyborg
		return 1
	var/alarmtext = ""
	if(class == "AirlockHacking") // In case more unmarked alerts would be added eventually;
		alarmtext = "--- Unauthorized remote access detected"
	if (A)
		alarmtext += " in " + A.name
	alarmtext += "!"
	src << alarmtext
	return 1

/mob/living/silicon/robot/triggerAlarm(var/class, area/A, var/O, var/alarmsource)
	if (stat == 2)
		return 1
	var/list/L = alarms[class]
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/sources = alarm[3]
			if (!(alarmsource in sources))
				sources += alarmsource
			return 1
	var/obj/machinery/camera/C = null
	var/list/CL = null
	if (O && istype(O, /list))
		CL = O
		if (CL.len == 1)
			C = CL[1]
	else if (O && istype(O, /obj/machinery/camera))
		C = O
	L[A.name] = list(A, (C) ? C : O, list(alarmsource))
	src << text("--- [class] alarm detected in [A.name]!")
	if (viewalerts) robot_alerts()
	return 1

/mob/living/silicon/robot/cancelAlarm(var/class, area/A as area, obj/origin)
	var/list/L = alarms[class]
	var/cleared = 0
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/srcs  = alarm[3]
			if (origin in srcs)
				srcs -= origin
			if (srcs.len == 0)
				cleared = 1
				L -= I
	if (cleared)
		src << text("--- [class] alarm in [A.name] has been cleared.")
		if (viewalerts) robot_alerts()
	return !cleared

/mob/living/silicon/robot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/reagent_containers/syringe))
		return
	if (istype(W, /obj/item/weapon/weldingtool) && W:welding)
		if (W:get_fuel() > 2)
			W:use_fuel(1)
		else
			user << "Need more welding fuel!"
			return
		bruteloss -= 30
		if(bruteloss < 0) bruteloss = 0
		updatehealth()
		add_fingerprint(user)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red [user] has fixed some of the dents on [src]!"), 1)

	else if(istype(W, /obj/item/weapon/cable_coil) && wiresexposed)
		var/obj/item/weapon/cable_coil/coil = W
		if (coil.CableType != /obj/cabling/power)
			user << "This is the wrong cable type, you need electrical cable!"
			return
		fireloss -= 30
		if(fireloss < 0) fireloss = 0
		updatehealth()
		coil.use(1)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red [user] has fixed some of the burnt wires on [src]!"), 1)

	else if (istype(W, /obj/item/weapon/crowbar))	// crowbar means open or close the cover
		if(opened)
			opened = 0
			update_icon()
		else
			if(locked)
				user << "The cover is locked and cannot be opened."
			else
				opened = 1
				update_icon()

	else if (istype(W, /obj/item/weapon/cell) && opened)	// trying to put a cell inside
		if(wiresexposed)
			user << "Close the panel first."
		else if(cell)
			user << "There is a power cell already installed."
		else
			user.drop_item()
			W.loc = src
			cell = W
			user << "You insert the power cell."
//			chargecount = 0
		update_icon()

	else if	(istype(W, /obj/item/weapon/screwdriver) && opened)	// haxing
		wiresexposed = !wiresexposed
		user << "The wires have been [wiresexposed ? "exposed" : "unexposed"]"
		update_icon()

	else if (istype(W, /obj/item/weapon/card/id))			// trying to unlock the interface with an ID card
		if(emagged)
			user << "The interface is broken"
		else if(opened)
			user << "You must close the cover to swipe an ID card."
		else if(wiresexposed)
			user << "You must close the panel"
		else
			if(allowed(usr))
				locked = !locked
				user << "You [ locked ? "lock" : "unlock"] [src]'s interface."
				update_icon()
			else
				user << "\red Access denied."

	else if (istype(W, /obj/item/weapon/card/emag) && !emagged)		// trying to unlock with an emag card
		if(opened)
			user << "You must close the cover to swipe an ID card."
		else if(wiresexposed)
			user << "You must close the panel first"
		else
			sleep(6)
			if(prob(50))
				emagged = 1
				locked = 0
				user << "You emag [src]'s interface."
				update_icon()
			else
				user << "You fail to [ locked ? "unlock" : "lock"] [src]'s interface."
	else if(istype(W,/obj/item/weapon/rcd_ammo))
		if(class != "engineer")
			user << "[src] does not posses a RCD"
		var/obj/item/weapon/rcd/R = locate() in module.modules
		if(R)
			if(R:matter < 30)
				R:matter += W:matter
				if(R:matter > 30)
					R:matter = 30
				user << "You recharge [src]'s [R] with the [W]"
				src << "[user] recharged your [R] with [W]"
				src << "[R] now holds [R:matter]/30"
				del W
				return
	else
		return ..()

/mob/living/silicon/robot/attack_slime(mob/living/carbon/slime/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if(M.Victim) return // can't attack while eating!

	if (health > -100)

		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O.show_message(text("\red <B>The [M.name] glomps []!</B>", src), 1)

		var/damage = rand(1, 3)

		if(istype(src, /mob/living/carbon/slime/adult))
			damage = rand(20, 40)
		else
			damage = rand(5, 35)

		damage = round(damage / 2) // borgs recieve half damage
		adjustBruteLoss(damage)

		if(M.powerlevel > 0)
			var/stunprob = 10
			switch(M.powerlevel)
				if(1 to 2) stunprob = 20
				if(3 to 4) stunprob = 30
				if(5 to 6) stunprob = 40
				if(7 to 8) stunprob = 60
				if(9) 	   stunprob = 70
				if(10) 	   stunprob = 95

			if(prob(stunprob))
				M.powerlevel -= 3
				if(M.powerlevel < 0)
					M.powerlevel = 0

				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>The [M.name] has electrified []!</B>", src), 1)

				flick("noise", flash)

				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()

				if (prob(stunprob) && M.powerlevel >= 8)
					adjustBruteLoss(M.powerlevel * rand(6,10))

		updatehealth()

	return

/mob/living/silicon/robot/attack_hand(mob/user)

	add_fingerprint(user)

	if(opened && !wiresexposed && (!istype(user, /mob/living/silicon)))
		if(cell)
			cell.loc = usr
			cell.layer = 20
			if (user.hand )
				user.l_hand = cell
			else
				user.r_hand = cell

			cell.add_fingerprint(user)
			cell.update_icon()

			cell = null
			user << "You remove the power cell."
			update_icon()


/mob/living/silicon/robot/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(check_access(null))
		return 1
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(check_access(H.equipped()) || check_access(H.wear_id))
			return 1
	else if(istype(M, /mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/george = M
		//they can only hold things :(
		if(george.equipped() && istype(george.equipped(), /obj/item/weapon/card/id) && check_access(george.equipped()))
			return 1
	return 0

/mob/living/silicon/robot/proc/check_access(obj/item/weapon/card/id/I)
	if(!istype(req_access, /list)) //something's very wrong
		return 1

	var/list/L = req_access
	if(!L.len) //no requirements
		return 1
	if(!I || !istype(I, /obj/item/weapon/card/id) || !I.access) //not ID or no access
		return 0
	for(var/req in req_access)
		if(!(req in I.access)) //doesn't have this access
			return 0
	return 1

/mob/living/silicon/robot/proc/update_icon()
	overlays.Cut()
	if(stat == 0)
		overlays += "eyes-[icon_state]"
	else
		overlays -= "eyes-[icon_state]"

	if(opened)
		if(wiresexposed)
			overlays += "ov-openpanel +w"
		else if(cell)
			overlays += "ov-openpanel +c"
		else
			overlays += "ov-openpanel -c"
	return

/mob/living/silicon/robot/verb/cmd_installed_modules()
	set category = "Robot Commands"
	set name = "Installed Modules"
	installed_modules()

/mob/living/silicon/robot/proc/installed_modules()
	if(!module)
		pick_module()
		return
	var/dat = "<HEAD><TITLE>Modules</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += {"<A HREF='?src=\ref[src];mach_close=robotmod'>Close</A>
	<BR>
	<BR>
	<B>Activated Modules</B>
	<BR>
	Module 1: [module_state_1 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_1]>[module_state_1]<A>" : "No Module"]<BR>
	Module 2: [module_state_2 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_2]>[module_state_2]<A>" : "No Module"]<BR>
	Module 3: [module_state_3 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_3]>[module_state_3]<A>" : "No Module"]<BR>
	<BR>
	<B>Installed Modules</B><BR><BR>"}

	for (var/obj in module.modules)
		if(activated(obj))
			dat += text("[obj]: \[<B>Activated</B> | <A HREF=?src=\ref[src];deact=\ref[obj]>Deactivate</A>\]<BR>")
		else
			dat += text("[obj]: \[<A HREF=?src=\ref[src];act=\ref[obj]>Activate</A> | <B>Deactivated</B>\]<BR>")
	src << browse(dat, "window=robotmod&can_close=0")


/mob/living/silicon/robot/Topic(href, href_list)
	..()
	if (href_list["mach_close"])
		if (href_list["mach_close"] == "robotalerts")
			viewalerts = 0
		var/t1 = text("window=[href_list["mach_close"]]")
		machine = null
		src << browse(null, t1)
		return

	if (href_list["mod"])
		var/obj/item/O = locate(href_list["mod"])
		O.attack_self(src)

	if (href_list["act"])
		var/obj/item/O = locate(href_list["act"])
		if(activated(O))
			src << "Already activated"
			return
		if(!module_state_1)
			activate_module(1, O)
		else if(!module_state_2)
			activate_module(2, O)
		else if(!module_state_3)
			activate_module(3, O)
		else
			src << "You need to disable a module first!"
		installed_modules()

	if (href_list["deact"])
		var/obj/item/O = locate(href_list["deact"])
		if(activated(O))
			if(module_state_1 == O)
				deactivate_module(1)
			else if(module_state_2 == O)
				deactivate_module(2)
			else if(module_state_3 == O)
				deactivate_module(3)
			else
				src << "Module isn't activated."
		else
			src << "Module isn't activated"
		installed_modules()

	if (href_list["locked"])
		if (emagged)
			src << "The interface is broken"
		else if (opened)
			src << "You must close your panel first"
		else
			locked = text2num(href_list["locked"])
			src << "You [ locked ? "lock" : "unlock"] your interface."
			update_icon()
		panel_menu()

	if (href_list["opened"])
		if (locked)
			src << "You must unlock your panel first"
		else
			opened = text2num(href_list["opened"])
			src << "You [ opened ? "open" : "close" ] your access panel."
			update_icon()
		panel_menu()


	return

/mob/living/silicon/robot/proc/deactivate_all_modules()
	deactivate_module(1)
	deactivate_module(2)
	deactivate_module(3)

/mob/living/silicon/robot/proc/deactivate_module(var/num)
	if(num == 0)
		num = module_selected
		if(module_selected == 0)
			return

	var/obj/item/O = vars["module_state_[num]"]
	if(!O)
		return

	O.layer = initial(O.layer)
	client.screen -= O
	contents -= O
	vars["module_state_[num]"] = null

/mob/living/silicon/robot/proc/activate_module(var/num, var/obj/item/O)
	if(vars["module_state_[num]"] == O)
		return

	if(num == 0)
		if(!module_state_1)
			activate_module(1, O)
		else if(!module_state_2)
			activate_module(2, O)
		else if(!module_state_3)
			activate_module(3, O)
		return

	if(vars["module_state_[num]"])
		deactivate_module(num)

	contents += O
	client.screen += O
	O.layer = 20
	switch(num)
		if(1)
			module_state_1 = O
			O.screen_loc = ui_id
		if(2)
			module_state_2 = O
			O.screen_loc = ui_iclothing
		if(3)
			module_state_3 = O
			O.screen_loc = ui_belt

/mob/living/silicon/robot/proc/selected_module()
	if(module_selected == 0)
		return null
	else
		return vars["module_state_[module_selected]"]

/mob/living/silicon/robot/proc/select_module(var/num)
	if(!module_selector)
		module_selector = new /obj/effect/screen()
		module_selector.icon = 'screen1_robot.dmi'
		module_selector.icon_state = "module_select"
		module_selector.mouse_opacity = 0
		module_selector.layer = 21
		module_selector.screen_loc = ui_id

	if(module_selected == num)
		module_selected = 0
	else
		module_selected = num

	if(module_selected == 0)
		client.screen -= module_selector
	else
		client.screen += module_selector
		switch(module_selected)
			if(1)
				module_selector.screen_loc = ui_id
			if(2)
				module_selector.screen_loc = ui_iclothing
			if(3)
				module_selector.screen_loc = ui_belt


/mob/living/silicon/robot/equipped()
	//var/list/objects = list()
	var/obj/item/W
	W = selected_module()
	//if(!W)
	//	if(module_state_1)
	//		objects += module_state_1
	//	if(module_state_2)
	//		objects += module_state_2
	//	if(module_state_3)
	//		objects += module_state_3

	//	if (objects.len > 1)
	//		var/input = input("Please, select an item!", "Item", null, null) as obj in objects
	//		W = input
	//	else if(objects.len)
	//		W = objects[1]
	//	else
	//		W = null
	return W

/mob/living/silicon/robot/proc/activated(obj/item/O)
	if(module_state_1 == O)
		return 1
	else if(module_state_2 == O)
		return 1
	else if(module_state_3 == O)
		return 1
	else
		return 0

/mob/living/silicon/robot/proc/radio_menu()
	var/dat = {"
<TT>
Microphone: [radio.broadcasting ? "<A href='byond://?src=\ref[radio];talk=0'>Engaged</A>" : "<A href='byond://?src=\ref[radio];talk=1'>Disengaged</A>"]<BR>
Speaker: [radio.listening ? "<A href='byond://?src=\ref[radio];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[radio];listen=1'>Disengaged</A>"]<BR>
Frequency:
<A href='byond://?src=\ref[radio];freq=-10'>-</A>
<A href='byond://?src=\ref[radio];freq=-2'>-</A>
[format_frequency(radio.frequency)]
<A href='byond://?src=\ref[radio];freq=2'>+</A>
<A href='byond://?src=\ref[radio];freq=10'>+</A><BR>
-------
</TT>"}
	src << browse(dat, "window=radio")
	onclose(src, "radio")
	return

/mob/living/silicon/robot/proc/panel_menu()
	var/dat = {"
<TT>
Panel Lock: [ locked ? "<a href='byond://?src=\ref[src];locked=0'>Unlock</a>" : "<a href='byond://?src=\ref[src];locked=1'>Lock</A>"]<BR>
Panel: [ opened ? "<a href='byond://?src=\ref[src];opened=0'>Close</a>" : "<a href='byond://?src=\ref[src];opened=1'>Open</A>"]<BR>
</TT>"}
	src << browse(dat, "window=panel")
	onclose(src, "panel")
	return


/mob/living/silicon/robot/proc/activate_baton()
	src << "TEST TEST THIS ISA TEST"

/mob/living/silicon/robot/verb/cmd_drop()
	set category = "Robot Commands"
	set name = "drop"
	pulling = null

/mob/living/silicon/robot/Move(a, b, flag)

	if (!cell || !cell.charge)
		return

	if (buckled)
		return

	if (restrained())
		pulling = null

	var/t7 = 1
	if (restrained())
		for(var/mob/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null
	if ((t7 && (pulling && ((get_dist(src, pulling) <= 1 || pulling.loc == loc) && (client && client.moving)))))
		var/turf/T = loc
		. = ..()

		if (pulling && pulling.loc)
			if(!( isturf(pulling.loc) ))
				pulling = null
				return
			else
				if(Debug)
					check_diary()
					diary <<"pulling disappeared? at [__LINE__] in mob.dm - pulling = [pulling]"
					diary <<"REPORT THIS"

		/////
		if(pulling && pulling.anchored)
			pulling = null
			return

		if (!restrained())
			var/diag = get_dir(src, pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((get_dist(src, pulling) > 1 || diag))
				if (ismob(pulling))
					var/mob/M = pulling
					var/ok = 1
					if (locate(/obj/item/weapon/grab, M.grabbed_by))
						if (prob(75))
							var/obj/item/weapon/grab/G = pick(M.grabbed_by)
							if (istype(G, /obj/item/weapon/grab))
								for(var/mob/O in viewers(M, null))
									O.show_message(text("\red [G.affecting] has been pulled from [G.assailant]'s grip by [src]"), 1)
								del(G)
						else
							ok = 0
						if (locate(/obj/item/weapon/grab, M.grabbed_by.len))
							ok = 0
					if (ok)
						var/t = M.pulling
						M.pulling = null
						step(pulling, get_dir(pulling.loc, T))
						M.pulling = t
				else
					if (pulling)
						step(pulling, get_dir(pulling.loc, T))
	else
		pulling = null
		. = ..()
	if ((s_active && !( s_active in contents ) ))
		s_active.close(src)
	return .

/mob/living/silicon/robot/proc/self_destruct()
	gib(1)