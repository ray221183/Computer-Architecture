.data
  str1: .string	"This is HW1_2: With size "
  str2: .string	" * "
  str3: .string	"\nBefore:\n"
  str4: .string	"Result:\n"
  str5: .string	"\t"
  str6: .string	"\n"
  data_i: .dword 105, 203, 173, 204, 177, 172, 12
       .dword 15, 250, 199, 199, 190, 210, 115
       .dword 183, 0, 35, 166, 164, 92, 137
       .dword 11, 155, 44, 49, 153, 255, 177
       .dword 228, 122, 150, 216, 74, 191, 219
       .dword 36, 163, 0, 70, 255, 163, 231
       .dword 233, 55, 195, 177, 190, 241, 145
  data_o: .dword 0:25 #initiate 25 dwords with value 0
  data_size: .dword 7, 7
  buffer: .dword 0:9
  
  
  


.globl main

.text

#----------------------------------------------------Do not modify below text----------------------------------------------------
main:
  # Main function loop parameters setting
  la t0, data_size
  ld s2, 0(t0)				# rows
  ld s3, 8(t0)				# cols

  # Print initiate
  li a7, 4
  la a0, str1
  ecall
  li a7, 1
  mv a0, s2
  ecall
  li a7, 4
  la a0, str2
  ecall
  li a7, 1
  mv a0, s3
  ecall
  li a7, 4
  la a0, str3
  ecall

  # Print function
  # a1 stores print address, a2 stores the row length, and a3 stores the col length
  la a1, data_i
  mv a2, s2					# data_i rows
  mv a3, s3					# data_i cols
  jal prints				# print data
#----------------------------------------------------Do not modify above text----------------------------------------------------
### Start your code here ###
# void medium_filter(int* x, int dim_x, int dim_y, int kernel_size = 3, int* out, int* in){
#     int new_xdim = dim_x-kernel_size+1;
#     int new_ydim = dim_y-kernel_size+1;

#     for(int x_idx=0; x_idx<new_xdim; x_idx++){
#         for(int y_idx=0; y_idx<new_ydim; y_idx++){

#             for(int i=0; i<kernel_size; i++){
#                 for(int j=0; j<kernel_size; j++){
#                     in[i*kernel_size+j] = x[ (x_idx+i)*dim_y + (y_idx+j) ];
#                 }
#             }

#             out[x_idx*new_ydim+y_idx] = get_medium(in, kernel_size * kernel_size);
#         }
#     }
# }
# int get_medium(int* in, int size = 9){
#     for(int i=0; i<size-1; i++){
#         for(int j=0; j<size-1-i; j++){
# #             if(in[j]>in[j+1]){
#                 int temp = in[j];
#                 in[j] = in[j+1];
#                 in[j+1] = temp;
#             }
#         }
#     }
#     return in[4];
#     // return (size%2 == 0) ? (in[size/2-1]+in[size/2])/2 : in[size/2];
# }

  #void medium_filter(int* x, int dim_x, int dim_y, int kernel_size = 3, int** out, int* in)
  la a0, data_o # out
  la a1, buffer # in
  la a2, data_i # x
  mv a3, s2 # dim_x
  mv a4, s3 # dim_y
  li a5, 3 # kernel_size, default = 3
  jal medium_filter # call medium_filter
  jal zero, ends
#-----------------------------------------end main-------------------------------------
medium_filter:
  #############################################################
  # a0 out, a1 in, a2 x, a3 dim_x, a4 dim_y, a5 kernel_size
  # s1 new_xdim, s2 new_ydim, s3 out, s4 x_idx, s5 y_idx, s6 (x_idx*dim_y + y_idx), s7 (x_idx*new_ydim+y_idx)
  # (x_idx+i)*dim_y + (y_idx+j) = (s6)(x_idx*dim_y + y_idx) + (i*dim_y + j)
  #############################################################
  # set stack frame of medium_filter
  addi sp, sp, -80
  # argument
  sd a1, 72(sp) # in
  sd a0, 64(sp) # out
  # return address
  sd ra, 56(sp)
  # saved reg
  sd s7, 48(sp)
  sd s6, 40(sp)
  sd s5, 32(sp)
  sd s4, 24(sp)
  sd s3, 16(sp)
  sd s2, 8(sp)
  sd s1, 0(sp)

  # new_xdim
  addi t0, a3, 1
  sub s1, t0, a5
  # new_ydim
  addi t1, a4, 1
  sub s2, t1, a5
  # out
  mv s3, a0

# start to slide window
  li s4, 0   # x_idx=0
  li s6, 0   # x_idx*dim_y + y_idx=0
  mv s7, a0   # &out[0]
slideloop1:
  bge s4, s1, exit_slideloop1  # continue if x_idx<new_xdim else break
  li s5, 0   # y_idx=0
slideloop2:
  bge s5, s2, exit_slideloop2  # continue if y_idx<new_ydim else break
# set in(buffer)
  li t0, 0    # i=0
  mv t2, a1   # &in[0] //address
  li t3, 0    # i*dim_y=0 //index
setinloop1:
  bge t0, a5, exit_setinloop1  # continue if i<kernel_size else break
  li t1, 0    # j=0
setinloop2:
  bge t1, a5, exit_setinloop2  # continue if j<kernel_size else break
  add t4, t3, t1 # i*dim_y + j
  add t5, s6, s5 # t5 = x_idx*dim_y + (y_idx)
  add t4, t5, t4 # (x_idx+i)*dim_y + (y_idx+j) //index
  slli t4, t4, 3 # transform index to address
  add t6, t4, a2 # &x[ (x_idx+i)*dim_y + (y_idx+j) ] //address
  ld t5, 0(t6)   
  sd t5, 0(t2)   # in[i*kernel_size+j] = x[ (x_idx+i)*dim_y + (y_idx+j) ];
  addi t2, t2, 8 # &in[++(i*kernel_size+j)]
  addi t1, t1, 1 # j++
  jal zero, setinloop2
exit_setinloop2:
  add t3, t3, a4 # t3 = (i+1)*dim_y + j
  addi t0, t0, 1 # i++
  jal zero, setinloop1
exit_setinloop1:
  li a0, 9       # size, default = 9
  mv a1, a1      # in
  jal get_medium # call get_medium
  sd a1, 0(s7)   # out[x_idx*new_ydim+y_idx] = get_medium(in, kernel_size * kernel_size)
  ld a1, 72(sp)  # restore in
  addi s7, s7, 8 # &out[++(x_idx*new_ydim+y_idx)]
  addi s5, s5, 1 # y_idx++
  jal zero, slideloop2
exit_slideloop2:
  add s6, s6, a4 # s6 = (x_idx+1)*dim_y
  addi s4, s4, 1  # x_idx++
  jal zero, slideloop1
exit_slideloop1:
  # restore data from stack, and free the memory space
  ld s1, 0(sp)
  ld s2, 8(sp)
  ld s3, 16(sp)
  ld s4, 24(sp)
  ld s5, 32(sp)
  ld s6, 40(sp)
  ld s7, 48(sp)
  ld ra, 56(sp)
  addi sp, sp, 80

  jr ra



get_medium:
  ###############################################
  # a0 size, a1 in
  # a1 return reg
  ###############################################
  addi t1, zero, 0 # i=0
  addi t2, a0, -1  # size - 1
sortfor1:
  bge t1 t2 exit_sortfor1  #continue if i<size-1 else go to exit1
  addi t3, zero, 0 # j=0
  sub t4, t2, t1 # size - 1 - i
sortfor2:
  bge t3, t4, exit_sortfor2 #continue if j<size-i-1 else go to exit2
  slli t5, t3, 3 # j*8
  add t5, a1, t5 # &in[j]
  lw t0 0(t5) # in[j]
  lw t6 8(t5) # in[j+1]
  bge t6 t0 exit_swap
# swap
  sw t6 0(t5) #in[j] = in[j+1]
  sw t0 8(t5) #in[j+1] = in[j]
exit_swap:
  addi t3, t3 1 #j++
  j sortfor2
exit_sortfor2:
  addi t1, t1, 1 #i++
  j sortfor1
exit_sortfor1:
  ld t0, 32(a1) # in[4]
  mv a1, t0     # return in[4]
  jr ra




#----------------------------------------------------Do not modify below text----------------------------------------------------
ends:
  # Print str4
  li a7, 4
  la a0, str4
  ecall
  # Print function
  # a1 stores print address, a2 stores the row length, and a3 stores the col length
  la a1, data_o
  addi a2, s2, -2			# data_o rows
  addi a3, s3, -2			# data_o cols
  jal prints				# print data

  # Done, terminate program
  li a7, 10				# terminate
  ecall					# system call

# Print function
prints:
  addi sp, sp, -32
  sd ra, 24(sp)
  sd s3, 16(sp)
  sd s2, 8(sp)
  sd s1, 0(sp)
  # a1 stores print address, a2 stores the row length, and a3 stores the col length
  mv s1, a1
  mv s2, a2
  mv s3, a3
  li t0, 0				# for(i=0)
printforloop1:
  bge t0, s2, printexit1		# if ( i>=row ) jump to printexit1
  li t1, 0				# for(j=0)
printforloop2:
  bge t1, s3, printexit2		# if ( j>=col ) jump to printexit2
  li a7, 1				# print_int
  ld t2, 0(s1)
  mv a0, t2
  ecall
  li a7 4
  la a0, str5
  ecall
  addi s1, s1, 8			# Move to next memory address(8 bytes)
  addi t1, t1, 1			# j = j + 1
  j printforloop2
printexit2:
  li a7, 4
  la a0, str6
  ecall
  addi t0, t0, 1			# i = i + 1
  j printforloop1
printexit1:
  ld s1, 0(sp)
  ld s2, 8(sp)
  ld s3, 16(sp)
  ld ra, 24(sp)
  addi sp, sp, 32
  jr ra
#----------------------------------------------------Do not modify above text----------------------------------------------------
