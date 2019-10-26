#ifndef __COP0_UTIL__
#define __COP0_UTIL__
#include "cop0.h"
#include "cai_io"

void dump_status(int value){
    status s(value);
    print_str("----------------------- cop0 status -------------------------\n");
#define TA(_X) (_X ? 'Y' : 'N')
    printf("cop(3 2 1 0)  bev  im(7 6 5 4 3 2 1 0)  erl  exl  ie\n");
    print_str("    ");
    for(int i = 0; i < 4; ++i){
        sys_print_char4(TA(s.cu[3 - i]));
        sys_print_char4(' ');
    }
    print_str("    ");
    sys_print_char4(TA(s.bev));
    print_str("     ");
    for(int i = 0; i < 8; ++i){
        sys_print_char4(TA(s.im[7 - i]));
        sys_print_char4(' ');
    }
    print_str("    ");
    sys_print_char4(TA(s.erl));
    print_str("    ");
    sys_print_char4(TA(s.exl));
    print_str("   ");
    sys_print_char4(TA(s.ie));
    print_str("\n");
#undef  TA
}

#endif