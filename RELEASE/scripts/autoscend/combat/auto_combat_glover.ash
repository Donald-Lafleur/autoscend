string auto_combatGloverStage5(int round, monster enemy, string text)
{
    // stage 5 = kill
	if(!in_glover())
	{
		return "";
	}

    // Try to just let the default combat code handle it, probably
    // by just whacking things with whatever weapon we have equipped.
    if(round < 15 && canSurvive(15 - round) && !will_usually_miss())
    {
        return "";
    }

    // SC's wielding clubs gets handled in the default combat code,
    // so we can't rely on guaranteed hits from a club. Wiki says there
    // is a bonus chance to hit for LTS as if you had 25% more buffed muscle,
    // and I think this is a conservative way to calculate that.
	if(current_hit_stat() == $stat[Muscle] && canUse($skill[Lunging Thrust-Smack], false) &&
    (buffed_hit_stat() + (0.20 * my_basestat(current_hit_stat()))) > monster_defense(enemy))
    {
        return useSkill($skill[Lunging Thrust-Smack], false);
    }

    skill cheesestorm = $skill[K&auml;seso&szlig;esturm];
    if(canUse(cheesestorm, false) && monster_element(enemy) != $element[stench])
    {
        return useSkill(cheesestorm, false);
    }

    // Saucegeyser is expensive so we only want to cast it once.
    // If just attacking a would win, that's what we want to do.
	if((round > 20 || will_usually_miss()) && canUse($skill[saucegeyser]))
    {
        return useSkill($skill[saucegeyser]);
    }

    if(round == 24 && !have_skill(cheesestorm))
    {
        auto_log_warning("Perming " + cheesestorm + " would probably make combat easier");
    }

    return "";
}