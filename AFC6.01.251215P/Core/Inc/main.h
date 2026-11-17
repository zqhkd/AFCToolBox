/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.h
  * @brief          : Header for main.c file.
  *                   This file contains the common defines of the application.
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2025 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __MAIN_H
#define __MAIN_H

#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include "stm32h7xx_hal.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Exported types ------------------------------------------------------------*/
/* USER CODE BEGIN ET */

/* USER CODE END ET */

/* Exported constants --------------------------------------------------------*/
/* USER CODE BEGIN EC */

/* USER CODE END EC */

/* Exported macro ------------------------------------------------------------*/
/* USER CODE BEGIN EM */

/* USER CODE END EM */

/* Exported functions prototypes ---------------------------------------------*/
void Error_Handler(void);

/* USER CODE BEGIN EFP */

/* USER CODE END EFP */

/* Private defines -----------------------------------------------------------*/
#define BMI088_CS_Pin GPIO_PIN_3
#define BMI088_CS_GPIO_Port GPIOE
#define DPS310_CS_Pin GPIO_PIN_4
#define DPS310_CS_GPIO_Port GPIOE
#define GPO8_Pin GPIO_PIN_13
#define GPO8_GPIO_Port GPIOC
#define GPO7_Pin GPIO_PIN_2
#define GPO7_GPIO_Port GPIOC
#define ADC3_INP1_Pin GPIO_PIN_3
#define ADC3_INP1_GPIO_Port GPIOC
#define TIM5_CH1_Pin GPIO_PIN_0
#define TIM5_CH1_GPIO_Port GPIOA
#define PWM_IN_T2_CH2_Pin GPIO_PIN_1
#define PWM_IN_T2_CH2_GPIO_Port GPIOA
#define SRAM_CS_Pin GPIO_PIN_4
#define SRAM_CS_GPIO_Port GPIOA
#define ICM46288_CS_Pin GPIO_PIN_4
#define ICM46288_CS_GPIO_Port GPIOC
#define GPO6_Pin GPIO_PIN_5
#define GPO6_GPIO_Port GPIOC
#define TIM3_CH3_Pin GPIO_PIN_0
#define TIM3_CH3_GPIO_Port GPIOB
#define TIM3_CH4_Pin GPIO_PIN_1
#define TIM3_CH4_GPIO_Port GPIOB
#define GPO5_Pin GPIO_PIN_2
#define GPO5_GPIO_Port GPIOB
#define PWM_IE_Pin GPIO_PIN_7
#define PWM_IE_GPIO_Port GPIOE
#define PWM_OE_Pin GPIO_PIN_8
#define PWM_OE_GPIO_Port GPIOE
#define PWM_T1_CH1_Pin GPIO_PIN_9
#define PWM_T1_CH1_GPIO_Port GPIOE
#define GPO4_Pin GPIO_PIN_10
#define GPO4_GPIO_Port GPIOE
#define PWM_T1_CH2_Pin GPIO_PIN_11
#define PWM_T1_CH2_GPIO_Port GPIOE
#define GPO3_Pin GPIO_PIN_12
#define GPO3_GPIO_Port GPIOE
#define PWM_T1_CH3_Pin GPIO_PIN_13
#define PWM_T1_CH3_GPIO_Port GPIOE
#define PWM_T1_CH4_Pin GPIO_PIN_14
#define PWM_T1_CH4_GPIO_Port GPIOE
#define GPO2_Pin GPIO_PIN_15
#define GPO2_GPIO_Port GPIOE
#define I2C2_SCL_Pin GPIO_PIN_10
#define I2C2_SCL_GPIO_Port GPIOB
#define I2C2_SDA_Pin GPIO_PIN_11
#define I2C2_SDA_GPIO_Port GPIOB
#define AT7456E_CS_Pin GPIO_PIN_12
#define AT7456E_CS_GPIO_Port GPIOB
#define W25Q01JV_CS_Pin GPIO_PIN_10
#define W25Q01JV_CS_GPIO_Port GPIOD
#define GPO1_Pin GPIO_PIN_11
#define GPO1_GPIO_Port GPIOD
#define PWM_T4_CH1_Pin GPIO_PIN_12
#define PWM_T4_CH1_GPIO_Port GPIOD
#define PWM_T4_CH2_Pin GPIO_PIN_13
#define PWM_T4_CH2_GPIO_Port GPIOD
#define LED_B2_T4_CH3_Pin GPIO_PIN_14
#define LED_B2_T4_CH3_GPIO_Port GPIOD
#define LED_B1_T4_CH4_Pin GPIO_PIN_15
#define LED_B1_T4_CH4_GPIO_Port GPIOD
#define GPI8_Pin GPIO_PIN_8
#define GPI8_GPIO_Port GPIOC
#define GPI7_Pin GPIO_PIN_9
#define GPI7_GPIO_Port GPIOC
#define GPI6_Pin GPIO_PIN_8
#define GPI6_GPIO_Port GPIOA
#define USB_VBUS_Pin GPIO_PIN_9
#define USB_VBUS_GPIO_Port GPIOA
#define PWM_IN_T2_CH1_Pin GPIO_PIN_15
#define PWM_IN_T2_CH1_GPIO_Port GPIOA
#define GPI5_Pin GPIO_PIN_4
#define GPI5_GPIO_Port GPIOD
#define GPI4_Pin GPIO_PIN_5
#define GPI4_GPIO_Port GPIOD
#define GPI3_Pin GPIO_PIN_6
#define GPI3_GPIO_Port GPIOD
#define GPI2_Pin GPIO_PIN_7
#define GPI2_GPIO_Port GPIOD
#define GPI1_Pin GPIO_PIN_7
#define GPI1_GPIO_Port GPIOB

/* USER CODE BEGIN Private defines */

/* USER CODE END Private defines */

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */
