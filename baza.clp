
;;;======================================================
;;; A little program to help with choosing game to play ;-)
;;;
;;; Needs dedicated .NET app to run
;;;
;;; Author:
;;; Michal Grzegorczyk
;;;======================================================

;;; ***************************
;;; * DEFTEMPLATES & DEFFACTS *
;;; ***************************

(deftemplate UI-state
   (slot id (default-dynamic (gensym*)))
   (slot display)
   (slot relation-asserted (default none))
   (slot response (default none))
   (multislot valid-answers)
   (slot state (default middle)))
   
(deftemplate state-list
   (slot current)
   (multislot sequence))
  
(deffacts startup
   (state-list))
   
;;;****************
;;;* STARTUP RULE *
;;;****************

(defrule system-banner ""

  =>
  
  (assert (UI-state (display WelcomeMessage)
                    (relation-asserted start)
                    (state initial)
                    (valid-answers))))

;;;***************
;;;* QUERY RULES *
;;;***************

(defrule which-genre-question
	(start)
    =>	
    (assert (UI-state (display WhichGenreQuestion)
                     (relation-asserted which-genre)
                     (response Medieval_Fantasy)
                     (valid-answers Medieval_Fantasy Far_future Mecha Genres_related_to_near_present Westerns Supers Other_alternative_history Genre_should_not_matter))))

(defrule which-sub-genre
	(which-genre Medieval_Fantasy)
    =>	
    (assert (UI-state (display WhichSubGenreQuestion)
                     (relation-asserted which-sub-genre)
                     (response Humor)
                     (valid-answers Humor High_fantasy/General High_magic Low_fantasy Oriental))))

(defrule with-meta-plots
	(which-sub-genre Oriental)
    =>	
    (assert (UI-state (display WithMetaPlotsQuestion)
                     (relation-asserted with-meta-plots)
                     (response Yes)
                     (valid-answers Yes No))))

(defrule semi-historical
	(which-sub-genre High_magic)
    =>	
    (assert (UI-state (display SemiHistoricalQuestion)
                     (relation-asserted semi-historical)
                     (response No)
                     (valid-answers No Yes))))

(defrule hybridize-it
	(semi-historical No)
    =>	
    (assert (UI-state (display HybridizeItQuestion)
                     (relation-asserted hybridize-it)
                     (response No)
                     (valid-answers No Yes))))

(defrule have-cash
	(which-sub-genre Low_fantasy)
    =>	
    (assert (UI-state (display HaveCashQuestion)
                     (relation-asserted have-cash)
                     (response Oodles)
                     (valid-answers Oodles Not_really))))

(defrule want-to-finance-store
	(have-cash Oodles)
    =>	
    (assert (UI-state (display WantFinanceStoreQuestion)
                     (relation-asserted want-finance-store)
                     (response Yes)
                     (valid-answers Yes Not_really))))

(defrule have-cash-loop
	?ind1 <- (have-cash Oodles)
    ?ind2 <- (want-finance-store Not_really)
    =>	
    (retract ?ind1)
    (retract ?ind2)
    (assert (UI-state (display HaveCashQuestion)
                     (relation-asserted have-cash)
                     (response Oodles)
                     (valid-answers Oodles Not_really))))

(defrule old-or-new
	(have-cash Not_really)
    =>	
    (assert (UI-state (display OldNewQuestion)
                     (relation-asserted old-or-new)
                     (response Old)
                     (valid-answers Old New))))

(defrule want-slew-or-skills
	(old-or-new Old)
    =>	
    (assert (UI-state (display SlewOrSkillsQuestion)
                     (relation-asserted want-slew-or-skills)
                     (response Not_really)
                     (valid-answers Not_really >15_abilities))))

(defrule really-genre
	(which-genre Genre_should_not_matter)
    =>	
    (assert (UI-state (display ReallyQuestion)
                     (relation-asserted really-genre)
                     (response Yes)
                     (valid-answers Yes Not_really))))


(defrule which-genre-loop
	?ind1 <- (really-genre Not_really)
    ?ind2 <- (which-genre Genre_should_not_matter)
    =>	
    (retract ?ind1)
    (retract ?ind2)
    (assert (UI-state (display WhichGenreQuestion)
                     (relation-asserted which-genre)
                     (response Medieval_Fantasy)
                     (valid-answers Medieval_Fantasy Far_future Mecha Genres_related_to_near_present Westerns Supers Other_alternative_history Genre_should_not_matter))))

(defrule with-classes
	(which-sub-genre High_fantasy/General)
    =>	
    (assert (UI-state (display WithClassesQuestion)
                     (relation-asserted with-classes)
                     (response Point_Systems)
                     (valid-answers Point_Systems Just_give_me_the_D'n'D_options 4_custom_charts_per_class No_class._All_point_buy))))

(defrule mythology-based
	(with-classes Point_Systems)
    =>	
    (assert (UI-state (display MysthologyQuestion)
                     (relation-asserted mythology-based)
                     (response No)
                     (valid-answers No Yes))))

(defrule gygax-opinion
	(with-classes Just_give_me_the_D'n'D_options)
    =>	
    (assert (UI-state (display GygaxQuestion)
                     (relation-asserted gygax-opinion)
                     (response He_is_the_father_of_RPGs)
                     (valid-answers He_is_the_father_of_RPGs He_is_cool Who_is_he))))

(defrule fundamentalist
	(gygax-opinion He_is_the_father_of_RPGs)
    =>	
    (assert (UI-state (display FundamentalistQuestion)
                     (relation-asserted fundamentalist)
                     (response No)
                     (valid-answers No Yes))))
                     
(defrule races-as-classes
	(fundamentalist No)
    =>	
    (assert (UI-state (display RacesAsClassesQuestion)
                     (relation-asserted races-as-classes)
                     (response Yes)
                     (valid-answers Yes Why_the_heck_can_not_my_dwarf_be_a_cleric Only_2_classes_are_needed I_am_a_schizo_and_want_skills_with_that))))

					 
(defrule what-based
	(which-genre Other_alternative_history)
    =>	
    (assert (UI-state (display WhatBasedQuestion)
                     (relation-asserted what-based)
                     (response FATE)
                     (valid-answers FATE Neither D20))))

(defrule supernatural-or-pulp
	(what-based FATE)
    =>	
    (assert (UI-state (display SupernaturalPulpQuestion)
                     (relation-asserted supernatural-or-pulp)
                     (response Supernatural)
                     (valid-answers Supernatural Pulp))))

(defrule oah-sub
	(what-based Neither)
    =>	
    (assert (UI-state (display OAHQuestion)
                     (relation-asserted oah-sub)
                     (response Pulp)
                     (valid-answers Pulp Japanese/Samurai Mobsters_1930s))))
(defrule what-is-math
	(really-genre Yes)
    =>	
    (assert (UI-state (display MathQuestion)
                     (relation-asserted what-is-math)
                     (response Huh)
                     (valid-answers Huh It_should_be_+x_not_+xy A_differential_equation))))



(defrule open-game
	(what-is-math Huh)
    =>	
    (assert (UI-state (display OpenGameQuestion)
                     (relation-asserted open-game)
                     (response Yes)
                     (valid-answers Yes No Does_not_matter))))

(defrule really-open
	(open-game Does_not_matter)
    =>	
    (assert (UI-state (display ReallyQuestion)
                     (relation-asserted really-open)
                     (response Sorta)
                     (valid-answers A_facist_could_make_it_for_all_I_care Sorta))))

(defrule cinematic
	(open-game Yes)
    =>	
    (assert (UI-state (display CinematicQuestion)
                     (relation-asserted cinematic)
                     (response Cinematic)
                     (valid-answers Cinematic Humor No))))

(defrule niche-genre
	(cinematic No)
    =>	
    (assert (UI-state (display NicheGenreQuestion)
                     (relation-asserted niche-genre)
                     (response No)
                     (valid-answers No Super_Heroes))))

(defrule real-comics
	(which-genre Supers)
    =>	
    (assert (UI-state (display RealComicsQuestion)
                     (relation-asserted real-comics)
                     (response DC)
                     (valid-answers No_or_other DC Marvel))))

(defrule d20-like
	(real-comics No_or_other)
    =>	
    (assert (UI-state (display D20LikeQuestion)
                     (relation-asserted d20-like)
                     (response No)
                     (valid-answers No Yes))))


(defrule point-buy
	(d20-like No)
    =>	
    (assert (UI-state (display PointBuyQuestion)
                     (relation-asserted point-buy)
                     (response Yes)
                     (valid-answers Yes Yes,_with_fractions Not_really))))

(defrule which-d
	(real-comics DC)
    =>	
    (assert (UI-state (display WhichDQuestion)
                     (relation-asserted which-d)
                     (response D20)
                     (valid-answers D20 D10 D6))))

(defrule which-system
	(real-comics Marvel)
    =>	
    (assert (UI-state (display SystemQuestion)
                     (relation-asserted which-system)
                     (response Diceless)
                     (valid-answers Diceless Online_Fansites))))

(defrule combat
	(which-genre Westerns)
    =>	
    (assert (UI-state (display CombatQuestion)
                     (relation-asserted combat)
                     (response Yes)
                     (valid-answers Yes No))))

(defrule steampunk
	(combat No)
    =>	
    (assert (UI-state (display SteamPunkQuestion)
                     (relation-asserted steampunk)
                     (response Yes)
                     (valid-answers Yes No))))

(defrule how-tailored
	(which-genre Mecha)
    =>	
    (assert (UI-state (display HowTailoredQuestion)
                     (relation-asserted how-tailored)
                     (response Mangled)
                     (valid-answers Just_an_add-on I_am_houseruling_it_all_anyway Mangled))))


(defrule universal-system
	(how-tailored I_am_houseruling_it_all_anyway)
    =>	
    (assert (UI-state (display UniversalSystemQuestion)
                     (relation-asserted universal-system)
                     (response Yes)
                     (valid-answers Yes No))))

(defrule undead
	(which-genre Genres_related_to_near_present)
    =>	
    (assert (UI-state (display UndeadQuestion)
                     (relation-asserted undead)
                     (response Not_really)
                     (valid-answers I_can_be_a_vampire If_done_well Not_really))))


(defrule humor-spies-cyber
	(undead Not_really)
    =>	
    (assert (UI-state (display HSCQuestion)
                     (relation-asserted humor-spies-cyber)
                     (response Humor)
                     (valid-answers Humor Spies Cyberpunk))))


(defrule genres-mixed
	(humor-spies-cyber Cyberpunk)
    =>	
    (assert (UI-state (display GenresMixedQuestion)
                     (relation-asserted genres-mixed)
                     (response Straight_up)
                     (valid-answers Straight_up A_little_of_everything Some_magic))))

(defrule what-spies
	(humor-spies-cyber Cyberpunk)
    =>	
    (assert (UI-state (display SpiesQuestion)
                     (relation-asserted what-spies)
                     (response Old)
                     (valid-answers Old New))))

(defrule full-or-lite
	(what-spies New)
    =>	
    (assert (UI-state (display FullLiteQuestion)
                     (relation-asserted full-or-lite)
                     (response Full_D20)
                     (valid-answers Full_D20 Lite))))


(defrule movie-or-tv
	(which-genre Far_future)
    =>	
    (assert (UI-state (display MTVQuestion)
                     (relation-asserted movie-or-tv)
                     (response Star_Wars)
                     (valid-answers Star_Wars No Other))))

(defrule star-wars
	(movie-or-tv Star_Wars)
    =>	
    (assert (UI-state (display StarWarsQuestion)
                     (relation-asserted star-wars)
                     (response No)
                     (valid-answers No Yes))))

(defrule open-game-future
	(movie-or-tv No)
    =>	
    (assert (UI-state (display OpenGameFutureQuestion)
                     (relation-asserted open-game-future)
                     (response Yes_and_no)
                     (valid-answers Yes_and_no Yes No))))

(defrule derivative
	(open-game-future No)
    =>	
    (assert (UI-state (display DerivativeQuestion)
                     (relation-asserted derivative)
                     (response Yes)
                     (valid-answers Yes Not))))

(defrule what-e
	(derivative Yes)
    =>	
    (assert (UI-state (display WhatEQuestion)
                     (relation-asserted what-e)
                     (response 2E)
                     (valid-answers 2E 3E 4E Old_school))))

(defrule fiction-or-fantasy
	(what-e Old_school)
    =>	
    (assert (UI-state (display FOrFQuestion)
                     (relation-asserted fiction-or-fantasy)
                     (response Science_Fiction)
                     (valid-answers Science_Fiction Science_Fantasy))))

(defrule gothic
	(derivative Not)
    =>	
    (assert (UI-state (display GothicQuestion)
                     (relation-asserted gothic)
                     (response Gothic)
                     (valid-answers Post_Apoc Gothic Space_Opera))))

;;; ***************************
;;; *  FINAL  *  CONCLUSIONS  *
;;; *************************** 
(defrule hackmaster
    (which-sub-genre Humor)
     =>
	(assert (UI-state (display Hackmaster)
                      (state final)
                     )))
                     
(defrule oriental
    (with-meta-plots No)
     =>
	(assert (UI-state (display Oriental)
                      (state final)
                     )))	

(defrule loft5r
    (with-meta-plots Yes)
     =>
	(assert (UI-state (display Loft5r)
                      (state final)
                     )))	

(defrule ars-magica
    (semi-historical Yes)
     =>
	(assert (UI-state (display Arsmagica)
                      (state final)
                     )))	

(defrule earth-dawn
    (hybridize-it Yes)
     =>
	(assert (UI-state (display Earthdawn)
                      (state final)
                     )))	
(defrule rune-quest
    (hybridize-it No)
     =>
	(assert (UI-state (display Runequest)
                      (state final)
                     )))
                     
(defrule warhammer
    (want-to-finance-store Yes)
     =>
	(assert (UI-state (display Warhammer)
                      (state final)
                     )))	
(defrule conan-tsr
    (want-slew-or-skills Not_really)
     =>
	(assert (UI-state (display Conantsr)
                      (state final)
                     )))		
(defrule conan-mongoose
    (old-or-new New)
     =>
	(assert (UI-state (display Conanmongoose)
                      (state final)
                     )))		
(defrule harnmaster
    (want-slew-or-skills >15_abilities)
     =>
	(assert (UI-state (display Harnmaster)
                      (state final)
                     )))	

(defrule fantasy-hero
    (with-classes No_class._All_point_buy)
     =>
	(assert (UI-state (display Fantasyhero)
                      (state final)
                     )))		
(defrule rolemaster
    (with-classes 4_custom_charts_per_class)
     =>
	(assert (UI-state (display Rolemaster)
                      (state final)
                     )))		

(defrule fantasy-hero2
    (mythology-based No)
     =>
	(assert (UI-state (display Fantasyhero)
                      (state final)
                     )))		

(defrule exalted
    (mythology-based Yes)
     =>
	(assert (UI-state (display Exalted)
                      (state final)
                     )))	

(defrule dd4e
    (gygax-opinion Who_is_he)
     =>
	(assert (UI-state (display Dd4e)
                      (state final)
                     )))		

(defrule dd0e
    (fundamentalist Yes)
     =>
	(assert (UI-state (display Dd0e)
                      (state final)
                     )))	

(defrule hackmaster-b
    (races-as-classes I_am_a_schizo_and_want_skills_with_that)
     =>
	(assert (UI-state (display Hackmasterb)
                      (state final)
                     )))	
(defrule tunnels-trolls
    (races-as-classes Only_2_classes_are_needed)
     =>
	(assert (UI-state (display Tunnelstrolls)
                      (state final)
                     )))	
(defrule becmi
    (races-as-classes Yes)
     =>
	(assert (UI-state (display Becmi)
                      (state final)
                     )))
(defrule dd1e
    (races-as-classes Why_the_heck_can_not_my_dwarf_be_a_cleric)
     =>
	(assert (UI-state (display Dd1e)
                      (state final)
                     )))

(defrule true20
    (gygax-opinion He_is_cool)
     =>
	(assert (UI-state (display True20)
                      (state final)
                     )))

(defrule d20-past
    (what-based D20)
     =>
	(assert (UI-state (display D20past)
                      (state final)
                     )))

(defrule gangbusters
    (oah-sub Mobsters_1930s)
     =>
	(assert (UI-state (display Gangbusters)
                      (state final)
                     )))
(defrule hollow-earth-expedition
    (oah-sub Pulp)
     =>
	(assert (UI-state (display Hollowearthexpedition)
                      (state final)
                     )))
(defrule bushido
    (oah-sub Japanese/Samurai)
     =>
	(assert (UI-state (display Bushido)
                      (state final)
                     )))
(defrule dresden-files
    (supernatural-or-pulp Supernatural)
     =>
	(assert (UI-state (display Dresdenfiles)
                      (state final)
                     )))
(defrule spirit-of-the-century
    (supernatural-or-pulp Pulp)
     =>
	(assert (UI-state (display Spiritofthecentury)
                      (state final)
                     )))
(defrule fudge
    (niche-genre No)
     =>
	(assert (UI-state (display Fudge)
                      (state final)
                     )))
(defrule open-d6
    (cinematic Cinematic)
     =>
	(assert (UI-state (display Opend6)
                      (state final)
                     )))
(defrule risus
    (cinematic Humor)
     =>
	(assert (UI-state (display Risus)
                      (state final)
                     )))
(defrule savage-worlds
    (open-game Yes)
     =>
	(assert (UI-state (display Savageworlds)
                      (state final)
                     )))
(defrule rifts
    (really-open A_facist_could_make_it_for_all_I_care)
     =>
	(assert (UI-state (display Rifts)
                      (state final)
                     )))
(defrule torg
    (really-open Sorta)
     =>
	(assert (UI-state (display Torg)
                      (state final)
                     )))
(defrule gurps
    (what-is-math It_should_be_+x_not_+xy)
     =>
	(assert (UI-state (display Gurps)
                      (state final)
                     )))
(defrule hero
    (what-is-math A_differential_equation)
     =>
	(assert (UI-state (display Hero)
                      (state final)
                     )))
(defrule gurps-supers
    (point-buy Yes,_with_fractions)
     =>
	(assert (UI-state (display Gurpssupers)
                      (state final)
                     )))
(defrule champions
    (point-buy Yes)
     =>
	(assert (UI-state (display Champions)
                      (state final)
                     )))
(defrule icons
    (point-buy Not_really)
     =>
	(assert (UI-state (display Icons)
                      (state final)
                     )))
(defrule mutants-and-man
    (d20-like Yes)
     =>
	(assert (UI-state (display Mutantsandman)
                      (state final)
                     )))
(defrule dc-adventures
    (which-d D20)
     =>
	(assert (UI-state (display Dcadventures)
                      (state final)
                     )))
(defrule dc-heroes
    (which-d D10)
     =>
	(assert (UI-state (display Dcheroes)
                      (state final)
                     )))
(defrule dc-universe
    (which-d D6)
     =>
	(assert (UI-state (display Dcuniverse)
                      (state final)
                     )))
(defrule marvel-universe
    (which-system Diceless)
     =>
	(assert (UI-state (display Marveluniverse)
                      (state final)
                     )))
(defrule marvel-super
    (which-system Online_Fansites)
     =>
	(assert (UI-state (display Marvelsuper)
                      (state final)
                     )))
(defrule boot-hill
    (combat Yes)
     =>
	(assert (UI-state (display Boothill)
                      (state final)
                     )))
(defrule deadlands
    (steampunk Yes)
     =>
	(assert (UI-state (display Deadlands)
                      (state final)
                     )))
(defrule aces-eights
    (steampunk No)
     =>
	(assert (UI-state (display Aceseights)
                      (state final)
                     )))
(defrule gurps-mech
    (how-tailored Just_an_add-on)
     =>
	(assert (UI-state (display Gurpsmech)
                      (state final)
                     )))
(defrule robotech
    (universal-system Yes)
     =>
	(assert (UI-state (display Robotech)
                      (state final)
                     )))
(defrule besm
    (how-tailored Mangled)
     =>
	(assert (UI-state (display Besm)
                      (state final)
                     )))
(defrule mechwarrior
    (universal-system No)
     =>
	(assert (UI-state (display Mechwarrior)
                      (state final)
                     )))
(defrule world-of-darkness
    (undead I_can_be_a_vampire)
     =>
	(assert (UI-state (display Worldofdarkness)
                      (state final)
                     )))
(defrule call-of-cthulu
    (undead If_done_well)
     =>
	(assert (UI-state (display Callofcthulu)
                      (state final)
                     )))
(defrule paranoia
    (humor-spies-cyber Humor)
     =>
	(assert (UI-state (display Paranoia)
                      (state final)
                     )))
(defrule top-secret
    (what-spies Old)
     =>
	(assert (UI-state (display Topsecret)
                      (state final)
                     )))
(defrule d20-modern
    (full-or-lite Full_D20)
     =>
	(assert (UI-state (display D20modern)
                      (state final)
                     )))
(defrule cyberpunk-2020
    (genres-mixed Straight_up)
     =>
	(assert (UI-state (display Cyberpunk2020)
                      (state final)
                     )))
(defrule rifts2
    (genres-mixed A_little_of_everything)
     =>
	(assert (UI-state (display Rifts)
                      (state final)
                     )))
(defrule shadowrun
    (genres-mixed Some_magic)
     =>
	(assert (UI-state (display Shadowrun)
                      (state final)
                     )))
(defrule spycraft
    (full-or-lite Lite)
     =>
	(assert (UI-state (display Spycraft)
                      (state final)
                     )))

(defrule star-wars-saga
    (star-wars No)
     =>
	(assert (UI-state (display Starwarssaga)
                      (state final)
                     )))

(defrule star-wars-d6
    (star-wars Yes)
     =>
	(assert (UI-state (display Starwarsd6)
                      (state final)
                     )))

(defrule alternity
    (what-e 2E)
     =>
	(assert (UI-state (display Alternity)
                      (state final)
                     )))

(defrule eclipse-phase
    (open-game-future Yes)
     =>
	(assert (UI-state (display Eclipsephase)
                      (state final)
                     )))

(defrule gamma-world
    (what-e 4E)
     =>
	(assert (UI-state (display Gammaworld)
                      (state final)
                     )))

(defrule d20-future
    (what-e 3E)
     =>
	(assert (UI-state (display D20future)
                      (state final)
                     )))

(defrule metamorphosis-alpha
    (fiction-or-fantasy Science_Fantasy)
     =>
	(assert (UI-state (display Metamorphosisalpha)
                      (state final)
                     )))

(defrule warhammer-40k-rpg
    (gothic Gothic)
     =>
	(assert (UI-state (display Warhammer40krpg)
                      (state final)
                     )))

(defrule gurps-fallout
    (gothic Post_Apoc)
     =>
	(assert (UI-state (display Gurpsfallout)
                      (state final)
                     )))

(defrule traveller
    (open-game-future Yes_and_no)
     =>
	(assert (UI-state (display Traveller)
                      (state final)
                     )))

(defrule fading-suns
    (gothic Space_Opera)
     =>
	(assert (UI-state (display Fadingsuns)
                      (state final)
                     )))

(defrule star-frontiers
    (fiction-or-fantasy Science_Fiction)
     =>
	(assert (UI-state (display Starfrontiers)
                      (state final)
                     )))

(defrule just-do-a-web
    (movie-or-tv Other)
     =>
	(assert (UI-state (display Justdoaweb)
                      (state final)
                     )))

;;;*************************
;;;* GUI INTERACTION RULES *
;;;*************************

(defrule ask-question

	(declare (salience 5))
   
   (UI-state (id ?id))
   
   ?f <- (state-list (sequence $?s&:(not (member$ ?id ?s))))
             
   =>
   
   (modify ?f (current ?id)
              (sequence ?id ?s))
   
   (halt))

(defrule handle-next-no-change-none-middle-of-chain

   (declare (salience 10))
   
   ?f1 <- (next ?id)

   ?f2 <- (state-list (current ?id) (sequence $? ?nid ?id $?))
                      
   =>
      
   (retract ?f1)
   
   (modify ?f2 (current ?nid))
   
   (halt))

(defrule handle-next-response-none-end-of-chain

   (declare (salience 10))
   
   ?f <- (next ?id)

   (state-list (sequence ?id $?))
   
   (UI-state (id ?id)
             (relation-asserted ?relation))
                   
   =>
      
   (retract ?f)

   (assert (add-response ?id)))   

(defrule handle-next-no-change-middle-of-chain

   (declare (salience 10))
   
   ?f1 <- (next ?id ?response)

   ?f2 <- (state-list (current ?id) (sequence $? ?nid ?id $?))
     
   (UI-state (id ?id) (response ?response))
   
   =>
      
   (retract ?f1)
   
   (modify ?f2 (current ?nid))
   
   (halt))

(defrule handle-next-change-middle-of-chain

   (declare (salience 10))
   
   (next ?id ?response)

   ?f1 <- (state-list (current ?id) (sequence ?nid $?b ?id $?e))
     
   (UI-state (id ?id) (response ~?response))
   
   ?f2 <- (UI-state (id ?nid))
   
   =>
         
   (modify ?f1 (sequence ?b ?id ?e))
   
   (retract ?f2))
   
(defrule handle-next-response-end-of-chain

   (declare (salience 10))
   
   ?f1 <- (next ?id ?response)
   
   (state-list (sequence ?id $?))
   
   ?f2 <- (UI-state (id ?id)
                    (response ?expected)
                    (relation-asserted ?relation))
                
   =>
      
   (retract ?f1)

   (if (neq ?response ?expected)
      then
      (modify ?f2 (response ?response)))
      
   (assert (add-response ?id ?response)))   

(defrule handle-add-response

   (declare (salience 10))
   
   (logical (UI-state (id ?id)
                      (relation-asserted ?relation)))
   
   ?f1 <- (add-response ?id ?response)
                
   =>
      
   (str-assert (str-cat "(" ?relation " " ?response ")"))
   
   (retract ?f1))   

(defrule handle-add-response-none

   (declare (salience 10))
   
   (logical (UI-state (id ?id)
                      (relation-asserted ?relation)))
   
   ?f1 <- (add-response ?id)
                
   =>
      
   (str-assert (str-cat "(" ?relation ")"))
   
   (retract ?f1))   

(defrule handle-prev

   (declare (salience 10))
      
   ?f1 <- (prev ?id)
   
   ?f2 <- (state-list (sequence $?b ?id ?p $?e))
                
   =>
   
   (retract ?f1)
   
   (modify ?f2 (current ?p))
   
   (halt))
   
