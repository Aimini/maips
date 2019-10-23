.globl main
.globl __start

.text
__start:
    lui  $gp,_gp_hi
    ori  $gp,$gp,_gp_lo
    lui  $sp,0x1041
    j   main
    jr  $31
