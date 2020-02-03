local entries = {
	-- Factions
	faction_union = { -- planet3, planet5
		name = "The Union",
		category = "Factions",
		text = "Official name: the Union of Sovereign Star-Systems"
		.. "/nSeveral acronyms were used on occasion, but the variety of official languages between the varied systems-states made it impossible for a majority to agree on a single one."
		.. "/n "
		.. "/nThis polity seems to have started as a defensive alliance, as the old empire was falling apart. Many systems in the region had long-suppressed desires for independence, and banded together to maintain a semblance in the slow disappearance of imperial law. With time, trade and law enforcement agreements completed the military treaties, and the Union slowly became a political entity in its own right, if a very decentralized one constituted of very autonomous members."
		.. "/n "
		.. "/nAs it grew in size and strength, it also started to run into rivals, both over strategic places and ideology. This drove them to create an unified military and foreign service, with the occasional bout of expansionism."
		.. "/nIt seems to have fared relatively well, until they were were faced with a much stronger enemy against whom they started to loose system after system."
		.. "/nWith the enemy at the gates of their core worlds, there was little hope of repelling them without of a miracle - instead of what, everyone disappeared."
	},
	faction_empire = { -- planet11, planet12, planet15, planet16, planet17, planet24, planet25, planet26
		name = "The Empire",
		category = "Factions",
		text = "Official name: the Ninth Galactic State, Second Restoration"
		.. "/nAs they started winning, everyone called it the Galactic Empire, or simply the Empire"
		.. "/n "
		.. "/nThe origin of this new Restoration is unclear. They claim that as the previous empire disintegrated, it retained its traditions and a core of systems, from which it started to rebuild and reassert itself and. They based the legitimacy of their grand conquest by turning it into a reclamation of its rightful place as the sole ruler of the galaxy. As such, it is unsurprising that their enemies would have less flattering histories, the most popular being that an ambitious warlord conquered the fallen empire's homeworlds before having delusions of grandeur."
		.. "/n "
		.. "/nWhatever the truth is, they did retain many of the traditions of the previous empire, and initially based their legal system and political organization on it. By the force of arms, they managed to slowly but surely conquer the galaxy again, with more and more resources and autonomy given to their formidable military machine. In the end, there were only a few factions still resisting them, with little hope of repelling their armies."
		.. "/nHowever, with so much of the empire's efforts being diverted toward the armies, it appears to have been growing unrest on many conquered worlds across the galaxy."
	},
	faction_rebels = { -- planet36, planet37, planet39, planet40, planet42, planet44, planet47, planet48, planet56
		name = "The Rebels",
		category = "Factions",
		text = "Unrest was steadily growing across the Empire, both on wealthy peripheral worlds and poor, isolated ones, mostly from the resources and attention diverted towards their war machine, and the rule of law becoming both harsher and less effective at keeping order. The Empire thought they could hold enough authority to prevent any serious challenge to their rule, at least for long enough to finish pacifying the galaxy. It appears they were wrong."
		.. "/nSeveral uprisings started on varied worlds in a large portion of the Empire. Unprepared to such a large rebellion, faced with an enemy relying more on subversion and deception than military control of territory, it quickly lost control of entire regions. The Empire was prompt to turn its war machine inward and crush the rebellion by the force of arms, as daunting a task as it was."
		.. "/n "
		.. "/nThe goal of the Rebels was not direct victory so much as mortally injuring the Empire from the inside, and holding long enough to survive it. What plans did they have for the aftermath is unclear, given how many disparate groups participated. However, for such coordinated uprisings to take place, a central organization had to be overseeing it. Was it an ad-hoc coalition of mutually hostile forces against a greater common enemy, or did they have their own agenda?"
	},
	faction_haven = { -- planet31
		name = "Haven",
		category = "Factions",
		text = ""
	},
	faction_lawless = { -- planet28, planet29, planet34, planet35, planet41, planet49, planet50, planet53
		name = "The Lawless",
		category = "Factions",
		text = ""
	},
	faction_dynasties = { -- planet 46, planet47, planet56
		name = "Dynasties",
		category = "Factions",
		text = ""
	},
	faction_dynasties_restored = { -- planet58, planet59
		name = "Dynasties Restored",
		category = "Factions",
		text = ""
	},
	faction_exarchs = { -- planet32
		name = "Exarchs",
		category = "Factions",
		text = ""
	},
	faction_survivors = { -- planet51, planet55, planet62
		name = "Survivors",
		category = "Factions",
		text = ""
	},
	
	-- Threats
	threat_automata = { -- planet69
		name = "Automata",
		category = "Threats",
		text = "Left to themselves, most armies will fall dormant to minimize energy and maintenance requirements. With proper settings and their own nanolathe arrays, they can stay functional for a very long time. And they will leave enough sensors active to detect threats, then awaken and engage them until new orders or supervision are received."
		.. "/n "
		.. "/nUnfortunately, it seems I lack the proper identification codes to be recognized by most of those damn automata, or enough time to find a flaw in their code and hack them - so they are engaging me on sight. There may not be sapient minds behind them, but tactical AIs should not be underestimated, especially when they have the home advantage."
		.. "/n "
		.. "/nI will need to be careful, choose the time and place of battle, and not wait for reinforcements from everywhere on the planet to overwhelm me, but I can make it. Not that I have a choice..."
	},
	threat_zombies = { -- planet43, planet59
		name = "Zombies",
		category = "Threats",
		text = "Suspected to be an ancient terror weapon for the defense by mutually-assured destruction of a long-forgotten polity, the zombie nanoplague was for a long time the most feared contagion in existence."
		.. "/n "
		.. "/nExtraordinarily virulent, it will contaminate an entire planet in less than a week from a single carrier, and cause the death of any organic lifeform in a few minutes at most. Only the most advanced antinanite barriers will stop it, and it will take over any civilian or insufficiently protected military machines. And what gave it its name is how even the most advanced military systems will be taken over and resurrected. The only way to neutralize for good an infected unit is to also destroy its wreck."
		.. "/n "
		.. "/nSome degree of coordination has been observed between infected units, but nothing like a collective intelligence seem to exist, and infected units are only driven by basic instructions to seek and destroy uninfected hardware, so it can be taken over in turn."
		.. "/n "
		.. "/nLeft to itself, a contaminated world will see its units fall dormant and slowly degrade as nanites cannibalize more and more of them to renew themselves. Fortunately, there is no programming for interplanetary or interstellar contamination, even when space-capable hardware is infected - which often degrades too fast to be capable of reaching other worlds in any cases, so quarantine is effective as containment method."
		.. "/n "
		.. "/nHowever, reclaiming contaminated worlds is extremely difficult, as those are much more resilient than any nanite should be able to. In dormant spore mode, it has been known to survive nuclear explosions. And while effective if painstakingly laborious methods were devised with time, tracking and destroying every secret laboratory having kept a sample proved to be a Sisyphean task, never to be quite over."
	},
	threat_chickens = { -- planet21, planet38, planet63
		name = "Chickens",
		category = "Threats",
		text = "Gallinuloides Horribilis"
		.. "/n "
		.. "/nHow the hell is that their official name? There is practically no biological link between those things and old Earth galliformes! In fact, those things are less birds than even mammals."
		.. "/n "
		.. "/nThe so-called chicken are a xenoform species of unknown origin, based on a hive-like social structure with specialized zooids with little to no individuality, and what is assumed to be a collective mind centered around a Queen. Whether they possess organic technology or simply extreme adaptation, the organisms forming a collective vary from tiny workers, light scouts and flyers the size of a small bombers to immobile spore-throwers, gigantic White Dragon and finally the Queen itself, a terrifying war machine that will act as final military reserves to an angered colony."
		.. "/n "
		.. "/nThey are invariably hostile when active, with no rumors of successful cohabitation with humans ever confirmed. They can however stay dormant for long periods in deep, near-undetectable underground chambers to which they are suspected to retreat upon the death of their Queen. This has made their complete eradication from a planet extremely challenging, especially if infrastracture or terraforming efforts are to be preserved."
		.. "/n "
		.. "/nHypotheses about their origins run from ancient dormant aliens awakened by human activity to secret weapon gone rogue to results of experiment on accelerated evolution that went wrong - or horribly right."
		-- ed note: The chickens are actually a secret project by a family of the early Dynasties. Observing the deficiencies of even regular modded humans, they sought to create a Humans 2.0 with traits such as extreme adaptation, collective intelligence over many zooids instead of singular body, ability to metabolize any CHON substrate, and other such fantastic abilities. They tried to keep it secret from rival families, recognizing correctly that they would not accept being displaced by Humans 2.0, but they ended up being discovered. The Dynasties panicked and eradicated the family, erasing every bit of data about it they could find so it couldn't be linked to them - fearing that humanity would turn against them in the same panic. It wouldn't be before centuries had passed that they would realize that they had missed some of the subjects.
	},
	threat_chickens_lifecycle = { -- planet38
		name = "Chickens lifecycle",
		category = "Threats",
		text = "Little is known or understood about the lifecycle of chicken. Colonies are centered around a Queen, which will be abandoned upon its death. Whether the colony is destroyed, its dormant remains taken over by a new one or if it will produce a new Queen after a long enough time is unknown, as is how Queens themselves are born and form new colonies."
		.. "/n "
		.. "/nDormant chicken can endure millennia in extremely deep stealth underground chambers, while active colonies form bewildering tunnel complexes, with little surface activity - though some cases of what may be surface agriculture have been observed. Size and activity of individual colonies vary wildly, from lone mountains to entire continents, and ranging from a few scattered zooids to subterranean metropolis. Given time, their activities will inevitably cover he entire planet."
		.. "/n "
		.. "/nChicken biology seem relatively close to Earth-native biology, but with significant, inexplicable differences, which may be sign of convergent evolution, Earth ancestry or an ability to copy and reuse foreign biological processes. Unsettlingly, human DNA markers have been found on what acts as their core genetic system."
	},
	threat_chickens_travel = { -- planet21
		name = "Chickens interstellar travel",
		category = "Threats",
		text = "No chicken space organism has ever been detected, nor stowaway zooid or biological material that could have started a new colony. Despite this, new colonies have regularly been found on worlds with no previously known chicken presence. While some could be explained by undetected dormant elements, some had ruled it out with near-certainty. As such, it has generally been accepted that chicken have means to either move or seed new colonies over interstellar distances. Whether by slower-than-light dormant seeds, incredibly stealthy starships, extremely sophisticated detection systems to launch far from human sensors, or even deep underground warp portals working by unknown physical principles, no concrete element has been found."
		.. "/n "
		.. "/nChicken have existed for at least as long as the early days of the human galactic age and their capabilities to live on almost any type of planet without any need for terraforming. Despite this and their demonstrated interstellar capabilities, they have never settled on more than a proportionally a handful of worlds, even including those ignored by humans as unsuitable for colonization or exploitation. Why haven't they long overrun has been said to be the key to understand what they really are."
	},
	threat_chickens_intelligence = { -- planet63
		name = "Chickens intelligence",
		category = "Threats",
		text = "Chicken thought processes, or even whether they are even sapient, is unknown. They have however proven themselves to be remarkably good at planning, adaptation and long-term resource management. Their degree of understanding of human societies is unknown, but they have sometimes been eerily good at striking unsuspecting or unprepared settlements at the worst possible time and place. Though some attribute this to exceptional pattern-recognition, others have hypothesized an ability to spy on and understand human communications and societies."
		.. "/n "
		.. "/nInter-colony skirmishes have been observed, often limited to underground tunnel fighting and nowhere near with the level of violence seen against humans, or with a Queen directly intervening. Similarly, while colonies don't always cooperate against humans and some prefer to go dormant than fight, no skirmish has ever been observed on a conflict where a colony was engaged against humans. Long-range coordination of chicken forces also hint at sophisticated inter-colony communications, though by which mechanisms is unknown. Controversial evidence of interstellar communication have been presented, but has always been judged invalid or inconclusive."
		.. "/n "
		.. "/nNo successful communicating with a collective mind has ever been demonstrated, however most have ended up in catastrophe, considerably limiting the number of latter attempts. This includes attempts at tacit understanding between settlers and local colonies for division of lands or resources. Conversely, no communication attempt from a collective mind have ever been recorded."
		.. "/n "
		.. "/nContrasting with their sophistication in many other domains, their strangely primitive warfare tactics has puzzled many scientists. Through history, mentions have been made of contact being lost with entire worlds, with nothing but ruins being discovered afterwards, and no explanation about what had happened - some have hypothesized that it could be the result of chicken colonies attacking with their full potential and intelligence."
	},
	
	-- Entries
	entry_first = { -- planet69
		name = "On a dam of all places",
		category = "Entries",
		text = "What am I doing on a hostile fortress world? Was I captured? But then why didn't the pull me out before moving me around? There is no trace planetary assault - then were those subverted by deep agents? A mistimed diversion? Why hasn't anyone intervened yet? Something feels very wrong."
		.. "/n "
		.. "/nSomehow the defense grid is still on automated alert. Something must be keeping everyone busy and a starship has answered my distress call. This is my chance to jump out of the system."
	},
	entry_commander = { -- planet1
		name = "Assault commander",
		category = "Entries",
		text = "Commanders are an old concept. Put everything needed to build an army with local resources on a compact chassis, slap a weapon and some armor, and harden it all for fast insertion on a hostile planet. Hopefully they send you on a less defended part of the world, where you are left alone long enough to entrench yourself, and launch an assault on strategic locations - or open a gate for the real assault forces to get in. Or you are defending a planet and get thrown wherever the enemy is deciding to land, then try and kill them before they can build enough of an army to kill you."
		.. "/n A few tried and true models, perfected for cost, effectiveness and reliability over many wars, and pretty much no surprise for many centuries. My memories are still blurred, but I remember extensively training on those."
		.. "/n "
		.. "/nAnd yet, this Assault Commander is unlike anything I have ever seen."
		.. "/nOne of the biggest limitations to Commander design is that they cannot jump with field improvements such as extra weapons, armor or system. Many have tried, and no-one is known to get even close to it, even in the old days. But, this one can. For each field upgrade I recover, it stays intact at a jump."
		.. "/n "
		.. "/nI never trained for it, or even heard of such a thing. And yet, it feels oddly familiar..."
	},
	entry_event = { -- planet2
		name = "Event",
		category = "Entries",
		text = "It is not just those worlds that are empty. It is the entire galaxy."
		.. "/nAgain, old ruins from what could be the same time litter the planet. But when I try to pick up long-range signals, detect hyperspace movements or any other sort of activity, the galaxy is silent. If someone is still out there, they either lost all interstellar capabilities, or they are hiding very well."
		.. "/n "
		.. "/nHow long has it been? What little star charts are left from the database are useless due to star drift, and I have neither the tools nor the knowledge required for dating the ruins. It could have been millennia. It could have been millions of years."
		.. "/nBut some recording survived, enough to prove that whatever the event was, it happened in an instant. One moment everyone was there, a day like any other. The next moment, they were all gone. Baselines, modified, cyborgs, synths, uplifts, free machines - everyone, no exception, and nothing else..."
	},
	entry_homeworld = { -- planet66
		name = "Homeworld",
		category = "Entries",
		text = ""
	},
	entry_starsong = { -- planet67
		name = "Starsong",
		category = "Entries",
		text = ""
	},
	entry_eternity_gate = { -- planet68
		name = "The Eternity Gate",
		category = "Entries",
		text = ""
	},
	
	-- Locations
	location_im_jaleth = { -- planet1
		name = "Im Jaleth ruins",
		category = "Locations",
		text = "This world has been abandoned for a very, very long time. What little ruins I had time to unearth were buried very deep, and all from the same geological strata. For some reason, the entire planet seem to have been abandoned at once, and never repopulated"
		.. "/nWas it kept empty as a buffer before the Folsom fortress world? Depriving themselves of a good inhabitable world like this one for a small strategic gain feels wasteful."
		.. "/n "
		.. "/nAnd again, no one has challenged me beyond automated defenses. No hails, no communications. Automata can be left to their own devices pretty much indefinitely, but why keep an empty buffer world and not leave overseers in case of surprise?"
	},
	location_chatka = { -- planet58
		name = "Battle of Chatka",
		category = "Locations",
		text = ""
	},
	location_tempest = { -- planet59
		name = "Tempest archeotech site",
		category = "Locations",
		text = ""
	},
	location_hibiliha = { -- planet61
		name = "Hibiliha warp station",
		category = "Locations",
		text = ""
	},
	location_intrepid = { -- planet64
		name = "The Garden of Intrepid",
		category = "Locations",
		text = ""
	},
	location_mannia = { -- planet64
		name = "Mannia transit camps",
		category = "Locations",
		text = ""
	},
	
	-- TODO remove empty example
	example_dropships = {
		name = "Dropships",
		category = "Example",
		text = ""
	},
}

for i,v in pairs(entries) do
	v.id = i
end

return entries
