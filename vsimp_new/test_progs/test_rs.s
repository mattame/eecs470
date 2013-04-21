	nop
	lda $r1,1
        lda $r2,100
loop:	mulq $r1,$r1,$r1
        subq $r2,1,$r2
        bne $r2,loop
        lda $r5,0x100
        stq $r1,0($r5)
        call_pal 0x555

