#hazard tests for EXMEM and MEMWB with sw and lw

.data
array: .word 0,1,2,3,4,5

la $s0, array
addi $t0, $zero, 5
addi $t1. $t0, $zero
lw $v0, 0($s0)
sw $v0, 4($s0)
