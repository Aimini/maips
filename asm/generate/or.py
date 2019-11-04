from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom import *


def my_gen1(A, au):
    base = 5
    for i in range(1, 32):
        au.li(reg_list[i], 1 << i)
    mask = 0xFFFFFFFE
    for i in range(2, 32):
        A('or {0},{0},{1}'.format(reg_list[i], reg_list[i - 1]))
    for i in range(1, 30):
        au.assert_equal(reg_list[i],  2**(i+1) - 2,reg_list[30],reg_list[31])

    for i in reg_list:
        au.li(i, numutil.u32())

    for i in range(10000):
        reg = regutil.get_random(k=2)
        au.li(reg[0], numutil.u32())
        au.li(reg[1], numutil.u32())
        reg = regutil.get_random(k=3)
        A('or {0},{1},{2}'.format(*reg))
        reg = regutil.get_random(k=3)
        A('or {0},{1},{2}'.format(*reg))
        reg = regutil.get_random(k=3)
        A('or {0},{1},{2}'.format(*reg))
    au.check_and_exit()


r = gen('or')
r.gen(my_gen1)
