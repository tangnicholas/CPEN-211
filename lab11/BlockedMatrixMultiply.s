//part 3 block matrix multiply 

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

.global _start
_start: 

MOV R0, #2 //n
MOV R11, #32 // load BLOCKSIZE
LDR R1, =matrix_a //loads base address of matrix A
LDR R2, =matrix_b //loads base address of matrix B
LDR R3, =matrix_c //loads base address of matrix C

dgemm:
     MOV R4, #0 // sj = 0  OUTER LOOP
    sjLoop: 
        MOV R5, #0 // si =0 
        siLoop:
            MOV R8, #0 // sk = 0
            skLoop:
                BL doBlock
            ADD R8, R8, R11 //sk+=BLOCKSIZE
            CMP R8, R0  // check if sk<N to loop again
            BLT skLoop
        ADD R5, R5, R11 //si+=BLOCKSIZE
        CMP R5, R0  // check if si<N to loop again
        BLT iLoop
    ADD R4, R4, R11 //sj+=BLOCKSIZE
    CMP R4, R0  // check if sj<N to loop again
    BLT sjLoop

doBlock:
    MOV R6, #0 // sum = 0.0;
    MOV R12, R5 //i =si 
    iLoop: 
    MOV R13, R4 //j =sj
        jLoop:
            LDR R7, =sums
            .word 0XED876B00 //FSTD R6, [ R7#0]  store sums into R6
            MOV R14, R8 //k =sk
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
                .word 0xDD976B00 //LDR r6, [r7, #0]  
                .word 0x1BC52F613 //FMULD R7 R9, R11    A[i][k] * B[k][j] in r7
                .word 0xDE366B07//FADDD R6, R6, R7    R7 = sum + A[i][k] * B[k][j]
                LDR R7, =sums // update sums
                .word 0XED876B00 //FSTD R6, [ R7#0]  store sums into R6

                ADD R14, R14, #1 //k++
                ADD R15, R8,  R11//sk+BLOCKSIZE
                CMP R14, R15  // check if k<sk+BLOCKSIZE to loop again
                BLT kLoop

        //C[i][j] = sum;
        LDR R7, =sums // update sums
        .word 0xDD976B00 //LDR r6, [r7, #0]  
        MUL R10, R4, R0  //  i*size(row) = i*N 
        ADD R10, R5, R10, LSL#3 // k*size(row) + j  -->   compute base address --> LSL#3  gives address of B[k][j] 
        ADD R7, R3, R10 // sum = matrix_c + address
        .word 0XED876B00 //FSTD R6, [ R7#0]  store sums into R6

        ADD R13, R13, #1 //j++
        ADD R15, R4,  R11//sj+BLOCKSIZE
        CMP R13, R15  // check if j<sj+BLOCKSIZE to loop again
        BLT jLoop

    ADD R12, R12, #1 //i++
    ADD R15, R5,  R11 //si+BLOCKSIZE
    CMP R12, R15  // check if i<si+BLOCKSIZE to loop again
    BLT iLoop	
    	
  

	









 
