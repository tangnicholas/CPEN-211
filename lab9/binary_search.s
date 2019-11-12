.globl binary_search
binary_search:
	SUB sp, sp, #36 // adjust stack to make room for 9 items
	STR r12, [sp,#32] // save register r12 for use afterwards
	STR r11, [sp,#28] // save register r11 for use afterwards
	STR r10, [sp,#24] // save register r10 for use afterwards
	STR r9, [sp,#20] // save register r9 for use afterwards
	STR r7, [sp,#16] // save register r7 for use afterwards

	STR r6, [sp,#12] // save register r6 for use KeyIndex
	STR r5, [sp,#8] // save register r5 for use middleValuez
	STR r4, [sp,#4] // save register r4 for use middleIndex
	// STR r8, [sp,#0] // save register r8 for use NumCalls 
	
	SUB r4, r3, r2 //(endindex-startindex)
	MOV r4, r4, LSR#1 //(endindex-startindex)/2
	ADD r4, r2, r4 //startIndex + (endindex-startindex)/2

	ADD r8, r8, #1 //NumCalls++

	CMP r2, r3 //compare start index and end index
	BGT gototheend  //theres an error if start>end 
	
	LDR r5, [r0, r4, LSL #2] //store middleValue to r5
	CMP r5, r1 //compare middleValue and key
	BEQ  //if middleVlue = key 
		MOV r6, r4	//KeyIndex = MiddleIndex
	BGT lowersearch //if middle > key go to uppersearch
	BLT uppersearch  //if middle < key go to lowersearch 
	
	STR r8, [sp,#0]
	SUB r8, r8, r8, LSL #1 //numcalls = -numCalls
	STR r8, [r0, r5, LSL #2] //numbers[middleIndex] = -NumCalls
	
	MOV r0, r6 // return KeyIndex
	MOV PC, LR
	
uppersearch: //middleindex becomes startIndex
	MOV r2, r4
	BL binary_search
	
lowersearch: // middleindex becomes endIndex
	MOV r3, r4
	BL binary_search

gototheend: //returns -1 
	MOV r0, #-1
	MOV PC, LR
