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

uint8_t CActor::x()
{
    return m_x;
}

void CActor::setX(int _x)
{
    m_x = _x;
}

uint8_t CActor::y()
{
    return m_y;
}

void CActor::setY(int _y)
{
    m_y = _y;
}

uint8_t CActor::aim()
{
    return m_aim;
}

void CActor::setAim(int _aim)
{
    m_aim = _aim;
}
