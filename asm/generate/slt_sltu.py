from gen_com import *
import random,sys

r = gen('slt')

def my_gen1(cmd,A,C,E):
    def assert_one(val1,val2):
        sign_val1 = val1
        sign_val2 = val2
        if cmd == "slt":
            sign_val1 = cutto_sign32(val1)
            sign_val2 = cutto_sign32(val2)


        reg_set = get_random_exclude_reg(k = 3)
        A(set_immed(reg_set[0],val1))
        A(set_immed(reg_set[1],val2))
        A("{} ${},${},${}".format(cmd,reg_set[2],reg_set[0],reg_set[1]))
        if sign_val1 < sign_val2:
            A(assert_equal_immed(reg_set[2],1))
        else:
            A(assert_equal_immed(reg_set[2],0))

    def test_by_iter(arg1,arg2):
            parameter_iter_pass(arg1,arg2,callback = assert_one)

    test_by_iter(get_bound(32),get_bound(32))
    test_by_iter(lambda : random.choice(get_bound(32)),repeat_function(get_u32,time = 1000))
    test_by_iter(repeat_function(get_u32,time = 1000), lambda : random.choice(get_bound(32)))
    for i in range(10000):
        assert_one(get_u32(), get_u32())
    A(check_and_exit())
def gen_when(cmd):
    r = gen(cmd)
    r.gen(lambda A,C,E:my_gen1(cmd,A,C,E))

gen_when(sys.argv[1])