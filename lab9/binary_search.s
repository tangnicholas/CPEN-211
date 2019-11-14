.globl binary_search
binary_search:
	SUB sp, sp, #28 // adjust stack to make room for 5 items

	STR r0, [sp,#24]
	STR r7, [sp,#20]
	STR lr, [sp,#16]
	STR r6, [sp,#12] // save register r6 for use KeyIndex
	STR r5, [sp,#8] // save register r5 for use middleValuez
	STR r4, [sp,#4] // save register r4 for use middleIndex
	STR r8, [sp,#0] // save register r8 for use NumCalls 
	

	SUB r4, r3, r2 //(endindex-startindex)
	MOV r4, r4, LSR#1 //(endindex-startindex)/2
	ADD r4, r2, r4 //startIndex + (endindex-startindex)/2

	ADD r8, r8, #1 //NumCalls++

	CMP r2, r3 //compare start index and end index
	BLE startsearch //if start<end start the search
	
	//IF ERROR RETURN -1
	MOV r0, #-1  //theres an error if start>end return -1
	LDR lr, [sp, #16] //save register lr for LR 
	LDR r6, [sp,#12] // save register r6 for use KeyIndex
	LDR r5, [sp,#8] // save register r5 for use middleValuez
	LDR r4, [sp,#4] // save register r4 for use middleIndex
	ADD sp, sp, #24 //pop at end
	MOV PC, lr // branch back to main
	
	
startsearch: 
	LDR r5, [r0, r4, LSL #2] //store middleValue to r5
	
	CMP r5, r1 //compare middleValue and key
	BGT lowersearch //if middle > key go to uppersearch
	BLT uppersearch  //if middle < key go to lowersearch
	
	//if middleVlue = key 
    MOV r6, r4  //KeyIndex = MiddleIndex
	MOV r0, r6 // return KeyIndex
	B gotomain
	
uppersearch: //middleindex becomes startIndex
	MOV r2, r4
	ADD r2, #1
	BL binary_search
	B gotomain
	
lowersearch: // middleindex becomes endIndex
	MOV r3, r4 
	SUB r3, #1
	BL binary_search	
	B gotomain

gotomain:
	LDR r7, [sp, #24]
	LDR r8, [sp, #0]
	SUB r8, r8, r8, LSL #1 //numcalls = -numCalls
	STR r8, [r7, r5, LSL #2] //numbers[middleIndex] = -NumCalls

	
	LDR r6, [sp,#12] // save register r6 for use KeyIndex
	LDR r5, [sp,#8] // save register r5 for use middleValuez
	LDR r4, [sp,#4] // save register r4 for use middleIndex
	LDR lr, [sp, #16]
	STR r7, [sp,#20]

	ADD sp, sp, #24 //pop at end
	MOV PC, lr

