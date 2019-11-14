.globl binary_search
binary_search:
	SUB sp, sp, #28 // adjust stack to make room for 7 items

	STR r0, [sp,#24] // save register r0 to use to return values
	STR r7, [sp,#20] // save regesiter for later use to adjust NumCalls
	STR lr, [sp,#16] // save register lr for remembering previous position 
	STR r6, [sp,#12] // save register r6 for use KeyIndex
	STR r5, [sp,#8] // save register r5 for use middleValuez
	STR r4, [sp,#4] // save register r4 for use middleIndex
	STR r8, [sp,#0] // save register r8 for use NumCalls 
	
	//find the middle index, save in r4
	SUB r4, r3, r2      //(endindex-startindex)
	MOV r4, r4, LSR#1   //(endindex-startindex)/2
	ADD r4, r2, r4      //startIndex + (endindex-startindex)/2

	ADD r8, r8, #1      //NumCalls++

	CMP r2, r3          //compare start index and end index
	BLE startsearch     //if start<end start the search
	
	//ERROR: start > end (key does not exist in array)
	MOV r0, #-1 		// return -1
	
	LDR lr, [sp, #16]  //load registers 7,6,5,4,lr to be poped
	LDR r7, [sp,#20] 	
	LDR r6, [sp,#12] 	
	LDR r5, [sp,#8] 	
	LDR r4, [sp,#4] 	
	ADD sp, sp, #24		//pop at end

	MOV PC, lr          //branch back to main
		
startsearch: 
	LDR r5, [r0, r4, LSL #2] //store middleValue to r5
	
	CMP r5, r1 //compare middleValue and key
	BGT lowersearch //if middle > key go to uppersearch
	BLT uppersearch  //if middle < key go to lowersearch
	
	//MiddleValue = key: now return the appropriate index 
    MOV r6, r4  //KeyIndex = MiddleIndex
	MOV r0, r6 // return KeyIndex
	B gotomain
	
lowersearch: 
	MOV r3, r4 // middleindex-1 becomes endIndex
	SUB r3, #1 
	BL binary_search //remember the following address to come back later
	B gotomain

uppersearch: 
	MOV r2, r4 //middleindex+1 becomes startIndex
	ADD r2, #1 
	BL binary_search //remember the following address to come back later
	B gotomain
	
gotomain:
	LDR r7, [sp, #24]  //loading r0 from stack into r7 to adjust numcalls
	
	LDR r8, [sp, #0]          //loading r8 to adjust numcalls
	SUB r8, r8, r8, LSL #1   //numcalls = -numCalls
	STR r8, [r7, r5, LSL #2] //numbers[middleIndex] = -NumCalls

	LDR r6, [sp,#12]    //load registers 7,6,5,4,lr to be poped
	LDR r5, [sp,#8] 
	LDR r4, [sp,#4] 
	LDR lr, [sp, #16]
	STR r7, [sp,#20]

	ADD sp, sp, #28 //pop at end
	MOV PC, lr // go back to previous branchlink to go back to MAIN
