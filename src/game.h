#include <stdint.h>
#include <cstdio>

#include "map.h"
#include "maparch.h"
#include "actor.h"

class CFrameSet;
class CFrame;

#pragma once

class CGame
{
public:
    CGame();
    ~CGame();

    void setLevel(int level);
    bool loadLevel();
    void init();
    void drawScreen(CFrame &frame);
    void mainLoop();

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
        HEIGHT = 240
    };

    int m_level;
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
};