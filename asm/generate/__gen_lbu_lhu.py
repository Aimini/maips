from __numutil import *
from __regutil import *
from __asmutil import *
from __gencom import *
import random
import math
import itertools
import sys


######################
# A: asm writer function
# reg:
# reg_val : which value store in reg
# immed:

def gen_when(load_cmd):
    byte_per_unit = 1
    if load_cmd == "lbu":
        cmd = "sb"
        byte_per_unit = 1
    else:
        cmd = "sh"
        byte_per_unit = 2

    total_bit = byte_per_unit*8
    max_limit = 2**total_bit

    def my_gen1(A, au):
        def gen_assert_one(A, au, reg_base, base, offset, target_value):
            au.li(reg_base, base)
            value_mask = max_limit - 1
            rt = regutil.get_one([reg_base])
            au.li(rt, target_value)
            A(f"{cmd}      {rt},{offset}({reg_base})")
            rt = regutil.get_one()
            A(f"{load_cmd} {rt},{offset}({reg_base})")
            au.assert_equal(rt,  target_value)

        data_segment_base = 0x10010000

        def convert_adddress(count):
                return data_segment_base + count*byte_per_unit

        def get_random_offset(conut):
            addr = convert_adddress(conut)
            offset = numutil.s16()
            return addr - offset, offset

        def test_one_address(count, offset):
            address = convert_adddress(count)
            base_address = address - offset
            gen_assert_one(A, au, regutil.get_one(), base_address, offset, memory_datas[count])

        def test_by_iter(word_cout, offset):
            parameter_iter_pass(word_cout, offset, callback=test_one_address)

        count_limit = int(2**12 / byte_per_unit)  # 2k half word
        data_segment_base = 0x10010000
        def data_gen_funct(): return numutil.below(max_limit)
        memory_datas = [data_gen_funct() for x in range(count_limit)]

        offset_bound = numutil.bound(16, True)
        for i in range(32):
            au.li(reg_list[i], 0)

        test_by_iter(range(count_limit), 0)
        test_by_iter(lambda: numutil.below(count_limit), 5*offset_bound)
        test_by_iter(repeat_function(numutil.below, count_limit, k=5000), numutil.s16)
        test_by_iter(lambda: numutil.below(count_limit), repeat_function(numutil.s16, k=5000))

        # move content form one cell to another cell
        for i in range(5000):
            read_base, read_offset = get_random_offset(numutil.below(count_limit))
            write_base, write_offset = get_random_offset(numutil.below(count_limit))
            base1, base2 = regutil.get_random(k=2)
            au.li(base1, read_base)
            au.li(base2, write_base)
            A(f"{load_cmd} {base1} {read_offset} ({base1})")
            A(f"{cmd}      {base1} {write_offset}({base2})")

        #  read memory
        # do some math
        # write back
        def do_some_math(count):
            offset = numutil.s16()
            base_address, offset = get_random_offset(numutil.below(count_limit))
            reg = regutil.get_one()
            au.li(reg, base_address)
            A(f"{load_cmd} {reg},{offset}({reg})")
            for i in range(random.choice(range(20))):
                A(get_random_alu())
            reg = regutil.get_one()
            au.li(reg, base_address)
            A(f"{cmd} {reg},{offset}({reg})")

        parameter_iter_pass(repeat_function(numutil.below, count_limit, k=5000), callback=do_some_math)

        au.check_and_exit()

    r = gen(load_cmd)
    r.gen(my_gen1)


gen_when(sys.argv[1])
