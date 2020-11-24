#----------------------------------------------------Do not modify below text----------------------------------------------------
.data
  str1: .string	"This is HW1_1:\nBefore sorting: \n"
  str2: .string	"\nAfter sorting:\n"
  str3: .string	"  "
  num: .dword  -1, 3, -5, 7, -9, 2, -4, 6, -8, 10

.globl main

.text
main:
  # Print initiate
  li a7, 4
  la a0, str1
  ecall
  
  # a2 stores the num address, a3 stores the length of  num
  la a2, num
  li a3, 10
  jal prints
  
  la a2, num
  li a3, 10
  jal sort
  
  # Print result
  li a7, 4
  la a0, str2
  ecall

  la a2, num
  li a3, 10
  jal prints
  
  # End the program
  li a7, 10
  ecall
#----------------------------------------------------Do not modify above text----------------------------------------------------
sort:
### Start your code here ###
  #for(int i=0; i<size-1; i++){
 #    for(int j=0; j<size-i-1; j++){
 ##        if(list[j] > list[j+1]){
 #            int temp = list[j];
 #            list[j] = list[j+1];
 #            list[j+1] = temp;
 #        }
 #    }
 # }
 #a2 num
 #a3 size
  addi t1, zero, 0 #t1: i=0
  addi a4, a3, -1 #a4 = size - 1
for1:
  bge t1 a4 exit1  #continue if i<size-1 else go to exit1
  addi t2, zero, 0 #t2: j=0
  sub t3, a4, t1 #a1 = size - 1 - i
for2:
  bge t2, t3, exit2 #continue if j<size-i-1 else go to exit2
  slli t4, t2, 3 #t4 = j*8
  add t5, a2, t4 #t5 = list+t4(=j*8)
  ld a5 0(t5) #a5(temp) = list[j]
  ld a6 8(t5) #a6 = list[j+1]
  bge a6 a5 exitswap
swap:
  sd a6 0(t5) #list[j] = listpj+1[
  sd a5 8(t5) #list[j+1] = a5(temp)
exitswap:
  addi t2, t2 1 #j++
  j for2
exit2:
  addi t1, t1, 1 #i++
  j for1
exit1:
  jr ra











#----------------------------------------------------Do not modify below text----------------------------------------------------
# Print function	
prints:
  mv t0, zero # for(i=0)
  # a2 stores the num address, a3 stores the length of  num
  mv t1, a2
  mv t2, a3
printloop:
  bge t0, t2, printexit # if ( i>=length of num ) jump to printexit 
  slli t4, t0, 3
  add t5, t1, t4
  lw t3, 0(t5)
  li a7, 1 # print_int
  mv a0, t3
  ecall
	
  li a7, 4
  la a0, str3
  ecall 
	
  addi t0, t0, 1 # i = i + 1
  j printloop
printexit:
  jr ra
#----------------------------------------------------Do not modify above text----------------------------------------------------
