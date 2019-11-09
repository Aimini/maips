
#include <cai_io>
#include <stdarg.h>
#include <syscall.h>
#include <cai_mem>
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

int main()
{
	unsigned int iter = 40;
	#define STACK_LIMIT 64U
	#define EINT_LIMIT (STACK_LIMIT / 4U)
	char str[STACK_LIMIT];
	memset_try_word(str, 0 , STACK_LIMIT);
	
	uint32_t elong_result[EINT_LIMIT];
	syscall::set_exception_callback(exception_callback);
	print_str("------------------------------------------\n");
	
	print_str("Hello World!\n");
	print_str("  from AI!  \n");
	test_print_int();
	print_str("\n");
	print_str("------------ calculate e -----------------\n");

	calculate_e(11, str, STACK_LIMIT - 1);
	printf("using string result is %s, match decimal %d places.\n",str,compare_to_e(str) - 2);

	snprintf(str,STACK_LIMIT,"%.29f", calculate_e_double(12));
	printf("using double result is %s, match decimal %d places.\n",str,compare_to_e(str) - 2);


	e_long<EINT_LIMIT>(iter, elong_result);
	str[0] = '2';
	str[1] = '.';
	for(unsigned int i = 1; i < EINT_LIMIT; ++i){
		unsigned int j = (i - 1) * 4  + 2;
		if(j >= STACK_LIMIT)
			break;
		snprintf(str + j,STACK_LIMIT - j,"%.4d",elong_result[i]);
	}
	printf("using long e result is %s, match decimal %d places.\n",str,  compare_to_e(str) - 2);


	_flush();
	exception_test();

	print_str("--------------- exit  --------------------\n");
	print_str("  Goodbyte! \n");
	
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