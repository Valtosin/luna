//Blocks an attempt to connect before even creating our client datum thing.

world/IsBanned(key,address,computer_id)
	//Guest Checking
	if(IsGuestKey(key))
		log_access("Failed Login: [key] - Guests not allowed")
		message_admins("Failed Login: [key] - Guests not allowed")
		return list("reason"="guest", "desc"="\nReason: White is so great, BYOND account is not required, right?")

	return ..()	//default pager ban stuff
