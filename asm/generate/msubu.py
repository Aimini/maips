from gen_com import *
import random,math

r = gen('msubu')

######################
# A: asm writer function
# reg: 
# reg_val : which value store in reg
# immed:

def gen_assert_one(A,reg1,reg1_val,reg2,reg2_val,prev_value):
        # although immed is sign extend ,but we still use unsign compare
        #sval = cutto_sign32(reg_val)
        if reg1 == 0:
             reg1_val = 0
        if reg2 == 0:
            reg2_val = 0
        if reg1 == reg2:
            reg1_val = reg2_val
        next_value = prev_value
        
        result =reg1_val * reg2_val;
        A(set_immed(reg1, reg1_val))
        A(set_immed(reg2, reg2_val))

        A("msubu ${},${}".format(reg1,reg2))
        next_value -= result;

        retrive_reg = random.sample(range(2,32),k = 2)
        A("mfhi ${}".format(retrive_reg[0]))
        A(assert_equal_immed(retrive_reg[0],(next_value >> 32) & 0xFFFFFFFF))

        A("mflo ${}".format(retrive_reg[1]))  
        A(assert_equal_immed(retrive_reg[1],next_value & 0xFFFFFFFF))
        return next_value & 0xFFFFFFFFFFFFFFFF 
            
def gen_partial(A,reg_val_gen1,reg_val_gen2,previous_value, time = 2):
    #zero 
    for x in range(time):
        for i in range(32):
            for j in range(32):
                reg_val1 = reg_val_gen1()
                reg_val2 = reg_val_gen2()
                # $s0 always being zero
                previous_value = gen_assert_one(A,i,reg_val1,j,reg_val2,previous_value);
    return previous_value;


def my_gen1(A,C,E):
    previous_value = 0;
    reg_sample = [0,0x43218765,0x7FFFFFFF,0x80000000,0x80000001,0xAB12CD45,0xFFFFFFFF]
    for s1 in reg_sample:
        for s2 in reg_sample:
            send_reg = random.sample(range(2,32),k = 2)
            previous_value = gen_assert_one(A, send_reg[0],s1,send_reg[1],s2,previous_value);

    gen_sample =  [lambda : random.choice(range(0,10)),\
        lambda : random.choice(range(0x7FFFFFF0,0x8000000F)),\
        lambda : random.choice(range(0x8FFFFFF0,0xFFFFFFFF))  ]
    for i in gen_sample:
        for j in gen_sample:
            previous_value = gen_partial(A,i,j,previous_value,time = 2)
    previous_value = gen_partial(A, lambda : random.choice(range(2**32)), lambda : random.choice(range(2**32)),previous_value,time = 3)
    A(check_and_exit())
r.gen(my_gen1)
