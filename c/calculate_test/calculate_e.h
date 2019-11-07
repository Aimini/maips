
#define  MIPS_DBG__
#include <cai_io>
#include <cai_mem>
#include <stdarg.h>
#include <syscall.h>
#include "exception_callback.h"

void calculate_e(int iter, char * out, int size) {
	int i = 0;
	long up = 1;
	long down = 1;
	int fisrt_less_down = 1;
	for (i = 1; i <= iter; ++i)
	{
		up = up * i + 1;
		down *= i;
	}
	i = 0;
	while (i < size)
	{
		while (up < down)
		{
			up *= 10;
			out[i++] = '0';
			if (i >= size) {
				return;
			}
		}
		long quotient = up / down;
		long remainder = up % down;
		char div = (char)quotient + '0';
		out[i++] = div;
		if (fisrt_less_down && i < size) {
			out[i++] = '.';
			fisrt_less_down = 0;
		}
		up = remainder * 10;
	}
}

double calculate_e_double(int iter) {
	int i = 0;
	double result = 1.0;
	double down = 1.0;
	for (i = 1; i <= iter; ++i)
	{
		down = down * 1.0f/i;
		result += down;
	}
	return result;
}


int compare_to_e(const char * in) {
	const char * const e =
		"2."
		"71828182845904523536028747135266249775724709369995";
	const char * cmp = e;
	int match = 0;
	while (*cmp && *in) {
		if (*cmp++ != *in++)
			break;
		++match;
	}
	return match;
}
