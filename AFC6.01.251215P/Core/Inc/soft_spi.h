#ifndef __SOFT_SPI_H__
#define __SOFT_SPI_H__

#include "main.h"

#define SPI4CsICM20602  0
#define SPI4CsDPS310    1

void Soft_SPI1_Init(void);
void SPI1_Write(uint8_t cs, uint8_t reg,uint8_t data);
uint8_t SPI1_Read(uint8_t cs, uint8_t reg);
void SPI1_Read_Long(uint8_t cs, uint8_t reg,uint8_t *buf,uint8_t length);
void SPI1_Write_Long(uint8_t cs, uint8_t reg,uint8_t *buf,uint8_t length);

void SPI4_CS(uint8_t cs);
void SPI4_NCS(uint8_t cs);
void Soft_SPI4_Init(void);
void SPI4_Read_Long(uint8_t cs,uint8_t reg,uint8_t *buf,uint8_t length);

void SPI4_Write(uint8_t cs,uint8_t reg,uint8_t data);
uint8_t SPI4_Read(uint8_t cs,uint8_t reg);

void FM25V01_SPI_Read(uint32_t addr,uint8_t reg,uint8_t *buf,uint32_t len);
void FM25V01_SPI_Write(uint32_t addr,uint8_t reg,uint8_t *buf,uint32_t len);

#endif


