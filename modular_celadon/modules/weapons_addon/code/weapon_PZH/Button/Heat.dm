// ============================================================
// Knapka shob tikat
// ============================================================
/datum/action/item_action/gun_heat_bullet
	name = "Superheat Chambered Round"
	desc = "Channels weapon heat into the chambered bullet. Increases gun heat, but the next shot will ignite the target and pierce armor. Must be fired within 5 seconds!"
	button_icon = 'modular_celadon/modules/weapons_addon/icons/phz.dmi'
	button_icon_state = "Heating"
	background_icon_state = "bg_tech_blue"

/datum/action/item_action/gun_heat_bullet/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE

	var/obj/item/gun/ballistic/automatic/automatically_weapon/PZH = target
	var/mob/living/carbon/human/user = owner

	if(!istype(PZH) || !istype(user))
		return FALSE

	if(PZH.overheated)
		to_chat(user, span_warning("[PZH] is overheated and cannot channel energy!"))
		return FALSE

	if(!PZH.chambered)
		to_chat(user, span_warning("There is no bullet in the chamber to heat up!"))
		return FALSE

	if(PZH.bullet_is_burning)
		to_chat(user, span_warning("The bullet in the chamber is already superheated!"))
		return FALSE

	to_chat(user, span_notice("You begin channeling magnetic induction to heat the chambered round..."))
	if(!do_after(user, 1.5 SECONDS, target = PZH))
		to_chat(user, span_warning("You interrupted the heating process!"))
		return FALSE

	if(!PZH.chambered || PZH.overheated)
		to_chat(user, span_warning("Heating failed: chamber status changed."))
		return FALSE

	PZH.current_heat = min(PZH.max_heat, PZH.current_heat + 30)
	PZH.bullet_is_burning = TRUE
	PZH.start_cooling_loop()
	PZH.update_heat_state()

	to_chat(user, span_userdanger("The bullet in the chamber glows cherry red! Shoot within 5 seconds!"))

	PZH.burning_bullet_timer = addtimer(CALLBACK(PZH, /obj/item/gun/ballistic/automatic/automatically_weapon/proc/bullet_cookoff), 5 SECONDS, TIMER_STOPPABLE)
	return TRUE
