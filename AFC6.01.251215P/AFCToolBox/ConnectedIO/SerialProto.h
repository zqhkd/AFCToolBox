#ifndef _SERIAL_PROTO_H_
#define _SERIAL_PROTO_H_

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "IO_Buffer.h"

union IU32
{
	unsigned char c[4];
	float f32;
};

unsigned char getCmdType(void);

unsigned char getMsgLen(void);

unsigned char setMsgLen(void);

unsigned char getInportNum(void);

unsigned char getOutportNum(void);

void setInportNum(void);

void setOutportNum(void);

int AddDataToBlkSendBuffer(unsigned short blkInstName, int elem, float* src, unsigned char* dstBuffer);

void AddDataToModelSendBuffer(int elem, unsigned char* srcBuffer);

void GetDataFromRecvBufferByInstname(unsigned short blkInstName, int elem, float* dstBuffer);

void SetDataByInstname(unsigned short blkInstName, int elem, float* srcBuffer);

void AddStartCmdToSendBuffer(void);

void AddNullToSendBuffer(void);

#endif // !_SERIAL_PROTO_H_

