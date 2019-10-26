extern "C" {
    void __set_status(int v);

    void __attribute__((used)) call_errorEPC();
    void __attribute__((used)) call_EPC();
}
#include "cop0_util.h"
void __attribute__((used))  call_errorEPC(){
    print_str("enter call errorEPC\n");
    dump_status();
    __set_status(0x2);
}

void __attribute__((used))  call_EPC(){
    print_str("enter call EPC\n");
    dump_status();
    __set_status(0x4);
}
    
