#include "actor.h"
#include "game.h"
#include "tilesdata.h"

enum
{
    AIM_UP,
    AIM_DOWN,
    AIM_LEFT,
    AIM_RIGHT
};

uint8_t AIMS[] = {
    AIM_DOWN, AIM_RIGHT, AIM_UP, AIM_LEFT,
    AIM_UP, AIM_LEFT, AIM_DOWN, AIM_RIGHT,
    AIM_RIGHT, AIM_UP, AIM_LEFT, AIM_DOWN,
    AIM_LEFT, AIM_DOWN, AIM_RIGHT, AIM_UP};

CActor::CActor(const uint8_t x, const uint8_t y, const uint8_t type, const uint8_t tileID, const uint8_t aim)
{
    m_x = x;
    m_y = y;
    m_aim = aim;
    m_type = type;
    m_tileID = tileID;
}

CActor::~CActor()
{
}

uint8_t CActor::x() const
{
    return m_x;
}

void CActor::setX(const uint8_t _x)
{
    m_x = _x;
}

uint8_t CActor::y() const
{
    return m_y;
}

void CActor::setY(const uint8_t _y)
{
    m_y = _y;
}

uint8_t CActor::aim() const
{
    return m_aim;
}

uint8_t CActor::type() const
{
    return m_type;
}

uint8_t CActor::tileID() const
{
    return m_tileID;
}

void CActor::setAim(const uint8_t _aim)
{
    m_aim = _aim;
}

bool CActor::canMove(const int aim) const
{
    auto &game = *CGame::getGame();
    CMap &map = game.map();
    const Pos &pos = Pos{m_x, m_y};
    const Pos &newPos = game.translate(pos, aim);
    if (pos.x == newPos.x && pos.y == newPos.y)
    {
        // invalid position outside of map
        return false;
    }

    const uint8_t c = map.at(newPos.x, newPos.y);
    const auto &def = getTileDef(c);
    const uint8_t rawData = map.getAttr(newPos.x, newPos.y);
    const uint8_t attr = rawData & FILTER_ATTR;
    if (rawData & FLAG_HIDDEN)
    {
        // ignore hidden tiles
        return true;
    }
    else if ((m_type != TYPE_PLAYER) &&
             (aim != Fall) && (attr == ATTR_STOP))
    {
        return false;
    }
    else if (def.type == TYPE_BACKGROUND ||
             def.type == TYPE_LADDER ||
             def.type == TYPE_BRIDGE ||
             def.type == TYPE_ROOT ||
             def.type == TYPE_SPECIAL ||
             def.type == TYPE_SOCKET ||
             def.type == TYPE_PULLEY ||
             def.type == TYPE_AUTO_ROPE ||
             def.type == TYPE_TRAP)
    {
        return true;
    }
    else if (m_type == TYPE_PLAYER)
    {
        if (def.type == TYPE_SWAMP ||
            def.type == TYPE_PICKUP ||
            def.type == TYPE_DIAMOND ||
            def.type == TYPE_STOP ||
            def.type == TYPE_SWITCH ||
            def.type == TYPE_KEY ||
            def.type == TYPE_TRANS_SOURCE ||
            def.type == TYPE_TRANS_DEST)
        {
            return true;
        }
        else if (def.type == TYPE_DOOR)
        {
            return game.hasKey(c - 1);
        }
        else if (c >= TILES_MAX)
        {
            // TODO: Revisit later
            printf("undefined tile=%.2x type=%.2x\n", c, def.type);
            return true;
        }
    }
    return false;
}

void CActor::move(const int aim)
{
    auto &game = *CGame::getGame();
    CMap &map = game.map();
    uint8_t c = map.at(m_x, m_y);

    Pos pos{m_x, m_y};
    pos = game.translate(pos, aim);
    m_x = pos.x;
    m_y = pos.y;

    m_aim = aim;
}

uint8_t CActor::findNextDir() const
{
    int i = AimCount - 1;
    while (i >= 0)
    {
        int aim = AIMS[m_aim * AimCount + i];
        if (canMove(aim))
        {
            return aim;
        }
        --i;
    }
    return None;
}

bool CActor::isPlayerThere(const uint8_t aim) const
{
    auto &game = *CGame::getGame();
    const auto &player = game.player();
    if (aim == Here)
    {
        return player.x() == m_x && player.y() == m_y;
    }
    const auto newPos = game.translate(Pos{m_x, m_y}, aim);
    return newPos.x == player.x() && newPos.y == player.y();
}

const Pos CActor::pos() const
{
    return Pos{m_x, m_y};
}