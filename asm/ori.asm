.text
ori $1,$0,0x000a
ori $2,$1,0x0014
ori $3,$2,0x0028
ori $4,$3,0x0050
ori $5,$4,0x00a0
ori $6,$5,0x0140
ori $7,$6,0x0280
ori $8,$7,0x0500
ori $9,$8,0x0a00
ori $10,$9,0x1400
ori $11,$10,0x2800
ori $12,$11,0x5000
ori $13,$12,0xa000
ori $14,$13,0x4001
ori $15,$14,0x8002
ori $16,$0,0x0005
ori $17,$0,0x000a
ori $18,$0,0x0014
ori $19,$0,0x0028
ori $20,$0,0x0050
ori $21,$0,0x00a0
ori $22,$0,0x0140
ori $23,$0,0x0280
ori $24,$0,0x0500
ori $25,$0,0x0a00
ori $26,$0,0x1400
ori $27,$0,0x2800
ori $28,$0,0x5000
ori $29,$0,0xa000
ori $30,$0,0x4001
ori $31,$0,0x8002

    lui $1, 0xffff
    sw  $0,   4($1)
    lui $6, 0x0001
    sw  $6, 0($1) 

    lui $1, 0xffff
    sw  $0, 0($1)
