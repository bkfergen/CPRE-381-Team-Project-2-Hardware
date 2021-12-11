# Test 0 - SW (store word)
#
# The objective of this test assembly file will be to check if an arbritrary data
# value stored in any of the argument, temporary, and saved registers, can be put
# into the starting address allocation of the data segment (0x10010000).
# My justification for including only these registers is that I think that these are
# likely going to involved in holding data that needs to potentially be sent out to data
# segment; therefore, the other remaining registers are not included in this test. The
# functionality of those other registers will be checked in other tests.

.data
.text
.globl main
main:
    	# Start Test
    	addi 	$t1, $0, 1
	addi	$t2, $0, 2
    	bne 	$t2, $t1, exit
	addi	$t3, $0, 5

exit:
    	# Exit program
		halt
    	li $v0, 10
    	syscall
