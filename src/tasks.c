#include "cmsis_os.h"
#include "main.h"
#include "tasks.h"
#include "stm32f4xx_hal.h"

static GPIO_InitTypeDef  GPIO_InitStruct;

void GPIO_init()
{
  // enable GPIOA clock
  __GPIOA_CLK_ENABLE();

  GPIO_InitStruct.Pin = GPIO_PIN_5;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_PULLUP;
  GPIO_InitStruct.Speed = GPIO_SPEED_FAST;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct); 
}

static void BlinkLED(void const *argv)
{
  if (argv != NULL) {;}

  while (1)
  {
    HAL_GPIO_TogglePin(GPIOA, GPIO_PIN_5);
    
    osDelay(500);
  }
}

inline void createTasks()
{
  GPIO_init();
  
  // define a BlinkLED thread
  osThreadDef(  LED_Thread,                   // Name of instances
                BlinkLED,                     // Implementation of thread
                osPriorityNormal,             // Priority
                1,                            // Quantity of instances
                2 * configMINIMAL_STACK_SIZE  // Stack size
             );

  // create a BlinkLED thread
  osThreadCreate(osThread(LED_Thread), NULL);

  return;
}

