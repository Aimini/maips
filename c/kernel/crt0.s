.globl __start
.globl exception_handler
.globl syscall_handler
.globl interrupt_handler
.globl print_booting_info
# external data
.extern clock_count
.equ user_text, 0x00400000 
.equ compare,   999 
.data
.align 4
    user_sp:     .word 0x1200FF00 # reserve 0x100byte
    kernel_sp:   .word 0x90040000

.text
__start:
    la   $k0, user_sp
    lw   $sp, 0($k0)
    
    la  $k0,_bss_start
    la  $k1,_bss_end
initial_bss:
    bge     $k0,  $k1, initial_bss_end
    sw      $0 ,0($k0)
    addiu   $k0,  $k0, 4
    b       initial_bss
initial_bss_end:

    li $k0, compare
    mtc0 $k0,$11 # compare overflow each 2000 tick

    li $k0, 0x00800000
    mtc0 $k0, $13 # claer cause set iv

    li $k0, 0x00000401
    mtc0 $k0,$12  # enable clock interrupt, clear bev
    
    jal print_booting_info
    la   $k0, user_text
    jr   $k0


.org 0x180 # exception
    j protected_exception_reg

.org 0x200
    j protected_interrupt_reg

protected_exception_reg:
addiu	$sp,$sp,-108
#save c0_epc 
mfc0	$k1,$14     
sw	    $k1,100($sp)
#save c0_status
mfc0	$k1,$12
sw	    $k1,96($sp)
#enable interrupt
#save lo
mflo	$k0
sw	    $k0,92($sp)
#save hi
mfhi	$k0
sw	    $k0,88($sp)
 #cause , passed to exception_handler

sw	    $a1,32($sp)
mfc0	$a1,$13

#c0_status
ins	    $k1,$zero,0x1,0x4 
mtc0	$k1,$12    
sw	    $at,16($sp)
sw	    $v0,20($sp)
sw	    $v1,24($sp)
sw	    $a0,28($sp)
sw	    $a2,36($sp)
sw	    $a3,40($sp)
sw	    $t0,44($sp)
sw	    $t1,48($sp)
sw	    $t2,52($sp)
sw	    $t3,56($sp)
sw	    $t4,60($sp)
sw	    $t5,64($sp)
sw	    $t6,68($sp)
sw	    $t7,72($sp)
sw	    $t8,76($sp)
sw	    $t9,80($sp)
sw	    $ra,84($sp)
sw	    $s0,104($sp)

    andi    $s0,  $a1,   0x7C
    xori    $s0,  $s0,   0x20 #check syscall
    blez    $s0, __turn_syscall_exception
    move    $a0,  $a1
    jal     exception_handler

__turn_syscall_exception:
    jal     syscall_handler
di
# because syscall put return value value in $v0
blez    $s0, ___reserve_syscall_v0
lw	    $v0,20($sp)
___reserve_syscall_v0:
lw	    $s0,104($sp)
lw	    $k0,92($sp)
lw	    $at,16($sp)
mtlo	$k0
lw	    $k0,88($sp)
lw	    $v1,24($sp)
lw	    $a0,28($sp)
lw	    $a1,32($sp)
lw	    $a2,36($sp)
lw	    $a3,40($sp)
lw	    $t0,44($sp)
mthi	$k0
lw	    $t1,48($sp)
lw	    $t2,52($sp)
lw	    $t3,56($sp)
lw	    $t4,60($sp)
lw	    $t5,64($sp)
lw	    $t6,68($sp)
lw	    $t7,72($sp)
lw	    $t8,76($sp)
lw	    $t9,80($sp)
lw	    $k1,100($sp)
lw	    $ra,84($sp)
addiu	$k1,$k1,4
mtc0	$k1,$14     #c0_epc
lw	    $k1,96($sp)

addiu	$sp,$sp,108
mtc0	$k1,$12    #c0_status
eret



protected_interrupt_reg:
        
    addiu	$sp,$sp,-104
    sw	    $a0, 28($sp)
    sw	    $a1, 32($sp)
    mfc0	$a0, $13 
    mfc0	$k1, $12
    and     $k1, $k1, $a0
    andi    $k1, $k1, 0xFF00
    andi    $k0, $k1, 0x400
    blez    $k0,__no_clock_interrupt  #not a clock interrupt

    la      $k0,clock_count
    lw      $a1,0($k0)
    addiu   $a1,$a1,1
    sw      $a1,0($k0)

    xori    $k0,$k1,0x400
    bgtz    $k0,__no_clock_interrupt #not only clock interrupt
    ins     $a0,$0, 10, 1
    mtc0    $a0,$13

    lw	    $a0, 28($sp)
    lw	    $a1, 32($sp)
    addiu	$sp,$sp,104
    eret

__no_clock_interrupt:
    addu    $k0, $a0,$0
    ins     $k0, $0, 8, 8
    mtc0    $k0, $13
    #save c0_epc 
    mfc0	$k1,$14     
    sw	    $k1,100($sp)
    #save c0_status
    mfc0	$k1,$12
    sw	    $k1,96($sp)

    #save lo
    mflo	$k0
    sw	    $k0,92($sp)
    
    #save hi
    mfhi	$k0
    sw	    $k0,88($sp)

    # using a0 pass cause

    #c0_status  enable interrupt
    ins	    $k1,$zero,0x1,0x4 
    mtc0	$k1,$12    
    sw	    $at,16($sp)
    sw	    $v0,20($sp)
    sw	    $v1,24($sp)
    sw	    $a2,36($sp)
    sw	    $a3,40($sp)
    sw	    $t0,44($sp)
    sw	    $t1,48($sp)
    sw	    $t2,52($sp)
    sw	    $t3,56($sp)
    sw	    $t4,60($sp)
    sw	    $t5,64($sp)
    sw	    $t6,68($sp)
    sw	    $t7,72($sp)
    sw	    $t8,76($sp)
    sw	    $t9,80($sp)
    sw	    $ra,84($sp)


    jal     interrupt_handler


    di
    lw	    $k0,92($sp)
    lw	    $at,16($sp)
    lw	    $v0,20($sp)
    mtlo	$k0
    lw	    $k0,88($sp)
    lw	    $v1,24($sp)
    lw	    $a0,28($sp)
    lw	    $a1,32($sp)
    lw	    $a2,36($sp)
    lw	    $a3,40($sp)
    lw	    $t0,44($sp)
    mthi	$k0
    lw	    $t1,48($sp)
    lw	    $t2,52($sp)
    lw	    $t3,56($sp)
    lw	    $t4,60($sp)
    lw	    $t5,64($sp)
    lw	    $t6,68($sp)
    lw	    $t7,72($sp)
    lw	    $t8,76($sp)
    lw	    $t9,80($sp)
    lw	    $k1,100($sp)
    lw	    $ra,84($sp)
    mtc0	$k1,$14     #c0_epc
    lw	    $k1,96($sp)

    addiu	$sp,$sp,104
    mtc0	$k1,$12    #c0_status
    eret

    


