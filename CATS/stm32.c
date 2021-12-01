#include "stm32f4xx.h"

/*

User LD2: the green LED is a user LED connected 
to ARDUINO® signal D13 corresponding 
to STM32 I/O PA5 (pin 21) or PB13 (pin 34) 
depending on the STM32 target.

*/
void ms_delay (int ms)
{
  while (ms-- > 0)
    {
      volatile int x = 500;
      while (x-- > 0)
	__asm ("nop");
    }
}
void loopProgr_in_c() {
// Setup peripheral clock for GPIOA
    RCC->AHB1RSTR |= RCC_AHB1RSTR_GPIOARST;    // Reset GPIOA 
    RCC->AHB1RSTR = 0;                         // Exit reset state
    
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;       // Enable GPIOA clock
    GPIOA->MODER |= GPIO_MODER_MODER5_0;	   // Enable Output on A5 (LED2 on Nucleo F401RE board)
    
    while (1)
    {
    	GPIOA->ODR ^= (1 << (5));	// toggle LED pin
    	ms_delay(800);

    }

 
} 
