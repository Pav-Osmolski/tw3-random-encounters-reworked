
enum EHumanType
{
  HT_BANDIT       = 0,
  HT_NOVBANDIT    = 1,
  HT_SKELBANDIT   = 2,
  HT_SKELBANDIT2  = 3,
  HT_CANNIBAL     = 4,
  HT_RENEGADE     = 5,
  HT_PIRATE       = 6,
  HT_SKELPIRATE   = 7,
  HT_NILFGAARDIAN = 8,
  HT_WITCHHUNTER  = 9,

  HT_MAX          = 10,
  HT_NONE         = 11
}

enum CreatureType {
  CreatureHUMAN        = 0,
  CreatureENDREGA      = 1,
  CreatureGHOUL        = 2,
  CreatureALGHOUL      = 3,
  CreatureNEKKER       = 4,
  CreatureDROWNER      = 5,
  CreatureROTFIEND     = 6,
  CreatureWOLF         = 7,
  CreatureWRAITH       = 8,
  CreatureHARPY        = 9,
  CreatureSPIDER       = 10,
  CreatureCENTIPEDE    = 11,
  CreatureDROWNERDLC   = 12,  
  CreatureBOAR         = 13,  
  CreatureBEAR         = 14,
  CreaturePANTHER      = 15,  
  CreatureSKELETON     = 16,
  CreatureECHINOPS     = 17,
  CreatureKIKIMORE     = 18,
  CreatureBARGHEST     = 19,
  CreatureSKELWOLF     = 20,
  CreatureSKELBEAR     = 21,
  CreatureWILDHUNT     = 22,
  CreatureBERSERKER    = 23,
  CreatureSIREN        = 24,
  CreatureHAG          = 25,

  // large creatures below
  // the dracolizard is used in a few places as the first large creature of the
  // enum. If you change it, you'll have to update it in the other places.
  CreatureARACHAS      = 26,
  CreatureDRACOLIZARD  = 27,
  CreatureGARGOYLE     = 28,
  CreatureLESHEN       = 29,
  CreatureWEREWOLF     = 30,
  CreatureFIEND        = 31,
  CreatureEKIMMARA     = 32,
  CreatureKATAKAN      = 33,
  CreatureGOLEM        = 34,
  CreatureELEMENTAL    = 35,
  CreatureNIGHTWRAITH  = 36,
  CreatureNOONWRAITH   = 37,
  CreatureCHORT        = 38,
  CreatureCYCLOP       = 39,
  CreatureTROLL        = 40,
  CreatureFOGLET       = 41,
  CreatureBRUXA        = 42,
  CreatureFLEDER       = 43,
  CreatureGARKAIN      = 44,
  CreatureDETLAFF      = 45,
  CreatureGIANT        = 46,  
  CreatureSHARLEY      = 47,
  CreatureWIGHT        = 48,
  CreatureGRYPHON      = 49,
  CreatureCOCKATRICE   = 50,
  CreatureBASILISK     = 51,
  CreatureWYVERN       = 52,
  CreatureFORKTAIL     = 53,
  CreatureSKELTROLL    = 54,

  // It is important to keep the numbers continuous.
  // The `SpawnRoller` classes uses these numbers to
  // to fill its arrays.
  // (so that i dont have to write 40 lines by hand)
  CreatureMAX          = 55,
  CreatureNONE         = 56,
}


enum EncounterType {
  // default means an ambush.
  EncounterType_DEFAULT  = 0,
  
  EncounterType_HUNT     = 1,
  EncounterType_CONTRACT = 2,
  EncounterType_HUNTINGGROUND = 3,
  EncounterType_MAX      = 4
}


enum OutOfCombatRequest {
  OutOfCombatRequest_TROPHY_CUTSCENE = 0,
  OutOfCombatRequest_TROPHY_NONE     = 1
}

enum TrophyVariant {
  TrophyVariant_PRICE_LOW = 0,
  TrophyVariant_PRICE_MEDIUM = 1,
  TrophyVariant_PRICE_HIGH = 2
}

enum RER_Difficulty {
  RER_Difficulty_EASY = 0,
  RER_Difficulty_MEDIUM = 1,
  RER_Difficulty_HARD = 2,
  RER_Difficulty_RANDOM = 3
}

enum StaticEncountersVariant {
  StaticEncountersVariant_LUCOLIVIER = 0,
  StaticEncountersVariant_AELTOTH = 1,
}