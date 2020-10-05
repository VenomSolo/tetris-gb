rgbasm -o main.o main.asm
rgblink -o pixel.gb main.o
rgbfix -v -p 0 pixel.gb