/*
 * *
 * * Copyright (C) Patryk Jaworski <regalis@regalis.com.pl>
 * *
 * * This program is free software: you can redistribute it and/or modify
 * * it under the terms of the GNU General Public License as published by
 * * the Free Software Foundation, either version 3 of the License, or
 * * (at your option) any later version.
 * *
 * * This program is distributed in the hope that it will be useful,
 * * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * * GNU General Public License for more details.
 * *
 * * You should have received a copy of the GNU General Public License
 * * along with this program. If not, see <http://www.gnu.org/licenses/>.
 * *
 * */
#include <stm32f4xx.h>
 
#define LED_PIN 5
#define LED_ON() GPIOA->BSRR |= (1 << 5)
#define LED_OFF() GPIOA->BSRR |= (1 << 21)
 
int main() {
        uint32_t index;

        /* Enbale GPIOA clock */
        RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;

        /* Configure GPIOA pin 5 as output */
        GPIOA->MODER |= (1 << (LED_PIN << 1));

        /* Configure GPIOA pin 5 in max speed */
        GPIOA->OSPEEDR |= (3 << (LED_PIN << 1));

        while(1){
            //The most janked up delay function you ever did see.
            for(index = 0; index < 50000000; index++){
            }
            
            //Toggle the LED on or off.
            GPIOA->ODR ^= (1 << 5);
        }
}
