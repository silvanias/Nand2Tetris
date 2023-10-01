[[Nand2Tetris]]
tags:: #SE_11 #LLL  
dates:: 2023-08-11 
relevant:: 

--- 
# Nand2Tetris Chapter 5
This is the chapter in which I put it all together, combining the chips built in chapters 1-3 and integrating them into a general-purpose computer system. This system is a very simple machine however is sufficiently powerful to illustrate all key operating and hardware principles of any general-purpose computer.
## 5.1 Computer Architecture Fundamentals
### 5.1.1 The Stored Program Concept
The stored program concept comes down to this: Programs/instructions should be treated as just another form of data.
The stored program concept to me is always a joyous one to think about as, though I can  understand why it is important from an academic point of view, it feels like an embedded (hehe) truth that is inseparable from the concept of a general purpose computer. It is amazing to imagine what a stroke of genius it must have been to go from having programmes embedded into hardware, to having a machine which behaves completely differently every time a different program is loaded in.
### 5.1.2 The von Neumann Architecture
The von Neumann machine (theorised by my favourite scientist) is a practical model of a computer that informs the construction of almost all computer platforms today. Shown below is a generic von Neumann computer architecture:
![[Screenshot 2023-08-11 at 11.33.47.png|500]]
The CPU interacts with a memory device, receiving data from some input device, and emitting data to some output device. As shown in the memory the architecture realises the stored program concept: both instructions and data are stored together.
### 5.1.3 Memory
Both data and instructions are stored in fixed-size registers as sequences of bits. As shown previously, all memory registers are handled the same way: to access a memory register, simply supply the address. The term Random Access Memory derives from the requirement that a randomly selected register can be reached within the same cycle, irrespective of the registers location. 
In some variants of the VN architecture, the data memory and the instruction memory are allocated and managed dynamically within the same physical address space. In other variants, they are stored in two physically separate memory units. The advantages of having two separate units is that they allow for instructions and data to be fetched in parallel, however need two sets of addressing circuits. There are many tradeoffs for each method.

Data memory: At the end of the day all high level operations regarding data (manipulating arrays/objects etc.), after translation to machine language is simply reading and writing to memory registers.

Instruction memory: When a high-level program is loaded onto the target computer, it must first be translated into machine language. each statement is translated into one or more low-level instructions, which are then written as binary value to a file called the binary. Before running the program, you must first load the binary version from a storage device, and serialise the instructions into the computer's instruction memory.

### 5.1.4 Central Processing Unit
The CPU has the especially important job of executing the instructions of the currently running program. The CPU executes these instructions using three main elements: An ALU, a set of registers, and a control unit. As I have already extensively covered the ALU I will not mention it here.

Registers: When performing computations, the CPU frequently needs to store interim values. This could be done by using the external memory registers, however it would lead to starvation of the CPU, in which the CPU has done all the things it needs to and is idle waiting for an interim value. This would make the CPU much much slower, so we equip the CPU with its own registers (much quicker to access). There are many uses for these registers, typically:
- Program counter (PC) - holds the memory address of the next instruction to be fetched from main memory.
- Memory address register (MAR) - holds the address of the current instruction that is to be fetched from memory, or the address in memory to which data is to be transferred.
- Memory data register (MDR) - holds the contents found at the address held in the MAR, or data which is to be transferred to main memory.
- Current instruction register (CIR) - holds the instruction that is currently being decoded and executed.
- Accumulator (ACC) - holds the data being processed and the results of processing.

Control Unit: A control unit decodes instruction into micro-codes, which are then routed to the hardware device needed, e.g. memory, logic unit, and tells them how to respond to the program's instructions.

### 5.1.5 Input and output
An essential part of handling I/O is _standards_. One can imagine that if every single keyboard in the world had a different way of representing the binary representation of the letter 'K', we would have the biggest headache in the world of getting the Hack computer to take in keyboard input correctly. Another problem that would arise is the wide array of I/O devices, all of which have their own engineering complexity. The clever solution that is used in the present day is to make all I/O devices look exactly the same to the computer. The key element in this abstraction is mapping the I/O device to a regular linear binary segment. This memory map is then used to continuously reflect the state of the physical device. This makes detecting the key 'K' being pressed as simple as looking up a single bit (or writing to a pixel on screen).

## 5.2 The Hack Hardware Platform: Specification
All that is true of pretty much any general-purpose computer system. Next I will focus on specifically the Hack computer.
### 5.2.1 Overview
The Hack platform is a 16-bit von Neumann machine which consists of a CPU, two memory modules serving as instruction memory and data memory, and two memory-mapped I/O devices: a screen and a keyboard. The CPU consists of the ALU and three registers named Data register, Address register, and Program Counter, all previously built. 
### 5.2.2 Central Processing Unit
The Hack CPU is designed to execute two types of instructions, in the case of an A-instruction (looks like @xxx in machine language) the 16 bits of the instruction are treated as a binary value and are loaded into the A register. In case of a C-instruction, things become more complicated as the instruction is treated as a capsule of control bits the specify various micro-operations.
The CPU consists of an ALU, only two registers named A and D (as shown in the machine language), and a program counter. The CPU is also connected to an instruction memory (the ROM), and a data memory (referenced using the letter M in machine language).
![[Screenshot 2023-09-03 at 13.40.43.png]]
The pc output will feed into the address input of the instruction memory chip, causing the ROM to emit the next instruction into the CPU.
### 5.2.3 Instruction Memory
![[Screenshot 2023-09-03 at 13.48.49.png|500]]
Thankfully the ROM is pretty easy to describe (15 bit address because there are roughly 32K addressable registers, 16 bit output as that is the size of all instructions in the machine language).
### 5.2.4 Input/Output
As previously described, access to input/output devices of the computer is made possible the RAM device. The two devices that will be able to interface with the Hack computer is a keyboard and a screen. I will be using two built in chips for these devices, as I am not interested in the peripheral refresh logic I would need to dive into to make these two devices reflect there current state at any moment in times. The chips will appear as standard memory devices, with the memory maps of the devices updated continuously through logic external to the computer. Below I layout the specifics of each chip:
![[Screenshot 2023-09-03 at 14.06.35.png]]
![[Screenshot 2023-09-03 at 14.08.54.png]]
### 5.2.5 Data Memory
The overall addressable space of the computer is realised by a chip named Memory. It will essentially be just a combination of three 16 bit chips: RAM16K, Screen, and Keyboard:
![[Screenshot 2023-09-03 at 14.11.48.png]]
The challenge of implementation is making the machine language programs see this chip as a single addressable space, e.g. if the address input is 16385 the implementation should access address 1 in the Screen chip.
### 5.2.6 Computer
At this point it seems a little silly to call this a chip, because it contains an entire computer :0, however I will implement it in the same way nonetheless. Once the Computer chip is connected to a screen and a keyboard the user will see a single bit input named reset. When this bit is set to 1 and then 0, the computer starts executing the currently loaded program. This is the Hack equivalent of booting up.

## 5.3 Implementation
Memory:
```HDL
/**
 * The complete address space of the Hack computer's memory,
 * including RAM and memory-mapped I/O. 
 * The chip facilitates read and write operations, as follows:
 *     Read:  out(t) = Memory[address(t)](t)
 *     Write: if load(t-1) then Memory[address(t-1)](t) = in(t-1)
 * In words: the chip always outputs the value stored at the memory 
 * location specified by address. If load==1, the in value is loaded 
 * into the memory location specified by address. This value becomes 
 * available through the out output from the next time step onward.
 * Address space rules:
 * Only the upper 16K+8K+1 words of the Memory chip are used. 
 * Access to address>0x6000 is invalid. Access to any address in 
 * the range 0x4000-0x5FFF results in accessing the screen memory 
 * map. Access to address 0x6000 results in accessing the keyboard 
 * memory map.
 */

CHIP Memory {
    IN in[16], load, address[15];
    OUT out[16];

    PARTS:
    // Put your code here:
    DMux4Way(in=load, sel=address[13..14], a=rama, b=ramb, c=screenload, d=kbd); 
    Or(a=rama, b=ramb, out=ramload);

    RAM16K(in=in,load=ramload, address=address[0..13], out=ramout);

    // Normalise address for screen
    Screen(in=in, load=screenload, address=address[0..12], out=screenout);
    Keyboard(out=keyout);
    
    Mux16(a=screenout, b=keyout, sel=address[13], out=mux1);
    Mux16(a=ramout, b=mux1, sel=address[14], out=out);
}
```
I went through lots of different iterations of this, and the experience made it very clear to me that if I am arriving at a very complex inelegant solution... there's probably a better one. 
CPU:
```HDL
/**
 * The Hack CPU (Central Processing unit), consisting of an ALU,
 * two registers named A and D, and a program counter named PC.
 * The CPU is designed to fetch and execute instructions written in 
 * the Hack machine language. In particular, functions as follows:
 * Executes the inputted instruction according to the Hack machine 
 * language specification. The D and A in the language specification
 * refer to CPU-resident registers, while M refers to the external
 * memory location addressed by A, i.e. to Memory[A]. The inM input 
 * holds the value of this location. If the current instruction needs 
 * to write a value to M, the value is placed in outM, the address 
 * of the target location is placed in the addressM output, and the 
 * writeM control bit is asserted. (When writeM==0, any value may 
 * appear in outM). The outM and writeM outputs are combinational: 
 * they are affected instantaneously by the execution of the current 
 * instruction. The addressM and pc outputs are clocked: although they 
 * are affected by the execution of the current instruction, they commit 
 * to their new values only in the next time step. If reset==1 then the 
 * CPU jumps to address 0 (i.e. pc is set to 0 in next time step) rather 
 * than to the address resulting from executing the current instruction. 
 */

CHIP CPU {

    IN  inM[16],         // M value input  (M = contents of RAM[A])
        instruction[16], // Instruction for execution
        reset;           // Signals whether to re-start the current
                         // program (reset==1) or continue executing
                         // the current program (reset==0).

    OUT outM[16],        // M value output
        writeM,          // Write to M? 
        addressM[15],    // Address in data memory (of M)
        pc[15];          // address of next instruction

    PARTS:
    
    Mux16(a=instruction, b=aluout, sel=instruction[15], out=fmuxout);
    // Always load into A if first bit = 0
    Not(in=instruction[15], out=notinsonefive);
    Or(a=instruction[5], b=notinsonefive, out=aregload);
    ARegister(in=fmuxout, load=aregload, out=aout, out[0..14]=addressM);
    Mux16(a=aout, b=inM, sel=instruction[12], out=smuxout);   

    And(a=instruction[15], b=instruction[4], out=loadd);
    DRegister(in=aluout, load=loadd, out=dout);
    ALU(x=dout, y=smuxout, zx=instruction[11], nx=instruction[10], zy=instruction[9] ,ny=instruction[8] ,f=instruction[7], no=instruction[6], out=aluout, out=outM ,zr=zr ,ng=ng);

    // Program counter logic
        // Validity check
        And(a=instruction[2], b=ng, out=j3t);
        And(a=instruction[1], b=zr, out=j2t);

        // Is number positive
        Or(a=zr, b=ng, out=j1ttt);
        Not(in=j1ttt, out=j1tt);
        And(a=instruction[0], b=j1tt, out=j1t); 
        
        Or(a=j3t, b=j2t, out=orvt);
        Or(a=j1t, b=orvt, out=validout);

        // Unconditional jump?
        And(a=instruction[0], b=instruction[1], out=tjout);
        And(a=instruction[2], b=tjout, out=jout);    
        
        Or(a=jout, b=validout, out=pcjump);
        And(a=pcjump, b=instruction[15], out=pcload);
    
    Not(in=pcload, out=incpc);
    PC(in=aout, load=pcload ,inc=incpc ,reset=reset, out[0..14]=pc); 
    //

    // Output writeM bit
    And(a=instruction[15], b=instruction[3], out=writeM);
}
```
Another tricky one. Finding the solution to the program counter logic took me a not insignificant amount of time haha. And finally...
Computer:
```HDL
/**
 * The HACK computer, including CPU, ROM and RAM.
 * When reset is 0, the program stored in the computer's ROM executes.
 * When reset is 1, the execution of the program restarts. 
 * Thus, to start a program's execution, reset must be pushed "up" (1)
 * and "down" (0). From this point onward the user is at the mercy of 
 * the software. In particular, depending on the program's code, the 
 * screen may show some output and the user may be able to interact 
 * with the computer via the keyboard.
 */

CHIP Computer {
    IN reset;

    PARTS:
    ROM32K(address=pcout, out=romout);
    CPU(inM=memoryout, instruction=romout, reset=reset, outM=cpuoutm, writeM=cpuwritem, addressM=cpuaddressm, pc=pcout);
    Memory(in=cpuoutm , load=cpuwritem, address=cpuaddressm, out=memoryout);
}
```
A much easier one!
## 5.4 Perspective
I have now built a general-purpose computer system from first principles. How cool!