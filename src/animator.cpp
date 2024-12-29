/*
    cs3-runtime-sdl
    Copyright (C) 2024  Francois Blanchette

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#include "animator.h"
#include "tilesdata.h"
#include <cstring>

const CAnimator::animzSeq_t animzTileSeq[] = {
    {
        TILES_DUMMY,
        ANIMZ_DUMMY,
        2,
    },
    {
        TILES_GOBBLIN,
        ANIMZ_GOBBLIN,
        2,
    },
    {
        TILES_OCTOPUS,
        ANIMZ_OCTOPUS,
        2,
    },
    {
        TILES_TEDDY,
        ANIMZ_TEDDY,
        2,
    },
    {
        TILES_VAMPLANT,
        ANIMZ_VAMPLANT,
        2,
    },
};

CAnimator::CAnimator()
{
}

CAnimator::~CAnimator()
{
}

void CAnimator::animate()
{
    ++m_offset;
}

uint8_t CAnimator::at(uint8_t tileID)
{
    constexpr size_t seqCount = sizeof(animzTileSeq) / sizeof(decltype(animzTileSeq));
    for (size_t i = 0; i < seqCount; ++i)
    {
        const auto seq = animzTileSeq[i];
        return seq.animz + (m_offset & (seq.count - 1));
    }
    return 0;
}

int CAnimator::offset()
{
    return m_offset;
}
