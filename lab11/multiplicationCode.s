//lab 11 part 2
 
sums: .double 0.0
matrix_a: 
					.double 1.1
					.double 1.2
          .double 2.1
          .double 2.2

matrix_b: 
					.double 1
					.double 2
          .double 3
          .double 4

matrix_c:



//matrix multiplication code GOES INSIDE STEP6
MOV R0, #2 //N
LDR R1, =matrix_a
LDR R2, =matrix_b
LDR R3, =matrix_c 

MOV R4, #0 // i = 0   OUTER LOOP
outerLoop: 
	MOV R5, #0 // j = 0
  jLoop:
    MOV R6, #0 // sum = 0.0;
    LDR R7, =sums
  	.word 0XED876B00 //FSTD R6, [ R7#0]  store sums into R6
    MOV R8, #0 // k = 0
    kLoop:
      //A[i][k]
      MUL R10, R4, R0  //  i*size(row) = i*N 
      ADD R10, R8, R10, LSL#3 // i*size(row) + k  -->   compute base address --> LSL#3  gives address of A[i][k] 
      ADD R7, R1, R10 // sum = matrix_a + address
			.word 0XED979B00 //FLDD R9, [ R7#0]

      //B[k][j]
      MUL R10, R8, R0  //  k*N
      ADD R10, R5, R10, LSL#3 // k*size(row) + j  -->   compute base address --> LSL#3  gives address of B[k][j] 
      ADD R7, R2, R10 // sum = matrix_b + address
    	.word 0XED97AB00//FLDD R11, [ R7#0]

      //sum = sum + A[i][k] * B[k][j];
      LDR R7, =sums
    	.word 0XED876B00 //FSTD R6, [ R7#0]  store sums into R6
    	.word 0x1BC52F613 //FMULD R7 R9, R11    A[i][k] * B[k][j] in r7
    	.word 0xDE366B07//FADDD R6, R6, R7    R7 = sum + A[i][k] * B[k][j]
      LDR R7, =sums // update sums
    	.word 0XED876B00 //FSTD R6, [ R7#0]  store sums into R6

      ADD R11, R11, #1 //k++
      CMP R11, R0  // check if k<N to loop again
      BLT kLoop
	
	//C[i][j] = sum;
		LDR R7, =sums // update sums
		.word 0xDD976B00 //LDR r6, [r7, #0]  
		MUL R10, R4, R0  //  i*size(row) = i*N 
    ADD R10, R5, R10, LSL#3 // k*size(row) + j  -->   compute base address --> LSL#3  gives address of B[k][j] 
  	ADD R7, R3, R10 // sum = matrix_c + address
		.word 0XED876B00 //FSTD R6, [ R7#0]  store sums into R6

		ADD R5, R5, #1 //j++
    CMP R5, R0  // check if j<N to loop again
    BLT jLoop

ADD R4, R4, #1 //i++
CMP R4, R0  // check if i<N to loop again
BLT outerLoop	
		

	










