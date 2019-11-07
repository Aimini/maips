#ifndef __EXCEPTION_CALLBACK__
#define __EXCEPTION_CALLBACK__
#include <cai_io>
#include <cop0_util.h>
void exception_callback(uint32_t cause)
{
	print_str("[exception callback]");
	switch ((cause >> 2)& 0x1F)
	{
	case 0:
		print_str("INT that shouldn't happen.");
		break;
	
	case 4:
		print_str("AdEL");
		break;
	case 5:
		print_str("AdES");
		break;
	case 8:
		print_str("SYSCALL");
		break;
	case 9:
		print_str("BREAK");
		break;
	case 10:
		print_str("RESERVED");
		break;
	case 11:
		print_str("CPU");
		break;
	case 12:
		print_str("OV");
		break;
	case 13:
		print_str("TR");
		break;
	
	default:
	print_str("unsupport.");
		break;
	}
	print_str("\n\n");
	_flush();
}
#endif