.globl __start
.globl __set_status
.globl call_errorEPC
.globl call_EPC
.text
__start:
    lui  $gp,_gp_hi
    ori  $gp,$gp,_gp_lo
    lui  $sp,0x9040

    li  $k1,100             #won't work
__loop:
    addiu   $k1,$k1,-1
    blez    $k1,__end

    la      $k0,call_EPC
    mtc0    $k0,$14, 0 #set EPC
    la      $k0,call_errorEPC
    mtc0    $k0,$30, 0 #set errorEPC

    la  $ra, __loop
    eret

__end:
    lui  $k0,0xffff
    sw   $0, 0($k0)

__set_status:
    mtc0 $a0,$12,0
    jr	 $ra
    


    
