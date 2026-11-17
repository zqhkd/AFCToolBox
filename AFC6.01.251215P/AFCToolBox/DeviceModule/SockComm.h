#ifndef _SOCKCOMM_H
#define _SOCKCOMM_H

#include <stdio.h>
#include <stdlib.h>
#include <Winsock2.h>
#include <Windows.h>

#define MAX_LENGTH      255
#define CLIENT_MAX_NUM  40

extern SOCKET sockClient;
extern SOCKET sockSrv;

extern HANDLE bufferMutex;		// 令其能互斥成功正常通信的信号量句柄
extern SOCKET sockConn;		// 客户端的套接字
extern SOCKET clientSocketGroup[CLIENT_MAX_NUM];
extern int sock_num;

int Client_Init();

void Client_Term();

int Server_Init();

void Server_Term();

#endif // !_SOCKCOMM_H
