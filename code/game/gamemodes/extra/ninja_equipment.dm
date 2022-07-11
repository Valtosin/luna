//===================================SPESS NINJA STUFF===================================

//SUIT===================================

/obj/item/clothing/suit/space/space_ninja/New()
	..()
	src.verbs += /obj/item/clothing/suit/space/space_ninja/proc/init//suit initialize verb
	spark_system = new /datum/effects/system/spark_spread()//spark initialize
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	var/datum/reagents/R = new/datum/reagents(480)//reagent initialize
	reagents = R
	R.my_atom = src
	reagents.add_reagent("tricordrazine", 80)
	reagents.add_reagent("dexalinp", 80)
	reagents.add_reagent("spaceacillin", 80)
	reagents.add_reagent("anti_toxin", 80)
	reagents.add_reagent("radium", 80)
	reagents.add_reagent("nutriment", 80)

/obj/item/clothing/suit/space/space_ninja/proc/ntick(var/mob/living/carbon/human/U as mob)
	set hidden = 1
	set background = 1

	spawn while(initialize&&charge>=0)//Suit on and has power.
		if(!initialize)	return//When turned off the proc stops.
		var/A = 5//Energy cost each tick.
		if(!kamikaze)
			if(istype(U.get_active_hand(), /obj/item/weapon/blade))//Sword check.
				if(charge<=0)//If no charge left.
					U.drop_item()//Sword is dropped from active hand (and deleted).
				else	A += 20//Otherwise, more energy consumption.
			else if(istype(U.get_inactive_hand(), /obj/item/weapon/blade))
				if(charge<=0)
					U.swap_hand()//swap hand
					U.drop_item()//drop sword
				else	A += 20
			if(active)
				A += 25
		else
			if(prob(25))
				U.bruteloss += 1
			A = 200
		charge-=A
		if(charge<0)
			if(kamikaze)
				U.say("I DIE TO LIVE AGAIN!")
				U.death()
				return
			charge=0
			active=0
		sleep(10)//Checks every second.

/obj/item/clothing/suit/space/space_ninja/proc/init()
	set name = "Initialize Suit"
	set desc = "Initializes the suit for field operation."
	set category = "Object"

	if(usr.mind&&usr.mind.special_role=="Space Ninja"&&usr:wear_suit==src&&!src.initialize)
		var/mob/living/carbon/human/U = usr
		verbs -= /obj/item/clothing/suit/space/space_ninja/proc/init
		U << "\blue Now initializing..."
		sleep(40)
		if(U.mind.assigned_role=="Mime")
			U << "\red <B>FATAL ERROR</B>: 382200-*#00CODE <B>RED</B>\nUNAUTHORIZED USE DETECTED\nCOMMENCING SUB-R0UTIN3 13...\nTERMINATING U-U-USER..."
			U.gib()
			return
		if(!istype(U.head, /obj/item/clothing/head/helmet/space/space_ninja))
			U << "\red <B>ERROR</B>: 100113 UNABLE TO LOCATE HEAD GEAR\nABORTING..."
			return
		if(!istype(U.shoes, /obj/item/clothing/shoes/space_ninja))
			U << "\red <B>ERROR</B>: 122011 UNABLE TO LOCATE FOOT GEAR\nABORTING..."
			return
		if(!istype(U.gloves, /obj/item/clothing/gloves/space_ninja))
			U << "\red <B>ERROR</B>: 110223 UNABLE TO LOCATE HAND GEAR\nABORTING..."
			return
		U << "\blue Securing external locking mechanism...\nNeural-net established."
		U.head:canremove=0
		U.shoes:canremove=0
		U.gloves:canremove=0
		canremove=0
		sleep(40)
		U << "\blue Extending neural-net interface...\nNow monitoring brain wave pattern..."
		sleep(40)
		if(U.stat==2||U.health<=0)
			U << "\red <B>FATAL ERROR</B>: 344--93#&&21 BRAIN WAV3 PATT$RN <B>RED</B>\nA-A-AB0RTING..."
			U.head:canremove=1
			U.shoes:canremove=1
			U.gloves:canremove=1
			canremove=1
			verbs += /obj/item/clothing/suit/space/space_ninja/proc/init
			return
		U << "\blue Linking neural-net interface...\nPattern \green <B>GREEN</B>\blue, continuing operation."
		sleep(40)
		U << "\blue VOID-shift device status: <B>ONLINE</B>.\nCLOAK-tech device status: <B>ONLINE</B>."
		sleep(40)
		U << "\blue Primary system status: <B>ONLINE</B>.\nBackup system status: <B>ONLINE</B>.\nCurrent energy capacity: <B>[src.charge]</B>."
		sleep(40)
		U << "\blue All systems operational. Welcome to <B>SpiderOS</B>, [U.real_name]."
		U.verbs += /mob/proc/ninjashift
		U.verbs += /mob/proc/ninjajaunt
		U.verbs += /mob/proc/ninjasmoke
		U.verbs += /mob/proc/ninjaboost
		U.verbs += /mob/proc/ninjapulse
		U.verbs += /mob/proc/ninjablade
		U.verbs += /mob/proc/ninjastar
		U.mind.special_verbs += /mob/proc/ninjashift
		U.mind.special_verbs += /mob/proc/ninjajaunt
		U.mind.special_verbs += /mob/proc/ninjasmoke
		U.mind.special_verbs += /mob/proc/ninjaboost
		U.mind.special_verbs += /mob/proc/ninjapulse
		U.mind.special_verbs += /mob/proc/ninjablade
		U.mind.special_verbs += /mob/proc/ninjastar
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/deinit
		verbs += /obj/item/clothing/suit/space/space_ninja/proc/spideros
		U.gloves.verbs += /obj/item/clothing/gloves/space_ninja/proc/drain_wire
		U.gloves.verbs += /obj/item/clothing/gloves/space_ninja/proc/toggled
		initialize=1
		affecting=U
		slowdown=0
		U.shoes:slowdown--
		ntick(usr)
	else
		if(usr.mind&&usr.mind.special_role=="Space Ninja")
			usr << "\red You do not understand how this suit functions."
		else if(usr:wear_suit!=src)
			usr << "\red You must be wearing the suit to use this function."
		else if(initialize)
			usr << "\red The suit is already functioning."
		else
			usr << "\red You cannot use this function at this time."
	return

/obj/item/clothing/suit/space/space_ninja/proc/deinit()
	set name = "De-Initialize Suit"
	set desc = "Begins procedure to remove the suit."
	set category = "Object"

	if(!initialize)
		usr << "\red The suit is not initialized."
		return
	if(alert("Are you certain you wish to remove the suit? This will take time and remove all abilities.",,"Yes","No")=="No")
		return

	var/mob/living/carbon/human/U = usr
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/deinit
	U << "\blue Now de-initializing..."
	if(kamikaze)
		U << "\blue Disengaging mode...\n\black<b>CODE NAME</b>: \red <b>KAMIKAZE</b>"
		U.verbs -= /mob/proc/ninjaslayer
		U.verbs -= /mob/proc/ninjawalk
		U.verbs -= /mob/proc/ninjamirage
		U.mind.special_verbs -= /mob/proc/ninjaslayer
		U.mind.special_verbs -= /mob/proc/ninjawalk
		U.mind.special_verbs -= /mob/proc/ninjamirage
		kamikaze = 0
		unlock = 0
		U.incorporeal_move = 0
		U.density = 1
		icon_state = "s-ninja"
	spideros = 0
	sleep(40)
	U.verbs -= /mob/proc/ninjashift
	U.verbs -= /mob/proc/ninjajaunt
	U.verbs -= /mob/proc/ninjasmoke
	U.verbs -= /mob/proc/ninjaboost
	U.verbs -= /mob/proc/ninjapulse
	U.verbs -= /mob/proc/ninjablade
	U.verbs -= /mob/proc/ninjastar
	U.mind.special_verbs -= /mob/proc/ninjashift
	U.mind.special_verbs -= /mob/proc/ninjajaunt
	U.mind.special_verbs -= /mob/proc/ninjasmoke
	U.mind.special_verbs -= /mob/proc/ninjaboost
	U.mind.special_verbs -= /mob/proc/ninjapulse
	U.mind.special_verbs -= /mob/proc/ninjablade
	U.mind.special_verbs -= /mob/proc/ninjastar
	U << "\blue Logging off, [U:real_name]. Shutting down <B>SpiderOS</B>."
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/spideros
	sleep(40)
	U << "\blue Primary system status: <B>OFFLINE</B>.\nBackup system status: <B>OFFLINE</B>."
	sleep(40)
	U << "\blue VOID-shift device status: <B>OFFLINE</B>.\nCLOAK-tech device status: <B>OFFLINE</B>."
	if(active)//Shutdowns stealth.
		active=0
	sleep(40)
	if(U.stat||U.health<=0)
		U << "\red <B>FATAL ERROR</B>: 412--GG##&77 BRAIN WAV3 PATT$RN <B>RED</B>\nI-I-INITIATING S-SELf DeStrCuCCCT%$#@@!!$^#!..."
		spawn(10)
			U << "\red #3#"
		spawn(20)
			U << "\red #2#"
		spawn(30)
			U << "\red #1#: <B>G00DBYE</B>"
			U.gib()
		return
	U << "\blue Disconnecting neural-net interface...\green<B>Success</B>\blue."
	sleep(40)
	U << "\blue Disengaging neural-net interface...\green<B>Success</B>\blue."
	sleep(40)
	if(istype(U.head, /obj/item/clothing/head/helmet/space/space_ninja))
		U.head.canremove=1
	if(istype(U.shoes, /obj/item/clothing/shoes/space_ninja))
		U.shoes:canremove=1
		U.shoes:slowdown++
	if(istype(U.gloves, /obj/item/clothing/gloves/space_ninja))
		U.gloves.icon_state = "s-ninja"
		U.gloves.item_state = "s-ninja"
		U.gloves:canremove=1
		U.gloves:candrain=0
		U.gloves:draining=0
		U.gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/drain_wire
		U.gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/toggled
	U.update_clothing()
	if(istype(U.get_active_hand(), /obj/item/weapon/blade))//Sword check.
		U.drop_item()
	if(istype(U.get_inactive_hand(), /obj/item/weapon/blade))
		U.swap_hand()
		U.drop_item()
	canremove=1
	U << "\blue Unsecuring external locking mechanism...\nNeural-net abolished.\nOperation status: <B>FINISHED</B>."
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/init
	initialize=0
	affecting=null
	slowdown=1
	return

/obj/item/clothing/suit/space/space_ninja/proc/spideros()
	set name = "Display SpiderOS"
	set desc = "Utilize built-in computer system."
	set category = "Object"

	var/mob/living/carbon/human/U = usr
	var/dat = "<html><head><title>SpiderOS</title></head><body bgcolor=\"#3D5B43\" text=\"#DB2929\"><style>a, a:link, a:visited, a:active, a:hover { color: #DB2929; }img {border-style:none;}</style>"
	/*Here is where you would create a link for the cartridge used if the item has one.
	As noted below, it's not worth the effort to make the cartridge removable unless it's done from the hub.*/
	if(spideros==0)
		dat += "<a href='byond://?src=\ref[src];choice=Refresh'><img src=sos_7.png> Refresh</a>"
	else
		dat += "<a href='byond://?src=\ref[src];choice=Refresh'><img src=sos_7.png> Refresh</a>"
		dat += " | <a href='byond://?src=\ref[src];choice=Return'><img src=sos_1.png> Return</a>"
	dat += " | <a href='byond://?src=\ref[src];choice=Close'><img src=sos_8.png> Close</a>"
	dat += "<br>"
	dat += "<h2 ALIGN=CENTER>SpiderOS v.1.337</h2>"
	dat += "Welcome, <b>[U.real_name]</b>.<br>"
	dat += "<br>"
	dat += "<img src=sos_10.png> Current Time: [round(world.time / 36000)+12]:[(world.time / 600 % 60) < 10 ? add_zero(world.time / 600 % 60, 1) : world.time / 600 % 60]<br>"
	dat += "<img src=sos_9.png> Battery Life: [round(charge/100)]%<br>"
	dat += "<img src=sos_11.png> Smoke Bombs: [sbombs]<br>"
	dat += "<br>"

	/*
	HOW TO USE OR ADAPT THIS CODE:
	The menu structure should not need to be altered to add new entries. Simply place them after what is already there.
	As an exception, if there are multiple-tiered windows, for instance, going into medical alerts and then to DNA testing or something,
	those menus should be added below their parents but have a greater value. The second sub-menu of menu 2 would have the number 22.
	Another sub-menu of menu 2 would be 23, then 24, and up to 29. If those menus have their own sub-menus a similar format follows.
	Sub-menu 1 of sub-menu 2(of menu 2) would be 221. Sub-menu 5 of sub-menu 2(of menu 2) would be 225. Menu 0 is a special case (it's the menu hub); you are free to use menus 1-9 (sub menus can be 0-9)
	to create your own data paths.
	The Return button, when used, simply removes the final number and navigates to the menu prior. Menu 334, the fourth sub-menu of sub-menu
	3, in menu 3, would navigate to sub menu 3 in menu 3. Or 33.
	It is possible to go to a different menu/sub-menu from anywhere. When creating new menus don't forget to add them to Topic proc or else the game
	will interpret you using the messenger function (the else clause in the switch).
	Other buttons and functions should be named according to what they do.*/
	switch(spideros)
		if(0)
			/*
			For items that use cartridges (PDAs), simply switch() their hub function based on the cartridge inserted.
			For ease of use, allow the removal of the cartidge only on the hub.
			*/
			dat += "<h4><img src=sos_1.png> Available Functions:</h4>"
			dat += "<ul>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Stealth'><img src=sos_4.png> Toggle Stealth: [active == 1 ? "Disable" : "Enable"]</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=1'><img src=sos_3.png> Medical Screen</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=2'><img src=sos_5.png> Atmos Scan</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=3'><img src=sos_12.png> Messenger</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=4'><img src=sos_6.png> Other</a></li>"
			dat += "</ul>"
		if(1)
			dat += "<h4><img src=sos_3.png> Medical Report:</h4>"
			if(U.dna)
				dat += "<b>Fingerprints</b>: <i>[md5(U.dna.uni_identity)]</i><br>"
				dat += "<b>Unique identity</b>: <i>[U.dna.unique_enzymes]</i><br>"
			dat += "<h4>Overall Status: [U.stat > 1 ? "dead" : "[U.health]% healthy"]</h4>"
			dat += "<h4>Nutrition Status: [U.nutrition]</h4>"
			dat += "Oxygen loss: [U.oxyloss]"
			dat += " | Toxin levels: [U.toxloss]<br>"
			dat += "Burn severity: [U.fireloss]"
			dat += " | Brute trauma: [U.bruteloss]<br>"
			dat += "Body Temperature: [U.bodytemperature-T0C]&deg;C ([U.bodytemperature*1.8-459.67]&deg;F)<br>"
			if(U.virus)
				dat += "Warning Virus Detected. Name: [U.virus.name].Type: [U.virus.spread]. Stage: [U.virus.stage]/[U.virus.max_stages]. Possible Cure: [U.virus.cure].<br>"
			dat += "<ul>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Dylovene'><img src=sos_2.png> Inject Dylovene: [reagents.get_reagent_amount("anti_toxin")/20] left</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Dexalin Plus'><img src=sos_2.png> Inject Dexalin Plus: [reagents.get_reagent_amount("dexalinp")/20] left</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Tricordazine'><img src=sos_2.png> Inject Tricordazine: [reagents.get_reagent_amount("tricordrazine")/20] left</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Spacelin'><img src=sos_2.png> Inject Spacelin: [reagents.get_reagent_amount("spaceacillin")/20] left</a></li>"
			dat += "<li><a href='byond://?src=\ref[src];choice=Nutriment'><img src=sos_2.png> Inject Nutriment: [reagents.get_reagent_amount("nutriment")/5] left</a></li>"//Special case since it's so freaking potent.
			dat += "</ul>"
		if(2)
			dat += "<h4><img src=sos_5.png>Atmospheric Scan:</h4>"//Headers don't need breaks. They are automatically placed.
			var/turf/T = get_turf_or_move(U.loc)
			if (isnull(T))
				dat += "Unable to obtain a reading."
			else
				var/datum/gas_mixture/environment = T.return_air()

				var/pressure = environment.return_pressure()
				var/total_moles = environment.total_moles()

				dat += "Air Pressure: [round(pressure,0.1)] kPa"

				if (total_moles)
					var/o2_level = environment.oxygen/total_moles
					var/n2_level = environment.nitrogen/total_moles
					var/co2_level = environment.carbon_dioxide/total_moles
					var/plasma_level = environment.toxins/total_moles
					var/unknown_level =  1-(o2_level+n2_level+co2_level+plasma_level)
					dat += "<ul>"
					dat += "<li>Nitrogen: [round(n2_level*100)]%</li>"
					dat += "<li>Oxygen: [round(o2_level*100)]%</li>"
					dat += "<li>Carbon Dioxide: [round(co2_level*100)]%</li>"
					dat += "<li>Plasma: [round(plasma_level*100)]%</li>"
					dat += "</ul>"
					if(unknown_level > 0.01)
						dat += "OTHER: [round(unknown_level)]%<br>"

					dat += "Temperature: [round(environment.temperature-T0C)]&deg;C"
		if(3)
			if(unlock==7)
				dat += "<a href='byond://?src=\ref[src];choice=32'><img src=sos_1.png> Hidden Menu</a>"
			dat += "<h4><img src=sos_12.png> Anonymous Messenger:</h4>"//Anonymous because the receiver will not know the sender's identity.
			dat += "<h4><img src=sos_6.png> Detected PDAs:</h4>"
			dat += "<ul>"
			var/count = 0
			for (var/obj/item/device/pda/P in world)
				if (!P.owner||P.toff)
					continue
				dat += "<li><a href='byond://?src=\ref[src];choice=\ref[P]'>[P]</a>"
				dat += "</li>"
				count++
			dat += "</ul>"
			if (count == 0)
				dat += "None detected.<br>"
			//dat += "<a href='byond://?src=\ref[src];choice=31'> Send Virus</a>
		if(32)
			dat += "<h4><img src=sos_1.png> Hidden Menu:</h4>"
			dat += "Please input password: "
			dat += "<a href='byond://?src=\ref[src];choice=Unlock Kamikaze'><b>HERE</b></a><br>"
			dat += "<br>"
			dat += "Remember, you will not be able to recharge energy during this function. If energy runs out, the suit will auto self-destruct.<br>"
			dat += "Use with caution. De-initialize the suit when energy is low."
		if(4)
			dat += "<h4><img src=sos_6.png> Ninja Manual:</h4>"
			dat += "<h5>Who they are:</h5>"
			dat += "Space ninjas are a special type of ninja, specifically one of the space-faring type. The vast majority of space ninjas belong to the Spider Clan, a cult-like sect, which has existed for several hundred years. The Spider Clan practice a sort of augmentation of human flesh in order to achieve a more perfect state of being and follow Postmodern Space Bushido. They also kill people for money. Their leaders are chosen from the oldest of the grand-masters, people that have lived a lot longer than any mortal man should.<br>Being a sect of technology-loving fanatics, the Spider Clan have the very best to choose from in terms of hardware--cybernetic implants, exoskeleton rigs, hyper-capacity batteries, and you get the idea. Some believe that much of the Spider Clan equipment is based on reverse-engineered alien technology while others doubt such claims.<br>Whatever the case, their technology is absolutely superb."
			dat += "<h5>How they relate to other SS13 organizations:</h5>"
			dat += "<ul>"
			dat += "<li>*<b>Nanotrasen</b> and the Syndicate are two sides of the same coin and that coin is valuable.</li>"
			dat += "<li>*<b>The Space Wizard Federation</b> is a problem, mainly because they are an extremely dangerous group of unpredictable individuals--not to mention the wizards hate technology and are in direct opposition of the Spider Clan. Best avoided or left well-enough alone.</li>"
			dat += "<li>*<b>Changeling Hivemind</b>: extremely dangerous and to be killed on sight.</li>"
			dat += "<li>*<b>Xeno Hivemind</b>: their skulls make interesting kitchen decorations and are challenging to best, especially in larger nests.</li>"
			dat += "</ul>"
			dat += "<h5>The reason they (you) are here</h5>:"
			dat += "Space ninjas are renowned throughout the known controlled space as fearless spies, infiltrators, and assassins. They are sent on missions of varying nature by Nanotrasen, the Syndicate, and other shady organizations and people. To hire a space ninja means serious business."
			dat += "<h5>Their playstyle:</h5>"
			dat += "A mix of traitor, changeling, and wizard. Ninjas rely on energy, or electricity to be precise, to keep their suits running (when out of energy, a suit hibernates). Suits gain energy from objects or creatures that contain electrical charge. APCs, cell batteries, SMES batteries, cyborgs, mechs, and exposed wires are currently supported. Through energy ninjas gain access to special powers--while all powers are tied to the ninja suit, the most useful of them are verb activated--to help them in their mission.<br>It is a constant struggle for a ninja to remain hidden long enough to recharge the suit and accomplish their objective; despite their arsenal of abilities, ninjas can die like any other. Unlike wizards, ninjas do not possess good crowd control and are typically forced to play more subdued in order to achieve their goals. Some of their abilities are specifically designed to confuse and disorient others.<br>With that said, it should be perfectly possible to completely flip the fuck out and rampage as a ninja."
			dat += "<h5>Their powers:</h5>"
			dat += "There are two primary types: powers that are activated through the suit and powers that are activated through the verb panel. Passive powers are always on. Active powers must be turned on and remain active only when there is energy to do so. All verb powers are active and their cost is listed next to them."
			dat += "<b>Powers of the suit</b>: cannot be tracked by AI (passive), faster speed (passive), stealth (active), vision switch (passive if toggled), voice masking (passive), SpiderOS (passive if toggled), energy drain (passive if toggled)."
			dat += "<ul>"
			dat += "<li><i>Voice masking</i> generates a random name the ninja can use over the radio and in-person. Although, the former use is recommended.</li>"
			dat += "<li><i>Toggling vision</i> cycles to one of the following: thermal, meson, or darkness vision.</li>"
			dat += "<li><i>Stealth</i>, when activated, drains more battery charge and works similarly to a syndicate cloak.</li>"
			dat += "<li><i>SpiderOS</i> is a specialized, PDA-like screen that allows for a small variety of functions, such as injecting healing chemicals directly from the suit. You are using it now, if that was not already obvious.</li>"
			dat += "</ul>"
			dat += "<b>Verbpowers</b>:"
			dat += "<ul>"
			dat += "<li>*<b>Phase Shift</b> (<i>2000E</i>) and <b>Phase Jaunt</b> (<i>1000E</i>) are unique powers in that they can both be used for defense and offense. Jaunt launches the ninja forward facing up to 10 squares, somewhat randomly selecting the final destination. Shift can only be used on turf in view but is precise (cannot be used on walls). Any living mob in the area teleported to is instantly gibbed.</li>"
			dat += "<li>*<b>Energy Blade</b> (<i>500E</i>) is a highly effective weapon. It is summoned directly to the ninja's hand and can also function as an EMAG for certain objects (doors/lockers/etc). You may also use it to cut through walls and disabled doors. Experiment! The blade will crit humans in two hits. This item cannot be placed in containers and when dropped or thrown disappears. Having an energy sword drains more power from the battery each tick.</li>"
			dat += "<li>*<b>EM Pulse</b> (<i>2500E</i>) is a highly useful ability that will create an electromagnetic shockwave around the ninja, disabling technology whenever possible. If used properly it can render a security force effectively useless. Of course, getting beat up with a toolbox is not accounted for.</li>"
			dat += "<li>*<b>Energy Star</b> (<i>300E</i>) is a ninja star made of green energy AND coated in poison. It works by picking a random living target within range and can be spammed to great effect in incapacitating foes. Just remember that the poison used is also used by the Xeno Hivemind (and will have no effect on them).</li>"
			dat += "<li>*<b>Adrenaline Boost</b> (<i>1 E. Boost/3</i>) recovers the user from stun, weakness, and paralysis. Also injects 20 units of radium into the bloodstream.</li>"
			dat += "<li>*<b>Smoke Bomb</b> (<i>1 Sm.Bomb/10</i>) is a weak but potentially useful ability. It creates harmful smoke and can be used in tandem with other powers to confuse enemies.</li>"
			dat += "<li>*<b>???</b>: unleash the <b>True Ultimate Power!</b></li>"
			dat += "</ul>"
			dat += "That is all you will need to know. The rest will come with practice and talent. Good luck!"
			dat += "<h4>Master /N</h4>"
/*
			//Sub-menu testing stuff.
			dat += "<li><a href='byond://?src=\ref[src];choice=49'> To sub-menu 49</a></li>"
		if(31)
			dat += "<h4><img src=sos_12.png> Send Virus:</h4>"
			dat += "<h4><img src=sos_6.png> Detected PDAs:</h4>"
			dat += "<ul>"
			var/count = 0
			for (var/obj/item/device/pda/P in world)
				if (!P.owner||P.toff)
					continue
				dat += "<li><a href='byond://?src=\ref[src];choice=\ref[P]'><i>[P]</i></a>"
				dat += "</li>"
				count++
			dat += "</ul>"
			if (count == 0)
				dat += "None detected.<br>"
		if(49)
			dat += "<h4><img src=sos_6.png> Other Functions 49:</h4>"
			dat += "<a href='byond://?src=\ref[src];choice=491'> To sub-menu 491</a>"
		if(491)
			dat += "<h4><img src=sos_6.png> Other Functions 491:</h4>"
			dat += "<a href='byond://?src=\ref[src];choice=0'> To main menu</a>"
*/
	dat += "</body></html>"

	U << browse(dat,"window=spideros;size=400x444;border=1;can_resize=0;can_close=0;can_minimize=0")
	//Setting the can>resize etc to 0 remove them from the drag bar but still allows the window to be draggable.

/obj/item/clothing/suit/space/space_ninja/Topic(href, href_list)
	..()
	var/mob/living/carbon/human/U = usr
	if(U.stat||U.wear_suit!=src||!initialize)//Check to make sure the guy is wearing the suit after clicking and it's on.
		U << "\red Your suit must be worn and active to use this function."
		U << browse(null, "window=spideros")//Closes the window.
		return

	switch(unlock)//To unlock Kamikaze mode. Irrelevant elsewhere.
		if(0)
			if(href_list["choice"]=="Stealth"&&spideros==0)	unlock++
		if(1)
			if(href_list["choice"]=="2"&&spideros==0)	unlock++
			else if(href_list["choice"]=="Return")
			else	unlock=0
		if(2)
			if(href_list["choice"]=="3"&&spideros==0)	unlock++
			else if(href_list["choice"]=="Return")
			else	unlock=0
		if(3)
			if(href_list["choice"]=="Stealth"&&spideros==0)	unlock++
			else if(href_list["choice"]=="Return")
			else	unlock=0
		if(4)
			if(href_list["choice"]=="1"&&spideros==0)	unlock++
			else if(href_list["choice"]=="Return")
			else	unlock=0
		if(5)
			if(href_list["choice"]=="1"&&spideros==0)	unlock++
			else if(href_list["choice"]=="Return")
			else	unlock=0
		if(6)
			if(href_list["choice"]=="4"&&spideros==0)	unlock++
			else if(href_list["choice"]=="Return")
			else	unlock=0
		if(7)//once unlocked, stays unlocked until deactivated.
		else
			unlock = 0

	switch(href_list["choice"])
		if("Close")
			U << browse(null, "window=spideros")
			return
		if("Refresh")//Refresh, goes to the end of the proc.
		if("Return")//Return
			if(spideros<=9)
				spideros=0
			else
				spideros = round(spideros/10)//Best way to do this, flooring to nearest integer. As an example, another way of doing it is attached below:
	//			var/temp = num2text(spideros)
	//			var/return_to = copytext(temp, 1, (length(temp)))//length has to be to the length of the thing because by default it's length+1
	//			spideros = text2num(return_to)//Maximum length here is 6. Use (return_to, X) to specify larger strings if needed.
		if("Stealth")
			if(active)
				spawn(0)
					anim(usr.loc,'mob.dmi',usr,"uncloak")
				active=0
				U << "\blue You are now visible."
				for(var/mob/O in oviewers(usr, null))
					O << "[usr.name] appears from thin air!"
			else
				spawn(0)
					anim(usr.loc,'mob.dmi',usr,"cloak")
				active=1
				U << "\blue You are now invisible to normal detection."
				for(var/mob/O in oviewers(usr, null))
					O << "[usr.name] vanishes into thin air!"
		if("0")//Menus are numbers, see note above. 0 is the hub.
			spideros=0
		if("1")//Begin normal menus 1-9.
			spideros=1
		if("2")
			spideros=2
		if("3")
			spideros=3
		if("32")
			spideros=32
		if("4")
			spideros=4
		/*Sub-menu testing stuff.
		if("31")
			spideros=31
		if("49")
			spideros=49
		if("491")
			spideros=491 */
		if("Unlock Kamikaze")
			if(input(U)=="Divine Wind")
				if( !(U.stat||U.wear_suit!=src||!initialize) )
					U << "\blue Engaging mode...\n\black<b>CODE NAME</b>: \red <b>KAMIKAZE</b>"
					sleep(40)
					U << "\blue Re-routing power nodes... \nUnlocking limiter..."
					sleep(40)
					U << "\blue Power nodes re-routed. \nLimiter unlocked."
					sleep(10)
					U << "\red Do or Die, <b>LET'S ROCK!!</b>"
					if(verbs.Find(/obj/item/clothing/suit/space/space_ninja/proc/deinit))//To hopefully prevent engaging kamikaze and de-initializing at the same time.
						kamikaze = 1
						active = 0
						icon_state = "s-ninjak"
						if(istype(U.gloves, /obj/item/clothing/gloves/space_ninja))
							U.gloves.icon_state = "s-ninjak"
							U.gloves.item_state = "s-ninjak"
							U.gloves:candrain = 0
							U.gloves:draining = 0
							U.gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/drain_wire
							U.gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/toggled
						U.update_clothing()
						U.verbs -= /mob/proc/ninjashift
						U.verbs -= /mob/proc/ninjajaunt
						U.verbs -= /mob/proc/ninjapulse
						U.verbs -= /mob/proc/ninjastar
						U.mind.special_verbs -= /mob/proc/ninjashift
						U.mind.special_verbs -= /mob/proc/ninjajaunt
						U.mind.special_verbs -= /mob/proc/ninjapulse
						U.mind.special_verbs -= /mob/proc/ninjastar
						U.verbs += /mob/proc/ninjaslayer
						U.verbs += /mob/proc/ninjawalk
						U.verbs += /mob/proc/ninjamirage
						U.mind.special_verbs += /mob/proc/ninjaslayer
						U.mind.special_verbs += /mob/proc/ninjawalk
						U.mind.special_verbs += /mob/proc/ninjamirage
						verbs -= /obj/item/clothing/suit/space/space_ninja/proc/spideros
						U.ninjablade()
						message_admins("\blue [U.key] used KAMIKAZE mode.", 1)
					else
						U << "Nevermind, you cheater."
				U << browse(null, "window=spideros")
				return
			else
				U << "\red ERROR: WRONG PASSWORD!"
				unlock = 0
				spideros = 0
		if("Dylovene")//These names really don't matter for specific functions but it's easier to use descriptive names.
			if(!reagents.get_reagent_amount("anti_toxin"))
				U << "\red Error: the suit cannot perform this function. Out of dylovene."
			else
				reagents.reaction(U, 2)
				reagents.trans_id_to(U, "anti_toxin", amount_per_transfer_from_this)
				U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
		if("Dexalin Plus")
			if(!reagents.get_reagent_amount("dexalinp"))
				U << "\red Error: the suit cannot perform this function. Out of dexalinp."
			else
				reagents.reaction(U, 2)
				reagents.trans_id_to(U, "dexalinp", amount_per_transfer_from_this)
				U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
		if("Tricordazine")
			if(!reagents.get_reagent_amount("tricordrazine"))
				U << "\red Error: the suit cannot perform this function. Out of tricordrazine."
			else
				reagents.reaction(U, 2)
				reagents.trans_id_to(U, "tricordrazine", amount_per_transfer_from_this)
				U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
		if("Spacelin")
			if(!reagents.get_reagent_amount("spaceacillin"))
				U << "\red Error: the suit cannot perform this function. Out of spaceacillin."
			else
				reagents.reaction(U, 2)
				reagents.trans_id_to(U, "spaceacillin", amount_per_transfer_from_this)
				U << "You feel a tiny prick and a sudden rush of liquid in to your veins."
		if("Nutriment")
			if(!reagents.get_reagent_amount("nutriment"))
				U << "\red Error: the suit cannot perform this function. Out of nutriment."
			else
				reagents.reaction(U, 2)
				reagents.trans_id_to(U, "nutriment", 5)
				U << "You feel a tiny prick and a sudden rush of substance in to your veins."

		else
		/*Leaving this for the messenger because it's an awesome solution. For switch to work, the variable has to be static.
		Not the case when P is a specific object. The downside, of course, is that there is only one slot.
		The following switch moves data to the appropriate function based on what screen it was clicked on. For now only uses screen 3.
		As an example, I added screen 31 to send the silence virus to people in the commented bits.
		You can do the same with functions that require dynamic tracking.
		*/
			switch(spideros)
				if(3)
					var/obj/item/device/pda/P = locate(href_list["choice"])
					var/t = input(U, "Please enter untraceable message.") as text
					t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
					if(!t||U.stat||U.wear_suit!=src||!initialize)//Wow, another one of these. Man...
						return
					if(isnull(P)||P.toff)//So it doesn't freak out if the object no-longer exists.
						U << "\red Error: unable to deliver message."
						spideros()
						return
					P.tnote += "<i><b>&larr; From unknown source:</b></i><br>[t]<br>"
					if (!P.silent)
						playsound(P.loc, 'twobeep.ogg', 50, 1)
						for (var/mob/O in hearers(3, P.loc))
							O.show_message(text("\icon[P] *[P.ttone]*"))
					P.overlays = null
					P.overlays += image('pda.dmi', "pda-r")
			/*	if(31)
					var/obj/item/device/pda/P = locate(href_list["choice"])
					if (!P.toff)
						U.show_message("\blue Virus sent!", 1)
						P.silent = 1
						P.ttone = "silence" */

	spideros()//Refreshes the screen by calling it again (which replaces current screen with new screen).
	return

/obj/item/clothing/suit/space/space_ninja/examine()
	set src in view()
	..()
	if(initialize)
		usr << "All systems operational. Current energy capacity: <B>[src.charge]</B>."
		if(!kamikaze)
			if(active)
				usr << "The CLOAK-tech device is <B>active</B>."
			else
				usr << "The CLOAK-tech device is <B>inactive</B>."
		else
			usr << "\red KAMIKAZE MODE ENGAGED!"
		usr << "There are <B>[sbombs]</B> smoke bombs remaining."
		usr << "There are <B>[aboost]</B> adrenaline boosters remaining."

//GLOVES===================================

/obj/item/clothing/gloves/space_ninja/proc/toggled()
	set name = "Toggle Drain"
	set desc = "Toggles the energy drain mechanism on or off."
	set category = "Object"
	if(!candrain)
		candrain=1
		usr << "You enable the energy drain mechanism."
	else
		candrain=0
		usr << "You disable the energy drain mechanism."

//DRAINING PROCS START===================================

/obj/item/clothing/gloves/space_ninja/proc/drain_wire()
	set name = "Drain From Wire"
	set desc = "Drain energy directly from an exposed wire."
	set category = "Object"

	var/obj/cable/attached
	var/mob/living/carbon/human/U = usr
	if(candrain&&!draining)
		var/turf/T = U.loc
		if(isturf(T) && T.is_plating())
			attached = locate() in T
			if(!attached)
				U << "\red Warning: no exposed cable available."
			else
				U << "\blue Connecting to wire, stand still..."
				if(do_after(U,50)&&!isnull(attached))
					drain("WIRE",attached,U:wear_suit,src)
				else
					U << "\red Procedure interrupted. Protocol terminated."
	return


/obj/item/clothing/gloves/space_ninja/proc/drain(var/target_type as text, var/target, var/obj/suit, var/obj/gloves)
//Var Initialize
	var/mob/living/carbon/human/U = usr
	var/obj/item/clothing/suit/space/space_ninja/S = suit
	var/obj/item/clothing/gloves/space_ninja/G = gloves

	var/drain = 0//To drain from battery.
	var/maxcapacity = 0//Safety check for full battery.
	var/totaldrain = 0//Total energy drained.

	G.draining = 1

	U << "\blue Now charging battery..."

	switch(target_type)
		if("APC")
			var/obj/machinery/power/apc/A = target
			if(A.cell&&A.cell.charge)
				var/datum/effects/system/spark_spread/spark_system = new /datum/effects/system/spark_spread()
				spark_system.set_up(5, 0, A.loc)
				while(G.candrain&&A.cell.charge>0&&!maxcapacity)
					drain = rand(G.mindrain,G.maxdrain)
					if(A.cell.charge<drain)
						drain = A.cell.charge
					if(S.charge+drain>S.maxcharge)
						drain = S.maxcharge-S.charge
						maxcapacity = 1//Reached maximum battery capacity.
					if (do_after(U,10))
						spark_system.start()
						playsound(A.loc, "sparks", 50, 1)
						A.cell.charge-=drain
						S.charge+=drain
						totaldrain+=drain
					else	break
				U << "\blue Gained <B>[totaldrain]</B> energy from the APC."
				if(!A.emagged)
					flick("apc-spark", src)
					A.emagged = 1
					A.locked = 0
					A.updateicon()
			else
				U << "\red This APC has run dry of power. You must find another source."

		if("SMES")
			var/obj/machinery/power/smes/A = target
			if(A.charge)
				var/datum/effects/system/spark_spread/spark_system = new /datum/effects/system/spark_spread()
				spark_system.set_up(5, 0, A.loc)
				while(G.candrain&&A.charge>0&&!maxcapacity)
					drain = rand(G.mindrain,G.maxdrain)
					if(A.charge<drain)
						drain = A.charge
					if(S.charge+drain>S.maxcharge)
						drain = S.maxcharge-S.charge
						maxcapacity = 1
					if (do_after(U,10))
						spark_system.start()
						playsound(A.loc, "sparks", 50, 1)
						A.charge-=drain
						S.charge+=drain
						totaldrain+=drain
					else	break
				U << "\blue Gained <B>[totaldrain]</B> energy from the SMES cell."
			else
				U << "\red This SMES cell has run dry of power. You must find another source."

		if("MECHA")
			var/obj/mecha/A = target
			A.occupant_message("\red Warning: Unauthorized access through sub-route 4, block H, detected.")
			if(A.get_charge())
				while(G.candrain&&A.cell.charge>0&&!maxcapacity)
					drain = rand(G.mindrain,G.maxdrain)
					if(A.cell.charge<drain)
						drain = A.cell.charge
					if(S.charge+drain>S.maxcharge)
						drain = S.maxcharge-S.charge
						maxcapacity = 1
					if (do_after(U,10))
						A.spark_system.start()
						playsound(A.loc, "sparks", 50, 1)
						A.cell.use(drain)
						S.charge+=drain
						totaldrain+=drain
					else	break
				U << "\blue Gained <B>[totaldrain]</B> energy from [src]."
			else
				U << "\red The exosuit's battery has run dry of power. You must find another source."

		if("CYBORG")
			var/mob/living/silicon/robot/A = target
			A << "\red Warning: Unauthorized access through sub-route 12, block C, detected."
			G.draining = 1
			if(A.cell&&A.cell.charge)
				while(G.candrain&&A.cell.charge>0&&!maxcapacity)
					drain = rand(G.mindrain,G.maxdrain)
					if(A.cell.charge<drain)
						drain = A.cell.charge
					if(S.charge+drain>S.maxcharge)
						drain = S.maxcharge-S.charge
						maxcapacity = 1
					if (do_after(U,10))
						A.spark_system.start()
						playsound(A.loc, "sparks", 50, 1)
						A.cell.charge-=drain
						S.charge+=drain
						totaldrain+=drain
					else	break
				U << "\blue Gained <B>[totaldrain]</B> energy from [A]."
			else
				U << "\red Their battery has run dry of power. You must find another source."

		if("WIRE")
			var/obj/cable/A = target
			var/datum/powernet/PN = A.get_powernet()
			while(G.candrain&&!maxcapacity&&!isnull(A))
				drain = (round((rand(G.mindrain,G.maxdrain))/2))
				var/drained = 0
				if(PN&&do_after(U,10))
					drained = min(drain, PN.avail)
					PN.newload += drained
					if(drained < drain)//if no power on net, drain apcs
						for(var/obj/machinery/power/terminal/T in PN.nodes)
							if(istype(T.master, /obj/machinery/power/apc))
								var/obj/machinery/power/apc/AP = T.master
								if(AP.operating && AP.cell && AP.cell.charge>0)
									AP.cell.charge = max(0, AP.cell.charge - 5)
									drained += 5
				else	break
				S.charge += drained
				if(S.charge>S.maxcharge)
					totaldrain += (drained-(S.charge-S.maxcharge))
					S.charge = S.maxcharge
					maxcapacity = 1
				else
					totaldrain += drained
				S.spark_system.start()
				if(drained==0)	break
			U << "\blue Gained <B>[totaldrain]</B> energy from the power network."
		else//Else nothing :<

	G.draining = 0

	return

//DRAINING PROCS END===================================

/obj/item/clothing/gloves/space_ninja/examine()
	set src in view()
	..()
	if(!canremove)
		if(candrain)
			usr << "The energy drain mechanism is: <B>active</B>."
		else
			usr << "The energy drain mechanism is: <B>inactive</B>."

//MASK===================================

/obj/item/clothing/mask/gas/voice/space_ninja/New()
	verbs += /obj/item/clothing/mask/gas/voice/space_ninja/proc/togglev
	verbs += /obj/item/clothing/mask/gas/voice/space_ninja/proc/switchm

/obj/item/clothing/mask/gas/voice/space_ninja/proc/togglev()
	set name = "Toggle Voice"
	set desc = "Toggles the voice synthesizer on or off."
	set category = "Object"
	var/vchange = (alert("Would you like to synthesize a new name or turn off the voice synthesizer?",,"New Name","Turn Off"))
	if(vchange=="New Name")
		var/chance = rand(1,100)
		switch(chance)
			if(1 to 50)//High chance of a regular name.
				var/g = pick(0,1)
				var/first = null
				var/last = pick(last_names)
				if(g==0)
					first = pick(first_names_female)
				else
					first = pick(first_names_male)
				voice = "[first] [last]"
			if(51 to 80)//Smaller chance of a clown name.
				var/first = pick(clown_names)
				voice = "[first]"
			if(81 to 90)//Small chance of a wizard name.
				var/first = pick(wizard_first)
				var/last = pick(wizard_second)
				voice = "[first] [last]"
			if(91 to 100)//Small chance of an existing crew name.
				var/list/names = new()
				for(var/mob/living/carbon/human/M in world)
					if(M==usr||!M.client||!M.real_name)	continue
					names.Add(M)
				if(!names.len)
					voice = "Cuban Pete"//Smallest chance to be the man.
				else
					var/mob/picked = pick(names)
					voice = picked.real_name
		usr << "You are now mimicking <B>[voice]</B>."
		return
	else
		if(voice!="Unknown")
			usr << "You deactivate the voice synthesizer."
			voice = "Unknown"
		else
			usr << "The voice synthesizer is already deactivated."
	return

/obj/item/clothing/mask/gas/voice/space_ninja/proc/switchm()
	set name = "Switch Mode"
	set desc = "Switches between Night Vision, Meson, or Thermal vision modes."
	set category = "Object"
	//Have to reset these manually since life.dm is retarded like that. Go figure.
	switch(mode)
		if(1)
			mode=2
			usr.see_in_dark = 2
			usr << "Switching mode to <B>Thermal Scanner</B>."
		if(2)
			mode=3
			usr.see_invisible = 0
			usr.sight &= ~SEE_MOBS
			usr << "Switching mode to <B>Meson Scanner</B>."
		if(3)
			mode=1
			usr.sight &= ~SEE_TURFS
			usr << "Switching mode to <B>Night Vision</B>."

/obj/item/clothing/mask/gas/voice/space_ninja/examine()
	set src in view()
	..()
	var/mode = "Night Vision"
	var/voice = "inactive"
	switch(mode)
		if(1)
			mode = "Night Vision"
		if(2)
			mode = "Thermal Scanner"
		if(3)
			mode = "Meson Scanner"
	if(vchange==0)
		voice = "inactive"
	else
		voice = "active"
	usr << "<B>[mode]</B> is active."
	usr << "Voice mimicking algorithm is set to <B>[voice]</B>."