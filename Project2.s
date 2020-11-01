.data
reply:	.space 10

.text
main:

	li $v0, 8
	la $a0, reply
	la $a1, 11
	syscall

	la $s1, reply
	lb $a0, 9($s1)
	
	li $v0, 11
	syscall

	li $v0, 10
	syscall