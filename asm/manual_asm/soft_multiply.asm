.text
    li	     $s0, 0x12# a
    li      $s1, 0x12 #b
    li      $s2, 0  # low 32bit
    li      $s3, 0  # high 32bit
    # result  = a0 * b + a1* b + ...
    # get b[0]
    andi        $s4 ,$s1, 1
    # b[31:1]
    srl         $s1, $s1, 1

    li          $t5, 32
do_multiply_once:
    # get a[0]
    blez         $t5,next
    addi	 $t5, $t5, -1
    andi        $t0,$s0,1
    srl         $s0,$s0,1
    blez        $t0,just_shift
    # add may cause carry, so we should check least significant
    # bit in b and high intermidate reuslt , caculate bit 0 ,then fill
    # bit 0 add result to low intermidate reuslt,and caculate
    # high intermidate reuslt[31:1] and b[31:1] Subsequently
    # $t0 = high[0]
    and      $t0,$s3,1
    # is high[0] + b[0] make 1 
    xor      $t1,$t0,$s4
    sll      $t1,$t1,31
    srl      $s2,$s2,1
    or       $s2,$s2,$t1
    # itermidate result shift right
    srl      $s3,$s3,1
    # is high[0] + b[0] == 2 , carry
    and      $t1,$t0,$s4
    addu     $s3,$s3,$t1
    addu     $s3,$s3,$s1
    j do_multiply_once
just_shift:
    and      $t0,$s3,1
    sll      $t0,$t0,31
    srl      $s2,$s2,1
    or       $s2,$s2,$t0
    srl      $s3,$s3,1
j do_multiply_once 

next:
    
    
