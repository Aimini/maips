from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom import *


def my_gen1(A, au):
    base = 5
    for i in range(1, 32):
        au.li(reg_list[i], (3 << (i - 1)) & 0xFFFFFFFF)
    mask = 0xFFFFFFFE
    for i in range(2, 32):
        A('xor {0},{0},{1}'.format(reg_list[i], reg_list[i - 1]))
        
    regs = regutil.get_random(k=2)
    for i in range(1, 30):
        if reg_list[i] not in regs:
            au.assert_equal(reg_list[i], 2**(i) + 1 ,regs[0], regs[1])

    for i in reg_list:
        au.li(i, numutil.u32())

    for i in range(10000):
        reg = regutil.get_random(k=2)
        au.li(reg[0], numutil.u32())
        au.li(reg[1], numutil.u32())
        reg = regutil.get_random(k=3)
        A('xor {0},{1},{2}'.format(*reg))
        reg = regutil.get_random(k=3)
        A('xor {0},{1},{2}'.format(*reg))
        reg = regutil.get_random(k=3)
        A('xor {0},{1},{2}'.format(*reg))
    au.check_and_exit()


r = gen('xor')
r.gen(my_gen1)
