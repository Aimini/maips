#ifndef __COP0__
#define __COP0__
#include <stdint.h>
#include "status.h"
#include "cop0.h"




uint32_t mfc0(char rd,char sel){
    uint32_t result;
#define __MFCO_DEF(_RD,_SEL)                          \
    if(rd == _RD && sel == _SEL) {                     \
        asm("mfc0    %0, $" #_RD "," #_SEL             \
            : "=r" (result)                            \
                                                       \
        );                                             \
        return result;                                 \
    }  
    __MFCO_DEF(8,0)
    __MFCO_DEF(9,0)
    __MFCO_DEF(11,0)
    __MFCO_DEF(12,0)
    __MFCO_DEF(13,0)
    __MFCO_DEF(14,0)
    __MFCO_DEF(15,1)
    __MFCO_DEF(17,0)
    __MFCO_DEF(30,0)
#undef __MFCO
    return 0;
}

void mtc0(char rd,char sel,uint32_t val){
#define __MTCO_DEF(_RD,_SEL)                            \
    if(rd == _RD && sel == _SEL) {                      \
        asm("mtc0    %0, $" #_RD "," #_SEL              \
            :                                           \
            : "r" (val)                                 \
                                                        \
        );                                              \
        return;                                         \
    }  
    __MTCO_DEF(8,0)
    __MTCO_DEF(9,0)
    __MTCO_DEF(11,0)
    __MTCO_DEF(12,0)
    __MTCO_DEF(13,0)
    __MTCO_DEF(14,0)
    __MTCO_DEF(15,1)
    __MTCO_DEF(17,0)
    __MTCO_DEF(30,0)
#undef __MTCO_DEF
}

int get_badvaddr(){
    return mfc0(8,0);
}

int get_epc(){
    return mfc0(14,0);
}

status get_status()
{
    return status(mfc0(12,0));
}


#endif
