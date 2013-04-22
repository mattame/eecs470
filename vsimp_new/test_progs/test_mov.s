     bsr $r26,go
end: call_pal 0x555
go:  mov 1,$r3
     addq $r31,$r31,$r31
     ret

