#ifndef __SYSCALL__
#define __SYSCALL__
#include <stdint.h>

namespace syscall{
    void print_str(char * str) {
        asm volatile (
            "li   $v0, 4 \n\r"
            "move $a0, %0 \n\r"
            "syscall  \n\r"
            :
            : "r"(str)
            : "$v0","$a0"
        );
    }

    void exit() {
        asm (
            "li $v0, 10 \n\r"
            "syscall  \n\r"
            :
            :
            : "$v0"
        );
    };

    uint32_t tick() {
        uint32_t t = 0;
        asm volatile (
            "li $v0, 30  \n\r"
            "syscall     \n\r"
            "move %0, $v0\n\r"
            :"=r"(t)
            :
            : "$v0"
        );
        return t;
    };

    void set_exception_callback(void (*sys_callback)(uint32_t cause)) {
        asm (
            "li   $v0, 11 \n\r"
            "move $a0, %0 \n\r"
            "syscall  \n\r"
            :
            : "r"(sys_callback)
            : "$v0","$a0"
        );
    }
};

#endif