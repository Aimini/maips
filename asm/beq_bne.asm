.text
    addi $a0,$0,0

    addi $s0,$0, 1
    addi $s1,$0, 2
    beq  $s0,$s1,wrong
    bne  $s0,$s1,next1
    j wrong
    j wrong

next1:
    addi $s2,$0,-5
    addi $s3,$0,-5
    bne  $s2,$s3,wrong
    beq  $s2,$s3,next2
    beq  $s2,$s3,wrong
    j wrong
    j wrong
next2:
    addi $s5, $0,-32768 # min immed
    addi $s6, $0,32767  #max immed
    beq  $s5, $s6, wrong
    bne  $s5, $s6, end
    bne  $s5, $s6, wrong
    bne  $s5, $s6, wrong
wrong:
    addi $a0,$0, -12321
    j   end

end:
###--my_syscall
    addi $v0, $0,  101 #assert $a0 != -12321
    addi $a1, $0, -12321
    nop
    nop
    nop
    syscall
###--else
    addi $a1, $0, -12321
    bne $a1, $a0, sys_nothing
    la,$v0, 4
    la,$a0, wrong_msg
    syscall
###--end_syscall
sys_nothing:

.data
    wrong_msg: .asciiz "wrong"