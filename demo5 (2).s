DEPTH 4096
.define LED_ADDRESS 0x1000
.define HEX_ADDRESS 0x2000
.define SW_ADDRESS  0x3000

//fibonacci series in hex and binary. switches 0 - 7 control the speed.

START: mv   sp, =0x1000       // initialize sp to bottom of memory

MAIN:  mv   r0, =1
       bl   DISPLAY               // display r0 on HEX
       bl   DELAY

	mv r3, =LED_ADDRESS
        st r0, [r3] //store the value in binary on lEDs

       mv   r1, =0  //f(n-2)
       mv   r2, =1 // f(n-1)

LOOP:  add r1, r2 // fn = f(n-1) + f(n-2)
       mv r0, r1
       mv r1, r2
       mv r2, r0

	mv r3, #0xFF
	cmp r0, r3
	 bpl RESET
 	b LOAD

RESET: mv   r0, #1
	mv   r1, #0  //f(n-2)
       mv   r2, #1 // f(n-1)
	
LOAD:   bl   DISPLAY               // display r0 on HEX
        bl   DELAY

        mv r3, =LED_ADDRESS
        st r0, [r3] //store the value in binary on lEDs


        b LOOP


END:   b    LOOP







// display r0 onto the hex
DISPLAY:   push r1
       push r2
       push r3

       mv   r3, #0  // initilize r3 to 0  
	// load hex address
       mv   r2, =HEX_ADDRESS  
// display each digit in hex
DIV: mv   r1, r0     //copy r0 value into r1     
       lsr  r1, r3   // shift r0 by r3 (lsr same as dividing by 2^n) rather than getting digits in dec by dividing by 10^n we instead div by 16^n aka 2^(4n) for hex digits    
       and  r1, #0xF     // isolate by anding with 1111, every 4 bits is one hex numb, also why we are shifting by 4 each time (islote each 4 bits ex each hexs)  
       add  r1, #BITCODES  

	//load the bitcode into r1   
       ld   r1, [r1]    
	//store the bitcode into the display    
       st   r1, [r2]
	// shift to the next hex address (next display)
       add  r2, #1   
	// increment the shift value by 4        
       add  r3, #4  
	// compare the shift value to 16          
       cmp  r3, #16           
       bne  DIV  // if shift value is not currently 16 then repeat
       
       pop  r3
       pop  r2
       pop  r1
       mv   pc, lr

// delay for the board
DELAY: push r1
	push r2
	push r3


	
	// set r3 to some value we will count down to
	mv r3, #0xFFFF 
	mv r1, =SW_ADDRESS
    ld r2, [r1] // load the value for the switches
	// isolate switches being flipped
	and r2, #0b11111111
    //if no switches set then only wait once
    cmp r2, #0
    beq WAIT2

    // multiply to increase the delay effect
    //lsl r2, #2

// nested for loop to slow down the sequence
WAIT1:     sub r2, #1 //wait for the number of set by the switches
	mv r3, #0xFFFF // reset the counter value

WAIT2:    sub r3, #1  // sub the constant counter
	cmp r3, #0  // once it hits zero done looping
    bne WAIT2
    cmp r2, #0   // see if outer loop done
    bne WAIT1


	pop r3   //pop everything
        pop r2
	pop r1
       mv   pc, lr

BITCODES:  .word 0b00111111       // '0'
       .word 0b00000110       // '1'
       .word 0b01011011       // '2'
       .word 0b01001111       // '3'
       .word 0b01100110       // '4'
       .word 0b01101101       // '5'
       .word 0b01111101       // '6'
       .word 0b00000111       // '7'
       .word 0b01111111       // '8'
       .word 0b01100111       // '9'
       .word 0b01110111       // 'A'
       .word 0b01111100       // 'b'
       .word 0b00111001       // 'C'
       .word 0b01011110       // 'd'
       .word 0b01111001       // 'E'
       .word 0b01110001       // 'F'
