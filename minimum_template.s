# Exercise 3
# Max Score: 12 points
#
# Students: 
#
# minimum.s 
# Finds the index of the smallest element in an integer array
# V[], which contains n items.  
# 
# Below is the C function.  
#
#   int minimum(int V[], int n)
#   {
#     int min, min_idx, i;
#     min=V[0];
#	  min_idx=0;
#     for(i=1;i<n;i++)
#       if (V[i] < min){
#         min=V[i];
#		  min_idx=i;
#		}
#     return min_idx;
#    }
#
# In the MIPS implementation given below, registers 
# $a0 and $a1 correspond to V[] and n. The index of the minimal 
# element is placed in $v0 as the return value.
#
# Task 1: Modify the "minimum" function given below so that it returns the index of the largest 
# element in the array. Insert your code into this file where "MaxIndex" is defined and demonstrate the 
# functionality   
#
# Task 2: The pseudo code of a new sorting algorithm is given below along with 
# most of the assembly code. You need to fill in for the missing part and demonstrate 
# the functionality using the same test cases used for MaxIndex function.
#
#
# This algorithm first finds the largest element in A[0]..A[n] and moves it to 
# position n, then finds the largest element in A[0]..A[n-1] and puts that in position n-1, 
# and so forth.
# -Use  MIPS function MaxIndex from Task 1, which takes two arguments A and n, and returns 
# the index of the largest element of A[0]..A[n]. The arguments and return values are passed 
# in registers $a0, $a1 and $v0 respectively.
# -Remember that integers are 32-bit, or 4-byte, MIPS quantities.
#
#
# Preconditions:
#   register (a0) address of the first element in the array
#   register (a1) size of the array


############################ Test Cases ###########################################################
.data

list0:      .word 4, 5, 6, 7, 8, 9, 10, 2, 1, 3
len0:       .word 10

list1:      .word 3, 9, 1, 8, 6, 5, 4, 7, 3, 11
len1:       .word 10

list2:      .word 1, 4, 0, 0, 0, 0, 0, 0, 0, 0 
len2:       .word 10

list3:      .word -1, -2, -3, -4, -5, -6, -7, -8, -9, -10 
len3:       .word 10

list4:      .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 
len4:       .word 10

list5:      .word 1, 5, 0, 3, 4, 0, 6, -7, 8, 9, 10 
len5:       .word 11

newline:    .asciiz     "\n" 
space:      .asciiz     " "

################# minimum routine that prints the index of the min element in an array ############
.text
.globl minimum

minimum:
    lw      $t0, 0($a0)     # min=V[0]
    addi    $t1,$0, 1       # i=1
    add     $t3,$0, 0       # $t3=0

loop:
    bge     $t1,$a1,done    # i>=n ?
    mul     $t2, $t1, 4     # $t2 = $t1 * 4
    add     $t2,$t2,$a0
    lw      $t2, 0($t2)     # $t2 = V[i]
    bge     $t2,$t0,next    # V[i] >= min ?
    add     $t0,$t2,$0      # min=V[i]
    add     $t3,$t1,$0      # max_index=max
next:
    addi    $t1,$t1,1       # i++
    j       loop            # Loop back
done: 
    add     $v0,$t3,$0      # return min
    jr      $ra

#################### MaxIndex routine that prints the index of the max element in an array ########
.text
.globl MaxIndex

MaxIndex:   
    # Please fill in your implementation for 'MaxIndex' below this line !##########################
    # Your code begins

    # Your code ends

    
#################### Sort function that sorts and prints the sorted array ##########################
.text
.globl sort

# Sort(A, n)
# for i = 0 to (n - 1) begin
#   m = MaxIndex(A, n - 1) // Find the largest element in A[0]..A[n - 1]
#   swap A[n - 1] and A[m] // Move it to the last position of the array
#   n = n - 1, update the "last position" of an array, every element after n - 1 is sorted
# end

sort: 
    sub     $sp,$sp,28          # [sp=sp-24] Adjust the stack pointer
    sw      $ra,0($sp)          # [stack[$sp]=$ra] Backup return address
    sw      $s0,4($sp)          # [stack[$sp+4]=$s0] Backup $s0
    sw      $s1,8($sp)          # [stack[$sp+8]=$s1] Backup $s1
    sw      $s2,12($sp)         # [stack[$sp+12]=$s2] Backup $s2
    sw      $s3,16($sp)         # [stack[$sp+16]=$s3] Backup $s3
    sw      $a0,20($sp)         # [stack[$sp+20]=$a0] Backup $a0
    sw      $a1,24($sp)         # [stack[$sp+24]=$a1] Backup $a1
    move    $s0,$a1             # [s0=i]
    mul     $s1,$s0,4           # [$s1=$s0*4] calculate total number of bytes
    add     $s1,$a0,$s1         # [$s1=$a0+$s1] Compute &A[i]

sloop:
    blt     $s0,2,lexit         # Branch to 'lexit' if [$s2 < 2]
    lw      $a0,20($sp)         # [$a0=($sp+20)] Load the address of 'list'
    move    $a1,$s0             # [$a1=$s0] Update 'n' elements to search
    jal MaxIndex                # Call function 'MaxIndex'
    
    # You will need 10-15 lines of code!
    # Your code begins
            # [$t0=MaxIndex] MaxIndex ($v0), that needs to be swapped with index n - 1
            # [$t0=4*$t0] Calculate the offset for MaxIndex
            # [$t0=$t0+$a0] Calculate the address for V[MaxIndex]
            # [$t2=V[$t0]] Load the value of memory address $t0 to $t2, $t2 = V[MaxIndex]
            # [$t1=$s0-1] The index (n - 1) that will be swapped with MaxIndex
            # [$t1=4*$t1] Calculate offset for index n - 1
            # [$t1=$t1+$a0] Calculate the address for V[n - 1]
            # [$t3=V[$t1]] Load the value of memory address $t1 to $t3, $t3 = V[n - 1]
            # [V[$t1]=$t2] Store V[n-1] to be V[MaxIndex]
            # [V[$t0]=$t3] Store V[MaxIndex] to be the original V[n - 1]
            # [$s0=$s0-1] Len = Len - 1    
    # Your code ends
    j       sloop           # Jump back to sort loop

lexit:
    lw      $ra,0($sp)      # [$ra=($sp)] Restore return address
    lw      $s0,4($sp)      # [$s0=($sp+4)] Restore $s0
    lw      $s1,8($sp)      # [$s1=($sp+8)] Restore $s1
    lw      $s2,12($sp)     # [$s2=($sp+12)] Restore $s2
    lw      $s3,16($sp)     # [$s3=($sp+16)] Restore $s3
    lw      $a0,20($sp)     # [$a0=($sp+20)] Restore $a0
    lw      $a1,24($sp)     # [$a0=($sp+20)] Restore $a0
    addi    $sp,$sp,28      # [$sp=$sp+24] Adjust the stack pointer.
    jr      $ra

#################### test function runs individual test cases #####################################
.text
.globl test

test:
    addi    $sp, $sp, -4        # Make space on stack
    sw      $ra, 0($sp)         # Save return address

    jal    minimum             # call 'minimum' function
#    jal    MaxIndex            # call 'MaxIndex' function
    jal    print_integer       # Jump to the routine that prints the index
   
# Comment out minimum, MaxIndex and print_integer function calls and uncomment sort and 
# print_sorted_array functions to test your sort routine.

#    jal     sort                # Call sort function
#    jal     print_array         # Call the function that prints the sorted array

# Do not modify following lines
    lw      $ra, 0($sp)          # Restore return address
    addi    $sp, $sp, 4        # Restore stack pointer
    jr      $ra                  # Return

    
########### A function that prints an integer #####################################################  
.text
.globl print_integer

print_integer:
    move    $a0, $v0           # a0 = result, for printing 
    li      $v0, 1               # Load the system call number 
    syscall
    
    # Print newline 
    la      $a0, newline     # Load the address of the string 
    li      $v0, 4               # Load the system call number
    syscall
    jr      $ra

    
############################# A function that prints an array #####################################    
.text
.globl print_array

print_array:
    blez    $a1,print_return    # No need to print if Len <= 0
    and     $t0,$t0,$0          #[$t0 = $t0 & $0] Initialize $t0 = 0
    and     $t1,$t1,$0          #[$t1 = $t0 & $0] Initialize $t1 = 0
    
print_loop:
    bge     $t1,$a1,print_return    # If $t0 >= Len, return
    addi    $sp, $sp, -4           # Make space on stack
    sw      $a0, 0($sp)              # Save $a0, array address
    mul     $t0,$t1,4               # [$t0 = $t1 * 4] Calculate the offset (Index * 4) for current element
    add     $t0,$t0,$a0             # [$t0 = $t0 + $a0] Calculate the address for current element
    lw      $t2, 0($t0)              #[$t2 = V[$t0]] Load the value in address $t0 to $1
    move    $a0, $t2               # [$a0 = $t2] Print current element
    li      $v0, 1                   # Load the system call number 
    syscall
    addi    $t1, $t1, 1            #[$t1 = $t1 + 1] Increment index by one for next element
    # Print comma
    la      $a0, space               # Load the address of the string 
    li      $v0, 4                   # Load the system call number
    syscall
    lw      $a0, 0($sp)              # $a0, array address
    addi    $sp, $sp, 4            # Restore stack pointer
    j print_loop                # Loop back to print next element

print_return:

    # Print space
    la      $a0, newline # Load the address of the string 
    li      $v0, 4 # Load the system call number
    syscall
    jr      $ra

    # Return

############################# Main function, your MIPS program starts here! ######################$
.text
.globl main
main:   
    addi    $sp, $sp, -4    # Make space on stack
    sw      $ra, 0($sp)     # Save return address

    la      $a0, list0      # 1st parameter: address of list[0]
    la      $a1, len0       # load address of 'len#'
    lw      $a1, 0($a1)
    jal     test            # call function

    la      $a0, list1      # 1st parameter: address of list[0]
    la      $a1, len1       # load address of 'len#'
    lw      $a1, 0($a1)
    jal     test            # call function

    la      $a0, list2      # 1st parameter: address of list[0]
    la      $a1, len2       # load address of 'len#'
    lw      $a1, 0($a1)
    jal     test            # call function

    la      $a0, list3      # 1st parameter: address of list[0]
    la      $a1, len3       # load address of 'len#'
    lw      $a1, 0($a1)
    jal     test            # call function

    la      $a0, list4      # 1st parameter: address of list[0]
    la      $a1, len4       # load address of 'len#'
    lw      $a1, 0($a1)
    jal     test            # call function

    la      $a0, list5      # 1st parameter: address of list[0]
    la      $a1, len5       # load address of 'len#'
    lw      $a1, 0($a1)
    jal     test            # call function

return:	
    li      $v0, 0          # Return value
    lw      $ra, 0($sp)     # Restore return address
    addi    $sp, $sp, 4    # Restore stack pointer
    jr      $ra