.globl main
.globl __start

.text
__start:
    la   $gp,_gp
    j    main
    jr   $31
