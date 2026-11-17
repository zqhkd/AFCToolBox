#include "soft_spi.h"

#define SPI1_FM25_CSN_H  HAL_GPIO_WritePin(SRAM_CS_GPIO_Port,SRAM_CS_Pin,GPIO_PIN_SET)
#define SPI1_FM25_CSN_L  HAL_GPIO_WritePin(SRAM_CS_GPIO_Port,SRAM_CS_Pin,GPIO_PIN_RESET)
#define SPI1_CSN_H       HAL_GPIO_WritePin(ICM46288_CS_GPIO_Port,ICM46288_CS_Pin,GPIO_PIN_SET)
#define SPI1_CSN_L  		 HAL_GPIO_WritePin(ICM46288_CS_GPIO_Port,ICM46288_CS_Pin,GPIO_PIN_RESET)
#define SPI1_SCK_H  		 HAL_GPIO_WritePin(GPIOA,GPIO_PIN_5,GPIO_PIN_SET)
#define SPI1_SCK_L  		 HAL_GPIO_WritePin(GPIOA,GPIO_PIN_5,GPIO_PIN_RESET)
#define SPI1_MOSI_H 		 HAL_GPIO_WritePin(GPIOA,GPIO_PIN_7,GPIO_PIN_SET)
#define SPI1_MOSI_L 		 HAL_GPIO_WritePin(GPIOA,GPIO_PIN_7,GPIO_PIN_RESET)
#define SPI1_MISO_read   HAL_GPIO_ReadPin(GPIOA,GPIO_PIN_6) 

#define SPI4_20602_CSN_H  HAL_GPIO_WritePin(BMI088_CS_GPIO_Port,BMI088_CS_Pin,GPIO_PIN_SET)
#define SPI4_20602_CSN_L  HAL_GPIO_WritePin(BMI088_CS_GPIO_Port,BMI088_CS_Pin,GPIO_PIN_RESET)
#define SPI4_310_CSN_H  	HAL_GPIO_WritePin(DPS310_CS_GPIO_Port,DPS310_CS_Pin,GPIO_PIN_SET)
#define SPI4_310_CSN_L  	HAL_GPIO_WritePin(DPS310_CS_GPIO_Port,DPS310_CS_Pin,GPIO_PIN_RESET)
#define SPI4_SCK_H  		HAL_GPIO_WritePin(GPIOE,GPIO_PIN_2,GPIO_PIN_SET)
#define SPI4_SCK_L  		HAL_GPIO_WritePin(GPIOE,GPIO_PIN_2,GPIO_PIN_RESET)
#define SPI4_MOSI_H 		HAL_GPIO_WritePin(GPIOE,GPIO_PIN_6,GPIO_PIN_SET)
#define SPI4_MOSI_L 		HAL_GPIO_WritePin(GPIOE,GPIO_PIN_6,GPIO_PIN_RESET)
#define SPI4_MISO_read  HAL_GPIO_ReadPin(GPIOE,GPIO_PIN_5) 

void Soft_SPI1_Init(void)
{
	GPIO_InitTypeDef GPIO_InitStruct = {0};
    
	GPIO_InitStruct.Pin = GPIO_PIN_5|GPIO_PIN_7;
	GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);
	
	GPIO_InitStruct.Pin = GPIO_PIN_6;
	GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);
	SPI1_CSN_H;
}

void Soft_SPI4_Init(void)
{
	GPIO_InitTypeDef GPIO_InitStruct = {0};
    
	GPIO_InitStruct.Pin = GPIO_PIN_2|GPIO_PIN_6;
	GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(GPIOE, &GPIO_InitStruct);
	
	GPIO_InitStruct.Pin = GPIO_PIN_5;
	GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
	GPIO_InitStruct.Pull = GPIO_NOPULL;
	GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
	HAL_GPIO_Init(GPIOE, &GPIO_InitStruct);
	SPI4_20602_CSN_H;
	SPI4_310_CSN_H;
}

void spi_delay(uint8_t iTim)
{
	for(uint8_t i = 0; i < iTim; i++){
		__NOP();__NOP();__NOP();__NOP();
	}
}

uint8_t SPI1_Transfer(uint8_t data)
{
	uint8_t i;

	for(i=0;i<8;i++) {
		SPI1_SCK_L;
		spi_delay(5);
		if(data & 0x80) {
			SPI1_MOSI_H;
		} else {
			SPI1_MOSI_L;
		}

		spi_delay(5);
		SPI1_SCK_H;
		data <<= 1;
		spi_delay(5);
		//if(SPI1_MISO_STATUS) data|=0x01;

		if(SPI1_MISO_read) data|=0x01;
		else data&=0xfe;

		spi_delay(5);
	}
	spi_delay(5);
	SPI1_SCK_L;
	return data;
}

#define SPI4Width  3
uint8_t SPI4_Transfer(uint8_t data)
{
	uint8_t i;

	for(i=0;i<8;i++) {
		SPI4_SCK_L;
		spi_delay(SPI4Width);
		if(data & 0x80) {
			SPI4_MOSI_H;
		} else {
			SPI4_MOSI_L;
		}

		spi_delay(SPI4Width);
		SPI4_SCK_H;
		data <<= 1;
		spi_delay(SPI4Width);

		if(SPI4_MISO_read) data|=0x01;
		else data&=0xfe;

		spi_delay(SPI4Width);
	}
	spi_delay(SPI4Width);
	SPI4_SCK_L;
	return data;
}

void SPI1_CS(uint8_t cs)
{
	if(cs==0) { //42688
		SPI1_CSN_L;
	} else if(cs==1) {  //FM25V01
		SPI1_FM25_CSN_L;
	}
	spi_delay(5);
}

void SPI1_NCS(uint8_t cs)
{
	if(cs==0) { //42688
		SPI1_CSN_H;
	} else if(cs==1) {  //FM25V01
		SPI1_FM25_CSN_H;
	}
	spi_delay(5);
}

// 以下为SPI1连接设备: ICM242688和FM25V01
void SPI1_Write(uint8_t cs, uint8_t reg,uint8_t data)
{
  SPI1_CS(cs);	
	SPI1_Transfer(0x7f&reg);
	SPI1_Transfer(data);
  SPI1_NCS(cs);	
}

uint8_t SPI1_Read(uint8_t cs, uint8_t reg)
{
	uint8_t tmp;
  SPI1_CS(cs);	
	SPI1_Transfer(0x80|reg);
	tmp = SPI1_Transfer(0);
	if(cs==0) { //42688
		SPI1_CSN_H;
	} else if(cs==1) {  //FM25V01
		SPI1_FM25_CSN_H;
	}
	return tmp;
}

void SPI1_Read_Long(uint8_t cs, uint8_t reg,uint8_t *buf,uint8_t length)
{
	uint8_t tmp;

	SPI1_CS(cs);
	SPI1_Transfer(0x80|reg);
	for(tmp=0;tmp<length;tmp++)
	{
		buf[tmp] = SPI1_Transfer(0);
	}
  SPI1_NCS(cs);
}

void SPI1_Write_Long(uint8_t cs, uint8_t reg,uint8_t *buf,uint8_t length)
{
	uint8_t j;
	SPI1_CS(cs);
	j = 0;
	SPI1_Transfer(reg);
	for(j = 0;j < length; j++)
	{
		SPI1_Transfer(buf[j]);
	}
	SPI1_NCS(cs);
}

void SPI4_CS(uint8_t cs)
{
	if(cs==SPI4CsICM20602) { //20602
		SPI4_20602_CSN_L;
	} else if(cs==SPI4CsDPS310) {  //DPS310
		SPI4_310_CSN_L;
	}
	spi_delay(5);
}

void SPI4_NCS(uint8_t cs)
{
	spi_delay(5);
  if(cs==SPI4CsICM20602) { //20602
		SPI4_20602_CSN_H;
	}
	else if(cs==SPI4CsDPS310) {  //DPS310
		SPI4_310_CSN_H;
	}
}

// 以下为SPI4连接设备: ICM20602和DPS310
void SPI4_Write(uint8_t cs,uint8_t reg,uint8_t data)
{
  SPI4_CS(cs);
	SPI4_Transfer(0x7f&reg);
	SPI4_Transfer(data);
  SPI4_NCS(cs);
}

uint8_t SPI4_Read(uint8_t cs,uint8_t reg)
{
	uint8_t tmp;
  SPI4_CS(cs);
	SPI4_Transfer(0x80|reg);
	tmp = SPI4_Transfer(0);
  SPI4_NCS(cs);
	return tmp;
}

void SPI4_Read_Long(uint8_t cs,uint8_t reg,uint8_t *buf,uint8_t length)
{
	uint8_t tmp;

  SPI4_CS(cs);
	SPI4_Transfer(0x80|reg);
	spi_delay(5);
	for(tmp=0;tmp<length;tmp++)
	{
		buf[tmp] = SPI4_Transfer(0);
	}
  SPI4_NCS(cs);
}

void FM25V01_SPI_Read(uint32_t addr,uint8_t reg,uint8_t *buf,uint32_t len)
{
	uint32_t i;
	SPI1_FM25_CSN_L;
	
	SPI1_Transfer(reg);
	SPI1_Transfer((addr&0x00FF0000)>>16);
	SPI1_Transfer((addr&0x0000FF00)>>8);
	SPI1_Transfer((addr&0x000000FF));
	
	for(i=0;i<len;i++) {
		buf[i] = SPI1_Transfer(0);
	}
	
	SPI1_FM25_CSN_H;
}

uint8_t FM25V01_RDSR(void)//寄存器配置内容读取
{
	uint8_t Reg_Status;

	SPI1_FM25_CSN_L;
	SPI1_Transfer(0x05);
	Reg_Status = SPI1_Transfer(0);
	SPI1_FM25_CSN_H;
	return(Reg_Status);
}

void FM25V01_SPI_Write(uint32_t addr,uint8_t reg,uint8_t *buf,uint32_t len)
{
	uint32_t i;
	SPI1_FM25_CSN_L;
	SPI1_Transfer(0x06);  //Enable Write
	SPI1_FM25_CSN_H;
	
	spi_delay(5);spi_delay(5);spi_delay(5);
	SPI1_FM25_CSN_L;
	SPI1_Transfer(reg);
	SPI1_Transfer((addr&0x00FF0000)>>16);
	SPI1_Transfer((addr&0x0000FF00)>>8);
	SPI1_Transfer((addr&0x000000FF));
	
	for(i=0;i<len;i++) {
		SPI1_Transfer(buf[i]);
	}
	
	SPI1_FM25_CSN_H;
	
//	spi_delay(5);spi_delay(5);spi_delay(5);
	while (0x01 == (FM25V01_RDSR() & 0x01)); 
	SPI1_Transfer(0x04);  //Disable Write
}
