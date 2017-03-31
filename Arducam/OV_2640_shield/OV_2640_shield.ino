
#include <Wire.h>
#include "mArduCAM_OV2640.hpp"
#include "commonTools.h"

mArduCAM_OV2640 cam_2MP(53);
void setup() {
  Wire.begin();        // join i2c bus (address optional for master)
  Serial.begin(250000);  // start serial for output
  int ret=cam_2MP.Init();
  if(ret==0)
  {
    printfx("mArduCAM_OV2640 init success\n");
  }
  else
  {
    printfx("mArduCAM_OV2640 init failed: err: %d\n",ret);
  }

}



void loop() {
  int ret;
  cam_2MP.flush_fifo();
  cam_2MP.clear_fifo_flag();
  ret=cam_2MP.start_capture();
  
  if(ret==0)
  {
    printfx("mArduCAM_OV2640 start_capture success\n");
  }
  else
  {
    printfx("mArduCAM_OV2640 start_capture failed: err: %d\n",ret);
  }

  while (1)
  {
    byte trig= cam_2MP.SPI_Get8b(SPI_REG_ARDUCHIP_TRIG);
    
    printfx("trig:%x\n",trig);
    if(trig&SPI_REG_CAP_DONE_MASK)break;
    delay(1);
  }
  
  Serial.println(F("ACK CMD CAM Capture Done."));
  read_fifo_burst(cam_2MP);
  cam_2MP.clear_fifo_flag();

  delay(1000);
}
struct RGB565
{
  unsigned int R : 5;
  unsigned int G : 6;
  unsigned int B : 5;
};
char grayAscii[]="@%#*+=-:.     ";
int read_fifo_burst(mArduCAM_OV2640 myCAM)
{
  uint32_t length = 0;
  
  int ret = myCAM.set_fifo_burst_begin(&length);//Set fifo burst mode
  printfx(">>set_fifo_burst_begin ret:%d<<\n",ret);
  if(ret != 0 )return ret;

  byte buffer[200];
  uint32_t rest_len=length;
  uint16_t ccc=0;
  
  while ( rest_len )
  {
    int recvL = (rest_len < sizeof(buffer))?rest_len:sizeof(buffer);
    memset(buffer, 0, recvL);
    myCAM.fifo_burst_recv(buffer, recvL);
    //TODO: deal with pixel data

    /*if(ccc++==0)
      printfx(">>%lu<<\n",rest_len);*/
    struct RGB565 *tranBuf=(struct RGB565 *)buffer;
    int tranBufL=recvL/2;
    
    for(int i=0;i<tranBufL;i++)
    {
      byte g=tranBuf[i].R+tranBuf[i].G+tranBuf[i].B;
      g/=10;
      printfx("%c",grayAscii[g]);
      ccc++;
      if(ccc==320)
      {
        ccc=0;
        printfx("\n");
      }
    }

    //printfx(">>%03d<<\n",tranBuf[0].R+tranBuf[0].G+tranBuf[0].B);
    
    rest_len-=recvL;
  }

  myCAM.set_fifo_burst_end();
  return 1;
}



