from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom  import *


###############
# add $2 n times, decided by jump time.
# at end of jump ,check $s == 2
###################
def my_gen(A,au):
    au.clear_reg()

    k = 5000
    start_addr = 0x004FFFF8
    gap = int((0x0FFFFFFF - start_addr)/k)
    jump_link = numutil.jl(k)
    start = jump_link[0]
    A(f"j mark{start}")
    A("nop")
    for x in range(k):
        addr = numutil.align_word(x * gap + start_addr)
        next_index = jump_link[x]
        next_mark = f"mark{next_index}" if next_index != start else "end"
        A(f"""
        .text {numutil.sx8(addr)}
        mark{x}:
        addiu $a0,$a0, 1
        j {next_mark}
        nop
        """)

    A("end:")
    au.assert_equal(reg_a0, k)
    au.check_and_exit()
    return "mars", "-r 0x00400000-0x0FFFFFFC -b"
r = gen('j')
r.gen(my_gen)
