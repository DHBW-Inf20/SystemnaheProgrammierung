as -g -o wait_10s.o wait_10s.s
ld -o wait_10s.elf wait_10s.o ../lib/lib_gpio.o ../lib/lib_sys_timer.o -T ../lib/stm32f1.ld
openocd -f interface/stlink-v2-1.cfg -f target/stm32f1x.cfg -c "program wait_10s.elf verify reset exit"
