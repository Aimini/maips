
fp = 0
count = 0
prev_addr = 0x00400000

def fill_to_next(addr):
    global prev_addr
    global count
    for x in range(int((addr - prev_addr)/4) - count):
        fp.write('nop\n');
    prev_addr = addr
    count = 0


def insert_instruction(str):
    fp.write('{}\n'.format(str))
    global count
    count += 1

with open("test_j_jal.asm",mode="w") as ft:
    fp = ft
    fp.write(".text\n")
    insert_instruction('addi $s0, $0, 4')
    insert_instruction('j start')
    insert_instruction('addi $s0, $0, -10000')
    fill_to_next(0x004FFFF4)
    insert_instruction('start: addi $s0,$s0,4')
    insert_instruction('j add4')
    insert_instruction('addi $s0, $0, -10000')
    fill_to_next(0x00600000)
    insert_instruction('add4: addi $s0,$s0,4')
    insert_instruction(' jal add8')
    insert_instruction('addi $s0, $0, -10000')
    fill_to_next(0x00700000)
    insert_instruction('add8: addi $s0,$s0,8')
    insert_instruction('addi $v0,$0,10')
    insert_instruction('nop')
    insert_instruction('nop')
    insert_instruction('nop')
    insert_instruction('syscall')

