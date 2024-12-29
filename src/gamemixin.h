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
#ifndef CGAMEMIXIN_H
#define CGAMEMIXIN_H

#ifdef USE_QFILE
#include <QTimer>
#endif
#include <cstdint>
#include <cstdio>
#include <string>

class CFrameSet;
class CGame;
class CFrame;
class CMapArch;
class CAnimator;
class IMusic;

class CGameMixin
{
public:
    explicit CGameMixin();
    virtual ~CGameMixin();
    void init(const std::string &maparch, const int index);
    inline bool within(int val, int min, int max);
    void enableHiScore();

#ifdef USE_QFILE
protected slots:
#endif
    virtual void mainLoop();
    void changeZoom();
    virtual void save() {};
    virtual void load() {};

protected:
    enum : uint32_t
    {
        TICK_RATE = 24,
        NO_ANIMZ = 255,
        KEY_PRESSED = 1,
        KEY_RELEASED = 0,
        INTRO_DELAY = TICK_RATE,
        HISCORE_DELAY = 5 * TICK_RATE,
        ALPHA = 0xff000000,
        WHITE = 0x00ffffff | ALPHA,
        YELLOW = 0x0000ffff | ALPHA,
        PURPLE = 0x00ff00ff | ALPHA,
        BLACK = 0x00000000 | ALPHA,
        GREEN = 0x0000ff00 | ALPHA,
        LIME = 0x0000ffbf | ALPHA,
        BLUE = 0x00ff0000 | ALPHA,
        CYAN = 0x00ffff00 | ALPHA,
        DARKBLUE = 0x00440000 | ALPHA,
        DARKGRAY = 0x00444444 | ALPHA,
        LIGHTGRAY = 0x00A9A9A9 | ALPHA,
        WIDTH = 320,
        HEIGHT = 240,
        TILE_SIZE = 16,
        COUNTDOWN_INTRO = 1,
        COUNTDOWN_RESTART = 2,
        FONT_SIZE = 8,
        MAX_SCORES = 18,
        CARET = 0xff,
        KEY_REPETE_DELAY = 5,
        KEY_NO_REPETE = 1,
        MAX_NAME_LENGTH = 16,
        SAVENAME_PTR_OFFSET = 8,
        CARET_SPEED = 8,
        INTERLINES = 2,
        Y_STATUS = 2,
    };

    enum KeyCode : uint8_t
    {
        Key_A,
        Key_N = Key_A + 13,
        Key_Y = Key_A + 24,
        Key_Z = Key_A + 25,
        Key_Space,
        Key_0,
        Key_9 = Key_0 + 9,
        Key_BackSpace,
        Key_Enter,
        Key_F1,
        Key_F2,
        Key_F3,
        Key_F4,
        Key_F5,
        Key_F6,
        Key_F7,
        Key_F8,
        Key_F9,
        Key_F10,
        Key_F11,
        Key_F12,
        Key_Count
    };

    enum
    {
        PROMPT_NONE,
        PROMPT_ERASE_SCORES,
        PROMPT_RESTART_GAME,
        PROMPT_LOAD,
        PROMPT_SAVE,
        PROMPT_RESTART_LEVEL,
        PROMPT_HARDCORE,
        PROMPT_TOGGLE_MUSIC
    };

    enum
    {
        INVALID = -1,
    };

    enum
    {
        AIM_UP,
        AIM_DOWN,
        AIM_LEFT,
        AIM_RIGHT,
        ButtonCount
    };

    uint8_t m_keyStates[Key_Count];
    uint8_t m_keyRepeters[Key_Count];

    using Rect = struct
    {
        int x;
        int y;
        int width;
        int height;
    };

    using hiscore_t = struct
    {
        int score;
        int level;
        char name[MAX_NAME_LENGTH];
    };

    hiscore_t m_hiscores[MAX_SCORES];
    uint8_t m_joyState[ButtonCount];
    uint32_t m_ticks = 0;
    CAnimator *m_animator = nullptr;
    CFrameSet *m_tiles = nullptr;
    CFrameSet *m_animz = nullptr;
    CFrameSet *m_annie = nullptr;
    uint8_t *m_fontData = nullptr;
    CGame *m_game = nullptr;
    CMapArch *m_maparch = nullptr;
    int m_playerFrameOffset = 0;
    int m_healthRef = 0;
    int m_countdown = 0;
    int m_scoreRank = INVALID;
    bool m_recordScore = false;
    bool m_zoom = false;
    bool m_assetPreloaded = false;
    bool m_scoresLoaded = false;
    bool m_hiscoreEnabled = false;
    bool m_paused = false;
    bool m_musicMuted = false;
    int m_prompt = PROMPT_NONE;
    void drawPreScreen(CFrame &bitmap);
    void drawScreen(CFrame &bitmap);
    void drawLevelIntro(CFrame &bitmap);
    virtual void preloadAssets();
    void drawFont(CFrame &frame, int x, int y, const char *text, const uint32_t color = WHITE);
    inline void drawRect(CFrame &frame, const Rect &rect, const uint32_t color = GREEN, bool fill = true);
    inline void drawKeys(CFrame &bitmap);
    inline void drawTile(CFrame &frame, const int x, const int y, CFrame &tile, bool alpha);
    void nextLevel();
    void restartLevel();
    void restartGame();
    virtual void sanityTest();
    void startCountdown(int f = 1);
    int rankScore();
    void drawScores(CFrame &bitmap);
    bool inputPlayerName();
    void clearScores();
    void clearKeyStates();
    void clearJoyStates();
    void manageGamePlay();
    void handleFunctionKeys();
    bool handlePrompts();
    virtual void drawHelpScreen(CFrame &bitmap);
    virtual bool loadScores();
    virtual bool saveScores();
    virtual bool read(FILE *sfile, std::string &name);
    virtual bool write(FILE *tfile, std::string &name);
    virtual void stopMusic();
    virtual void startMusic();
    virtual void setZoom(bool zoom);
};

#endif // CGAMEMIXIN_H
