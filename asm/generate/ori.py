from gen_com import *

r = gen('ori')
def my_gen1(A,R,C,E):
    base = 5
    previous = 0
    R(0)
    for i in range(1, 16):
        x = i % 16
        rotate = (base << x) & 0xFFFF | base >> (16 - x)
        previous = previous | rotate
        R(previous)
        A('ori ${0},${1},0x{2:0>4x}'.format(i,i - 1,rotate))
    

    for i in range(16, 32):
        x = i % 16
        rotate = (base << x) & 0xFFFF | base >> (16 - x)
        R(rotate)
        A('ori ${0},${1},0x{2:0>4x}'.format(i,0,rotate))

    C(1,6)
    E(1)
r.gen(my_gen1)

r = gen('ori_2')
def my_gen2(A,R,C,E):
    R(0)
    for i in range(1, 32):
        x = i % 16
        rotate = (1 << x) & 0xFFFF
        R(rotate)
        A('ori ${0},${1},0x{2:0>4x}'.format(i,0,rotate))

    C(5,17)
    E(5)
r.gen(my_gen2)