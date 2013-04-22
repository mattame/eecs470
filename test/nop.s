//test program with nops
// this multiplies 2x10, puts it in r3, decrements until 0, breaks out, and  halts //
    
      lda $r5, 10
      nop
      lda $r3, 2
      nop
      mulq $r3, $r5, $r7
      nop
      lda $r8, 4
      nop
loop:
      subq $r8, $r7, $r7
      nop
      bge $r7, loop
      nop
      addq $r3, $r3, $r3    
      nop
      call_pal 0x555
      nop
