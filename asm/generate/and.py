from gen_com import *

r = gen('and')
def my_gen1(A,C,E):
    base = 5
    for i in range(1, 32):
        A(set_immed(i,(0xFFFFFFFE << i)|(2**i - 1)))
    mask = 0xFFFFFFFE
    for i in range(2, 32):
        A('and ${0},${0},${1}'.format(i,i - 1))
    for i in range(3, 32):
        A(assert_equal_immed(i, (mask << i)& 0xFFFFFFFF | 1,1,2))


    for i in range(0, 32):
        A('li ${},{}'.format(i,get_u32()))

    for i in range(10000):
        reg = get_random_exclude_reg(k = 2)
        A('li ${},{}'.format(reg[0],get_u32()))
        A('li ${},{}'.format(reg[1],get_u32()))
        reg = get_random_exclude_reg(k = 3)
        A('and ${0},${1},${2}'.format(*reg))
        reg = get_random_exclude_reg(k = 3)
        A('and ${0},${1},${2}'.format(*reg))
        reg = get_random_exclude_reg(k = 3)
        A('and ${0},${1},${2}'.format(*reg))
    A(check_and_exit())

r.gen(my_gen1)