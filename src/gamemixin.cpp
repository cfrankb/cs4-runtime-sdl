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
#include <cstring>
#include "gamemixin.h"
#include "tilesdata.h"
#include "shared/FrameSet.h"
#include "shared/Frame.h"
#include "map.h"
#include "game.h"
#include "maparch.h"
#include "animator.h"

// Check windows
#ifdef _WIN64
#define ENVIRONMENT64
#else
#ifdef _WIN32
#define ENVIRONMENT32
#endif
#endif

// Check GCC
#if __GNUC__
#if __x86_64__ || __ppc64__
#define ENVIRONMENT64
#else
#define ENVIRONMENT32
#endif
#endif

CGameMixin::CGameMixin()
{
    m_game = CGame::getGame();
    m_animator = new CAnimator();
    m_prompt = PROMPT_NONE;
    clearJoyStates();
    // clearScores();
    clearKeyStates();
}

CGameMixin::~CGameMixin()
{
    if (m_animator)
    {
        delete m_animator;
    }

    if (m_game)
    {
        delete m_game;
    }

    if (m_tiles)
    {
        delete m_tiles;
    }

    if (m_animz)
    {
        delete m_animz;
    }

    if (m_annie)
    {
        delete m_annie;
    }

    if (m_fontData)
    {
        delete[] m_fontData;
    }
}

void CGameMixin::preloadAssets()
{
    // TODO: implement in child class
}

void CGameMixin::drawFont(CFrame &frame, int x, int y, const char *text, const uint32_t color)
{
    static uint8_t caret[8]{
        0xff,
        0xff,
        0xff,
        0xff,
        0xff,
        0xff,
        0xff,
        0xff,
    };
    uint32_t *rgba = frame.getRGB();
    const int rowPixels = frame.len();
    const int fontSize = 8;
    const int fontOffset = fontSize;
    const int textSize = strlen(text);
    for (int i = 0; i < textSize; ++i)
    {
        uint8_t *font = nullptr;
        if (static_cast<uint8_t>(text[i]) == CARET)
        {
            font = caret;
        }
        else
        {
            const uint8_t c = static_cast<uint8_t>(text[i]) - ' ';
            font = m_fontData + c * fontOffset;
        }
        for (int yy = 0; yy < fontSize; ++yy)
        {
            uint8_t bitFilter = 1;
            for (int xx = 0; xx < fontSize; ++xx)
            {
                rgba[(yy + y) * rowPixels + xx + x] = font[yy] & bitFilter ? color : BLACK;
                bitFilter = bitFilter << 1;
            }
        }
        x += fontSize;
    }
}

void CGameMixin::drawRect(CFrame &frame, const Rect &rect, const uint32_t color, bool fill)
{
    uint32_t *rgba = frame.getRGB();
    const int rowPixels = frame.len();
    if (fill)
    {
        for (int y = 0; y < rect.height; y++)
        {
            for (int x = 0; x < rect.width; x++)
            {
                rgba[(rect.y + y) * rowPixels + rect.x + x] = color;
            }
        }
    }
    else
    {
        for (int y = 0; y < rect.height; y++)
        {
            for (int x = 0; x < rect.width; x++)
            {
                if (y == 0 || y == rect.height - 1 || x == 0 || x == rect.width - 1)
                {
                    rgba[(rect.y + y) * rowPixels + rect.x + x] = color;
                }
            }
        }
    }
}

void CGameMixin::drawTile(CFrame &bitmap, const int x, const int y, CFrame &tile, bool alpha)
{
    const uint32_t *tileData = tile.getRGB();
    uint32_t *dest = bitmap.getRGB() + x + y * WIDTH;
    if (alpha)
    {
        for (uint32_t row = 0; row < TILE_SIZE; ++row)
        {
            for (uint32_t col = 0; col < TILE_SIZE; ++col)
            {
                const uint32_t &rgba = tileData[col];
                if (rgba & ALPHA)
                {
                    dest[col] = rgba;
                }
            }
            dest += WIDTH;
            tileData += TILE_SIZE;
        }
    }
    else
    {

#ifdef ENVIRONMENT64
        uint64_t *d64 = reinterpret_cast<uint64_t *>(dest);
        const uint64_t *s64 = reinterpret_cast<const uint64_t *>(tileData);
        for (uint32_t row = 0; row < TILE_SIZE; ++row)
        {
            int i = 0;
            d64[i++] = *(s64++);
            d64[i++] = *(s64++);
            d64[i++] = *(s64++);
            d64[i++] = *(s64++);

            d64[i++] = *(s64++);
            d64[i++] = *(s64++);
            d64[i++] = *(s64++);
            d64[i++] = *(s64++);
            d64 += WIDTH / 2;
        }
#else
        for (uint32_t row = 0; row < TILE_SIZE; ++row)
        {
            int i = 0;

            dest[i++] = *(tileData++);
            dest[i++] = *(tileData++);
            dest[i++] = *(tileData++);
            dest[i++] = *(tileData++);

            dest[i++] = *(tileData++);
            dest[i++] = *(tileData++);
            dest[i++] = *(tileData++);
            dest[i++] = *(tileData++);

            dest[i++] = *(tileData++);
            dest[i++] = *(tileData++);
            dest[i++] = *(tileData++);
            dest[i++] = *(tileData++);

            dest[i++] = *(tileData++);
            dest[i++] = *(tileData++);
            dest[i++] = *(tileData++);
            dest[i++] = *(tileData++);
            dest += WIDTH;
        }
#endif
    }
}

void CGameMixin::drawKeys(CFrame &bitmap)
{
    CGame &game = *m_game;
    CFrameSet &tiles = *m_tiles;
    int y = HEIGHT - TILE_SIZE;
    int x = WIDTH - TILE_SIZE;
    const uint8_t *keys = game.keys();
    for (int i = 0; i < 6; ++i)
    {
        uint8_t k = keys[i];
        if (k)
        {
            drawTile(bitmap, x, y, *tiles[k], true);
            x -= TILE_SIZE;
        }
    }
}

void CGameMixin::drawScreen(CFrame &bitmap)
{
    enum
    {
        FLAG_UP_DOWN = 4,
        UP_OFFSET = 0,
        DOWN_OFFSET = 2,
        FILTER_ENV = 3, // WATER, LAVA, SLIME
        ENV_FRAMES = 3,
        FILTER_ATTR = 0xf8 // STOP 00 01 02 etc
    };

    CMap *map = &m_game->map();
    CGame &game = *m_game;

    const int maxRows = HEIGHT / TILE_SIZE;
    const int maxCols = WIDTH / TILE_SIZE;
    const int rows = std::min(maxRows, map->hei());
    const int cols = std::min(maxCols, map->len());

    const int lmx = std::max(0, game.player().x() - cols / 2);
    const int lmy = std::max(0, game.player().y() - rows / 2);
    const int mx = std::min(lmx, map->len() > cols ? map->len() - cols : 0);
    const int my = std::min(lmy, map->hei() > rows ? map->hei() - rows : 0);

    CFrameSet &tiles = *m_tiles;
    CFrameSet &animz = *m_animz;
    CFrameSet &annie = *m_annie;
    bitmap.fill(BLACK);

    uint8_t offset = m_animator->offset() & 1;
    for (int y = 0; y < rows; ++y)
    {
        for (int x = 0; x < cols; ++x)
        {
            const uint8_t tileID = map->at(x + mx, y + my);
            const auto &attr = map->getAttr(x, y);
            if (attr & FILTER_ENV)
            {
                // draw background
                auto bframe = ENV_FRAMES * ((attr & FILTER_ENV) - 1) +
                              ((attr & FLAG_UP_DOWN) ? DOWN_OFFSET : UP_OFFSET) +
                              offset;
                bitmap.drawAt(*(animz[bframe]), x * TILE_SIZE, y * TILE_SIZE, false);
            }
            if (tileID == TILES_STOP || tileID == TILES_BLANK)
            {
                // skip blank tiles
                continue;
            }
            // draw tile
            bitmap.drawAt(*(tiles[tileID]), x * TILE_SIZE, y * TILE_SIZE, true);
        }
    }

    // draw player
    const CActor &player = game.player();
    CFrame *tile = annie[player.aim() * 8 + m_playerFrameOffset];
    drawTile(bitmap,
             (player.x() - mx) * TILE_SIZE,
             (player.y() - my) * TILE_SIZE, *tile,
             true);

    // draw monsters
    CActor *monsters;
    int count;
    game.getMonsters(monsters, count);
    for (int i = 0; i < count; ++i)
    {
        const CActor &monster = monsters[i];
        if (monster.within(mx, my, mx + cols, my + rows))
        {
            // animations
            const int x = monster.x() - mx;
            const int y = monster.y() - my;
            CFrame *tile = animz[m_animator->at(monster.type())];
            drawTile(bitmap, x * TILE_SIZE, y * TILE_SIZE, *tile, true);
        }
    }

    // draw game status
    char tmp[32];
    if (m_paused)
    {
        drawFont(bitmap, 0, Y_STATUS, "PRESS [F4] TO RESUME PLAYING...", LIGHTGRAY);
    }
    else if (m_prompt == PROMPT_ERASE_SCORES)
    {
        drawFont(bitmap, 0, Y_STATUS, "ERASE HIGH SCORES, CONFIRM (Y/N)?", LIGHTGRAY);
    }
    else if (m_prompt == PROMPT_RESTART_GAME)
    {
        drawFont(bitmap, 0, Y_STATUS, "RESTART GAME, CONFIRM (Y/N)?", LIGHTGRAY);
    }
    else if (m_prompt == PROMPT_LOAD)
    {
        drawFont(bitmap, 0, Y_STATUS, "LOAD PREVIOUS SAVEGAME, CONFIRM (Y/N)?", LIGHTGRAY);
    }
    else if (m_prompt == PROMPT_SAVE)
    {
        drawFont(bitmap, 0, Y_STATUS, "SAVE GAME, CONFIRM (Y/N)?", LIGHTGRAY);
    }
    else if (m_prompt == PROMPT_HARDCORE)
    {
        drawFont(bitmap, 0, Y_STATUS, "HARDCORE MODE, CONFIRM (Y/N)?", LIGHTGRAY);
    }
    else if (m_prompt == PROMPT_TOGGLE_MUSIC)
    {
        drawFont(bitmap, 0, Y_STATUS,
                 m_musicMuted ? "PLAY MUSIC, CONFIRM (Y/N)?"
                              : "MUTE MUSIC, CONFIRM (Y/N)?",
                 LIGHTGRAY);
    }
    else
    {
        int tx;
        int bx = 0;
        tx = sprintf(tmp, "%.8d ", game.score());
        drawFont(bitmap, 0, Y_STATUS, tmp, WHITE);
        bx += tx;
        tx = sprintf(tmp, "DIAMONDS %.2d ", game.goals());
        drawFont(bitmap, bx * FONT_SIZE, Y_STATUS, tmp, YELLOW);
        bx += tx;
        sprintf(tmp, "LIVES %.2d ", game.lives());
        drawFont(bitmap, bx * FONT_SIZE, Y_STATUS, tmp, PURPLE);
    }

    // draw bottom rect
    drawRect(bitmap, Rect{0, bitmap.hei() - 16, WIDTH, TILE_SIZE}, DARKGRAY, true);
    drawRect(bitmap, Rect{0, bitmap.hei() - 16, WIDTH, TILE_SIZE}, LIGHTGRAY, false);

    // draw health bar
    drawRect(bitmap, Rect{4, bitmap.hei() - 12, std::min(game.health() / 2, bitmap.len() - 4), 8},
             game.godModeTimer() ? WHITE : LIME, true);
    drawRect(bitmap, Rect{4, bitmap.hei() - 12, std::min(game.health() / 2, bitmap.len() - 4), 8},
             WHITE, false);

    // draw keys
    drawKeys(bitmap);
}

void CGameMixin::drawLevelIntro(CFrame &bitmap)
{
    char t[32];
    switch (m_game->mode())
    {
    case CGame::MODE_INTRO:
        sprintf(t, "LEVEL %.2d", m_game->level() + 1);
        break;
    case CGame::MODE_RESTART:
        if (m_game->lives() > 1)
        {
            sprintf(t, "LIVES LEFT %.2d", m_game->lives());
        }
        else
        {
            strcpy(t, "LAST LIFE !");
        }
        break;
    case CGame::MODE_GAMEOVER:
        strcpy(t, "GAME OVER");
    };

    int x = (WIDTH - strlen(t) * FONT_SIZE) / 2;
    int y = (HEIGHT - FONT_SIZE) / 2;
    bitmap.fill(BLACK);
    drawFont(bitmap, x, y, t, WHITE);
}

void CGameMixin::mainLoop()
{
    ++m_ticks;
    CGame &game = *m_game;
    if (game.mode() != CGame::MODE_CLICKSTART &&
        m_countdown > 0)
    {
        --m_countdown;
    }

    switch (game.mode())
    {
    case CGame::MODE_HISCORES:
        if (m_recordScore && inputPlayerName())
        {
            m_recordScore = false;
            saveScores();
        }
    case CGame::MODE_INTRO:
    case CGame::MODE_RESTART:
    case CGame::MODE_GAMEOVER:
        if (m_countdown)
        {
            return;
        }
        if (game.mode() == CGame::MODE_GAMEOVER)
        {
            if (!m_hiscoreEnabled)
            {
                restartGame();
                return;
            }

            game.setMode(CGame::MODE_HISCORES);
            if (!m_scoresLoaded)
            {
                m_scoresLoaded = loadScores();
            }
            m_scoreRank = rankScore();
            m_recordScore = m_scoreRank != INVALID;
            m_countdown = HISCORE_DELAY;
            return;
        }
        else if (game.mode() == CGame::MODE_HISCORES)
        {
            if (!m_recordScore)
            {
                restartGame();
            }
            return;
        }
        else
        {
            game.setMode(CGame::MODE_LEVEL);
        }
        break;
    case CGame::MODE_IDLE:
    case CGame::MODE_CLICKSTART:
        return;
    case CGame::MODE_HELP:
        if (!m_keyStates[Key_F1])
        {
            // keyup
            m_keyRepeters[Key_F1] = 0;
        }
        else if (m_keyRepeters[Key_F1])
        {
            // avoid keys repeating
            return;
        }
        else
        {
            m_game->setMode(CGame::MODE_LEVEL);
            m_keyRepeters[Key_F1] = 1;
        }
        return;
    }

    manageGamePlay();
}

void CGameMixin::manageGamePlay()
{
    CGame &game = *m_game;
    if (!m_paused && handlePrompts())
    {
        return;
    }

    handleFunctionKeys();
    if (m_paused)
    {
        return;
    }

    if (m_ticks % game.playerSpeed() == 0 && !game.isPlayerDead())
    {
        game.managePlayer(m_joyState);
    }

    if (m_ticks % 3 == 0)
    {
        if (game.health() < m_healthRef && m_playerFrameOffset != 7)
        {
            m_playerFrameOffset = 7;
        }
        else if (*(reinterpret_cast<uint32_t *>(m_joyState)))
        {
            m_playerFrameOffset = (m_playerFrameOffset + 1) % 7;
        }
        else
        {
            m_playerFrameOffset = 0;
        }
        m_healthRef = game.health();
        m_animator->animate();
    }

    game.manageMonsters(m_ticks);

    if (game.isPlayerDead())
    {
        game.killPlayer();

        if (!game.isGameOver())
        {
            restartLevel();
        }
        else
        {
            startCountdown(COUNTDOWN_INTRO);
            game.setMode(CGame::MODE_GAMEOVER);
        }
    }

    if (!game.isGameOver())
    {
        if (game.goals() == 0)
        {
            nextLevel();
        }
    }
}

void CGameMixin::nextLevel()
{
    m_healthRef = 0;
    m_game->nextLevel();
    sanityTest();
    startCountdown(COUNTDOWN_INTRO);
    m_game->loadLevel(false);
}

void CGameMixin::restartLevel()
{
    startCountdown(COUNTDOWN_INTRO);
    m_game->loadLevel(true);
}

void CGameMixin::restartGame()
{
    m_paused = false;
    startCountdown(COUNTDOWN_RESTART);
    m_game->restartGame();
    sanityTest();
    m_game->loadLevel(false);
}

void CGameMixin::startCountdown(int f)
{
    m_countdown = f * INTRO_DELAY;
}

void CGameMixin::init(const std::string &maparch, const int index)
{
    if (!m_assetPreloaded)
    {
        preloadAssets();
        m_assetPreloaded = true;
    }
    if (!m_game->setMapArch(maparch))
    {
        printf("failed to extract index from maparch: %s\n", maparch.c_str());
        return;
    }
    m_game->setLevel(index);
    // sanityTest();
    m_countdown = INTRO_DELAY;
    m_game->loadLevel(false);
}

void CGameMixin::changeZoom()
{
    setZoom(!m_zoom);
}

void CGameMixin::setZoom(bool zoom)
{
    m_zoom = zoom;
}

bool CGameMixin::within(int val, int min, int max)
{
    return val >= min && val <= max;
}

void CGameMixin::sanityTest()
{
    // TODO: sanityTest() to be implemented in child class
}

int CGameMixin::rankScore()
{
    int score = m_game->score();
    if (score <= m_hiscores[MAX_SCORES - 1].score)
    {
        return INVALID;
    }

    uint32_t i;
    for (i = 0; i < MAX_SCORES; ++i)
    {
        if (score > m_hiscores[i].score)
        {
            break;
        }
    }

    for (uint32_t j = MAX_SCORES - 2; j >= i; --j)
    {
        m_hiscores[j + 1] = m_hiscores[j];
    }

    m_hiscores[i].score = m_game->score();
    m_hiscores[i].level = m_game->level() + 1;
    memset(m_hiscores[i].name, 0, sizeof(m_hiscores[i].name));
    return i;
}

void CGameMixin::drawScores(CFrame &bitmap)
{
    bitmap.fill(BLACK);
    char t[50];
    int y = 1;
    strcpy(t, "HALL OF HEROES");
    int x = (WIDTH - strlen(t) * FONT_SIZE) / 2;
    drawFont(bitmap, x, y * FONT_SIZE, t, WHITE);
    ++y;
    strcpy(t, std::string(strlen(t), '=').c_str());
    x = (WIDTH - strlen(t) * FONT_SIZE) / 2;
    drawFont(bitmap, x, y * FONT_SIZE, t, WHITE);
    y += 2;

    for (uint32_t i = 0; i < MAX_SCORES; ++i)
    {
        uint32_t color = i & INTERLINES ? CYAN : BLUE;
        if (m_recordScore && m_scoreRank == i)
        {
            color = YELLOW;
        }
        bool showCaret = (color == YELLOW) && (m_ticks & CARET_SPEED);
        sprintf(t, " %.8d %.2d %s%c",
                m_hiscores[i].score,
                m_hiscores[i].level,
                m_hiscores[i].name,
                showCaret ? CARET : '\0');
        drawFont(bitmap, 1, y * FONT_SIZE, t, color);
        ++y;
    }

    ++y;
    if (m_scoreRank == INVALID)
    {
        strcpy(t, " SORRY, YOU DIDN'T QUALIFY.");
        drawFont(bitmap, 0, y * FONT_SIZE, t, YELLOW);
    }
    else if (m_recordScore)
    {
        strcpy(t, "PLEASE TYPE YOUR NAME AND PRESS ENTER.");
        x = (WIDTH - strlen(t) * FONT_SIZE) / 2;
        drawFont(bitmap, x, y++ * FONT_SIZE, t, YELLOW);
    }
}

void CGameMixin::drawHelpScreen(CFrame &bitmap)
{
    bitmap.fill(BLACK);
    const char *helptext[]{
        "",
        "!HELP",
        "!====",
        "",
        "Use cursor keys to move.",
        "",
        "Collect all the diamonds to move to the",
        "next level. Avoid monsters and other",
        "hazards.",
        "",
        "Pick up objects to open up secret",
        "passages.",
        "",
        "F1 Help",
        "F2 Restart Game",
        "F3 Erase Scores",
        "F4 Pause Game",
        "F9 Load savegame",
        "F10 Save savegame ",
        "F11 Toggle Music",
        "F12 Harcore Mode",
        "",
        "~PRESS [F1] AGAIN TO RETURN TO THE GAME.",
    };

    char t[50];
    int y = 0;

    for (size_t i = 0; i < sizeof(helptext) / sizeof(helptext[0]); ++i)
    {
        strcpy(t, helptext[i]);
        char *p = t;
        int x = 0;
        auto color = WHITE;
        if (p[0] == '~')
        {
            ++p;
            color = YELLOW;
        }
        else if (p[0] == '!')
        {
            ++p;
            x = (WIDTH - strlen(p) * FONT_SIZE) / 2;
        }
        drawFont(bitmap, x, y * FONT_SIZE, p, color);
        ++y;
    }
}

bool CGameMixin::handlePrompts()
{
    auto result = m_prompt != PROMPT_NONE;
    if (m_prompt != PROMPT_NONE && m_keyStates[Key_N])
    {
        m_prompt = PROMPT_NONE;
    }
    else if (m_keyStates[Key_Y])
    {
        if (m_prompt == PROMPT_ERASE_SCORES)
        {
            clearScores();
            saveScores();
        }
        else if (m_prompt == PROMPT_RESTART_GAME)
        {
            restartGame();
        }
        else if (m_prompt == PROMPT_LOAD)
        {
            load();
        }
        else if (m_prompt == PROMPT_SAVE)
        {
            save();
        }
        else if (m_prompt == PROMPT_HARDCORE)
        {
            m_game->setLives(1);
        }
        else if (m_prompt == PROMPT_TOGGLE_MUSIC)
        {
            m_musicMuted ? startMusic() : stopMusic();
            m_musicMuted = !m_musicMuted;
        }
        m_prompt = PROMPT_NONE;
    }
    return result;
}

void CGameMixin::handleFunctionKeys()
{
    for (int k = Key_F1; k <= Key_F12; ++k)
    {
        if (!m_keyStates[k])
        {
            // keyup
            m_keyRepeters[k] = 0;
            continue;
        }
        else if (m_keyRepeters[k])
        {
            // avoid keys repeating
            continue;
        }
        if (m_paused && k != Key_F4)
        {
            // don't handle any other
            // hotkeys while paused
            continue;
        }

        switch (k)
        {
        case Key_F1:
            m_game->setMode(CGame::MODE_HELP);
            m_keyRepeters[k] = KEY_NO_REPETE;
            break;
        case Key_F2: // restart game
            m_prompt = PROMPT_RESTART_GAME;
            break;
        case Key_F3: // erase scores
            m_prompt = PROMPT_ERASE_SCORES;
            break;
        case Key_F4:
            m_paused = !m_paused;
            m_keyRepeters[k] = KEY_NO_REPETE;
            break;
        case Key_F9:
            m_prompt = PROMPT_LOAD;
            break;
        case Key_F10:
            m_prompt = PROMPT_SAVE;
            break;
        case Key_F11:
            m_prompt = PROMPT_TOGGLE_MUSIC;
            break;
        case Key_F12:
            m_prompt = PROMPT_HARDCORE;
        }
    }
}

bool CGameMixin::inputPlayerName()
{
    auto range = [](uint16_t keyCode, uint16_t start, uint16_t end)
    {
        return keyCode >= start && keyCode <= end;
    };

    int j = m_scoreRank;
    for (int k = 0; k < Key_Count; ++k)
    {
        m_keyRepeters[k] ? --m_keyRepeters[k] : 0;
    }

    for (int k = 0; k < Key_Count; ++k)
    {
        if (!m_keyStates[k])
        {
            m_keyRepeters[k] = 0;
            continue;
        }
        else if (m_keyRepeters[k])
        {
            continue;
        }
        char c = 0;
        if (range(k, Key_0, Key_9))
        {
            c = k + '0' - Key_0;
        }
        else if (range(k, Key_A, Key_Z))
        {
            c = k + 'A' - Key_A;
        }
        else if (k == Key_Space)
        {
            c = k + ' ' - Key_Space;
        }
        else if (k == Key_BackSpace)
        {
            m_keyRepeters[k] = KEY_REPETE_DELAY;
            int i = strlen(m_hiscores[j].name);
            if (i > 0)
            {
                m_hiscores[j].name[i - 1] = '\0';
            }
            continue;
        }
        else if (k == Key_Enter)
        {
            return true;
        }
        else
        {
            // don't handle any other keys
            m_keyRepeters[k] = 0;
            continue;
        }
        if (strlen(m_hiscores[j].name) == sizeof(m_hiscores[j].name) - 1)
        {
            // already at maxlenght
            continue;
        }
        m_keyRepeters[k] = KEY_REPETE_DELAY;
        char s[2] = {c, 0};
        strcat(m_hiscores[j].name, s);
    }
    return false;
}

bool CGameMixin::loadScores()
{
    return true;
}

bool CGameMixin::saveScores()
{
    return true;
}

void CGameMixin::enableHiScore()
{
    m_hiscoreEnabled = true;
}

void CGameMixin::clearScores()
{
    memset(m_hiscores, 0, sizeof(m_hiscores));
}

void CGameMixin::clearKeyStates()
{
    memset(m_keyStates, 0, sizeof(m_keyStates));
    memset(m_keyRepeters, 0, sizeof(m_keyRepeters));
}

void CGameMixin::clearJoyStates()
{
    memset(m_joyState, 0, sizeof(m_joyState));
}

bool CGameMixin::read(FILE *sfile, std::string &name)
{
    auto readfile = [sfile](auto ptr, auto size)
    {
        return fread(ptr, size, 1, sfile) == 1;
    };
    if (!m_game->read(sfile))
    {
        return false;
    }
    clearJoyStates();
    clearKeyStates();
    m_paused = false;
    m_prompt = PROMPT_NONE;
    readfile(&m_ticks, sizeof(m_ticks));
    readfile(&m_playerFrameOffset, sizeof(m_playerFrameOffset));
    readfile(&m_healthRef, sizeof(m_healthRef));
    readfile(&m_countdown, sizeof(m_countdown));

    size_t ptr = 0;
    fseek(sfile, SAVENAME_PTR_OFFSET, SEEK_SET);
    readfile(&ptr, sizeof(uint32_t));
    fseek(sfile, ptr, SEEK_SET);
    size_t size = 0;
    readfile(&size, sizeof(uint16_t));
    char *tmp = new char[size];
    readfile(tmp, size);
    name = tmp;
    delete[] tmp;
    return true;
}

bool CGameMixin::write(FILE *tfile, std::string &name)
{
    auto writefile = [tfile](auto ptr, auto size)
    {
        return fwrite(ptr, size, 1, tfile) == 1;
    };
    m_game->write(tfile);
    writefile(&m_ticks, sizeof(m_ticks));
    writefile(&m_playerFrameOffset, sizeof(m_playerFrameOffset));
    writefile(&m_healthRef, sizeof(m_healthRef));
    writefile(&m_countdown, sizeof(m_countdown));

    size_t ptr = ftell(tfile);
    size_t size = name.size();
    writefile(&size, sizeof(uint16_t));
    writefile(name.c_str(), name.size());
    fseek(tfile, SAVENAME_PTR_OFFSET, SEEK_SET);
    writefile(&ptr, sizeof(uint32_t));
    return true;
}

void CGameMixin::drawPreScreen(CFrame &bitmap)
{
    const char t[] = "CLICK TO START";
    int x = (WIDTH - strlen(t) * FONT_SIZE) / 2;
    int y = (HEIGHT - FONT_SIZE) / 2;
    bitmap.fill(BLACK);
    drawFont(bitmap, x, y, t, WHITE);
}

void CGameMixin::stopMusic()
{
    // TODO: implement in child class
}

void CGameMixin::startMusic()
{
    // TODO: implement in child class
}
