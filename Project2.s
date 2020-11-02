.data
reply:	.space 10
msg:	.asciiz "Invalid input"

.text
main:
	li $v0, 4
	la $a0, msg
	syscall

	li $s1, 28
	li $s2, 21952
	mult $s1, $s2
	
	li $v0, 1
	mflo $a0
	syscall 

	li $v0, 10
	syscall