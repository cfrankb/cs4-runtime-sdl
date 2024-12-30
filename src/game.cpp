#include "game.h"
#include <cstring>
#include "tilesdata.h"
#include "shared/Frame.h"
#include "shared/FrameSet.h"
#include "shared/FileWrap.h"

const char DEFAULT_ARCH[] = "data/levels.mapz-cs4";
CGame *g_gamePrivate = nullptr;
#define _same(_t, _v) static_cast<decltype(_t)>(_v)

CGame::CGame()
{
    m_hp = DEFAULT_HP;
    m_level = 0;
    m_lives = DEFAULT_LIVES;
    m_score = 0;
    m_nextLife = SCORE_LIFE;
    m_extraSpeedTimer = 0;
    m_godModeTimer = 0;
    m_ropes = 0;
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
    m_ropes = 0;
    m_bulbs = 0;
    memset(m_keys, 0, sizeof(m_keys));
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
    m_godModeTimer = std::max(m_godModeTimer - 1, 0);
    m_extraSpeedTimer = std::max(m_extraSpeedTimer - 1, 0);
    const auto x = m_player.x();
    const auto y = m_player.y();
    auto const pu = m_map.at(x, y);
    auto const rawAttr = m_map.getAttr(x, y);
    auto const env = rawAttr & FILTER_HAZARD;

    if (env == ENV_WATER)
    {
        // suffocate
        if (m_oxygen)
        {
            --m_oxygen;
        }
        else if (m_hp)
        {
            --m_hp;
        }
    }
    else if (env == ENV_SLIME || env == ENV_LAVA)
    {
        // instant death
        m_hp = 0;
        return;
    }
    else
    {
        // restore oxygen
        m_oxygen = std::max(m_oxygen, _same(m_oxygen, DEFAULT_OXYGEN));
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

    const tiledef_t &def = getTileDef(pu);
    const auto attr = rawAttr & FILTER_ATTR;
    if (joystate[Z_KEY] && def.type == TYPE_SWITCH)
    {
        if (pu == TILES_SWITCH_UP)
        {
            m_map.set(x, y, TILES_SWITCH_DOWN);
        }
        else
        {
            m_map.set(x, y, TILES_SWITCH_UP);
        }
        if (attr)
        {
            flipHiddenFlag(attr);
        }
    }

    if (joystate[KILL_KEY])
    {
        killPlayer();
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

int CGame::oxygen()
{
    return m_oxygen;
}

int CGame::ropes()
{
    return m_ropes;
}

int CGame::bulbs()
{
    return m_bulbs;
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
    m_hp = 0;
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
    const int x = m_player.x();
    const int y = m_player.y();
    const uint8_t pu = m_map.at(x, y);
    const uint8_t rawData = m_map.getAttr(x, y);
    const tiledef_t &def = getTileDef(pu);
    if (rawData & FLAG_HIDDEN)
    {
        // hidden tiles cannot be consumed
        return;
    }
    else if (def.type == TYPE_PICKUP)
    {
        addPoints(def.score);
        m_map.at(m_player.x(), m_player.y()) = TILES_BLANK;
        addHealth(def.health);
        if (pu == TILES_OXYGEN_BOTTLE)
        {
            m_oxygen = std::min(m_oxygen + OXYGEN_BONUS, _same(m_oxygen, MAX_OXYGEN));
        }
        else if (pu == TILES_ROPE)
        {
            ++m_ropes;
        }
        else if (pu == TILES_LIGHT_BULB)
        {
            ++m_bulbs;
        }
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
    else if (def.type == TYPE_BACKGROUND ||
             def.type == TYPE_TRANS_DEST ||
             def.type == TYPE_TRANS_SOURCE)
    {
        // do no consume blank or transporter
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
    const uint8_t attr = rawData & FILTER_ATTR;
    if (attr)
        printf("attr : %.2x\n", attr);
    if (attr != 0 && attr != ATTR_STOP)
    {
        if (def.type != TYPE_SWITCH)
        {
            const uint8_t env = m_map.getAttr(x, y) & FILTER_ENV;
            m_map.setAttr(x, y, env);
            if (flipHiddenFlag(attr))
            {
                //    playSound(SOUND_0009);
            }
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

uint8_t *CGame::keys()
{
    return m_keys;
};

void CGame::addHealth(const int hp)
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

void CGame::addOxygen(const int oxygen)
{
    m_oxygen = std::max(m_oxygen + oxygen, _same(m_oxygen, MAX_OXYGEN));
}

void CGame::addKey(const uint8_t c)
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

int CGame::flipHiddenFlag(const uint8_t attr)
{
    printf("flipHiddenFlag %.2x\n", attr);
    int count = 0;
    for (const auto &[key, rawData] : m_map.attrs())
    {
        const uint8_t tileAttr = rawData & FILTER_ATTR;
        if (tileAttr == attr)
        {
            const Pos pos = CMap::toPos(key);
            const uint8_t tile = m_map.at(pos.x, pos.y);
            const auto &def = getTileDef(tile);
            printf("-->found at x: %d y: %d type:%.2x attr %.2x\n",
                   pos.x, pos.y, def.type, rawData);
            if (def.type == TYPE_SWITCH ||
                def.type == TYPE_TRANS_DEST ||
                def.type == TYPE_TRANS_SOURCE ||
                def.type == TYPE_DIAMOND)
            {
                continue;
            }
            ++count;
            m_map.setAttr(pos.x, pos.y, rawData ^ FLAG_HIDDEN);
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
