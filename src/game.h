#include <stdint.h>
#include <cstdio>
#include <vector>

#include "map.h"
#include "maparch.h"
#include "actor.h"

class CFrameSet;
class CFrame;
class CMapArch;

#pragma once

class CGame
{
public:
    ~CGame();

    static CGame *getGame();
    void setLevel(const int level);
    bool loadLevel(const bool restart);
    void init();
    void setMode(const int mode);
    int mode();
    uint8_t *keys();
    bool hasKey(uint8_t c);
    CActor &player();
    CMap &map();
    void nextLevel();
    void restartGame();
    bool read(FILE *);
    bool write(FILE *);
    void setLives(const int lives);
    int lives();
    int score();
    int level();
    int goals();
    int health();
    int oxygen();
    int ropes();
    int bulbs();
    int playerSpeed();
    bool setMapArch(const std::string &maparch);
    bool isPlayerDead();
    bool isGameOver();
    void killPlayer();
    int godModeTimer();
    void managePlayer(const uint8_t *joyState);
    void manageMonsters(const uint32_t ticks);
    const std::vector<CActor> &monsters() const;
    const CActor &getMonster(const int i) const;
    Pos translate(const Pos &p, int aim) const;

    enum GameMode
    {
        MODE_INTRO,
        MODE_LEVEL,
        MODE_RESTART,
        MODE_GAMEOVER,
        MODE_CLICKSTART,
        MODE_HISCORES,
        MODE_IDLE,
        MODE_HELP
    };

private:
    CGame();
    bool initLevel();
    bool move(const int aim);
    void consume();
    void addPoints(const int points);
    void addLife();
    void addHealth(const int hp);
    void addOxygen(const int oxygen);
    void addKey(const uint8_t c);
    int triggerFlip(const uint8_t attr);
    void manageActionKeys(const uint8_t *joystate);
    void manageHazards();
    void putRope(const uint8_t aim);
    void takeRope(const uint8_t aim);
    void breakBridge();

    enum : int
    {
        MAX_ACTORS = 64,
        GROW_BY = 8,
        TILE_SIZE = 16,
        WIDTH = 320,
        HEIGHT = 240,
        DEFAULT_PLAYER_SPEED = 3,
        DEFAULT_LIVES = 5,
        DEFAULT_HP = 64,
        DEFAULT_OXYGEN = 32,
        SCORE_LIFE = 5000,
        MAX_OXYGEN = 128,
        MAX_KEYS = 6,
        MAX_LIVES = 99,
        MAX_HEALTH = 128,
        GODMODE_TIMER = 100,
        EXTRASPEED_TIMER = 100,
        FILTER_ATTR = 0x78,   // STOP 00 01 02 etc
        FILTER_ENV = 0x07,    // Water, Lava, Slime (including bottom)
        FILTER_HAZARD = 0x03, // Water, Lava, Slime
        FLAG_HIDDEN = 0x80,   // hide tile from engine
        ENV_WATER = 1,        // water
        ENV_LAVA = 2,         // lava
        ENV_SLIME = 3,        // slime
        ENV_BOTTOM = 4,       // bit on=botton, off=top (water, lava, slime)
        ATTR_STOP = 0x08,     // stop monsters
        LEVEL_BONUS = 500,
        OXYGEN_BONUS = 16,
        Z_KEY = 4,
        KILL_KEY = 5,
    };

    int m_mode;
    int m_level;
    int m_lives;
    int m_score;
    int m_goals;
    int m_hp;
    int m_ropes;
    int m_bulbs;
    int m_oxygen;
    int m_nextLife;
    int m_godModeTimer;
    int m_extraSpeedTimer;
    std::vector<CActor> m_actors;
    CActor m_player;
    void addActor(const CActor &actor);
    CMap m_map;

    IndexVector m_mapIndex;
    std::string m_mapArch;
    uint8_t m_keys[MAX_KEYS];
};