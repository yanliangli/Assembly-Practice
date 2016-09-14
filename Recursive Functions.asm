# Homework #4
# name: Yan Li
# sbuid: 110644059


#####################################
#marcos
####################################
.macro push_s_registers_onto_stack
	addi $sp, $sp, -32
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
.end_macro

.macro restore_s_registers_from_stack
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $s7, 28($sp)
	addi $sp, $sp, 32
.end_macro

.macro write(%address, %x, %reg)
	addi $sp, $sp, -16
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	sw $v0, 12($sp)
	move $a0, %reg
	la $a1, %address
	li $a2, %x
	li $v0, 15
	syscall
	lw $a0, 0($sp)
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $v0, 12($sp)
	addi $sp, $sp, 16
.end_macro

.macro my_itof(%reg, %reg2)
	addi $sp, $sp, -16
	sw $a1, 12($sp)
	sw $a0, 8 ($sp)
	sw $a2, 4 ($sp)
	sw $ra, 0 ($sp)
	move $a0, %reg
	move $a1, %reg2
	jal itof
	lw $a1, 12($sp)
	lw $a0, 8 ($sp)
	lw $a2, 4 ($sp)
	lw $ra, 0 ($sp)
	addi $sp, $sp, 16
.end_macro



#####################################
#
#	text
#
####################################
.text

#Part 1

#-------------------------------------------------------------------
#/**
#* This function writes the ASCII representation of a number to a
#file.
#* $a0 = @param integer_to_write Integer that will be written to the
#file.
#* $a1 = @param file_descriptor File descriptor of the output file.
#(Assume valid FD) */
#
#public void itof(int integer_to_write, int file_descriptor);
#-------------------------------------------------------------------
itof:
  	push_s_registers_onto_stack
  	move $s0, $a1		# file descriptor
  	move $s1, $a0 		# integer to wirte 
	li $t0, '0'		# ascii for 0	
  	li $t3, 10
  	move $t7, $0		# digit counter
  	move $s6, $0		# initially negativ flag is off
  	bgez $s1, positive_num	# if it is positive number
 	addi $s6, $0, 1		# if it negative, s6 is 1 
  	neg $s1, $s1		# treate it as a positive number
	
  	positive_num:
  	loop_itof:
  	div $s1, $t3     # int / 10
  	mflo $s1	# quotion
  	mfhi $t4	# remainder
 	add $t4,$t4, $t0 	# convert reaminder to ascii
  	addi $sp, $sp, -1
  	sb $t4, ($sp)	# store on the stack
  	addi $t7, $t7, 1	#increment counter
 	bne $s1,$0, loop_itof
  	move $t5, $0			# loop counter
  	bne $s6, 1, loop_write	# if negative
  	addi $sp, $sp, -1
  	li $t0, '-'
  	sb $t0, ($sp)
  	addi $t7, $t7, 1		# final digit counter
  	loop_write:
  	move $a0, $s0 
  	la $a1, ($sp)
  	li $a2, 1
  	li $v0, 15
  	syscall   # write file
  	addi $sp, $sp, 1
  	addi $t5, $t5, 1
  	blt $t5, $t7, loop_write
 
  	restore_s_registers_from_stack
  	jr $ra

########################################################################
#	Part 2
########################################################################
#bears function
bears:
	lw $s0, 0($sp)
	push_s_registers_onto_stack
	write(str_bears, 7, $s0)
	my_itof($a0,$s0)
	write(str_comma, 2, $s0)
	my_itof($a1,$s0)
	write(str_comma, 2, $s0)
	my_itof($a2,$s0)
	write(str_comma, 2, $s0)
	my_itof($a3,$s0)
	write(str_next_line1, 3, $s0)
	
	# if (initial == goal)
	bne $a0, $a1, check_n
	write(str_return, 8, $s0)			#return 1
	li $t3, 1
	my_itof($t3, $s0)
	write(str_next_line2, 1, $s0)
	li $v0, 1
	restore_s_registers_from_stack
	jr $ra
	
	#else if (n == 0)
	check_n:
	bnez $a3, first_recur
	write(str_return, 8, $s0)			#return 0
	my_itof($0, $s0)
	write(str_next_line2, 1, $s0)
	li $v0, 0
	restore_s_registers_from_stack
	jr $ra
	
	#else if (bears(initial+increment, goal, increment, n-1) == 1)
	first_recur:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $a3, 4($sp)
	addi $sp, $sp, -4
	sw $s0, 0($sp)

	add $a0, $a0, $a2     # initial + increment
	addi $a3, $a3, -1	# n - 1
	jal bears
	
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	
	lw $a0, 0($sp)
	lw $a3, 4($sp)
	addi $sp, $sp, 8
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	bne $v0, 1, second_recur
	write(str_return, 8, $s0)			#return 1
	li $t3, 1
	my_itof($t3, $s0)
	write(str_next_line2, 1, $s0)
	li $v0, 1
	restore_s_registers_from_stack
  	jr $ra
  	
  	# else if ((initial % 2 == 0) && (bears(initial/2, goal,increment, n-1) == 1))
	second_recur:
	li $s6, 2
	divu $a0, $s6
	mfhi $s7      	#remainder
	bnez $s7, j_else
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $a3, 4($sp)
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	mflo $a0	# initial / 2
	addi $a3, $a3, -1 # n - 1
	jal bears
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	lw $a0, 0($sp)
	lw $a3, 4($sp)
	addi $sp, $sp, 8
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	bne $v0, 1, j_else
	write(str_return, 8, $s0)			#return 1
	li $t3, 1
	my_itof($t3, $s0)
	write(str_next_line2, 1, $s0)
	li $v0, 1
	restore_s_registers_from_stack
  	jr $ra
	
	# else
	j_else:
	write(str_return, 8, $s0)			#return 0
	my_itof($0, $s0)
	write(str_next_line2, 1, $s0)
	li $v0, 0
	restore_s_registers_from_stack
	jr $ra
##############################################################################################
#
#		Part 3
#
###############################################################################################

###############################################################
#/**
#* This function returns the occurrences of candidate in the
#integer array.
#*
#* @ param a0 input_array Integer array
#* @ param a1 candidate Integer being searched for in the array
#* @ param a2 startIndex Start index of the array
#* @ param a3 endIndex End index of the array
#* @ param fd File descriptor of opened file
#*
#* @ return int the number of times candidate occurred in the
#array.
#*/
#recursiveFindMajorityElement function
###############################################################
recursiveFindMajorityElement:
	lw $s4, 0($sp)
	push_s_registers_onto_stack
	sub $s0, $a3, $a2
	addi $s0, $s0, 1	#array_length = end -start + 1
	
	write(str_find_majority, 30, $s4)
	my_itof($a2, $s4)	#start index
	write(str_comma, 2, $s4)
	my_itof($a3, $s4)	#end index
	write(str_comma, 2, $s4)
	my_itof($s0, $s4)	#arraylength index
	write(str_next_line1, 3, $s4)
	
	
	
	restore_s_registers_from_stack
	jr $ra

#################################################
#/**
#* This function iterates though the candidate elements and call
#the
#* recursiveFindMajorityElement function. If a majority is found
#
#* it returns the element. -1 if there isn't a majority element.
#*
#* @ param input_array Array of positive integers.
#* @ param fd File descriptor of opened file to write to.
#*
#* @ return int The element that is the majority. -1 if no
#majority.
#*/
#iterateCandidates function
#################################################
iterateCandidates:
	push_s_registers_onto_stack
	li $s6, 0	# end index
	li $s7, 0	# start index
	
	ic_inc:
	lw $t1, ($a0)
	addi $s6, $s6, 1	# end index ++
	addi $a0, $a0, 4
	bne $t1, -1, ic_inc
	sll $t0, $s6, 2
	sub $a0, $a0, $t0 
	addi $s6, $s6, -2 	# end index --
	move $s5, $0

	ic_loop:
	addi $s5, $s5, 1
	write(str_candidate, 11, $a1)
	lw $s2, ($a0)
	my_itof($s2, $a1)
	write(str_next_line2, 1, $a1)
	
	move $t1, $a1
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	
	move $a1, $s2
	move $a2, $s7
	move $a3, $s6
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	sw $t1, 0($sp)
	jal recursiveFindMajorityElement
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	lw $a0, 0($sp)
	lw $a1, 4($sp)
	addi $sp, $sp, 8
	addi $a0, $a0, 4
	move $t0, $v0
	addi $t6, $s6, 1
	li $t2, 2
	div $t6, $t2
	mflo $t6
	blt $t0, $t6, go_on
	move $v0, $s2
	restore_s_registers_from_stack
	jr $ra
	go_on:
	blt $s5, $s6, ic_loop
	
	write(str_majority_element, 18, $a1)
	my_itof($0, $a1)
	write(str_next_line2, 1, $a1)
	restore_s_registers_from_stack
	jr $ra

##################################
#	Part 4
###################################
#/**
#* This function finds the lone element in an integer array using
#recursion.
#*
#* @ param input_array Integer array
#* @ param startIndex Start index of the array
#* @ param endIndex End index of the array
# @ param fd File descriptor of opened file
#*
#* return int Unique element in the array or -1 if no unique
#element in array.
#*/
#recursiveFindLoneElement function
##########################################################
recursiveFindLoneElement:
	push_s_registers_onto_stack
	
	write(str_lonly, 26, $a3)
	my_itof($a1, $a3)
	write(str_comma, 2, $a3)
	my_itof($a2, $a3)
	write(str_next_line1, 3 , $a3)
	
	
	subu $s0, $a2, $a1	# array_length
	addi $s0, $s0, 1	# array_length = end - start + 1
	
	#if(( array_length % 2 ) == 0)
	li $t2, 2
	divu $s0, $t2
	mfhi $t1
	mflo $s1	# mid
	beqz $t1, part4_return_negone
	#if(array_length == 1)
	beq $s0, 1, part4_return_startIndex
	#else
	add $t7, $s1, $a1	# mid + startIndex
	sll $t7, $t7, 2
	add $a0, $a0, $t7
	lw $s2, ($a0)		# s2 = target
	lw $s3, -4($a0)		# s3 = left
	lw $s4, 4($a0)		# s4 = right
	sub $a0, $a0, $t7
	beq $s2, $s3, look_left_side
	beq $s2, $s4, look_right_side
	write(str_return, 8, $a3)
	my_itof($s2, $a3)
	write(str_next_line2, 1, $a3)
	move $v0, $s2	
	restore_s_registers_from_stack	#return target
  	jr $ra
  	
  	#else if (target == left && target != right)
	look_left_side:
	bne $s2, $s3, look_right_side
	beq $s2, $s4, look_right_side
	addi $t4, $s1, -2	# mid - 2
	sub $t4, $t4, $a1	#######  left_half_length = ((mid-2)-startIndex) + 1
	addi $t4, $t4, 1	# lefthand length
	li $t2, 2
	divu $t4, $t2
	mfhi $t0
	bnez $t0, left_hand_else
	addi $t2, $s1, 1 	# mid + 1
	add $t1, $a1, $t2	#### child_star_index = startIndex + ( mid + 1 )
	move $t2, $a2		### child end
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $a1, $t1	#child start
	move $a2, $t2	# child end
	jal recursiveFindLoneElement
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	write(str_return, 8, $a3)			#return ret
	my_itof($v0, $a3)
	write(str_next_line2, 1, $a3)
	restore_s_registers_from_stack
	jr $ra
	
	left_hand_else:
	move $t1, $a1		### child start
	addi $t2, $s1, -2 	# mid - 2
	add $t2, $a1, $t2	#### child_end_index = startIndex + ( mid - 2 )
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $a1, $t1	#child start
	move $a2, $t2	# child end
	jal recursiveFindLoneElement
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	write(str_return, 8, $a3)			#return ret
	my_itof($v0, $a3)
	write(str_next_line2, 1, $a3)
	restore_s_registers_from_stack
	jr $ra
	
	#left hand
	look_right_side:
	beq $s2, $s3, part4_return_negone
	bne $s2, $s4, part4_return_negone
	addi $t4, $s1, 2	# mid + 2
	sub $t4, $a2, $t4	# endIndex - (mid+2) + 1
	addi $t4, $t4, 1	# right_half_length 
	li $t2, 2
	divu $t4, $t2
	mfhi $t5
	bnez $t5, right_hand_else
	
	move $t1, $a1		### child start = startIndex
	addi $t2, $s1, -1 	# mid - 1
	add $t2, $a1, $t2	#### child_end_index = startIndex + ( mid - 1 )
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $a1, $t1	#child start
	move $a2, $t2	# child end
	jal recursiveFindLoneElement
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	write(str_return, 8, $a3)			#return ret
	my_itof($v0, $a3)
	write(str_next_line2, 1, $a3)
	restore_s_registers_from_stack
	jr $ra
	
	right_hand_else:
	addi $t1, $s1, 2 	# mid + 2
	add $t1, $a1, $t1	#### child_start_index = startIndex + ( mid + 2 )
	move $t2, $a2		### ened child = endIndex
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $a1, $t1	#child start
	move $a2, $t2	# child end
	jal recursiveFindLoneElement
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	write(str_return, 8, $a3)			#return ret
	my_itof($v0, $a3)
	write(str_next_line2, 1, $a3)
	restore_s_registers_from_stack
	jr $ra

	part4_return_startIndex:
	move $t7, $a1
	sll $t7, $t7, 2	   # startIndex * 4
	add $a0, $a0, $t7
	lw $t3, ($a0)
	sub $a0, $a0, $t7	# restore array pointer
	write(str_return, 8, $a3)
	my_itof($t3, $a3)
	write(str_next_line2, 1, $a3)	
	move $v0, $t3
	restore_s_registers_from_stack
  	jr $ra
	
	part4_return_negone:
	write(str_return, 8, $a3)			#return -1
	li $s3, -1
	my_itof($s3, $a3)
	write(str_next_line2, 1, $a3)
	li $v0, -1
	restore_s_registers_from_stack
  	jr $ra


####################
#
### Data Section ###
#
####################
.data
str_bears: .asciiz "bears( " 
str_find_majority: .asciiz "recursiveFindMajorityElement( "
str_candidate: .asciiz "candidate: "
str_majority_element: .asciiz "majority element: "
str_lonly: .asciiz "recursiveFindLoneElement( "
str_return: .asciiz "return: "
str_comma: .asciiz ", "
str_next_line1: .asciiz " )\n"
str_next_line2: .asciiz "\n"
