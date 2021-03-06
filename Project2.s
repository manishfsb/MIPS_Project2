.data
												
reply:	.space 1000							#Taking 1000 characters as input
msg:	.asciiz "Invalid input"
msg1:	.asciiz "Invalid input"

.text
main:	li $s0, 0							#Register to store sum of the values of the characters in our base system
	li $s5, 29							#Initializing register to 29, the base with my Id. So that we can multiply by 29 with each character from the back
	li $s6, 1							#A register to keep on multiplying by our base, since the last character will be the value only

	li $t0, 0							#Boolean register that stores 0 if we haven't reached a valid character, 1 if we have
	li $t1, 0							#Register to track only 3 characters after the first valid character						
	li $t2, 0							#another boolean register
							
	li $v0, 8						
	la $a0, reply							#Reading input string
	li $a1, 1001
	syscall
 	
	la $s4, reply							#Loading the address of reply in $s1 so that we can add -1 to access each character							#Loading address of reply in $s2 as well so that we can check if we've finished scanning the first character
	addi $s1, $s4, 999

	move $a1, $s1
	jal Sub1							#Calling our subprogram sub1, rearranged print, invalid and End labels so that we aren't calling our subprogram infinitely

print:							
	beq $v1, -1, invali						#checking if a character was invalid passed through v1, if not print the sum of values

	li $v0, 1
	add $a0, $s0, $zero						#print the total value stored in $s0 across all three cases
	syscall	
	j End
	
invali: 
	li $v0, 4
	la $a0, msg1							#print the string 'Invalid input' in case we have invalid cases
	syscall 
	
End:	li $v0, 10							#terminate once the output or invalid string is printed
	syscall

Sub1:						
First:	blt $a1, $s4, Sub						#this branch checks if we're done removing leading spaces, then we check for just the four characters which might or might not be valid						
	lb $a0, 0($a1)

LoopA:
	beq $a0, 32, After2 
	beq $a0, 9, After2
	beq $a0, 0, After2						#Checking for space, tab, null and enter as only leading and trailing white spaces
	beq $a0, 10, After2
	
	beq $t2, 1, invalid
	
	li $t2, 1							#Changing the register to 1 to indicate we have reached our first valid character
	la $t3, 0($a1)							#storing the address and moving address to t3 to later remember where we should start scanning 4 characters from
	addi $a1, $a1, -4						#once we reach the first valid character, we only care about the leading white spaces, we skip the next four characters because they will be filtered in our subprogram
	j First

After2:	
	addi $a1, $a1, -1
	j First

Sub:	beq $t2, $zero, invalid						#if we haven't found a valid character while scanning through all leading and trailing white spaces, instead of proceeding to calculation, we go to the invalid branch
	
	lb $a0, 0($t3)							#Load the character to $a0 and go to filter to check if it's invalid or a lowercase, uppercase or a number
	j Filter
									
After:	blt $t3, $s4, return						#checking if t3 is less than s4 which is the address of the first character, at which point we return out of the program 
	addi $t3, $t3, -1						#decrementing by 1 as we are iterating from the back
	j Sub

Base:	mult $s6, $s5							#keep on multiplying s6 by our base to calculate the total value correctly, equivalent to t6 = t6 * t5 in high level languages
	mflo $s6
	j After								

After1:	beq $t3, $s4, return						#if the white space characters are either the first or last character, we don't check further. If they're not, we check left and right to see if they're invalid
	addi $t1, $t1, 1
	beq $t1, 4, return						
									
	beq $t0, $zero, After
	lb $a0, -1($t3)

	beq $a0, 32, After 
	beq $a0, 9, After
	beq $a0, 0, After						#Checking for space, tab, null, enter and if they are in between valid characters, if not we just move to next character
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
		
							
numeric:li $s2, -48
	j Common							# - 48 in s2 because 0 has value 0 in our base system
							
Lower:	li $s2, -87							# - 87 in s2 because a has value 10 in our base system
	j Common

Upper:	li $s2, -55							# - 55 in s2 because A has value 10 in our base system
	j Common
			
Common:	addi $t1, $t1, 1						#register to track number of characters scanned
	li $t0, 1							#boolean style register to track a valid character is scanned at least once, we use this to invalidate spaces between valid characters
	add $s3, $a0, $s2						#instead of repeating the same steps in the three labels, we just load the values we use to get the value of a character in each label and then do all the computations in one common label.
	mult $s6, $s3
	mflo $s7							
	add $s0, $s0, $s7						#finding the value of the character, then multiplying with the power of our base
	beq $t1, 4, return						#once we're done scanning through 4 characters, we jump to return
	j Base						

invalid:li $v1, -1							#in case, any of the characters are invalid, we store -1 in v1 and later check if it is -1 in print label

return:	move $v0, $s0							#total value of the characters, if valid stored in s0, moved to v0 to return to our subprogram.
	jr $ra								#return to the next line after where we call our program

						

	
	

	

	

	

	