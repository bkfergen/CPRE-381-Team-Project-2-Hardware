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

xor $t8, $t7, $t5
xori $t9, $t8, FF

or $s0, $t9, $zero
or $s0, $s0, $t8

ori $s1, $s0, FF00

slt $s1, $s1, $t0
slti $s2, $s1, F



