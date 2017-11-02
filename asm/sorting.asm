.section .data

.include "file_handling.asm"
.include "alloc.asm"
.include "parsing.asm"
.include "print.asm"

.section .text

.globl _start

_start:

mov 16(%rsp), %rdx        # Retrieve filename from command line argument

###########################################################
################### Open text file ########################
###########################################################
mov $2, %rax
mov %rdx, %rdi            # Pointer to a string (filename)
mov $0, %rsi              # Setting a flag, we use 0
mov $0, %rdx              # 0 is equal to read-only mode
syscall

push %rax                 # Put File descriptor from rax to stack
call get_file_size        # Reads from the stack and returns filesize in rax
pop %r12                  # Put File descriptor from the stack to r12

push %rax                 # Put file size from rax to stack
call alloc_mem            # Reads from the stack and returns a pointer in rax
mov %rax, %r14            # Put the pointer to start of memory from rax to r14
pop %r13                  # Put filesize in r13

###########################################################
#################### Read text file #######################
######## Copies data from the file to buffer (r14) ########
## Read the n bytes from the text file and return in rax ##
###########################################################
mov $0, %rax
mov %r12, %rdi            # file descriptor
mov %r14, %rsi            # pointer to memory
mov %r13, %rdx            # num of bytes to read (filesize)
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
push %r14                 # Push start of buffer 1 on stack
call parse_number_buffer  # Writes ascii signs from buffer 1
                          # into integers in buffer 2
pop %r14                  # pointer buffer 1
pop %r13                  # filesize buffer 1
pop %r15                  # pointer buffer 2
pop %r9                   # filesize buffer 2

###########################################################
################## Selection Sort #########################
############## 1. Find minimum ############################
############## 2. Swap with first element #################
############## 3. Sort rest of the list ###################
###########################################################
# rcx = pointer - above rcx list is sorted
# r8  = pointer to cmp value
# r9  = filesize buffer 2
# r10 = minimum value
# r12 = cmp value
# r13 = pointer to minimum
# r14 = counter
# r15 = pointer buffer 2
add %r15, %r9             # end of buffer
mov %r15, %rcx            # everything above rcx is sorted
# mov $0, %r14            # used as counter

outer:
  # outer for loop
  mov (%rcx), %r10        # First number is minimum
  mov %rcx, %r8           # r8 starts by pointing at first element
  inner:
    # inner for loop
    add $8, %r8           # r8 points to next number
    cmp %r8, %r9          # have we reached the end of the buffer?
    je endOfList          # exit inner for loop
    mov (%r8), %r12       # r12 is temporary compare value
    # inc %r14            # increments the counter
    cmp %r10, %r12        # is cmp value less than minimum?
    jl newMinimum         # if yes jump to newMinimum
    jge inner             # if no go to next number
    newMinimum:
      # overwrite r10 and r13 with the new minimum value and address
      mov %r12, %r10      # a new minimum value is saved
      mov %r8, %r13       # a new minimum address is saved
      jmp inner           # go to next number
endOfList:
  # The minimum of the unsorted list is found
  # We wish to put the minimum in top of the memory (first in the list)
  mov (%rcx), %r12        # moves first number in memory to minimum numbers address
  mov %r12, (%r13)
  mov %r10, (%rcx)        # moves minimum number to first numbers address
  add $8, %rcx            # we want minimum to be over rcx pointer
  cmp %rcx, %r9           # did rcx pointer reach end of buffer?
  jne outer               # if not, find another minimum

printing_loop:
# prints every number in buffer
push (%r15)
call print_number
pop %rax
add $8, %r15              # r15 points to next number
cmp %r15, %r9             # did r15 pointer reach end of buffer?
jne printing_loop         # if not, print another number

# push %r14
# call print_number       # prints the counter
# pop %r14

###########################################################
################### Close the file ########################
###########################################################
mov $3, %rax
mov $3, %rdi
syscall

###########################################################
################### syscall to exit #######################
###########################################################
mov $60, %rax
mov $0, %rdi
syscall
