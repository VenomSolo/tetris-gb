rgbasm -o main.o main.asm
rgbasm -o tetromino.o tetromino.asm
rgbasm -o map.o map.asm
rgbasm -o player.o player.asm
rgblink -o tetris.gb tetromino.o map.o player.o main.o
rgbfix -v -p 0 tetris.gb