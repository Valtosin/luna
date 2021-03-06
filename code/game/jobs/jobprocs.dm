/proc/SetupOccupationsList()
	var/list/new_occupations = list()

	for(var/occupation in occupations)
		if (!(new_occupations.Find(occupation)))
			new_occupations[occupation] = 1
		else
			new_occupations[occupation] += 1

	occupations = new_occupations
	return


/proc/FindOccupationCandidates(list/unassigned, job, level)
	var/list/candidates = list()

	for (var/mob/new_player/player in unassigned)
		if (level == 1 && player.preferences.occupation1 == job)
			candidates += player

		if (level == 2 && player.preferences.occupation2 == job)
			candidates += player

		if (level == 3 && player.preferences.occupation3 == job)
			candidates += player

	return candidates


/proc/PickOccupationCandidate(list/candidates)
	if (candidates.len > 0)
		var/list/randomcandidates = shuffle(candidates)
		candidates -= randomcandidates[1]
		return randomcandidates[1]

	return null


/proc/SetTitles()
	for (var/mob/new_player/player in world)
		if(!player.preferences) continue
		if(player.preferences.occupation1 == player.mind.assigned_role && player.preferences.title1)
			player.mind.title = player.preferences.title1
		else if(player.preferences.occupation2 == player.mind.assigned_role && player.preferences.title2)
			player.mind.title = player.preferences.title2
		else if(player.preferences.occupation3 == player.mind.assigned_role && player.preferences.title3)
			player.mind.title = player.preferences.title3
	return 0


/proc/DivideOccupations()
	var/list/unassigned = list()
	var/list/occupation_choices = occupations.Copy()
	var/list/occupation_eligible = occupations.Copy()
	occupation_choices = shuffle(occupation_choices)

	for (var/mob/new_player/player in world)
		if (player.client && player.ready && !player.mind.assigned_role)
			unassigned += player

			// If someone picked AI before it was disabled, or has a saved profile with it
			// on a game that now lacks it, this will make sure they don't become the AI,
			// by changing that choice to Captain.
			if (!config.allow_ai)
				if (player.preferences.occupation1 == "AI")
					player.preferences.occupation1 = "Captain"
				if (player.preferences.occupation2 == "AI")
					player.preferences.occupation2 = "Captain"
				if (player.preferences.occupation3 == "AI")
					player.preferences.occupation3 = "Captain"
	if (unassigned.len == 0)
		return 0

	var/mob/new_player/captain_choice = null

	for (var/level = 1 to 3)
		var/list/captains = FindOccupationCandidates(unassigned, "Captain", level)
		for(var/mob/new_player/traitorcheck in captains)	//Do not allow Traitors to choose to be Captain.  Remove them from the list of potential Captains.
			if(traitorcheck.mind.special_role)
				captains -= traitorcheck
		var/mob/new_player/candidate = PickOccupationCandidate(captains)

		if (candidate != null)
			captain_choice = candidate
			unassigned -= captain_choice
			break

	if (captain_choice == null && unassigned.len > 0)
		unassigned = shuffle(unassigned)
		var/mob/new_player/traitorcheck = unassigned[1]
		if (traitorcheck.mind.special_role)		//If a Traitor is first in the list of people checked to be Captain, reshuffle the list.  This will decrease the chance of a Traitor Captains without eliminating it entirely.
			unassigned = shuffle(unassigned)

		for(var/mob/new_player/player in unassigned)
			captain_choice = player
			break
		unassigned -= captain_choice

	if (captain_choice == null)
		world << "Captainship not forced on anyone."
	else
		captain_choice.mind.assigned_role = "Captain"

	//so that an AI is chosen during this game mode
	if(ticker.mode.name == "AI malfunction" && unassigned.len > 0)
		var/mob/new_player/ai_choice = null

		for (var/level = 1 to 3)
			var/list/ais = FindOccupationCandidates(unassigned, "AI", level)
			var/mob/new_player/candidate = PickOccupationCandidate(ais)

			if (candidate != null)
				ai_choice = candidate
				unassigned -= ai_choice
				break

		if (ai_choice == null && unassigned.len > 0)
			unassigned = shuffle(unassigned)
			for(var/mob/new_player/player in unassigned)
				ai_choice = player
				break
			unassigned -= ai_choice

		if (ai_choice != null)
			ai_choice.mind.assigned_role = "AI"
		else
			world << "It is [ticker.mode.name] and there is no AI, someone should fix this"

	for (var/level = 1 to 3)
		if (unassigned.len == 0)	//everyone is assigned
			break

		for (var/occupation in assistant_occupations)
			if (unassigned.len == 0)
				break
			var/list/candidates = FindOccupationCandidates(unassigned, occupation, level)
			for (var/mob/new_player/candidate in candidates)
				candidate.mind.assigned_role = occupation
				unassigned -= candidate

		for (var/occupation in occupation_choices)
			if (unassigned.len == 0)
				break
			if(ticker.mode.name == "AI malfunction" && occupation == "AI")
				continue
			var/eligible = occupation_eligible[occupation]
			if (eligible == 0)
				continue
			var/list/candidates = FindOccupationCandidates(unassigned, occupation, level)
			var/eligiblechange = 0
			while (eligible--)
				var/mob/new_player/candidate = PickOccupationCandidate(candidates)
				if (candidate == null)
					break
				candidate.mind.assigned_role = occupation
				unassigned -= candidate
				eligiblechange++
			occupation_eligible[occupation] -= eligiblechange

	if (unassigned.len)
		unassigned = shuffle(unassigned)
		for (var/occupation in occupation_choices)
			if (unassigned.len == 0)
				break
			if(ticker.mode.name == "AI malfunction" && occupation == "AI")
				continue
			var/eligible = occupation_eligible[occupation]
			while (eligible-- && unassigned.len > 0)
				var/mob/new_player/candidate = unassigned[1]
				if (candidate == null)
					break
				candidate.mind.assigned_role = occupation
				unassigned -= candidate

	for (var/mob/new_player/player in unassigned)
		player.mind.assigned_role = pick(assistant_occupations)

	// Assign vacant head of department roles at random from the departments under them.
	for (var/department in get_job_types())
		var/list/candidate_list = list()
		var/list/job_list = get_type_jobs(department)
		var/head = get_department_head(department)

		// Skip departments that don't have assigned heads.
		if (!head)
			continue

		// Build candidate list from already-assigned players.
		for (var/mob/new_player/player in world)
			if(!player.mind) continue
			// Clear the list if an existing head is found. We don't want two HoDs.
			if (player.mind.assigned_role == head)
				candidate_list = list()
				break
			// Don't give the job to anyone banned or in the wrong department either.
			if (job_list.Find(player.mind.assigned_role))
				candidate_list += player

		// Assign a candidate at random. Leave it vacant if there's no one suitable.
		if (candidate_list.len > 0)
			candidate_list = shuffle(candidate_list)
			var/mob/new_player/candidate = candidate_list[1]
			candidate.mind.assigned_role = head

	return 1

/mob/living/carbon/human/proc/Equip_Rank(rank, joined_late)
	/*if(joined_late && ticker.mode.name == "ctf")
		var/red_team
		var/green_team

		for(var/mob/living/carbon/human/M in world)
			if(M.client)
				if(M.client.team == "Red")
					red_team++
				if(M.client.team == "Green")
					green_team++

		if(!src.client.team)
			if(red_team > green_team)
				src.client.team = "Green"
			else
				src.client.team = "Red"


		src << "You are in the [src.client.team] Team!"
		var/obj/item/device/radio/headset/H = new /obj/item/device/radio/headset(src)
		src.equip_if_possible(H, slot_w_radio)
		if(src.client.team == "Red")
			H.set_frequency(1465)
			src.equip_if_possible(new /obj/item/clothing/under/color/red(src), src.slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/tdome/red(src), slot_wear_suit)
		else if(src.client.team == "Green")
			H.set_frequency(1449)
			src.equip_if_possible(new /obj/item/clothing/under/color/green(src), src.slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/tdome/green(src), slot_wear_suit)
		src.equip_if_possible(new /obj/item/clothing/shoes/black(src), src.slot_shoes)
		src.equip_if_possible(new /obj/item/clothing/mask/gas/emergency(src), src.slot_wear_mask)
		src.equip_if_possible(new /obj/item/clothing/gloves/swat(src), src.slot_gloves)

		src.equip_if_possible(new /obj/item/clothing/glasses/thermal(src), src.slot_glasses)

		var/obj/item/weapon/tank/air/O = new /obj/item/weapon/tank/air(src)
		src.equip_if_possible(O, src.slot_back)
		src.internal = O

		var/obj/item/weapon/card/id/W = new(src)
		W.name = "[src.real_name]'s ID card ([src.client.team] Team)"
		if(src.client.team == "Red")
			W.access = access_red
		else if(src.client.team == "Green")
			W.access = access_green
		else
			world << "Unspecified team, [src.client.team]"

		W.assignment = "[src.client.team] Team"
		W.registered = src.real_name
		src.equip_if_possible(W, src.slot_wear_id)

		return

	if(joined_late && ticker.mode.name == "deathmatch")
		src.equip_if_possible(new /obj/item/clothing/under/color/black(src), src.slot_w_uniform)
		src.equip_if_possible(new /obj/item/clothing/shoes/black(src), src.slot_shoes)
		src.equip_if_possible(new /obj/item/clothing/suit/swat_suit/death_commando(src), src.slot_wear_suit)
		src.equip_if_possible(new /obj/item/clothing/mask/gas/death_commando(src), src.slot_wear_mask)
		src.equip_if_possible(new /obj/item/clothing/gloves/swat(src), src.slot_gloves)
		src.equip_if_possible(new /obj/item/clothing/glasses/thermal(src), src.slot_glasses)
		src.equip_if_possible(new /obj/item/weapon/gun/energy/pulse_rifle(src), src.slot_l_hand)
		src.equip_if_possible(new /obj/item/weapon/grenade/flashbang(src), src.slot_r_store)

		var/obj/item/weapon/tank/air/O = new /obj/item/weapon/tank/air(src)
		src.equip_if_possible(O, src.slot_back)
		src.internal = O

		var/randomname = "Killiam Shakespeare"
		if(commando_names.len)
			randomname = pick(commando_names)
			commando_names -= randomname
		var/newname = input(src,"You are a death commando. Would you like to change your name?", "Character Creation", randomname)
		if(!length(newname))
			newname = randomname
		newname = strip_html(newname,40)

		src.real_name = newname
		src.name = newname // there are WAY more things than this to change, I'm almost certain

		var/obj/item/weapon/card/id/W = new(src)
		W.name = "[newname]'s ID card (Death Commando)"
		W.access = get_all_accesses()
		W.assignment = "Death Commando"
		W.registered = newname
		src.equip_if_possible(W, src.slot_wear_id)
		return
	*/


	switch(rank)
		if ("Counselor")
			src.equip_if_possible(new /obj/item/device/pda/chaplain(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/chaplain(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)
			src.equip_if_possible(new /obj/item/device/radio/headset(src),slot_ears)
			src.equip_if_possible(new /obj/item/clothing/suit/storage/chaplain_hoodie(src), slot_wear_suit)

		if ("Geneticist")
			src.equip_if_possible(new /obj/item/device/pda/gene(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/geneticist(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/white(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_medsci,slot_ears)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)

		if ("Chemist")
			src.equip_if_possible(new /obj/item/device/pda/chem(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/chemist(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/white(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_medsci(src),slot_ears)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)

		if ("Janitor")
			src.equip_if_possible(new /obj/item/device/pda/janitor(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/janitor(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/galoshes(src), slot_shoes)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)

		if ("Clown")
			src.equip_if_possible(new /obj/item/device/pda/clown(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/clown(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/clown_shoes(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/mask/gas/clown_hat(src), slot_wear_mask)
			src.equip_if_possible(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/bikehorn(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/clown(src), slot_back)
			src.mutations += CLUMSY

		if ("Mime")
			src.equip_if_possible(new /obj/item/device/pda/mime(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/mime(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/mask/gas/mime(src), slot_wear_mask)
			src.equip_if_possible(new /obj/item/clothing/gloves/latex(src), slot_gloves)
			src.equip_if_possible(new /obj/item/clothing/head/beret(src), slot_head)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)
			src.silent += 1000000
			src.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/mimewall()

		if ("Engineer")
			src.equip_if_possible(new /obj/item/device/pda/engineering(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/engineer(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/orange(src), slot_shoes)
			src.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(src), slot_l_hand)
			src.equip_if_possible(new /obj/item/clothing/gloves/yellow(src), slot_gloves)
			src.equip_if_possible(new /obj/item/weapon/crowbar(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/device/t_scanner(src), slot_r_store)
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_eng(src),slot_ears)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/industrial(src), slot_back)
			src.equip_if_possible(new /obj/item/clothing/suit/storage/hazard(src), slot_wear_suit)

		if ("Unassigned")
			src.equip_if_possible(new /obj/item/clothing/under/color/grey(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)

		if ("Forensic Technician")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_sec(src), slot_ears)
			src.equip_if_possible(new /obj/item/device/pda/det(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/forensic_technician(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			//src.equip_if_possible(new /obj/item/clothing/head/det_hat(src), slot_head)
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/weapon/storage/box/fcard(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/fcardholder(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/clothing/suit/storage/gearharness(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/device/detective_scanner(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/lighter/zippo(src), slot_l_store)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/security(src), slot_back)

		if ("Medical Doctor")
			src.equip_if_possible(new /obj/item/device/pda/medical(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/medical(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/white(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/weapon/storage/firstaid/regular(src), slot_l_hand)
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_med(src),slot_ears)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/medic(src), slot_back)

		if ("Captain")
			src.equip_if_possible(new /obj/item/device/radio/headset/heads/captain(src), slot_ears)
			src.equip_if_possible(new /obj/item/device/pda/heads/captain(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/captain(src), slot_w_uniform)
		//	src.equip_if_possible(new /obj/item/clothing/suit/armor/captain(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
		//	src.equip_if_possible(new /obj/item/clothing/head/caphat(src), slot_head)
			src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(src), slot_glasses)
//			src.equip_if_possible(new /obj/item/weapon/gun/taser_gun(src), slot_belt)
			src.equip_if_possible(new /obj/item/weapon/gun/energy/taser(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/storage/box/id(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/clothing/gloves/green(src), slot_gloves)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/captain(src), slot_back)

		if ("Security Officer")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_sec(src), slot_ears)
			src.equip_if_possible(new /obj/item/device/pda/security(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/color/red(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/jackboots(src), slot_shoes)
//			src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(src), slot_glasses)
//			src.equip_if_possible(new /obj/item/weapon/gun/taser_gun(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/handcuffs(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/handcuffs(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/clothing/head/helmet/secsoft(src), slot_head)
//			src.equip_if_possible(new /obj/item/weapon/storage/box/grenades/flashbang(src), slot_in_backpack)
//			src.equip_if_possible(new /obj/item/weapon/melee/baton(src), slot_belt)
//			src.equip_if_possible(new /obj/item/device/flash(src), slot_l_store)
			src.equip_if_possible(new /obj/item/clothing/gloves/red(src), slot_gloves)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/security(src), slot_back)

		if ("Scientist")
			src.equip_if_possible(new /obj/item/device/pda/toxins(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/scientist(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/white(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat(src), slot_wear_suit)
//			src.equip_if_possible(new /obj/item/clothing/suit/bio_suit(src), slot_wear_suit)
//			src.equip_if_possible(new /obj/item/clothing/head/bio_hood(src), slot_head)
			src.equip_if_possible(new /obj/item/clothing/mask/gas(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/tank/oxygen(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_sci(src),slot_ears)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)

		if ("Head of Security")
			src.equip_if_possible(new /obj/item/device/radio/headset/heads/hos(src), slot_ears)
			src.equip_if_possible(new /obj/item/device/pda/heads/hos(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/head_of_security(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/suit/storage/armor/hos(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/shoes/jackboots(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/head/helmet/HoS(src), slot_head)
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/security(src), slot_back)

		if ("Head of Personnel")
			src.equip_if_possible(new /obj/item/device/radio/headset/heads/hop(src), slot_ears)
			src.equip_if_possible(new /obj/item/device/pda/heads/hop(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/head_of_personnel(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/vest(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/head/helmet(src), slot_head)
			src.equip_if_possible(new /obj/item/weapon/gun/energy/taser(src), slot_in_backpack)
//			src.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(src), slot_glasses)
//			src.equip_if_possible(new /obj/item/weapon/gun/taser_gun(src), slot_belt)
//			src.equip_if_possible(new /obj/item/weapon/gun/energy/laser(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/storage/box/id(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)
//			src.equip_if_possible(new /obj/item/device/flash(src), slot_l_store)

		if ("Warden")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_sec(src), slot_ears)
			src.equip_if_possible(new /obj/item/device/pda/warden(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/warden(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/suit/warden_jacket(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/clothing/shoes/jackboots(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/security(src), slot_back)

		if ("Atmospheric Technician")
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_eng(src), slot_ears)
			src.equip_if_possible(new /obj/item/clothing/under/rank/atmospheric_technician(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(src), slot_l_hand)
			src.equip_if_possible(new /obj/item/weapon/crowbar(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/industrial(src), slot_back)
			src.equip_if_possible(new /obj/item/clothing/suit/storage/hazard(src), slot_wear_suit)

		if ("Barman")
			src.equip_if_possible(new /obj/item/clothing/under/rank/bartender(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/bar(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/suit/armor/vest(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)
			src.equip_if_possible(new /obj/item/device/radio/headset(src),slot_ears)

		if ("Chef")
			src.equip_if_possible(new /obj/item/clothing/under/rank/chef(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/chef(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/head/chefhat(src), slot_head)
			src.equip_if_possible(new /obj/item/weapon/kitchen/rollingpin(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)
			src.equip_if_possible(new /obj/item/device/radio/headset(src),slot_ears)

		if ("Roboticist")
			src.equip_if_possible(new /obj/item/device/pda/robot(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/roboticist(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/weapon/crowbar(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(src), slot_l_hand)
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_rob,slot_ears)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)

		if ("Hydroponicist")
			src.equip_if_possible(new /obj/item/device/pda/hydro(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/under/rank/hydroponics(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/device/radio/headset(src),slot_ears)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)
			src.equip_if_possible(new /obj/item/clothing/head/greenbandana(src), slot_head)
			src.equip_if_possible(new /obj/item/clothing/suit/storage/apron(src), slot_wear_suit)

		if ("Quartermaster")
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/under/rank/cargo(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/quartermaster(src), slot_belt)
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_cargo(src), slot_ears) // heads(!)/qm
			//src.equip_if_possible(new /obj/item/clothing/suit/exo_suit(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)

		if ("Cargo Technician")
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/under/rank/cargotech(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/cargo(src), slot_belt)
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_cargo(src), slot_ears)
			//src.equip_if_possible(new /obj/item/clothing/suit/exo_suit(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)

		if ("Chief Engineer")
			src.equip_if_possible(new /obj/item/device/pda/heads/ce(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/gloves/yellow(src), slot_gloves)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/head/helmet/hardhat(src), slot_head)
			src.equip_if_possible(new /obj/item/clothing/glasses/meson(src), slot_glasses)
			src.equip_if_possible(new /obj/item/weapon/gun/energy/taser(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/clothing/under/rank/chief_engineer(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/radio/headset/heads/ce(src), slot_ears)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/industrial(src), slot_back)
			src.equip_if_possible(new /obj/item/clothing/suit/storage/hazard(src), slot_wear_suit)

		if ("Research Director")
			src.equip_if_possible(new /obj/item/device/pda/heads/rd(src), slot_belt)
			src.equip_if_possible(new /obj/item/clothing/shoes/brown(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/under/rank/research_director(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/clothing/suit/storage/labcoat(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/weapon/clipboard(src), slot_r_hand)
			src.equip_if_possible(new /obj/item/weapon/gun/energy/taser(src), slot_in_backpack)
			src.equip_if_possible(new /obj/item/device/radio/headset/heads/rd(src), slot_ears)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack(src), slot_back)

		if ("Shaft Miner")
			src.equip_if_possible(new /obj/item/clothing/gloves/black(src), slot_gloves)
			src.equip_if_possible(new /obj/item/clothing/shoes/black(src), slot_shoes)
			src.equip_if_possible(new /obj/item/clothing/under/rank/miner(src), slot_w_uniform)
			src.equip_if_possible(new /obj/item/device/pda/miner(src), slot_belt)
			src.equip_if_possible(new /obj/item/device/radio/headset/headset_mine(src), slot_ears)
			//src.equip_if_possible(new /obj/item/clothing/suit/exo_suit(src), slot_wear_suit)
			src.equip_if_possible(new /obj/item/weapon/storage/backpack/industrial(src), slot_back)
			src.equip_if_possible(new /obj/item/clothing/glasses/meson(src), slot_glasses)
		else
			src << "RUH ROH! Your job is [rank] and the game just can't handle it! Please report this bug to an administrator."
	src.equip_if_possible(new /obj/item/device/radio/headset(src), slot_ears)

	spawnId(rank)
	if(rank == "Captain")
		world << "<b>[src] is the captain!</b>"
	src << "<B>You are the [rank].</B>"
	src.job = rank
	src.mind.assigned_role = rank
	//DERP
	if (!joined_late && rank != "Tourist")
		var/obj/S = null
		for(var/obj/effect/landmark/start/sloc in world)
			if (sloc.name != rank)
				continue
			if (locate(/mob) in sloc.loc)
				continue
			S = sloc
			break
		if (!S)
			S = locate("start*[rank]") // use old stype
		if (!S) // No start point for rank.
			world << "Map bug: no (unoccupied) start locations available for [rank]. Attempting to use shuttle..."
			var/start = pick(latejoin)
			if(!start)//If it can't even find space  here, something must be *very* wrong. Probably a lazy mapper or early WIP map.
				world << "Map bug: There aren't any start locations for the shuttle, either!."
			else
				src.loc = start
		if (istype(S, /obj/effect/landmark/start) && istype(S.loc, /turf))
			src.loc = S.loc

	else
		src.loc = pick(latejoin)
	src.update_clothing()
	return

/mob/living/carbon/human/proc/spawnId(rank)
	var/obj/item/weapon/card/id/C = null
	switch(rank)
		if("Captain")
			C = new /obj/item/weapon/card/id/gold(src)
		else
			C = new /obj/item/weapon/card/id(src)
	if(C)
		C.registered = src.real_name
		C.assignment = rank
		if(src.mind.title && HasTitles(rank))
			C.name = "[C.registered]'s ID Card ([src.mind.title])"
		else
			C.name = "[C.registered]'s ID Card ([C.assignment])"
		C.access = get_access(C.assignment)
		src.equip_if_possible(C, slot_wear_id)
	src.equip_if_possible(new /obj/item/device/pda(src), slot_belt)
	if (istype(src.belt, /obj/item/device/pda))
		src.belt:owner = src.real_name
		src.belt.name = "PDA-[src.real_name]"