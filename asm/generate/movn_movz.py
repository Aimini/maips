from gen_com import *
import random,math,itertools
def gen_when(cmd):

    r = gen(cmd)

    def gen_assert_one(A,reg, value, reg2, condition_value):
            # although immed is sign extend ,but we still use unsign compare
            #sval = cutto_sign32(reg_val)
            if reg == 0:
                value = 0
            if reg2 == 0:
                condition_value = 0

            A(set_immed(reg, value))
            A(set_immed(reg2, condition_value))
            
            rd, = get_random_exclued_reg(k = 1, exclude =[reg2])
            rd_value = random.choice(range(2**32))
            A(set_immed(rd, rd_value))
            if reg == rd:
                value = rd_value
            A(f"{cmd} ${rd},${reg},${reg2}")
            if cmd == "movz" and condition_value == 0 or cmd == "movn" and condition_value != 0 :
                A(assert_equal_immed(rd, value & 0xFFFFFFFF))
            
            else:
                A(assert_equal_immed(rd, rd_value & 0xFFFFFFFF))


    def my_gen1(A,C,E):
        for i in range(32):
            A(f"li ${i},0")


        
        def test_one(value, condition_value):
            reg = get_random_exclued_reg(k = 2)
            gen_assert_one(A, reg[0], value, reg[1], condition_value)
        
        def test_by_iter(word_cout,offset):
            parameter_iter_pass(word_cout,offset,callback = test_one)

        offset_bound = get_bound_s16()

        test_by_iter(get_u32, 5*get_bound(32,False))
        test_by_iter(repeat_function(get_u32,time = 5000), get_u32)
        test_by_iter(5*get_bound(32,False), get_u32)
        

        A(check_and_exit())

    r.gen(my_gen1)


gen_when("movz")
gen_when("movn")