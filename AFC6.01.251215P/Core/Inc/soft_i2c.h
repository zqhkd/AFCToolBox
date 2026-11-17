#ifndef __SOFT_I2C_H__
#define __SOFT_I2C_H__

#include "main.h"

#define GPIO_I2C2	     GPIOB
#define SCL2_PIN       GPIO_PIN_10
#define SDA2_PIN       GPIO_PIN_11

#define SCL2_H         HAL_GPIO_WritePin(GPIO_I2C2,SCL2_PIN,GPIO_PIN_SET)
#define SCL2_L         HAL_GPIO_WritePin(GPIO_I2C2,SCL2_PIN,GPIO_PIN_RESET)

#define SDA2_H         HAL_GPIO_WritePin(GPIO_I2C2,SDA2_PIN,GPIO_PIN_SET)
#define SDA2_L         HAL_GPIO_WritePin(GPIO_I2C2,SDA2_PIN,GPIO_PIN_RESET)

#define SCL2_read      HAL_GPIO_ReadPin(GPIO_I2C2,SCL2_PIN) 
#define SDA2_read      HAL_GPIO_ReadPin(GPIO_I2C2,SDA2_PIN) 

void Soft_IIC2_Init(void);
void Single_Write2(uint8_t SlaveAddress,uint8_t REG_Address,uint8_t REG_data);
uint8_t Single_Read2(uint8_t SlaveAddress,uint8_t REG_Address);
void I2C_Read2(uint8_t addr, uint8_t reg, uint8_t len, uint8_t *buf);

#endif


