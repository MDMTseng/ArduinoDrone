
#include <Wire.h>
#include "mArduCAM_OV2640.hpp"

mArduCAM_OV2640 cam_2MP;
void setup() {
  Wire.begin();        // join i2c bus (address optional for master)
  Serial.begin(9600);  // start serial for output
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

/*
  if (myCAM.get_bit(ARDUCHIP_TRIG, CAP_DONE_MASK))
  {
    Serial.println(F("ACK CMD CAM Capture Done."));
    read_fifo_burst(myCAM);
    //Clear the capture done flag
    myCAM.clear_fifo_flag();
  }*/
 delay(1000);
}

void printfx(const char *format, ...)
{
  char buf[200];
  va_list ap;
    va_start(ap, format);
    vsnprintf(buf, sizeof(buf), format, ap);
    Serial.print(buf);
    va_end(ap);
}
