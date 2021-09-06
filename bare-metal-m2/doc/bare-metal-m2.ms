.T
Modula-2 running on bare metal on the Raspberry Pi-4
.B
here are some instructions and simple test programs which demonstrate
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
.CMD git clone https://github.com/gaiusm/m2-cross
.CMD mkdir build-m2-cross
.CMD cd build-m2-cross
.CMD ../m2-cross/configure
.CMD make
.B-EXAMPLE-END
.B
this will build and install the
.PRG gm2 ,
.PRG gcc ,
.PRG g++
cross compilers into
.PRG $HOME/opt-gcc-12/cross/bin
(and
.PRG $HOME/opt-gcc-12/cross/{lib,share} )
.C
note currently this location is hardcoded
.bp
.T
The bare metal software
.B
there are four objects which will be linked to produce the bare metal
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
   GPIO_MAX     = LED_GPCLR1 ;
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
.bp
.T
Compile and link the application
.B
continue in the command line terminal and type:
.B-EXAMPLE-BEGIN
.CMD cd ../m2-cross/bare-metal-m2
.CMD ./buildm2 ledtest
.B-EXAMPLE-END
.B
this produces a
.PRG kernel.img
file which can be placed into the Raspberry Pi-4
boot file
.PRG kernel8.img
.C
the Raspberry Pi-4 will boot and run this image
.bp
.T
Making the Raspberry Pi-4 boot the kernel8.img file
.B
the placing the
.PRG kernel8.img
into the sdcard is one approach which will work - albeit a slow way to
develop
.B
another (much quicker) method is to configure a tftpserver to serve
the
.PRG kernel8.img
file and configure the Raspberry Pi-4 to boot using tftp
.bp
.T
Turning on an external LED
.B
the code shown below will pulse
.PRG GPIO4
(pin7) lo / high
.C
one simple use for the program is to pulse a LED
.C
the trivial circuit requires a current limiting resistor (330 ohm)
in series with the LED
.C
.PRG <PIN7>
connected to the registor which is connected to the long leg of the LED
.C
the short leg of the LED is connected to GND
.PRG <PIN14>
.B-EXAMPLE-BEGIN

GPIO4        330 ohm    led    GND
<PIN7> ------/\e/\e/\e/----|>|---<PIN14>
                    long  short
.B-EXAMPLE-END
.bp
.T
ledtest2 program
.B-EXAMPLE-BEGIN
.ps -2
.vs -2
MODULE ledtest2 ;

(* Flash an offboard LED of the RPI4 using Modula-2
   You will need to install an LED and resister between PIN 7
   (GPIO4) and ground.
   Author:  Gaius Mulley   31/8/2021.  *)

FROM SYSTEM IMPORT ADDRESS ;

CONST
   GPIO_BASE    = 0FE200000H ;
   GPIO_MAX     = 32 ;
   GPIO_GPFSEL  = 4 ;
   LED_GPFBIT   = 6 ;
   LED_GPIO_BIT = 10 ;
   LED_GPCLR0   = 10 ;
   LED_GPSET0   = 7 ;
   LED_GPCLR1   = 11 ;
   LED_GPSET1   = 8 ;
.B-EXAMPLE-END
.bp
.B-EXAMPLE-BEGIN
.ps -2
.vs -2
VAR
   gpio[GPIO_BASE] : ARRAY [0..GPIO_MAX] OF BITSET ;

PROCEDURE inp_gpio (pin: CARDINAL) ;
VAR
   value   : BITSET ;
   position: CARDINAL ;
BEGIN
   position := (pin MOD 10) * 3 ;
   short_delay ;
   value := gpio[pin DIV 10] ;
   EXCL (value, position) ;
   EXCL (value, position + 1) ;
   EXCL (value, position + 2) ;
   short_delay ;
   gpio[pin DIV 10] := value
END inp_gpio ;
.B-EXAMPLE-END
.bp
.B-EXAMPLE-BEGIN
.ps -2
.vs -2
PROCEDURE out_gpio (pin: CARDINAL) ;
VAR
   value   : BITSET ;
   position: CARDINAL ;
BEGIN
   position := (pin MOD 10) * 3 ;
   short_delay ;
   value := gpio[pin DIV 10] ;
   INCL (value, position) ;
   EXCL (value, position + 1) ;
   EXCL (value, position + 2) ;
   short_delay ;
   gpio[pin DIV 10] := value
END out_gpio ;
.B-EXAMPLE-END
.bp
.B-EXAMPLE-BEGIN
.ps -2
.vs -2
PROCEDURE short_delay ;
CONST
   delay = 10000 ;
VAR
   i: CARDINAL ;
BEGIN
   FOR i := 0 TO delay DO
      ASM VOLATILE ("nop")
   END
END short_delay ;
.B-EXAMPLE-END
.bp
.B-EXAMPLE-BEGIN
.ps -2
.vs -2
PROCEDURE waste_time ;
CONST
   delay = 500000 ;
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
CONST
   LED_EXTERNAL_BIT = 4 ;  (* pin 7  *)

BEGIN
   (* Set this bit to TRUE to enable the LED as an output.  *)
   inp_gpio (LED_EXTERNAL_BIT) ;
   out_gpio (LED_EXTERNAL_BIT) ;
   LOOP
      (* set the bit (led on).  *)
      gpio[LED_GPSET0] := BITSET {LED_EXTERNAL_BIT} ;
      waste_time ;
      (* clear the bit (led off).  *)
      gpio[LED_GPCLR0] := BITSET {LED_EXTERNAL_BIT} ;
      waste_time
   END
END ledtest2.
.B-EXAMPLE-END
.bp
.T
Building ledtest2
.B
the
.PRG kernel.img
containing the
.PRG ledtest2
binary can be built using the following command:
.B-EXAMPLE-BEGIN
.CMD ./buildm2 ledtest2
.B-EXAMPLE-END
