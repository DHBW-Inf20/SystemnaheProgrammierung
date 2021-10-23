as -g -o u04_05.o u04_05.s
ld -o u04_05.elf u04_05.o ../lib/lib_gpio.o -T ../lib/stm32f1.ld
openocd -f interface/stlink-v2-1.cfg -f target/stm32f1x.cfg -c "program u04_05.elf verify reset exit"
