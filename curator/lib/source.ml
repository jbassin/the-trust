open! Core
open! Async
open! Import

type t =
  { full_name : string
  ; short_name : string
  ; abbreviation : string
  ; color : string option
  }
[@@deriving fields, yojson_of]

let create ~full_name ~abbreviation ?(short_name = full_name) ?(color = None) () =
  Fields.create ~full_name ~short_name ~abbreviation ~color
;;

let standard_sources =
  [ "Missing Source", "ERR"
  ; "Organized Play Foundation", "OPF"
  ; "Core Rulebook", "CR"
  ; "Advanced Player's Guide", "APG"
  ; "Gamemastery Guide", "GG"
  ; "Guns & Gears", "G&G"
  ; "Secrets of Magic", "SM"
  ; "Beginner's Box", "BB"
  ; "Bestiary #1", "B:1"
  ; "Bestiary #2", "B:2"
  ; "Bestiary #3", "B:3"
  ; "Abomination Vaults Player's Guide", "AVPG"
  ; "Age of Ashes Player's Guide", "AAPG"
  ; "Agents of Edgewatch Player's Guide", "AEPG"
  ; "Extinction Curse Player's Guide", "ECPG"
  ; "Fists of the Ruby Phoenix Player's Guide", "FRPPG"
  ; "Outlaws of Alkenstar Player's Guide", "OAPG"
  ; "Strength of Thousands Player's Guide", "STPG"
  ; "Quest for the Frozen Flame Player's Guide", "QFFPG"
  ; "Pathfinder Blog", "BLOG"
  ; "Pathfinder Special: Fumbus!", "S:F"
  ]
  |> List.map ~f:(fun (full_name, abbreviation) -> create ~full_name ~abbreviation ())
;;

let adventure_path_sources =
  [ "#145: Hellknight Hill"
  ; "#146: Cult of Cinders"
  ; "#147: Tomorrow Must Burn"
  ; "#148: Fires of the Haunted City"
  ; "#149: Against the Scarlet Triad"
  ; "#150: Broken Promises"
  ; "#151: The Show Must Go On"
  ; "#152: Legacy of the Lost God"
  ; "#153: Life's Long Shadows"
  ; "#154: Siege of the Dinosaurs"
  ; "#155: Lord of the Black Sands"
  ; "#156: The Apocalypse Prophet"
  ; "#157: Devil at the Dreaming Palace"
  ; "#158: Sixty Feet Under"
  ; "#159: All or Nothing"
  ; "#160: Assault on Hunting Lodge Seven"
  ; "#161: Belly of the Black Whale"
  ; "#162: Ruins of the Radiant Siege"
  ; "#163: Ruins of Gauntlight"
  ; "#164: Hands of the Devil"
  ; "#165: Eyes of Empty Death"
  ; "#166: Despair on Danger Island"
  ; "#167: Ready? Fight!"
  ; "#168: King of the Mountain"
  ; "#169: Kindled Magic"
  ; "#170: Spoken on the Song Wind"
  ; "#171: Hurricane's Howl"
  ; "#172: Secrets of the Temple-City"
  ; "#173: Doorway to the Red Star"
  ; "#174: Shadows of the Ancients"
  ; "#175: Broken Tusk Moon"
  ; "#176: Lost Mammoth Valley"
  ; "#177: Burning Tundra"
  ]
  |> List.map ~f:(fun full_name ->
         let abbreviation = "AP:" ^ String.drop_prefix (String.prefix full_name 4) 1 in
         let short_name = String.drop_prefix full_name 6 in
         create ~full_name ~short_name ~abbreviation ())
;;

let adventure_sources =
  [ "Little Trouble in Big Absalom", "LTBA"
  ; "Malevolence", "M"
  ; "Night of the Gray Death", "NGD"
  ; "The Fall of Plaguestone", "FP"
  ; "The Slithering", "S"
  ; "Threshold of Knowledge", "TK"
  ; "Troubles in Otari", "TO"
  ]
  |> List.map ~f:(fun (short_name, abbreviation) ->
         create
           ~full_name:[%string "Adventure: %{short_name}"]
           ~short_name
           ~abbreviation:[%string "A:%{abbreviation}"]
           ())
;;

let bounty_sources =
  [ 1, "The Whitefang Wyrm"
  ; 2, "Blood of the Beautiful"
  ; 6, "The Road from Otari"
  ; 7, "Cleanup Duty"
  ; 12, "Somewhere Below"
  ; 14, "The Blackwood Truce"
  ; 18, "From Family Lost"
  ]
  |> List.map ~f:(fun (number, name) ->
         create
           ~full_name:[%string "Bounty #%{number#Int}: %{name}"]
           ~short_name:name
           ~abbreviation:[%string "BTY:%{number#Int}"]
           ())
;;

let lost_omens_sources =
  [ "Absalom, City of Lost Omens", "A"
  ; "Ancestry Guide", "AG"
  ; "Character Guide", "CG"
  ; "Gods & Magic", "G&M"
  ; "Legends", "L"
  ; "Monsters of Myth", "MM"
  ; "Pathfinder Society Guide", "PSG"
  ; "The Grand Bazaar", "GB"
  ; "The Mwangi Expanse", "ME"
  ; "World Guide", "WG"
  ]
  |> List.map ~f:(fun (short_name, abbreviation) ->
         create
           ~full_name:[%string "Lost Omens: %{short_name}"]
           ~short_name
           ~abbreviation:[%string "LO:%{abbreviation}"]
           ())
;;

let society_quest_sources =
  [ 2, "Unforgiving Fire"
  ; 3, "Grehunde's Gorget"
  ; 4, "Port Peril Pub Crawl"
  ; 5, "The Dragon Who Stole Evoking Day"
  ; 6, "Wayfinder Origins"
  ; 10, "The Broken Scales"
  ]
  |> List.map ~f:(fun (number, name) ->
         create
           ~full_name:[%string "Society Quest #%{number#Int}: %{name}"]
           ~short_name:name
           ~abbreviation:[%string "SQ:%{number#Int}"]
           ())
;;

let society_scenario_sources =
  [ 100, "Origin of the Open Road"
  ; 103, "Escaping the Grave"
  ; 104, "Bandits of Immenwood"
  ; 106, "Lost on the Spirit Road"
  ; 108, "Revolution on the Riverside"
  ; 115, "The Blooming Catastrophe"
  ; 117, "The Thorned Monarch"
  ; 119, "Iolite Squad Alpha"
  ; 120, "The Lost Legend"
  ; 124, "Lightning Strikes, Stars Fall"
  ; 125, "Grim Symphony"
  ; 201, "Citadel of Corruption"
  ; 203, "Catastrophe's Spark"
  ; 209, "The Seven Secrets of Dacilane Academy"
  ; 216, "Freedom for Wishes"
  ; 219, "Enter the Pallid Peak"
  ; 221, "In Pursuit of Water"
  ; 224, "Breaking the Storm: Parting Clouds"
  ; 302, "The East Hill Haunting"
  ; 305, "Inheritor's Rite"
  ; 309, "The Secluded Siege"
  ; 310, "Delve the Pallid Depths"
  ; 311, "No Time for Treason"
  ]
  |> List.map ~f:(fun (number, name) ->
         create
           ~full_name:[%string "Society Scenario #%{number#Int}: %{name}"]
           ~short_name:name
           ~abbreviation:[%string "SS:%{number#Int}"]
           ())
;;

let one_shot_sources =
  [ 2, "Dinner at Lionlodge" ]
  |> List.map ~f:(fun (number, name) ->
         create
           ~full_name:[%string "One-Shot #%{number#Int}: %{name}"]
           ~short_name:name
           ~abbreviation:[%string "OS:%{number#Int}"]
           ())
;;

let all =
  List.concat
    [ standard_sources
    ; adventure_path_sources
    ; adventure_sources
    ; bounty_sources
    ; lost_omens_sources
    ; society_quest_sources
    ; society_scenario_sources
    ; one_shot_sources
    ]
;;

let all_by_abbr = List.map all ~f:(fun t -> t.abbreviation, t) |> String.Map.of_alist_exn
let missing = String.Map.find_exn all_by_abbr "ERR"
let is_missing { abbreviation; _ } = String.equal abbreviation "ERR"
let find ~abbr = String.Map.find all_by_abbr abbr

let normalize = function
  | "Organized Play Foundation" -> find ~abbr:"OPF"
  | "Pathfinder #145: Hellknight Hill" -> find ~abbr:"AP:145"
  | "Pathfinder #146: Cult of Cinders" -> find ~abbr:"AP:146"
  | "Pathfinder #147: Tomorrow Must Burn" -> find ~abbr:"AB:147"
  | "Pathfinder #148: Fires of the Haunted City" -> find ~abbr:"AP:148"
  | "Pathfinder #149: Against the Scarlet Triad" -> find ~abbr:"AP:149"
  | "Pathfinder #150: Broken Promises" -> find ~abbr:"AP:150"
  | "Pathfinder #151: The Show Must Go On" -> find ~abbr:"AP:151"
  | "Pathfinder #152: Legacy of the Lost God" -> find ~abbr:"AP:152"
  | "Pathfinder #153: Life's Long Shadow" | "Pathfinder #153: Life's Long Shadows" ->
    find ~abbr:"AP:153"
  | "Pathfinder #154: Siege of the Dinosaurs" -> find ~abbr:"AP:154"
  | "Pathfinder #155: Lord of the Black Sands" -> find ~abbr:"AP:155"
  | "Pathfinder #156: The Apocalypse Prophet" -> find ~abbr:"AP:156"
  | "Pathfinder #157: Devil at the Dreaming Palace" -> find ~abbr:"AP:157"
  | "Pathfinder #158: Sixty Feet Under" -> find ~abbr:"AP:158"
  | "Pathfinder #159: All or Nothing" -> find ~abbr:"AP:159"
  | "Pathfinder #160: Assault on Hunting Lodge Seven" -> find ~abbr:"AP:160"
  | "Pathfinder #161: Belly of the Black Whale" -> find ~abbr:"AP:161"
  | "Pathfinder #162: Ruins of the Radiant Siege" -> find ~abbr:"AP:162"
  | "Pathfinder #163: Ruins of Gauntlight" -> find ~abbr:"AP:163"
  | "Pathfinder #164: Hands of the Devil" -> find ~abbr:"AP:164"
  | "Pathfinder #165: Eyes of Empty Death" -> find ~abbr:"AP:165"
  | "Pathfinder #166: Despair on Danger Island" -> find ~abbr:"AP:166"
  | "Pathfinder #167: Ready? Fight!" -> find ~abbr:"AP:167"
  | "Pathfinder #168: King of the Mountain" -> find ~abbr:"AP:168"
  | "Pathfinder #169: Kindled Magic" -> find ~abbr:"AP:169"
  | "Pathfinder #170: Spoken on the Song Wind" -> find ~abbr:"AP:170"
  | "Pathfinder #171: Hurricane's Howl" -> find ~abbr:"AP:171"
  | "Pathfinder #172: Secrets of the Temple-City" -> find ~abbr:"AP:172"
  | "Pathfinder #173: Doorway to the Red Star" -> find ~abbr:"AP:173"
  | "Pathfinder #174: Shadows of the Ancients" -> find ~abbr:"AP:174"
  | "Pathfinder #175: Broken Tusk Moon" -> find ~abbr:"AP:175"
  | "Pathfinder #176: Lost Mammoth Valley" -> find ~abbr:"AP:176"
  | "Pathfinder #177: Burning Tundra" -> find ~abbr:"AP:177"
  | "Pathfinder Advanced Player's Guide" -> find ~abbr:"APG"
  | "Pathfinder Adventure: Little Trouble in Big Absalom" -> find ~abbr:"A:LTBA"
  | "Pathfinder Adventure: Malevolence" -> find ~abbr:"A:M"
  | "Pathfinder Adventure: Night of the Gray Death" -> find ~abbr:"A:NGD"
  | "Pathfinder Adventure: The Fall of Plaguestone" -> find ~abbr:"A:FP"
  | "Pathfinder Adventure: The Slithering" -> find ~abbr:"A:S"
  | "Pathfinder Adventure: Threshold of Knowledge" -> find ~abbr:"A:TK"
  | "Pathfinder Adventure: Troubles in Otari" -> find ~abbr:"A:TO"
  | "Pathfinder Beginner Box: Hero's Handbook" | "Pathfinder Beginners Box" ->
    find ~abbr:"BB"
  | "Pathfinder Bestiary 2" -> find ~abbr:"B:2"
  | "Pathfinder Bestiary 3" -> find ~abbr:"B:3"
  | "Pathfinder Bestiary" -> find ~abbr:"B:1"
  | "Pathfinder Blog"
  | "Pathfinder Blog: April Fools"
  | "Pathfinder Blog: The Waters of Stone Ring Pond" -> find ~abbr:"BLOG"
  | "Pathfinder Bounty #12: Somewhere Below" -> find ~abbr:"BTY:12"
  | "Pathfinder Bounty #14: The Blackwood Truce" -> find ~abbr:"BTY:14"
  | "Pathfinder Bounty #18: From Family Lost" -> find ~abbr:"BTY:18"
  | "Pathfinder Bounty #1: The Whitefang Wyrm" -> find ~abbr:"BTY:1"
  | "Pathfinder Bounty #2: Blood of the Beautiful" -> find ~abbr:"BTY:2"
  | "Pathfinder Bounty #6: The Road from Otari" -> find ~abbr:"BTY:6"
  | "Pathfinder Bounty #7: Cleanup Duty" -> find ~abbr:"BTY:7"
  | "Pathfinder Core Rulebook" | "Pafinder Core Rulebook" -> find ~abbr:"CR"
  | "Pathfinder Gamemastery Guide" -> find ~abbr:"GG"
  | "Pathfinder Guns & Gears" -> find ~abbr:"G&G"
  | "Pathfinder Lost Omens Ancestry Guide" | "Pathfinder Lost Omens: Ancestry Guide" ->
    find ~abbr:"LO:AG"
  | "Pathfinder Lost Omens Legends" | "Pathfinder Lost Omens: Legends" ->
    find ~abbr:"LO:L"
  | "Pathfinder Lost Omens World Guide" | "Pathfinder Lost Omens: World Guide" ->
    find ~abbr:"LO:WG"
  | "Pathfinder Lost Omens: Absalom, City of Lost Omens" -> find ~abbr:"LO:A"
  | "Pathfinder Lost Omens: Character Guide" | "Pathfinder Lot Omens Character Guide" ->
    find ~abbr:"LO:CG"
  | "Pathfinder Lost Omens: Gods & Magic"
  | "Pathfindier Core Rulebook, Pathfinder Lost Omens: Gods & Magic" ->
    find ~abbr:"LO:G&M"
  | "Pathfinder Lost Omens: Monsters of Myth" -> find ~abbr:"LO:MM"
  | "Pathfinder Lost Omens: Pathfinder Society Guide" -> find ~abbr:"LO:PSG"
  | "Pathfinder Lost Omens: The Grand Bazaar" -> find ~abbr:"LO:GB"
  | "Pathfinder Lost Omens: The Mwangi Expanse" -> find ~abbr:"LO:ME"
  | "Pathfinder One-Shot #2: Dinner at Lionlodge" -> find ~abbr:"OS:2"
  | "Pathfinder Secrets of Magic" -> find ~abbr:"SM"
  | "Pathfinder Society Quest #10: The Broken Scales" -> find ~abbr:"SQ:10"
  | "Pathfinder Society Quest #2: Unforgiving Fire" -> find ~abbr:"SQ:2"
  | "Pathfinder Society Quest #3: Grehunde's Gorget" -> find ~abbr:"SQ:3"
  | "Pathfinder Society Quest #4: Port Peril Pub Crawl" -> find ~abbr:"SQ:5"
  | "Pathfinder Society Quest #5: The Dragon Who Stole Evoking Day"
  | "Pathfinder Society Quest 5: The Dragon who Stole Evoking Day" -> find ~abbr:"SQ:5"
  | "Pathfinder Society Quest #9: Wayfinder Origins" -> find ~abbr:"SQ:9"
  | "Pathfinder Society Scenario #1-03: Escaping the Grave" -> find ~abbr:"SS:103"
  | "Pathfinder Society Scenario #1-08: Revolution on the Riverside" ->
    find ~abbr:"SS:108"
  | "Pathfinder Society Scenario #1-15: The Blooming Catastrophe" -> find ~abbr:"SS:115"
  | "Pathfinder Society Scenario #1-17: The Perennial Crown Part 2, The Thorned Monarch"
    -> find ~abbr:"SS:117"
  | "Pathfinder Society Scenario #1-19: Iolite Squad Alpha" -> find ~abbr:"SS:119"
  | "Pathfinder Society Scenario #1-24: Lightning Strikes, Stars Fall" ->
    find ~abbr:"SS:124"
  | "Pathfinder Society Scenario #2-09: The Seven Secrets of Dacilane Academy" ->
    find ~abbr:"SS:209"
  | "Pathfinder Society Scenario #3-02: The East Hill Haunting" -> find ~abbr:"SS:302"
  | "Pathfinder Society Scenario #3-05: Inheritor's Rite" -> find ~abbr:"SS:305"
  | "Pathfinder Society Scenario #3-09: The Secluded Siege" -> find ~abbr:"SS:309"
  | "Pathfinder Society Scenario #3-10: Delve the Pallid Depths" -> find ~abbr:"SS:310"
  | "Pathfinder Society Scenario #3-11: No Time for Treason" -> find ~abbr:"SS:311"
  | "Pathfinder Society Scenario 1-00: Origin of the Open Road" -> find ~abbr:"SS:100"
  | "Pathfinder Society Scenario 1-04: Bandits of Immenwood" -> find ~abbr:"SS:104"
  | "Pathfinder Society Scenario 1-06: Lost on the Spirit Road" -> find ~abbr:"SS:106"
  | "Pathfinder Society Scenario 1-20: The Lost Legend" -> find ~abbr:"SS:120"
  | "Pathfinder Society Scenario 1-25: Grim Symphony" -> find ~abbr:"SS:125"
  | "Pathfinder Society Scenario 2-01: Citadel of Corruption" -> find ~abbr:"SS:201"
  | "Pathfinder Society Scenario 2-03: Catastrophe's Spark" -> find ~abbr:"SS:203"
  | "Pathfinder Society Scenario 2-16: Freedom for Wishes" -> find ~abbr:"SS:216"
  | "Pathfinder Society Scenario 2-19: Enter the Pallid Peak" -> find ~abbr:"SS:219"
  | "Pathfinder Society Scenario 2-21: In Pursuit of Water" -> find ~abbr:"SS:221"
  | "Pathfinder Society Scenario 2-24: Breaking The Storm: Parting Clouds" ->
    find ~abbr:"SS:224"
  | "Pathfinder Special: Fumbus!" -> find ~abbr:"S:F"
  | "Pathfinder: Abomination Vaults Player's Guide" -> find ~abbr:"AVPG"
  | "Pathfinder: Age of Ashes Player's Guide" -> find ~abbr:"AAPG"
  | "Pathfinder: Agents of Edgewatch Player's Guide" -> find ~abbr:"AEPG"
  | "Pathfinder: Extinction Curse Player's Guide" -> find ~abbr:"ECPG"
  | "Pathfinder: Fists of the Ruby Phoenix Player's Guide" -> find ~abbr:"FRPPG"
  | "Pathfinder: Outlaws of Alkenstar Player's Guide" -> find ~abbr:"OAPG"
  | "Pathfinder: Quest for the Frozen Flame Player's Guide" -> find ~abbr:"QFFPG"
  | "Strength of Thousands Player's Guide" -> find ~abbr:"STPG"
  | _ -> None
;;
