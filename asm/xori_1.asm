.text
xori $1,$0,0x0006
xori $2,$1,0x000c
xori $3,$2,0x0018
xori $4,$3,0x0030
xori $5,$4,0x0060
xori $6,$5,0x00c0
xori $7,$6,0x0180
xori $8,$7,0x0300
xori $9,$8,0x0600
xori $10,$9,0x0c00
xori $11,$10,0x1800
xori $12,$11,0x3000
xori $13,$12,0x6000
xori $14,$13,0xc000
xori $15,$14,0x8001
xori $16,$15,0x0003
xori $17,$16,0x0006
xori $18,$17,0x000c
xori $19,$18,0x0018
xori $20,$19,0x0030
xori $21,$20,0x0060
xori $22,$21,0x00c0
xori $23,$22,0x0180
xori $24,$23,0x0300
xori $25,$24,0x0600
xori $26,$25,0x0c00
xori $27,$26,0x1800
xori $28,$27,0x3000
xori $29,$28,0x6000
xori $30,$29,0xc000
xori $31,$30,0x8001

lui $31, 0xffff
sw  $0,   4($31)
lui $2, 0x0001
sw  $2, 0($31) 

lui $31, 0xffff
sw  $0, 0($31)
