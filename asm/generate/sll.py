from gen_com import *

g = gen("sll")
def my_gen(A,R,C,E):
    R(0)
    A("ori $1,0x0001")
    R(0x0002)
    for i in range(2,32):
        A("sll ${0},$1,{1}".format(i,i));
        R(1 << i)
    A("sll $1,$1,0");
    A("sll $1,$1,1");
    C(20,21)
    E(20)

g.gen(my_gen)

g = gen("sll_2")
def my_gen2(A,R,C,E):
    R(0)
    A("ori $31,0x1001")
    for i in range(1,32):
        A("sll ${0},$31,{1}".format(i,i));
        R((0x1001 << i) &0xFFFFFFFF)
    C(21,22)
    E(21)

g.gen(my_gen2)