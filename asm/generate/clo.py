from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *
import random,math,itertools

r = gen('clo')

######################
# A: asm writer function
# reg: 
# reg_val : which value store in reg
# immed:

def gen_assert_one(A,au,reg1,reg1_val):
        # although immed is sign extend ,but we still use unsign compare
        #sval = numutil.sign32(reg_val)
        if reg1 == reg_zero:
             reg1_val = 0   

        au.li(reg1, reg1_val)
        try:
            result = f"{reg1_val:0>32b}".index('0');
        except ValueError as e:
            result = 32

        rd  = regutil.get_one()
        au.li(reg1,reg1_val)
        A("clo {},{}".format(rd, reg1))
        au.assert_equal(rd, result & 0xFFFFFFFF)
            
def gen_partial(A,au,reg_val_gen1, time = 2):
    #zero 
    for x in range(time):
        for i in reg_list:
                reg_val1 = reg_val_gen1()
                gen_assert_one(A,au,i,reg_val1);


def my_gen1(A,au):
    fill_one = 2**32 - 1
    for x in range(20):
        for i in range(33):
            v = (fill_one << i) & 0xFFFFFFFF 
            if i > 1:
                v += random.choice(range(2**(i - 1)))

            send_reg = regutil.get_one()
            gen_assert_one(A, au, send_reg,v);

    reg_sample = numutil.bound(32)
    for s1 in reg_sample:
        send_reg = regutil.get_one()
        gen_assert_one(A, au, send_reg, s1);

    gen_sample =  [lambda : random.choice(range(0,10)),\
        lambda : random.choice(range(0x7FFFFFF0,0x8000000F)),\
        lambda : random.choice(range(0x8FFFFFF0,0xFFFFFFFF))  ]
    for i in gen_sample:
        gen_partial(A, au, i,time = 2)

    gen_partial(A, au, lambda : numutil.u32(),time = 20)
    au.check_and_exit()
r.gen(my_gen1)