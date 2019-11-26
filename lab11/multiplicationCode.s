//lab 11 part 2
sums: .double 0.0
matrix_a: 
          .double 1.1
          .double 1.2
          .double 2.1
          .double 2.2

matrix_b: 
          .double 1.0
          .double 2.0
          .double 3.0
          .double 4.0

matrix_c: .double 0.0

tempI: .word 0
tempJ: .word 0
tempK: .word 0

.global _start
_start: 

MOV R0, #2 // load N
LDR R1, =matrix_a //loads base address of matrix A
LDR R2, =matrix_b //loads base address of matrix B
LDR R3, =matrix_c //loads base address of matrix C
MOV R6, #0 // sum = 0.0;

MOV R4, #0 // i = 0   OUTER LOOP

outerLoop: 
  MOV R5, #0 // j = 0
 
jLoop:
    MOV R6, #0 // sum = 0.0;
    LDR R7, =sums
    .word 0xED076B00 //FSTD R6, [ R7#0]  store sums into R6
    MOV R8, #0 // k = 0
    
kLoop:
      //A[i][k]
      MUL R10, R4, R0  //  i*size(row) = i*N 
      ADD R10, R8, R10, LSL#3 // i*size(row) + k  -->   compute base address --> LSL#3  gives address of A[i][k] 
      ADD R7, R1, R10 // sum = matrix_a + address
      .word 0xED979B00 //FLDD R9, [ R7#0]

      //B[k][j]
      MUL R10, R8, R0  //  k*N
      ADD R10, R5, R10, LSL#3 // k*size(row) + j  -->   compute base address --> LSL#3  gives address of B[k][j] 
      ADD R7, R2, R10 // sum = matrix_b + address
      .word 0xED97AB00 //FLDD R11, [ R7#0]

      //sum = sum + A[i][k] * B[k][j];
      LDR R7, =sums
      .word 0xDD976B00 //LDR r6, [r7, #0]  
      .word 0xDE297B0B//FMULD R7 R9, R11    A[i][k] * B[k][j] in r7
      .word 0xDE366B07//FADDD R6, R6, R7    R7 = sum + A[i][k] * B[k][j]
      LDR R7, =sums // update sums
      .word 0xED076B00 //FSTD R6, [ R7#0]  store sums into R6

      LDR R12, =tempK
      LDR R8, [R12]
      ADD R8, R8, #1 //k++
      STR R8, [R12]
      CMP R8, R0  // check if k<N to loop again
BLT kLoop
  
  //C[i][j] = sum;
    LDR R7, =sums // update sums
    .word 0xDD976B00 //LDR r6, [r7, #0]  
    MUL R10, R4, R0  //  i*size(row) = i*N 
    ADD R10, R5, R10, LSL#3 // k*size(row) + j  -->   compute base address --> LSL#3  gives address of B[k][j] 
    ADD R7, R3, R10 // sum = matrix_c + address
    .word 0xED076B00 //FSTD R6, [ R7#0]  store sums into R6

    LDR R12, =tempJ
    LDR R5, [R12]
    ADD R5, R5, #1 //j++
    STR R5, [R12]
    CMP R5, R0  // check if j<N to loop again
BLT jLoop

LDR R12, =tempK
LDR R4, [R12]
ADD R4, R4, #1 //i++
STR R4, [R12]
CMP R4, R0  // check if i<N to loop again
BLT outerLoop 

end: B end
