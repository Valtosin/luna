/*
Catagories
-----------
Fiction
Engineering
Medical
History
Business
Self-Help
Science
Religion
Cooking
*/
#define Fiction 1
#define Engineering 2
#define Medical 3
#define History 4
#define Business 5
#define SelfHelp 6
#define Science 7
#define Religion 8
#define Cooking 9
obj/item/weapon/book
	name = "book"
	icon = 'items.dmi'
	icon_state = "book"
	var/by = "name"
	var/list/pages = list()
	var/texts
	var/cat = Fiction
obj/item/weapon/book/attack_self(mob/user)
	usr << browse(texts,"window=bookwin")
obj/item/weapon/book/Topic(href, href_list)
	if(href_list["page"])
		var/page = href_list["addr"]
		if(page)
			if(pages[page])
				var/datum/bookhand/page/pagex = page[1]
				var/dat = pagex.texts
				var/nextpage = page++
				if(pages[nextpage])
					dat += "<A href='?src=\ref[src];page=[nextpage]'>Next page</A>"
				winset(usr,"bookwin", "title=[src.name]")
				usr << browse(dat,"window=bookwin")

var/datum/bookhand/BOOKHAND
datum/bookhand/page
	var/texts = null
datum/book
	var/name
	var/by
	var/texts
	var/cat
datum/bookhand
	var/list/books = list()

datum/bookhand/New()
	BOOKHAND = src // I shouldent need to fucking do this.
//	world.log << "Loaded Books: [src.books.len]"
	Update()
datum/bookhand/proc/MakeBook(var/title,var/author,var/text,var/cat)
	var/datum/book/B = new()
	B.name = title
	B.by = author
	B.texts = text
	B.cat = cat
	src.books += B

datum/bookhand/proc/Update()
	for(var/obj/machinery/bookcase/B in world)
		B.update()
		//world.log << "Updating [B]"

obj/machinery/bookcase
	name = "Fiction Bookcase"
	icon = 'computer.dmi'
	icon_state = "bookcase"
	density = 1
	anchored = 1
	var/cat = Fiction

obj/machinery/bookcase/engi
	name = "Engineering Bookcase"
	cat = Engineering
obj/machinery/bookcase/med
	name = "Medical Bookcase"
	cat = Medical
obj/machinery/bookcase/his
	name = "History Bookcase"
	cat = History
obj/machinery/bookcase/bus
	name = "Business Bookcase"
	cat = Business
obj/machinery/bookcase/sh
	name = "Self-Help Bookcase"
	cat = SelfHelp
obj/machinery/bookcase/sci
	name = "Science Bookcase"
	cat = Science
obj/machinery/bookcase/reli
	name = "Religion Bookcase"
	cat = Religion
obj/machinery/bookcase/cook
	name = "Cooking Bookcase"
	cat = Cooking
obj/machinery/bookcase/proc/update()
	for(var/datum/book/BC in BOOKHAND.books)
		if(BC.cat == src.cat)
			var/obj/item/weapon/book/B = new(src)
			B.name = BC.name
			B.by = BC.by
			B.texts = dd_replacetext(BC.texts, "\n", "<BR>")
			B.cat = BC.cat
obj/machinery/bookcase/attack_hand(mob/user)
	if(src.contents.len <= 0)
		user << "Seems someone forgot to restock \the [src]..."
		return
	var/obj/item/weapon/book/B = input(user,"Choose a book to take out","Books") as obj in src.contents
	if(in_range(src,user))
		B.loc = user.loc
obj/machinery/bookcase/attackby(obj/item/weapon/book/B,mob/user)
	if(istype(B))		//Change by Mloc: Books should be the only things to go in bookcases!
		user << "\blue You add the \"[B.name]\" to the [src.name]."
		user.drop_item()
		B.loc = src
	else
		user << "\red You can't add \a [B.name] to a bookshelf!"
