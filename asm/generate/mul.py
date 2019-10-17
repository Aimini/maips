from gen_com import *
import random,math,itertools

r = gen('mul')

######################
# A: asm writer function
# reg: 
# reg_val : which value store in reg
# immed:

def gen_assert_one(A,reg1,reg1_val,reg2,reg2_val):
        # although immed is sign extend ,but we still use unsign compare
        #sval = cutto_sign32(reg_val)
        if reg1 == 0:
             reg1_val = 0
        if reg2 == 0:
            reg2_val = 0
        if reg1 == reg2:
            reg1_val = reg2_val

        if reg2_val != 0:
            result = cutto_sign32(reg1_val) * cutto_sign32(reg2_val);
            A(set_immed(reg1, reg1_val))
            A(set_immed(reg2, reg2_val))

            
            rt = random.choice(range(0,32))
            A("mul ${},${},${}".format(rt, reg1, reg2))
            if rt == 0:
                result = 0
            A(assert_equal_immed(rt, result & 0xFFFFFFFF))
            
def gen_partial(A,reg_val_gen1,reg_val_gen2, time = 2):
    #zero 
    for x in range(time):
        for i in range(32):
            for j in range(32):
                reg_val1 = reg_val_gen1()
                reg_val2 = reg_val_gen2()
                # $s0 always being zero
                gen_assert_one(A,i,reg_val1,j,reg_val2);


def my_gen1(A,C,E):
    previous_value = 0
    reg_sample = itertools.chain(range(0,5),range(2**31 - 4, 2**31 + 4),range(2**32 - 5,2**32))
    for s1 in reg_sample:
        for s2 in reg_sample:
            send_reg = random.sample(range(2,32),k = 2)
            gen_assert_one(A, send_reg[0],s1,send_reg[1],s2);

    gen_sample =  [lambda : random.choice(range(0,10)),\
        lambda : random.choice(range(0x7FFFFFF0,0x8000000F)),\
        lambda : random.choice(range(0x8FFFFFF0,0xFFFFFFFF))  ]
    for i in gen_sample:
        for j in gen_sample:
            gen_partial(A,i,j,time = 2)

    gen_partial(A, lambda : random.choice(range(2**32)), lambda : random.choice(range(2**32)),time = 10)
    A(check_and_exit())
r.gen(my_gen1)