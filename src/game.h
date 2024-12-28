#include <stdint.h>
#include <cstdio>

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
    CGame();
    ~CGame();

    void setLevel(const int level);
    bool loadLevel(const bool restart);
    void init();
    void drawScreen(CFrame &frame);
    void mainLoop();
    void setMode(const int mode);
    int mode();
    inline uint8_t *keys()
    {
        return m_keys;
    };

    inline CMap &map()
    {
        return m_map;
    }

    inline CActor &player()
    {
        return m_player;
    }

    void nextLevel();
    void restartGame();
    bool read(FILE *)
    {
        return true;
    }

    bool write(FILE *)
    {
        return true;
    }

    void setLives(const int lives)
    {
        m_lives = lives;
    }

    int lives()
    {
        return m_lives;
    }

    int score()
    {
        return m_score;
    }

    int level()
    {
        return m_level;
    }

    int goals()
    {
        return m_goals;
    }

    int health()
    {
        return m_hp;
    }

    int playerSpeed()
    {
        return DEFAULT_PLAYER_SPEED;
    }

    bool setMapArch(const std::string &maparch);

    bool isPlayerDead()
    {
        return false;
    }

    bool isGameOver()
    {
        return false;
    }

    void killPlayer()
    {
        m_hp = 0;
    }

    int godModeTimer()
    {
        return 0;
    }

    void managePlayer(const uint8_t *joyState);
    void manageMonsters(const uint32_t ticks);

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

    enum
    {
        KeyCount = 6
    };

protected:
private:
    bool loadLevelIndex();
    bool initLevel();

    enum
    {
        MAX_ACTORS = 64,
        GROW_BY = 8,
        TILE_SIZE = 16,
        WIDTH = 320,
        HEIGHT = 240,
        DEFAULT_PLAYER_SPEED = 3
    };

    int m_mode;
    int m_level;
    int m_lives;
    int m_score;
    int m_goals;
    int m_hp;
    CMap m_map;
    CActor *m_actors = new CActor[MAX_ACTORS];
    CActor m_player;
    int m_actorMax = MAX_ACTORS;
    int m_actorCount = 0;
    void addActor(const CActor &actor);
    void preloadAssets();

    CFrameSet *m_tiles;
    CFrameSet *m_animz;

    IndexVector m_mapIndex;
    std::string m_mapArch;
    uint8_t m_keys[KeyCount];
};