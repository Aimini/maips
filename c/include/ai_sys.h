#ifndef __MY_SYS__
#define __MY_SYS__

#ifdef MIPS_DBG__
volatile int * const __dbg_args = (volatile int *)(0xffff0000);

void sys_exit() {
	__dbg_args[0] = 0;
}


void sys_print_char4(int chars) {
	__dbg_args[1] = chars;
	__dbg_args[0] = 3;
}

void sys_print_int(int i) {
	__dbg_args[1] = i;
	__dbg_args[0] = 4;
}
#else

#include<fstream>
void sys_exit() {

}

void sys_print_char4(int chars) {
	int i = 0;
	for (i = 0; i < 4; ++i) {
		char c = (chars >> (8 * i)) & 0xFF;
		if (c == 0)
			break;
		putchar(c);
	}
}
void sys_print_int(int i) {
	printf("%d", i);
}

#endif

#endif