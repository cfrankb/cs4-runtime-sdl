#include "actor.h"

CActor::CActor(const uint8_t x, const uint8_t y, const uint8_t type, const uint8_t aim)
{
    m_x = x;
    m_y = y;
    m_aim = aim;
    m_type = type;
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

void CActor::setAim(const uint8_t _aim)
{
    m_aim = _aim;
}

bool CActor::canMove(const int aim)
{
    return true;
}

void CActor::move(const int aim)
{
    switch (aim)
    {
    case Up:
        --m_y;
        break;
    case Down:
        ++m_y;
        break;
    case Left:
        --m_x;
        break;
    case Right:
        ++m_x;
    }
}