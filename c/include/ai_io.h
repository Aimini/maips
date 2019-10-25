#ifndef __AI_IO__
#define __AI_IO__

#include "ai_sys.h"
#include "printf-master/printf.h"

#ifdef __cplusplus
extern "C" {
#endif

void _putchar(char c)
{
	sys_print_char4(c);
}

void print_str(const char * str) {
	// int * char4_ptr = (int *)str;
	// int i = 0;
	// int end = 0;
	while (*str) {
		sys_print_char4((unsigned char)*str++);
		// int chars = *char4_ptr++;
		// sys_print_char4(chars);
		// for (i = 0; i < 4; ++i) {
		// 	unsigned char c = (chars >> (8 * i)) & 0xFF;
		// 	if (c == 0)
		// 	{
		// 		end = 1;
		// 		break;
		// 	}
		// }
	}
}

void print_int(int i) {
	int max_10base = 1000000000;
	int still_less_than_base = 1;
	if (i == 0x80000000)
		print_str("-2147483648"); 
	else if (i == 0)
		sys_print_char4('0');
	else {
		if (i < 0) {
			sys_print_char4('-');
			i = -i;
		}
		while (max_10base > 0)
		{
			if (i >= max_10base)
			{
				still_less_than_base = 0;
				sys_print_char4(i / max_10base + '0');
				i = i % max_10base;
			}
			else if (!still_less_than_base)
			{
				sys_print_char4('0');
			}
			max_10base = max_10base / 10;
		}
	}
}

#ifdef __cplusplus
}
#endif

#endif