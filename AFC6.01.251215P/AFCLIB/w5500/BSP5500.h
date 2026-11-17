#ifndef _BSP_W5500_H_
#define _BSP_W5500_H_

#include "ACGCommonAPI.h"
#include "spi.h"
#include "wizchip_conf.h"
#include "stdbool.h"

#define SPI1_CS_GPIO_Port GPIOA
#define SPI1_CS_Pin GPIO_PIN_4
/*----------W5500复位引脚修改------------------------------------------------------------*/
/*----------复位引脚由CP3_C改为PC4-------------------------------------------------------*/
/*----------2025.10.23------------------------------------------------------------------*/
#define W5500_RST_PORT      GPIOC
//#define W5500_RST_PIN       GPIO_PIN_3
#define W5500_RST_PIN       GPIO_PIN_4

#define WLanNum   1   // 定义网口数量

void SPI_CrisEnter(void);
void SPI_CrisExit(void);

// 初始化网络端口，idxWLan为网络端口索引号，暂时仅有一个网络端口，暂未用
void initWLanOut(uint8_t idxWLan,char *ipAddress,char *localIpAddress, uint16_t destPort);	//w5500网口芯片初始换函数

void initWLanIn(uint8_t idxWLan,char *ipAddress,char *localIpAddress, uint16_t destPort,uint8_t dataSize);	//w5500网口芯片初始换函数

void writeWLan(uint8_t idxWLan,uint16_t iBytes,uint8_t iVal);

// 启动网络端口接收的监测线程
void vStartWLanRecvThread(uint8_t idxWLan);

// 从模型网口读取变量到模型端口(ReadMC模块)，供用户模型Simulink程序使用。
uint8_t readWLan(uint8_t idxWLan,uint8_t idxByte);

// tcp/ip的测试程序
void do_tcpc(bool flag);				//tcp-server，flag为0 -- 仅输出，为1 -- 收到数后再返回

// 检测W5500芯片是否存在
bool w5500_check_existence(void);

//void getW5500(void);
//void putW5500(void);
//void network_init(uint8_t *ethernet_buff, wiz_NetInfo *conf_info);
//void wiz_phy_link_check(void);
//uint8_t spi1_read_write_byte(uint8_t txdata);


//void  CS_L(void);
//void  CS_H(void); 
#endif 

