.text 
	addi $s0,$0,4
	j start
.text 0x004FFFF4
	start:
	addi $s0,$0,4
	j add4
.text 0x00600000
	add4: 
	addi $s0,$0,4
	jal add8
.text 0x00700000
	add8: 
	addi $s0,$0,8