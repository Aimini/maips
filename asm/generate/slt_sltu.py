from __asmutil import *
from __gencom import *


def my_gen1(A, au, cmd):
    def assert_one(val1, val2):
        sign_val1 = val1
        sign_val2 = val2
        if cmd == "slt":
            sign_val1 = numutil.sign32(val1)
            sign_val2 = numutil.sign32(val2)

        reg_set = regutil.get_random(k=3)
        au.li(reg_set[0], val1)
        au.li(reg_set[1], val2)
        A("{} {},{},{}".format(cmd, reg_set[2], reg_set[0], reg_set[1]))
        if sign_val1 < sign_val2:
            au.assert_equal(reg_set[2], 1)
        else:
            au.assert_equal(reg_set[2], 0)

    def test_by_iter(arg1, arg2):
            parameter_iter_pass(arg1, arg2, callback=assert_one)

    test_by_iter(numutil.bound(32), numutil.bound(32))
    test_by_iter(lambda: random.choice(numutil.bound(32)), repeat_function(numutil.u32, k=1000))
    test_by_iter(repeat_function(numutil.u32, k=1000), lambda: random.choice(numutil.bound(32)))
    for i in range(10000):
        assert_one(numutil.u32(), numutil.u32())
    au.check_and_exit()


def gen_when(cmd):
    r = gen(cmd)
    r.gen(lambda A, au: my_gen1(A, au, cmd))


gen_when("slt")
gen_when("sltu")
