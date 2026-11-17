#include "i2cAPI.h"

void Soft_IIC2_Init(void)
{
	GPIO_InitTypeDef GPIO_Initure;
    
	//PH4,5初始化设置
	GPIO_Initure.Pin=SCL2_PIN|SDA2_PIN;
	GPIO_Initure.Mode=GPIO_MODE_OUTPUT_PP;  //推挽输出
	GPIO_Initure.Pull=GPIO_NOPULL;          //上拉
	GPIO_Initure.Speed=GPIO_SPEED_FREQ_HIGH;    //快速
	HAL_GPIO_Init(GPIO_I2C2,&GPIO_Initure);
}

void I2C2_delay(void)
{
	__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();
	__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();
	__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();
}

void SDA2_OUT(void)
{
	GPIO_InitTypeDef GPIO_InitStruct;
	GPIO_InitStruct.Pin = SDA2_PIN;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_HIGH;
  HAL_GPIO_Init(GPIO_I2C2, &GPIO_InitStruct);
}

void SDA2_IN(void)
{
	GPIO_InitTypeDef GPIO_InitStruct;
	GPIO_InitStruct.Pin = SDA2_PIN;
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(GPIO_I2C2, &GPIO_InitStruct);
}

//产生IIC起始信号
void IIC2_Start(void)
{
	SDA2_OUT();     //sda线输出
	SDA2_H;	  	  
	SCL2_H;
	I2C2_delay();
 	SDA2_L;//START:when CLK is high,DATA change form high to low 
	I2C2_delay();
}	  
//产生IIC停止信号
void IIC2_Stop(void)
{
	SDA2_OUT();//sda线输出
	SCL2_L;
	I2C2_delay();
	SDA2_L;//STOP:when CLK is high DATA change form low to high
 	I2C2_delay();
	SCL2_H; 
	I2C2_delay();
	SDA2_H;//发送I2C总线结束信号
	I2C2_delay();					   	
}
//等待应答信号到来
//返回值：1，接收应答失败
//        0，接收应答成功
uint8_t IIC2_Wait_Ack(void)
{
	uint8_t ucErrTime=0;
	SDA2_IN();      //SDA设置为输入  
	SDA2_H;I2C2_delay();		   
	SCL2_H;I2C2_delay();		
	while(SDA2_read)
	{
		ucErrTime++;
		if(ucErrTime>250)
		{
			SCL2_L;I2C2_delay();		
			IIC2_Stop();
			return 1;
		}
	}
	SCL2_L;//时钟输出0 	  
	I2C2_delay();		
	SDA2_OUT();
	return 0;  
} 
//产生ACK应答
void IIC2_Ack(void)
{
	SCL2_L;
	I2C2_delay();	
	SDA2_OUT();
	SDA2_L;
	I2C2_delay();	
	SCL2_H;
	I2C2_delay();	
	SCL2_L;
	I2C2_delay();	
}
//不产生ACK应答		    
void IIC2_NAck(void)
{
	SCL2_L;
	I2C2_delay();	
	SDA2_OUT();
	SDA2_H;
	I2C2_delay();	
	SCL2_H;
	I2C2_delay();	
	SCL2_L;
	I2C2_delay();	
}			

//IIC发送一个字节
//返回从机有无应答
//1，有应答
//0，无应答			  
void IIC2_Send_Byte(uint8_t txd)
{          
	uint8_t i=8;
	SDA2_OUT();
	while(i--)
	{
			SCL2_L;
			I2C2_delay();	
			if(txd&0x80)
					SDA2_H;
			else
					SDA2_L;
			txd<<=1;
			SCL2_H;
			I2C2_delay();	
	}
	SCL2_L;

} 	 

//读1个字节，ack=1时，发送ACK，ack=0，发送nACK   
uint8_t IIC2_Read_Byte(uint8_t ack)
{
	uint8_t i=8;
	uint8_t ReceiveByte=0;

	SDA2_IN();
	while(i--)
	{
			ReceiveByte<<=1;
			SCL2_L;
			I2C2_delay();	
			SCL2_H;
			I2C2_delay();	
			if(SDA2_read)
			{
					ReceiveByte|=0x01;
			}
	}
	if (ack)
		IIC2_Ack(); //发送ACK  
	else
		IIC2_NAck();//发送nACK
	return ReceiveByte;
}

//功能：按地址给指定寄存器写入一个字节
/////////////////////////////
void Single_Write2(uint8_t SlaveAddress,uint8_t REG_Address,uint8_t REG_data)		     //void
{
	IIC2_Start();
	IIC2_Send_Byte(SlaveAddress<<1);
	if(IIC2_Wait_Ack())
	{
		IIC2_Stop();
		return;
	}
	IIC2_Send_Byte(REG_Address);
	IIC2_Wait_Ack();
	IIC2_Send_Byte(REG_data);
	IIC2_Wait_Ack();
	IIC2_Stop();
}

//功能：按地址从指定寄存器读取一个字节
//备注：无
/////////////////////////////
uint8_t Single_Read2(uint8_t SlaveAddress,uint8_t REG_Address)
{  
	IIC2_Start();
	IIC2_Send_Byte(SlaveAddress<<1);
	if(IIC2_Wait_Ack())
	{
		IIC2_Stop();
		return 1;
	}
	IIC2_Send_Byte(REG_Address);
	IIC2_Wait_Ack();
	IIC2_Start();
	IIC2_Send_Byte(SlaveAddress<<1 | 0x01);
	IIC2_Wait_Ack();
	uint8_t REG_data= IIC2_Read_Byte(0);
	IIC2_Stop();
	return REG_data;
}	

//功能：按地址从指定寄存器读取多个字节
//备注：无
/////////////////////////////
void I2C_Read2(uint8_t addr, uint8_t reg, uint8_t len, uint8_t *buf)
{
	IIC2_Start();
	IIC2_Send_Byte(addr<<1);
	if(IIC2_Wait_Ack())
	{
		IIC2_Stop();
		return;
	}
	IIC2_Send_Byte(reg);
	IIC2_Wait_Ack();

	IIC2_Start();
	IIC2_Send_Byte(addr<<1 | 0x01);
	IIC2_Wait_Ack();
	while(len)
	{
		if(len == 1)
		{
			*buf = IIC2_Read_Byte(0);
		}
		else
		{
			*buf = IIC2_Read_Byte(1);
		}
		buf++;
		len--;
	}
	IIC2_Stop();
}

