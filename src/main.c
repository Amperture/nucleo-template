/*
 * ===========================================================================
 *
 *       Filename:  main.c
 *
 *    Description:  A simple beginner project to get to a blinking light
 *                  on an STM32F401 Nucleo Board 
 *
 *        Version:  1.0
 *        Created:  06/14/2015 06:08:55 AM
 *       Revision:  none
 *       Compiler:  arm-none-eabi-gcc
 *
 *         Author:  W. Alex Best (mn), alexbest@alexbest.me
 *        Company:  Amperture Engineering
 *
 * ===========================================================================
 */

#include <stm32f4xx.h>

#define DELAY 10000
#define LED_PIN 5
#define LED_SPEED 3

void delay(){
   uint32_t i = 0;

   while (i < DELAY){
       i++;
   }

}

int main() {

    // Enable GPIOA system clock in RCC.
    // See page 118 of the STM32F401RE Reference Manual from ST
    RCC->AHB1ENR |= (1 << 0);

    //GPIO Init: Pin Mode
    //1 = Output
    GPIOA->MODER |= (1 << 2*LED_PIN);

    //GPIO Init: Pin Speed
    GPIOA->OSPEEDR |= (LED_SPEED << 2*LED_PIN);

    while(1){
        GPIOA->ODR ^= (1 << LED_PIN);
        delay();
    } 
    
}
