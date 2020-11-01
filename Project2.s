.data
reply:	.space 10
msg:	.asciiz "Invalid input"

.text
main:
	li $v0, 8
	la $a0, reply
	la $a1, 11
	syscall
	
	la $s2, reply

	la $s1, reply
	addi $s1, $s1, 9

First:	lb $a0, 0($s1)

Loop:	li $v0, 11
	syscall

	slt $t0, $s1, $s2
	bne $t0, $zero, End
	j Add 

Add:	addi $s1, $s1, -1
	j First 

End:	li $v0, 10
	syscall