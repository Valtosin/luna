/datum/game_mode
	var/name = "Invalid"
	var/config_tag = null
	var/votable = 1
	var/probability = 1

	// Antags.
	var/list/datum/mind/traitors = list()
	var/list/datum/mind/changelings = list()
	var/list/datum/mind/head_revolutionaries = list()
	var/list/datum/mind/revolutionaries = list()
	var/list/datum/mind/syndicates = list()
	var/list/datum/mind/wizards = list()
	var/list/datum/mind/cult = list()
	// this includes admin-appointed antags and multiantags. Easy!

	var/list/logtraitors = list()

	var/uplink_welcome = "Syndicate Uplink Console:"
	var/uplink_items = {"
/obj/item/weapon/storage/box/syndie_kit/imp_freedom:3:Freedom Implant, with injector;
/obj/item/weapon/storage/box/syndie_kit/imp_compress:5:Compressed matter implant, with injector;
/obj/item/weapon/storage/box/syndie_kit/imp_explosive:6:Explosive implant, with injector;
/obj/item/weapon/gun/projectile/revolver:7:Revolver;
/obj/item/ammo_magazine/box/a357:3:Revolver Ammo;
/obj/item/weapon/gun/energy/crossbow:5:Energy crossbow;
/obj/item/weapon/melee/energy/sword:5:Energy sword;
/obj/item/device/hacktool:4:Hacktool;
/obj/item/weapon/storage/toolbox/syndicate:1:Fully Loaded Toolbox;
/obj/item/weapon/soap/syndie:1:Syndicate Soap;
/obj/item/clothing/shoes/syndigaloshes:2:No-Slip Syndicate Shoes;
/obj/item/device/encryptionkey/syndicate:1:Binary Encryption Key;
/obj/item/clothing/under/chameleon:2:Chameleon Jumpsuit;
/obj/item/weapon/card/emag:3:Cryptographic Sequencer;
/obj/item/weapon/card/id/syndicate:4:Fake ID;
/obj/item/clothing/glasses/thermal:4:Thermal Glasses;
/obj/item/weapon/storage/box/grenades/emp:4:Box of EMP grenades;
/obj/item/weapon/cartridge/syndicate:3:Detomatix PDA cart;
/obj/item/device/chameleon:4:Chameleon projector;
/obj/item/weapon/pen/sleepypen:4:Sleepy pen;
/obj/item/clothing/mask/gas/voice:3:Voice changer;
/obj/item/weapon/aiModule/freeform:3:Freeform AI module;
/obj/item/device/powersink:5:Power sink;
/obj/item/weapon/syndie/c4explosive:4:Low power explosive charge;
/obj/item/weapon/syndie/c4explosive/heavy:7:HIGH power explosive charge;
/obj/item/weapon/reagent_containers/pill/cyanide:4:Cyanide Pill
	"}
	var/uplink_uses = 10

	var/list/allwords = list("travel","self","see","hell","blood","join","tech","destroy", "other", "hide")

	var/enabled = 1

/datum/game_mode/proc/announce()
	world << "<B>The current game mode is - [name]!</B>"

/datum/game_mode/proc/pre_setup()
	return 1

/datum/game_mode/proc/post_setup()

/datum/game_mode/proc/process()

/datum/game_mode/proc/check_finished()
	if(main_shuttle.location==2)
		return 1
	return 0

/datum/game_mode/proc/declare_completion()
	for(var/datum/mind/traitor in traitors)
		var/traitorwin = 1
		var/traitor_name

		if(traitor.current)
			traitor_name = "[traitor.current.real_name] (played by [traitor.key])"
		else
			traitor_name = "[traitor.key] (character destroyed)"

		world << "<B>The syndicate traitor was [traitor_name]</B>"
		var/count = 1
		for(var/datum/objective/objective in traitor.objectives)
			world << "<B>Objective #[count]</B>: [objective.explanation_text] \..."
			if (objective.check_completion())
				world << "\green <B>Success</B>"
			else
				world << "\red Failed"
				traitorwin = 0
			count++

		world << "<B>The traitor [(traitorwin ? "was successful" : "has failed")]!</B>"
		
	check_round()
	return 1

/datum/game_mode/proc/check_win()

/datum/game_mode/proc/latespawn(var/mob)

/datum/game_mode/proc/send_intercept()
/datum/game_mode/proc/check_round()
/datum/game_mode/proc/equip_traitor(mob/living/carbon/human/traitor_mob)
	if (!istype(traitor_mob))
		return

	// generate list of radio freqs
	var/freq = 1441
	var/list/freqlist = list()
	while (freq <= 1489)
		if (freq < 1451 || freq > 1459)
			freqlist += freq
		freq += 2
		if ((freq % 2) == 0)
			freq += 1
	freq = freqlist[rand(1, freqlist.len)]
	// generate a passcode if the uplink is hidden in a PDA
	var/pda_pass = "[rand(100,999)] [pick("Alpha","Bravo","Delta","Omega")]"

	// find a radio! toolbox(es), backpack, belt, headset
	var/loc = ""
	var/obj/item/device/R = null //Hide the uplink in a PDA if available, otherwise radio
	if (!R && istype(traitor_mob.belt, /obj/item/device/pda))
		R = traitor_mob.belt
		loc = "on your belt"
	if (!R && istype(traitor_mob.wear_id, /obj/item/device/pda))
		R = traitor_mob.wear_id
		loc = "on your jumpsuit"
	if (!R && istype(traitor_mob.l_hand, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = traitor_mob.l_hand
		var/list/L = S.return_inv()
		for (var/obj/item/device/radio/foo in L)
			R = foo
			loc = "in the [S.name] in your left hand"
			break
	if (!R && istype(traitor_mob.r_hand, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = traitor_mob.r_hand
		var/list/L = S.return_inv()
		for (var/obj/item/device/radio/foo in L)
			R = foo
			loc = "in the [S.name] in your right hand"
			break
	if (!R && istype(traitor_mob.back, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = traitor_mob.back
		var/list/L = S.return_inv()
		for (var/obj/item/device/radio/foo in L)
			R = foo
			loc = "in the [S.name] on your back"
			break
	if (!R && traitor_mob.w_uniform && istype(traitor_mob.belt, /obj/item/device/radio))
		R = traitor_mob.belt
		loc = "on your belt"
	if (!R && istype(traitor_mob.ears, /obj/item/device/radio))
		R = traitor_mob.ears
		loc = "on your head"
	if (!R)
		traitor_mob << "Unfortunately, the Syndicate wasn't able to get you a radio."
	else
		if (istype(R, /obj/item/device/radio))
			var/obj/item/device/radio/radio = R
			var/obj/item/device/uplink/headset/T = new /obj/item/device/uplink/headset(R)

			radio.uplink = T
			radio.traitor_frequency = freq
			T.hostradio = R
			traitor_mob << "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name] [loc]. Simply dial the frequency [format_frequency(freq)] to unlock its hidden features."
			traitor_mob.mind.store_memory("<B>Radio Freq:</B> [format_frequency(freq)] ([R.name] [loc]).")

		else if (istype(R, /obj/item/device/pda))
			var/obj/item/device/pda/pda = R
			var/obj/item/device/uplink/pda/T = new /obj/item/device/uplink/pda(R)

			pda.uplink = T
			T.unlocking_code = pda_pass
			T.hostpda = R
			traitor_mob << "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name] [loc]. Simply enter the code \"[pda_pass]\" into the ringtone select to unlock its hidden features."
			traitor_mob.mind.store_memory("<B>Uplink Passcode:</B> [pda_pass] ([R.name] [loc]).")

/*	var/obj/item/device/R = null //Hide the uplink in a PDA if available, otherwise radio
	if (!R && istype(traitor_mob.belt, /obj/item/device/pda))
		R = traitor_mob.belt
		loc = "on your belt"
	if (!R && istype(traitor_mob.l_hand, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = traitor_mob.l_hand
		var/list/L = S.return_inv()
		for (var/obj/item/device/radio/foo in L)
			R = foo
			loc = "in the [S.name] in your left hand"
			break
	if (!R && istype(traitor_mob.r_hand, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = traitor_mob.r_hand
		var/list/L = S.return_inv()
		for (var/obj/item/device/radio/foo in L)
			R = foo
			loc = "in the [S.name] in your right hand"
			break
	if (!R && istype(traitor_mob.back, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = traitor_mob.back
		var/list/L = S.return_inv()
		for (var/obj/item/device/radio/foo in L)
			R = foo
			loc = "in the [S.name] on your back"
			break
	if (!R && traitor_mob.w_uniform && istype(traitor_mob.belt, /obj/item/device/radio))
		R = traitor_mob.belt
		loc = "on your belt"
	if (!R && istype(traitor_mob.ears, /obj/item/device/radio))
		R = traitor_mob.ears
		loc = "on your head"
	if (!R)
		traitor_mob << "Unfortunately, the Syndicate wasn't able to get you a radio."
	else
		if (istype(R, /obj/item/device/radio))
			// generate list of radio freqs
			while (freq <= 1489)
				if (freq < 1451 || freq > 1459)
					freqlist += freq
				freq += 2
				if ((freq % 2) == 0)
					freq += 1
			freq = freqlist[rand(1, freqlist.len)]

			var/obj/item/device/uplink/radio/T = new /obj/item/device/uplink/radio(R)
			R:traitorradio = T
			R:traitor_frequency = freq
			T.name = R.name
			T.icon_state = R.icon_state
			T.origradio = R
			traitor_mob << "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name] [loc]. Simply dial the frequency [format_frequency(freq)] to unlock its hidden features."
			traitor_mob.mind.store_memory("<B>Radio Freq:</B> [format_frequency(freq)] ([R.name] [loc]).")
		else if (istype(R, /obj/item/device/pda))
			var/obj/item/device/uplink/pda/T = new /obj/item/device/uplink/pda(R)
			R:uplink = T
			T.unlocking_code = pda_pass
			T.hostpda = R
			traitor_mob << "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name] [loc]. Simply enter the code \"[pda_pass]\" into the ringtone select to unlock its hidden features."
			traitor_mob.mind.store_memory("<B>Uplink Passcode:</B> [pda_pass] ([R.name] [loc]).")*/