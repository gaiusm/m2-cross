.T
Modula-2 running on bare metal on the Raspberry Pi-4
.B
here are some instructions and simple test programs which demostrate
Modula-2 running on the Raspberry Pi-4
.B
there are a number of steps required:
.C
install the tool chain, this will be a cross development tool
chain
.C
write the tiny test program
.C
deploy the binary to target
.bp
.T
Cross development tool chain
.B
references:
.C
.URL https://www.valvers.com/open-software/raspberry-pi/bare-metal-programming-in-c-part-1
.C
.URL https://gist.github.com/preshing/41d5c7248dea16238b60
.C
.URL https://wiki.osdev.org/Raspberry_Pi_Bare_Bones
.C
probably other websites were used as well, apologies if these are absent
.bp
.B
the following has been tested under Debian Buster building on an amd64 machine
.B-EXAMPLE-BEGIN
.CMD git clone
.CMD mkdir build-m2-cross
.CMD ../m2-cross/configure
.CMD make
.B-EXAMPLE-END
.B
this will build and install the gm2, gcc, g++ cross compilers into
.PRG $HOME/opt-gcc-12/cross/bin
(and
.PRG $HOME/opt-gcc-12/cross/{lib,share} )
.C
note currently this location is hardcoded
.bp
.T
The bare metal software
.B
there are four objects which will be linked to produce the baremetal
application
.C
.PRG armc-08-start.S
assembly language start up which assigns the stack and calls
.PRG armc-08-cstartup.c
.C
.PRG armc-08-cstartup.c
initialise the BSS to zero and calls
.PRG main
.C
\fIapplication\fP\fC\s[-1]_m2.c\s0\fP scaffold which calls each
dependant module constructor in turn and deconstructor when it
terminates
.C
\fIapplication\fP\fC\s[-1].mod\s0\fP the main program
.bp
.T
Main program: \fCledtest.mod\fP
.B-EXAMPLE-BEGIN
.ps -2
.vs -2
MODULE ledtest ;

(* Flash the onboard green LED of the RPI4 using Modula-2.
   The tiny onboard green LED is located next to the red power LED
   (also known as the ACT LED which flashes during bootup).
   Author:  Gaius Mulley   31/8/2021.  *)

FROM SYSTEM IMPORT ADDRESS ;

CONST
   GPIO_BASE    = 0FE200000H ;
   GPIO_MAX     = LED_GPCLR ;
   (* GPIO bitset offsets.  *)
   GPIO_GPFSEL  = 4 ;
   LED_GPSET1   = 8 ;
   LED_GPCLR1   = 11 ;
   (* BIT positions.  *)
   LED_GPFBIT   = 6 ;
   LED_GPIO_BIT = 10 ;
.B-EXAMPLE-END
.bp
.B-EXAMPLE-BEGIN
.ps -2
.vs -2

VAR
   gpio[GPIO_BASE] : ARRAY [0..GPIO_MAX] OF BITSET ;


PROCEDURE waste_time ;
CONST
   delay = 800000 ;
VAR
   i: CARDINAL ;
BEGIN
   FOR i := 0 TO delay DO
      ASM VOLATILE ("nop")
   END
END waste_time ;
.B-EXAMPLE-END
.bp
.B-EXAMPLE-BEGIN
.ps -2
.vs -2
BEGIN
   (* Set this bit to TRUE to enable the LED as an output.  *)
   INCL (gpio[GPIO_GPFSEL], LED_GPFBIT) ;
   LOOP
      (* set the bit (led on).  *)
      gpio[LED_GPSET1] := BITSET {LED_GPIO_BIT} ;
      waste_time ;
      (* clear the bit (led off).  *)
      gpio[LED_GPCLR1] := BITSET {LED_GPIO_BIT} ;
      waste_time
   END
END ledtest.
.B-EXAMPLE-END