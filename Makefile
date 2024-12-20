CXX=g++
STD=-std=c++17
INC=
LIBS=-lSDL2 -lz
CXXFLAGS=-O3
PARGS=
BPATH=build
BNAME=cs4-sdl
TARGET=$(BPATH)/$(BNAME)
TEMPLATE=
DEPS=$(BPATH)/main$(EXT) $(BPATH)/maparch$(EXT) $(BPATH)/debug$(EXT) $(BPATH)/map$(EXT) $(BPATH)/FrameSet$(EXT) $(BPATH)/Frame$(EXT) $(BPATH)/DotArray$(EXT) $(BPATH)/helper$(EXT) $(BPATH)/PngMagic$(EXT) $(BPATH)/FileWrap$(EXT)
EXT=.o

all: $(TARGET)

$(BPATH)/main$(EXT): src/main.cpp
	$(CXX) $(STD) $(CXXFLAGS) -c $< $(INC) -o $@

$(BPATH)/maparch$(EXT): src/maparch.cpp src/maparch.h
	$(CXX) $(STD) $(CXXFLAGS) -c $< $(INC) -o $@

$(BPATH)/debug$(EXT): src/debug.cpp src/debug.h
	$(CXX) $(STD) $(CXXFLAGS) -c $< $(INC) -o $@

$(BPATH)/map$(EXT): src/map.cpp src/map.h
	$(CXX) $(STD) $(CXXFLAGS) -c $< $(INC) -o $@

$(BPATH)/FrameSet$(EXT): src/shared/FrameSet.cpp src/shared/FrameSet.h
	$(CXX) $(STD) $(CXXFLAGS) -c $< $(INC) -o $@

$(BPATH)/Frame$(EXT): src/shared/Frame.cpp src/shared/Frame.h
	$(CXX) $(STD) $(CXXFLAGS) -c $< $(INC) -o $@

$(BPATH)/DotArray$(EXT): src/shared/DotArray.cpp src/shared/DotArray.h
	$(CXX) $(STD) $(CXXFLAGS) -c $< $(INC) -o $@

$(BPATH)/helper$(EXT): src/shared/helper.cpp src/shared/helper.h
	$(CXX) $(STD) $(CXXFLAGS) -c $< $(INC) -o $@

$(BPATH)/PngMagic$(EXT): src/shared/PngMagic.cpp src/shared/PngMagic.h
	$(CXX) $(STD) $(CXXFLAGS) -c $< $(INC) -o $@

$(BPATH)/FileWrap$(EXT): src/shared/FileWrap.cpp src/shared/FileWrap.h
	$(CXX) $(STD) $(CXXFLAGS) -c $< $(INC) -o $@

$(TARGET): $(DEPS)
	$(CXX) $(CXXFLAGS) $(DEPS) $(LIBS) $(PARGS) -o $@ $(TEMPLATE)

clean:
	rm -rf $(BPATH)/*