/*** asmSort.s   ***/
#include <xc.h>
.syntax unified

@ Declare the following to be in data memory
.data
.align    

@ Define the globals so that the C code can access them
/* define and initialize global variables that C can access */
/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Benzen Raspur"  

.align   /* realign so that next mem allocations are on word boundaries */
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

@ Tell the assembler that what follows is in instruction memory    
.text
.align

/********************************************************************
function name: asmSwap(inpAddr,signed,elementSize)
function description:
    Checks magnitude of each of two input values 
    v1 and v2 that are stored in adjacent in 32bit memory words.
    v1 is located in memory location (inpAddr)
    v2 is located at mem location (inpAddr + M4 word size)
    
    If v1 or v2 is 0, this function immediately
    places -1 in r0 and returns to the caller.
    
    Else, if v1 <= v2, this function 
    does not modify memory, and returns 0 in r0. 

    Else, if v1 > v2, this function 
    swaps the values and returns 1 in r0

Inputs: r0: inpAddr: Address of v1 to be examined. 
	             Address of v2 is: inpAddr + M4 word size
	r1: signed: 1 indicates values are signed, 
	            0 indicates values are unsigned
	r2: size: number of bytes for each input value.
                  Valid values: 1, 2, 4
                  The values v1 and v2 are stored in
                  the least significant bits at locations
                  inpAddr and (inpAddr + M4 word size).
                  Any bits not used in the word may be
                  set to random values. They should be ignored
                  and must not be modified.
Outputs: r0 returns: -1 If either v1 or v2 is 0
                      0 If neither v1 or v2 is 0, 
                        and a swap WAS NOT made
                      1 If neither v1 or v2 is 0, 
                        and a swap WAS made             
             
         Memory: if v1>v2:
			swap v1 and v2.
                 Else, if v1 == 0 OR v2 == 0 OR if v1 <= v2:
			DO NOT swap values in memory.

NOTE: definitions: "greater than" means most positive number
********************************************************************/     
.global asmSwap
.type asmSwap,%function     
asmSwap:

    /* YOUR asmSwap CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    push    {r4, r5, lr}        /*save, we will use*/
    mov     r3, r1              /*r3 is a signed flag*/ 
   
    /*load v1 and v2 to elementSize frm flowchart and signed flag*/
    cmp     r2, 4
    beq     1f                  /*size = 4 go to load_word*/
    cmp     r2, 2
    beq     2f                  /*size = 2 go to load_half*/
     /*size = 1 byte */
0:                                  /*label off load_byte*/
    cmp     r3, 0
    beq     3f                  /*unsigned byte*/
    ldrsb   r4, [r0]            /*v1(is signed)*/
    ldrsb   r5, [r0, 4]       /*v2*/
    b       4f
3:                                  /*unsigned byte*/
    ldrb    r4, [r0]            /*v1*/
    ldrb    r5, [r0, 4]        /*v2*/
    b       4f
2:                                  /*label off load_byte*/
    cmp     r3, 0
    beq     5f                  /*unsigned word*/
    ldrsh   r4, [r0]             /*v1(is signed)*/
    ldrsh   r5, [r0, 4]         /*v2*/
    b       4f
5:                                  /*unsigned word*/
    ldrh    r4, [r0]            /*v1*/
    ldrh    r5, [r0, 4]        /*v2*/
    b       4f
1:                                  /*label load_word size 4)*/
    ldr     r4, [r0]            /*v1*/
    ldr     r5, [r0, 4]        /*v2*/
4:  /*values in r4 and r5 (v1) and (v2)*/

    /*Test (if v1=0 v2=0)*/
    cmp     r4, 0
    beq     swap_sentinel
    cmp     r5, 0
    beq     swap_sentinel

    /*Compare v1 and v2 if signed / unsigned*/
    cmp     r3, 0
    beq     compare_unsigned

    cmp     r4, r5              /*compare*/
    bgt     swap_do
    b       swap_no
compare_unsigned:
    cmp     r4, r5
    bhi     swap_do            /*unsigned is greater*/
    b       swap_no

swap_do:
    /*Store v2 at v1 location. And v1 at v2 location*/
    cmp     r2, 4
    beq     swap_word
    cmp     r2, 2
    beq     swap_half
    /*byte swap*/
swap_byte:
    strb    r5, [r0]
    strb    r4, [r0, 4]
    movs    r0, 1            /* return 1*/
    pop     {r4, r5, pc}
swap_half:
    strh    r5, [r0]
    strh    r4, [r0, 4]
    movs    r0, 1
    pop     {r4, r5, pc}
swap_word:
    str     r5, [r0]
    str     r4, [r0, 4]
    movs    r0, 1
    pop     {r4, r5, pc}
swap_no:
    movs    r0, 0
    pop     {r4, r5, pc}
swap_sentinel:
    /*return -1 as mentioned in planning*/
    movs    r0, #1
    rsbs    r0, r0, 0         /*r0=-1*/
    pop     {r4, r5, pc}
    /* YOUR asmSwap CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */
    
    
/********************************************************************
function name: asmSort(startAddr,signed,elementSize)
function description:
    Sorts value in an array from lowest to highest.
    The end of the input array is marked by a value
    of 0.
    The values are sorted "in-place" (i.e. upon returning
    to the caller, the first element of the sorted array 
    is located at the original startAddr)
    The function returns the total number of swaps that were
    required to put the array in order in r0. 
    
         
Inputs: r0: startAddr: address of first value in array.
		      Next element will be located at:
                          inpAddr + M4 word size
	r1: signed: 1 indicates values are signed, 
	            0 indicates values are unsigned
	r2: elementSize: number of bytes for each input value.
                          Valid values: 1, 2, 4
Outputs: r0: number of swaps required to sort the array
         Memory: The original input values will be
                 sorted and stored in memory starting
		 at mem location startAddr
NOTE: definitions: "greater than" means most positive number    
********************************************************************/     
.global asmSort
.type asmSort,%function
asmSort:   

    /* Note to Profs: 
     */

    /* YOUR asmSort CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
 @ Prologue ­– save needed callee‑saved registers
    push    {r4, r5, r6, r7, r8, r9, lr}

    mov     r4, r0      /*start address of array */
    mov     r5, r1      /*signed flag */
    mov     r6, r2      /*elementSize */
    movs    r7, #0      /*totalSwapCount=0 */

outer_pass:
    movs    r9, #0      /*swappedThis Pass*/
    mov     r8, r4      /*ptr = startAddr*/

inner_loop:
    mov     r0, r8      /* = current element address*/
    mov     r1, r5      /* signed flag*/
    mov     r2, r6      /* = elementSize */
    bl      asmSwap

    cmp     r0, 0
    blt     end_pass            /*r0 = -1  (negative) is equal greater than end of array */

    cmp     r0, 1
    beq     did_swap
    b       after_update

did_swap:
    adds    r7, r7, 1         
    movs    r9, 1            /*mark that we swapped this pass*/

after_update:
    adds    r8, r8, 4          /*ptr += sizeof(word)*/
    b       inner_loop

end_pass:
    cmp     r9, 1
    beq     outer_pass          /*if we swapped, do another pass here*/

    mov     r0, r7              /*return total swaps*/

    pop     {r4, r5, r6, r7, r8, r9, pc}



    /* YOUR asmSort CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




