#include "game.h"
#include <cstring>
#include "tilesdata.h"
#include "shared/Frame.h"
#include "shared/FrameSet.h"

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
    if (sfile)
    {
        fseek(sfile, offset, SEEK_SET);
        m_map.read(sfile);
        fclose(sfile);
    }
    else
    {
        printf("couldn't open %s\n", m_mapArch.c_str());
        return false;
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
    m_actors.push_back(actor);
}

bool CGame::initLevel()
{
    m_goals = 0;
    m_actors.clear();
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
            default:
                // sanitize invalid tiles
                if (tileID >= TILES_MAX)
                {
                    printf("invalid tile at (%d,%d) %.2x [attr:%.2x]\n", x, y, tileID, m_map.getAttr(x, y));
                    m_map.at(x, y) = TILES_BLANK;
                }
            }
        }
    }

    printf("player found :%s\n", playerFound ? "true" : "false");
    printf("monsters: %d\n", m_actors.size());
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

    manageHazards();

    uint8_t aims[] = {CActor::Up, CActor::Down, CActor::Left, CActor::Right};
    for (size_t i = 0; i < sizeof(aims); ++i)
    {
        uint8_t aim = aims[i];
        if (joystate[aim] && move(aim))
        {
            break;
        }
    }

    manageActionKeys(joystate);

    if (m_player.canFall())
    {
        m_player.move(CActor::Down, false);
        consume();
    }
}

void CGame::manageHazards()
{
    const auto x = m_player.x();
    const auto y = m_player.y();
    const auto rawData = m_map.getAttr(x, y);
    const auto haz = m_map.getAttr(x, y) & FILTER_HAZARD;

    if ((rawData & FILTER_ENV) == (ENV_WATER | ENV_BOTTOM))
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
    else if (haz == ENV_SLIME || haz == ENV_LAVA)
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
}

void CGame::manageActionKeys(const uint8_t *joystate)
{
    const auto x = m_player.x();
    const auto y = m_player.y();
    const auto pu = m_map.at(x, y);
    if (pu >= TILES_MAX)
    {
        // sanity check
        return;
    }
    auto const rawAttr = m_map.getAttr(x, y);
    const tiledef_t &def = getTileDef(pu);
    const auto attr = rawAttr & FILTER_ATTR;
    if (joystate[Z_KEY] && def.type == TYPE_SWITCH)
    {
        if (pu == TILES_SWITCH_UP)
        {
            m_map.set(x, y, TILES_SWITCH_DOWN);
        }
        else if (pu == TILES_SWITCH_DOWN)
        {
            m_map.set(x, y, TILES_SWITCH_UP);
        }
        if (attr)
        {
            triggerFlip(attr);
        }
    }
    else if (joystate[Z_KEY] && def.type == TYPE_PULLEY)
    {
        switch (pu)
        {
        case TILES_LEFT_PULLEY_WITH_ROPE:
            // with rope
            m_map.set(x, y, TILES_LEFT_PULLEY);
            ++m_ropes;
            takeRope(CActor::Left);
            break;
        case TILES_RIGHT_PULLEY_WITH_ROPE:
            m_map.set(x, y, TILES_RIGHT_PULLEY);
            ++m_ropes;
            takeRope(CActor::Right);
            break;

        case TILES_LEFT_PULLEY:
            // no rope
            if (m_ropes)
            {
                m_map.set(x, y, TILES_LEFT_PULLEY_WITH_ROPE);
                putRope(CActor::Left);
                --m_ropes;
            }
            break;
        case TILES_RIGHT_PULLEY:
            if (m_ropes)
            {
                m_map.set(x, y, TILES_RIGHT_PULLEY_WITH_ROPE);
                putRope(CActor::Right);
                --m_ropes;
            }
        }
    }

    if (joystate[KILL_KEY])
    {
        m_hp = 0;
    }
}

void CGame::takeRope(const uint8_t aim)
{
    const int8_t offset = (aim == CActor::Left ? -1 : 1);
    const auto x = m_player.x();
    const auto y = m_player.y();
    for (uint8_t row = 0;; ++row)
    {
        uint expectedTile;
        if (row == 0)
        {
            expectedTile = (aim == CActor::Left ? TILES_LEFT_ROPE_PULLEY : TILES_RIGHT_PULLEY_ROPE);
        }
        else
        {
            expectedTile = (aim == CActor::Left ? TILES_LEFT_ROPE : TILES_RIGHT_ROPE);
        }

        if (m_map.at(x + offset, y + row) == expectedTile)
        {
            m_map.at(x + offset, y + row) = TILES_BLANK;
        }
        else
        {
            break;
        }
    }
}

void CGame::putRope(const uint8_t aim)
{
    const int8_t offset = (aim == CActor::Left ? -1 : 1);
    const auto x = m_player.x();
    const auto y = m_player.y();
    for (uint8_t row = 0; m_map.at(x + offset, y + row) == TILES_BLANK; ++row)
    {
        if (row == 0)
        {
            m_map.at(x + offset, y + row) = (aim == CActor::Left ? TILES_LEFT_ROPE_PULLEY : TILES_RIGHT_PULLEY_ROPE);
        }
        else
        {
            m_map.at(x + offset, y + row) = (aim == CActor::Left ? TILES_LEFT_ROPE : TILES_RIGHT_ROPE);
        }
    }
}

void CGame::breakBridge()
{
    const auto x = m_player.x();
    const auto y = m_player.y();
    const auto tileID = m_map.at(x, y);
    if (tileID >= TILES_MAX)
    {
        // sanity check
        return;
    }
    auto const rawAttr = m_map.getAttr(x, y);
    if (rawAttr & FLAG_HIDDEN)
    {
        return;
    }
    const tiledef_t &def = getTileDef(tileID);
    if (!def.type == TYPE_BRIDGE || tileID != TILES_BRIDGE_0)
    {
        return;
    }
    if (tileID != TILES_BRIDGE_11)
    {
        m_map.set(x, y, tileID + 1);
    }
    else
    {
        m_map.set(x, y, TILES_BLANK);
    }
}

void CGame::manageMonsters(const uint32_t ticks)
{
    const int speedCount = 9;
    bool speeds[speedCount];
    for (uint32_t i = 0; i < sizeof(speeds); ++i)
    {
        speeds[i] = i ? (ticks % i) == 0 : true;
    }

    uint8_t dirs[] = {CActor::Up, CActor::Down, CActor::Left, CActor::Right};
    std::vector<CActor> newMonsters;
    for (size_t i = 0; i < m_actors.size(); ++i)
    {
        CActor &actor = m_actors[i];
        const tiledef_t &def = getTileDef(actor.tileID());
        if (!speeds[def.speed])
        {
            continue;
        }

        if (def.type == TYPE_MONSTER)
        {
            // printf("id:%d type:%.2x s:%d tile:%.2x\n", i, def.type, def.speed, actor.tileID());
            if (actor.isPlayerThere(actor.aim()))
            {
                // apply health damages
                addHealth(def.health);
                if (def.ai & AI_STICKY)
                {
                    continue;
                }
            }

            int aim = actor.findNextDir();
            if (aim != CActor::None)
            {
                actor.move(aim);
                if (!(def.ai & AI_ROUND))
                {
                    continue;
                }
            }
            for (uint8_t i = 0; i < sizeof(dirs); ++i)
            {
                if (actor.isPlayerThere(dirs[i]))
                {
                    // apply health damages
                    addHealth(def.health);
                    if (def.ai & AI_FOCUS)
                    {
                        actor.setAim(dirs[i]);
                    }
                    break;
                }
            }
        }
        else if (def.type == TYPE_VAMPLANT)
        {
            if (actor.isPlayerThere(CActor::Here))
            {
                // apply damage from config
                addHealth(def.health);
            }
            for (uint8_t i = 0; i < sizeof(dirs); ++i)
            {
                if (actor.isPlayerThere(dirs[i]))
                {
                    // apply damage from config
                    addHealth(def.health);
                }
            }
        }
        else if (def.type == TYPE_DRONE)
        {
            int aim = actor.aim();
            if (aim < CActor::Left)
            {
                aim = CActor::Left;
            }

            if (actor.isPlayerThere(actor.aim()))
            {
                // apply health damages
                addHealth(def.health);
            }

            if (actor.canMove(aim))
            {
                actor.move(aim);
            }
            else
            {
                aim ^= 1;
            }
            actor.setAim(aim);
        }
        else if (def.type == TYPE_PLATFORM)
        {
            uint8_t aim = actor.aim();
            bool canMove = actor.canMove(aim);
            if (actor.tileID() == TILES_PLATFORM_UP_DN)
            {
                aim &= 1;
                if (aim == CActor::Up)
                {
                    if (actor.isPlayerThere(aim))
                    {
                        if (m_player.canMove(aim))
                            m_player.move(CActor::Up);
                        else
                            m_hp = 0;
                    }
                }
                else if (aim == CActor::Down && actor.canMove(CActor::Down))
                {
                    if (actor.isPlayerThere(CActor::Down))
                    {
                        m_player.move(CActor::Down);
                    }
                }
            }
            // left/right platform
            else if (actor.tileID() == TILES_PLATFORM_LF_RG)
            {
                aim |= 2;
                if (actor.isPlayerThere(CActor::Up) && canMove)
                {
                    if (m_player.canMove(aim))
                    {
                        m_player.move(aim, false);
                    }
                    else
                    {
                        m_hp = 0;
                    }
                }
            }

            if (canMove)
            {
                actor.move(aim);
            }
            else
            {
                actor.setAim(aim ^ 1);
            }
        }
    }
    // moved here to avoid reallocation while using a reference
    for (auto const &monster : newMonsters)
    {
        addActor(monster);
    }
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

const std::vector<CActor> &CGame::monsters() const
{
    return m_actors;
}

const CActor &CGame::getMonster(int i) const
{
    return m_actors[i];
}

CActor &CGame::player()
{
    return m_player;
}

void CGame::consume()
{
    const int x = m_player.x();
    const int y = m_player.y();
    const uint8_t pu = m_map.at(x, y);
    const uint8_t rawData = m_map.getAttr(x, y);
    if (rawData & FLAG_HIDDEN || (pu >= TILES_MAX))
    {
        // hidden tiles cannot be consumed
        // invalid tiles should be ignored
        return;
    }

    const tiledef_t &def = getTileDef(pu);
    if (def.type == TYPE_PICKUP)
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
    }
    else if (def.type == TYPE_KEY)
    {
        addPoints(def.score);
        m_map.at(m_player.x(), m_player.y()) = TILES_BLANK;
        addKey(pu);
        addHealth(def.health);
    }
    else if (def.type == TYPE_DIAMOND)
    {
        addPoints(def.score);
        m_map.at(m_player.x(), m_player.y()) = TILES_BLANK;
        --m_goals;
        addHealth(def.health);
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
    else if (def.type == TYPE_SOCKET)
    {
        if (pu == TILES_SOCKET_OFF && m_bulbs != 0)
        {
            m_map.at(m_player.x(), m_player.y()) = TILES_LIGHTBULB_SOCKET_OFF;
            --m_bulbs;
        }
        else if (pu == TILES_SOCKET_ON && m_bulbs != 0)
        {
            m_map.at(m_player.x(), m_player.y()) = TILES_LIGHTBULB_SOCKET_ON;
            --m_bulbs;
        }
        else if (pu == TILES_SOCKET_ON)
        {
            m_hp = 0;
        }
        return;
    }
    else if (def.type == TYPE_TRAP)
    {
        if (pu == TILES_BREAKABLE_ROOT)
        {
        }
        else if (pu == TILES_FREEZE_TRAP)
        {
        }
        else if (pu == TILES_ENERGY_DRAIN_TRAP)
        {
        }
        addHealth(def.health);
        addPoints(def.score);
        m_map.at(m_player.x(), m_player.y()) = TILES_BLANK;
    }
    else if (def.type == TYPE_SPECIAL)
    {
        printf("special :%.2x\n", pu);
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
    if (attr != 0 &&
        attr != ATTR_STOP &&
        def.type != TYPE_SWITCH)
    {
        const uint8_t env = m_map.getAttr(x, y) & FILTER_ENV;
        m_map.setAttr(x, y, env);
        triggerFlip(attr);
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

int CGame::triggerFlip(const uint8_t attr)
{
    printf("triggerFlip %.2x\n", attr);
    int count = 0;
    for (const auto &[key, rawData] : m_map.attrs())
    {
        const uint8_t tileAttr = rawData & FILTER_ATTR;
        if (tileAttr == attr)
        {
            const Pos pos = CMap::toPos(key);
            const uint8_t tileID = m_map.at(pos.x, pos.y);
            if (tileID >= TILES_MAX)
            {
                // ignore invalid tile
                continue;
            }
            const auto &def = getTileDef(tileID);
            printf("-->found at x: %d y: %d type:%.2x attr %.2x\n",
                   pos.x, pos.y, def.type, rawData);
            if (def.type == TYPE_SWITCH ||
                def.type == TYPE_TRANS_DEST ||
                def.type == TYPE_TRANS_SOURCE ||
                def.type == TYPE_DIAMOND ||
                def.type == TYPE_PICKUP)
            {
                continue;
            }
            ++count;

            if (def.type == TYPE_SOCKET)
            {
                switch (tileID)
                {
                case TILES_SOCKET_OFF:
                case TILES_SOCKET_ON:
                    m_map.at(pos.x, pos.y) = tileID ^ 0xe;
                    break;
                case TILES_LIGHTBULB_SOCKET_OFF:
                case TILES_LIGHTBULB_SOCKET_ON:
                    m_map.at(pos.x, pos.y) = tileID ^ 2;
                }
            }
            else
            {
                m_map.setAttr(pos.x, pos.y, rawData ^ FLAG_HIDDEN);
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

Pos CGame::translate(const Pos &p, const int aim) const
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
