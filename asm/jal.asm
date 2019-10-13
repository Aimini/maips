.text
j start
.text 0x004FFFF8
start:
ori $1,1
j mark0

.text 0x00500000
mark0:
addu $2,$2,$1
jal mark1

.text 0x0FFB2AB0
mark1:
addu $2,$2,$1
jal mark2

.text 0x0FFF4FDC
mark2:
addu $2,$2,$1
jal mark3

.text 0x0FFFB290
mark3:
addu $2,$2,$1
jal mark4

.text 0x0FFFCF78
mark4:
addu $2,$2,$1
jal mark5

.text 0x0FFFD8C0
mark5:
addu $2,$2,$1
jal mark6

.text 0x0FFFED70
mark6:
addu $2,$2,$1
jal mark7

.text 0x0FFFF95C
mark7:
addu $2,$2,$1
jal mark8

.text 0x0FFFFA24
mark8:
addu $2,$2,$1
jal mark9

.text 0x0FFFFD4C
mark9:
addu $2,$2,$1
jal mark10

.text 0x0FFFFEBC
mark10:
addu $2,$2,$1
jal mark11
mark11:

lui $14, 0xffff
sw  $0,   4($14)
lui $10, 0x0001
sw  $10, 0($14) 

lui $14, 0xffff
sw  $0, 0($14)
