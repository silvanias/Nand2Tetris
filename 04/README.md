[[Nand2Tetris]]
tags:: #SE_11 #LLL  
dates:: 2023-07-23 
relevant:: 

--- 
# Nand2Tetris Chapter 4
This chapter will be dedicated to familiarising myself with the machine language that this virtual computer will eventually realise. As a short refresh, machine language is the binary codes that the computer understand and execute directly and can be written in two equivalent ways: binary and symbolic.
Using machine language you can instruct the processor to complete arithmetic and logical operations, read and write values from memory, evaluate expressions, and decide which instruction to fetch and execute next. As opposed to high-level languages, machine languages are designed for complete control over a specific hardware platform.

## 4.1 Machine Language: Overview
As is the consistent theme throughout this project, abstraction is utilised here as I don't really care about the hardware in this chapter, and so I will look at the minimal subset of hardware elements that are explicitly needed in the machine language instructions.

### 4.1.1 Hardware Elements
A machine language can be viewed as an agreed-upon formalism designed to manipulate _memory_ using a _processor_ and a set of _registers_.
Memory in this context is a collection of hardware devices that store data and instructions, whereas registers are specifically located inside the processor's chip as high-speed local memory. This is done to increase the speed when manipulating instructions and data inside the CPU (not having to access memory far away).
The CPU registers are of two types: _data registers_ (for holding data values), and _address registers_, designed to hold values that can be interpreted either as data values or as memory addresses. The architecture of this computer is configured such that placing a value in an address register causes the memory location whose address is that value to become selected. This is obviously essential for many different actions.

### 4.1.2 Languages
An example piece of machine language looks like this:
![[Pasted image 20230730121741.png]]
This can clearly become quite error prone (imagine missing a 1 somewhere :cries:).
Assuming the addition operator uses the 6-bit code 101011 and registers R1 and R2 use the codes 00001 and 00010, then we can chain these together to get the 16-bit instruction 1010110000100010, the binary equivalent of "Set R1 to the value of R1+R2".
In chapter 6 I will deal with converting this mess of binary into an _assembly language_ which will take the instruction R1+R2 and convert it into binary, with the knowledge of what each symbols binary equivalent is. The program that translate these instructions is called an _assembler_.
As mentioned previously these languages discussed are specific to the CPU it aims to control, thus there are many many different machine languages with all different syntaxes. However, all machine/assembly languages are theoretically equivalent as they all support the same similar sets of generic tasks.

### 4.1.3 Instructions
In the following layout of the assembly language instructions i'm assuming that the computer's processor has a set of registers R0, R1, R2.. without worrying about type and amount.

Arithmetic and logical operations: I of course need access to basic logical and arithmetic operations in the symbolic instructions, such as addition/And. An example:
![[Screenshot 2023-07-30 at 12.44.58.png|300]]
For this program to actually execute on the computer I need a piece of software i've not actually made yet, but i'll assume I have access to an assembler for now.
Memory access: Again an essential part, as mentioned previously this will be done using an address register.
Flow control: The natural sequence of a program is to run one instruction, then moving to the next instruction and so on, however to do more complex things (like multiplication ;) we will also need the ability to "jump" to a location other than the next instruction. There can be a variety of different conditions (BRZ/BRP for example) and ways (symbolic/physical) to do this. Shown below are two examples that perform the exact same logic:
![[Screenshot 2023-07-30 at 13.38.22.png|400]]
The version using symbolic addresses is the one I will use 99% of the time as it tends to be much easier to write and debug. Another example is that it is relocatable, as the code can be split into chunks and moved elsewhere without worrying about whether an address of an instruction has changed at any point.

## 4.2 The Hack Machine Language
I will first give a conceptual description of the computer I am building, and then show an example complete program.

### 4.2.1 Background
The design of the Hack computer follows an architecture invented by my favourite computer scientist: The von Neumann architecture. This means instruction data and program data are stored in the same memory. 

Memory: The hack platform uses two distinct memory units: a _data memory_ (RAM) and an _instruction memory_ (ROM). Both memories are 16-bit wide, and each has a 15-bit address space. Therefore the maximum addressable size of each memory is 32K 16-bit words.
The data memory is a read/write device, meaning instructions can read data from and write data to selected RAM registers. As there is always an value in the memory's address input, there is always a selected register, referred to as M in Hack instructions.
The instruction memory is a read-only device, with programs only loaded into it using some external method. As with RAM there is always a value in the input and so there is always a _current instruction._

Registers: Hack instructions can manipulate three 16-bit registers: a _data register_ D, an _address register_ A, and a selected data memory register M. The data register simply stores a 16-bit value, meanwhile the address register A can also serve as a data register. If you want to store the value 12 in the A register you must use the instruction @12. This will seem a little weird but I will explain it later: If you wish to set the D register to 17, use the instruction @17 followed by D=A. 

Addressing: The Hack instruction @ xxx sets the A register to the value xxx. Additionally the RAM register who address is xxx becomes the selected memory register M. Thirdly, the value of the ROM register whose address is xxx becomes the selected instruction. This is crucial as it allows us to do two very different actions, either manipulating the data memory register, or doing something with the selected instruction. 
As a short example lets set the value of RAM\[100] to 17: 
- @17
- D=A
- @100
- M=D
In the first pair of instructions, A serves as a data register; in the second as an address register. This is all done for simplicity in the long run to create a more elegant computer architecture.

Branching: In the Hack language branching is done by loading the address of an instruction (@xxx) then followed by the Hack instruction 0;JMP. This instruction realises the Hack version of _unconditional branching_.
There is also _conditional branching_, the logic if D\==0 goto xxx is done by loading the potential instruction (@xxx) then followed by the instruction D;JEQ, there are actually several different conditional branching commands which i'll cover later.

Variables: The hack instruction set also allows me to use variables, for example @y where y is a symbol bound to a value. When running this code, the assembler (which I haven't built yet) will bind the symbols I use in a program to consistent addresses in the data memory. In addition to variables defined by the programmer the Hack language also has sixteen built-in symbols named R0, R1, ..., R15 which are bound to their respective numbers (like a const).

### 4.2.2 The Hack Language Specification
In general the Hack language supports two instructions, instructions that start with an @ called address instructions/A-instructions and a compute instruction, which is simply all other instructions. Their general implementations in both symbolic and binary formats are shown below:
![[Screenshot 2023-08-02 at 17.43.30.png|500]]
The Hack ALU will take in its first input from the D register, and its second input will either be from the A register (when the a-bit is 0) or from M (when the a-bit is 1). At the risk of repeating myself it is obvious here that I do not have all 128 different instructions possible here, and that is to make my life as easy as possible (and so that I can implement some cool stuff later ;)). Another important feature is that the ALU output can be stored in zero, one, two or three possible destinations, simultaneously. In the case of the final jump bits being all set to zero, then the next instruction in the program will be fetched and executed (Per convention I will use 0;JMP to specify this, of which zero is an arbitrary choice that has no consequence).

### 4.2.3 Input/Output Handling
The Hack hardware platform can be connected to both a screen and a keyboard, with both devices interacting with the platform via _memory maps_. Drawing pixels on the screen is done by writing binary words into a designated memory segment, and listening to the keyboard is done by reading a designated xmemory location. The physical I/O devices and their maps are synchronised via continuous refresh loops external to the main hardware platform. 

## 4.3 Project
The given challenge for this chapter is to write and test two programs in assembly language. The two programs are:

Multiplication: The inputs for the program are the values stored in RAM\[0] and RAM\[1]. The program computes the product between these two values and stores the result in RAM\[2]. Assume that R0 ≥ 0, R1 ≥ 0, and R0 \* R1 < 32768.

I/O Handling: This program runs an infinite loop that listens to the keyboard. When a key is pressed, the program blackens the screen by writing black in every pixel. When no key is pressed, the program clears the screen by writing white in every pixel. The filling of the screen can be done in any spatial pattern as long as the screen _eventually_ will result in a fully blackened screen. I will be able to check this output by using a provided simulated screen in the CPU emulator I am using.

### 4.3.1 Multiplication
Before I show you my final result for the program i'd like to show a hilarious mistake I made:
```ASL
  @R0
  D=M
  @R1 
  D=D*M
  @R2
  M=D
(END)
  @END
  0;JMP
```
Notice anything wrong with it?
My mistake was trying to multiply the values of two memory locations together, when I do not have the ability to do so yet! Definitely made me laugh at myself.
Here is the actual program:
```ASL
  // initialising i
  @i
  M=1
  // for the case R1 = 0
  @R2
  M=0

(MULT)
  @i
  D=M
  @R1
  
  // i - @R1
  D=D-M
  
  // if i > @R1: jmp to END
  @END
  D;JGT

  // R0 = R2 + R0
  @R2
  D=M
  @R0
  D=D+M
  @R2
  M=D

  @i
  M=M+1
  @MULT
  0;JMP
(END)
  @END
  0;JMP
```
This program also demonstrates the recommended way of terminating specifically Hack programs, as entering an infinite loop prevents the CPU's fetch-execute logic trying to execute instructions which are not in the program (this can be very bad).

### 4.3.2 I/O Handling
This task really highlighted to me how impressive of a feat programming something like rollercoaster tycoon in assembly is. Debugging in this thing is an absolute NIGHTMARE! Anyhow here it is:
```ASL

(KEY_PRESS)
  @KBD
  D=M
  @KEY_PRESS
  D;JEQ

  @col
  M=0
  @row
  M=-1

(ROW)
  @col
  M=0
  @row
  M=M+1
  // if (row=256) goto HELD_KEY
  @row
  D=M
  @256
  D=D-A
  @HELD_KEY
  D;JEQ
  

// Times current row by 32
  @rowx32
  M=0

  @32
  D=A
  @noofwords
  M=D

  @i
  M=0

(MULT)
  @i
  D=M
  @noofwords
  
  // i - @noofwords
  D=D-M
  
  // if i > @noofwords: jmp to END
  @END
  D;JEQ

  // @row = @rowx32 + @row
  @rowx32
  D=M
  @row
  D=D+M
  @rowx32
  M=D

  @i
  M=M+1
  @MULT
  0;JMP
(END)


(COL)
  // if (col==32) goto ROW
  @col
  D=M
  @32
  D=D-A
  @ROW
  D;JEQ

  // The screen has a total of 256 rows of 32 16-bit words
  // Address of the 16 left-most pixels at the screen's top row:
  @SCREEN
  D=A  
  @rowx32
  D=D+M
  // Load count
  @col
  A=D+M
  // Set word to black
  M=-1

  // Update count
  @col
  M=M+1
  
  @COL
  0;JMP
  
  // Everything is drawn
(HELD_KEY)
  @KBD
  D=M
  @HELD_KEY
  D;JNE

  // If key not held, reverse everything
  @row
  M=-1
(WROW)
  @col
  M=0
  @row
  M=M+1
  // if (row=256) goto WEND
  @row
  D=M
  @256
  D=D-A
  @WEND
  D;JEQ
  

// Times current row by 32
  @rowx32
  M=0

  @32
  D=A
  @noofwords
  M=D

  @i
  M=0

(WMULT)
  @i
  D=M
  @noofwords
  
  // i - @noofwords
  D=D-M
  
  // if i > @noofwords: jmp to WMEND
  @WMEND
  D;JEQ

  // @row = @rowx32 + @row
  @rowx32
  D=M
  @row
  D=D+M
  @rowx32
  M=D

  @i
  M=M+1
  @WMULT
  0;JMP
(WMEND)

(WCOL)
  // if (col==32) goto WROW
  @col
  D=M
  @32
  D=D-A
  @WROW
  D;JEQ

  // Load base address
  @SCREEN
  D=A
  
  @rowx32
  D=D+M
  // Load count
  @col
  A=D+M
  M=0

  // Update count
  @col
  M=M+1
  
  @WCOL
  0;JMP

  // Making the screen white now done
(WEND)
  @KEY_PRESS
  0;JMP
```

## 4.4 Perspective
While programming in any assembly language is complex, this Hack assembly language is still quite basic. A typical machine language features more operations, more data types and more registers. The reason Hack is basic is mostly due to it being a 1/2 address machine language: As there is no room to pack both an instruction code and a 15-bit address into a 16-bit instructions, operations involving memory access require two Hack instructions. The first specifies the address we wish to operate on and the second specifies the operation. You can clearly see this by the above program generally being an alternating sequence of A then C instructions. 
A future consideration I can have when building my own assembler is whether I wish to continue with this style of language, or I simply make macro-instructions that are just two Hack instructions behind the scenes. This would make the whole language much easier to write in.