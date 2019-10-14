.data
msg: .asciiz "you print it!"
.text
    lui $s0,0xffff
    
    li      $s2, 3
    # "1234"
    li      $s1,0x34333231
    sw		$s1, 4($s0)
    sw    	$s2, 0($s0)
    # "567\n"
    li      $s1,0x0A373635
    sw		$s1, 4($s0)
    sw    	$s2, 0($s0)

    sw    	$0,  0($s0)