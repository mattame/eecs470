//test program without nops
// same as nop, but no nops
  
  
      lda $r5, 10
     
      lda $r3, 2
      
      mulq $r3, $r5, $r7
      
      lda $r8, 4
      
loop:
      subq $r8, $r7, $r7
      
      bge $r7, loop
      
      addq $r3, $r3, $r3    

      call_pal 0x555
