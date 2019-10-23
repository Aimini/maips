.data
   str1: .asciiz "Hello World!\n"
   str2: .asciiz ""
   str3: .asciiz "AI"

.text
    addi    $sp, $sp, -16
    sw      $s0, 0($sp)
    sw      $s1, 4($sp)
    sw      $s2, 8($sp)
    sw      $s3, 12($sp)
    la      $s0, str1
print_str_begin:
    lb      $s1, 0($s0)
    blez    $s1, print_str_end
    lui     $s2, 0xffff
    sw		$s1,4($s2) # store char
    li      $s1,3 
    sw      $s1,0($s2)# call function print char
    addi    $s0,$s0,1
    j       print_str_begin
print_str_end:

#     la      $s0, str1
# .print_str2_begin:
#     $s1     lw,  $(s0)
#     blez    $s1, print_str2_end
#     lui     $s2, 0xffff
#     sw		$s1,4($s2) # store 4 char
#     li      $s3,3 
#     sw      $s3,0($s2)# call function print 4 char
#     clz     $s3, $s1  # if $s1 contain '\0' it's must has one byte of zero
#     addu	$s3, $s1, s3   # $s1 - 0x00FFFFFF 
    
#     addu    $s1,$s1,4
#     j       print_str2_begin
# .print_str2_end:
lw      $s0, 0($sp)
lw      $s1, 4($sp)
lw      $s2, 8($sp)
lw      $s3, 12($sp)
addi    $sp, $sp, 16
    