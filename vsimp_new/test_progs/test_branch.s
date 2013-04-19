	addq $r1,2,$r1
loc:    subq $r1,1,$r1
        beq $r1,loc
        call_pal 0x555
