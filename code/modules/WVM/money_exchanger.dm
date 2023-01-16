/* Code by Tienn */
/* Sprites by Moonmandoom*/
/* new_vendors.dmi by Pebbles*/

#define STATE_IDLE 0
#define STATE_SERVICE 1
#define STATE_VEND 2
#define STATE_LOCKOPEN 3

#define CASH_CAP 1

/* exchange rates X * CAP*/
#define CASH_AUR 100 /* 100 caps to 1 AUR */
#define CASH_DEN 4 /* 4 caps to 1 DEN */
#define CASH_NCR 0.4 /* $100 to 40 caps */
#define CASH_USD 0.004 /* $10000 to 40 caps */

/**********************Money Exchanger**************************/

/obj/machinery/mineral/money_exchanger
	name = "Federal Reserve Currency Exchanger"
	desc = "The Commonwealth Bank Currency Exchanger, once a staple of American Banking across all the US Commonwealths. This one, along with most seen across the various wastelands, is rusted and barely functional, but it keeps on ticking nonetheless. Much like Old America."
	icon = 'icons/WVM/machines.dmi'
	icon_state = "liberationstation_idle" //placeholder

	density = TRUE
	use_power = FALSE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	can_be_unanchored = FALSE
	layer = 2.9

	var/stored_caps = 0	// store caps
	var/expected_price = 0
	var/list/prize_list = list()  //if you add something to this, please, for the love of god, sort it by price/type. use tabs and not spaces.
	var/list/highpop_list = list()  //if you add something to this, please, for the love of god, sort it by price/type. use tabs and not spaces.

/obj/machinery/mineral/money_exchanger/usd
	name = "Federal Reserve Currency Exchanger"
	desc = "The Commonwealth Bank Currency Exchanger, once a staple of American Banking across all the US Commonwealths. This one, along with most seen across the various wastelands, is rusted and barely functional, but it keeps on ticking nonetheless. Much like Old America."
	icon = 'icons/WVM/machines.dmi'
	icon_state = "liberationstation_idle" //placeholder

	prize_list = list(
		new /datum/data/money_exchanger("Pre-War Money",					/obj/item/stack/f13Cash/usd,											10)
		)
	highpop_list = list(
		new /datum/data/money_exchanger("Pre-War Money",					/obj/item/stack/f13Cash/usd,											10)
		)

/**********************NCR Money exchanger**************************/
/obj/machinery/mineral/money_exchanger/ncr
	name = "NCR Currency Exchanger"
	desc = "New California Republic Reserves Currency Exchanger MK.I. Heavily weathered from years of neglect and poor maintenance. Miraculously it still works, somehow. The quote “In order to give, you must first take. Todays taxes, tomorrows paycheck.” Can be seen on across the  top of the machine."
	icon = 'icons/WVM/new_vendors.dmi'
	icon_state = "ncr_money_printer" //placeholder

	prize_list = list(
		new /datum/data/money_exchanger("$5 NCR Bill",					/obj/item/stack/f13Cash/ncr5,											2),
		new /datum/data/money_exchanger("$20 NCR Bill",					/obj/item/stack/f13Cash/ncr20,											8),
		new /datum/data/money_exchanger("$100 NCR Bill",				/obj/item/stack/f13Cash/ncr100,											40)
		)
	highpop_list = list(
		new /datum/data/money_exchanger("$5 NCR Bill",					/obj/item/stack/f13Cash/ncr5,											2),
		new /datum/data/money_exchanger("$20 NCR Bill",					/obj/item/stack/f13Cash/ncr20,											8),
		new /datum/data/money_exchanger("$100 NCR Bill",				/obj/item/stack/f13Cash/ncr100,											40)
		)

/datum/data/money_exchanger
	var/equipment_name = "generic"
	var/equipment_path = null
	var/cost = 0 

	/datum/data/money_exchanger/New(name, path, cost)
		src.equipment_name = name
		src.equipment_path = path
		src.cost = cost

/obj/machinery/mineral/money_exchanger/ui_interact(mob/user)
	. = ..()
	var/dat
	dat +="<div class='statusDisplay'>"
	dat += "<b>Bottle caps value stored:</b> [stored_caps]. <A href='?src=[REF(src)];choice=eject'>Eject money</A><br>"
	dat += "</div>"
	dat += "<br>"
	dat +="<div class='statusDisplay'>"
	dat += "<b>Currency conversion rates:</b><br>"
	dat += "1 Bottle cap = [CASH_CAP] bottle caps value <br>"
	dat += "1 NCR dollar = [CASH_NCR] bottle caps value. May recieve a $.50 tax! <br>"
	dat += "1 Denarius = [CASH_DEN] bottle caps value <br>"
	dat += "1 Aureus = [CASH_AUR] bottle caps value <br>"
	dat += "1 USD dollar = [CASH_USD] bottle caps value <br>"
	dat += "</div>"
	dat += "<br>"
	dat +="<div class='statusDisplay'>"
	dat += "<b>Vendor goods:</b><BR><table border='0' width='300'>"
	if (GLOB.player_list.len>50)
		for(var/datum/data/money_exchanger/prize in highpop_list)
			dat += "<tr><td>[prize.equipment_name]</td><td>[prize.cost]</td><td><A href='?src=[REF(src)];purchase=[REF(prize)]'>Purchase</A></td></tr>"
	else
		for(var/datum/data/money_exchanger/prize in prize_list)
			dat += "<tr><td>[prize.equipment_name]</td><td>[prize.cost]</td><td><A href='?src=[REF(src)];purchase=[REF(prize)]'>Purchase</A></td></tr>"
	dat += "</table>"
	dat += "</div>"

	var/datum/browser/popup = new(user, "tradingvendor", "NCR Currency Exchanger", 400, 500)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/mineral/money_exchanger/Topic(href, href_list)
	if(..())
		return
	if(href_list["choice"] == "eject")
		remove_all_caps()
	if(href_list["purchase"] && GLOB.player_list.len>50)
		var/datum/data/money_exchanger/prize = locate(href_list["purchase"])
		if (!prize || !(prize in highpop_list))
			to_chat(usr, span_warning("Error: Invalid choice!"))
			return
		if(prize.cost > stored_caps)
			to_chat(usr, span_warning("Error: Insufficent USD for [prize.equipment_name]!"))
		else
			stored_caps -= prize.cost
			GLOB.vendor_cash += prize.cost
			to_chat(usr, span_notice("[src] clanks to life briefly before vending [prize.equipment_name]!"))
			new prize.equipment_path(src.loc)
			SSblackbox.record_feedback("nested tally", "wasteland_equipment_bought", 1, list("[type]", "[prize.equipment_path]"))
	else if(href_list["purchase"])
		var/datum/data/money_exchanger/prize = locate(href_list["purchase"])
		if (!prize || !(prize in prize_list))
			to_chat(usr, span_warning("Error: Invalid choice!"))
			return
		if(prize.cost > stored_caps)
			to_chat(usr, span_warning("Error: Insufficent USD for [prize.equipment_name]!"))
		else
			stored_caps -= prize.cost
			GLOB.vendor_cash += prize.cost
			to_chat(usr, span_notice("[src] clanks to life briefly before vending [prize.equipment_name]!"))
			new prize.equipment_path(src.loc)
			SSblackbox.record_feedback("nested tally", "wasteland_equipment_bought", 1, list("[type]", "[prize.equipment_path]"))
	updateUsrDialog()
	return

/obj/machinery/mineral/money_exchanger/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/f13Cash))
		add_caps(I)
	else
		attack_hand(user)

/obj/machinery/mineral/money_exchanger/proc/add_caps(obj/item/I)
	if(istype(I, /obj/item/stack/f13Cash/caps))
		var/obj/item/stack/f13Cash/currency = I
		var/inserted_value = FLOOR(currency.amount * 1, 1)
		stored_caps += inserted_value
		I.use(currency.amount)
		playsound(src, 'sound/items/change_jaws.ogg', 60, 1)
		to_chat(usr, "You put [inserted_value] bottle caps value to a vending machine.")
		src.ui_interact(usr)
	else if(istype(I, /obj/item/stack/f13Cash/usd))
		var/obj/item/stack/f13Cash/ncr/currency = I
		var/inserted_value = FLOOR(currency.amount * 0.004, 1)
		stored_caps += inserted_value
		I.use(currency.amount)
		playsound(src, 'sound/items/change_jaws.ogg', 60, 1)
		to_chat(usr, "You put [inserted_value] bottle caps value to a vending machine.")
		src.ui_interact(usr)
	else if(istype(I, /obj/item/stack/f13Cash/denarius))
		var/obj/item/stack/f13Cash/denarius/currency = I
		var/inserted_value = FLOOR(currency.amount * 4, 1)
		stored_caps += inserted_value
		I.use(currency.amount)
		playsound(src, 'sound/items/change_jaws.ogg', 60, 1)
		to_chat(usr, "You put [inserted_value] bottle caps value to a vending machine.")
		src.ui_interact(usr)
	else if(istype(I, /obj/item/stack/f13Cash/aureus))
		var/obj/item/stack/f13Cash/aureus/currency = I
		var/inserted_value = FLOOR(currency.amount * 100, 1)
		stored_caps += inserted_value
		I.use(currency.amount)
		playsound(src, 'sound/items/change_jaws.ogg', 60, 1)
		to_chat(usr, "You put [inserted_value] bottle caps value to a vending machine.")

/obj/machinery/mineral/money_exchanger/proc/remove_all_caps()
	if(stored_caps <= 0)
		return
	var/obj/item/stack/f13Cash/I = new /obj/item/stack/f13Cash/iou
	if(stored_caps > I.max_amount)
		I.add(I.max_amount - 1)
		I.forceMove(src.loc)
		stored_caps -= I.max_amount
	else
		I.add(stored_caps - 1)
		I.forceMove(src.loc)
		stored_caps = 0
	say("Brrrrrrrrr!")
	playsound(src, 'sound/items/change_jaws.ogg', 60, 1)
	src.ui_interact(usr)

/**********************Legion Coin Minter**************************/
/obj/machinery/mineral/coin_minter/legion
	name = "Legion Currency Exchanger"
	desc = "Caesar’s Legion has sized the means of production; having refitted this Pre-War Coin Press Machine to print bastardized American coins with Caesar’s face and a Bull on them. The words “Property of Officiorum Ab Industria. The Only Wealth Which You Will Keep Forever Is The Wealth You Have Given Away.” have been stamped into the side of the machine with small metal lettering."
	icon = 'icons/obj/economy.dmi'
	icon_state = "coinpress0" //placeholder

	density = TRUE
	use_power = FALSE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	can_be_unanchored = FALSE
	layer = 2.9

	var/stored_caps = 0	// store caps
	var/expected_price = 0
	var/list/prize_list = list()  //if you add something to this, please, for the love of god, sort it by price/type. use tabs and not spaces.
	var/list/highpop_list = list()  //if you add something to this, please, for the love of god, sort it by price/type. use tabs and not spaces.

	prize_list = list(
		new /datum/data/coin_minter("Denarius",					/obj/item/stack/f13Cash/denarius,											4),
		new /datum/data/coin_minter("Aureus",					/obj/item/stack/f13Cash/aureus,											100)
		)
	highpop_list = list(
		new /datum/data/coin_minter("Denarius",					/obj/item/stack/f13Cash/denarius,											4),
		new /datum/data/coin_minter("Aureus",					/obj/item/stack/f13Cash/aureus,											100)
		)

/datum/data/coin_minter
	var/equipment_name = "generic"
	var/equipment_path = null
	var/cost = 0 

/datum/data/coin_minter/New(name, path, cost)
	src.equipment_name = name
	src.equipment_path = path
	src.cost = cost

/obj/machinery/mineral/coin_minter/legion/ui_interact(mob/user)
	. = ..()
	var/dat
	dat +="<div class='statusDisplay'>"
	dat += "<b>Bottle caps value stored:</b> [stored_caps]. <A href='?src=[REF(src)];choice=eject'>Eject money</A><br>"
	dat += "</div>"
	dat += "<br>"
	dat +="<div class='statusDisplay'>"
	dat += "<b>Currency conversion rates:</b><br>"
	dat += "1 Bottle cap = [CASH_CAP] bottle caps value <br>"
	dat += "1 NCR dollar = [CASH_NCR] bottle caps value. May recieve a $.50 tax! <br>"
	dat += "1 Denarius = [CASH_DEN] bottle caps value <br>"
	dat += "1 Aureus = [CASH_AUR] bottle caps value <br>"
	dat += "1 USD dollar = [CASH_USD] bottle caps value. <br>"
	dat += "</div>"
	dat += "<br>"
	dat +="<div class='statusDisplay'>"
	dat += "<b>Vendor goods:</b><BR><table border='0' width='300'>"
	if (GLOB.player_list.len>50)
		for(var/datum/data/coin_minter/prize in highpop_list)
			dat += "<tr><td>[prize.equipment_name]</td><td>[prize.cost]</td><td><A href='?src=[REF(src)];purchase=[REF(prize)]'>Purchase</A></td></tr>"
	else
		for(var/datum/data/coin_minter/prize in prize_list)
			dat += "<tr><td>[prize.equipment_name]</td><td>[prize.cost]</td><td><A href='?src=[REF(src)];purchase=[REF(prize)]'>Purchase</A></td></tr>"
	dat += "</table>"
	dat += "</div>"

	var/datum/browser/popup = new(user, "tradingvendor", "Legion Currency Exchanger", 400, 500)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/mineral/coin_minter/legion/Topic(href, href_list)
	if(..())
		return
	if(href_list["choice"] == "eject")
		remove_all_caps()
	if(href_list["purchase"] && GLOB.player_list.len>50)
		var/datum/data/coin_minter/prize = locate(href_list["purchase"])
		if (!prize || !(prize in highpop_list))
			to_chat(usr, span_warning("Error: Invalid choice!"))
			return
		if(prize.cost > stored_caps)
			to_chat(usr, span_warning("Error: Insufficent USD for [prize.equipment_name]!"))
		else
			stored_caps -= prize.cost
			GLOB.vendor_cash += prize.cost
			to_chat(usr, span_notice("[src] clanks to life briefly before vending [prize.equipment_name]!"))
			new prize.equipment_path(src.loc)
			SSblackbox.record_feedback("nested tally", "wasteland_equipment_bought", 1, list("[type]", "[prize.equipment_path]"))
	else if(href_list["purchase"])
		var/datum/data/coin_minter/prize = locate(href_list["purchase"])
		if (!prize || !(prize in prize_list))
			to_chat(usr, span_warning("Error: Invalid choice!"))
			return
		if(prize.cost > stored_caps)
			to_chat(usr, span_warning("Error: Insufficent USD for [prize.equipment_name]!"))
		else
			stored_caps -= prize.cost
			GLOB.vendor_cash += prize.cost
			to_chat(usr, span_notice("[src] clanks to life briefly before vending [prize.equipment_name]!"))
			new prize.equipment_path(src.loc)
			SSblackbox.record_feedback("nested tally", "wasteland_equipment_bought", 1, list("[type]", "[prize.equipment_path]"))
	updateUsrDialog()
	return

/obj/machinery/mineral/coin_minter/legion/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/f13Cash))
		add_caps(I)
	else
		attack_hand(user)

/obj/machinery/mineral/coin_minter/legion/proc/add_caps(obj/item/I)
	if(istype(I, /obj/item/stack/f13Cash/caps))
		var/obj/item/stack/f13Cash/currency = I
		var/inserted_value = FLOOR(currency.amount * 1, 1)
		stored_caps += inserted_value
		I.use(currency.amount)
		playsound(src, 'sound/items/change_jaws.ogg', 60, 1)
		to_chat(usr, "You put [inserted_value] bottle caps value to a vending machine.")
		src.ui_interact(usr)
	else if(istype(I, /obj/item/stack/f13Cash/usd))
		var/obj/item/stack/f13Cash/ncr/currency = I
		var/inserted_value = FLOOR(currency.amount * 10, 1)
		stored_caps += inserted_value
		I.use(currency.amount)
		playsound(src, 'sound/items/change_jaws.ogg', 60, 1)
		to_chat(usr, "You put [inserted_value] bottle caps value to a vending machine.")
		src.ui_interact(usr)
	else if(istype(I, /obj/item/stack/f13Cash/ncr))
		var/obj/item/stack/f13Cash/denarius/currency = I
		var/inserted_value = FLOOR(currency.amount * 2, 1)
		stored_caps += inserted_value
		I.use(currency.amount)
		playsound(src, 'sound/items/change_jaws.ogg', 60, 1)
		to_chat(usr, "You put [inserted_value] bottle caps value to a vending machine.")
		src.ui_interact(usr)
	else if(istype(I, /obj/item/stack/f13Cash/aureus))
		var/obj/item/stack/f13Cash/aureus/currency = I
		var/inserted_value = FLOOR(currency.amount * 100, 1)
		stored_caps += inserted_value
		I.use(currency.amount)
		playsound(src, 'sound/items/change_jaws.ogg', 60, 1)
		to_chat(usr, "You put [inserted_value] bottle caps value to a vending machine.")

/obj/machinery/mineral/coin_minter/legion/proc/remove_all_caps()
	if(stored_caps <= 0)
		return
	var/obj/item/stack/f13Cash/C = new /obj/item/stack/f13Cash/caps
	if(stored_caps > C.max_amount)
		C.add(C.max_amount - 1)
		C.forceMove(src.loc)
		stored_caps -= C.max_amount
	else
		C.add(stored_caps - 1)
		C.forceMove(src.loc)
		stored_caps = 0
	playsound(src, 'sound/items/coinflip.ogg', 60, 1)
	src.ui_interact(usr)
