// This uses Ezandora's wonderful Helix Fossil script to handle building a team and combat.
boolean in_pokefam()
{
	return my_path() == $path[Pocket Familiars];
}

void pokefam_initializeSettings()
{
	if(in_pokefam())
	{
		// No need to restore HP or MP in Pocket Familiars.
		set_property("auto_ignoreRestoreFailure", true);
		// No need for a beehive as combat is different.
		set_property("auto_getBeehive", false);
		set_property("auto_ignoreFlyer", true);
		// No Naughty Sorceress so no need for a wand.
		set_property("auto_wandOfNagamar", false);
		set_property("auto_buyPokefamCaps", true);
	}
}

string pokefam_defaultMaximizeStatement()
{
	// Combat is completely different in pokefam, so most stuff doesn't matter there
	string res = "5item,meat";
	if(my_level() < 13 || get_property("auto_disregardInstantKarma").to_boolean())
	{
		res += ",10exp,5" + my_primestat() + " experience percent";
	}
	return res;
}

int pokefam_currentPokedollars()
{
	// Visit the pokemporium to collect pokedollars for leveling up familiars.
	// For whatever reason this only works if you do it this way. Using visit_url
	// causes the available amount value to be changed to the amount gained when visiting. 
	cli_execute("shop.php?whichshop=pokefam");
	return available_amount($item[1\,960 pok&eacute;dollar bill]);
}

void pokefam_purchaseBestCap()
{
	// Only spend pokedollars on caps. Helix Fossil handles the familiar selection,
	// so we wouldn't know what fams to use the vitamins on anyway.
	item best_cap = $item[none];
	// Avarice is 100% item drop, Sloth is -15% combat rate, Wrath is +30 ML, Mu is +4 all res.
	foreach cap in $items[Team Avarice Cap, Team Sloth Cap, Team Wrath Cap, Mu Cap]
	{
		if(!possessEquipment(cap))
		{
			best_cap = cap;
			break;
		}
	}

	if(best_cap == $item[none])
	{
		set_property("auto_buyPokefamCaps", false);
		auto_log_info("You have all 4 team caps now or don't need any of them, so there's nothing left worth saving for.");
		return;
	}

	// We can afford it and should buy it to see if there's something else we want to save for.
	if(!buy($coinmaster[The Pok&eacute;mporium], 1, best_cap))
	{
		auto_log_error("Pokemporium Cap purchase failed. If this happens repeatedly manually set auto_buyPokefamCaps to false");
	}
}

void pokefam_makeTeam()
{
	if(!in_pokefam())
	{
		return;
	}

    // Check if we can buy a team cap from the pokemporium, and if we can do so.
	if(pokefam_currentPokedollars() >= 50 && get_property("auto_buyPokefamCaps").to_boolean())
	{
		pokefam_purchaseBestCap();
	}

	if(git_exists("Ezandora-Helix-Fossil"))
	{
		// The argument to the script is the max desired number of level 5 fams to include. It's 2 when we have
		// something to buy in order to allow a middle spot for a pocket familiar to level up and earn pokebucks.
		// It might be worth trying to use only 1 level 5 familiar if we have a level 5 slotter.
		auto_log_info("Setting our team via Ezandora:", "green");
		int max_level_5_fams = 2;
		if(get_property("_auto_pokefamLosses").to_int() > 20)
		{
			max_level_5_fams = 3;
		}
		else if(in_terrarium($familiar[slotter])) // Ezandora's script will always use slotter
		{
			max_level_5_fams = 1;
		}
		cli_execute("PocketFamiliarsAutoSelect Strongest " + max_level_5_fams);
	}
}

boolean L12_pokefam_clearBattlefield()
{
	// Pocket Familiars specific handling for clearing the battlefield.
	if(!in_pokefam())
	{
		return false;
	}

	if (internalQuestStatus("questL12War") != 1)
	{
		return false;
	}

	if (get_property("hippiesDefeated").to_int() < 1000 && get_property("fratboysDefeated").to_int() < 1000)
	{
		auto_log_info("Doing the wars.", "blue");
		equipWarOutfit();
		return warAdventure();
	}
	return false;
}
