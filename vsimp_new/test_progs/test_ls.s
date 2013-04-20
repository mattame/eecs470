/*
	lda dest,10
	ldq dest,10(offsetbase)
	stq source,10(offsetbase)
*/

/*
   this will write the the value 0xFF to the location 1000 and beyond if correct,
   and 0xAA (or something else random) if incorrect
*/


        addq	$r5,55,$r5
	addq	$r1,10,$r1
        mulq    $r1,100,$r1
	stq	$r5,0($r1)
	ldq	$r6,0($r1)
        cmpeq   $r5,$r6,$r30
	bne	$r30,good
        br	bad

good: 	addq	$r4,255,$r4
loop1:	stq	$r4,0($r1)
        addq 	$r1,8,$r1
        addq    $r31,100,$r9
        mulq    $r9,10,$r9
        addq    $r9,80,$r9
	cmpule	$r9,$r1,$r30
        bne     $r30,done
        br      loop1

bad:   addq    $r4,170,$r4
       mulq    $r1,2,$r1 
loop2:  stq     $r4,0($r1)
        addq    $r1,8,$r1
        addq    $r31,100,$r9
        mulq    $r9,20,$r9
        addq    $r9,80,$r9
        cmpule  $r9,$r1,$r30
        bne     $r30,done
        br	loop2
	
done:
	call_pal 0x555
     
