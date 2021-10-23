as -g -o led_d7_an.o u04_04.s
ld -o led_d7_an.elf led_d7_an.o -T ../lib/stm32f1.ld
openocd -f interface/stlink-v2-1.cfg -f target/stm32f1x.cfg -c "program led_d7_an.elf verify reset exit"
