#include "shared/FileWrap.h"
#include "shared/FrameSet.h"
#include "shared/Frame.h"
#include "maparch.h"
#include "map.h"
#include <cstdio>
#include <cstring>

#define EXIT_SUCCESS 0
#define EXIT_FAILURE 1
#define FILE_OFFSET 7
#define TILE_SIZE 16
#define TILE_BYTES (TILE_SIZE * TILE_SIZE)
#define MAIN_ARCH_FILE "data/levels.mapz-cs4"
#define CS4_TILES "data/cs4tiles.obl"
#define CS4_EDIT "data/cs4edit.obl"
#define CS4_ANIMZ "data/cs4animz.obl"
#define CS4_NUM "data/cs4num.obl"

// original color palette
const uint32_t g_palette[] = {
    0x00000000, 0xffab0303, 0xff03ab03, 0xffabab03, 0xff0303ab, 0xffab03ab, 0xff0357ab, 0xffababab,
    0xff575757, 0xffff5757, 0xff57ff57, 0xffffff57, 0xff5757ff, 0xffff57ff, 0xff57ffff, 0xffffffff,
    0xff000000, 0xff171717, 0xff232323, 0xff2f2f2f, 0xff3b3b3b, 0xff474747, 0xff535353, 0xff636363,
    0xff737373, 0xff838383, 0xff939393, 0xffa3a3a3, 0xffb7b7b7, 0xffcbcbcb, 0xffe3e3e3, 0xffffffff,
    0xffff0303, 0xffff0343, 0xffff037f, 0xffff03bf, 0xffff03ff, 0xffbf03ff, 0xff7f03ff, 0xff4303ff,
    0xff0303ff, 0xff0343ff, 0xff037fff, 0xff03bfff, 0xff03ffff, 0xff03ffbf, 0xff03ff7f, 0xff03ff43,
    0xff03ff03, 0xff43ff03, 0xff7fff03, 0xffbfff03, 0xffffff03, 0xffffbf03, 0xffff7f03, 0xffff4303,
    0xffff7f7f, 0xffff7f9f, 0xffff7fbf, 0xffff7fdf, 0xffff7fff, 0xffdf7fff, 0xffbf7fff, 0xff9f7fff,
    0xff7f7fff, 0xff7f9fff, 0xff7fbfff, 0xff7fdfff, 0xff7fffff, 0xff7fffdf, 0xff7fffbf, 0xff7fff9f,
    0xff7fff7f, 0xff9fff7f, 0xffbfff7f, 0xffdfff7f, 0xffffff7f, 0xffffdf7f, 0xffffbf7f, 0xffff9f7f,
    0xffffb7b7, 0xffffb7c7, 0xffffb7db, 0xffffb7eb, 0xffffb7ff, 0xffebb7ff, 0xffdbb7ff, 0xffc7b7ff,
    0xffb7b7ff, 0xffb7c7ff, 0xffb7dbff, 0xffb7ebff, 0xffb7ffff, 0xffb7ffeb, 0xffb7ffdb, 0xffb7ffc7,
    0xffb7ffb7, 0xffc7ffb7, 0xffdbffb7, 0xffebffb7, 0xffffffb7, 0xffffebb7, 0xffffdbb7, 0xffffc7b7,
    0xff730303, 0xff73031f, 0xff73033b, 0xff730357, 0xff730373, 0xff570373, 0xff3b0373, 0xff1f0373,
    0xff030373, 0xff031f73, 0xff033b73, 0xff035773, 0xff037373, 0xff037357, 0xff03733b, 0xff03731f,
    0xff037303, 0xff1f7303, 0xff3b7303, 0xff577303, 0xff737303, 0xff735703, 0xff733b03, 0xff731f03,
    0xff733b3b, 0xff733b47, 0xff733b57, 0xff733b63, 0xff733b73, 0xff633b73, 0xff573b73, 0xff473b73,
    0xff3b3b73, 0xff3b4773, 0xff3b5773, 0xff3b6373, 0xff3b7373, 0xff3b7363, 0xff3b7357, 0xff3b7347,
    0xff3b733b, 0xff47733b, 0xff57733b, 0xff63733b, 0xff73733b, 0xff73633b, 0xff73573b, 0xff73473b,
    0xff735353, 0xff73535b, 0xff735363, 0xff73536b, 0xff735373, 0xff6b5373, 0xff635373, 0xff5b5373,
    0xff535373, 0xff535b73, 0xff536373, 0xff536b73, 0xff537373, 0xff53736b, 0xff537363, 0xff53735b,
    0xff537353, 0xff5b7353, 0xff637353, 0xff6b7353, 0xff737353, 0xff736b53, 0xff736353, 0xff735b53,
    0xff430303, 0xff430313, 0xff430323, 0xff430333, 0xff430343, 0xff330343, 0xff230343, 0xff130343,
    0xff030343, 0xff031343, 0xff032343, 0xff033343, 0xff034343, 0xff034333, 0xff034323, 0xff034313,
    0xff034303, 0xff134303, 0xff234303, 0xff334303, 0xff434303, 0xff433303, 0xff432303, 0xff431303,
    0xff432323, 0xff43232b, 0xff432333, 0xff43233b, 0xff432343, 0xff3b2343, 0xff332343, 0xff2b2343,
    0xff232343, 0xff232b43, 0xff233343, 0xff233b43, 0xff234343, 0xff23433b, 0xff234333, 0xff23432b,
    0xff234323, 0xff2b4323, 0xff334323, 0xff3b4323, 0xff434323, 0xff433b23, 0xff433323, 0xff432b23,
    0xff432f2f, 0xff432f33, 0xff432f37, 0xff432f3f, 0xff432f43, 0xff3f2f43, 0xff372f43, 0xff332f43,
    0xff2f2f43, 0xff2f3343, 0xff2f3743, 0xff2f3f43, 0xff2f4343, 0xff2f433f, 0xff2f4337, 0xff2f4333,
    0xff2f432f, 0xff33432f, 0xff37432f, 0xff3f432f, 0xff43432f, 0xff433f2f, 0xff43372f, 0xff43332f,
    0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000};

struct leveldef_t
{
    const char *fname;
    const char *name;
};

const leveldef_t g_files[] = {
    {"lee01.cs4", "grab the diamonds_ ha! ha! ha!ha!"},
    {"lee02.cs4", "figure out which one you must pull."},
    {"lee03.cs4", "even andrea can win this one."},
    {"lee04.cs4", "they are ugly people like julie jean."},
    {"lea01.cs4", "sonia has pulled a fast one."},
    {"lea02.cs4", "the pumpkin collector is here."},
    {"lea03.cs4", "learning how to jump is easy."},
    {"lea04.cs4", "you must learn about electricity."},
    {"lea05.cs4", "don't let them catch up."},
    {"lev01.cs4", "The inner level is here"},
    {"lev02.cs4", "don't go for the expected."},
    {"lev03.cs4", "watch your back _"},
    {"lev04.cs4", "the towers of death."},
    {"lev05.cs4", "This one will look easy_"},
};

bool generateScreenshots()
{
    struct obl5data_t
    {
        CFrameSet frameSet;
        const char *filename;
    };

    obl5data_t g_frameSets[] = {
        {CFrameSet(), "data/cs4animz.obl"},
        {CFrameSet(), "data/cs4edit.obl"},
        {CFrameSet(), "data/cs4num.obl"},
        {CFrameSet(), "data/cs4tiles.obl"},
    };

    enum
    {
        SET_ANIMZ,
        SET_EDIT,
        SET_NUM,
        SET_TILES,
        SET_COUNT
    };

    const uint16_t mapLen = 128;
    const uint16_t mapHei = 64;
    CMapArch arch;
    const size_t count = sizeof(g_files) / sizeof(leveldef_t);

    // read index from archfile
    IndexVector index;
    if (!CMapArch::indexFromFile(MAIN_ARCH_FILE, index))
    {
        printf("can't read arch index\n");
        return false;
    }

    // read framesets
    CFileWrap file;
    for (int i = 0; i < SET_COUNT; ++i)
    {
        auto &set = g_frameSets[i];
        if (!file.open(set.filename))
        {
            printf("failed to open %s\n", set.filename);
            return false;
        }
        set.frameSet.read(file);
        file.close();
    }

    if (!file.open(MAIN_ARCH_FILE))
    {
        printf("failed to open archfile\n");
        return false;
    }

    CMap map;
    for (int i = 0; i < count; ++i)
    {
        // readmap
        file.seek(index[i]);
        map.read(file);

        char tmp[16];
        strcpy(tmp, g_files[i].fname);
        char *p = strstr(tmp, ".");
        if (p != nullptr)
        {
            *p = 0;
        }

        char target[128];
        sprintf(target, "techdocs/images/%s.png", tmp);
        CFrame frame(mapLen * TILE_SIZE, mapHei * TILE_SIZE);
        frame.fill(0xff000000);

        enum
        {
            FLAG_UP_DOWN = 4,
            UP_OFFSET = 0,
            DOWN_OFFSET = 2,
            FILTER_ENV = 3, // WATER, LAVA, SLIM
            ENV_FRAMES = 3,
            FILTER_ATTR = 0xf8 // STOP 00 01 02 etc
        };

        for (int y = 0; y < mapHei; ++y)
        {
            for (int x = 0; x < mapLen; ++x)
            {
                const auto &tile = map.at(x, y);
                const auto &attr = map.getAttr(x, y);
                if (attr & 0x80)
                {
                    printf("%s (%d %d) %.2x\n", tmp, x, y, attr);
                }
                if (attr & FILTER_ENV)
                {
                    auto bframe = ENV_FRAMES * ((attr & FILTER_ENV) - 1) + ((attr & FLAG_UP_DOWN) ? DOWN_OFFSET : UP_OFFSET);
                    frame.drawAt(*(g_frameSets[SET_ANIMZ].frameSet[bframe]), x * TILE_SIZE, y * TILE_SIZE, true);
                }
                frame.drawAt(*(g_frameSets[SET_EDIT].frameSet[tile]), x * TILE_SIZE, y * TILE_SIZE, true);
                if (attr & FILTER_ATTR)
                {
                    auto num = (attr >> 3) & 0x1f;
                    frame.drawAt(*(g_frameSets[SET_NUM].frameSet[num]), x * TILE_SIZE, y * TILE_SIZE, true);
                }
            }
        }
        CFileWrap tfile;
        if (!tfile.open(target, "wb"))
        {
            printf("can't write %s\n", target);
            return false;
        }
        uint8_t *png;
        int size;
        frame.toPng(png, size);
        tfile.write(png, size);
        delete[] png;
        tfile.close();
    }

    file.close();
    return true;
}

bool createArchive()
{
    const uint16_t mapLen = 128;
    const uint16_t mapHei = 64;

    CMapArch arch;
    const size_t count = sizeof(g_files) / sizeof(leveldef_t);

    uint32_t index[count];
    uint8_t *mapData = new uint8_t[mapLen * mapHei];

    for (int i = 0; i < count; ++i)
    {
        CMap *map = new CMap(mapLen, mapHei);

        CFileWrap sfile;
        const char *fname = g_files[i].fname;
        std::string path = std::string("techdocs/data/") + g_files[i].fname;
        map->setTitle(g_files[i].name);

        if (!sfile.open(path.c_str()))
        {
            printf("can't read file: %s\n", path.c_str());
            return EXIT_FAILURE;
        }
        sfile.read(map->data(), mapLen * mapHei);
        sfile.read(mapData, mapLen * mapHei);

        for (int y = 0; y < mapHei; ++y)
        {
            uint8_t *linePtr = mapData + y * mapLen;
            for (int x = 0; x < mapLen; ++x)
            {
                const auto &c = linePtr[x];
                if (c)
                {
                    map->setAttr(x, y, c);
                }
            }
        }
        arch.add(map);
    }

    delete[] mapData;
    arch.write(MAIN_ARCH_FILE);

    return true;
}

bool convert(const char *src, const char *dest)
{
    CFrameSet fs;

    CFileWrap sfile;
    if (!sfile.open(src))
    {
        printf("can't read file: %s\n", src);
        return EXIT_FAILURE;
    }

    CFileWrap tfile;
    if (!tfile.open(dest, "wb"))
    {
        printf("can't write file: %s\n", dest);
        return EXIT_FAILURE;
    }

    size_t size = sfile.getSize() - FILE_OFFSET;
    sfile.seek(FILE_OFFSET);
    uint8_t *pixels = new uint8_t[size];
    sfile.read(pixels, size);
    sfile.close();

    int count = size / TILE_BYTES;
    for (int i = 0; i < count; ++i)
    {
        CFrame *frame = new CFrame(TILE_SIZE, TILE_SIZE);
        uint8_t *ptr = pixels + i * TILE_BYTES;
        for (int y = 0; y < TILE_SIZE; ++y)
        {
            for (int x = 0; x < TILE_SIZE; ++x)
            {
                const uint8_t &idx = ptr[x + y * TILE_SIZE];
                frame->at(x, y) = g_palette[idx];
            }
        }
        fs.add(frame);
    }
    fs.write(tfile);
    printf("%s %d\n", src, count);
    tfile.close();
    delete[] pixels;
    return true;
}

void generateData()
{
    convert("techdocs/data/cs4ani.mcg", CS4_ANIMZ);
    convert("techdocs/data/cs4edit.mcg", CS4_EDIT);
    convert("techdocs/data/cs4graph.mcg", CS4_TILES);
    convert("techdocs/data/cs4num.mcg", CS4_NUM);
    createArchive();
}

int main(int argc, char *args[])
{
    generateScreenshots();
}