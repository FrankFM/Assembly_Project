.section .data

file_stat:	
.space 144	#Size of the fstat struct

#buffer:
#.space 1024

.section .text

.globl _start

_start:


mov 16(%rsp), %rdx
push %rsi

# Open text file
mov $2, %rax
mov %rdx, %rdi
mov $0, %rsi     # Setting a flag, we use 0
mov $0, %rdx     # 0 is equal to read-only mode
syscall

push %rax
call get_file_size


pop %r8        #File descriptor 

push %rax
call alloc_mem

pop %r9           #Output from get_file_size
mov %rax, %r10    #Pointer to start of memory

#number:
#.long -8(%rsp)

#pop %rax

#buffer:
#.space number

#Load the first n bytes from the text file
mov $0, %rax
mov %r8, %rdi
mov %r10, %rsi
mov %r9, %rdx
syscall

# Write the n bytes from the text file
mov $1, %rax
mov $1, %rdi
#mov $buffer, %rsi
mov %r10, %rsi
mov %r9, %rdx
syscall

#Syscall to exit

mov $60, %rax
mov $0, %rdi
syscall

###############################################################################
# This function returns the filesize in rax. It expects the file handler to be
# on the stack.
#
# The function is not register save!
###############################################################################
.type get_file_size, @function
get_file_size:
	push 	%rbp
	mov 	%rsp,%rbp 		#Function Prolog


	#Get File Size
	mov		$5,%rax			#Syscall fstat
	mov		16(%rbp),%rdi	#File Handler
	mov		$file_stat,%rsi	#Reserved space for the stat struct
	syscall
	mov		$file_stat, %rbx
	mov		48(%rbx),%rax	#Position of size in the struct

	mov		%rbp,%rsp		#Function Epilog
	pop 	%rbp			
	ret



###############################################################################
# This function is our simple and naive memory manager. It expects to
# receive the number of bytes to be reserved on the stack.
# 
# The function is not register save!
# 
# The function returns the beginning of the reserved heap space in rax
###############################################################################

.type alloc_mem, @function
alloc_mem:
	push 	%rbp
	mov 	%rsp,%rbp 		#Function Prolog

	#First, we need to retrieve the current end of our heap
	mov		$0,%rdi
	mov		$12,%rax
	syscall					#The current end is in %rax
	push	%rax			#We have to save this, this will be the beginning of the cleared field
	add		16(%rbp),%rax	#Now we add the desired additional space on top of the current end of our heap	
	mov		%rax,%rdi
	mov		$12,%rax
	syscall

	pop		%rax
	mov		%rbp,%rsp		#Function Epilog
	pop 	%rbp			
	ret
