#include <stdint.h>

#pragma once

class CActor
{
public:
    CActor(const uint8_t x = 0, const uint8_t y = 0, const uint8_t type = 0, const uint8_t aim = 0);
    ~CActor();
    uint8_t x();
    void setX(int _x);
    uint8_t y();
    void setY(int _y);
    uint8_t aim();
    void setAim(int _aim);
    enum
    {
        Up,
        Down,
        Left,
        Right
    };

protected:
    uint8_t m_x;
    uint8_t m_y;
    uint8_t m_type;
    uint8_t m_aim;
};