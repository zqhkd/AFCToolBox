#ifndef _CONNECTEDIO_BASE_H_
#define _CONNECTEDIO_BASE_H_

#include "SockComm.h"
#include "DataHandle.h"

#define CONNECTEDIO
#define START_CMD 0x5F
#define FINISH_CMD 0x6F

#define BLK_GET_DATA 0x4D
#define	BLK_NOTIFY_DATA 0x1D
#define DATA_RECEIVED 0x2D

#define NOTIFY_DATA 0x6D
#define END_FLAG 0x7D

enum engine_status
{
	RUNNING = 0,
	STOPPED
};

#define UP
typedef unsigned char uint8_t;

typedef unsigned short uint16_t;

struct Block
{
	uint16_t ID; //实例名称
	int elem;//信号个数
};

uint8_t Recv_buffer[MAX_LENGTH];
uint8_t Send_buffer[MAX_LENGTH];

int InportCnt;
int OutportCnt;
int StartCmdFlag;
int errorFlag;

void GetDataFromEngine();

void ConnectedIOTerm();


#endif 
