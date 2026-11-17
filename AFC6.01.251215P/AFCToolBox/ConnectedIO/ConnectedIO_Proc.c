#include "ConnectedIO_Proc.h"

uint8_t Recv_buffer[MAX_LENGTH] = { 0 };
uint8_t Send_buffer[MAX_LENGTH] = { 0 };
int InportCnt = 0;
int OutportCnt = 0;
uint8_t cmdType = 0x00;
extern float a;
int pSendNum;
int cnt = 0;
void ConnectedIOProc(void)
{
 while(cmdType != START_CMD && cmdType != NOTIFY_DATA )
 {
     memset(Recv_buffer, 0, MAX_LENGTH);
     HAL_UART_Receive(&huart5, Recv_buffer, MAX_LENGTH, 50);
     cmdType = getCmdType();
 }

 InportCnt = 5;
 OutportCnt = 2;
 setInportNum();
 setOutportNum();

 memset(Send_buffer, 0, MAX_LENGTH);

 //AD
 struct Block AD_blk;
 AD_blk.blkInstname = AD;
 AD_blk.elem = 3;
 float AD_array[3] = {0};
 AD_array[0] = getADSampleData(0);
 AD_array[1] = getADSampleData(1);
 AD_array[2] = getADSampleData(2);
 SetDataByInstname(AD_blk.blkInstname, AD_blk.elem, AD_array);

 //AdSample
 struct Block AdSample_blk;
 AdSample_blk.blkInstname = AdSample;
 AdSample_blk.elem = 3;
 float AdSample_array[3] = {0};
 AdSample_array[0] = getADSampleData(0);
 AdSample_array[1] = getADSampleData(1);
 AdSample_array[2] = getADSampleData(2);
 SetDataByInstname(AdSample_blk.blkInstname, AdSample_blk.elem, AdSample_array);

 //AdSample1
 struct Block AdSample1_blk;
 AdSample1_blk.blkInstname = AdSample1;
 AdSample1_blk.elem = 3;
 float AdSample1_array[3] = {0};
 AdSample1_array[0] = getADSampleData(0);
 AdSample1_array[1] = getADSampleData(1);
 AdSample1_array[2] = getADSampleData(2);
 SetDataByInstname(AdSample1_blk.blkInstname, AdSample1_blk.elem, AdSample1_array);

 //AdSample2
 struct Block AdSample2_blk;
 AdSample2_blk.blkInstname = AdSample2;
 AdSample2_blk.elem = 3;
 float AdSample2_array[3] = {0};
 AdSample2_array[0] = getADSampleData(0);
 AdSample2_array[1] = getADSampleData(1);
 AdSample2_array[2] = getADSampleData(2);
 SetDataByInstname(AdSample2_blk.blkInstname, AdSample2_blk.elem, AdSample2_array);

 //AdSample3
 struct Block AdSample3_blk;
 AdSample3_blk.blkInstname = AdSample3;
 AdSample3_blk.elem = 3;
 float AdSample3_array[3] = {0};
 AdSample3_array[0] = getADSampleData(0);
 AdSample3_array[1] = getADSampleData(1);
 AdSample3_array[2] = getADSampleData(2);
 SetDataByInstname(AdSample3_blk.blkInstname, AdSample3_blk.elem, AdSample3_array);

 //SimuComOut1
 struct Block SimuComOut1_blk;
 SimuComOut1_blk.blkInstname = SimuComOut1;
 SimuComOut1_blk.elem = 1;
 float SimuComOut1_array[1] = {0};
 GetDataFromRecvBufferByInstname(SimuComOut1_blk.blkInstname, SimuComOut1_blk.elem, SimuComOut1_array);
 setSimuComOutData(SimuComOut1_array[0]);

 //SimuComOut2
 struct Block SimuComOut2_blk;
 SimuComOut2_blk.blkInstname = SimuComOut2;
 SimuComOut2_blk.elem = 1;
 float SimuComOut2_array[1] = {0};
 GetDataFromRecvBufferByInstname(SimuComOut2_blk.blkInstname, SimuComOut2_blk.elem, SimuComOut2_array);
 setSimuComOutData(SimuComOut2_array[0]);

 if(InportCnt == 0)
 {
 AddNullToSendBuffer();
 }

 setMsgLen();
 if(cnt == 0)
 {
     HAL_UART_Transmit_DMA(&SimuCom_tx, Send_buffer, MAX_LENGTH);
 }
 else{
     HAL_UART_Transmit_DMA(&SimuCom_tx, Send_buffer, pSendNum + 5);
}
 pSendNum = 0;
 cmdType = 0x00;
 cnt++;
}
