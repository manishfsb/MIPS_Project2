.data
												
reply:	.space 10							#Taking 10 characters as input
msg:	.asciiz "Invalid input"

.text
main:	li $s0, 0							#Register to store sum of the values of the characters in our base system
	li $s5, 2							#Initializing register to 29, the base with my Id. So that we can multiply by 29 with each character from the back
	li $s6, 1							#The last character will be it's value multiplied by 28 ^ 0 = 1. So we keep on multiplying this register by $s5 for our base system until we scan upto the first element							
									
	li $v0, 8						
	la $a0, reply							#Reading input string
	li $a1, 11
	syscall
 	
	la $s4, reply							#Loading the address of reply in $s1 so that we can add 1 to access each character							#Loading address of reply in $s2 as well so that we can check if we've finished scanning the first character
	addi $s1, $s4, 9
						
First:	lb $a0, 0($s1)							
	j Filter							#Load the last character to $a0 and go to filter to check if it's invalid or a lowercase, uppercase or a number

After:	mult $s6, $s5
	mflo $s6							#checking if s1 is less than s4 which is the address of the first character, at which point we terminate 
	addi $s1, $s1, -1
	blt $s1, $s4, End
	
	j First								#decrement address of reply by 1 until we've reached the beginning of the string
	
Filter:	li $t1, 48 
	li $t2, 57
	li $t3, 64							#My Howard Id: 02898734, so base is 29 and the last valid lowercase character is 's' , last valid uppercase = 'S'  
	li $t4, 83
	li $t5, 97
	li $t6, 115							#loading different values to registers to compare ASCII characters and filter if the character is a number, lowercase or uppercase
	
	
	blt $a0, $t1, invalid						
	bgt $a0,$t6, invalid 
	ble $a0, $t6, more						

more:	
	bge $a0, $t5, Lower						#checking if characters are valid in our base system, if they are, they will go to the respective branches	
	bgt $a0, $t4, invalid
	bgt $a0, $t3, Upper
	bgt $a0, $t2, invalid
	bge $a0, $t1, numeric
									
numeric:
	li $s2, -48	
	add $s3, $a0, $s2						#if character is a numeric character
	add $s0, $s0, $s3						#storing the sum in $s0 after each character so that we can have the total value
	j After
	

Lower:	li $s2, -87	
	add $s3, $a0, $s2						#if character is lowercase
	add $s0, $s0, $s3						#$a0 % 87 could also have been done, instead of subtracting in all three cases
	j After	

Upper:	li $s2, -55	
	add $s3, $a0, $s2
	mult $s3, $s6
	mflo $s7 							#if character is uppercase
	add $s0, $s0, $s7
	j After
									#all three branches will eventually lead back to the next character

invalid:li $v0, 4
	la $a0, msg							#print invalid input, a string stored in msg if a character is invalid
	syscall 

	li $v0, 10							#terminate if the input is invalid
	syscall	
							
End:	li $v0, 1
	add $a0, $s0, $zero						#print the total value stored in $s0 across all three cases
	syscall	

	li $v0, 10							#terminate once the output is printed
	syscall

	
	

	

	

	

	