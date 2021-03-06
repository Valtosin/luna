//
//  Note: If you disable this file, enable "chat_tabs_disabled".
//

/mob/proc/ctab_message(var/tab, var/message)
	if(src.client)
		src.client.ctab_message(tab, message)



/client/proc/ctab_message(var/tab, var/message, var/send_to)
	if(cmptext(tab, "game"))
		src << message
		return

	if(cmptext(tab, "all"))
		src << message
		if(!ctab_settings["tabs"])
			ctab_settings["tabs"] = list()
		for(var/t in ctab_settings["tabs"])
			src << output(message, "ctab_tab_[lowertext(t)].output")
		return

	if(istype(tab,/list))
		for(var/t in tab)
			ctab_message(t, message, send_to)
		return

	if(!istext(tab))
		return

	var/tabl = lowertext(tab)

	//winexists was probably fetching data from the client. Speed this up by checking a server-side var first.
	if(!ctab_settings["tab_[tabl]"] && !winexists(src, "ctab_tab_[tabl]"))
		winclone(src, "ctab_template", "ctab_tab_[tabl]")
		if(!winexists(src, "ctab_tab_[tabl]"))
			usr << "Tried to create tab [tab], but failed"
			return
		if(winget(src, "ctabs.tabs", "current-tab") == "ctab_settings")
			winset(src, "ctab_tab_[tabl]", "title=\"[tab]\"")
			winset(src, "ctabs.tabs", "tabs=\"-ctab_settings\"")
			winset(src, "ctabs.tabs", "tabs=\"+ctab_tab_[tabl],ctab_settings\"")
			winset(src, "ctabs.tabs", "current-tab=\"ctab_settings\"")
		else
			winset(src, "ctab_tab_[tabl]", "title=\"[tab]\"")
			winset(src, "ctabs.tabs", "tabs=\"-ctab_settings\"")
			winset(src, "ctabs.tabs", "tabs=\"+ctab_tab_[tabl],ctab_settings\"")
		if(!ctab_settings["display_[tabl]"])
			if(send_to)
				if(istype(send_to,/list))
					ctab_settings["display_[tabl]"] = send_to
				else
					ctab_settings["display_[tabl]"] = list(send_to)
			else
				ctab_settings["display_[tabl]"] = list("Game", tab)
		ctab_settings["tab_[tabl]"] = "show"
		if(!ctab_settings["tabs"])
			ctab_settings["tabs"] = list()
		ctab_settings["tabs"] += tab
		ctab_update()

	for(var/t in ctab_settings["display_[tabl]"])
		if(cmptext(t, "game"))
			src << message
		else
			src << output(message, "ctab_tab_[lowertext(t)].output")
			spawn()//Unknown, but the winget in ctab_updated may wait for the client to respond with the answer. Thus, spawning probably lets it continue with the rest while it waits for a reply.
				ctab_updated(t)



/client/New()
	..()
	if(!ctab_settings["tabs"])
		ctab_settings["tabs"] = list()

	var/list/hidden_tabs = stringsplit(winget(src, "ctabs_hidden.tabs", "tabs"), ",")
	var/list/tabs = stringsplit(winget(src, "ctabs.tabs", "tabs"), ",")

	for(var/t in hidden_tabs)
		if(t == "" || t == " ")
			continue

		var/tab = winget(src, t, "title")
		if(text2ascii(tab) == text2ascii("!"))
			tab = copytext(tab, 2, length(tab))

		var/tabl = lowertext(tab)
		ctab_settings["display_[tabl]"] = list("Game", tab)
		ctab_settings["tab_[tabl]"] = "hide"
		ctab_settings["tabs"] += tab

	for(var/t in tabs)
		if(t == "ctab_settings" || t == "" || t == " ")
			continue
		var/tab = winget(src, t, "title")
		if(text2ascii(tab) == text2ascii("!"))
			tab = copytext(tab, 2, length(tab))
		if(cmptext(tab, "game"))
			continue
		var/tabl = lowertext(tab)
		ctab_settings["display_[tabl]"] = list("Game", tab)
		ctab_settings["tab_[tabl]"] = "show"
		ctab_settings["tabs"] += tab

	ctab_update()



/client/proc/ctab_updated(var/tab)
	var/tabl = lowertext(tab)
	if(winget(src, "ctabs.tabs", "current-tab") != "ctab_tab_[tabl]")
		winset(src, "ctab_tab_[tabl]", "title=\"![tab]!\"")



/client/verb/ctab_tabread()
	set name = ".ctab_tabread"
	var/tab = winget(src, "ctabs.tabs", "current-tab")
	var/title = winget(src, tab, "title")
	if(text2ascii(title) == text2ascii("!"))
		winset(src, tab, "title=\"[copytext(title, 2, length(title))]\"")



/client/proc/ctab_update()
	var/contents = ""
	contents += "currently in [ctab_settings["windowed"]?"window":"pane"] mode. (<a href=?ctab_action=toggle_window>change</a>)<br>"

	if(!ctab_settings["tabs"])
		ctab_settings["tabs"] = list()

	contents += "<br><table border=1><tr><td>Tab</td><td>toggle</td></tr>"
	for(var/tab in ctab_settings["tabs"])
		var/tabl = lowertext(tab)
		contents += "<tr><td>[tab]</td>"
		contents += "<td><a href=?ctab_action=toggle_tab_display;tab_name=[tab]>[ctab_settings["tab_[tabl]"]=="show"?"hide":"show"]</a></td>"
		contents += "<td><a href=?ctab_action=edit_tab;tab_name=[tab]>edit</a></td>"
		contents += "</tr>"

	contents += "</table><br><br>"
	contents += "<a href=?ctab_action=add_tab>Add custom tab</a><br><br>"

	src << browse(contents,"window=ctab_settings.browser")



/client/Topic(href,href_list[],hsrc)
	..()
	if(href_list["ctab_action"])
		var/tab = href_list["tab_name"]
		var/tabl = lowertext(tab)

		switch(href_list["ctab_action"])

			if("toggle_window")
				if(ctab_settings["windowed"])
					ctab_settings["windowed"] = 0
					winset(src, "ctab_window.child", "right=none")
					winset(src, "rpane.rpanewindow", "right=\"ctabs\"")
					winshow(src, "ctab_window", 0)

				else
					ctab_settings["windowed"] = 1
					winset(src, "rpane.rpanewindow", "right=none")
					winset(src, "ctab_window.child", "right=\"ctabs\"")
					winshow(src, "ctab_window", 1)

			if("toggle_tab_display")
				if(ctab_settings["tab_[tabl]"] == "show")
					ctab_settings["tab_[tabl]"] = "hide"
					winset(src, "ctabs_hidden.tabs", "tabs=\"+ctab_tab_[tabl]\"")
				else
					ctab_settings["tab_[tabl]"] = "show"
					winset(src, "ctabs.tabs", "tabs=\"-ctab_settings\"")
					winset(src, "ctabs.tabs", "tabs=\"+ctab_tab_[tabl],ctab_settings\"")
					winset(src, "ctabs.tabs", "current-tab=\"ctab_settings\"")

			if("edit_tab")
				ctab_update_edit_tab_window(tab)

			if("toggle_tab_in_tab")
				var/target = href_list["target_tab_name"]
				if(target in ctab_settings["display_[tabl]"])
					ctab_settings["display_[tabl]"] -= target
				else
					ctab_settings["display_[tabl]"] += target
				ctab_update_edit_tab_window(tab)

			if("add_tab")
				tab = input(src, "Name the tab (permitted characters: letters, numbers, and underscores)", "", "") as text
				var/len = length(tab)
				if(len >= 1)
					var/i
					var/failed = 0
					for(i=1, i<=len, i++)
						var/a = text2ascii(tab, i)
						if(!((a >= text2ascii("a") && a <= text2ascii("z")) || (a >= text2ascii("A") && a <= text2ascii("Z")) || (a >= text2ascii("0") && a <= text2ascii("9")) || a == text2ascii("_")))
							failed = 1
					if(failed)
						alert(src, "At least one invalid character was found. You can only use letters (a-z, A-Z), numbers (0-9), and underscores (_).")
					else
						if(tab in ctab_settings["tabs"])
							alert (src, "That tab already exists!")
						else
							ctab_message(tab, "Tab opened.")

		ctab_update()




/client/proc/ctab_update_edit_tab_window(var/tab)
	var/tabl = lowertext(tab)
	var/contents = "Edit tab settings for [tab]<br><br>"
	contents += "Display messages on the following tabs:<br><table border=1><tr><td>tab name</td><td>Displaying?</td></tr>"
	if(!ctab_settings["tabs"])
		ctab_settings["tabs"] = list()

	for(var/t in list("Game"))
		contents += "<tr><td>[t]</td>"
		var/show = "no"
		if(t in ctab_settings["display_[tabl]"])
			show = "yes"
		contents += "<td><a href=?ctab_action=toggle_tab_in_tab;tab_name=[tab];target_tab_name=[t]>[show]</a></td></tr>"

	for(var/t in ctab_settings["tabs"])
		contents += "<tr><td>[t]</td>"
		var/show = "no"
		if(t in ctab_settings["display_[tabl]"])
			show = "yes"
		contents += "<td><a href=?ctab_action=toggle_tab_in_tab;tab_name=[tab];target_tab_name=[t]>[show]</a></td></tr>"
	contents += "</table>"
	src << browse(contents, "window=edit_ctab")

