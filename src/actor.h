#include <stdint.h>

#pragma once

class CActor
{
public:
    CActor(const uint8_t x = 0, const uint8_t y = 0, const uint8_t type = 0, const uint8_t tileID = 0, const uint8_t aim = 0);
    ~CActor();
    uint8_t x() const;
    void setX(const uint8_t _x);
    uint8_t y() const;
    void setY(const uint8_t _y);
    uint8_t aim() const;
    uint8_t type() const;
    uint8_t tileID() const;
    void setAim(const uint8_t _aim);
    bool canMove(const int aim);
    void move(const int aim);
    inline bool within(int x1, int y1, int x2, int y2) const
    {
        return (m_x >= x1) && (m_x < x2) && (m_y >= y1) && (m_y < y2);
    }

    enum
    {
        Up,
        Down,
        Left,
        Right,
        Fall = 0xff
    };

protected:
    enum
    {
        FILTER_ATTR = 0x78, // STOP 00 01 02 etc
        FLAG_HIDDEN = 0x80, // hide tile from engine
        ATTR_STOP = 0x08,   // stop monsters
    };

    uint8_t m_x;      // x
    uint8_t m_y;      // y
    uint8_t m_type;   // actor type
    uint8_t m_tileID; // tile associated
    uint8_t m_aim;    // aim
};