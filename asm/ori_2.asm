.text
ori $1,$0,0x0002
ori $2,$0,0x0004
ori $3,$0,0x0008
ori $4,$0,0x0010
ori $5,$0,0x0020
ori $6,$0,0x0040
ori $7,$0,0x0080
ori $8,$0,0x0100
ori $9,$0,0x0200
ori $10,$0,0x0400
ori $11,$0,0x0800
ori $12,$0,0x1000
ori $13,$0,0x2000
ori $14,$0,0x4000
ori $15,$0,0x8000
ori $16,$0,0x0001
ori $17,$0,0x0002
ori $18,$0,0x0004
ori $19,$0,0x0008
ori $20,$0,0x0010
ori $21,$0,0x0020
ori $22,$0,0x0040
ori $23,$0,0x0080
ori $24,$0,0x0100
ori $25,$0,0x0200
ori $26,$0,0x0400
ori $27,$0,0x0800
ori $28,$0,0x1000
ori $29,$0,0x2000
ori $30,$0,0x4000
ori $31,$0,0x8000

lui $5, 0xffff
sw  $0,   4($5)
lui $17, 0x0001
sw  $17, 0($5) 

    lui $5, 0xffff
    sw  $0, 0($5)
