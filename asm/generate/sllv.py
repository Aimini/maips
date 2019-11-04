from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom import *

g = gen("sllv")


def my_gen2(A, au):
    def gen_sslv(shift_base, base_value):
        for i in range(2, 32):
            au.li(reg_list[1], shift_base)
            au.li(reg_list[i], base_value + i)
            A(f"sllv ${i},$1,${i}")
            au.assert_equal(reg_list[i], (shift_base << ((base_value + i) % 32)) & 0xFFFFFFFF)
    gen_sslv(1, 0)
    for i in range(512):
        gen_sslv(numutil.u32(), numutil.u32())

    for i in range(1024):
        reg = regutil.get_random(k=3)
        A(f"addu {reg[0]},{reg[1]},{reg[2]}")
        reg = regutil.get_random(k=3)
        A(f"addu {reg[0]},{reg[1]},{reg[2]}")
        reg = regutil.get_random(k=3)
        A(f"addu {reg[0]},{reg[1]},{reg[2]}")
        reg = regutil.get_random(k=3)
        A(f"sllv {reg[0]},{reg[1]},{reg[2]}")
    au.check_and_exit()


g.gen(my_gen2)
