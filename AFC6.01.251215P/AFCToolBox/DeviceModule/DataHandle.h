#ifndef _DATA_HANDLE_H_
#define _DATA_HANDLE_H_

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ConnectedIO_Base.h"
#define DLL_API  __declspec(dllexport)  
union IU32
{
	unsigned char c[4];
	float f32;
};

DLL_API unsigned char getCmdType();

DLL_API unsigned char getInportNum();

DLL_API unsigned char getOutportNum();

DLL_API void setInportNum();

DLL_API void setOutportNum();

DLL_API int AddDataToBlkSendBuffer(unsigned short blkInstName, int elem, float* src, unsigned char* dstBuffer);

DLL_API void AddDataToModelSendBuffer(int elem, unsigned char* srcBuffer);

DLL_API void GetDataFromRecvBufferByID(unsigned short blkInstName, int elem, float* dstBuffer);

DLL_API void SetDataByID(unsigned short blkID, int elem, float* srcBuffer);

DLL_API void AddStartCmdToSendBuffer();

DLL_API void AddNullToSendBuffer();

void GetDataFromEngine();

void GetDataFromRecvBufferByBLKID(unsigned short blkInstName, int elem, float* dstBuffer, uint8_t* Recv_buffer);

#endif // !_DATA_HANDLE_H_

