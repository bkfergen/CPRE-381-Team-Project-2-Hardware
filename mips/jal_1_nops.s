 .data 
 
 .text 
 
 .globl main
 
 main:
 	# start test
 	jal test
	NOP
	NOP
	NOP
 	
 
 test: 
	addi $t1, $0, 25	# testing basic functionaly of jumpting to correct section and loading $ra
	halt			# end program
