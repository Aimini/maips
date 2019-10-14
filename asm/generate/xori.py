from gen_com import *

r = gen('xori_1')
def my_gen1(A,C,E):
    base =  0x0003
    for i in range(1, 32):
        x = i % 16
        rotate = (base << x) & 0xFFFF | base >> (16 - x)
        A('xori ${},${},0x{:0>4x}'.format(i,i - 1,rotate))
    A(check_and_exit())

r.gen(my_gen1)

r = gen('xori_2')
def my_gen2(A,C,E):
    for i in range(0, 32):
        A('li ${},{}'.format(i,random.choice(range(2**32))))

    for i in range(1024):
        A('li   ${},0x{:0>8x}'.format(random.choice(range(32)),random.choice(range(2**32))))
        A('li   ${},0x{:0>8x}'.format(random.choice(range(32)),random.choice(range(2**32))))
        A('xori ${},${},0x{:0>4x}'.format(random.choice(range(32)),random.choice(range(32)),random.choice(range(2**16))))
        A('xori ${},${},0x{:0>4x}'.format(random.choice(range(32)),random.choice(range(32)),random.choice(range(2**16 - 10,2**16))))
        A('xori ${},${},0x{:0>4x}'.format(random.choice(range(32)),random.choice(range(32)),random.choice(range(0,10))))
    A(check_and_exit())

r.gen(my_gen2)