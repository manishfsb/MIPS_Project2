.data
												
reply:	.space 10						#Taking 1000 characters as input
msg1:	.asciiz "Invalid input"

.text
main:	li $s0, 0							#Register to store sum of the values of the characters in our base system
	li $s5, 30							#Initializing register to 29, the base with my Id. So that we can multiply by 29 with each character from the back
	li $s6, 1							#A register to keep on multiplying by our base, since the last character will be the value only

	li $t0, 0							#Boolean register that stores 0 if we haven't reached a valid character, 1 if we have
	li $t1, 0							#Register to track only 3 characters after the first valid character						
	li $t2, 0							#another boolean register
							
	li $v0, 8						
	la $a0, reply							#Reading input string
	li $a1, 11
	syscall
 	
	la $s4, reply							#Loading the address of reply in $s1 so that we can add 1 to access each character							#Loading address of reply in $s2 as well so that we can check if we've finished scanning the first character
	addi $s1, $s4, 9
						
First:	blt $s1, $s4, call							
	lb $a0, 0($s1)

LoopA:
	beq $a0, 32, After2 
	beq $a0, 9, After2
	beq $a0, 0, After2						#Checking for space, tab, null and enter
	beq $a0, 10, After2
	
	beq $t2, 1, invali
	j Save
	li $t2, 1							#Changing the register to 1 to indicate we have reached our first valid character
	la $t3, 0($s1)
	move $a1, $t3
	addi $s1, $s1, -4
	j First

After2:	
	addi $s1, $s1, -1
	j First

Sub:	lb $a0, 0($a1)
	j Filter
									#Load the last character to $a0 and go to filter to check if it's invalid or a lowercase, uppercase or a number
After:									#checking if s1 is less than s4 which is the address of the first character, at which point we terminate 
	addi $a1, $a1, -1
	j Sub

Base:	mult $s6, $s5
	mflo $s6
	j After								#decrement address of reply by 1 until we've reached the beginning of the string

After1:	beq $a1, $s4, skip						#if the filling characters are either the first or last character, we don't check further. If they're not, we check left and right to see if they're invalid

	beq $t0, $zero, After
	lb $a0, -1($a1)

skip:	beq $a0, 32, After 
	beq $a0, 9, After
	beq $a0, 0, After						#Checking for space, tab, null and enter
	beq $a0, 10, After
	j invalid					
	
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
		
							
numeric:
	addi $t1, $t1, 1
	bgt $t1, 4, return
	li $t0, 1
	li $s2, -48	
	add $s3, $a0, $s2
	mult $s6, $s3
	mflo $s7							#if character is a numeric character
	add $s0, $s0, $s7						#storing the sum in $s0 after each character so that we can have the total value
	j Base
	

Lower:	addi $t1, $t1, 1
	bgt $t1, 4, return
	li $t0, 1
	li $s2, -87	
	add $s3, $a0, $s2
	mult $s3, $s6
	mflo $s7							#if character is lowercase
	add $s0, $s0, $s7						#$a0 % 87 could also have been done, instead of subtracting in all three cases
	j Base	

Upper:	addi $t1, $t1, 1
	bgt $t1, 4, return
	li $t0, 1
	li $s2, -55	
	add $s3, $a0, $s2
	mult $s3, $s6
	mflo $s7 							#if character is uppercase
	add $s0, $s0, $s7
	j Base
									#all three branches will eventually lead back to the next character

invalid:li $v0, -1
	j return

return:	move $v0, $s0
	jr $ra

call:	jal Sub
							
print:	beq $t1, 0, invali
	beq $v0, -1, invali

	li $v0, 1
	add $a0, $s0, $zero						#print the total value stored in $s0 across all three cases
	syscall	
	j End
	

invali: li $v0, 4
	la $a0, msg1
	syscall 
	
End:	li $v0, 10							#terminate once the output is printed
	syscall

	
	

	

	

	

	