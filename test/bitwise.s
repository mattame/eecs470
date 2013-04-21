//tests the bitwise instructions straightforwardly

lda $r2, 0x0001
lda $r1, 0x00f3

and   $r1, $r2, $r3   // 0x0001
xor   $r1, $r2, $r3   // 0x00f2
eqv   $r1, $r2, $r3   // 0xff0d
bis   $r1, $r2, $r3   // 0x00f3
ornot $r1, $r2, $r3   // 0xffff
bic   $r1, $r2, $r3   // 0x00f2

lda $r2, 0x0f02
lda $r3, 0x0003

srl  $r1, $r2, $r4    // 0x003c
srl  $r1, $r3, $r4    // 0x001e
sll  $r1, $r2, $r4    // 0x03cc
sll  $r1, $r3, $r4    // 0x0798

lda  $r5, 0xf013
sra  $r5, $r2, $r6    // 0xfc04
sra  $r5, $r3, $r6    // 0xfe02 
