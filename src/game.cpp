#include "game.h"
#include "tilesdata.h"
#include "shared/Frame.h"
#include "shared/FrameSet.h"
#include "shared/FileWrap.h"

const char DEFAULT_ARCH[] = "data/levels.mapz-cs4";
CGame *g_gamePrivate = nullptr;

CGame::CGame()
{
    m_hp = DEFAULT_HP;
    m_level = 0;
    m_lives = DEFAULT_LIVES;
    m_score = 0;
    m_nextLife = SCORE_LIFE;
    m_extraSpeedTimer = 0;
    m_godModeTimer = 0;
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

bool CGame::loadLevel(bool restart)
{
    printf("loading level: %d ...\n", m_level + 1);
    setMode(restart ? MODE_RESTART : MODE_INTRO);

    const auto levelCount = m_mapIndex.size();
    const int offset = m_mapIndex[m_level % levelCount];
    FILE *sfile = fopen(m_mapArch.c_str(), "rb");
    if (sfile == nullptr)
    {
        printf("couldn't open %s\n", m_mapArch.c_str());
        return false;
    }
    else if (sfile)
    {
        fseek(sfile, offset, SEEK_SET);
        m_map.read(sfile);
        fclose(sfile);
    }
    m_hp = DEFAULT_HP;
    m_oxygen = DEFAULT_OXYGEN;
    return initLevel();
}

void CGame::init()
{
    //  m_tiles = new CFrameSet();
    //  m_animz = new CFrameSet();
    // preloadAssets();
    // loadLevelIndex(); // get level index from archive
    // m_level = 0;
    // loadLevel(false);
}

void CGame::addActor(const CActor &actor)
{
    m_actors[m_actorCount++] = actor;
}

bool CGame::initLevel()
{
    m_goals = 0;
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
                m_player = CActor(x, y, TYPE_PLAYER, tileID, CActor::Down);
                m_map.at(x, y) = TILES_BLANK;
                playerFound = true;
                break;
            case TILES_DIAMOND:
                m_goals++;
                break;
            case TILES_VAMPLANT:
                addActor(CActor(x, y, TYPE_VAMPLANT, tileID, CActor::Up));
                m_map.at(x, y) = TILES_BLANK;
                break;
            case TILES_FISH:
                addActor(CActor(x, y, TYPE_DRONE, tileID, CActor::Left));
                m_map.at(x, y) = TILES_BLANK;
                break;
            case TILES_CHANGE_LINK:
                addActor(CActor(x, y, TYPE_MONSTER, tileID, CActor::Left));
                m_map.at(x, y) = TILES_BLANK;
                break;
            case TILES_PLATFORM_UP_DN:
                addActor(CActor(x, y, TYPE_PLATFORM, tileID, CActor::Up));
                m_map.at(x, y) = TILES_BLANK;
                break;
            case TILES_PLATFORM_LF_RG:
                addActor(CActor(x, y, TYPE_PLATFORM, tileID, CActor::Left));
                m_map.at(x, y) = TILES_BLANK;
                break;
            case TILES_DUMMY:
                addActor(CActor(x, y, TYPE_MONSTER, TILES_DUMMY, CActor::Left));
                m_map.at(x, y) = TILES_BLANK;
                break;
            case TILES_DUMMY_ON_BRIDGE:
                addActor(CActor(x, y, TYPE_MONSTER, TILES_DUMMY, CActor::Left));
                m_map.at(x, y) = TILES_BRIDGE_0;
                break;
            case TILES_DUMMY_ON_LADDER:
                addActor(CActor(x, y, TYPE_MONSTER, TILES_DUMMY, CActor::Left));
                m_map.at(x, y) = TILES_LADDER;
                break;
            case TILES_GOBBLIN:
                addActor(CActor(x, y, TYPE_MONSTER, TILES_GOBBLIN, CActor::Left));
                m_map.at(x, y) = TILES_BLANK;
                break;
            case TILES_GOBBLIN_ON_BRIDGE:
                addActor(CActor(x, y, TYPE_MONSTER, TILES_GOBBLIN, CActor::Left));
                m_map.at(x, y) = TILES_BRIDGE_0;
                break;
            case TILES_GOBBLIN_ON_LADDER:
                addActor(CActor(x, y, TYPE_MONSTER, TILES_GOBBLIN, CActor::Left));
                m_map.at(x, y) = TILES_LADDER;
                break;
            case TILES_TEDDY:
                addActor(CActor(x, y, TYPE_MONSTER, TILES_TEDDY, CActor::Left));
                m_map.at(x, y) = TILES_BLANK;
                break;
            case TILES_TEDDY_ON_BRIDGE:
                addActor(CActor(x, y, TYPE_MONSTER, TILES_TEDDY, CActor::Left));
                m_map.at(x, y) = TILES_BRIDGE_0;
                break;
            case TILES_TEDDY_ON_LADDER:
                addActor(CActor(x, y, TYPE_MONSTER, TILES_TEDDY, CActor::Left));
                m_map.at(x, y) = TILES_LADDER;
                break;
            case TILES_OCTOPUS:
                addActor(CActor(x, y, TYPE_MONSTER, TILES_OCTOPUS, CActor::Left));
                m_map.at(x, y) = TILES_BLANK;
                break;
            case TILES_OCTOPUS_ON_BRIDGE:
                addActor(CActor(x, y, TYPE_MONSTER, TILES_OCTOPUS, CActor::Left));
                m_map.at(x, y) = TILES_BRIDGE_0;
                break;
            case TILES_OCTOPUS_ON_LADDER:
                addActor(CActor(x, y, TYPE_MONSTER, TILES_OCTOPUS, CActor::Left));
                m_map.at(x, y) = TILES_LADDER;
                break;
            }
        }
    }

    printf("player found :%s\n", playerFound ? "true" : "false");
    printf("monsters: %d\n", m_actorCount);

    return playerFound;
}

void CGame::setMode(int mode)
{
    m_mode = mode;
}

int CGame::mode()
{
    return m_mode;
}

void CGame::nextLevel()
{
    addPoints(LEVEL_BONUS + m_hp);
    if (m_level != m_mapIndex.size() - 1)
    {
        ++m_level;
    }
    else
    {
        m_level = 0;
    }
}

void CGame::restartGame()
{
    m_hp = DEFAULT_HP;
    m_level = 0;
    m_lives = DEFAULT_LIVES;
    m_score = 0;
    m_nextLife = SCORE_LIFE;
    m_extraSpeedTimer = 0;
    m_godModeTimer = 0;
}

bool CGame::setMapArch(const std::string &maparch)
{
    m_mapArch = maparch;
    return CMapArch::indexFromFile(m_mapArch.c_str(), m_mapIndex);
}

bool CGame::move(const int aim)
{
    if (m_player.canMove(aim))
    {
        m_player.move(aim);
        consume();
        return true;
    }

    return false;
}

void CGame::managePlayer(const uint8_t *joystate)
{
    // m_godModeTimer = std::max(m_godModeTimer - 1, 0);
    // m_extraSpeedTimer = std::max(m_extraSpeedTimer - 1, 0);
    //    auto const pu = m_player.getPU();
    auto const pu = m_map.at(m_player.x(), m_player.y());
    auto const env = m_map.getAttr(m_player.x(), m_player.y()) & FILTER_HAZARD;

    if (env == ENV_WATER)
    {
    }
    else if (env == ENV_SLIME || env == ENV_LAVA)
    {
        m_hp = 0;
        return;
    }

    uint8_t aims[] = {CActor::Up, CActor::Down, CActor::Left, CActor::Right};
    for (uint8_t i = 0; i < 4; ++i)
    {
        uint8_t aim = aims[i];
        if (joystate[aim] && move(aim))
        {
            break;
        }
    }
}

void CGame::manageMonsters(const uint32_t ticks)
{
}

CGame *CGame::getGame()
{
    if (g_gamePrivate == nullptr)
    {
        g_gamePrivate = new CGame();
    }
    return g_gamePrivate;
}

bool CGame::read(FILE *)
{
    return true;
}

bool CGame::write(FILE *)
{
    return true;
}

void CGame::setLives(const int lives)
{
    m_lives = lives;
}

int CGame::lives()
{
    return m_lives;
}

int CGame::score()
{
    return m_score;
}

int CGame::level()
{
    return m_level;
}

int CGame::goals()
{
    return m_goals;
}

int CGame::health()
{
    return m_hp;
}

int CGame::playerSpeed()
{
    return DEFAULT_PLAYER_SPEED;
}

bool CGame::isPlayerDead()
{
    return m_hp == 0;
}

bool CGame::isGameOver()
{
    return m_lives == 0;
}

void CGame::killPlayer()
{
    m_lives = m_lives ? m_lives - 1 : 0;
}

int CGame::godModeTimer()
{
    return 0;
}

void CGame::getMonsters(CActor *&monsters, int &count)
{
    monsters = m_actors;
    count = m_actorCount;
}

CActor &CGame::getMonster(int i)
{
    return m_actors[i];
}

void CGame::consume()
{
    const uint8_t pu = m_map.at(m_player.x(), m_player.y());
    const tiledef_t &def = getTileDef(pu);
    if (def.type == TYPE_PICKUP)
    {
        addPoints(def.score);
        m_map.at(m_player.x(), m_player.y()) = TILES_BLANK;
        addHealth(def.health);
        // playTileSound(pu);
    }
    else if (def.type == TYPE_KEY)
    {
        addPoints(def.score);
        m_map.at(m_player.x(), m_player.y()) = TILES_BLANK;
        addKey(pu);
        addHealth(def.health);
        //        playSound(SOUND_KEY);
    }
    else if (def.type == TYPE_DIAMOND)
    {
        addPoints(def.score);
        m_map.at(m_player.x(), m_player.y()) = TILES_BLANK;
        --m_goals;
        addHealth(def.health);
        //  playTileSound(pu);
    }
    else if (def.type == TYPE_SWAMP)
    {
        addHealth(def.health);
    }
    else if (def.type == TYPE_SWITCH)
    {
        // do no consume switch
        return;
    }

    // apply flags
    if (def.flags & FLAG_EXTRA_LIFE)
    {
        addLife();
    }

    if (def.flags & FLAG_GODMODE)
    {
        m_godModeTimer = GODMODE_TIMER;
    }

    if (def.flags & FLAG_EXTRA_SPEED)
    {
        m_extraSpeedTimer = EXTRASPEED_TIMER;
    }

    // trigger key
    const int x = m_player.x();
    const int y = m_player.y();
    const uint8_t attr = m_map.getAttr(x, y) & FILTER_ATTR;
    if (attr)
        printf("attr : %.2x\n", attr);
    if (attr != 0 && attr != ATTR_STOP)
    {
        const uint8_t env = m_map.getAttr(x, y) & FILTER_ENV;
        m_map.setAttr(x, y, env);
        if (clearAttr(attr))
        {
            //    playSound(SOUND_0009);
        }
    }
}

void CGame::addPoints(const int points)
{
    m_score += points;
    if (m_score >= m_nextLife)
    {
        m_nextLife += SCORE_LIFE;
        addLife();
    }
}

void CGame::addLife()
{
    m_lives = std::min(m_lives + 1, static_cast<int>(MAX_LIVES));
}

CMap &CGame::map()
{
    return m_map;
}

void CGame::addHealth(int hp)
{
    if (hp > 0)
    {
        m_hp = std::min(m_hp + hp, static_cast<int>(MAX_HEALTH));
    }
    else if (hp < 0 && !m_godModeTimer)
    {
        m_hp = std::max(m_hp + hp, 0);
    }
}

void CGame::addKey(uint8_t c)
{
    for (uint32_t i = 0; i < sizeof(m_keys); ++i)
    {
        if (m_keys[i] == c)
        {
            break;
        }
        if (m_keys[i] == '\0')
        {
            m_keys[i] = c;
            break;
        }
    }
}

int CGame::clearAttr(const uint8_t attr)
{
    int count = 0;
    for (int y = 0; y < m_map.hei(); ++y)
    {
        for (int x = 0; x < m_map.len(); ++x)
        {
            const uint8_t tileAttr = m_map.getAttr(x, y) & FILTER_ATTR;
            if (tileAttr == attr)
            {
                ++count;
                const uint8_t tile = m_map.at(x, y);
                const auto &def = getTileDef(tile);
                if (def.type == TYPE_DIAMOND)
                {
                    --m_goals;
                }
                const uint8_t tileEnv = m_map.getAttr(x, y) & FILTER_ENV;
                m_map.set(x, y, TILES_BLANK);
                m_map.setAttr(x, y, tileEnv);
            }
        }
    }
    return count;
}

bool CGame::hasKey(uint8_t c)
{
    for (uint32_t i = 0; i < sizeof(m_keys); ++i)
    {
        if (m_keys[i] == c)
        {
            return true;
        }
    }
    return false;
}

Pos CGame::translate(const Pos &p, int aim)
{
    Pos t = p;

    switch (aim)
    {
    case CActor::Up:
        if (t.y > 0)
        {
            --t.y;
        }
        break;
    case CActor::Down:
        if (t.y < m_map.hei() - 1)
        {
            ++t.y;
        }
        break;
    case CActor::Left:
        if (t.x > 0)
        {
            --t.x;
        }
        break;
    case CActor::Right:
        if (t.x < m_map.len() - 1)
        {
            ++t.x;
        }
    }

    return t;
}
