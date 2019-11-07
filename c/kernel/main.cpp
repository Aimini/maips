
#define  MIPS_DBG__
#include <cai_io>
#include <cai_mem>
#include <stdarg.h>
#include <cop0_util.h>

typedef void (*sys_callback_t)(uint32_t cause);
sys_callback_t interrupt_callback = 0;
sys_callback_t exception_callback  = 0;
uint32_t clock_count, soft_interrupt0, soft_interrut1;

extern "C" {
	void  print_booting_info();
	void exception_handler(uint32_t cause,uint32_t epc);
	uint32_t  syscall_handler();
	void interrupt_handler(uint32_t cause);
}

void process_syscall(uint32_t v0, uint32_t a0);

void  print_booting_info(){
	uint32_t sp;
	asm (
		"move  %0, $sp  \n\r"
	: "=r"(sp)
	:
	:);
	printf("******************************************************\n");
	printf("* starting...\n");
	printf("* sp at %p\n",sp);
	dump_status();
	printf("******************************************************\n");
}


void  exception_handler(uint32_t cause,uint32_t epc) {

	
	int exc_code = (cause >> 2) & 0x1F;
	printf("[info] exception happen with code [0x%X]\n",exc_code);
	uint32_t bad_instruction = *(uint32_t *)(epc);
	bool in_bd = cause & 0x80000000;
	int cu = cause >> 28;
	if(in_bd){
	 	printf("[error]: why you cause exception in delay slot???\n");
		sys_exit();
	}

	switch (exc_code)
	{
		case 4:
		case 5:
			printf("[error] %s error address 0x%X at address [0x%X]:0x%X"
			, exc_code == 4? "load":"store", get_badvaddr(),epc, bad_instruction);
		break;

		case 9:
			printf("[notice] break at [0x%X]:0x%X",  epc, bad_instruction);
		break;
		
		case 10:
			printf("[error] reserved instruciton at [0x%X]:0x%X", epc, bad_instruction);
		break;

		case 11:
			printf("[error] cop%d unusable at [0x%X]:0x%X", cu, epc, bad_instruction);
		break;

		case 12:
			printf("[notice] aritmetic overflow at [0x%X]:0x%X", epc, bad_instruction);
		break;

		case 13:
			printf("[notice] trap at [0x%X]:0x%X", epc, bad_instruction);
		break;

		default:
			printf("[error] unkonw exception(%d) at [0x%X]:0x%X",exc_code, epc, bad_instruction);
		break;
	}
	_putchar('\n');

	if(exception_callback != 0)
		exception_callback(cause);
}

uint32_t syscall_handler() {
	uint32_t v0,a0;
		asm volatile (
		"addu  %0, $v0, $0  \n\r"
		"addu  %1, $a0, $0  \n\r"
	:  "=r"(v0), "=r"(a0)
	:
	:);
	uint32_t count = mfc0(9,0);
	uint32_t p  = mfc0(11,0) + 1;
	uint32_t tick = (count + clock_count * p);
	if(v0 != 4)
		printf("[info] syscall, v0: %X, a0: %X\n", v0, a0);
	
	switch(v0){
		case 4:
			print_str((char *)(a0));
			break;

		case 10:
			print_str("[info] system exit.\n");
			sys_exit();
			break;

		case 11:
			printf("[info] set exception callback %p.\n",a0);
			exception_callback = (sys_callback_t)a0;
			break;

		case 30:
			// printf("[tick] %d.\n",tick);
			return tick;
			break;
	}
	return 0;
}



void interrupt_handler(uint32_t cause){
	printf("interrupt append : hw5 hw4 hw3 hw2 hw1 hw0 sw1 sw0\n");
	printf("interrupt append :");
	for(int i = 0; i < 8; ++i){
		printf("   %c", ((cause >> 8) & (1 <<(7 - i))) ? 'Y' : 'N');
	}
	printf("\n");
	if(interrupt_callback != 0)
		interrupt_callback(cause);
}