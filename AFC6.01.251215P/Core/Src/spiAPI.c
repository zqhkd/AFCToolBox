#include "spiAPI.h"
#include "string.h"
#include "spi.h"

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

#define MAX_SPI_BUFFER_SIZE  50

void spi_delay(uint8_t iTim)
{
	for(uint8_t i = 0; i < iTim; i++){
		__NOP();__NOP();__NOP();__NOP();
	}
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

#define SPI1Width  5
uint8_t SPI1_Transfer(uint8_t data)
{
	uint8_t i;

	for(i=0;i<8;i++) {
		SPI1_SCK_L;
		spi_delay(SPI1Width);
		if(data & 0x80) {
			SPI1_MOSI_H;
		} else {
			SPI1_MOSI_L;
		}

		spi_delay(SPI1Width);
		SPI1_SCK_H;
		data <<= 1;
		spi_delay(SPI1Width);

		if(SPI1_MISO_read) data|=0x01;
		else data&=0xfe;

		spi_delay(SPI1Width);
	}
	spi_delay(SPI1Width);
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

void writeRegByte(SPI_HandleTypeDef *hspi, uint8_t reg, uint8_t data)
{
	uint8_t tx_data[2];
	tx_data[0] = reg; tx_data[1] = data;
	HAL_SPI_Transmit(hspi,tx_data,2,1);    // 将寄存器和单字节数据发送至spi
}

uint8_t readRegByte(SPI_HandleTypeDef *hspi, uint8_t reg)
{
	uint8_t tx_data[2] = {reg, 0x00};
	uint8_t rx_data[2] = {0};
	
	HAL_StatusTypeDef ret = HAL_SPI_TransmitReceive(hspi,tx_data,rx_data,2,1);
  
  return rx_data[1];
}

void writeRegBuff(SPI_HandleTypeDef *hspi, uint8_t reg,uint8_t *data, uint8_t length)
{
	static uint8_t tx_buffer[MAX_SPI_BUFFER_SIZE];
	// 检查长度是否超出缓冲区容量
	if ((length + 1) > MAX_SPI_BUFFER_SIZE) {
		// 处理错误：长度超出缓冲区容量
		Error_Handler();
		return;
	}

	// 将寄存器地址放在缓冲区的第一个字节
	tx_buffer[0] = reg;

	// 将数据复制到缓冲区后续位置
	memcpy(&tx_buffer[1], data, length);

	// 发送合并后的数据
	HAL_SPI_Transmit(hspi, tx_buffer, length + 1, HAL_MAX_DELAY);
}

void readRegBuff(SPI_HandleTypeDef *hspi, uint8_t reg, uint8_t *data, uint8_t length)
{
	uint8_t tx_buff[MAX_SPI_BUFFER_SIZE],rx_buff[MAX_SPI_BUFFER_SIZE];
	tx_buff[0] = reg;  

	// 后面需要发送虚拟字节来生成时钟
	for (uint8_t i = 0; i < length; i++) {
			tx_buff[i+1] = 0x00;  // 虚拟数据，只为生成时钟
	}
  
	HAL_SPI_TransmitReceive(hspi,tx_buff,rx_buff, length + 1, 1);
	
	// rx_buff[0] 通常是设备对寄存器地址的响应（通常忽略）
	// rx_buff[1] 到 rx_buffer[total_length-1] 是真正的数据
	memcpy(data, &rx_buff[1], length);	
}

// 以下为SPI1连接设备: ICM242688和FM25V01
void SPI1_Write(uint8_t cs, uint8_t reg,uint8_t data)
{
  SPI1_CS(cs);
#ifdef __SPI1_SOFT_SIMU__
	SPI1_Transfer(reg & 0x7f);
	SPI1_Transfer(data);
#else
	writeRegByte(&hspi1,reg & 0x7f,data);
#endif
  SPI1_NCS(cs);	
}

uint8_t SPI1_Read(uint8_t cs, uint8_t reg)
{
	uint8_t tmp;
  SPI1_CS(cs);	
#ifdef __SPI1_SOFT_SIMU__
	SPI1_Transfer(reg | 0x80);
	tmp = SPI1_Transfer(0);
#else
	tmp = readRegByte(&hspi1,reg | 0x80); // 读操作需要置位指令地址的最高位
#endif
	SPI1_NCS(cs);
	return tmp;
}

void SPI1_Write_Long(uint8_t cs, uint8_t reg,uint8_t *data,uint8_t length)
{
	SPI1_CS(cs);
#ifdef __SPI1_SOFT_SIMU__
	SPI1_Transfer(reg & 0x7f);
	for(uint8_t i = 0;i < length; i++)
	{
		SPI1_Transfer(data[i]);
	}
#else	
	writeRegBuff(&hspi1,reg | 0x7f,data,length);
#endif
	SPI1_NCS(cs);
}

void SPI1_Read_Long(uint8_t cs, uint8_t reg,uint8_t *data,uint8_t length)
{
	SPI1_CS(cs);
#ifdef __SPI1_SOFT_SIMU__
	SPI1_Transfer(0x80|reg);
	for(uint8_t i=0;i<length;i++)
	{
		data[i] = SPI1_Transfer(0);
	}
#else
	readRegBuff(&hspi1,reg | 0x80, data, length); // 读操作需要置位指令地址的最高位
#endif
  SPI1_NCS(cs);
}

// 以下为SPI4连接设备: ICM20602和DPS310
void SPI4_Write(uint8_t cs, uint8_t reg,uint8_t data)
{
  SPI4_CS(cs);
#ifdef __SPI4_SOFT_SIMU__
	SPI4_Transfer(reg & 0x7f);
	SPI4_Transfer(data);
#else
	writeRegByte(&hspi4,reg & 0x7f,data);
#endif
  SPI4_NCS(cs);	
}

uint8_t SPI4_Read(uint8_t cs, uint8_t reg)
{
	uint8_t tmp;
  SPI4_CS(cs);	
#ifdef __SPI4_SOFT_SIMU__
	SPI4_Transfer(reg | 0x80);
	tmp = SPI4_Transfer(0);
#else	
	tmp = readRegByte(&hspi4,reg | 0x80); // 读操作需要置位指令地址的最高位
#endif
	SPI4_NCS(cs);
	return tmp;
}

void SPI4_Write_Long(uint8_t cs, uint8_t reg,uint8_t *data,uint8_t length)
{
	SPI4_CS(cs);
#ifdef __SPI4_SOFT_SIMU__
	SPI4_Transfer(reg & 0x7f);
	for(uint8_t i = 0;i < length; i++)
	{
		SPI4_Transfer(data[i]);
	}
#else
	writeRegBuff(&hspi4,reg | 0x7f,data,length);
#endif
	SPI4_NCS(cs);
}

void SPI4_Read_Long(uint8_t cs, uint8_t reg,uint8_t *data,uint8_t length)
{
	SPI4_CS(cs);
#ifdef __SPI4_SOFT_SIMU__
	SPI4_Transfer(reg | 0x80);
	spi_delay(5);
	for(uint8_t i=0;i<length;i++)
	{
		data[i] = SPI4_Transfer(0);
	}
#else
	readRegBuff(&hspi4,reg | 0x80, data, length); // 读操作需要置位指令地址的最高位
#endif
  SPI4_NCS(cs);
}

void FM25V01_SPI_Read(uint32_t addr,uint8_t reg,uint8_t *data,uint32_t length)
{
	uint8_t i;
	SPI1_FM25_CSN_L;
	
#ifdef __SPI1_SOFT_SIMU__
	SPI1_Transfer(reg);
	SPI1_Transfer((addr&0x00FF0000)>>16);
	SPI1_Transfer((addr&0x0000FF00)>>8);
	SPI1_Transfer((addr&0x000000FF));
	
	for(i=0;i<length;i++) {
		data[i] = SPI1_Transfer(0);
	}	
#else	
	uint8_t cmdIdx = 0;
	uint8_t tx_buff[MAX_SPI_BUFFER_SIZE],rx_buff[MAX_SPI_BUFFER_SIZE];
	tx_buff[cmdIdx++] = reg;  // 读操作需要置位指令地址的最高位
  tx_buff[cmdIdx++] = (addr&0x00FF0000)>>16;
  tx_buff[cmdIdx++] = (addr&0x0000FF00)>>8;
  tx_buff[cmdIdx++] =  addr&0x000000FF;
	
	// 后面需要发送虚拟字节来生成时钟
	for (i = 0; i < length; i++) {
			tx_buff[i+cmdIdx] = 0x00;  // 虚拟数据，只为生成时钟
	}
  
	HAL_SPI_TransmitReceive(&hspi1,tx_buff,rx_buff, length + cmdIdx, 1);
	
	// rx_buff[0] 通常是设备对寄存器地址的响应（通常忽略）
	// rx_buff[1] 到 rx_buffer[total_length-1] 是真正的数据
	memcpy(data, &rx_buff[cmdIdx], length);		
#endif
	
	SPI1_FM25_CSN_H;
}

uint8_t FM25V01_RDSR(void)//寄存器配置内容读取
{
	uint8_t Reg_Status;

	SPI1_FM25_CSN_L;
#ifdef __SPI1_SOFT_SIMU__
	SPI1_Transfer(0x05);
	Reg_Status = SPI1_Transfer(0);
#else
	Reg_Status = readRegByte(&hspi1,0x05);
#endif
	SPI1_FM25_CSN_H;
	
	return(Reg_Status);
}

void FM25V01_SPI_Write(uint32_t addr,uint8_t reg,uint8_t *data,uint32_t length)
{
	uint32_t i;
	SPI1_FM25_CSN_L;
	
#ifdef __SPI1_SOFT_SIMU__
	SPI1_Transfer(0x06);  //Enable Write
#else	
	uint8_t cmdIdx = 0;
	uint8_t tx_buff[MAX_SPI_BUFFER_SIZE];
	tx_buff[0] = 0x06;  //Enable Write。
	HAL_SPI_Transmit(&hspi1, tx_buff, 1, HAL_MAX_DELAY);
#endif
	
	SPI1_FM25_CSN_H;
	
	spi_delay(5);spi_delay(5);spi_delay(5);
	
	SPI1_FM25_CSN_L;
#ifdef __SPI1_SOFT_SIMU__
	SPI1_Transfer(reg);
	SPI1_Transfer((addr&0x00FF0000)>>16);
	SPI1_Transfer((addr&0x0000FF00)>>8);
	SPI1_Transfer((addr&0x000000FF));
	
	for(i=0;i<length;i++) {
		SPI1_Transfer(data[i]);
	}
#else	
	tx_buff[cmdIdx++] = reg;  // 读操作需要置位指令地址的最高位
  tx_buff[cmdIdx++] = (addr&0x00FF0000)>>16;
  tx_buff[cmdIdx++] = (addr&0x0000FF00)>>8;
  tx_buff[cmdIdx++] =  addr&0x000000FF;	
	
	for(i=0;i<length;i++) {
	  tx_buff[i+cmdIdx] = data[i];  // 虚拟数据，只为生成时钟
	}
	// 发送合并后的数据
	HAL_SPI_Transmit(&hspi1, tx_buff, length + cmdIdx, HAL_MAX_DELAY);
#endif
	
	SPI1_FM25_CSN_H;
	
//	spi_delay(5);spi_delay(5);spi_delay(5);
	while (0x01 == (FM25V01_RDSR() & 0x01)); 
#ifdef __SPI1_SOFT_SIMU__
  SPI1_Transfer(0x04);  //Disable Write
#else
	tx_buff[0] = 0x04;  // Disable Write
	HAL_SPI_Transmit(&hspi1, tx_buff, 1, HAL_MAX_DELAY);
#endif
}
