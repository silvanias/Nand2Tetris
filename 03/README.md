[[Nand2Tetris]]
tags:: #SE_11 #LLL  
dates:: 2023-06-29 
relevant:: 

--- 
# Nand2Tetris Chapter 3
So far all previously built chips have been time independent: they respond to different combinations of their inputs without delay, except for the time it takes the inner works to complete the computations. These types of chips are sometimes called *combinational*. In this chapter I will build *sequential* chips, which dependent not only on the inputs in current time but also on the inputs and outputs processed previously. 
To model the progression of time I will use a clock the generates on ongoing sequence of binary signals (looks like a square wave). The clocks signals are grouped in cycles, and these cycles are used to regulate the operations of all memory chips used by the computer.

## 3.1 Memory Devices
As humans we tend to take for granted the fact that we remember things over time, but this is actually quite hard to implement in logic, which is aware of neither time nor state. We need both of these things in order to use variables in computer programs.
The core time dependent logic gate that is used is called the "data flip-flop", which can flip and flop  between two stable states (0 and 1 respectively). DFF's can be used to create 1-bit registers, then n-bit registers, and eventually a RAM device which will contain a number of such n-bit registers. 

## 3.2 Sequential Logic
### 3.2.1 Time Matters
Previously I have assumed that any operations done are done instantly, however in reality outputs are always delayed, due to at least two reasons:
1. The inputs of chips do not instantly arrive, they have come from the outputs of chips before them and this travel takes time.
2. The computation the chip performs also takes time, imagine the ALU with how many chip parts it has that its input signals must traverse through.
Thus this must be accounted for in the computer. Time is typically seen to be a thing of continual progression, between every two points in time there are also infinitely small points in time. This is not practical for computer scientists and so time is broken into fixed-length cycles. This has the happy effect of allowing us to synchronise different operations across the system.
The duration of a cycle is chosen to be slightly longer than the maximum time delay in any chip in the system.
![[Screenshot 2023-06-29 at 17.12.05.png]]
As shown above, we really only want to read the output of the Not gate once the initial time delay is over and it has stabilised to a value. If we do this then we never encounter the time delays, and it simply appears like the gate has instantly outputted the correct output. Due to the progress in switching technologies, hardware engineers are currently making the duration of a cycle last about a billionth of a second, which makes a computer incredibly fast.

### 3.2.2 Flip-Flops 
There are particular types of low-level devices that enables the storing of information over time called "flip-flop" gates. There are four different types of flip-flops (which can all be converted to each other) but in Nand2Tetris I will use a "data flip-flop" whose interface includes a single-bit input and a single-bit output. Additionally the DFF has a clock input which feeds from the master clock's signal. Using both the data and clock inputs the DFF outputs the input value from the previous cycle at the end of every cycle, like so (the clock input is marked as a small triangle):
![[Screenshot 2023-06-29 at 17.42.04.png|500]]
All DFF's across a computer are connected to the same master clock by means of a dedicated clock bus that feeds the master clock signal to all the DFF gates in the system.

### 3.2.3 Combinational and Sequential Logic
Shown below is a typical sequential logic design which feeds from, and connects to combinational chips. The purpose of this is to give sequential chips the ability to respond to current as well as previous inputs and outputs.
![[Screenshot 2023-06-29 at 18.02.43.png|400]]
Without the addition of the DFF gates this chip would have an infinite feedback loop, as the output of the combinational logic gate would depend on a previous output, which would depend on a previous output, which would depend on a.... The DFF introduces a time delay to make this previous output be something different to the current input.
To reiterate, the use of cycles here is crucial. If we ask the ALU to add x + y, in which x is in L1 cache and y is on a hard drive, the output will be complete trash, **until** y arrives back at the ALU and output is stabilised. It is crucially important that the computers clock cycle takes slightly longer than the time it takes for a bit to travel the longest distance from one side of the chip to the other, and then only look at the ALU's output after a cycle is complete. This enables *synchronicity* (wowww).

## 3.3 Specification
The four memory chips that I will implement this chapter are as follows:
- Data flip-flops (already gone over)
- Registers
- RAM Devices
- Counters

### 3.3.2 Registers
I will implement a single-bit register, named `Bit` and a 16-bit register, named `Register`. The Bit chip will store a single bit of data over time. The chip interface consists of an `in` input which carries the data bit, a `load` input that enables the register for writes, and an `out` output that emits the current state of the register.
If the load bit equals false, the register is latched maintaining its current value (regardless of input bit).
```HDL
Chip name: Bit (1-bit register)
Input: in, load
Output: out
Function: 
if load(t) then out(t+1) = in(t)
else            out(t+1) = out(t)
```
![[Screenshot 2023-06-29 at 18.46.05.png |400]]

The 16-bit `Register` chip behaves the exact same way but for 16-bit values.
```HDL
Chip name: Register (16-bit register)
Input: in[16], load
Output: out[16]
Function: 
if load(t) then out(t+1) = in(t)
else            out(t+1) = out(t)
```

### 3.3.3 Random Access Memory
A direct-access memory unit is an aggregate of $n$ `Register` chips. Much like in an array a number between 0 and n-1 can be selected to access each register in the RAM, to read/write to. Just like arrays it is important to note the accessing of any address in RAM is $O(1)$ regardless of the register's address or size of RAM.
```HDL
Chip name: RAMn
Input: in[16], load, address[k] (k = log_2(n))
Output: out[16]
Function: Out emits the value stored at the register specified by address. If load==1 then the register specified by address is set to the value of in. The loaded value will be emitted by out from the next cycle onward.
```
![[Screenshot 2023-06-29 at 19.01.06.png|300]]

### 3.3.4 Counter
The counters only function is to increment its value by 1 each time unit. Once the full architecture of the computer is realised ill use the counter (program counter) in the fetch-decode-execute cycle. The interface of the PC is actually very similar to a register, except that it has the control bits `inc` and `reset`. When inc == 1, the the PC increments its state every clock cycle. To reset the counter to 0 (needed once a program has completed), the reset bit must be set to 1. All the rest of the functions it shares with registers.
```HDL
Chip name: PC
Input: in[16], load, inc, reset
Output: out[16]
Function: 16-bit counter
if reset(t)     out(t+1) = 0
else if	load(t) out(t+1) = in(t)
else if	inc(t)  out(t+1) = out(t) + 1
else            out(t+1) = out(t)
```

## 3.4 Implementation
The Data Flip Flop's functionality can be implemented in several different ways, including ones that use Nand gates only. Unfortunately these implementations are impossible to model in the current hardware simulator I am using, as they require feedback loops among combinational gates. As such I will be treating the DFF as a primitive building block and use a built-in implementation.
Bit:
```API
/**
 * 1-bit register:
 * If load[t] == 1 then out[t+1] = in[t]
 *                 else out does not change (out[t+1] = out[t])
 */

CHIP Bit {
    IN in, load;
    OUT out;

    PARTS:
    Mux(a=DFFcyc, b=in, sel=load, out=muxout);
    // muxout goes through DFF, introducing a time delay
    // and avoiding a cyclical data race.
    DFF(in=muxout, out=DFFcyc, out=out);
}
```
Register:
```API
/**
 * 16-bit register:
 * If load[t] == 1 then out[t+1] = in[t]
 * else out does not change
 */

CHIP Register {
    IN in[16], load;
    OUT out[16];

    PARTS:
    Bit(in=in[0], load=load, out=out[0]);
    Bit(in=in[1], load=load, out=out[1]);
    Bit(in=in[2], load=load, out=out[2]);
    Bit(in=in[3], load=load, out=out[3]);
    Bit(in=in[4], load=load, out=out[4]);
    Bit(in=in[5], load=load, out=out[5]);
    Bit(in=in[6], load=load, out=out[6]);
    Bit(in=in[7], load=load, out=out[7]);
    Bit(in=in[8], load=load, out=out[8]);
    Bit(in=in[9], load=load, out=out[9]);
    Bit(in=in[10], load=load, out=out[10]);
    Bit(in=in[11], load=load, out=out[11]);
    Bit(in=in[12], load=load, out=out[12]);
    Bit(in=in[13], load=load, out=out[13]);
    Bit(in=in[14], load=load, out=out[14]);
    Bit(in=in[15], load=load, out=out[15]);
}
```
Program counter:
```API
/**
 * A 16-bit counter with load and reset control bits.
 * if      (reset[t] == 1) out[t+1] = 0
 * else if (load[t] == 1)  out[t+1] = in[t]
 * else if (inc[t] == 1)   out[t+1] = out[t] + 1  (integer addition)
 * else                    out[t+1] = out[t]
 */

CHIP PC {
    IN in[16],load,inc,reset;
    OUT out[16];

    PARTS:
    // Always store previous out
    Register(in=tmuxin, load=true, out=out, out=incin);
    
    Inc16(in=incin, out=incout);
    // Do you want to add one to the previous out?
    Mux16(a=incin, b=incout, sel=inc, out=fmuxin);
    
    // Take in the new input?
    Mux16(a=fmuxin, b=in, sel=load, out=smuxin);
    // Zero the value?
    Mux16(a=smuxin, b=false, sel=reset, out=tmuxin);
}
```
I appreciate this implementation is a little hard to understand (I had trouble understanding it too haha), but if you follow the paths of possible inputs through I guarantee it works.
RAM:
The computer I am building requires a RAM device of 16K (16384) 16-bit registers, which would be a ginormous pain to do in all one go, and so I am doing a gradual process.
```API
/**
 * Memory of 8 registers, each 16 bit-wide. Out holds the value
 * stored at the memory location specified by address. If load==1, then 
 * the in value is loaded into the memory location specified by address 
 * (the loaded value will be emitted to out from the next time step onward).
 */

CHIP RAM8 {
    IN in[16], load, address[3];
    OUT out[16];

    PARTS:
    DMux8Way(in=load, sel=address, a=loada, b=loadb, c=loadc, 
    d=loadd, e=loade, f=loadf, g=loadg, h=loadh);    
    Register(in=in, load=loada, out=a);
    Register(in=in, load=loadb, out=b);
    Register(in=in, load=loadc, out=c);
    Register(in=in, load=loadd, out=d);
    Register(in=in, load=loade, out=e);
    Register(in=in, load=loadf, out=f);
    Register(in=in, load=loadg, out=g);
    Register(in=in, load=loadh, out=h);
    Mux8Way16(a=a, b=b, c=c, d=d, e=e, f=f, g=g, h=h, 
    sel=address, out=out);
}
```
64 16-bit registers:
```API
/**
 * Memory of 64 registers, each 16 bit-wide. Out holds the value
 * stored at the memory location specified by address. If load==1, then 
 * the in value is loaded into the memory location specified by address 
 * (the loaded value will be emitted to out from the next time step onward).
 */

CHIP RAM64 {
    IN in[16], load, address[6];
    OUT out[16];

    PARTS:
    DMux8Way(in=load, sel=address[0..2], a=loada, b=loadb, c=loadc,
    d=loadd, e=loade, f=loadf, g=loadg, h=loadh);
    RAM8(in=in, load=loada, address=address[3..5], out=a);
    RAM8(in=in, load=loadb, address=address[3..5], out=b);
    RAM8(in=in, load=loadc, address=address[3..5], out=c);
    RAM8(in=in, load=loadd, address=address[3..5], out=d);
    RAM8(in=in, load=loade, address=address[3..5], out=e);
    RAM8(in=in, load=loadf, address=address[3..5], out=f);
    RAM8(in=in, load=loadg, address=address[3..5], out=g);
    RAM8(in=in, load=loadh, address=address[3..5], out=h);
    Mux8Way16(a=a, b=b, c=c, d=d, e=e, f=f, g=g, h=h,
    sel=address[0..2], out=out);
}
```
512 16-bit registers:
```API
/**
 * Memory of 512 registers, each 16 bit-wide. Out holds the value
 * stored at the memory location specified by address. If load==1, then 
 * the in value is loaded into the memory location specified by address 
 * (the loaded value will be emitted to out from the next time step onward).
 */

CHIP RAM512 {
    IN in[16], load, address[9];
    OUT out[16];

    PARTS:
    DMux8Way(in=load, sel=address[0..2], a=loada, b=loadb, c=loadc,
    d=loadd, e=loade, f=loadf, g=loadg, h=loadh);
    RAM64(in=in, load=loada, address=address[3..8], out=a);
    RAM64(in=in, load=loadb, address=address[3..8], out=b);
    RAM64(in=in, load=loadc, address=address[3..8], out=c);
    RAM64(in=in, load=loadd, address=address[3..8], out=d);
    RAM64(in=in, load=loade, address=address[3..8], out=e);
    RAM64(in=in, load=loadf, address=address[3..8], out=f);
    RAM64(in=in, load=loadg, address=address[3..8], out=g);
    RAM64(in=in, load=loadh, address=address[3..8], out=h);
    Mux8Way16(a=a, b=b, c=c, d=d, e=e, f=f, g=g, h=h,
    sel=address[0..2], out=out);
} 
```
4096 16-bit registers:
```API
/**
 * Memory of 4K registers, each 16 bit-wide. Out holds the value
 * stored at the memory location specified by address. If load==1, then 
 * the in value is loaded into the memory location specified by address 
 * (the loaded value will be emitted to out from the next time step onward).
 */

CHIP RAM4K {
    IN in[16], load, address[12];
    OUT out[16];

    PARTS:
    DMux8Way(in=load, sel=address[0..2], a=loada, b=loadb, c=loadc,
    d=loadd, e=loade, f=loadf, g=loadg, h=loadh);
    RAM512(in=in, load=loada, address=address[3..11], out=a);
    RAM512(in=in, load=loadb, address=address[3..11], out=b);
    RAM512(in=in, load=loadc, address=address[3..11], out=c);
    RAM512(in=in, load=loadd, address=address[3..11], out=d);
    RAM512(in=in, load=loade, address=address[3..11], out=e);
    RAM512(in=in, load=loadf, address=address[3..11], out=f);
    RAM512(in=in, load=loadg, address=address[3..11], out=g);
    RAM512(in=in, load=loadh, address=address[3..11], out=h);
    Mux8Way16(a=a, b=b, c=c, d=d, e=e, f=f, g=g, h=h,
    sel=address[0..2], out=out);
} 
```
And finally, 16,384 16-bit registers:
```API
/**
 * Memory of 16K registers, each 16 bit-wide. Out holds the value
 * stored at the memory location specified by address. If load==1, then 
 * the in value is loaded into the memory location specified by address 
 * (the loaded value will be emitted to out from the next time step onward).
 */

CHIP RAM16K {
    IN in[16], load, address[14];
    OUT out[16];

    PARTS:
    DMux4Way(in=load, sel=address[0..1], a=loada, b=loadb, c=loadc,
    d=loadd);
    RAM4K(in=in, load=loada, address=address[2..13], out=a);
    RAM4K(in=in, load=loadb, address=address[2..13], out=b);
    RAM4K(in=in, load=loadc, address=address[2..13], out=c);
    RAM4K(in=in, load=loadd, address=address[2..13], out=d);
    Mux4Way16(a=a, b=b, c=c, d=d, sel=address[0..1], out=out);
}
```
My chunk of RAM is now completely finished :).