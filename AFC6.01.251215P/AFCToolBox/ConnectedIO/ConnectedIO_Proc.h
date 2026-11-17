#ifndef _CONNECTED_IO_PROC_H_
#define _CONNECTED_IO_PROC_H_

#include "ADSample.h"
#include "SimuOut.h"
#include "usart.h"
#include "SerialProto.h"
#include <stdlib.h>
#define SimuCom_rx  huart5
#define SimuCom_tx  huart5

void ConnectedIOProc(void);

#endif
