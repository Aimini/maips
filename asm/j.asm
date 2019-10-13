.text
j start
.text 0x004FFFF8
start:
ori $1,1
j mark0

.text 0x00500000
mark0:
addu $2,$2,$1
j mark1

.text 0x0728448C
mark1:
addu $2,$2,$1
j mark2

.text 0x0889B000
mark2:
addu $2,$2,$1
j mark3

.text 0x0E45E558
mark3:
addu $2,$2,$1
j mark4

.text 0x0F183164
mark4:
addu $2,$2,$1
j mark5

.text 0x0F9F6DE0
mark5:
addu $2,$2,$1
j mark6

.text 0x0FA21DC0
mark6:
addu $2,$2,$1
j mark7

.text 0x0FEB0928
mark7:
addu $2,$2,$1
j mark8

.text 0x0FF5EC50
mark8:
addu $2,$2,$1
j mark9

.text 0x0FFF071C
mark9:
addu $2,$2,$1
j mark10

.text 0x0FFF26A0
mark10:
addu $2,$2,$1
j mark11

.text 0x0FFF55EC
mark11:
addu $2,$2,$1
j mark12

.text 0x0FFF7CB8
mark12:
addu $2,$2,$1
j mark13

.text 0x0FFFECE8
mark13:
addu $2,$2,$1
j mark14

.text 0x0FFFF000
mark14:
addu $2,$2,$1
j mark15

.text 0x0FFFF3EC
mark15:
addu $2,$2,$1
j mark16

.text 0x0FFFF988
mark16:
addu $2,$2,$1
j mark17

.text 0x0FFFFDAC
mark17:
addu $2,$2,$1
j mark18
mark18:

lui $17, 0xffff
li  $22,  0x00000012
sw  $22, 4($17)
sw  $2, 8($17)
li  $22, 0x00000001
sw  $22, 0($17) 

lui $15, 0xffff
sw  $0,   4($15)
lui $18, 0x0001
sw  $18, 0($15) 

lui $15, 0xffff
sw  $0, 0($15)
