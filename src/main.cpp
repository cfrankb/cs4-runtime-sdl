#include <algorithm>
#include <unistd.h>
#include <stdio.h>
#include "runtime.h"
#include "maparch.h"

#define FPS 24
#define SLEEP 1000 / FPS
// #define TEST_SPEED

#ifdef __EMSCRIPTEN__
#include <emscripten.h>
CRuntime *g_runtime = nullptr;
extern "C"
{
    int savegame(int x)
    {
        /// printf("savegame: %d\n", x);
        if (x == 0)
        {
            g_runtime->load();
        }
        else
        {
            g_runtime->save();
        }
        return 0;
    }

    int mute(int x)
    {
        if (x == 0)
        {
            g_runtime->stopMusic();
        }
        else
        {
            g_runtime->startMusic();
        }
        return 0;
    }
}
#endif

void loop_handler(void *arg)
{
    static int cycle = 0;
    CRuntime *runtime = reinterpret_cast<CRuntime *>(arg);
    uint32_t bticks = SDL_GetTicks();
    if (cycle == 0)
    {
        runtime->paint();
    }
    runtime->doInput();
    runtime->run();
    uint32_t aticks = SDL_GetTicks();
    int64_t diff = aticks - bticks;
    if (diff > SLEEP && cycle == 0)
    {
        ++cycle;
    }
    else if (diff <= SLEEP)
    {
        if (cycle)
            --cycle;
        usleep((SLEEP - diff) * 1000);
    }
    else
    {
        usleep(SLEEP * 1000);
    }

#ifdef TEST_SPEED
    printf("time %d %d %d\n", aticks - bticks, bticks, aticks);
#endif
}

int main(int argc, char *args[])
{
    CRuntime runtime;
    CMapArch maparch;

    runtime.init("data/levels.mapz-cs4", 0);
    runtime.enableHiScore();
    runtime.enableMusic();
    runtime.SDLInit();
    runtime.preRun();
    runtime.paint();
#ifdef __EMSCRIPTEN__
    g_runtime = &runtime;
    emscripten_set_main_loop_arg(loop_handler, &runtime, -1, 1);
// emscripten_set_main_loop_timing(EM_TIMING_SETTIMEOUT, 1000/FPS*1000);
#else
    while (true)
    {
        loop_handler(&runtime);
    }
#endif
    return 0;
}
