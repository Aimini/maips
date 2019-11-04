from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *

r = gen('and')
def my_gen(A,au):
    base = 5
    for i in range(1, 32):
        au.li(reg_list[i], (0xFFFFFFFE << i)|(2**i - 1))
    mask = 0xFFFFFFFE
    for i in range(2, 32):
        A('and {0},{0},{1}'.format(reg_list[i], reg_list[i - 1]))
    for i in range(3, 32):
        au.assert_equal(reg_list[i], (mask << i) & 0xFFFFFFFF | 1,reg_list[1],reg_list[2])


    # for i in reg_list:
    #     au.li(i, numutil.u32())

    # for i in range(5000):
    #     reg = regutil.get_random(k = 2)
    #     au.li(reg[0],numutil.u32())
    #     au.li(reg[1],numutil.u32())
    #     for x in range(3):
    #         reg = regutil.get_random(k = 3)
    #         A('and {0},{1},{2}'.format(*reg))
    au.check_and_exit()
    return ["mars","-D"]

r.gen(my_gen)