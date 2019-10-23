
#define  MIPS_DBG__
#include <cai_io>
#include <cai_mem>
#include <stdarg.h>

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


int compare_to_e(char * in) {
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

void test_print_int() {
	print_str("test print interger\n");
	printf("          0:%d\n",0);
	printf("          1:%d\n",1);
	printf(" 1111111111:%d\n",1111111111);
	printf("    max int:0x%X\n",0x7FFFFFFF);
	printf("    min int:0x%X\n",0x80000000);
	printf("         -1:%d\n",-1);
}
extern "C" {
	int main();
}

#define STACK_LIMIT 32
int main()
{
	int match = 0;
	int iter = 11;
	double de = 1.0f;
	char str[STACK_LIMIT];
	str[0] = 0;
	strcpy(str, "Hello World!\n");
	print_str("------------------------------------------\n");
	print_str(str);
	strcpy(str, "  from AI!  \n");
	print_str(str);
	test_print_int();
	print_str("\n");
	print_str("------------ calculate e -----------------\n");

	calculate_e(iter, str, STACK_LIMIT - 1);
	str[STACK_LIMIT - 1] = 0;
	match = compare_to_e(str) - 2;
	printf("using string result is %s, match decimal %d places.\n",str,match);

	de = calculate_e_double(iter);
	snprintf(str,STACK_LIMIT,"%.30lf",de);
	match = compare_to_e(str) - 2;
	printf("using double result is %s, match decimal %d places.\n",str,match);
	//print_str("--------------- exit  --------------------\n");
	//strcpy(str, "  Goodbyte! \n");
	//print_str(str);
	sys_exit();
}