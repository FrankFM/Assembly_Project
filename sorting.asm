.section .data

.include "file_handling.asm"
.include "alloc.asm"
.include "parsing.asm"
.include "print.asm"

.section .text

.globl _start

_start:

mov 16(%rsp), %rdx   # retrieve filename from command line argument

###########################################################
################### Open text file ########################
###########################################################
mov $2, %rax
mov %rdx, %rdi			  # Pointer to a string (filename)
mov $0, %rsi          # Setting a flag, we use 0
mov $0, %rdx          # 0 is equal to read-only mode
syscall

push %rax             # Put File descriptor from rax to stack
call get_file_size    # Reads from the stack and returns filesize in rax
pop %r12              # Put File descriptor from the stack to r12

push %rax             # Put file size from rax to stack
call alloc_mem        # Reads from the stack and returns a pointer in rax
mov %rax, %r14        # Put the pointer to start of memory from rax to r14
pop %r13              # Put filesize in r13

###########################################################
#################### Read text file #######################
######## Copies data from the file to buffer (r14) ########
## Read the n bytes from the text file and return in rax ##
###########################################################
mov $0, %rax
mov %r12, %rdi				# file descriptor
mov %r14, %rsi				# pointer to memory
mov %r13, %rdx				# num of bytes to read (filesize)
syscall

push %r13                 # push filesize to stack
push %r14                 # push pointer to first memory buffer to stack
call get_number_count     # returns how many numbers is stored in buffer to rax
pop %r14                  # pointer buffer 1
pop %r13                  # filesize buffer 1

# amount of number times 8 gives us bytes needed for buffer 2
imul $8, %rax, %r9        # filesize buffer 2
push %r9                  # Push filesize for buffer 2 to stack
call alloc_mem            # Returns a pointer to buffer 2 in rax

mov %rax, %r15            # Pointer to buffer 2 (start of memory)

push %r15                 # Push start of buffer 2 on stack
push %r13                 # Push filesize on stack
push %r14                 # Push buffer 1 on stack
call parse_number_buffer
pop %r14
pop %r13
pop %r15
pop %r9

# rcx = pointer sorted list
# rdx = first number which needs to be moved
# r8  = pointer to cmp value
# r9  = filesize buffer2
# r10 = minimum
# r12 = cmp value
# r13 = adress to minimum
# r14 = counter
# r15 = pointer buffer2
add %r15, %r9		# end of buffer
mov %r15, %rcx		# everything above r11 is sorted
mov $0, %r14

###########################################################
################## Selection Sort #########################
############## 1. Find minimum ############################
############## 2. Swap with first element #################
############## 3. Sort rest of the list ###################
###########################################################

sort:
	# outer for loop
	mov (%rcx), %r10	# First number is minimum
	mov %rcx, %r8

	minimum:
		# inner for loop
		add $8, %r8
		cmp %r8, %r9
		je endOfList
		mov (%r8), %r12
		inc %r14
		cmp %r10, %r12
	jl newMinimum
	jge minimum

		newMinimum:
		  mov %r12, %r10
      mov %r8, %r13
		jmp minimum

endOfList:alloc_mem r
  mov (%rcx), %rdx    # could be done in one line, but then it crashes
  mov %rdx, (%r13)    # first number goes to minimum numbers adress
  mov %r10, (%rcx)    # minimum number goes to first numbers adress
	add $8, %rcx        # the list is sorted above r11
  cmp %rcx, %r9
jne sort

printing_loop:
push (%r15)
call print_number
pop %rax
add $8, %r15
cmp %r15, %r9
jne printing_loop

push %r14
call print_number
pop %r14

# Close the file again
mov $3, %rax
mov $3, %rdi
syscall

# Syscall to exit
mov $60, %rax
mov $0, %rdi
syscall
