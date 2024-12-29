//////////////////////////////////////////////////
// autogenerated
#include <stdint.h>
#pragma once

typedef struct
{
    uint8_t flags;
    uint8_t type;
    uint8_t score;
    int8_t health;
    uint8_t speed;
    uint8_t ai;
    bool hidden;
    const char * basename;
} tiledef_t;

// ai
#define AI_STICKY                        0x01
#define AI_ROUND                         0x02
#define AI_CLASSIC                       0x02
#define AI_NEO                           0x03
#define AI_FOCUS                         0x04

// speed
#define SPEED_FAST                       0x03
#define SPEED_NORMAL                     0x04
#define SPEED_SLOW                       0x05
#define SPEED_VERYSLOW                   0x06

// type
#define TYPE_BACKGROUND                  0x00
#define TYPE_STOP                        0x01
#define TYPE_PLAYER                      0x02
#define TYPE_WALLS                       0x03
#define TYPE_PICKUP                      0x04
#define TYPE_DOOR                        0x05
#define TYPE_KEY                         0x06
#define TYPE_SWAMP                       0x07
#define TYPE_MONSTER                     0x08
#define TYPE_DRONE                       0x09
#define TYPE_VAMPLANT                    0x0a
#define TYPE_DIAMOND                     0x0b
#define TYPE_LADDER                      0x0c
#define TYPE_PLATFORM                    0x0d
#define TYPE_SPECIAL                     0x0e
#define TYPE_SWITCH                      0x0f
#define TYPE_TRANS_SOURCE                0x10
#define TYPE_TRANS_DEST                  0x11
#define TYPE_TRAP                        0x12
#define TYPE_BRIDGE                      0x13
#define TYPE_ROOT                        0x14
#define TYPE_UNUSED                      0xff

// animz
#define ANIMZ_WATER_UP1                  0x00 // &wateru1
#define ANIMZ_WATER_UP2                  0x01 // &wateru2
#define ANIMZ_WATER_DOWN                 0x02 // water2
#define ANIMZ_LAVA_UP1                   0x03 // &lavaup1
#define ANIMZ_LAVA_UP2                   0x04 // &lavaup2
#define ANIMZ_LAVA_DOWN                  0x05 // lavadn
#define ANIMZ_SLIME                      0x06 // slime
#define ANIMZ_SLIME2                     0x07 // slime2
#define ANIMZ_SLIME_DOWN                 0x08 // slimedn
#define ANIMZ_TRANS                      0x09 // !trans
#define ANIMZ_TRANS2                     0x0a // !trans2
#define ANIMZ_VAMPLANT                   0x0b // $1deadpl
#define ANIMZ_VAMPLANT2                  0x0c // $2deadpl
#define ANIMZ_PLATFORM                   0x0d // magicpla
#define ANIMZ_RFISH                      0x0e // rfish
#define ANIMZ_LFISH                      0x0f // lfish
#define ANIMZ_DUMMY                      0x10 // $1dummy
#define ANIMZ_DUMMY2                     0x11 // $1dummy
#define ANIMZ_GOBBLIN                    0x12 // $1gobbli
#define ANIMZ_GOBBLIN2                   0x13 // $2gobbli
#define ANIMZ_TEDDY                      0x14 // $1teddy
#define ANIMZ_TEDDY2                     0x15 // $2teddy
#define ANIMZ_OCTOPUS                    0x16 // $1octop
#define ANIMZ_OCTOPUS2                   0x17 // $2octop
#define ANIMZ_UNUSED1                    0x18 // chglnk0
#define ANIMZ_UNUSED2                    0x19 // chglnk1

// tiles
#define TILES_BLANK                      0x00 // Blank
#define TILES_BRICK                      0x01 // Brick
#define TILES_PLAYER                     0x02 // Player
#define TILES_LIGHT_BULB                 0x03 // Light Bulb
#define TILES_ORB                        0x04 // Orb
#define TILES_CHEST                      0x05 // Chest
#define TILES_DIAMOND                    0x06 // Diamond
#define TILES_NECKLESS                   0x07 // Neckless
#define TILES_ROPE                       0x08 // Rope
#define TILES_TNT                        0x09 // Tnt
#define TILES_FLOWER                     0x0a // Flower
#define TILES_OXYGEN_BOTTLE              0x0b // Bottle of Oxygen
#define TILES_TRIFORCE                   0x0c // TriForce
#define TILES_SHIELD                     0x0d // Shield
#define TILES_LADDER                     0x0e // Ladder
#define TILES_ROPE_PULLEY                0x0f // Rope <- Pulley
#define TILES_PULLEY                     0x10 // Pulley
#define TILES_ROPE_PULLEY_11             0x11 // Rope    Pulley
#define TILES_PULLEY_12                  0x12 // Pulley
#define TILES_PULLEY_ROPE                0x13 // Pulley -> Rope
#define TILES_PULLEY_ROPE_14             0x14 // Pulley    Rope
#define TILES_SWITCH_UP                  0x15 // ELectric SWitch UP
#define TILES_SWITCH_DOWN                0x16 // ELectric SWitch DN
#define TILES_DEADLY_SOCKET_XXX          0x17 // Deadly Socket XXX
#define TILES_LIGHT_BULB_IN_SOCKET       0x18 // Light Bulb in Socket
#define TILES_UNPOWED_SOCKET             0x19 // Unpowed Socket
#define TILES_UNLIGHTED_BULB_IN_SCREW    0x1a // UNLighted Bulb in screw
#define TILES_MAGIC_BOX                  0x1b // Magic Box
#define TILES_RIGHT_PULLEY_WITH_ROPE     0x1c // Right Pulley with rope
#define TILES_LEFT_PULLEY_WITH_ROPE      0x1d // Left Pulley with rope
#define TILES_HEARTKEY                   0x1e // HeartKey
#define TILES_HEARTDOOR                  0x1f // HeartDoor
#define TILES_WATERKEY                   0x20 // WaterKey
#define TILES_WATERDOOR                  0x21 // WaterDoor
#define TILES_SKEY                       0x22 // SKey
#define TILES_SDOOR                      0x23 // SDoor
#define TILES_BKEY                       0x24 // BKey
#define TILES_BDOOR                      0x25 // BDoor
#define TILES_GREENWALL                  0x26 // GreenWall
#define TILES_PATTERN                    0x27 // Pattern
#define TILES_ROCKWALL93                 0x28 // Rockwall93
#define TILES_ROCKWALL                   0x29 // Rockwall
#define TILES_ROCKWALL_UP                0x2a // Rockwall UP
#define TILES_ROCKWALL_DN                0x2b // Rockwall DN
#define TILES_NEWPATTERN                 0x2c // NewPattern
#define TILES_BLUEPATTERN                0x2d // BluePattern
#define TILES_PINE_TREE                  0x2e // Pine Tree
#define TILES_STATUE                     0x2f // Statue
#define TILES_ROCK                       0x30 // Rock
#define TILES_ROCK_2                     0x31 // Rock #2
#define TILES_ROCK_3                     0x32 // Rock #3
#define TILES_ROCK_NEWPLANT              0x33 // Rock & NewPlant
#define TILES_NEW_PLANT                  0x34 // New Plant
#define TILES_BREAKABLE_ROOT             0x35 // Breakable ROOT
#define TILES_ROOT                       0x36 // ROOT
#define TILES_BRIDGE_ROOT                0x37 // BRIDGE & ROOT
#define TILES_BRIDGE_0                   0x38 // BRIDGE #0
#define TILES_BRIDGE_1                   0x39 // BRIDGE #1
#define TILES_BRIDGE_2                   0x3a // BRIDGE #2
#define TILES_BRIDGE_3                   0x3b // BRIDGE #3
#define TILES_BRIDGE_4                   0x3c // BRIDGE #4
#define TILES_BRIDGE_5                   0x3d // BRIDGE #5
#define TILES_BRIDGE_6                   0x3e // BRIDGE #6
#define TILES_BRIDGE_7                   0x3f // BRIDGE #7
#define TILES_BRIDGE_8                   0x40 // BRIDGE #8
#define TILES_BRIDGE_9                   0x41 // BRIDGE #9
#define TILES_BRIDGE_10                  0x42 // BRIDGE #10
#define TILES_BRIDGE_11                  0x43 // BRIDGE #11
#define TILES_FORCE_FIELD                0x44 // Force Field
#define TILES_STOP                       0x45 // Stop
#define TILES_ENERGY_DRAIN_TRAP          0x46 // Energy Drain Trap
#define TILES_FREEZE_TRAP                0x47 // Freeze Trap
#define TILES_TRANSPORTER                0x48 // Transporter
#define TILES_TRANSPORTER_DEST           0x49 // Transporter's destination
#define TILES_VAMPLANT                   0x4a // Vampire Plant
#define TILES_FISH                       0x4b // Fish
#define TILES_CHANGE_LINK                0x4c // Change Link
#define TILES_BOBY_OF_THE_WORM           0x4d // Boby of the worm
#define TILES_PLATFORM_UP_DN             0x4e // Magic Platform UP/DN
#define TILES_PLATFORM_LF_RG             0x4f // Magic Platform LF/RG
#define TILES_DUMMY                      0x50 // Dummy
#define TILES_DUMMY_ON_BRIDGE            0x51 // Dummy on bridge
#define TILES_DUMMY_ON_LADDER            0x52 // Dummy on ladder
#define TILES_GOBBLIN                    0x53 // Gobblin
#define TILES_GOBBLIN_ON_BRIDGE          0x54 // Gobblin on bridge
#define TILES_GOBBLIN_ON_LADDER          0x55 // Gobblin on ladder
#define TILES_TEDDY                      0x56 // Teddy
#define TILES_TEDDY_ON_BRIDGE            0x57 // Teddy on bridge
#define TILES_TEDDY_ON_LADDER            0x58 // Teddy on ladder
#define TILES_OCTOPUS                    0x59 // Octopus
#define TILES_OCTOPUS_ON_BRIDGE          0x5a // Octopus on bridge
#define TILES_OCTOPUS_ON_LADDER          0x5b // Octopus on ladder