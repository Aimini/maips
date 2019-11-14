#ifndef __CALCULATE_E__
#define __CALCULATE_E__
#include <stdint.h>
#include <cai_mem>

template<class T,class E>
T * memset_try_word(T * dest, E value, size_t n){
	if(((uint32_t)dest) %4 == 0){
		for(;0 < n;++dest,--n)
			*dest = value;
		return dest;
	}
	else{
		return (T *)memset(dest,value,n*sizeof(T));
	}
}

template<size_t SIZE = 1000>
void e_long(unsigned int iter, uint32_t *result,void (*step_callback)(unsigned int step) = 0){
	
	const unsigned int max_base = 10000;
	unsigned int d = 2;

	uint32_t partial[SIZE];
	memset_try_word(partial + 1, 0UL ,SIZE - 1);
	partial[0] = 1;
	memset_try_word(result + 1,  0UL ,SIZE - 1);
	result[0] = 2;

	for( d = 2;d <= iter; ++d)
	{
		unsigned int remainder = 0;
		for (unsigned int j = 0; j < SIZE; ++j) 
		{
			unsigned int current = remainder * max_base;
			current += partial[j];
			partial[j] = current / d;
			remainder = current % d;
		}

		unsigned int carry = 0; 
		unsigned int j = SIZE;
		do
		{
			--j;
			unsigned int current = result[j] + carry + partial[j];
			result[j] =  current % max_base;
			carry = current / max_base;
		}while (j);
	}
}

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
		"2."  // 450 + 2
		"718281828459045235360287471352662497757247093699959574966967627724076630353"
  		"547594571382178525166427427466391932003059921817413596629043572900334295260"
  		"595630738132328627943490763233829880753195251019011573834187930702154089149"
	  	"934884167509244761460668082264800168477411853742345442437107539077744992069"
		"551702761838606261331384583000752044933826560297606737113200709328709127443"
  		"747047230696977209310141692836819025515108657463772111252389784425056953696";

	const char * cmp = e;
	int match = 0;
	while (*cmp && *in) {
		if (*cmp++ != *in++)
			break;
		++match;
	}
	return match;
}
#endif