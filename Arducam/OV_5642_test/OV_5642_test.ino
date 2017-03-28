
#include <Wire.h>
#include "OV5642.h"

void setup() {
  Wire.begin();        // join i2c bus (address optional for master)
  Serial.begin(9600);  // start serial for output
}

void loop() {
 byte rdata[20];

 Serial.println(">>>");
 byte addr[]= { 0x47, 0x40,0x21 };
 I2C_W8Arr(OV5642_I2C_ADDR,addr,sizeof(addr));
 I2C_W8Arr(OV5642_I2C_ADDR,addr,sizeof(addr));
 I2C_W8Arr(OV5642_I2C_ADDR,addr,sizeof(addr));
 //I2C_R8Arr(OV5642_I2C_ADDR,rdata,1);
 
 Serial.println("EEE");

 delay(100);
}


byte I2C_W8Arr(byte devAddr,byte *dat,int datL)
{
  Wire.beginTransmission(devAddr);
  
  Serial.println(">>>");
  byte i=0;
  for ( i=0 ; i<datL ; i++ )
  {
    Wire.write(dat[i]);
  }
  Serial.println(">>>");
  if (Wire.endTransmission())
  {
    return 0;
  }
  Serial.println(">ss>>");
  return 1;
}
int I2C_R8Arr(byte devAddr,byte *read_buff,size_t readL)
{
  Wire.requestFrom(devAddr, readL);
  int i=0;
  for(i=0;i<readL;)
  {
    if (Wire.available())
    {
      read_buff[i]= Wire.read();
      i++;
    }
    else
    {
    }
  }
  
  return 0;
}

