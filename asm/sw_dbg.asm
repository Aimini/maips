#
#    prepare for debug environment.
#    none instruction was implemented before this.
#    register $s0 - $s7 will be filled with (1 << n, $Sn) by modelsim,
#    and $v0 will be filled with 0xffff0000
#
#    modelsim will excute some operation when detect wirte data at
#     address 0xffff0000:
#     0  : check argument memory unit,print value from 0xffff0004 - 0xffff001C
#     1  : end simulate , $finish
#
#
.text
    sw  $s1,4($v0)
    sw  $s2,8($v0)
    sw  $s3,12($v0)
    sw  $s4,16($v0)
    sw  $s5,20($v0)
    sw  $s6,24($v0)
    sw  $s7,28($v0)
    sw  $s0,0($v0)