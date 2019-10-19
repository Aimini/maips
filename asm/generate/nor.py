from gen_com import *

r = gen('nor')
def my_gen1(A,C,E):
    base = 5
    reg_values = list(range(32))
    for i in range(1, 32):
        reg_values[i] = (3 << (i - 1))&0xFFFFFFFF
        A(set_immed(i, reg_values[i]))


    for i in range(2, 32):
        A('nor ${0},${0},${1}'.format(i,i - 1))

    value = reg_values[1]
    regs = get_random_exclude_reg(k = 2)
    for i in range(2, 30):
        value = ~(reg_values[i] | value)
        if i not in regs:
            A(assert_equal_immed(i,  value ,regs[0],regs[1]))

    for i in range(0, 32):
        A('li ${},{}'.format(i,get_u32()))

    for i in range(10000):
        reg = get_random_exclude_reg(k = 2)
        A('li ${},{}'.format(reg[0],get_u32()))
        A('li ${},{}'.format(reg[1],get_u32()))
        reg = get_random_exclude_reg(k = 3)
        A('nor ${0},${1},${2}'.format(*reg))
        reg = get_random_exclude_reg(k = 3)
        A('nor ${0},${1},${2}'.format(*reg))
        reg = get_random_exclude_reg(k = 3)
        A('nor ${0},${1},${2}'.format(*reg))
    A(check_and_exit())

r.gen(my_gen1)