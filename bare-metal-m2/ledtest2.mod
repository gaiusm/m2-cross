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

VAR
   gpio[GPIO_BASE] : ARRAY [0..GPIO_MAX] OF BITSET ;


(* GPIO setup macros.  Must always use inp_gpio (x) before using out_gpio (x).  *)
(* #define INP_GPIO(g)   *(gpio.addr + ((g)/10)) &= ~(7<<(((g)%10)*3))  *)

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


(* #define OUT_GPIO(g)   *(gpio.addr + ((g)/10)) |=  (1<<(((g)%10)*3))  *)

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
