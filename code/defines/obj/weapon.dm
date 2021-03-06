/obj/item/weapon
	name = "weapon"
	icon = 'weapons.dmi'

/obj/item/device/analyzer
	desc = "A hand-held environmental scanner which reports current gas levels."
	name = "analyzer"
	icon_state = "atmos"
	item_state = "analyzer"
	w_class = 2.0
	flags = FPRINT | CONDUCT
	throwforce = 5
	w_class = 2.0
	throw_speed = 4
	origin_tech = "magnets=1;engineering=1"
	throw_range = 20

/obj/item/weapon/c_tube
	name = "cardboard tube"
	icon = 'items.dmi'
	icon_state = "c_tube"
	throwforce = 1
	w_class = 1.0
	throw_speed = 4
	throw_range = 5

/obj/item/weapon/card
	name = "card"
	icon = 'card.dmi'
	w_class = 1.0

	var/list/files = list(  )

/obj/item/weapon/card/data
	name = "data card"
	icon_state = "data"
	var/function = "storage"
	var/data = "null"
	var/special = null
	item_state = "card-id"

/obj/item/weapon/card/emag
	desc = "It's a card with a magnetic strip attached to some circuitry."
	name = "cryptographic sequencer"
	icon_state = "emag"
	item_state = "card-id"
	origin_tech = "magnets=2;syndicate=2"

/obj/item/weapon/card/id
	name = "identification card"
	icon_state = "id"
	item_state = "card-id"
	var/access = list()
	var/registered = null
	var/assignment = null
/obj/item/weapon/card/id/attackby()
	return

/obj/item/weapon/card/id/gold
	name = "identification card"
	icon_state = "gold"
	item_state = "gold_id"

/obj/item/weapon/card/id/syndicate
	name = "agent id card"
	origin_tech = "syndicate=3"
	access = list(access_maint_tunnels)

/obj/item/weapon/card/id/syndicate/afterattack(var/obj/item/weapon/O as obj, mob/user as mob)
	if(istype(O, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/I = O
		src.access |= I.access
		usr << "\blue The card's microscanners activate as you pass it over the ID, copying its access."

/obj/item/weapon/card/id/captains_spare
	name = "Captain's spare ID"
	icon_state = "gold"
	item_state = "gold_id"
	registered = "Captain"
	assignment = "Captain"
	New()
		access = get_access("Captain")
		..()

/obj/item/device/cloak
	name = "cloaking device"
	desc = "Use this to become invisible to the human eyesocket."
	icon = 'device.dmi'
	icon_state = "shield0"
	var/active = 0.0
	flags = FPRINT | CONDUCT
	item_state = "electronic"
	throwforce = 10.0
	throw_speed = 2
	throw_range = 10
	w_class = 2.0
	origin_tech = "magnets=3;syndicate=4"

/obj/item/weapon/crowbar
	name = "crowbar"
	icon = 'items.dmi'
	icon_state = "crowbar"
	flags = FPRINT | CONDUCT
	force = 5.0
	throwforce = 7.0
	item_state = "wrench"
	w_class = 2.0
	m_amt = 50
	origin_tech = "engineering=1"

/obj/item/weapon/crowbar/red
	name = "red crowbar"
	desc = "It looks dangerously robust."
	icon_state = "red_crowbar"
	force = 10.0

/obj/item/weapon/dummy
	name = "dummy"
	invisibility = 101.0
	anchored = 0
	flags = 0

/obj/item/weapon/f_card
	name = "fingerprint card"
	icon = 'card.dmi'
	icon_state = "fingerprint0"
	var/amount = 10.0
	item_state = "paper"
	throwforce = 1
	w_class = 1.0
	throw_speed = 3
	throw_range = 5


/obj/item/weapon/fcardholder
	name = "fingerprint case"
	icon = 'items.dmi'
	icon_state = "fcardholder0"
	item_state = "clipboard"

/obj/item/weapon/game_kit
	name = "gaming kit"
	icon = 'items.dmi'
	icon_state = "game_kit"
	var/selected = null
	var/board_stat = null
	var/data = ""
	var/base_url = "http://svn.slurm.us/public/spacestation13/misc/game_kit"
	item_state = "sheet-metal"
	w_class = 5.0

/obj/item/weapon/gift
	name = "gift"
	icon = 'items.dmi'
	icon_state = "gift3"
	var/size = 3.0
	var/obj/item/gift = null
	item_state = "gift"
	w_class = 4.0

/obj/item/device/hand_tele
	name = "hand tele"
	icon = 'device.dmi'
	icon_state = "hand_tele"
	item_state = "electronic"
	throwforce = 5
	w_class = 2.0
	throw_speed = 3
	throw_range = 5
	m_amt = 10000
	origin_tech = "magnets=1;bluespace=3"

/obj/item/weapon/handcuffs
	name = "handcuffs"
	desc = "Use this to keep prisoners in line."
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	flags = FPRINT | CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 5
	w_class = 2.0
	throw_speed = 2
	throw_range = 5
	m_amt = 500
	origin_tech = "materials=1"

/obj/item/weapon/handcuffs/cable
	name = "cable restraints"
	desc = "Looks like some cables tied together. Could be used to tie something up."
	icon_state = "cuff_red"
	item_state = "coil_red"
	m_amt = 0

/obj/item/weapon/caution
	desc = "Caution! Wet Floor!"
	name = "Wet Floor Sign"
	icon = 'janitor.dmi'
	icon_state = "caution"
	force = 1.0
	throwforce = 3.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	flags = FPRINT


/obj/item/weapon/paint
	name = "Paint Can"
	icon = 'old_or_unused.dmi'
	icon_state = "paint_neutral"
	item_state = "paintcan"
	w_class = 3.0

/obj/item/weapon/paper
	name = "Paper"
	icon = 'items.dmi'
	icon_state = "paper"
	var/info = null
	var/stamped = 0
	throwforce = 0
	w_class = 1.0
	throw_speed = 3
	throw_range = 15
	var/see_face = 1
	var/body_parts_covered = HEAD
	var/protective_temperature = T0C + 10
	var/heat_transfer_coefficient = 0.99
	var/gas_transfer_coefficient = 1
	var/permeability_coefficient = 0.99
	var/siemens_coefficient = 0.80

/obj/item/weapon/paper/scan
	var/mname
	var/dna
	var/age
	var/bloodtype
	var/fingerprint
	var/mgender

/obj/item/weapon/paper/Router_pass
	name = "paper- 'NSV Luna Network Router Passwords'"

	New()
		..()
		spawn(100)
			for(var/obj/machinery/router/R in world)
				info += "[R.name] password: [R.net_pass]<BR>\n"

/obj/item/weapon/paper/Internal
	name = "paper- 'Internal Atmosphere Operating Instructions'"
	info = "Equipment:<BR>\n\t1+ Tank(s) with appropriate atmosphere<BR>\n\t1 Gas Mask w regulator (standard issue)<BR>\n<BR>\nProcedure:<BR>\n\t1. Wear mask<BR>\n\t2. Attach oxygen tank pipe to regulater (automatic))<BR>\n\t3. Set internal!<BR>\n<BR>\nNotes:<BR>\n\tDon't forget to stop internal when tank is low by<BR>\n\tremoving internal!<BR>\n<BR>\n\tDo not use a tank that has a high concentration of toxins.<BR>\n\tThe filters shut down on internal mode!<BR>\n<BR>\n\tWhen exiting a high danger environment it is advised<BR>\n\tthat you exit through a decontamination zone!<BR>\n<BR>\n\tRefill a tank at a oxygen canister by equiping the tank (Double Click)<BR>\n\tthen 'attacking' the canister (Double Click the canister)."

/obj/item/weapon/paper/Court
	name = "paper- 'Judgement'"
	info = "For crimes against the station, the offender is sentenced to:<BR>\n<BR>\n"

/obj/item/weapon/paper/Toxin
	name = "paper- 'Chemical Information'"
	info = "Known Onboard Toxins:<BR>\n\tGrade A Semi-Liquid Plasma:<BR>\n\t\tHighly poisonous. You cannot sustain concentrations above 15 units.<BR>\n\t\tA gas mask fails to filter plasma after 50 units.<BR>\n\t\tWill attempt to diffuse like a gas.<BR>\n\t\tFiltered by scrubbers.<BR>\n\t\tThere is a bottled version which is very different<BR>\n\t\t\tfrom the version found in canisters!<BR>\n<BR>\n\t\tWARNING: Highly Flammable. Keep away from heat sources<BR>\n\t\texcept in a enclosed fire area!<BR>\n\t\tWARNING: It is a crime to use this without authorization.<BR>\nKnown Onboard Anti-Toxin:<BR>\n\tAnti-Toxin Type 01P: Works against Grade A Plasma.<BR>\n\t\tBest if injected directly into bloodstream.<BR>\n\t\tA full injection is in every regular Med-Kit.<BR>\n\t\tSpecial toxin Kits hold around 7.<BR>\n<BR>\nKnown Onboard Chemicals (other):<BR>\n\tRejuvenation T#001:<BR>\n\t\tEven 1 unit injected directly into the bloodstream<BR>\n\t\t\twill cure paralysis and sleep toxins.<BR>\n\t\tIf administered to a dying patient it will prevent<BR>\n\t\t\tfurther damage for about units*3 seconds.<BR>\n\t\t\tit will not cure them or allow them to be cured.<BR>\n\t\tIt can be administeredd to a non-dying patient<BR>\n\t\t\tbut the chemicals disappear just as fast.<BR>\n\tSleep Toxin T#054:<BR>\n\t\t5 units wilkl induce precisely 1 minute of sleep.<BR>\n\t\t\tThe effects are cumulative.<BR>\n\t\tWARNING: It is a crime to use this without authorization"

/obj/item/weapon/paper/courtroom
	name = "paper- 'A Crash Course in Legal SOP on NSV Luna'"
	info = "<B>Roles:</B><BR>\nThe Forensic Technician is basically the investigator and prosecutor.<BR>\nA Staff Assistant can perform these functions with written authority from the Forensic Technician.<BR>\nThe Captain/HoP/Warden is ct as the judicial authority.<BR>\nThe Security Officers are responsible for executing warrants, security during trial, and prisoner transport.<BR>\n<BR>\n<B>Investigative Phase:</B><BR>\nAfter the crime has been committed the Forensic Technician's job is to gather evidence and try to ascertain not only who did it but what happened. He must take special care to catalogue everything and don't leave anything out. Write out all the evidence on paper. Make sure you take an appropriate number of fingerprints. IF he must ask someone questions he has permission to confront them. If the person refuses he can ask a judicial authority to write a subpoena for questioning. If again he fails to respond then that person is to be jailed as insubordinate and obstructing justice. Said person will be released after he cooperates.<BR>\n<BR>\nONCE the FT has a clear idea as to who the criminal is he is to write an arrest warrant on the piece of paper. IT MUST LIST THE CHARGES. The FT is to then go to the judicial authority and explain a small version of his case. If the case is moderately acceptable the authority should sign it. Security must then execute said warrant.<BR>\n<BR>\n<B>Pre-Pre-Trial Phase:</B><BR>\nNow a legal representative must be presented to the defendant if said defendant requests one. That person and the defendant are then to be given time to meet (in the jail IS ACCEPTABLE). The defendant and his lawyer are then to be given a copy of all the evidence that will be presented at trial (rewriting it all on paper is fine). THIS IS CALLED THE DISCOVERY PACK. With a few exceptions, THIS IS THE ONLY EVIDENCE BOTH SIDES MAY USE AT TRIAL. IF the prosecution will be seeking the death penalty it MUST be stated at this time. ALSO if the defense will be seeking not guilty by mental defect it must state this at this time to allow ample time for examination.<BR>\nNow at this time each side is to compile a list of witnesses. By default, the defendant is on both lists regardless of anything else. Also the defense and prosecution can compile more evidence beforehand BUT in order for it to be used the evidence MUST also be given to the other side.\nThe defense has time to compile motions against some evidence here.<BR>\n<B>Possible Motions:</B><BR>\n1. <U>Invalidate Evidence-</U> Something with the evidence is wrong and the evidence is to be thrown out. This includes irrelevance or corrupt security.<BR>\n2. <U>Free Movement-</U> Basically the defendant is to be kept uncuffed before and during the trial.<BR>\n3. <U>Subpoena Witness-</U> If the defense presents god reasons for needing a witness but said person fails to cooperate then a subpoena is issued.<BR>\n4. <U>Drop the Charges-</U> Not enough evidence is there for a trial so the charges are to be dropped. The FT CAN RETRY but the judicial authority must carefully reexamine the new evidence.<BR>\n5. <U>Declare Incompetent-</U> Basically the defendant is insane. Once this is granted a medical official is to examine the patient. If he is indeed insane he is to be placed under care of the medical staff until he is deemed competent to stand trial.<BR>\n<BR>\nALL SIDES MOVE TO A COURTROOM<BR>\n<B>Pre-Trial Hearings:</B><BR>\nA judicial authority and the 2 sides are to meet in the trial room. NO ONE ELSE BESIDES A SECURITY DETAIL IS TO BE PRESENT. The defense submits a plea. If the plea is guilty then proceed directly to sentencing phase. Now the sides each present their motions to the judicial authority. He rules on them. Each side can debate each motion. Then the judicial authority gets a list of crew members. He first gets a chance to look at them all and pick out acceptable and available jurors. Those jurors are then called over. Each side can ask a few questions and dismiss jurors they find too biased. HOWEVER before dismissal the judicial authority MUST agree to the reasoning.<BR>\n<BR>\n<B>The Trial:</B><BR>\nThe trial has three phases.<BR>\n1. <B>Opening Arguments</B>- Each side can give a short speech. They may not present ANY evidence.<BR>\n2. <B>Witness Calling/Evidence Presentation</B>- The prosecution goes first and is able to call the witnesses on his approved list in any order. He can recall them if necessary. During the questioning the lawyer may use the evidence in the questions to help prove a point. After every witness the other side has a chance to cross-examine. After both sides are done questioning a witness the prosecution can present another or recall one (even the EXACT same one again!). After prosecution is done the defense can call witnesses. After the initial cases are presented both sides are free to call witnesses on either list.<BR>\nFINALLY once both sides are done calling witnesses we move onto the next phase.<BR>\n3. <B>Closing Arguments</B>- Same as opening.<BR>\nThe jury then deliberates IN PRIVATE. THEY MUST ALL AGREE on a verdict. REMEMBER: They mix between some charges being guilty and others not guilty (IE if you supposedly killed someone with a gun and you unfortunately picked up a gun without authorization then you CAN be found not guilty of murder BUT guilty of possession of illegal weaponry.). Once they have agreed they present their verdict. If unable to reach a verdict and feel they will never they call a deadlocked jury and we restart at Pre-Trial phase with an entirely new set of jurors.<BR>\n<BR>\n<B>Sentencing Phase:</B><BR>\nIf the death penalty was sought (you MUST have gone through a trial for death penalty) then skip to the second part. <BR>\nI. Each side can present more evidence/witnesses in any order. There is NO ban on emotional aspects or anything. The prosecution is to submit a suggested penalty. After all the sides are done then the judicial authority is to give a sentence.<BR>\nII. The jury stays and does the same thing as I. Their sole job is to determine if the death penalty is applicable. If NOT then the judge selects a sentence.<BR>\n<BR>\nTADA you're done. Security then executes the sentence and adds the applicable convictions to the person's record.<BR>\n"

/obj/item/weapon/paper/flag
	icon_state = "flag_neutral"
	item_state = "paper"
	anchored = 1.0

/obj/item/weapon/paper/jobs
	name = "paper- 'Job Information'"
	info = "Information on all formal jobs that can be assigned on Space Station 13 can be found on this document.<BR>\nThe data will be in the following form.<BR>\nGenerally lower ranking positions come first in this list.<BR>\n<BR>\n<B>Job Name</B>   general access>lab access-engine access-systems access (atmosphere control)<BR>\n\tJob Description<BR>\nJob Duties (in no particular order)<BR>\nTips (where applicable)<BR>\n<BR>\n<B>Research Assistant</B> 1>1-0-0<BR>\n\tThis is probably the lowest level position. Access with this is restricted. Head of Personnel should\nappropriate the correct level of assistance.<BR>\n1. Assist the researchers.<BR>\n2. Clean up the labs.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Staff Assistant</B> 2>0-0-0<BR>\n\tThis position assists the security officer in his duties. The staff assisstants should primarily br\npatrolling the ship waiting until they are needed to maintain ship safety.\n(Addendum: Updated/Elevated Security Protocols admit issuing of low level weapons to security personnel)<BR>\n1. Patrol ship/Guard key areas<BR>\n2. Assist security officer<BR>\n3. Perform other security duties.<BR>\n<BR>\n<B>Technical Assistant</B> 1>0-0-1<BR>\n\tThis is yet another low level position. The technical assistant helps the engineer and the statian\ntechnician with the upkeep and maintenance of the station. This job is very important because it usually\ngets to be a heavy workload on station technician and these helpers will alleviate that.<BR>\n1. Assist Station technician and Engineers.<BR>\n2. Perform general maintenance of station.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Medical Assistant</B> 1>1-0-0<BR>\n\tThis is the fourth position yet it is slightly less common. This position doesn't have much power\noutside of the med bay. Consider this position like a nurse who helps to upkeep medical records and the\nmaterials (filling syringes and checking vitals)<BR>\n1. Assist the medical personnel.<BR>\n2. Update medical files.<BR>\n3. Prepare materials for medical operations.<BR>\n<BR>\n<B>Research Technician</B> 2>3-0-0<BR>\n\tThis job is primarily a step up from research assistant. These people generally do not get their own lab\nbut are more hands on in the experimentation process. At this level they are permitted to work as consultants to\nthe others formally.<BR>\n1. Inform superiors of research.<BR>\n2. Perform research alongside of official researchers.<BR>\n<BR>\n<B>Forensic Technician</B> 3>2-0-0<BR>\n\tThis job is in most cases slightly boring at best. Their sole duty is to\nperform investigations of crine scenes and analysis of the crime scene. This\nalleviates SOME of the burden from the security officer. This person's duty\nis to draw conclusions as to what happened and testify in court. Said person\nalso should stroe the evidence ly.<BR>\n1. Perform crime-scene investigations/draw conclusions.<BR>\n2. Store and catalogue evidence properly.<BR>\n3. Testify to superiors/inquieries on findings.<BR>\n<BR>\n<B>Station Technician</B> 2>0-2-3<BR>\n\tPeople assigned to this position must work to make sure all the systems aboard Space Station 13 are operable.\nThey should primarily work in the computer lab and repairing faulty equipment. They should work with the\natmospheric technician.<BR>\n1. Maintain Luna systems.<BR>\n2. Repair equipment.<BR>\n<BR>\n<B>Atmospheric Technician</B> 3>0-0-4<BR>\n\tThese people should primarily work in the atmospheric control center and lab. They have the very important\njob of maintaining the delicate atmosphere on Luna.<BR>\n1. Maintain atmosphere on NSV Luna<BR>\n2. Research atmospheres on the space station. (safely please!)<BR>\n<BR>\n<B>Engineer</B> 2>1-3-0<BR>\n\tPeople working as this should generally have detailed knowledge as to how the propulsion systems on Luna\nwork. They are one of the few classes that have unrestricted access to the engine area.<BR>\n1. Upkeep the engine.<BR>\n2. Prevent fires in the engine.<BR>\n3. Maintain a safe orbit.<BR>\n<BR>\n<B>Medical Researcher</B> 2>5-0-0<BR>\n\tThis position may need a little clarification. Their duty is to make sure that all experiments are safe and\nto conduct experiments that may help to improve the station. They will be generally idle until a new laboratory\nis constructed.<BR>\n1. Make sure the station is kept safe.<BR>\n2. Research medical properties of materials studied of Space Station 13.<BR>\n<BR>\n<B>Scientist</B> 2>5-0-0<BR>\n\tThese people study the properties, particularly the toxic properties, of materials handled on Luna.\nTechnically they can also be called Plasma Technicians as plasma is the material they routinly handle.<BR>\n1. Research plasma<BR>\n2. Make sure all plasma is properly handled.<BR>\n<BR>\n<B>Medical Doctor (Officer)</B> 2>0-0-0<BR>\n\tPeople working this job should primarily stay in the medical area. They should make sure everyone goes to\nthe medical bay for treatment and examination. Also they should make sure that medical supplies are kept in\norder.<BR>\n1. Heal wounded people.<BR>\n2. Perform examinations of all personnel.<BR>\n3. Moniter usage of medical equipment.<BR>\n<BR>\n<B>Security Officer</B> 3>0-0-0<BR>\n\tThese people should attempt to keep the peace inside the station and make sure the station is kept safe. One\nside duty is to assist in repairing the station. They also work like general maintenance personnel. They are not\ngiven a weapon and must use their own resources.<BR>\n(Addendum: Updated/Elevated Security Protocols admit issuing of weapons to security personnel)<BR>\n1. Maintain order.<BR>\n2. Assist others.<BR>\n3. Repair structural problems.<BR>\n<BR>\n<B>Head of Security</B> 4>5-2-2<BR>\n\tPeople assigned as Head of Security should issue orders to the security staff. They should\nalso carefully moderate the usage of all security equipment. All security matters should be reported to this person.<BR>\n1. Oversee security.<BR>\n2. Assign patrol duties.<BR>\n3. Protect the station and staff.<BR>\n<BR>\n<B>Head of Personnel</B> 4>4-2-2<BR>\n\tPeople assigned as head of personnel will find themselves moderating all actions done by personnel. \nAlso they have the ability to assign jobs and access levels.<BR>\n1. Assign duties.<BR>\n2. Moderate personnel.<BR>\n3. Moderate research. <BR>\n<BR>\n<B>Captain</B> 5>5-5-5 (unrestricted station wide access)<BR>\n\tThis is the highest position youi can aquire on Space Station 13. They are allowed anywhere inside the\nspace station and therefore should protect their ID card. They also have the ability to assign positions\nand access levels. They should not abuse their power.<BR>\n1. Assign all positions on Luna<BR>\n2. Inspect the station for any problems.<BR>\n3. Perform administrative duties.<BR>\n"

/obj/item/weapon/paper/Medicine_Information
	name = "paper- 'Medicine Information'"
	info = {"
	<B>Medicinal Chemical Information</B>
	<hr>
	<u>Dexalin</u><br>
	This commonly requested chemical is essential in healing respiratory damage.
	If administered quickly, it can mean the difference between life and death.<br>
	Formula: 1 Plasma + 1 Oxygen -> 2 Dexalin
	<br><br>
	<u>Kelotane</u><br>
	Distributed as pills or ointment throughout the station. Essential in treating burn victims.<br>
	Formula: 1 Silicon + 1 Carbon -> 2 Kelotane
	<br><br>
	<u>Bicardine</u><br>
	Has a restorative effect on injuries caused by external trauma, such as weapons.<br>
	Formula: 1 Inaprovaline + 1 Carbon -> 2 Bicardine
	<br><br>
	<u>Leporazine</u><br>
	Stimulates natural homeostasis mechanisms to regulate body temperature.<br>
	Formula: 1 Silicon + 1 Plasma -> 2 Leporazine
	<br><br>
	<u>Synaptizine</u><br>
	Regulates nerve and synapse signals, allowing quick recovery from paralysis or drowsiness.<br>
	Formula: 1 Sugar + 1 Lithium + 1 Water -> 3 Synaptizine
	<br><br>
	<u>Hyronalin</u><br>
	Neutralizes radioactive elements in the body.<br>
	Formula: 1 Radium + 1 Anti-Toxin -> 2 Hyronalin
	<br><br>
	<u>Arithrazine</u><br>
	Aggressively neutralizes radioactive materials, converting them quickly into more manageable toxic chemicals.<br>
	Formula: 1 Hyronalin + 1 Hydrogen -> 2 Arithrazine
	<br><br>
	<u>Tricordrazine</u>
	Originally synthesized from Cordrazine, this chemical helps repair any kind of cellular trauma.<br>
	Formula: 1 Inaprovaline + 1 Anti-Toxin -> 2 Tricordrazine
	<br><br>
	<u>Cryoxadone</u><br>
	Heals all damage very rapidly when the subject's body temperature is below 170.<br>
	Formula: 1 Dexalin + 1 Water + 1 Oxygen -> 10 Cryoxadone
	<br><br>
	<u>Alkysine</u><br>
	Restores neural connections and encourages neural remapping, healing almost any brain damage.<br>
	Formula: 1 Chlorine + 1 Nitrogen + 1 Anti-Toxin -> 2 Alkysine
	<br><br>
	<u>Cryptobiolin</u><br>
	Non-medicinal intermediary chemical for Spaceacillin which interrupts neural signals, causing confusion.<br>
	Formula: 1 Potassium + 1 Oxygen + 1 Sugar -> 3 Cryptobiolin
	<br><br>
	<u>Spaceacillin</u>
	An all-purpose antiviral chemical which is in high demand during epidemics of Space Rhinovirus.<br>
	Formula: 1 Cryptobiolin + 1 Inaprovaline -> 2 Spaceacillin
	"}

/obj/item/weapon/paper/photograph
	name = "photo"
	icon_state = "photo"
	var/photo_id = 0.0
	item_state = "paper"

/obj/item/weapon/paper/sop
	name = "paper- 'Standard Operating Procedure'"
	info = {"Alert Levels:<BR><BR>\n
	Blue - Emergency<BR>\n
	\t1. Caused by fire<BR>\n
	\t2. Caused by manual interaction<BR>\n
	\tAction:<BR>\n\t\tClose all fire doors. These can only be opened by reseting the alarm<BR><BR>\n

	Toxin Laboratory Procedure:<BR>\n
	\tWear a gas mask regardless<BR>\n
	\tGet an oxygen tank.<BR>\n
	\tActivate internal atmosphere<BR>\n<BR>\n
	\tAfter<BR>\n
	\t\tDecontaminate<BR>\n
	\t\tVisit medical examiner<BR>\n<BR><BR>\n

	Disaster Procedure:<BR>\n
	\tFire:<BR>\n
	\t\tActivate sector fire alarm.<BR>\n
	\t\tMove to a safe area.<BR>\n
	\t\tGet a fire suit<BR>\n
	\t\tAfter:<BR>\n
	\t\t\tAssess Damage<BR>\n
	\t\t\tRepair damages<BR>\n
	\t\t\tIf needed, Evacuate<BR>\n
	\tMeteor Shower:<BR>\n
	\t\tActivate fire alarm<BR>\n
	\t\tMove to the back of ship<BR>\n
	\t\tAfter<BR>\n
	\t\t\tRepair damage<BR>\n
	\t\t\tIf needed, Evacuate"}

/obj/item/weapon/paper/engine
	name = "paper- 'Generator Startup Procedure'"
	info = {"<B>Thermo-Electric Generator Startup Procedure for Mark I Plasma-Fired Engines</B>
<HR>
<i>Warning!</i> Improper engine and generator operation may cause exposure to hazardous gasses, extremes of heat and cold, and dangerous electrical voltages.<BR>
Only trained personnel should operate station systems. Follow all procedures carefully. Wear correct personal protective equipment at all times.<BR>
Refer to your supervisor or Head of Personnel for procedure updates and additional information.
<HR>
Standard checklist for engine and generator cold-start.<BR>
<ol>
<li>Perform visual inspection of external (cooling) and internal (heating) heat-exchange pipe loops.
Refer any breaks or cracks in the pipe to Station Maintenance for repair before continuing.
<li>Connect a CO<sub>2</sub> canister to the external (cooling) loop connector, and release the contents. Check loop pressurization is stable.<BR>
<i>Note:</i> Observe standard canister safety procedures.<BR>
<i>Note:</i> Other gasses may be substituted as a medium in the external (cooling) loop in the event that CO<sub>2</sub> is not available.
<li>Connect a CO<sub>2</sub> canister to the internal (heating) loop connector, and release the contents. Check loop pressurization is stable.<BR>
<i>Note:</i> Observe standard canister safety procedures.<BR>
<i>Note:</i> Nitrogen may be substituted as a medium in the internal (heating) loop in the event that CO<sub>2</sub> is not available.
<i>Do not use plasma in the internal (heating) pipe loop as an unsafe condition may result.</i>
<li>Using the thermo-electric generator (TEG) master control panel, engage the internal and external loop circulator pumps at 1% maximum rate.<BR>
<li>Ignite the engine. Refer to document NTRSN-113-H9-12939 for proper engine preparation, ignition, and plasma-oxygen loading procedures.<BR>
<i>Note:</i> Exceeding recommended plasma-oxygen concentrations can cause engine damage and potential hazards.
<li>Monitor engine temperatures until stable operation is achieved.
<li>Increase internal and external circulator pumps to 10% of maximum rate. Monitor the generated power output on the TEG control panel.<BR>
<i>Note:</i> Consult appendix A for expected electrical generation rates.
<li>Adjust circulator rates until required electrical demand is met.<BR>
<i>Note:</i> Generation rate varies with internal and external loop temperatures, exchange media pressure, and engine geometry. Refer to Appendix B or your supervisor for locally determined optimal settings.<BR>
<i>Note:</i> Do not exceed safety ratings for station power cabling and electrical equipment.
<li>With the power generation rate stable, engage charging of the superconducting magnetic energy storage (SMES) devices.
Total SMES charging rate should not exceed total power generation rate, or an overload condition may occur.
"}

/obj/item/weapon/rack_parts
	name = "rack parts"
	icon = 'items.dmi'
	icon_state = "rack_parts"
	flags = FPRINT | CONDUCT

/obj/item/weapon/screwdriver
	name = "screwdriver"
	icon = 'items.dmi'
	icon_state = "screwdriver"
	flags = FPRINT | CONDUCT
	force = 5.0
	w_class = 1.0
	slash = 1
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	m_amt = 50
	g_amt = 20

/obj/item/weapon/melee/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon_state = "chain"
	item_state = "chain"
	flags = FPRINT | CONDUCT
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	w_class = 3
	origin_tech = "combat=4"
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")

/obj/item/weapon/staff
	name = "wizards staff"
	desc = "Apparently a staff used by the wizard."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "staff"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	flags = FPRINT | NOSHIELD
	attack_verb = list("bludgeoned", "whacked", "disciplined")

/obj/item/weapon/staff/broom
	name = "broom"
	desc = "Used for sweeping, and flying into the night while cackling. Black cat not included."
	icon_state = "broom"

/obj/item/weapon/wirecutters
	name = "wirecutters"
	icon = 'items.dmi'
	icon_state = "cutters"
	flags = FPRINT | CONDUCT
	force = 6.0
	slash = 1
	throw_speed = 2
	throw_range = 9
	w_class = 2.0
	m_amt = 80

/obj/item/weapon/wrapping_paper
	name = "wrapping paper"
	icon = 'items.dmi'
	icon_state = "wrap_paper"
	var/amount = 20.0


/obj/item/device/camera_bug
	name = "camera bug"
	icon_state = "camerabug"
	w_class = 1.0
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	var/bug_active = 0

/obj/item/device/camera_bug/attack_self(mob/user as mob)
	var/list/cameras = new/list()
	for (var/obj/machinery/camera/C in world)
		if (C.bugged && C.status)
			cameras.Add(C)
	if (length(cameras) == 0)
		user << "\red No bugged functioning cameras found."
		return

	var/list/friendly_cameras = new/list()

	for (var/obj/machinery/camera/C in cameras)
		friendly_cameras.Add(C.c_tag)

	var/target = input("Select the camera to observe", null) as null|anything in friendly_cameras
	if (!target)
		return

	for (var/obj/machinery/camera/C in cameras)
		if (C.c_tag == target)
			target = C
			break
	if (user.stat == 2) return

	user.client.eye = target
	bug_active = 1

	spawn(100)
		bug_active = 0


/obj/item/weapon/module
	icon = 'module.dmi'
	icon_state = "std_module"
	w_class = 2.0
	item_state = "electronic"
	flags = FPRINT|CONDUCT
	var/mtype = 1						// 1=electronic 2=hardware

/obj/item/weapon/module/card_reader
	name = "card reader module"
	icon_state = "card_mod"
	desc = "An electronic module for reading data and ID cards."

/obj/item/weapon/module/power_control
	name = "power control module"
	icon_state = "power_mod"
	desc = "Heavy-duty switching circuits for power control."

/obj/item/weapon/module/id_auth
	name = "ID authentication module"
	icon_state = "id_mod"
	desc = "A module allowing secure authorization of ID cards."

/obj/item/weapon/module/cell_power
	name = "power cell regulator module"
	icon_state = "power_mod"
	desc = "A converter and regulator allowing the use of power cells."

/obj/item/weapon/module/cell_power
	name = "power cell charger module"
	icon_state = "power_mod"
	desc = "Charging circuits for power cells."


/obj/item/weapon/a_gift
	name = "gift"
	icon = 'items.dmi'
	icon_state = "gift"
	item_state = "gift"
	pressure_resistance = 70