.data
												
reply:	.space 10							#Taking 10 characters as input
msg1:	.asciiz "Invalid input"

.text
main:	li $s0, 0							#Register to store sum of the values of the characters in our base system
	li $s5, 30							#Initializing register to 29, the base with my Id. So that we can multiply by 29 with each character from the back
	li $s6, 1							#A register to keep on multiplying by our base, since the last character will be the value only

	li $t0, 0							#Boolean register that stores 0 if we haven't reached a valid character, 1 if we have
	li $t1, 0							#Register to track only 3 characters after the first valid character
							
	li $v0, 8						
	la $a0, reply							#Reading input string
	li $a1, 11
	syscall
 	
	la $s4, reply							#Loading the address of reply in $s1 so that we can add 1 to access each character							#Loading address of reply in $s2 as well so that we can check if we've finished scanning the first character
	addi $s1, $s4, 9
	addi $t5, $s4, 9
						
First:	lb $a0, 0($s1)							
	j Filter							#Load the last character to $a0 and go to filter to check if it's invalid or a lowercase, uppercase or a number

After:									#checking if s1 is less than s4 which is the address of the first character, at which point we terminate 
	addi $s1, $s1, -1
	blt $s1, $s4, print

	beq $t1, 4, bool
	j First

Base:	mult $s6, $s5
	mflo $s6
	j After								#decrement address of reply by 1 until we've reached the beginning of the string

After1:	beq $s1, $s4, Middle						#if the filling characters are either the first or last character, we don't check further. If they're not, we check left and right to see if they're invalid
	beq $s1, $s5, Middle

	lb $a0, -1($s1)
	
	beq $t0, $zero, First

	beq $a0, 32, First 
	beq $a0, 9, First
	beq $a0, 0, First						#Checking for space, tab, null and enter
	beq $a0, 10, First
	
	j invalid						
	
	 
	bne $t0, $zero, invalid
	j After
	
Filter:	
	beq $a0, 32, After1 
	beq $a0, 9, After1
	beq $a0, 0, After1						#Checking for space, tab, null and enter
	beq $a0, 10, After1						
	
	blt $a0, 48, invalid						
	bgt $a0, 115, invalid
	 
	ble $a0, 115, more

	
more:	
	bge $a0, 97, Lower						#checking if characters are valid in our base system, if they are, they will go to the respective branches	
	bgt $a0, 83, invalid
	bgt $a0, 64, Upper
	bgt $a0, 57, invalid
	bge $a0, 48, numeric
	
bool:	li $t0, 0
	j First	
							
numeric:
	addi $t1, $t1, 1
	bgt $t1, 4, invalid
	li $t0, 1
	li $s2, -48	
	add $s3, $a0, $s2
	mult $s6, $s3
	mflo $s7							#if character is a numeric character
	add $s0, $s0, $s7						#storing the sum in $s0 after each character so that we can have the total value
	j Base
	

Lower:	addi $t1, $t1, 1
	bgt $t1, 4, invalid
	li $t0, 1
	li $s2, -87	
	add $s3, $a0, $s2
	mult $s3, $s6
	mflo $s7							#if character is lowercase
	add $s0, $s0, $s7						#$a0 % 87 could also have been done, instead of subtracting in all three cases
	j Base	

Upper:	addi $t1, $t1, 1
	bgt $t1, 4, invalid
	li $t0, 1
	li $s2, -55	
	add $s3, $a0, $s2
	mult $s3, $s6
	mflo $s7 							#if character is uppercase
	add $s0, $s0, $s7
	j Base
									#all three branches will eventually lead back to the next character

invalid:li $v0, 4
	la $a0, msg1							#print invalid input a string stored in msg if a character is invalid
	syscall 
	j End
							
print:	beq $t1, 0, invalid

	li $v0, 1
	add $a0, $s0, $zero						#print the total value stored in $s0 across all three cases
	syscall	
	j End

End:	li $v0, 10							#terminate once the output is printed
	syscall

	
	

	

	

	

	