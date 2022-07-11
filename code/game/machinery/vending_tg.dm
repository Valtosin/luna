/datum/data/vending_producttg
	var/product_name = "generic"
	var/product_path = null
	var/amount = 0
	var/display_color = "blue"


/obj/machinery/vending_tg
	name = "\improper Vendomat"
	desc = "A generic vending machine."
	icon = 'icons/obj/vending.dmi'
	icon_state = "generic"
	layer = 2.9
	anchored = 1
	density = 1
	var/active = 1		//No sales pitches if off!
	var/vend_ready = 1	//Are we ready to vend?? Is it time??
	var/vend_delay = 10	//How long does it take to vend?

	// To be filled out at compile time
	var/list/products	= list()	//For each, use the following pattern:
	var/list/contraband	= list()	//list(/type/path = amount,/type/path2 = amount2)
	var/list/premium 	= list()	//No specified amount = only one in stock

	var/product_slogans = ""	//String of slogans separated by semicolons, optional
	var/product_ads = ""		//String of small ad messages in the vending screen - random chance
	var/list/product_records = list()
	var/list/hidden_records = list()
	var/list/coin_records = list()
	var/list/slogan_list = list()
	var/list/small_ads = list()	//Small ad messages in the vending screen - random chance of popping up whenever you open it
	var/vend_reply				//Thank you for shopping!
	var/last_reply = 0
	var/last_slogan = 0			//When did we last pitch?
	var/slogan_delay = 6000		//How long until we can pitch again?
	var/icon_vend				//Icon_state when vending!
	var/icon_deny				//Icon_state when vending!
	var/seconds_electrified = 0	//Shock customers like an airlock.
	var/shoot_inventory = 0		//Fire items at customers! We're broken!
	var/shut_up = 1				//Stop spouting those godawful pitches!
	var/extended_inventory = 0	//can we access the hidden inventory?
	var/panel_open = 0			//Hacking that vending machine. Gonna get a free candy bar.
	var/scan_id = 1
	var/obj/item/weapon/coin/coin
	var/datum/wires/vending/wires = null


/obj/machinery/vending_tg/New()
	..()
	wires = new(src)
	spawn(4)
		slogan_list = text2list(product_slogans, ";")

		// So not all machines speak at the exact same time.
		// The first time this machine says something will be at slogantime + this random value,
		// so if slogantime is 10 minutes, it will say it at somewhere between 10 and 20 minutes after the machine is crated.
		last_slogan = world.time + rand(0, slogan_delay)

		build_inventory(products)
		 //Add hidden inventory
		build_inventory(contraband, 1)
		build_inventory(premium, 0, 1)
		power_change()


/obj/machinery/vending_tg/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if(prob(50))
				del(src)
				return
		if(3.0)
			if(prob(25))
				malfunction()


/obj/machinery/vending_tg/blob_act()
	if(prob(75))
		malfunction()
	else
		del(src)


/obj/machinery/vending_tg/proc/build_inventory(list/productlist, hidden=0, req_coin=0)
	for(var/typepath in productlist)
		var/amount = productlist[typepath]
		if(isnull(amount)) amount = 1

		var/atom/temp = new typepath(null)
		var/datum/data/vending_producttg/R = new /datum/data/vending_producttg()
		R.product_name = temp.name
		R.product_path = typepath
		R.amount = amount
		R.display_color = pick("red","blue","green")

		if(hidden)
			hidden_records += R
		else if(req_coin)
			coin_records += R
		else
			product_records += R
//		world << "Added: [R.product_name]] - [R.amount] - [R.product_path]"


/obj/machinery/vending_tg/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/card/emag))
		emagged = 1
		user << "You short out the product lock on [src]"
		return
	else if(istype(W, /obj/item/weapon/screwdriver))
		panel_open = !panel_open
		user << "You [panel_open ? "open" : "close"] the maintenance panel."
		overlays.Cut()
		if(panel_open)
			overlays += image(icon, "[initial(icon_state)]-panel")
		updateUsrDialog()
		return
	else if(istype(W, /obj/item/device/multitool)||istype(W, /obj/item/weapon/wirecutters))
		if(panel_open)
			attack_hand(user)
		return
	else if(istype(W, /obj/item/weapon/coin) && premium.len > 0)
		user.drop_item()
		W.loc = src
		coin = W
		user << "<span class='notice'>You insert [W] into [src].</span>"
		return
	else
		..()


/obj/machinery/vending_tg/attack_paw(mob/user)
	return attack_hand(user)


/obj/machinery/vending_tg/attack_ai(mob/user)
	return attack_hand(user)


/obj/machinery/vending_tg/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	user.set_machine(src)

	if(seconds_electrified != 0)
		if(shock(user, 100))
			return

	var/dat = ""

	if(premium.len > 0)
		dat += "<TT><b>Coin slot:</b> "
		if (coin)
			dat += "[coin] <a href='byond://?src=\ref[src];remove_coin=1'>Remove</A></TT><br><br>"
		else
			dat += "No coin<br><br></TT>"
	dat += "<TT><b>Select an item:</b></TT><br>"
	dat += "<TABLE width=100%><TR><TD><TT><B>Product:</B></TT></TD> <TD><TT><B>Amount:</B></TT></TD><TD></TD></TR>"
//	dat += "<div class='statusDisplay'>"
	if(product_records.len == 0)
		dat += "<font color = 'red'>No product loaded!</font>"
	else
		var/list/display_records = product_records
		if(extended_inventory)
			display_records = product_records + hidden_records
		if(coin)
			display_records = product_records + coin_records
		if(coin && extended_inventory)
			display_records = product_records + hidden_records + coin_records
		//dat += "<ul>"
		for (var/datum/data/vending_producttg/R in display_records)
			//dat += "<li>"
			dat += "<TR><TD><TT><FONT color = '[R.display_color]'><B>[R.product_name]</B></TT></TD>"
			dat += " <TD><TT>[R.amount]</TT></TD></font>"
			if(R.amount > 0)
				dat += "<TD><TT><a href='byond://?src=\ref[src];vend=\ref[R]'>Vend</A></TT></TD></TR>"
			else
				dat += "<TD><TT><span class='linkOff'>Sold Out</span></TD></TT></TR>"

//			if(R.amount > 0)
//				dat += "<a href='byond://?src=\ref[src];vend=\ref[R]'>Vend</A> "
//			else
//				dat += "<span class='linkOff'>Sold Out</span> "
//			dat += "<FONT color = '[R.display_color]'><B>[R.product_name]</B>:</font>"
//			dat += " <b>[R.amount]</b>"
//			dat += "</li>"
		//dat += "</ul>"
	//dat += "</div>"
	dat += "</TABLE>"

	if(panel_open)
		dat += wires()

		if(product_slogans != "")
			dat += "The speaker switch is [shut_up ? "off" : "on"]. <a href='?src=\ref[src];togglevoice=[1]'>Toggle</a>"

	user << browse(dat, "window=vending")
	onclose(user, "")
//	var/datum/browser/popup = new(user, "vending", (name))
//	popup.set_content(dat)
//	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
//	popup.open()


// returns the wire panel text
/obj/machinery/vending_tg/proc/wires()
	return wires.GetInteractWindow()


/obj/machinery/vending_tg/Topic(href, href_list)
	if(..())
		return

	if(istype(usr,/mob/living/silicon))
		if(istype(usr,/mob/living/silicon/robot))
//			var/mob/living/silicon/robot/R = usr
//			if(!(R.module && istype(R.module,/obj/item/weapon/robot_module/butler) ))
			usr << "<span class='notice'>The vending machine refuses to interface with you, as you are not in its target demographic!</span>"
			return
		else
			usr << "<span class='notice'>The vending machine refuses to interface with you, as you are not in its target demographic!</span>"
			return


	if(href_list["remove_coin"])
		if(!coin)
			usr << "<span class='notice'>There is no coin in this machine.</span>"
			return

		coin.loc = loc
		if(!usr.get_active_hand())
			usr.put_in_hands(coin)
		usr << "<span class='notice'>You remove [coin] from [src].</span>"
		coin = null


	usr.set_machine(src)
	if((href_list["vend"]) && (vend_ready))
		if((!allowed(usr)) && !emagged && scan_id)	//For SECURE VENDING MACHINES YEAH
			usr << "<span class='warning'>Access denied.</span>"	//Unless emagged of course
			flick(icon_deny,src)
			return

		vend_ready = 0 //One thing at a time!!

		var/datum/data/vending_producttg/R = locate(href_list["vend"])
		if(!R || !istype(R) || !R.product_path || R.amount <= 0)
			vend_ready = 1
			return

		if(R in coin_records)
			if(!coin)
				usr << "<span class='notice'>You need to insert a coin to get this item.</span>"
				return
			if(coin.string_attached)
				if(prob(80))
					usr << "<span class='notice'>You successfully pull the coin out before [src] could swallow it.</span>"
				else
					usr << "<span class='notice'>You weren't able to pull the coin out fast enough, the machine ate it, string and all.</span>"
					del(coin)
			else
				del(coin)

		R.amount--

		if(((last_reply + (vend_delay + 200)) <= world.time) && vend_reply)
			speak(vend_reply)
			last_reply = world.time

		use_power(5)
		if(icon_vend) //Show the vending animation if needed
			flick(icon_vend,src)
		spawn(vend_delay)
			new R.product_path(get_turf(src))
			vend_ready = 1
			return

		updateUsrDialog()
		return

	else if(href_list["togglevoice"] && panel_open)
		shut_up = !shut_up

	updateUsrDialog()


/obj/machinery/vending_tg/process()
	if(stat & (BROKEN|NOPOWER))
		return
	if(!active)
		return

	if(seconds_electrified > 0)
		seconds_electrified--

	//Pitch to the people!  Really sell it!
	if(last_slogan + slogan_delay <= world.time && slogan_list.len > 0 && !shut_up && prob(10))
		var/slogan = pick(slogan_list)
		speak(slogan)
		last_slogan = world.time

	if(shoot_inventory && prob(2))
		throw_item()


/obj/machinery/vending_tg/proc/speak(message)
	if(stat & (BROKEN|NOPOWER))
		return
	if(!message)
		return

	visible_message("<span class='name'>[src]</span> <span class='game say'>beeps, \"[message]\"</span>")


/obj/machinery/vending_tg/power_change()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
	else
		if(powered())
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
		else
			icon_state = "[initial(icon_state)]-off"
			stat |= NOPOWER


//Oh no we're malfunctioning!  Dump out some product and break.
/obj/machinery/vending_tg/proc/malfunction()
	for(var/datum/data/vending_product/R in product_records)
		if(R.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		var/dump_path = R.product_path
		if(!dump_path)
			continue

		while(R.amount>0)
			new dump_path(loc)
			R.amount--
		break

	stat |= BROKEN
	icon_state = "[initial(icon_state)]-broken"
	return

//Somebody cut an important wire and now we're following a new definition of "pitch."
/obj/machinery/vending_tg/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(5,src)
	if(!target)
		return 0
	var/turf/target_turf = get_turf(target)
	if(prob(15)) target_turf = locate(target_turf.x + 1, target_turf.y, target_turf.z)
	if(prob(15)) target_turf = locate(target_turf.x - 1, target_turf.y, target_turf.z)
	if(prob(15)) target_turf = locate(target_turf.x, target_turf.y + 1, target_turf.z)
	if(prob(15)) target_turf = locate(target_turf.x, target_turf.y - 1, target_turf.z)

	if(!target_turf)
		return 0

	for(var/datum/data/vending_product/R in product_records)
		if(R.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		var/dump_path = R.product_path
		if(!dump_path)
			continue

		R.amount--
		throw_item = new dump_path(loc)
		break
	if(!throw_item)
		return 0

	throw_item.throw_at(target_turf, 16, 3)
	visible_message("<span class='danger'>[src] launches [throw_item] at [target]!</span>")
	return 1


/obj/machinery/vending_tg/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
//	if(electrocute_mob(user, get_area(src), src, 0.7))
//		return 1
//	else
//		return 0

/*
 * Vending machine types
 */

/*

/obj/machinery/vending_tg/[vendors name here]   // --vending machine template   :)
	name = ""
	desc = ""
	icon = ''
	icon_state = ""
	vend_delay = 15
	products = list()
	contraband = list()
	premium = list()

*/

/*
/obj/machinery/vending_tg/atmospherics //Commenting this out until someone ponies up some actual working, broken, and unpowered sprites - Quarxink
	name = "Tank Vendor"
	desc = "A vendor with a wide variety of masks and gas tanks."
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser"
	product_paths = "/obj/item/weapon/tank/oxygen;/obj/item/weapon/tank/plasma;/obj/item/weapon/tank/emergency_oxygen;/obj/item/weapon/tank/emergency_oxygen/engi;/obj/item/clothing/mask/breath"
	product_amounts = "10;10;10;5;25"
	vend_delay = 0
*/

/obj/machinery/vending_tg/boozeomat
	name = "\improper Booze-O-Mat"
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	icon_state = "boozeomat"        //////////////18 drink entities below, plus the glasses, in case someone wants to edit the number of bottles
	icon_deny = "boozeomat-deny"
	products = list(/obj/item/weapon/reagent_containers/food/drinks/bottle/gin = 5,/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/tequilla = 5,/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth = 5,/obj/item/weapon/reagent_containers/food/drinks/bottle/rum = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/wine = 5,/obj/item/weapon/reagent_containers/food/drinks/bottle/cognac = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua = 5,/obj/item/weapon/reagent_containers/food/drinks/beer = 6,
					/obj/item/weapon/reagent_containers/food/drinks/ale = 6,/obj/item/weapon/reagent_containers/food/drinks/bottle/orangejuice = 4,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/tomatojuice = 4,/obj/item/weapon/reagent_containers/food/drinks/bottle/limejuice = 4,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/cream = 4,/obj/item/weapon/reagent_containers/food/drinks/soda/tonic = 8,
					/obj/item/weapon/reagent_containers/food/drinks/soda/cola = 8, /obj/item/weapon/reagent_containers/food/drinks/soda/sodawater = 15,
					/obj/item/weapon/reagent_containers/food/drinks/drinkingglass = 30,/obj/item/weapon/reagent_containers/food/drinks/ice = 9)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/cup/tea = 10)
	vend_delay = 15
	product_slogans = "I hope nobody asks me for a bloody cup o' tea...;Alcohol is humanity's friend. Would you abandon a friend?;Quite delighted to serve you!;Is nobody thirsty on this station?"
	product_ads = "Drink up!;Booze is good for you!;Alcohol is humanity's best friend.;Quite delighted to serve you!;Care for a nice, cold beer?;Nothing cures you like booze!;Have a sip!;Have a drink!;Have a beer!;Beer is good for you!;Only the finest alcohol!;Best quality booze since 2053!;Award-winning wine!;Maximum alcohol!;Man loves beer.;A toast for progress!"
	req_access_txt = "25"

/obj/machinery/vending_tg/assist
	products = list(	/obj/item/device/assembly/prox_sensor = 5,/obj/item/device/assembly/igniter = 5,/obj/item/device/assembly/signaler = 5,
						/obj/item/weapon/wirecutters = 2, /obj/item/weapon/cartridge/signal = 4)
	contraband = list(/obj/item/device/flashlight = 5,/obj/item/device/assembly/timer = 2/*, /obj/item/device/assembly/voice = 2*/)
	product_ads = "Only the finest!;Have some tools.;The most robust equipment.;The finest gear in space!"

/obj/machinery/vending_tg/coffee
	name = "hot drinks machine"
	desc = "A vending machine which dispenses hot drinks."
	product_ads = "Have a drink!;Drink up!;It's good for you!;Would you like a hot joe?;I'd kill for some coffee!;The best beans in the galaxy.;Only the finest brew for you.;Mmmm. Nothing like a coffee.;I like coffee, don't you?;Coffee helps you work!;Try some tea.;We hope you like the best!;Try our new chocolate!;Admin conspiracies"
	icon_state = "coffee"
	icon_vend = "coffee-vend"
	vend_delay = 34
	products = list(/obj/item/weapon/reagent_containers/food/drinks/coffee = 25,/obj/item/weapon/reagent_containers/food/drinks/cup/tea = 25,/obj/item/weapon/reagent_containers/food/drinks/cup/h_chocolate = 25)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/ice = 10)



/obj/machinery/vending_tg/snack
	name = "\improper Getmore Chocolate Corp"
	desc = "A snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars"
	product_slogans = "Try our new nougat bar!;Twice the calories for half the price!"
	product_ads = "The healthiest!;Award-winning chocolate bars!;Mmm! So good!;Oh my god it's so juicy!;Have a snack.;Snacks are good for you!;Have some more Getmore!;Best quality snacks straight from mars.;We love chocolate!;Try our new jerky!"
	icon_state = "snack"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/candy = 6,/obj/item/weapon/reagent_containers/food/drinks/dry_ramen = 6,/obj/item/weapon/reagent_containers/food/snacks/chips =6,
					/obj/item/weapon/reagent_containers/food/snacks/sosjerky = 6,/obj/item/weapon/reagent_containers/food/snacks/no_raisin = 6,/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie = 6,
					/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers = 6)
	contraband = list(/obj/item/weapon/reagent_containers/food/snacks/syndicake = 6)



/obj/machinery/vending_tg/cola
	name = "\improper Robust Softdrinks"
	desc = "A softdrink vendor provided by Robust Industries, LLC."
	icon_state = "Cola_Machine"
	product_slogans = "Robust Softdrinks: More robust than a toolbox to the head!"
	product_ads = "Refreshing!;Hope you're thirsty!;Over 1 million drinks sold!;Thirsty? Why not cola?;Please, have a drink!;Drink up!;The best drinks in space."
	products = list(/obj/item/weapon/reagent_containers/food/drinks/soda/cola = 10,/obj/item/weapon/reagent_containers/food/drinks/soda/space_mountain_wind = 10,
					/obj/item/weapon/reagent_containers/food/drinks/soda/dr_gibb = 10,/obj/item/weapon/reagent_containers/food/drinks/soda/starkist = 10,
					/obj/item/weapon/reagent_containers/food/drinks/soda/space_up = 10)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/soda/thirteenloko = 5,/obj/item/weapon/reagent_containers/food/drinks/soda/rootbeer = 5)

/obj/machinery/vending_tg/cola/soda
	icon_state = "soda"

//This one's from bay12
/obj/machinery/vending_tg/cart
	name = "\improper PTech"
	desc = "Cartridges for PDAs"
	product_slogans = "Carts to go!"
	icon_state = "cart"
	icon_deny = "cart-deny"
	products = list(/obj/item/weapon/cartridge/medical = 10,/obj/item/weapon/cartridge/engineering = 10,/obj/item/weapon/cartridge/security = 10,
					/obj/item/weapon/cartridge/janitor = 10,/obj/item/weapon/cartridge/signal/toxins = 10,/obj/item/device/pda/heads = 10,
					/obj/item/weapon/cartridge/captain = 3,/obj/item/weapon/cartridge/quartermaster = 10)


/obj/machinery/vending_tg/cigarette
	name = "cigarette machine" //OCD had to be uppercase to look nice with the new formating
	desc = "If you want to get cancer, might as well do it in style"
	product_slogans = "Space cigs taste good like a cigarette should.;I'd rather toolbox than switch.;Smoke!;Don't believe the reports - smoke today!"
	product_ads = "Probably not bad for you!;Don't believe the scientists!;It's good for you!;Don't quit, buy more!;Smoke!;Nicotine heaven.;Best cigarettes since 2150.;Award-winning cigs."
	vend_delay = 34
	icon_state = "cigs"
	products = list(/obj/item/weapon/cigpacket = 10,/obj/item/weapon/storage/matches = 10,/obj/item/weapon/lighter/random = 4)
	contraband = list(/obj/item/weapon/lighter/zippo = 4)
	premium = list(/obj/item/clothing/mask/cigarette/cigar/havana = 2, /obj/item/weapon/cigpacket/med = 2)

/obj/machinery/vending_tg/medical
	name = "\improper NanoMed Plus"
	desc = "Medical drug dispenser."
	icon_state = "med"
	icon_deny = "med-deny"
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	req_access_txt = "5"
	products = list(/obj/item/weapon/reagent_containers/glass/bottle/antitoxin = 4,/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline = 4,
					/obj/item/weapon/reagent_containers/glass/bottle/stoxin = 4,/obj/item/weapon/reagent_containers/glass/bottle/toxin = 4,
					/obj/item/weapon/reagent_containers/syringe/antiviral = 4,/obj/item/weapon/reagent_containers/syringe = 12,
					/obj/item/device/healthanalyzer = 5,/obj/item/weapon/reagent_containers/glass/beaker = 4, /obj/item/weapon/reagent_containers/dropper = 2)
	contraband = list(/obj/item/weapon/reagent_containers/pill/tox = 3,/obj/item/weapon/reagent_containers/pill/stox = 4,/obj/item/weapon/reagent_containers/pill/antitox = 6)


//This one's from bay12
/obj/machinery/vending_tg/plasmaresearch
	name = "\improper Toximate 3000"
	desc = "All the fine parts you need in one vending machine!"
	products = list(/obj/item/clothing/under/rank/scientist = 6,/obj/item/clothing/suit/bio_suit = 6,/obj/item/clothing/head/bio_hood = 6,
					/obj/item/device/transfer_valve = 6,/obj/item/device/assembly/timer = 6,/obj/item/device/assembly/signaler = 6,
					/obj/item/device/assembly/prox_sensor = 6,/obj/item/device/assembly/igniter = 6)

/obj/machinery/vending_tg/wallmed
	name = "\improper NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?"
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	density = 0 //It is wall-mounted, and thus, not dense. --Superxpdude
	products = list(/obj/item/stack/medical/bruise_pack = 3, /obj/item/stack/medical/ointment = 3, /obj/item/stack/medical/bandaid = 2,
					/obj/item/weapon/reagent_containers/syringe/inaprovaline = 4, /obj/item/weapon/reagent_containers/syringe/antitoxin = 4,
					/obj/item/weapon/reagent_containers/syringe/antiviral = 4, /obj/item/device/healthanalyzer = 2)
	contraband = list(/obj/item/weapon/reagent_containers/pill/tox = 2, /obj/item/weapon/reagent_containers/glass/bottle/stoxin = 2)

/obj/machinery/vending_tg/security
	name = "\improper SecTech"
	desc = "A security equipment vendor"
	product_ads = "Crack capitalist skulls!;Beat some heads in!;Don't forget - harm is good!;Your weapons are right here.;Handcuffs!;Freeze, scumbag!;Don't tase me bro!;Tase them, bro.;Why not have a donut?"
	icon_state = "sec"
	icon_deny = "sec-deny"
	req_access_txt = "1"
	products = list(/obj/item/weapon/handcuffs = 16,/obj/item/weapon/grenade/flashbang = 8,/obj/item/device/flash = 8,/obj/item/weapon/melee/baton = 4,/obj/item/clothing/glasses/sunglasses = 2,
					/obj/item/weapon/gun/energy/taser = 2, /obj/item/weapon/reagent_containers/food/snacks/donut/normal = 12,/obj/item/weapon/storage/box/evidence = 2)
	contraband = list(/obj/item/kitchen/donut_box = 2, /obj/item/weapon/gun/energy/gun = 1)
/*
/obj/machinery/vending_tg/hydronutrients
	name = "\improper NutriMax"
	desc = "A plant nutrients vendor"
	product_slogans = "Aren't you glad you don't have to fertilize the natural way?;Now with 50% less stink!;Plants are people too!"
	product_ads = "We like plants!;Don't you want some?;The greenest thumbs ever.;We like big plants.;Soft soil..."
	icon_state = "nutri"
	icon_deny = "nutri-deny"
	products = list(/obj/item/nutrient/ez = 35,/obj/item/nutrient/l4z = 25,/obj/item/nutrient/rh = 15,/obj/item/weapon/pestspray = 20,
					/obj/item/weapon/reagent_containers/syringe = 5,/obj/item/weapon/storage/bag/plants = 5)
	contraband = list(/obj/item/weapon/reagent_containers/glass/bottle/ammonia = 10,/obj/item/weapon/reagent_containers/glass/bottle/diethylamine = 5)

/obj/machinery/vending_tg/hydroseeds
	name = "\improper MegaSeed Servitor"
	desc = "When you need seeds fast!"
	product_slogans = "THIS'S WHERE TH' SEEDS LIVE! GIT YOU SOME!;Hands down the best seed selection on the station!;Also certain mushroom varieties available, more for experts! Get certified today!"
	product_ads = "We like plants!;Grow some crops!;Grow, baby, growww!;Aw h'yeah son!"
	icon_state = "seeds"
	products = list(/obj/item/seeds/bananaseed = 3,/obj/item/seeds/berryseed = 3,/obj/item/seeds/carrotseed = 3,/obj/item/seeds/chantermycelium = 3,/obj/item/seeds/chiliseed = 3,
					/obj/item/seeds/cornseed = 3, /obj/item/seeds/eggplantseed = 3, /obj/item/seeds/potatoseed = 3, /obj/item/seeds/replicapod = 3,/obj/item/seeds/soyaseed = 3,
					/obj/item/seeds/sunflowerseed = 3,/obj/item/seeds/tomatoseed = 3,/obj/item/seeds/towermycelium = 3,/obj/item/seeds/wheatseed = 3,/obj/item/seeds/appleseed = 3,
					/obj/item/seeds/poppyseed = 3,/obj/item/seeds/ambrosiavulgarisseed = 3,/obj/item/seeds/whitebeetseed = 3,/obj/item/seeds/watermelonseed = 3,/obj/item/seeds/limeseed = 3,
					/obj/item/seeds/lemonseed = 3,/obj/item/seeds/orangeseed = 3,/obj/item/seeds/grassseed = 3,/obj/item/seeds/cocoapodseed = 3,
					/obj/item/seeds/cabbageseed = 3,/obj/item/seeds/grapeseed = 3,/obj/item/seeds/pumpkinseed = 3,/obj/item/seeds/cherryseed = 3)
	contraband = list(/obj/item/seeds/amanitamycelium = 2,/obj/item/seeds/glowshroom = 2,/obj/item/seeds/libertymycelium = 2,/obj/item/seeds/nettleseed = 2,
						/obj/item/seeds/plumpmycelium = 2,/obj/item/seeds/reishimycelium = 2)
	premium = list(/obj/item/weapon/reagent_containers/spray/waterflower = 1)
*/

/obj/machinery/vending_tg/magivend
	name = "\improper MagiVend"
	desc = "A magic vending machine."
	icon_state = "MagiVend"
	product_slogans = "Sling spells the proper way with MagiVend!;Be your own Houdini! Use MagiVend!"
	vend_delay = 15
	vend_reply = "Have an enchanted evening!"
	product_ads = "FJKLFJSD;AJKFLBJAKL;1234 LOONIES LOL!;>MFW;Kill them fuckers!;GET DAT FUKKEN DISK;HONK!;EI NATH;Destroy the station!;Admin conspiracies since forever!;Space-time bending hardware!"
	products = list(/obj/item/clothing/head/wizard = 1,/obj/item/clothing/suit/wizrobe = 1,/obj/item/clothing/head/wizard/red = 1,/obj/item/clothing/suit/wizrobe/red = 1,/obj/item/clothing/shoes/sandal = 1,/obj/item/weapon/staff = 2)
	contraband = list(/obj/item/weapon/reagent_containers/glass/bottle/virus/wizarditis = 1, /obj/item/weapon/staff/magical/test = 1)	//No one can get to the machine to hack it anyways; for the lulz - Microwave
/*
/obj/machinery/vending_tg/dinnerware
	name = "dinnerware"
	desc = "A kitchen and restaurant equipment vendor"
	product_ads = "Mm, food stuffs!;Food and food accessories.;Get your plates!;You like forks?;I like forks.;Woo, utensils.;You don't really need these..."
	icon_state = "dinnerware"
	products = list(/obj/item/weapon/tray = 8,/obj/item/weapon/kitchen/utensil/fork = 6,/obj/item/weapon/kitchenknife = 3,/obj/item/weapon/reagent_containers/food/drinks/drinkingglass = 8,/obj/item/clothing/suit/chef/classic = 2)
	contraband = list(/obj/item/weapon/kitchen/rollingpin = 2, /obj/item/weapon/butch = 2)
*/
/obj/machinery/vending_tg/sovietsoda
	name = "\improper BODA"
	desc = "Old sweet water vending machine"
	icon_state = "sovietsoda"
	product_ads = "For Tsar and Country.;Have you fulfilled your nutrition quota today?;Very nice!;We are simple people, for this is all we eat.;If there is a person, there is a problem. If there is no person, then there is no problem."
	products = list(/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/soda = 30)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/cola = 20)

/obj/machinery/vending_tg/tool
	name = "\improper YouTool"
	desc = "Tools for tools."
	icon_state = "tool"
	icon_deny = "tool-deny"
	//req_access_txt = "12" //Maintenance access
	products = list(/obj/item/weapon/cable_coil = 10,/obj/item/weapon/crowbar = 5,/obj/item/weapon/weldingtool = 4,/obj/item/weapon/wirecutters = 5,
					/obj/item/weapon/wrench = 5,/obj/item/device/analyzer = 5,/obj/item/device/t_scanner = 5,/obj/item/weapon/screwdriver = 5)
	contraband = list(/obj/item/weapon/weldingtool/industrial = 2,/obj/item/clothing/gloves/fyellow = 4)
	premium = list(/obj/item/clothing/gloves/yellow = 2)

/*obj/machinery/vending_tg/engivend
	name = "\improper Engi-Vend"
	desc = "Spare tool vending. What? Did you expect some witty description?"
	icon_state = "engivend"
	icon_deny = "engivend-deny"
//	req_access_txt = "11" //Engineering Equipment access
	products = list(/obj/item/clothing/glasses/meson = 2,/obj/item/device/multitool = 4,/obj/item/weapon/airlock_electronics = 10,/obj/item/weapon/module/power_control = 10,/obj/item/weapon/airalarm_electronics = 10,/obj/item/weapon/cell/high = 10)
	contraband = list(/obj/item/weapon/cell/potato = 3)
	premium = list(/obj/item/weapon/storage/belt/utility = 3)*/

//This one's from bay12
/obj/machinery/vending_tg/engineering
	name = "\improper Robco Tool Maker"
	desc = "Everything you need for do-it-yourself station repair."
	icon_state = "engi"
	icon_deny = "engi-deny"
	req_access_txt = "11"
	products = list(/obj/item/clothing/under/rank/chief_engineer = 4,/obj/item/clothing/under/rank/engineer = 4,/obj/item/clothing/shoes/orange = 4,/obj/item/clothing/head/helmet/hardhat = 4,
					/obj/item/weapon/storage/belt/utility = 4,/obj/item/clothing/glasses/meson = 4,/obj/item/clothing/gloves/yellow = 4, /obj/item/weapon/screwdriver = 12,
					/obj/item/weapon/crowbar = 12,/obj/item/weapon/wirecutters = 12,/obj/item/device/multitool = 12,/obj/item/weapon/wrench = 12,/obj/item/device/t_scanner = 12,
					/obj/item/weapon/cell/high = 8, /obj/item/weapon/weldingtool = 8,/obj/item/clothing/head/helmet/welding = 8,
					/obj/item/weapon/light/tube = 10,/obj/item/clothing/suit/fire = 4, /obj/item/weapon/stock_parts/scanning_module = 5,/obj/item/weapon/stock_parts/micro_laser = 5,
					/obj/item/weapon/stock_parts/matter_bin = 5,/obj/item/weapon/stock_parts/manipulator = 5,/obj/item/weapon/stock_parts/console_screen = 5)
	// There was an incorrect entry (cablecoil/power).  I improvised to cablecoil/heavyduty.
	// Another invalid entry, /obj/item/weapon/circuitry.  I don't even know what that would translate to, removed it.
	// The original products list wasn't finished.  The ones without given quantities became quantity 5.  -Sayu

//This one's from bay12
/obj/machinery/vending_tg/robotics
	name = "\improper Robotech Deluxe"
	desc = "All the tools you need to create your own robot army."
	icon_state = "robotics"
	icon_deny = "robotics-deny"
	req_access_txt = "29"
	products = list(/obj/item/clothing/suit/storage/labcoat = 2,/obj/item/clothing/under/rank/roboticist = 2,/obj/item/weapon/cable_coil = 4,/obj/item/device/flash = 6,
					/obj/item/weapon/cell/high/empty = 10, /obj/item/device/assembly/prox_sensor = 4,/obj/item/device/assembly/signaler = 4,/obj/item/device/healthanalyzer = 4,
					/obj/item/weapon/surgical/scalpel = 2,/obj/item/weapon/surgical/circular_saw = 2,/obj/item/weapon/tank/anesthetic = 4,/obj/item/clothing/mask/breath/medical = 4,
					/obj/item/weapon/screwdriver = 5,/obj/item/weapon/crowbar = 5)
	contraband = list(/obj/item/weapon/stock_parts/scanning_module = 2,/obj/item/weapon/stock_parts/micro_laser = 3,
					/obj/item/weapon/stock_parts/matter_bin = 5,/obj/item/weapon/stock_parts/manipulator = 3,/obj/item/weapon/stock_parts/console_screen = 2)
	//everything after the power cell had no amounts, I improvised.  -Sayu

