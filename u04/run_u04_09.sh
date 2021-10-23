as -g -o u04_09.o u04_09.s
ld -o u04_09.elf u04_09.o ../lib/lib_gpio.o ../lib/lib_sys_timer.o -T ../lib/stm32f1.ld
openocd -f interface/stlink-v2-1.cfg -f target/stm32f1x.cfg -c "program u04_09.elf verify reset exit"
