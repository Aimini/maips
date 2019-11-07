#ifndef __SYSCALL__
#define __SYSCALL__

namespace syscall{
    void print_str(char * str) {
        asm (
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



    void set_exception_handler(void (*sys_callback)(int cause)) {
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