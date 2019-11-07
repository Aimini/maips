
#define  MIPS_DBG__
#include <cai_io>
#include <cai_mem>
#include <stdarg.h>
#include <syscall.h>
#include "exception_callback.h"
#include "exception_test.h"
#include "calculate_e.h"

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
	double de = 1.55f;
	char str[STACK_LIMIT];
	str[STACK_LIMIT - 1] = 0;
	syscall::set_exception_callback(exception_callback);

	strncpy(str, "Hello World!\n",STACK_LIMIT - 1);
	print_str("------------------------------------------\n");
	print_str(str);
	strncpy(str, "  from AI!  \n",STACK_LIMIT - 1);
	print_str(str);
	test_print_int();
	print_str("\n");
	print_str("------------ calculate e -----------------\n");

	calculate_e(iter, str, STACK_LIMIT - 1);
	str[STACK_LIMIT - 1] = 0;
	match = compare_to_e(str) - 2;
	printf("using string result is %s, match decimal %d places.\n",str,match);

	de = calculate_e_double(iter);
	snprintf(str,STACK_LIMIT,"%.29lf",de);
	match = compare_to_e(str) - 2;
	printf("using double result is %s, match decimal %d places.\n",str,match);
	_flush();
	exception_test();

	print_str("--------------- exit  --------------------\n");
	strncpy(str, "  Goodbyte! \n",STACK_LIMIT - 1);
	print_str(str);
	
	while(true){
		uint32_t hns = syscall::tick();
		uint32_t us = hns / 10U; 
		hns %= 10;
		uint32_t ms = us / 1000U;
		us %= 1000;
		uint32_t s = ms / 1000U;
		ms %= 1000;
		printf("%2ds%3dms%3dus%d00ns \n",s, ms, us, hns);
		_flush();
	}
	syscall::exit();
}