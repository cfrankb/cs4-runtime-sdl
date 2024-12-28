#include "game.h"
#include "tilesdata.h"
#include "shared/Frame.h"
#include "shared/FrameSet.h"
#include "shared/FileWrap.h"

const char DEFAULT_ARCH[] = "data/levels.mapz-cs4";

CGame::CGame()
{
    init();
}

CGame::~CGame()
{
    if (m_actors)
    {
        delete[] m_actors;
        m_actors = nullptr;
    }
}

void CGame::setLevel(int level)
{
    m_level = level;
}

bool CGame::loadLevel()
{
    const auto levelCount = m_mapIndex.size();
    const int offset = m_mapIndex[m_level % levelCount];
    FILE *sfile = fopen(DEFAULT_ARCH, "rb");
    if (sfile == nullptr)
    {
        return false;
    }
    else if (sfile)
    {
        fseek(sfile, offset, SEEK_SET);
        m_map.read(sfile);
        fclose(sfile);
    }

    return initLevel();
}

bool CGame::loadLevelIndex()
{
    return CMapArch::indexFromFile(DEFAULT_ARCH, m_mapIndex);
}

void CGame::init()
{

    m_tiles = new CFrameSet();
    m_animz = new CFrameSet();
    preloadAssets();

    loadLevelIndex(); // get level index from archive
    m_level = 0;
    loadLevel();
}

void CGame::addActor(const CActor &actor)
{
    m_actors[m_actorCount++] = actor;
}

bool CGame::initLevel()
{
    m_actorCount = 0;
    bool playerFound = false;

    for (int y = 0; y < m_map.hei(); ++y)
    {
        for (int x = 0; x < m_map.len(); ++x)
        {
            const auto &tileID = m_map.at(x, y);
            const auto &attr = m_map.getAttr(x, y);
            switch (tileID)
            {
            case TILES_PLAYER:
                m_player = CActor(x, y, tileID, CActor::Down);
                m_map.at(x, y) = TILES_BLANK;
                playerFound = true;
                break;
            case TILES_VAMPLANT:
                addActor(CActor(x, y, tileID, CActor::Up));
                m_map.at(x, y) = TILES_BLANK;
                break;
            case TILES_FISH:
                addActor(CActor(x, y, tileID, CActor::Left));
                m_map.at(x, y) = TILES_BLANK;
                break;
            case TILES_CHANGE_LINK:
                addActor(CActor(x, y, tileID, CActor::Left));
                m_map.at(x, y) = TILES_BLANK;
                break;
            case TILES_PLATFORM_UP_DN:
                addActor(CActor(x, y, tileID, CActor::Up));
                m_map.at(x, y) = TILES_BLANK;
                break;
            case TILES_PLATFORM_LF_RG:
                addActor(CActor(x, y, tileID, CActor::Left));
                m_map.at(x, y) = TILES_BLANK;
                break;
            case TILES_DUMMY:
                addActor(CActor(x, y, TILES_DUMMY, CActor::Left));
                m_map.at(x, y) = TILES_BLANK;
                break;
            case TILES_DUMMY_ON_BRIDGE:
                addActor(CActor(x, y, TILES_DUMMY, CActor::Left));
                m_map.at(x, y) = TILES_BRIDGE_0;
                break;
            case TILES_DUMMY_ON_LADDER:
                addActor(CActor(x, y, TILES_DUMMY, CActor::Left));
                m_map.at(x, y) = TILES_LADDER;
                break;
            case TILES_GOBBLIN:
                addActor(CActor(x, y, TILES_GOBBLIN, CActor::Left));
                m_map.at(x, y) = TILES_BLANK;
                break;
            case TILES_GOBBLIN_ON_BRIDGE:
                addActor(CActor(x, y, TILES_GOBBLIN, CActor::Left));
                m_map.at(x, y) = TILES_BRIDGE_0;
                break;
            case TILES_GOBBLIN_ON_LADDER:
                addActor(CActor(x, y, TILES_GOBBLIN, CActor::Left));
                m_map.at(x, y) = TILES_LADDER;
                break;
            case TILES_TEDDY:
                addActor(CActor(x, y, TILES_TEDDY, CActor::Left));
                m_map.at(x, y) = TILES_BLANK;
                break;
            case TILES_TEDDY_ON_BRIDGE:
                addActor(CActor(x, y, TILES_TEDDY, CActor::Left));
                m_map.at(x, y) = TILES_BRIDGE_0;
                break;
            case TILES_TEDDY_ON_LADDER:
                addActor(CActor(x, y, TILES_TEDDY, CActor::Left));
                m_map.at(x, y) = TILES_LADDER;
                break;
            case TILES_OCTOPUS:
                addActor(CActor(x, y, TILES_OCTOPUS, CActor::Left));
                m_map.at(x, y) = TILES_BLANK;
                break;
            case TILES_OCTOPUS_ON_BRIDGE:
                addActor(CActor(x, y, TILES_OCTOPUS, CActor::Left));
                m_map.at(x, y) = TILES_BRIDGE_0;
                break;
            case TILES_OCTOPUS_ON_LADDER:
                addActor(CActor(x, y, TILES_OCTOPUS, CActor::Left));
                m_map.at(x, y) = TILES_LADDER;
                break;
            }
        }
    }

    printf("player found :%d\n", playerFound ? "true" : "false");
    printf("monsters: %d\n", m_actorCount);

    return playerFound;
}

void CGame::preloadAssets()
{
    struct obl5data_t
    {
        CFrameSet *frameSet;
        const char *filename;
    };

    obl5data_t frameSets[] = {
        {m_animz, "data/cs4animz.obl"},
        {m_tiles, "data/cs4tiles.obl"},
    };

    enum
    {
        SET_COUNT = sizeof(frameSets) / sizeof(obl5data_t)
    };

    // read framesets
    CFileWrap file;
    for (int i = 0; i < SET_COUNT; ++i)
    {
        auto &set = frameSets[i];
        if (!file.open(set.filename))
        {
            printf("failed to open %s\n", set.filename);
        }
        set.frameSet->read(file);
        file.close();
    }
}

void CGame::drawScreen(CFrame &frame)
{

    frame.fill(0xff000000);

    enum
    {
        FLAG_UP_DOWN = 4,
        UP_OFFSET = 0,
        DOWN_OFFSET = 2,
        FILTER_ENV = 3, // WATER, LAVA, SLIME
        ENV_FRAMES = 3,
        FILTER_ATTR = 0xf8 // STOP 00 01 02 etc
    };

    const auto mapLen = WIDTH / TILE_SIZE;
    const auto mapHei = HEIGHT / TILE_SIZE;

    CFrameSet &tiles = *m_tiles;
    CFrameSet &animz = *m_animz;

    for (int y = 0; y < mapHei; ++y)
    {
        for (int x = 0; x < mapLen; ++x)
        {
            const auto &tileID = m_map.at(x, y);
            const auto &attr = m_map.getAttr(x, y);
            if (attr & 0x80)
            {
                // printf("%s (%d %d) %.2x\n", tmp, x, y, attr);
            }
            if (attr & FILTER_ENV)
            {
                auto bframe = ENV_FRAMES * ((attr & FILTER_ENV) - 1) + ((attr & FLAG_UP_DOWN) ? DOWN_OFFSET : UP_OFFSET);
                frame.drawAt(*(animz[bframe]), x * TILE_SIZE, y * TILE_SIZE, true);
            }
            frame.drawAt(*(tiles[tileID]), x * TILE_SIZE, y * TILE_SIZE, true);
            if (attr & FILTER_ATTR)
            {
                auto num = (attr >> 3) & 0x1f;
                //  frame.drawAt(*(g_frameSets[SET_NUM].frameSet[num]), x * TILE_SIZE, y * TILE_SIZE, true);
            }
        }
    }
}

void CGame::mainLoop()
{
    CFrame frame(WIDTH, HEIGHT);
    drawScreen(frame);
}