//PART4
.include    "address_map_arm.s" 
.include    "interrupt_ID.s" 

/* ********************************************************************************
 * This program demonstrates use of interrupts with assembly language code.
 * The program responds to interrupts from the pushbutton KEY port in the FPGA.
 *
 * The interrupt service routine for the pushbutton KEYs indicates which KEY has
 * been pressed on the LED display.
      
 This code is from "interupt_example.s", as provided by Altera.
 ********************************************************************************/

.section    .vectors, "ax" 

            B       _start                  // reset vector
            B       SERVICE_UND             // undefined instruction vector
            B       SERVICE_SVC             // software interrrupt vector
            B       SERVICE_ABT_INST        // aborted prefetch vector
            B       SERVICE_ABT_DATA        // aborted data vector
.word       0 // unused vector
            B       SERVICE_IRQ             // IRQ interrupt vector
            B       SERVICE_FIQ             // FIQ interrupt vector

.text

.global PD_ARRAY
            PD_ARRAY:
      .fill       17,4,0xDEADBEEF               //Process 0
      .fill       13,4,0xDEADBEE1               //Process 1
      .word       0x3F000000              //SP
      .word       0                       //LR
      .word       PROC1+4                 //PC
      .word       0x53                    //CPSR (0x53 means IRQ enabled, mode = SVC)

.global count_global
            count_global: .fill 1,4,0x0
.global CHAR_BUFFER
            CHAR_BUFFER: .word 0
.global CHAR_FLAG
            CHAR_FLAG: .word 0
.global CURRENT_PID
            CURRENT_PID: .word 0
.global     _start      
_start:

/* Set up stack pointers for IRQ and SVC processor modes */
            MOV     R1, #0b11010010         // interrupts masked, MODE = IRQ
            MSR     CPSR_c, R1              // change to IRQ mode
            LDR     SP, =A9_ONCHIP_END - 3  // set IRQ stack to top of A9 onchip memory
/* Change to SVC (supervisor) mode with interrupts disabled */
            MOV     R1, #0b11010011         // interrupts masked, MODE = SVC
            MSR     CPSR, R1                // change to supervisor mode
            LDR     SP, =DDR_END - 3        // set SVC stack to top of DDR3 memory

            BL      CONFIG_GIC             // configure the ARM generic interrupt controller

                                            // write to the pushbutton KEY interrupt mask register
            LDR     R0, =KEY_BASE           // pushbutton KEY base address
            MOV     R1, #0xF               // set interrupt mask bits
            STR     R1, [R0, #0x8]          // interrupt mask register is (base + 8)

                                            // enable IRQ interrupts in the processor
            MOV     R0, #0b01010011         // IRQ unmasked, MODE = SVC
            MSR     CPSR_c, R0              

//ADDED code to congigure the timer (referenced from DE1-SoC_Computer.pdf): 
            LDR   R2, =0xFFFEC600 // MPCore private timer base address
            LDR   R3, =100000000 // timeout = 1/(200 MHz) x 100×10 ∧ 6 = 0.5 sec
            STR   R3, [R2] // write to timer load register
            MOV   R3, #0b111 // set bits: I = 1,  A = 1, enable = 1, and prescaler is 0.
            STR   R3, [R2, #0x8] // write to timer control register
            MSR   CPSR_c, R0 

//ADDED code to configure interrupts when you type on keyboard
            LDR   R0, =0xFF201004 //dataregister control address
            LDR   R1, =0x1 //RE is set to 1
            STR   R1, [R0]

    
IDLE:
            LDR   R11, =CURRENT_PID
            MOV   R12, #0
            STR   R12, [R11]

            LDR   R4, =CHAR_FLAG
            LDR   R5, [R4]
            CMP   R5, #1
            BEQ   R_CHARBUFF
PROC1:
            MOV   R8, #0 //count

WHILELOOP:  ADD   R8, R8, #1 //Add 1 to count
            LDR   R10, =LED_BASE // base address of LED display
            STR   R8, [R10] // display value on red LEDs

            MOV   R9, #0 //i
DOWHILE:    ADD   R9, R9, #1

            LDR   R13, =0xBEBC200
            CMP   R9, R13 //LARGE_NUMBER should delay for ~1s at 200MHz clk speed
            BLT   DOWHILE
            B     WHILELOOP

R_CHARBUFF:
            LDR   R6, =CHAR_BUFFER
            LDR   R0, [R6]
            BL    PUT_JTAG

            LDR   R7, =0x0
            STR   R7, [R4]

            B     IDLE


PUT_JTAG:   
            LDR   R1, =0xFF201000
            LDR   R2, [R1, #4] 
            LDR   R3, =0xFFFF
            ANDS  R2, R2, R3
            BEQ   END_PUT
            STR   R0, [R1]

END_PUT:    BX    LR


/* Define the exception service routines */

/*--- Undefined instructions --------------------------------------------------*/
SERVICE_UND:                                
            B       SERVICE_UND             

/*--- Software interrupts -----------------------------------------------------*/
SERVICE_SVC:                                
            B       SERVICE_SVC             

/*--- Aborted data reads ------------------------------------------------------*/
SERVICE_ABT_DATA:                           
            B       SERVICE_ABT_DATA        

/*--- Aborted instruction fetch -----------------------------------------------*/
SERVICE_ABT_INST:                           
            B       SERVICE_ABT_INST        

/*--- IRQ ---------------------------------------------------------------------*/
SERVICE_IRQ:                                
            PUSH    {R0-R7, LR}             

/* Read the ICCIAR from the CPU interface */
            LDR     R4, =MPCORE_GIC_CPUIF   
            LDR     R5, [R4, #ICCIAR]       // read from ICCIAR

//ADDED to check for timer interupt
            CMP   R5, #MPCORE_PRIV_TIMER_IRQ
            BNE   FPGA_IRQ1_HANDLER //if not timer interrupt, check key interrupt

//ADDED FOR PART 4
                  LDR R0, =CURRENT_PID
                  LDR R1, [R0]
                  CMP R1, #0

                  BEQ secondarray
                  BNE firstarray

firstarray:
            LDR         R13, =PD_ARRAY
                  STM R13!, {R0-R15}
                  MOV R1, #0
                  STR R1, [R0]
            LDR         R0, [R13, #0]
            LDR         R1, [R13, #4]
            LDR         R2, [R13, #8]
            LDR         R3, [R13, #12]
            LDR         R4, [R13, #16]
            LDR         R5, [R13, #20]
            LDR         R6, [R13, #24]
            LDR         R7, [R13, #28]
            LDR         R8, [R13, #32]
            LDR         R9, [R13, #36]
            LDR         R10, [R13, #40]
            LDR         R11, [R13, #44]
            LDR         R12, [R13, #48]
                  LDR   R14, [R13, #56]
                  LDR         R13, [R13, #52]
                  SUBS  PC, LR, #4
                  LDR         R0, =PD_ARRAY  //load CPSR to register
                  MSR         SPSR, R0 //
                  B           CHECK_JTAG_IN
secondarray:
            LDR         R13, =PD_ARRAY
                  ADD R13, R13, #68
                  STM R13!, {R0-R15}
                  MOV R1, #0
                  STR R1, [R0]

                  LDR         R0, [R13, #68]
            LDR         R1, [R13, #72]
            LDR         R2, [R13, #76]
            LDR         R3, [R13, #80]
            LDR         R4, [R13, #84]
            LDR         R5, [R13, #88]
            LDR         R6, [R13, #92]
            LDR         R7, [R13, #96]
            LDR         R8, [R13, #100]
            LDR         R9, [R13, #104]
            LDR         R10, [R13, #108]
            LDR         R11, [R13, #112]
            LDR         R12, [R13, #116]
            LDR   R14, [R13, #120]
            LDR         R13, [R13, #124]
                  SUBS  PC, LR, #4
                  LDR         R0, =PD_ARRAY  //load CPSR to register
                  MSR         SPSR, R0 //
                  
//ADDED to process interrupts geenrated by the JTAG UART (with reference to exmaple in De1 pdf)
CHECK_JTAG_IN:
            LDR       R1, =JTAG_UART_BASE
            LDR       R0, [R1]
            ANDS      R2, R0, #0x8000 // check if there is new data
            BEQ       RET_NULL
            AND       R0, R0, #0x00FF

            LDR       R3, =CHAR_BUFFER    
            STR       R0, [R3]  //load global variable
            LDR       R2, =CHAR_FLAG //loading flag
            MOV       R3, #1
            STR       R3, [R2]

            B         TIMER_ISR



RET_NULL:   MOV       R0, #0
            B         TIMER_ISR

TIMER_ISR:          
            LDR   R6, =count_global
            LDR   R7, [R6]  //load global variable
            ADD   R7, R7, #1 //increment by 1
            STR   R7, [R6] //store new value

            B         EXIT_IRQ

FPGA_IRQ1_HANDLER:                          
            CMP     R5, #KEYS_IRQ   



UNEXPECTED: BNE     TIMER_ISR             // if not recognized, stop here
            BL      KEY_ISR      


EXIT_IRQ:                                   
/* Write to the End of Interrupt Register (ICCEOIR) */
            STR     R5, [R4, #ICCEOIR]      // write to ICCEOIR

            POP     {R0-R7, LR}             
            SUBS    PC, LR, #4              

/*--- FIQ ---------------------------------------------------------------------*/
SERVICE_FIQ:                                
            B       SERVICE_FIQ
.end

