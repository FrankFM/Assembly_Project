.section .data

.include "file_handling.asm"
.include "alloc.asm"
.include "parsing.asm"
.include "print.asm"

.section .text

.globl _start

_start:


mov 16(%rsp), %rdx
push %rsi

# Open text file
mov $2, %rax
mov %rdx, %rdi
mov $0, %rsi      # Setting a flag, we use 0
mov $0, %rdx      # 0 is equal to read-only mode
syscall

push %rax
call get_file_size


pop %r12           #File descriptor

push %rax
call alloc_mem

mov %rax, %r14    #Pointer to start of memory

pop %r13           #Output from get_file_size


#push %r13
#call print_number
#pop %r13


# Read the first n bytes from the text file
mov $0, %rax
mov %r12, %rdi
mov %r14, %rsi
mov %r13, %rdx
syscall


push %r13
call alloc_mem
pop %r13


mov %rax, %r15	 #Pointer to second buffer (start of memory)
push %r15
push %r13
push %r14

call parse_number_buffer
pop %r14
pop %r13
pop %r15





push %r13
push %r14
call get_number_count

push %rax
call print_number
pop %rax

pop %r14
push %r15
call get_number_count
pop %r15

pop %r13


#mov $0, -8(%r13)


#loop1:
#mov


push %rax
call print_number
pop %rax

# Read the first n bytes from the text file
#mov $0, %rax
#mov %r12, %rdi
#mov %r14, %rsi
#mov %r13, %rdx
#syscall

# Write the n bytes from the text file
#mov $1, %rax
#mov $1, %rdi
#mov %r14, %rsi
#mov %r13, %rdx
#syscall

# Close the file again
mov $3, %rax
mov $3, %rdi
syscall

#Syscall to exit

mov $60, %rax
mov $0, %rdi
syscall


