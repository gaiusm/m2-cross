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
