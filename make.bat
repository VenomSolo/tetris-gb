rgbasm -o main.o main.asm
rgblink -o tetris.gb main.o
rgbfix -v -p 0 tetris.gb