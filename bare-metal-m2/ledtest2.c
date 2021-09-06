// GPIO setup macros. Always use INP_GPIO(x) before using OUT_GPIO(x)
#define INP_GPIO(g)   *(gpio_addr + ((g)/10)) &= ~(7<<(((g)%10)*3))
#define OUT_GPIO(g)   *(gpio_addr + ((g)/10)) |=  (1<<(((g)%10)*3))
#define SET_GPIO_ALT(g,a) *(gpio_addr + (((g)/10))) |= (((a)<=3?(a) + 4:(a)==4?3:2)<<(((g)%10)*3))

#define GPIO_SET  *(gpio_addr + 8)  // sets   bits which are 1 ignores bits which are 0
#define GPIO_CLR  *(gpio_addr + 11) // clears bits which are 1 ignores bits which are 0

#define GPIO_SET0  *(gpio_addr + 7)  // sets   bits which are 1 ignores bits which are 0
#define GPIO_CLR0  *(gpio_addr + 10) // clears bits which are 1 ignores bits which are 0

#define GPIO_READ(g)  *(gpio_addr + 13) &= (1<<(g))
#define GPIO_BASE 0xfe200000UL

void waste_time (void)
{
  unsigned int i;

  for (i = 0; i < 500000; i++)
    asm volatile ("nop");
}


#if 1
void RPI_SetGpioPinFunction (unsigned int gpio, unsigned int func)
{
  volatile unsigned int *gpio_addr = (unsigned int *) GPIO_BASE;
  unsigned int fsel_copy = gpio_addr[gpio / 10];
  fsel_copy &= ~( 7 << ( ( gpio % 10 ) * 3 ) );
  fsel_copy |= (func << ( ( gpio % 10 ) * 3 ) );
  gpio_addr[gpio / 10] = fsel_copy;
}


void RPI_SetGpioOutput (unsigned int gpio)
{
    RPI_SetGpioPinFunction (gpio, 1);
}
#endif


void _M2_ledtest2_init (void)
{
  volatile unsigned int *gpio_addr = (unsigned int *) GPIO_BASE;

#if 0
  INP_GPIO (4);
  OUT_GPIO (4);  /* pin 7.  */
#else
  RPI_SetGpioOutput (4);
#endif
  for (;;)
    {
      waste_time ();
      GPIO_SET0 = 1 << 4;
      waste_time ();
      GPIO_CLR0 = 1 << 4;
    }
}

void _M2_ledtest2_finish (void)
{
  /* nothing to do.  */
}
