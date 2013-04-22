
lda $r2, 0x0001
lda $r1, 0x00f3

and   $r1, $r2, $r3   
xor   $r1, $r2, $r3  
eqv   $r1, $r2, $r3 
bis   $r1, $r2, $r3   
ornot $r1, $r2, $r3   
bic   $r1, $r2, $r3   


lda $r2, 0x0f02
lda $r3, 0x0003

srl  $r1, $r2, $r4   
srl  $r1, $r3, $r4  
sll  $r1, $r2, $r4 
sll  $r1, $r3, $r4    


lda  $r5, 0xf013

call_pal 0x555

sra  $r5, $r2, $r6    
sra  $r5, $r3, $r6   

call_pal 0x555 
