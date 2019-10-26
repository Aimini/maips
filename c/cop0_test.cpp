#include "ai_io.h"
#include "status.h"
#include "cop0_util.h"

int get_fixed_zero_bit(char rd,char sel){
    mtc0(rd,sel,0xFFFFFFFF);
    int result = mfc0(rd,sel);
    return ~result;
}

int get_fixed_one_bit(char rd,char sel){
    mtc0(rd,sel,0);
    int result = mfc0(rd,sel);
    return result;
}

int get_fixed_bit_mask(char rd,char sel,int * value){
    int fz = get_fixed_zero_bit(rd,sel);
    int fo = get_fixed_one_bit(rd,sel);
    int mask = fz | fo;
    *value = fo;
    return mask;
}



typedef struct {
    const char * name;
    char rd,sel;
} cop0_t;

int main(){
    
    const char * reg_name[9] = {
        "BadVaddr",
        "Count",
        "Compare",
        "Status",
        "Cause",
        "EPC",
        "EBase",
        "LLAddr",
        "ErrorEPC"
    };
    const char reg_list[9][2] = { 
        {8,0}, {9,0},{11,0},
         {12,0},{13,0},{14,0},
        {15,1},{17,0},{30,0}};
    printf("%10s  %8s  %8s\n","name","mask","fix value");
    for(int i = 0; i < 9; ++i){
        int value = 0;
        const char * rdsel = reg_list[i];
        int mask = get_fixed_bit_mask(rdsel[0],rdsel[1],&value);
        printf("%10s  %8x  %8x\n",reg_name[i],mask,value);
    }

    dump_status(mfc0(12,0));
    sys_exit();
}
