/* export _startup symbol */
.global _startup

/* declare these symbols come from the external */
.extern _stack_end
.extern resetHandler
.extern InterruptHandler

/* alias */
.thumb_set _resetHandler,_startup
.thumb_set _irqHandler,interruptHandler

/* define vector_table */
.section .vector_table,"a",%progbits
.type  _vector_table, %object
_vector_table:
    .word  _stack_end /*_estack */
    .word  _resetHandler /*_startup */
    .word  _irqHandler /*NMI_Handler */
    .word  _irqHandler /*HardFault_Handler */
    .word  _irqHandler /*MemManage_Handler */
    .word  _irqHandler /*BusFault_Handler */
    .word  _irqHandler /*UsageFault_Handler */
    .word  _irqHandler /*0 */
    .word  _irqHandler /*0 */
    .word  _irqHandler /*0 */
    .word  _irqHandler /*0 */
    .word  _irqHandler /*SVC_Handler */
    .word  _irqHandler /*DebugMon_Handler */
    .word  _irqHandler /*0 */
    .word  _irqHandler /*PendSV_Handler */
    .word  _irqHandler /*SysTick_Handler */
    
    /* External Interrupts */
    .word  _irqHandler    /* Window WatchDog              */                                                                
    .word  _irqHandler    /* PVD through EXTI Line detection */                                       
    .word  _irqHandler    /* Tamper and TimeStamps through the EXTI line */       
    .word  _irqHandler    /* RTC Wakeup through the EXTI line */                                    
    .word  _irqHandler    /* FLASH                        */                                                                  
    .word  _irqHandler    /* RCC                          */                                                                    
    .word  _irqHandler    /* EXTI Line0                   */                                    
    .word  _irqHandler    /* EXTI Line1                   */                                        
    .word  _irqHandler    /* EXTI Line2                   */                                        
    .word  _irqHandler    /* EXTI Line3                   */                                        
    .word  _irqHandler    /* EXTI Line4                   */                                        
    .word  _irqHandler    /* DMA1 Stream 0                */                        
    .word  _irqHandler    /* DMA1 Stream 1                */                          
    .word  _irqHandler    /* DMA1 Stream 2                */                          
    .word  _irqHandler    /* DMA1 Stream 3                */                          
    .word  _irqHandler    /* DMA1 Stream 4                */                          
    .word  _irqHandler    /* DMA1 Stream 5                */                          
    .word  _irqHandler    /* DMA1 Stream 6                */                          
    .word  _irqHandler    /* ADC1, ADC2 and ADC3s         */                          
    .word  _irqHandler    /* CAN1 TX                      */                                      
    .word  _irqHandler    /* CAN1 RX0                     */                                        
    .word  _irqHandler    /* CAN1 RX1                     */                                        
    .word  _irqHandler    /* CAN1 SCE                     */                                        
    .word  _irqHandler    /* External Line[9:5]s          */                                        
    .word  _irqHandler    /* TIM1 Break and TIM9          */         
    .word  _irqHandler    /* TIM1 Update and TIM10        */         
    .word  _irqHandler    /* TIM1 Trigger and Commutation and TIM11 */
    .word  _irqHandler    /* TIM1 Capture Compare         */                                        
    .word  _irqHandler    /* TIM2                         */                          
    .word  _irqHandler    /* TIM3                         */                          
    .word  _irqHandler    /* TIM4                         */                          
    .word  _irqHandler    /* I2C1 Event                   */                                        
    .word  _irqHandler    /* I2C1 Error                   */                                        
    .word  _irqHandler    /* I2C2 Event                   */                                        
    .word  _irqHandler    /* I2C2 Error                   */                                            
    .word  _irqHandler    /* SPI1                         */                          
    .word  _irqHandler    /* SPI2                         */                          
    .word  _irqHandler    /* USART1                       */                          
    .word  _irqHandler    /* USART2                       */                          
    .word  _irqHandler    /* USART3                       */                          
    .word  _irqHandler    /* External Line[15:10]s        */                                        
    .word  _irqHandler    /* RTC Alarm (A and B) through EXTI Line */                               
    .word  _irqHandler    /* USB OTG FS Wakeup through EXTI line */                                         
    .word  _irqHandler    /* TIM8 Break and TIM12         */         
    .word  _irqHandler    /* TIM8 Update and TIM13        */         
    .word  _irqHandler    /* TIM8 Trigger and Commutation and TIM14 */
    .word  _irqHandler    /* TIM8 Capture Compare         */                                        
    .word  _irqHandler    /* DMA1 Stream7                 */                                        
    .word  _irqHandler    /* FSMC                         */                          
    .word  _irqHandler    /* SDIO                         */                          
    .word  _irqHandler    /* TIM5                         */                          
    .word  _irqHandler    /* SPI3                         */                          
    .word  _irqHandler    /* UART4                        */                          
    .word  _irqHandler    /* UART5                        */                          
    .word  _irqHandler    /* TIM6 and DAC1&2 underrun errors */                             
    .word  _irqHandler    /* TIM7                         */
    .word  _irqHandler    /* DMA2 Stream 0                */                          
    .word  _irqHandler    /* DMA2 Stream 1                */                          
    .word  _irqHandler    /* DMA2 Stream 2                */                          
    .word  _irqHandler    /* DMA2 Stream 3                */                          
    .word  _irqHandler    /* DMA2 Stream 4                */                          
    .word  _irqHandler    /* Reserved                     */                          
    .word  _irqHandler    /* Reserved                     */                                   
    .word  _irqHandler    /* CAN2 TX                      */                                        
    .word  _irqHandler    /* CAN2 RX0                     */                                        
    .word  _irqHandler    /* CAN2 RX1                     */                                        
    .word  _irqHandler    /* CAN2 SCE                     */                                        
    .word  _irqHandler    /* USB OTG FS                   */                          
    .word  _irqHandler    /* DMA2 Stream 5                */                          
    .word  _irqHandler    /* DMA2 Stream 6                */                          
    .word  _irqHandler    /* DMA2 Stream 7                */                          
    .word  _irqHandler    /* USART6                       */                            
    .word  _irqHandler    /* I2C3 event                   */                                        
    .word  _irqHandler    /* I2C3 error                   */                                        
    .word  _irqHandler    /* USB OTG HS End Point 1 Out   */                          
    .word  _irqHandler    /* USB OTG HS End Point 1 In    */                          
    .word  _irqHandler    /* USB OTG HS Wakeup through EXTI */                                        
    .word  _irqHandler    /* USB OTG HS                   */                          
    .word  _irqHandler    /* Reserved                     */                          
    .word  _irqHandler    /* Reserved                     */                          
    .word  _irqHandler    /* Hash and Rng                 */
    .word  _irqHandler    /* FPU                          */

.section .text
.type  _startup, %function
_startup:
  ldr   sp, =_stack_end     /* set stack pointer */
  b resetHandler
