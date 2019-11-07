#ifndef __EXCEPTION_TEST_
#define __EXCEPTION_TEST_

#include "cop0.h"

void exception_test(){
	// ENTER USER MODE BUT can use COP0 
	asm("mfc0 $t0,$12");
	asm("li   $t1,0x1");
	asm("ins  $t0,$t1,28,1");
	asm("li   $t1,0x8");
	asm("ins  $t0,$t1,1,4");
	asm("mtc0 $t0,$12");
	soft_interrupt(1);
	soft_interrupt(2);
	soft_interrupt(3);
	// sete CU[0] to 0
	asm("mfc0 $t0,$12");
	asm("ins  $t0,$0,28,1");
	asm("mtc0 $t0,$12");

	//cop0 unusable
	asm("li   $t0,0x0FFFFFFF");
	asm("mtc0 $t0,$12");
	asm("teq  $0,$0");
	// overflow
	asm("li   $t0,0x7FFFFFFF");
	asm("li   $t1,1");
	asm("add  $t0,$t0,$t1");
	asm("teqi  $0,0");

	// overflow
	asm("li    $t0,0x80000000");
	asm("addi  $t0,$t0,0xFFFF");
	asm("tne   $0, $t0");

	//break
	asm("break");
	asm("tnei  $0,1");

	// reserved
	asm("li    $t0,0x0FFFFFFF");
	asm("lwc2  $2, 0($t0)");
	asm("tge  $t0, $0");

	// unalign word
	asm("li    $t0,0x10000000");
	asm("sw    $2, 2($t0)");
	asm("tgei  $t0, 0");

	// unalign half word
	asm("li    $t0,0x10000000");
	asm("lh    $2, 1($t0)");
	asm("tlt   $0, $t0");

	// enter kernel
	asm("li    $t0, 0x80000000");
	asm("lw    $2,  0($t0)");
	asm("tlti  $0,  1");
}


#endif