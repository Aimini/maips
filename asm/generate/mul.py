from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *
import random,math,itertools

r = gen('mul')

######################
# A: asm writer function
# reg: 
# reg_val : which value store in reg
# immed:

def gen_assert_one(A,au,reg1,reg1_val,reg2,reg2_val):
        # although immed is sign extend ,but we still use unsign compare
        #sval = numutil.sign32(reg_val)
        if reg1== reg_zero:
             reg1_val = 0
        if reg2 == reg_zero:
            reg2_val = 0
        if reg1 == reg2:
            reg1_val = reg2_val

        
        result = numutil.sign32(reg1_val) * numutil.sign32(reg2_val);
        au.li(reg1, reg1_val)
        au.li(reg2, reg2_val)

        
        rd = regutil.get_one()
        A("mul {},{},{}".format(rd, reg1, reg2))
        if rd == reg_zero:
            result = 0
        au.assert_equal(rd, result & 0xFFFFFFFF)
            
def gen_partial(A,au,reg_val_gen1,reg_val_gen2, time = 2):
    #zero 
    for x in range(time):
        for i in list(reg_list):
            for j in list(reg_list):
                reg_val1 = reg_val_gen1()
                reg_val2 = reg_val_gen2()
                # $s0 always being zero
                gen_assert_one(A,au,i,reg_val1,j,reg_val2);


def my_gen1(A,au):
    previous_value = 0
    reg_sample = numutil.bound(32)
    for s1 in reg_sample:
        for s2 in reg_sample:
            send_reg = regutil.get_random(k = 2)
            gen_assert_one(A, au, send_reg[0],s1,send_reg[1],s2);

    gen_sample =  [lambda : random.choice(range(0,10)),\
        lambda : random.choice(range(0x7FFFFFF0,0x8000000F)),\
        lambda : random.choice(range(0x8FFFFFF0,0xFFFFFFFF))  ]
    for i in gen_sample:
        for j in gen_sample:
            gen_partial(A, au, i,j,time = 1)

    gen_partial(A, au, lambda : numutil.u32(), lambda : numutil.u32(),time = 5)
    au.check_and_exit()
r.gen(my_gen1)