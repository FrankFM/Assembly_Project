.section .data

.include "file_handling.asm"
.include "alloc.asm"
.include "parsing.asm"
.include "print.asm"

.section .text

.globl _start

_start:


mov 16(%rsp), %rdx   # retrieve filename from command line argument

# Open text file
mov $2, %rax
mov %rdx, %rdi
mov $0, %rsi         # Setting a flag, we use 0
mov $0, %rdx         # 0 is equal to read-only mode
syscall

push %rax            # Put File descriptor from rax to stack
call get_file_size   # get_file_size reads from the stack and returns in rax


pop %r12             # Put File descriptor from the stack to r12

push %rax            # Put file size from rax to stack
call alloc_mem       # alloc_mem reads from the stack and returns in rax

mov %rax, %r14       # Put the Pointer to start of memory from rax to r14
                     # r14 is the buffer size

pop %r13             # Put output from get_file_size in r13 (size of file)


#push %r13
#call print_number
#pop %r13


# Copies data from the file to buffer (r14)
# Read the n bytes from the text file and return in rax
mov $0, %rax
mov %r12, %rdi
mov %r14, %rsi
mov %r13, %rdx
syscall

push %r13             # push filesize to stack
push %r14             # push pointer to first buffer to stack
call get_number_count
pop %r14
pop %r13

#mov %rax, %rdx       # Save the number counted from file

push %rax
call print_number
pop %rax

imul $8, %rax, %r9
push %r9
call print_number
pop %r9

push %r9             # Push filesize for second buffer to stack
call alloc_mem
pop %r9

mov %rax, %r15       # Pointer to second buffer (start of memory)

push %r15
push %r9
push %r14
call parse_number_buffer
pop %r14
pop %r9
pop %r15


# rdx = first number which needs to be moved
# r9  = filesize buffer2
# r15 = pointer buffer2
# r10 = minimum
# r11 = pointer sorted list
# r12 = cmp value
# r13 = adress to minimum
# r14 = counter(index)
# r8  = pointer to cmp value
add %r15, %r9		# end of buffer
mov %r15, %r11		# everything above r11 is sorted

sort:
	# outer for loop
	mov (%r11), %r10	# First number is minimum
	mov %r11, %r8

	minimum:
		# inner for loop
		add $8, %r8
		cmp %r8, %r9
		je endOfList
		mov (%r8), %r12
		cmp %r10, %r12
	jl newMinimum
	jge minimum

		newMinimum:
		  mov %r12, %r10
      mov %r8, %r13
		jmp minimum

endOfList:
  mov (%r11), %rdx    # could be done in one line, but then it crashes
  mov %rdx, (%r13)    # first number goes to minimum numbers adress
  mov %r10, (%r11)    # minimum number goes to first numbers adress
	add $8, %r11        # the list is sorted above r11
  cmp %r11, %r9
jne sort

# så skal der bruges et print loop her
# man kunne evt. incremente r15

printing_loop:
push (%r15)
call print_number
pop %rax
add $8, %r15
cmp %r15, %r9
jne printing_loop

#push 792(%r15)
#call print_number
#pop %rax

#push (%r15)
#call print_number
#pop %rax







# Close the file again
mov $3, %rax
mov $3, %rdi
syscall

#Syscall to exit

mov $60, %rax
mov $0, %rdi
syscall
