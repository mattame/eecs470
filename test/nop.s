//test program with nops

  
  
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
      
      addq $r3, $r3, $r3    
