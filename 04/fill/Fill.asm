// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed. 
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.


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