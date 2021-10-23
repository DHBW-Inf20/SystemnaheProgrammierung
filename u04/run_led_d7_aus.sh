as -g -o led_d7_aus.o u04_04_aus.s
ld -o led_d7_aus.elf led_d7_aus.o -T ../lib/stm32f1.ld
openocd -f interface/stlink-v2-1.cfg -f target/stm32f1x.cfg -c "program led_d7_aus.elf verify reset exit"
