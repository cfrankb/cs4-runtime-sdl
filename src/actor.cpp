#include "actor.h"
#include "map.h"
#include "game.h"
#include "tilesdata.h"

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

bool CActor::canMove(const int aim)
{
    auto &game = *CGame::getGame();
    CMap &map = game.map();
    const Pos &pos = Pos{m_x, m_y};
    const Pos &newPos = game.translate(pos, aim);
    if (pos.x == newPos.x && pos.y == newPos.y)
    {
        return false;
    }

    uint8_t c = map.at(newPos.x, newPos.y);
    const auto &def = getTileDef(c);
    if (def.type == TYPE_BACKGROUND)
    {
        return true;
    }
    else if (m_type == TYPE_PLAYER)
    {
        if (def.type == TYPE_SWAMP ||
            def.type == TYPE_PICKUP ||
            def.type == TYPE_DIAMOND ||
            def.type == TYPE_STOP ||
            def.type == TYPE_LADDER ||
            def.type == TYPE_SWITCH ||
            def.type == TYPE_BRIDGE ||
            def.type == TYPE_KEY)
        {
            return true;
        }
        else if (def.type == TYPE_DOOR)
        {
            return game.hasKey(c - 1);
        }
        else if (c >= TILES_MAX)
        {
            printf("undefined tile=%.2x type=%.2x\n", c, def.type);
        }
    }
    return false;
}

void CActor::move(const int aim)
{
    auto &game = *CGame::getGame();
    CMap &map = game.map();
    uint8_t c = map.at(m_x, m_y);
    //    map.set(m_x, m_y, m_pu);

    Pos pos{m_x, m_y};
    pos = game.translate(pos, aim);
    m_x = pos.x;
    m_y = pos.y;

    // m_pu = map.at(m_x, m_y);
    // map.set(m_x, m_y, c);
    m_aim = aim;
}