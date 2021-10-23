as -g -o led_d2_d7_d13_an.o u04_07.s
ld -o led_d2_d7_d13_an.elf led_d2_d7_d13_an.o ../lib/lib_gpio.o -T ../lib/stm32f1.ld
openocd -f interface/stlink-v2-1.cfg -f target/stm32f1x.cfg -c "program led_d2_d7_d13_an.elf verify reset exit"
