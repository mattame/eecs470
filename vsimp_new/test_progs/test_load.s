	lda  $r0, 0
	stq  $r0, 0x38($r31)
	addq $r0, 15, $r0
	stq  $r0, 0x48($r31)
	lda  $r1, 24
	addq $r1, $r0, $r2
	mulq $r0, 2, $r3
	stq  $r3, 0x40($r31)
	call_pal 0x555
