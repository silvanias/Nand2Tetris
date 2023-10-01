[[Nand2Tetris]]
tags:: #SE_11 #LLL  
dates:: 2023-06-14 
relevant:: 

--- 
# Nand2Tetris Chapter 2

## 2.1 Arithmetic Operations
At a very minimum a general-purpose computer system is required to perform the following arithmetic operations on signed integers:
- Addition
- Sign conversion
- Subtraction
- Comparison
- Multiplication
- Division 
In a very similar way to the last chapter of this project, the basic building block of addition can be used to implement all other operations. I will not go through the effort of proving this as I think its pretty obvious, and will come up in the implementation of the functions anyhow.

## 2.2 Binary Numbers 
I'm already pretty confident of my knowledge on how binary numbers "work" but as a brief summary:
A number in the decimal system, for example 442, can be broken down by digit to show that it is the summation of:
$442_{10} = 4*10^{2}+ 4*10^{1}+2*10^{0}= 442$
Now if we look at a binary number, for example 1001, we can do the exact same thing:
$1001_{2} = 1*2^{3}+0*2^{2}+ 0*2^{1}+1*2^{0}= 9_{10}$
When I first learned this it really helped me to understand that having a base-10 number system is no more special than a base-9 or 11, and binary is simply the lowest number you can have. In a computer everything is stored in binary, and so when asking a high level language to add 9 + 10, both values are converted into binary first, then added, then converted back to denary, then displayed to a user.

The hardware term "word size" is used to describe the amount of bits that computers use for representing a basic chunk of information. This is important to have as numbers themselves are of course unbounded, yet this is impossible to represent in a computer as you would need infinite binary digits to represent these numbers. In general, using $n$ bits we can represent all nonnegative integers ranging from 0 to $2^n-1$.
Word size applies a limit to what we can represent in a processor. Typically, 8, 16, 32, or 64-bit registers are used for representing integers (respectively, byte, short, int and long). Computing operations on 16-bit numbers is 4 times faster than 64-bit numbers and so it is always recommended to use the most compact data type as you can.

## 2.3 Binary Addition
Binary addition can be surmised with these three simple rules:
- 0 + 0 = 0
- 1 + 0 = 1
- 1 + 1 = 0 carry 1
To add two numbers simply go back to elementary school days and stack the bits of the two numbers and add them column by column, starting with the least significant bits and ending with the most significant bits (MSB):
![[Pasted image 20230617185440.png]]
As you can see in the above example we have an overflow, in which the most significant bitwise addition generates a carry of 1. As the programmer of a system you can choose to do with this information what you will, but I am just going to ignore it. I am happy to guarantee that the result of adding any two n-bit numbers is correct up to n bits. While this might sound slightly crazy this is not an insane decision (I promise). 

## 2.4 Signed binary 
As shown previously an n-bit binary system can code $2^n$ different things. In my computer I would of course like to be able to represent negative numbers (at the very least so we can do subtraction), and the most common solution to do this in binary is called "Two's complement" which is a beautifully elegant solution for reasons I will demonstrate. 
In a binary system that uses a word size of n bits, the two's complement bitstream that represents negative x is taken to be the bitstream that represents $2^{n}-x$. Simply put, if a number is negative the MSB is set to 1, and all the digits after it minus from this number. If we have a 4-bit system, -4 is represented by $2^{4} - 4 = 4$, and so -4 = 1100. -8 as the MSB, then add on 4.
Some facts about an n-bit binary system with two's complement representation:
- The system codes $2^n$ signed numbers, ranging from $-2^{n-1}$ to $2^{n-1}-1$.
- The MSB of any nonnegative number begins with a 0.
- The MSB of any negative number begins with a 1.
- If you want the bitstream of -x from the bitstream of x, simply invert all the bits of x and add 1 to the result.
Here is the real elegance in two's complement: subtraction. Consider 5 - 6, we can view this of course as 5 + (-6), and to do this in binary it is simply 0101 + 1010. The result is 1111 which turns out to be the binary code of -1. Another example to validate an earlier decision: (-3) + (-4) = 1101 + 1100 = (ignoring the overflow bit) 1001 = -7. With this technique its quite clear to see that addition and subtraction are handled the exact same way with no difference in implementation.
Basically every arithmetic operation can be implemented reductively using binary addition, and so this combined with the lack of need for special hardware makes life much much easier.

## 2.5 Specification 
In this section I will lay out the chips needed, with the end goal being an arithmetic logic unit.

- Half-adder: The first step to adding binary numbers is to simply add two bits using the rules I defined previously:
![[Screenshot 2023-06-17 at 20.14.17.png]]
```API Style
Chip name: HalfAdder
Input: a, b
Output: sum, carry
Function: 
sum = LSB of a + b
carry = MSB of a + b
```
As you can see I will treat the result of the addition as two separate bits, sum and carry.

- Full-adder: The full-adder is very similar to the half-adder and has a familiar method of construction to the previous chapter:
![[Screenshot 2023-06-17 at 20.18.48.png]]
```API Style
Chip name: FullAdder
Input: a, b, c
Output: sum, carry
Function: 
sum = LSB of a + b + c
carry = MSB of a + b + c
```
- Adder: This chip is much more general; its job is to add two n-bit numbers.
![[Screenshot 2023-06-17 at 20.21.17.png]]
```API Style
Chip name: Add16
Input: a[16], b[16]
Output: out[16]
Function: Adds two 16-bit numbers, ignoring the overflow bit.
```
Though I have specified a 16-bit adder here, it should go without saying this logic design can be easily extended to implement any n-bit adder chip.
-  Incrementer:
This chip is very simple, it just adds 1 to a given number (Im going to need it for the fetch decode execute cycle later). This can of course be done by the previous adder chip but it can be done much more efficiently with a dedicated incrementer chip.
```API Style
Chip name: Inc16
Input: in[16]
Output: out[16]
Function: out = in + 1, ignoring the overflow bit.
```

## 2.5.2 The Arithmetic Logic Unit
The big end goal of this chapter is to work towards a computational centerpiece of our central processing unit, the ALU. An Arithmetic Logic Unit is a chip designed to compute a set of arithmetic and logic operations. Exactly which operations an ALU should be capable of is a design decision. Every chip before this are pretty generic, all computers use half adders or  multiplexers, and these have identical function regardless of the computer architecture. This is not the case with an ALU. In the case of this course it has been decided that the ALU will only perform integer arithmetic and that the ALU will be able to compute eighteen arithmetic-logical functions, shown below:
![[Screenshot 2023-06-18 at 14.06.47.png|500]]
The computers ALU operates on two 16-bit two's complement integers, and on six 1-bit inputs, called control bits. The control bits instruct the ALU with which function to compute. This incredibly simplistic ALU design is really very elegant. All control bits signify conditional micro-actions, which are then chained together from left to right to give a final result of one of the crucial arithmetic-logic functions:
![[Screenshot 2023-06-18 at 14.19.07.png]]
To illustrate this, lets suppose that we wish to decrement x by 1, for x = 24. To do this we feed the binary code into the x input and set the ALU's control bits to 001110 (row 12). According to the specification this should output 16 bits representing 24. Note that the zx and nx control bits are set to 0, so don't set x to 0 or negate it. The zy and ny bits are both set to 1, so we *first* 0 the input y *then* not it, returning 1111111111111111. This binary code represents -1 in two's complement. We then see that the f bit is set to 1 meaning the ALU will add both x and y, resulting in 24 + (-1). The final bit is set to 0 so the output is not inverted, returning x - 1 as we had hoped! As another quick example you can also see Demorgan's law creeping back in for the final row. 
There are more possibilities here (up to 64) with some of them actually being useful, however I have decided not to overcomplicate the logic design. You may also wonder what the zr and ng outputs are for, and this is simply to tell the cpu whether the outputted number is negative or zero. 
The trade-off chosen in this project is to design a basic ALU with minimal funcitonality and use system software to implement any further mathematical operations as needed. For example multiplication and division can be done using efficient bitwise algorithms. 
```API Style
Chip name: ALU
Input: 
	x[16], y[16], // 16-but data inputs
	zx,           // Zero x input
	nx,           // Negate x input
	zy,           // Zero y input
	ny,           // Negate y input
	f,            // if f out=add(x,y) else out=and(x,y)
	no            // Negate the out input
Output: 
	out[16],      // 16-bit output
	zr,           // if out==0 zr=1 else zr=0
	ng            // if out<0 ng=1 else ng=0
Function:
	if zx x=0     // 16-bit zero constant 
	if nx x=!x    // Bit-wise negation
	if zy y=0     // 16-bit zero constant
	if ny y=!y    // Bit-wise negation
	if f out=x+y  // Integer two's complement addition
	else out=x&y  // Bit-wise And
	if no out=!out           // Bit-wise negation
	if out==0 zr=1 else zr=0 // 16-bit equality comparison
	if out<0 ng=1 else ng=0  // two's complement comparison
Comment: The overflow bit is ignored.
```

## 2.6 Implementation

### Adder chips
The logic diagram for the half-adder comes from recognising that the individual bits sum and carry match the truth tables for already implemented elementary logic gates:
```HDL
/**
 * Computes the sum of two bits.
 */

CHIP HalfAdder {
    IN a, b;    // 1-bit inputs
    OUT sum,    // Right bit of a + b 
        carry;  // Left bit of a + b

    PARTS:
    And(a=a, b=b, out=carry);
    Xor(a=a, b=b, out=sum);

}
```
Full adder:
```HDL
/**
 * Computes the sum of three bits.
 */

CHIP FullAdder {
    IN a, b, c;  // 1-bit inputs
    OUT sum,     // Right bit of a + b + c
        carry;   // Left bit of a + b + c

    PARTS:
    HalfAdder(a=a, b=b, sum=sum1, carry=carry1);
    HalfAdder(a=sum1, b=c, sum=sum, carry=carry2);
    Or(a=carry1, b=carry2, out=carry);
}
```
16-bit Adder:
```HDL
/**
 * Adds two 16-bit values.
 * The most significant carry bit is ignored.
 */

CHIP Add16 {
    IN a[16], b[16];
    OUT out[16];

    PARTS:
    FullAdder(a=a[0], b=b[0], sum=out[0], carry=carry0);
    FullAdder(a=a[1], b=b[1], c=carry0, sum=out[1], carry=carry1);
    FullAdder(a=a[2], b=b[2], c=carry1, sum=out[2], carry=carry2);
    FullAdder(a=a[3], b=b[3], c=carry2, sum=out[3], carry=carry3);
    FullAdder(a=a[4], b=b[4], c=carry3, sum=out[4], carry=carry4);
    FullAdder(a=a[5], b=b[5], c=carry4, sum=out[5], carry=carry5);
    FullAdder(a=a[6], b=b[6], c=carry5, sum=out[6], carry=carry6);
    FullAdder(a=a[7], b=b[7], c=carry6, sum=out[7], carry=carry7);
    FullAdder(a=a[8], b=b[8], c=carry7, sum=out[8], carry=carry8);
    FullAdder(a=a[9], b=b[9], c=carry8, sum=out[9], carry=carry9);
    FullAdder(a=a[10], b=b[10], c=carry9, sum=out[10], carry=carry10);
    FullAdder(a=a[11], b=b[11], c=carry10, sum=out[11], carry=carry11);
    FullAdder(a=a[12], b=b[12], c=carry11, sum=out[12], carry=carry12);
    FullAdder(a=a[13], b=b[13], c=carry12, sum=out[13], carry=carry13);
    FullAdder(a=a[14], b=b[14], c=carry13, sum=out[14], carry=carry14);
    FullAdder(a=a[15], b=b[15], c=carry14, sum=out[15]);
}
```
Incrementer:
```HDL
/**
 * 16-bit incrementer:
 * out = in + 1 (arithmetic addition)
 */

CHIP Inc16 {
    IN in[16];
    OUT out[16];

    PARTS:
    Add16(a=in, b[0]=true, out=out);
}
```
ALU:
```HDL
/**
 * The ALU (Arithmetic Logic Unit).
 * Computes one of the following functions:
 * x+y, x-y, y-x, 0, 1, -1, x, y, -x, -y, !x, !y,
 * x+1, y+1, x-1, y-1, x&y, x|y on two 16-bit inputs, 
 * according to 6 input bits denoted zx,nx,zy,ny,f,no.
 * In addition, the ALU computes two 1-bit outputs:
 * if the ALU output == 0, zr is set to 1; otherwise zr is set to 0;
 * if the ALU output < 0, ng is set to 1; otherwise ng is set to 0.
 */

// Implementation: the ALU logic manipulates the x and y inputs
// and operates on the resulting values, as follows:
// if (zx == 1) set x = 0        // 16-bit constant
// if (nx == 1) set x = !x       // bitwise not
// if (zy == 1) set y = 0        // 16-bit constant
// if (ny == 1) set y = !y       // bitwise not
// if (f == 1)  set out = x + y  // integer 2's complement addition
// if (f == 0)  set out = x & y  // bitwise and
// if (no == 1) set out = !out   // bitwise not
// if (out == 0) set zr = 1
// if (out < 0) set ng = 1

CHIP ALU {
    IN  
        x[16], y[16],  // 16-bit inputs        
        zx, // zero the x input?
        nx, // negate the x input?
        zy, // zero the y input?
        ny, // negate the y input?
        f,  // compute out = x + y (if 1) or x & y (if 0)
        no; // negate the out output?

    OUT 
        out[16], // 16-bit output
        zr, // 1 if (out == 0), 0 otherwise
        ng; // 1 if (out < 0),  0 otherwise

    PARTS: 
    // x
    And16(a=x, b=false, out=zeroxout);
    Mux16(a=x, b=zeroxout, sel=zx, out=zxout);
    Not16(in=zxout, out=notzxout);
    Mux16(a=zxout, b=notzxout, sel=nx, out=nxout);
    
    // y
    And16(a=y, b=false, out=zeroyout);
    Mux16(a=y, b=zeroyout, sel=zy, out=zyout);
    Not16(in=zyout, out=notzyout);
    Mux16(a=zyout, b=notzyout, sel=ny, out=nyout);

    // out
    And16(a=nxout, b=nyout, out=andxy);
    Add16(a=nxout, b=nyout, out=addxy);
    Mux16(a=andxy, b=addxy, sel=f, out=fmux);
    Not16(in=fmux, out=notfmux);
    Mux16(a=fmux, b=notfmux, sel=no, out=out, out[15]=ngf, out[0..7]=zf1, out[8..15]=zf2);
    
    // flags
    And(a=ngf, b=true, out=ng);
    Or8Way(in=zf1, out=zfg1);
    Or8Way(in=zf2, out=zfg2);
    Or(a=zfg1, b=zfg2, out=bfzf);
    Not(in=bfzf, out=zr);
}
```
Shown below is the circuit diagram for the ALU:
![[Screenshot 2023-06-19 at 17.35.23.png]]
You will have to use your imagination here as I did **not** want to display this in 16bits, but the underlying logic is basically the same.