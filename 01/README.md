[[Nand2Tetris]]
tags:: #SE_11 #LLL  
dates:: 2023-06-08 
relevant:: 

--- 
# Nand2Tetris Chapter 1

The implementation of a process is the "how", the abstraction is the "what".

> Any real-world computation can be translated into an equivalent computation involving a Turing machine.

At the bottom, all computers are essentially equivalent.
Abstraction is essential to this course. All projects are built upon the previous projects shoulders, and no knowledge of how it works is necessary. This is a VERY important concept in computer science for all sorts of reasons. A simplistic one is to imagine how a team of engineers will work on a big system together, without trodding on each others toes.

## 1.1
A Boolean function is one that operates on binary inputs and returns binary outputs. The basic boolean operators are defined here:
[[Propositional logic]]
A Nand gate (not-and) will equal true always, except from when both input values are true (1,1,1,0 in a conventional truth table). Supposedly ANY boolean operator can be expressed using Nand gates. 
We have a set of laws that allow us to simplify Boolean functions, for example De Morgan's laws: 
Not(x And y) = Not(x) or Not(y)
Not(x Or y) = Not(x) and Not(y)
The reason why this is important is that the left side of the equation is completely equivalent to the right side, however the left side requires 2 logic gates, but the right side requires 3. This means that for the same functionality you are getting 1/3 less power consumption! Interestingly reducing a Boolean expression into its simplest form is an NP-Hard problem. 
Go through this if you have forgotten what that means: [[Complexity classes]].

Given a truth table of a Boolean function how can we construct a boolean expression?
![[Screenshot 2023-06-09 at 12.31.11.png||355]]
I believe the process is pretty clear here from the table, and shows that it is always possible to create a boolean expression from a truth table. It is the disjunction (Or-ing) of all the conjunctive (And-ing) whose construction was just described. This is a bit like the boolean version of the sum of products, and is referred to as the functions Disjunctive Normal Form (DNF).

To prove that any boolean expression can consist of only Nand gates the proof goes like this:
1. Any Boolean function can be represented by a Boolean expression containing only And, Or and Not operators. 
	Proof: Any truth table can by used for synthesising a DNF, which is only the disjunction and conjunction of variables and their negations. 
2. Any Boolean function can be represented by a Boolean expression containing only Not and And operators. 
	Proof: According to De Morgan law, the Or operator can be expressed using the Not and And operators. Combining this with the the previous proof, this conjecture is also proven.
3. Any Boolean function can be represented by a Boolean expression containing only Nand operators.
	Proof: Not(x) = Nand(x,x). If you set the input to the Nand gate with two of the same variable, the Nand gate simply equals the negation of the variable. Then of course And(x,y) = Not(Nand(x,y)). Combined with the other two proofs then we can definitively say that all Boolean functions can be represented by a Boolean expression containing only Nand gates.

## 1.2 Logic Gates
A gate is a physical device that implements a simple Boolean function. Gates are typically implemented as transistors etched in silicon, packed as chips, however as comp sci students we can be blissfully unaware of this and treat them as black boxes. 
Composite gates are when two gates are combined together, e.g. a three way and gate is simply two and gates with ones output feeding into another's.
![[Screenshot 2023-06-09 at 14.40.54.png]]
As you can see a Xor is either (¬a ^ b) or (¬b^a). 
The fundamental requirement of logic design is that "the gate implementation will realise its stated interface". So regardless of what the implementation looks like inside, the out must equal the truth table (interface).

## 1.3 Hardware Construction (HDL)
Hardware designers design chip architecture using a formalism called Hardware Description Language. The chip is then virtually subjected to tests using a hardware simulator which takes the HDL program and creates a software representation of the chip logic. In addition to correctness the hardware designer will also look at speed of computation, energy consumption, and overall cost.
The HDL used in Nand2Tetris is a lighter version of the industrial style.

## 1.4 Specification
1.4 goes over the interfaces of the basic logic gates. I will write here the only ones I was unaware of:
- Multiplexer: Three-input gate, taking in two input bits, a and b, and a selection bit (sel). Dependent on this selector bit either a or b is outputted. Gate name often abbreviated to Mux.
- Demultiplexer: Performs the opposite function of a multiplexer, takes in one input bit and routes it to one of two values, a and b, dependent on the selection bit. The output bit not routed to is set to 0.

At some point computer hardware often needs to process multi-bit values, for example is 16 == 15 cannot be done with a standard And gate. Manipulating a sequence of bits as a single entity is called a "bus" 
The logical architecture of n-bit gates are all the the same, irrespective of n's value (e.g. 16,32,64 bits). HDL treats n-bit gates in a similar manner to arrays, indexing them from left to right (zero based of course). For example if in and out represent two 16-bit values, then out\[4] = in\[5] sets the 4th bit of out to the value of the 5th bit of in.
- Multi-bit Not: An n-bit Not gate applies the boolean operation Not to each bit in the n-bit input.
```API Style
Chip name: Not16
Input: in[16]
Output: out[16]
Function: for i = 0..15 out[i] = Not(in[i])
```
- Multi-bit And: An n-bit And gate applies the boolean operation And to each respective pair of bits in the two n-bit inputs.
```API Style
Chip name: And16
Input: a[16], b[16]
Output: out[16]
Function: for i = 0..15 out[i] = And(a[i], b[i])
```
- Multi-bit Or: An n-bit Or gate applies the boolean operation Or to each respective pair of bits in the two n-bit inputs.
```API Style
Chip name: Not16
Input: in[16]
Output: out[16]
Function: for i = 0..15 out[i] = Or(in[i])
```
- Multi-bit Multiplexer: Works the exact same way you would expect apart from a, b and out will all be n-bits wide.

It is also necessary to be aware of the multi-way versions of basic gates, as we will frequently need to operate on more than two inputs.
- Multi-way Or: An m-way Or gate outputs 1 when at least one of its m input bits is 1, and 0 otherwise. An 8-way variant of this gate:
```API Style
Chip name: Or8Way
Input: in[8]
Output: out
Function: out = Or(in[0], in[1], ..., in[7])
```
- Multi-way/Multi-bit multiplexer: An m-way n-bit multiplexer selects one of its m n-bit inputs, and outputs it to its n-bit output. The selection is specified by a set of k selection bits, where $k = \log_2{m}$ (because there must be enough combination of bits to have the possibility for each in to be selected). 
![[Screenshot 2023-06-11 at 12.38.45.png|400]]
In the project I will need a 4-way 16-bit multiplexer and an 8-way 16-bit multiplexer, but the principles are the same: 
```API Style
Chip name: Mux4Way16
Input: a[16],b[16],c[16],d[16], sel[2]
Output: out[16]
Function: if(sel == 00,01,10,11) then out = a,b,c,d (respectively)
Comment: This assignment is a 16-bit operation. For example, "out = a" means "for i = 0..15 out[i] = a[i]".
```
- Multi-way/Multi-bit demultiplexer: An m-way n-bit demultiplexer routes its single n-bit input to one of its m n-bit outputs. The other outputs are set to 0. The selection is again specified by a set of k selection bits, where $k = \log_2{m}$.
![[Screenshot 2023-06-11 at 12.48.48.png|400]]
Target computer will need a 4-way 1-bit demultiplexer and an 8-way 1-bit demultiplexer: 
```API Style
Chip name: DMux4Way
Input: in,sel[2]
Output: a,b,c,d
Function: 
	if(sel == 00) then {a,b,c,d} = {1,0,0,0},
	else if(sel == 01) then {a,b,c,d} = {0,1,0,0},
	else if(sel == 10) then {a,b,c,d} = {0,0,1,0},
	else if(sel == 11) then {a,b,c,d} = {0,0,0,1}
```

## 1.5 Implementation
Having described the interfaces of the basic logic gates (what), we now need to learn the how. The two general approaches I will look at are behavioural simulation and hardware implementation.
### Behavioural simulation
So far everything is described in an abstract manner but it would be nice to experiment with these abstractions before building them in HDL. To do this we can use conventional programming. This is generally pretty simple, using an OOP language create a set of classes for each generic chip, then write eval methods for the logic, allow the classes to interact with each other so that high-level chips can be defined in terms of lower ones. Then if you want you can make a GUI to allow putting different vals in the chip inputs, and observe the outputs. This enables experimenting with chip interfaces before the much longer process of building them in HDL. Inexpensive and quick :) 

### Hardware implementation
For each gate I will first implement it in HDL, and then will use a .tst that tells the hardware simulator how to test the gate, along with an .cmp compare file that lists the correct output that the supplied test is expected to generate.

### Elementary logic gates
Not:
```HDL
/**
 * Not gate:
 * out = not in
 */

CHIP Not {
    IN in;
    OUT out;

    PARTS:
    Nand(a=in, b=in, out=out);
}
```
And:
```HDL
/**
 * And gate: 
 * out = 1 if (a == 1 and b == 1)
 *       0 otherwise
 */

CHIP And {
    IN a, b;
    OUT out;

    PARTS:
    Nand(a=a, b=b, out=nandout);
    Not(in=nandout, out=out);
}
```
Or:
```HDL
 /**
 * Or gate:
 * out = 1 if (a == 1 or b == 1)
 *       0 otherwise
 * Demorgan law: 
 * Not(a Or b) = Not(a) and Not(b)
 */

CHIP Or {
    IN a, b;
    OUT out;

    PARTS:
    Not(in=a, out=nota);
    Not(in=b, out=notb);
    And(a=nota, b=notb, out=notor);
    Not(in=notor, out=out);
}
```
Xor:
```HDL
/**
 * Exclusive-or gate:
 * out = not (a == b)
 */

CHIP Xor {
    IN a, b;
    OUT out;

    PARTS:
    Not(in=a, out=nota);
    And(a=nota, b=b, out=notaandb);
    Not(in=b, out=notb);
    And(a=a, b=notb, out=aandnotb);
    Or(a=notaandb, b=aandnotb, out=out);
}
```
Mux:
```HDL
/** 
 * Multiplexor:
 * out = a if sel == 0
 *       b otherwise
 */

CHIP Mux {
    IN a, b, sel;
    OUT out;

    PARTS:
    Not(in=sel, out=notsel);
    And(a=a, b=notsel, out=aandnotsel);
    And(a=sel, b=b, out=bandsel);
    Or(a=aandnotsel, b=bandsel, out=out);
}
```
DMux:
```HDL
/**
 * Demultiplexor:
 * {a, b} = {in, 0} if sel == 0
 *          {0, in} if sel == 1
 */

CHIP DMux {
    IN in, sel;
    OUT a, b;

    PARTS:
    Not(in=sel, out=notsel);
    And(a=in, b=notsel, out=a);
    And(a=in, b=sel, out=b); 
}

```

### 16-bit variants
Not16:
```HDL
/**
 * 16-bit Not:
 * for i=0..15: out[i] = not in[i]
 */

CHIP Not16 {
    IN in[16];
    OUT out[16];

    PARTS:
	Not(in=in[0], out=out[0]);
	Not(in=in[1], out=out[1]);
	Not(in=in[2], out=out[2]);
	Not(in=in[3], out=out[3]);
	Not(in=in[4], out=out[4]);
	Not(in=in[5], out=out[5]);
	Not(in=in[6], out=out[6]);
	Not(in=in[7], out=out[7]);
	Not(in=in[8], out=out[8]);
	Not(in=in[9], out=out[9]);
	Not(in=in[10], out=out[10]);
	Not(in=in[11], out=out[11]);
	Not(in=in[12], out=out[12]);
	Not(in=in[13], out=out[13]);
	Not(in=in[14], out=out[14]);
	Not(in=in[15], out=out[15]);
}
```
And16:
```HDL
/**
 * 16-bit bitwise And:
 * for i = 0..15: out[i] = (a[i] and b[i])
 */

CHIP And16 {
    IN a[16], b[16];
    OUT out[16];

    PARTS:
    And(a=a[0], b=b[0], out=out[0]);
    And(a=a[1],b=b[1], out=out[1]);
    And(a=a[2],b=b[2], out=out[2]);
    And(a=a[3],b=b[3], out=out[3]);
    And(a=a[4],b=b[4], out=out[4]);
    And(a=a[5],b=b[5], out=out[5]);
    And(a=a[6],b=b[6], out=out[6]);
    And(a=a[7],b=b[7], out=out[7]);
    And(a=a[8],b=b[8], out=out[8]);
    And(a=a[9],b=b[9], out=out[9]);
    And(a=a[10],b=b[10], out=out[10]);
    And(a=a[11],b=b[11], out=out[11]);
    And(a=a[12],b=b[12], out=out[12]);
    And(a=a[13],b=b[13], out=out[13]);
    And(a=a[14],b=b[14], out=out[14]);
    And(a=a[15],b=b[15], out=out[15]);
}
```
Or16:
```HDL
/**
 * 16-bit bitwise Or:
 * for i = 0..15 out[i] = (a[i] or b[i])
 */

CHIP Or16 {
    IN a[16], b[16];
    OUT out[16];

    PARTS:
    Or(a=a[0], b=b[0], out=out[0]);
    Or(a=a[1],b=b[1], out=out[1]);
    Or(a=a[2],b=b[2], out=out[2]);
    Or(a=a[3],b=b[3], out=out[3]);
    Or(a=a[4],b=b[4], out=out[4]);
    Or(a=a[5],b=b[5], out=out[5]);
    Or(a=a[6],b=b[6], out=out[6]);
    Or(a=a[7],b=b[7], out=out[7]);
    Or(a=a[8],b=b[8], out=out[8]);
    Or(a=a[9],b=b[9], out=out[9]);
    Or(a=a[10],b=b[10], out=out[10]);
    Or(a=a[11],b=b[11], out=out[11]);
    Or(a=a[12],b=b[12], out=out[12]);
    Or(a=a[13],b=b[13], out=out[13]);
    Or(a=a[14],b=b[14], out=out[14]);
    Or(a=a[15],b=b[15], out=out[15]);
}
```
Mux16:
```HDL
/**
 * 16-bit multiplexor: 
 * for i = 0..15 out[i] = a[i] if sel == 0 
 *                        b[i] if sel == 1
 */

CHIP Mux16 {
    IN a[16], b[16], sel;
    OUT out[16];

    PARTS:
    Mux(a=a[0], b=b[0], sel=sel, out=out[0]);
    Mux(a=a[1],b=b[1], sel=sel, out=out[1]);
    Mux(a=a[2],b=b[2], sel=sel, out=out[2]);
    Mux(a=a[3],b=b[3], sel=sel, out=out[3]);
    Mux(a=a[4],b=b[4], sel=sel, out=out[4]);
    Mux(a=a[5],b=b[5], sel=sel, out=out[5]);
    Mux(a=a[6],b=b[6], sel=sel, out=out[6]);
    Mux(a=a[7],b=b[7], sel=sel, out=out[7]);
    Mux(a=a[8],b=b[8], sel=sel, out=out[8]);
    Mux(a=a[9],b=b[9], sel=sel, out=out[9]);
    Mux(a=a[10],b=b[10], sel=sel, out=out[10]);
    Mux(a=a[11],b=b[11], sel=sel, out=out[11]);
    Mux(a=a[12],b=b[12], sel=sel, out=out[12]);
    Mux(a=a[13],b=b[13], sel=sel, out=out[13]);
    Mux(a=a[14],b=b[14], sel=sel, out=out[14]);
    Mux(a=a[15],b=b[15], sel=sel, out=out[15]);
}
```

### Multi-way variants
Or8Way:
```HDL
/**
 * 8-way Or: 
 * out = (in[0] or in[1] or ... or in[7])
 */

CHIP Or8Way {
    IN in[8];
    OUT out;

    PARTS:
    Or(a=in[0], b=in[1], out=out1);
    Or(a=in[2], b=out1, out=out2);
    Or(a=in[3], b=out2, out=out3);
    Or(a=in[4], b=out3, out=out4);
    Or(a=in[5], b=out4, out=out5);
    Or(a=in[6], b=out5, out=out6);
    Or(a=in[7], b=out6, out=out);
}
```
Mux4Way16:
```HDL
/**
 * 4-way 16-bit multiplexor:
 * out = a if sel == 00
 *       b if sel == 01
 *       c if sel == 10
 *       d if sel == 11
 */

CHIP Mux4Way16 {
    IN a[16], b[16], c[16], d[16], sel[2];
    OUT out[16];

    PARTS:
    Mux16(a=a, b=b, sel=sel[0], out=Mux1);
    Mux16(a=c, b=d, sel=sel[0], out=Mux2);
    Mux16(a=Mux1, b=Mux2, sel=sel[1], out=out);
}
```
Mux8Way16:
```HDL
/**
 * 8-way 16-bit multiplexor:
 * out = a if sel == 000
 *       b if sel == 001
 *       etc.
 *       h if sel == 111
 */

CHIP Mux8Way16 {
    IN a[16], b[16], c[16], d[16],
       e[16], f[16], g[16], h[16],
       sel[3];
    OUT out[16];

    PARTS:
    Mux4Way16(a=a, b=b, c=c, d=d, sel=sel[0..1], out=Mux4way1);
    Mux4Way16(a=e, b=f, c=g, d=h, sel=sel[0..1], out=Mux4way2);
    Mux16(a=Mux4way1, b=Mux4way2, sel=sel[2], out=out);
}
```
DMux4Way:
```HDL
/**
 * 4-way demultiplexor:
 * {a, b, c, d} = {in, 0, 0, 0} if sel == 00
 *                {0, in, 0, 0} if sel == 01
 *                {0, 0, in, 0} if sel == 10
 *                {0, 0, 0, in} if sel == 11
 */

CHIP DMux4Way {
    IN in, sel[2];
    OUT a, b, c, d;

    PARTS:
    DMux(in=in, sel=sel[0], a=a1, b=b1); 
    DMux(in=a1, sel=sel[1], a=a, b=c);
    DMux(in=b1, sel=sel[1], a=b, b=d);
}
```
DMux8Way:
```HDL
/**
 * 8-way demultiplexor:
 * {a, b, c, d, e, f, g, h} = {in, 0, 0, 0, 0, 0, 0, 0} if sel == 000
 *                            {0, in, 0, 0, 0, 0, 0, 0} if sel == 001
 *                            etc.
 *                            {0, 0, 0, 0, 0, 0, 0, in} if sel == 111
 */

CHIP DMux8Way {
    IN in, sel[3];
    OUT a, b, c, d, e, f, g, h;

    PARTS:
    DMux(in=in, sel=sel[0], a=a1, b=b1); 
    DMux4Way(in=a1, sel=sel[1..2], a=a, b=c, c=e, d=g);
    DMux4Way(in=b1, sel=sel[1..2], a=b, b=d, c=f, d=h);
}
```

## Things not taken into consideration
I have paid no attention to efficiency and cost considerations throughout these designs, for example wire crossovers and energy consumption. Physically there are many different things that would need to be taken into account, for example which switching technology would be used, each having its own speed/cost/energy etc. If I was to look at any of these I would be veering into solid-state physics and electrical engineering which is not my current focus (maybe some time in the future :D).