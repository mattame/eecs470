	lda $r1,1
        lda $r2,100
loop:	mulq $r1,$r1,$r1
        subq $r2,1,$r2
        bne $r2,loop
        call_pal 0x555

