// these global variables are placed in global.dm
// these should be added to relevant places within the code such as the chef cooking something would increment the
// meals score thing

	score_crewscore = 0 // this is the overall score for the whole round
	score_stuffshipped = 0 // how many useful items have cargo shipped out?
	score_stuffharvested = 0 // how many harvests have hydroponics done?
	score_oremined = 0 // obvious
	score_cyborgsmade = 0
	score_researchdone = 0
	score_eventsendured = 0 // how many random events did the station survive?
	score_powerloss = 0 // how many APCs have poor charge?
	score_escapees = 0 // how many people got out alive?
	score_deadcrew = 0 // dead bodies on the station, oh no
	score_mess = 0 // how much poo, puke, gibs, etc went uncleaned
	score_meals = 0
	score_disease = 0 // how many rampant, uncured diseases are on board the station

	score_deadcommand = 0 // used during rev, how many command staff perished
	score_arrested = 0 // how many traitors/revs/whatever are alive in the brig
	score_traitorswon = 0 // how many traitors were successful?
	score_allarrested = 0 // did the crew catch all the enemies alive?

	score_opkilled = 0 // used during nuke mode, how many operatives died?
	score_disc = 0 // is the disc safe and secure?
	score_nuked = 0 // was the station blown into little bits?

	// these ones are mainly for the stat panel
	score_powerbonus = 0 // if all APCs on the station are running optimally, big bonus
	score_messbonus = 0 // if there are no messes on the station anywhere, huge bonus
	score_deadaipenalty = 0 // is the AI dead? if so, big penalty

	score_foodeaten = 0 // nom nom nom
	score_clownabuse = 0 // how many times a clown was punched, struck or otherwise maligned

	score_richestname = null // this is all stuff to show who was the richest alive on the shuttle
	score_richestjob = null  // kinda pointless if you dont have a money system i guess
	score_richestcash = 0
	score_richestkey = null

	score_dmgestname = null // who had the most damage on the shuttle (but was still alive)
	score_dmgestjob = null
	score_dmgestdamage = 0
	score_dmgestkey = null

// and this stuff goes in gameticker.dm's declare_completion() proc

	// Score Calculation and Display

	// Who is alive/dead, who escaped
	for (var/mob/living/silicon/ai/I in world)
		if (I.stat == 2 && I.z == 1)
			score_deadaipenalty = 1
			score_deadcrew += 1
	for (var/mob/living/carbon/human/I in world)
		for (var/datum/ailment/disease/V in I.ailments)
			if (!V.vaccine && !V.spread != "Remissive") score_disease++
		if (I.stat == 2 && I.z == 1) score_deadcrew += 1
	for(var/mob/living/player in world)
		if (player.client)
			if (player.stat != 2)
				var/turf/location = get_turf(player.loc)
				var/area/escape_zone = locate(/area/shuttle/escape/centcom)
				if (location in escape_zone)
					score_escapees += 1


	var/cashscore = 0
	var/dmgscore = 0
	for(var/mob/living/carbon/human/E in world)
		cashscore = 0
		dmgscore = 0
		var/turf/location = get_turf(E.loc)
		var/area/escape_zone = locate(/area/shuttle/escape/centcom)
		if(E.stat != 2 && location in escape_zone) // Escapee Scores
			for (var/obj/item/weapon/card/id/C1 in E.contents) cashscore += C1.money
			for (var/obj/item/weapon/spacecash/C2 in E.contents) cashscore += C2.value
			for (var/obj/item/weapon/storage/S in E.contents)
				for (var/obj/item/weapon/card/id/C3 in S.contents) cashscore += C3.money
				for (var/obj/item/weapon/spacecash/C4 in S.contents) cashscore += C4.value
			for(var/datum/data/record/Ba in data_core.bank)
				if(Ba.fields["name"] == E.real_name) cashscore += Ba.fields["current_money"]
			if (cashscore > score_richestcash)
				score_richestcash = cashscore
				score_richestname = E.real_name
				score_richestjob = E.job
				score_richestkey = E.key
			dmgscore = E.bruteloss + E.fireloss + E.toxloss + E.oxyloss
			if (dmgscore > score_dmgestdamage)
				score_dmgestdamage = dmgscore
				score_dmgestname = E.real_name
				score_dmgestjob = E.job
				score_dmgestkey = E.key

	var/nukedpenalty = 1000
	if (ticker.mode.config_tag == "nuclear")
		var/foecount = 0
		for(var/datum/mind/M in ticker.mode:syndicates)
			foecount++
			if (!M || !M.current)
				score_opkilled++
				continue
			var/turf/T = M.current.loc
			if (T && istype(T.loc, /area/security/brig)) score_arrested += 1
			else if (M.current.stat == 2) score_opkilled++
		if(foecount == score_arrested) score_allarrested = 1

		score_disc = 1
		for (var/datum/computer/file/nuclear_auth/A in nuclear_auths)
			if(!A.holder) continue
			var/turf/location = get_turf(A.holder.loc)
			var/area/bad_zone1 = locate(/area)
			var/area/bad_zone2 = locate(/area/syndicate_station)
			var/area/bad_zone3 = locate(/area/wizard_station)
			if (location in bad_zone1) score_disc = 0
			if (location in bad_zone2) score_disc = 0
			if (location in bad_zone3) score_disc = 0
			if (A.holder.z != 1) score_disc = 0

		if (score_nuked)
			for (var/obj/machinery/nuclearbomb/NUKE in world)
				if (NUKE.r_code == "Nope") continue
				var/turf/T = NUKE.loc
				if (istype(T,/area/syndicate_station) || istype(T,/area/wizard_station) || istype(T,/area/solar)) nukedpenalty = 1000
				else if (istype(T,/area/security/main) || istype(T,/area/security/brig) || istype(T,/area/security/armory) || istype(T,/area/security/checkpoint2)) nukedpenalty = 50000
				else if (istype(T,/area/engine/power)) nukedpenalty = 100000
				else nukedpenalty = 10000

	if (ticker.mode.config_tag == "revolution")
		var/foecount = 0
		for(var/datum/mind/M in ticker.mode:head_revolutionaries)
			foecount++
			if (!M || !M.current)
				score_opkilled++
				continue
			var/turf/T = M.current.loc
			if (istype(T.loc, /area/security/brig)) score_arrested += 1
			else if (M.current.stat == 2) score_opkilled++
		if(foecount == score_arrested) score_allarrested = 1
		for(var/mob/living/carbon/human/player in world)
			if(player.mind)
				var/role = player.mind.assigned_role
				if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director"))
					if (player.stat == 2) score_deadcommand++

	// Check station's power levels
	for (var/obj/machinery/power/apc/A in world)
		if (A.z != 1) continue
		for (var/obj/item/weapon/cell/C in A.contents)
			if (C.charge < 2300) score_powerloss += 1 // 200 charge leeway

	// Check how much uncleaned mess is on the station
	for (var/obj/effect/decal/cleanable/M in world)
		if (M.z != 1) continue
		if (istype(M, /obj/effect/decal/cleanable/blood/gibs/)) score_mess += 3
		if (istype(M, /obj/effect/decal/cleanable/blood/)) score_mess += 1
		if (istype(M, /obj/effect/decal/cleanable/greenpuke)) score_mess += 1
		if (istype(M, /obj/effect/decal/cleanable/poo)) score_mess += 1
		if (istype(M, /obj/effect/decal/cleanable/urine)) score_mess += 1
		if (istype(M, /obj/effect/decal/cleanable/vomit)) score_mess += 1

	// Bonus Modifiers
	//var/traitorwins = score_traitorswon
	var/deathpoints = score_deadcrew * 25
	var/researchpoints = score_researchdone * 30
	var/eventpoints = score_eventsendured * 50
	var/borgpoints = score_cyborgsmade * 50
	var/escapoints = score_escapees * 25
	var/harvests = score_stuffharvested * 5
	var/shipping = score_stuffshipped * 5
	var/mining = score_oremined * 2
	var/meals = score_meals * 5
	var/power = score_powerloss * 20
	var/messpoints
	if (score_mess != 0) messpoints = score_mess
	var/plaguepoints = score_disease * 30

	// Mode Specific
	if (ticker.mode.config_tag == "nuclear")
		if (score_disc) score_crewscore += 500
		var/killpoints = score_opkilled * 250
		var/arrestpoints = score_arrested * 1000
		score_crewscore += killpoints
		score_crewscore += arrestpoints
		if (score_nuked) score_crewscore -= nukedpenalty

	if (ticker.mode.config_tag == "revolution")
		var/arrestpoints = score_arrested * 1000
		var/killpoints = score_opkilled * 500
		var/comdeadpts = score_deadcommand * 500
		if (score_traitorswon) score_crewscore -= 10000
		score_crewscore += arrestpoints
		score_crewscore += killpoints
		score_crewscore -= comdeadpts

	// Good Things
	score_crewscore += shipping
	score_crewscore += harvests
	score_crewscore += mining
	score_crewscore += borgpoints
	score_crewscore += researchpoints
	score_crewscore += eventpoints
	score_crewscore += escapoints

	if (power == 0)
		score_crewscore += 2500
		score_powerbonus = 1
	if (score_mess == 0)
		score_crewscore += 3000
		score_messbonus = 1
	score_crewscore += meals
	if (score_allarrested) score_crewscore *= 3 // This needs to be here for the bonus to be applied properly

	// Bad Things
	score_crewscore -= deathpoints
	if (score_deadaipenalty) score_crewscore -= 250
	score_crewscore -= power
	//if (score_crewscore != 0) // Dont divide by zero!
	//	while (traitorwins > 0)
	//		score_crewscore /= 2
	//		traitorwins -= 1
	score_crewscore -= messpoints
	score_crewscore -= plaguepoints

	// Show the score - might add "ranks" later
	world << "<b>The crew's final score is:</b>"
	world << "<b><font size='4'>[score_crewscore]</font></b>"
	for(var/mob/E in world)
		if(E.client) E.scorestats()

// and afaik this can go anywhere but I have it at the end of gameticker.dm

/mob/proc/scorestats()
	var/dat = {"<B>Round Statistics and Score</B><BR><HR>"}
	if (ticker.mode.name == "nuclear emergency")
		var/foecount = 0
		var/crewcount = 0
		var/diskdat = ""
		var/bombdat = null
		for(var/datum/mind/M in ticker.mode:syndicates)
			foecount++
		for(var/mob/living/C in world)
			if (!istype(C,/mob/living/carbon/human) || !istype(C,/mob/living/silicon/robot) || !istype(C,/mob/living/silicon/ai)) continue
			if (C.stat == 2) continue
			if (!C.client) continue
			crewcount++
		for(var/datum/computer/file/nuclear_auth/Nauth in nuclear_auths)
			var/obj/item/weapon/disk/data/N = Nauth.holder
			if(!N) continue
			var/atom/disk_loc = N.loc
			while(!istype(disk_loc, /turf))
				if(istype(disk_loc, /mob))
					var/mob/M = disk_loc
					diskdat += "Carried by [M.real_name] "
				if(istype(disk_loc, /obj))
					var/obj/O = disk_loc
					diskdat += "in \a [O.name] "
				disk_loc = disk_loc.loc
			diskdat += "in [disk_loc.loc]"
			break // Should only need one go-round, probably
		var/nukedpenalty = 0
		for(var/obj/machinery/nuclearbomb/NUKE in world)
			if (NUKE.r_code == "Nope") continue
			var/turf/T = NUKE.loc
			bombdat = T.loc
			if (istype(T,/area/syndicate_station) || istype(T,/area/wizard_station) || istype(T,/area/solar/) || istype(T,/area)) nukedpenalty = 1000
			else if (istype(T,/area/security/main) || istype(T,/area/security/brig) || istype(T,/area/security/armory) || istype(T,/area/security/checkpoint2)) nukedpenalty = 50000
			else if (istype(T,/area/engine/power)) nukedpenalty = 100000
			else nukedpenalty = 10000
			break
		if (!diskdat) diskdat = "Uh oh. Something has fucked up! Report this."
		dat += {"<B><U>MODE STATS</U></B><BR>
		<B>Number of Operatives:</B> [foecount]<BR>
		<B>Number of Surviving Crew:</B> [crewcount]<BR>
		<B>Final Location of Nuke:</B> [bombdat]<BR>
		<B>Final Location of Disk:</B> [diskdat]<BR><BR>
		<B>Nuclear Disk Secure:</B> [score_disc ? "Yes" : "No"] ([score_disc * 500] Points)<BR>
		<B>Operatives Arrested:</B> [score_arrested] ([score_arrested * 1000] Points)<BR>
		<B>Operatives Killed:</B> [score_opkilled] ([score_opkilled * 250] Points)<BR>
		<B>Station Destroyed:</B> [score_nuked ? "Yes" : "No"] (-[nukedpenalty] Points)<BR>
		<B>All Operatives Arrested:</B> [score_allarrested ? "Yes" : "No"] (Score tripled)<BR>
		<HR>"}
	if (ticker.mode.name == "revolution")
		var/foecount = 0
		var/comcount = 0
		var/revcount = 0
		var/loycount = 0
		for(var/datum/mind/M in ticker.mode:head_revolutionaries)
			if (M.current && M.current.stat != 2) foecount++
		for(var/datum/mind/M in ticker.mode:revolutionaries)
			if (M.current && M.current.stat != 2) revcount++
		for(var/mob/living/carbon/human/player in world)
			if(player.mind)
				var/role = player.mind.assigned_role
				if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director"))
					if (player.stat != 2) comcount++
				else
					if(player.mind in ticker.mode:revolutionaries) continue
					loycount++
		for(var/mob/living/silicon/X in world)
			if (X.stat != 2) loycount++
		var/revpenalty = 10000
		dat += {"<B><U>MODE STATS</U></B><BR>
		<B>Number of Surviving Revolution Heads:</B> [foecount]<BR>
		<B>Number of Surviving Command Staff:</B> [comcount]<BR>
		<B>Number of Surviving Revolutionaries:</B> [revcount]<BR>
		<B>Number of Surviving Loyal Crew:</B> [loycount]<BR><BR>
		<B>Revolution Heads Arrested:</B> [score_arrested] ([score_arrested * 1000] Points)<BR>
		<B>Revolution Heads Slain:</B> [score_opkilled] ([score_opkilled * 500] Points)<BR>
		<B>Command Staff Slain:</B> [score_deadcommand] (-[score_deadcommand * 500] Points)<BR>
		<B>Revolution Successful:</B> [score_traitorswon ? "Yes" : "No"] (-[score_traitorswon * revpenalty] Points)<BR>
		<B>All Revolution Heads Arrested:</B> [score_allarrested ? "Yes" : "No"] (Score tripled)<BR>
		<HR>"}
	var/totalfunds = wagesystem.station_budget + wagesystem.research_budget + wagesystem.shipping_budget
	dat += {"<B><U>GENERAL STATS</U></B><BR>
	<U>THE GOOD:</U><BR>
	<B>Useful Items Shipped:</B> [score_stuffshipped] ([score_stuffshipped * 5] Points)<BR>
	<B>Hydroponics Harvests:</B> [score_stuffharvested] ([score_stuffharvested * 5] Points)<BR>
	<B>Ore Mined:</B> [score_oremined] ([score_oremined * 2] Points)<BR>
	<B>Refreshments Prepared:</B> [score_meals] ([score_meals * 5] Points)<BR>
	<B>Research Completed:</B> [score_researchdone] ([score_researchdone * 30] Points)<BR>
	<B>Cyborgs Constructed:</B> [score_cyborgsmade] ([score_cyborgsmade * 50] Points)<BR>"}
	if (emergency_shuttle.location == 2) dat += "<B>Shuttle Escapees:</B> [score_escapees] ([score_escapees * 25] Points)<BR>"
	dat += {"<B>Random Events Endured:</B> [score_eventsendured] ([score_eventsendured * 50] Points)<BR>
	<B>Whole Station Powered:</B> [score_powerbonus ? "Yes" : "No"] ([score_powerbonus * 2500] Points)<BR>
	<B>Ultra-Clean Station:</B> [score_mess ? "No" : "Yes"] ([score_messbonus * 3000] Points)<BR><BR>
	<U>THE BAD:</U><BR>
	<B>Dead Bodies on Station:</B> [score_deadcrew] (-[score_deadcrew * 25] Points)<BR>
	<B>Uncleaned Messes:</B> [score_mess] (-[score_mess] Points)<BR>
	<B>Station Power Issues:</B> [score_powerloss] (-[score_powerloss * 20] Points)<BR>
	<B>Rampant Diseases:</B> [score_disease] (-[score_disease * 30] Points)<BR>
	<B>AI Destroyed:</B> [score_deadaipenalty ? "Yes" : "No"] (-[score_deadaipenalty * 250] Points)<BR><BR>
	<U>THE WEIRD</U><BR>
	<B>Final Station Budget:</B> $[num2text(totalfunds,50)]<BR>"}
	var/profit = totalfunds - 100000
	if (profit > 0) dat += "<B>Station Profit:</B> +[num2text(profit,50)]<BR>"
	else if (profit < 0) dat += "<B>Station Deficit:</B> [num2text(profit,50)]<BR>"
	dat += {"<B>Food Eaten:</b> [score_foodeaten]<BR>
	<B>Times a Clown was Abused:</B> [score_clownabuse]<BR><BR>"}
	if (score_escapees)
		dat += {"<B>Richest Escapee:</B> [score_richestname], [score_richestjob]: $[num2text(score_richestcash,50)] ([score_richestkey])<BR>
		<B>Most Battered Escapee:</B> [score_dmgestname], [score_dmgestjob]: [score_dmgestdamage] damage ([score_dmgestkey])<BR>"}
	else
		if (emergency_shuttle.location != 2) dat += "The station wasn't evacuated!<BR>"
		else dat += "No-one escaped!<BR>"
	dat += {"<HR><BR>
	<B><U>FINAL SCORE: [score_crewscore]</U></B><BR>"}
	var/score_rating = "The Aristocrats!"
	switch(score_crewscore)
		if(-99999 to -50000) score_rating = "Even the Singularity Deserves Better"
		if(-49999 to -5000) score_rating = "Singularity Fodder"
		if(-4999 to -1000) score_rating = "You're All Fired"
		if(-999 to -500) score_rating = "A Waste of Perfectly Good Oxygen"
		if(-499 to -250) score_rating = "A Wretched Heap of Scum and Incompetence"
		if(-249 to -100) score_rating = "Outclassed by Lab Monkeys"
		if(-99 to -21) score_rating = "The Undesirables"
		if(-20 to 20) score_rating = "Ambivalently Average"
		if(21 to 99) score_rating = "Not Bad, but Not Good"
		if(100 to 249) score_rating = "Skillful Servants of Science"
		if(250 to 499) score_rating = "Best of a Good Bunch"
		if(500 to 999) score_rating = "Lean Mean Machine Thirteen"
		if(1000 to 4999) score_rating = "Promotions for Everyone"
		if(5000 to 9999) score_rating = "Ambassadors of Discovery"
		if(10000 to 49999) score_rating = "The Pride of Science Itself"
		if(50000 to INFINITY) score_rating = "NanoTrasen's Finest"
	dat += "<B><U>RATING:</U></B> [score_rating]"
	src << browse(dat, "window=roundstats;size=500x600")
	return