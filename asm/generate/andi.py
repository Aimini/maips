from gen_com import *

r = gen('andi_1')
def my_gen1(A,C,E):
    base = 5
    for i in range(0, 32):
        A('li ${0},0xFFFFFFFF'.format(i))
        
    base =  0xFFFA
    for i in range(1, 32):
        x = i % 16
        rotate = (base << x) & 0xFFFF | base >> (16 - x)
        A('andi ${0},${0},{1}'.format(i,rotate))
    A(check_and_exit())

r.gen(my_gen1)
r = gen('andi_2')
def my_gen2(A,C,E):
    for i in range(0, 32):
        A('li ${},{}'.format(i,random.choice(range(2**32))))

    for i in range(4096):
        A('li ${},{}'.format(random.choice(range(32)),random.choice(range(2**32))))
        A('li ${},{}'.format(random.choice(range(32)),random.choice(range(2**32))))
        A('andi ${0},${1},{2}'.format(random.choice(range(32)),random.choice(range(32)),random.choice(range(2**16))))
        A('andi ${0},${1},{2}'.format(random.choice(range(32)),random.choice(range(32)),random.choice(range(2**16 - 10,2**16))))
        A('andi ${0},${1},{2}'.format(random.choice(range(32)),random.choice(range(32)),random.choice(range(0,10))))
    A(check_and_exit())

r.gen(my_gen2)