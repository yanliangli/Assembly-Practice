############################################################################
##
##  TEXT SECTION
##
############################################################################
.text
.globl main

main:

file_open:
li $v0, 13
la $a0, file_to_write
li $a1, 1
li $a2, 0
syscall   # file descripotor returned in $v0
move $t0, $v0
sw $t0, file_descriptor
	

#li $a0, 90
#lw $a1, file_descriptor
#jal itof

la $a0, part3_array
lw $a1, file_descriptor
jal iterateCandidates


close_file:
li $v0, 16
lw $a0, file_descriptor
syscall

exit_program:
li $v0, 10
syscall

############################################################################
##
##  DATA SECTION
##
############################################################################
.data

.align 2
file_to_write: .asciiz "yan.txt"
file_descriptor: .word 0
part3_array: .word 1, 2, 2, 4, 1, 4, 4, 4, -1
part4_array: .word 1, 1, 2, 3, 3, 5, 5, 8, 8, 13, 13, -1

.include "hw4.asm"
