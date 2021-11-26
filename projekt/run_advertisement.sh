as -g -o advertisement.o advertisement.s
ld -o advertisement.elf advertisement.o ../lib/lib_gpio.o ../lib/lib_lcd.o ../lib/lib_timer.o -T stm32f1.ld
openocd -f interface/stlink-v2-1.cfg -f target/stm32f1x.cfg -c "program advertisement.elf verify reset exit"
