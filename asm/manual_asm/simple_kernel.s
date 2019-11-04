.globl __start
.text
__start:
    li $ra, 0x00400000
    mtc0 $ra,$30
    li $ra,0
    eret
    