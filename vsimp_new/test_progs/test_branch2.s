      nop
      addq $r2,1,$r2
      subq $r3,1,$r3
      nop
l1:   beq $r1,l5
l2:   beq $r1,l7
l3:   nop
l4:   nop
l5:   beq $r2,l4
l6:   beq $r1,l8
l7:   addq $r0,1,$r0
l8:   beq $r2,l1
l9:   beq r3,l1
l10:  call_pal 0x555
