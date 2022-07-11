#define SAVEFILE_VERSION_MIN	2
#define SAVEFILE_VERSION_MAX	2

/datum/preferences/proc/savefile_path(mob/user)
	return "data/player_saves/[copytext(user.ckey, 1, 2)]/[user.ckey]/preferences.sav"
