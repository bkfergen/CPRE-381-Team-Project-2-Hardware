
j jump0 
addi $t0,$zero,1

jump0:
addi $t1,$zero,1
beq  $zero, $zero, jump1
addi $t2,$zero,1

jump1:
addi $t3, $zero, 1
bne  $t3, $zero, jump3
addi $t4, $zero, 1

jump2:
addi $t7, $zero, 1
jr $ra

jump3:
addi $t5, $zero, 1
jal jump2
j jump4
addi $t6, $zero, 1

jump4:
addi $t9, $zero, 1
