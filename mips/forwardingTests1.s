addi $t0, $zero, 1
addi $t1, $zero, 1
add  $t2, $t1, $zero
add  $t3, $t2, $t1
addiu $t4, $t3, 3
addu $t5, $t4, 5

and $t5, $t4, $zero
andi $t6, $t4, 7

lui $t6, FFFF

nor $t7, $t6, $t5
nor $t8, $t7, $zero