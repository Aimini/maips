from gen_com import *
import random,math,itertools

r = gen('clz')

######################
# A: asm writer function
# reg: 
# reg_val : which value store in reg
# immed:

def gen_assert_one(A,reg1,reg1_val):
        # although immed is sign extend ,but we still use unsign compare
        #sval = cutto_sign32(reg_val)
        if reg1 == 0:
             reg1_val = 0   

        A(set_immed(reg1, reg1_val))
        try:
            result = f"{reg1_val:0>32b}".index('1');
        except ValueError as e:
            result = 32

        rd = random.choice(range(1,32))
        A("li ${},0x{:0>8x}".format(reg1,reg1_val))
        A("clz ${},${}".format(rd, reg1))
        A(assert_equal_immed(rd, result & 0xFFFFFFFF))
            
def gen_partial(A,reg_val_gen1, time = 2):
    #zero 
    for x in range(time):
        for i in range(32):
                reg_val1 = reg_val_gen1()
                # $s0 always being zero
                gen_assert_one(A,i,reg_val1,);


def my_gen1(A,C,E):
    for x in range(20):
        for i in range(33):
            if i > 30:
                v = (2**31 >> i)
            else:
                v = (2**31 >> i) + random.choice(range(31 - i))
            send_reg = random.choice(range(1,32))
            gen_assert_one(A, send_reg,v);


    reg_sample = itertools.chain(range(0,5),range(2**31 - 4, 2**31 + 4),range(2**32 - 5,2**32))
    for s1 in reg_sample:
        send_reg = random.choice(range(1,32))
        gen_assert_one(A, send_reg,s1);

    gen_sample =  [lambda : random.choice(range(0,10)),\
        lambda : random.choice(range(0x7FFFFFF0,0x8000000F)),\
        lambda : random.choice(range(0x8FFFFFF0,0xFFFFFFFF))  ]
    for i in gen_sample:
        gen_partial(A,i,time = 2)

    gen_partial(A, lambda : random.choice(range(2**32)),time = 20)
    A(check_and_exit())
r.gen(my_gen1)