
#define  MIPS_DBG__
#include <cai_io>
#include <cai_mem>
#include <stdarg.h>
#include <cop0_util.h>

typedef void (*sys_callback_t)(int cause);
sys_callback_t interrupt_callback = 0;
sys_callback_t exception_callback  = 0;
unsigned int clock_count, soft_interrupt0, soft_interrut1;

extern "C" {
	void  print_booting_info();
	void exception_handler(int cause);
	int  syscall_handler();
	void interrupt_handler(int cause);
}

void process_syscall(int v0, int a0);

void  print_booting_info(){
	int sp;
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


void  exception_handler(int cause) {

	
	int exc_code = (cause >> 2) & 0x1F;
	printf("[info] exception happen with code %x\n",exc_code);
	int epc      = get_epc();
	int badvaddr = get_badvaddr();
	int bad_data = *(int *)(badvaddr);
	int bad_instruction = *(int *)(epc);
	if(cause & 0x80000000){
	 	printf("[error]: why you cause exception in delay slot???\n");
		sys_exit();
	}

	switch (exc_code)
	{
		case 4:
			printf("[error] load error at address 0x%X\n",bad_data);		
		break;

		case 5:
			printf("[error] store error at address 0x%X\n",bad_data);
		break;


		case 9:
			printf("[notice] break at [%X]:%X", epc, bad_instruction);
		break;
		
		case 10:
			printf("[error] reserved instruciton at [%X]:%X", epc, bad_instruction);
		break;

		case 11:
			printf("[error] cop unusable at [%X]:%X", epc, bad_instruction);
		break;

		case 12:
			printf("[notice] aritmetic overflow at [%X]:%X", epc, bad_instruction);
		break;

		case 13:
			printf("[notice] trap at [%X]:%X", epc, bad_instruction);
		break;

		default:
			printf("[error] unkonw exception(%d) at [%X]:%X",exc_code, epc, bad_instruction);
		break;
	}
	if(exception_callback != 0)
		exception_callback(cause);
}

int syscall_handler() {
	int v0,a0;
		asm volatile (
		"addu  %0, $v0, $0  \n\r"
		"addu  %1, $a0, $0  \n\r"
	:  "=r"(v0), "=r"(a0)
	:
	:);
	int count = mfc0(9,0);
	int p  = mfc0(11,0) + 1;
	int tick = (count + clock_count * p);
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
			printf("[info] set interrupt handler %p.\n",a0);
			interrupt_callback = (sys_callback_t)a0;
			break;

		case 30:
			return tick;
			break;
	}
	return 0;
}



void interrupt_handler(int cause){
	printf("interrupt append : hw5 hw4 hw3 hw2 hw1 hw0 sw1 sw0\n");
	printf("interrupt append :");
	for(int i = 0; i < 8; ++i){
		printf("   %c", ((cause >> 8) & (1 << i)) ? 'Y' : 'N');
	}
	printf("\n");
	if(interrupt_callback != 0)
		interrupt_callback(cause);
}