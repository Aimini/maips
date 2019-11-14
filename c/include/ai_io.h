#ifndef __AI_IO__
#define __AI_IO__

#include "syscall.h"
#include "printf-master/printf.h"
#ifdef __cplusplus
extern "C" {
#endif
#ifndef  _PRINT_BUF_LEN
#define _PRINT_BUF_LEN 64
#endif
	static char buffer[_PRINT_BUF_LEN];
	static int top = 0;
void _flush(){
	buffer[top] = 0;
	syscall::print_str(buffer);
	top = 0;
}

void _putchar(char c)
{
	buffer[top++] = c;
	if(top >= _PRINT_BUF_LEN - 1){
		buffer[_PRINT_BUF_LEN - 1] = 0;
		syscall::print_str(buffer);
		top = 0;
	}
}

void print_str(const char * s){
	while(*s){
		_putchar(*s++);
	}
}


void print_int(int i) {
	int max_10base = 1000000000;
	int still_less_than_base = 1;
	if (i == 1 << 31)
		print_str("-2147483648");
	else if (i == 0)
		_putchar('0');
	else {
		if (i < 0) {
			_putchar('-');
			i = -i;
		}
		while (max_10base > 0)
		{
			if (i >= max_10base)
			{
				still_less_than_base = 0;
				_putchar(i / max_10base + '0');
				i = i % max_10base;
			}
			else if (!still_less_than_base)
			{
				_putchar('0');
			}
			max_10base = max_10base / 10;
		}
	}
}

#ifdef __cplusplus
}
#endif

#endif