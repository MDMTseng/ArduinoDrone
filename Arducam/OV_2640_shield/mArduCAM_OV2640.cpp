#include "mArduCAM_OV2640.hpp"


//#define DBUG_PRINT
int mArduCAM_OV2640::Init()
{
  int ret;
  ret = I2C_W8bAd8bVa(i2c_addr, 0xff, 0x01);
  if (ret != 0)return ret;
  ret = I2C_W8bAd8bVa(i2c_addr, 0x12, 0x80);
  if (ret != 0)return ret;
  delay(100);
  if (0)
  {
    /*I2C_WRegSet_PROGMEM_8b(i2c_addr,OV2640_JPEG_INIT,sizeof(OV2640_JPEG_INIT));
      I2C_WRegSet_PROGMEM_8b(i2c_addr,OV2640_YUV422,sizeof(OV2640_YUV422));
      I2C_WRegSet_PROGMEM_8b(i2c_addr,OV2640_JPEG,sizeof(OV2640_JPEG));
      I2C_W8bAd8bVa(i2c_addr,0xff, 0x01);
      I2C_W8bAd8bVa(i2c_addr,0x15, 0x00);
      I2C_WRegSet_PROGMEM_8b(i2c_addr,OV2640_320x240_JPEG,sizeof(OV2640_320x240_JPEG));
      //wrSensorReg8_8(0xff, 0x00);
      //wrSensorReg8_8(0x44, 0x32);*/
  }
  else
  {
    ret = I2C_WRegSet_PROGMEM_8b(i2c_addr, OV2640_QVGA, sizeof(OV2640_QVGA));
    if (ret != 0)return ret;
  }


  uint8_t vid, pid;
  get_vid_pid(&vid, &pid);
  if ((vid != 0x26 ) && (( pid != 0x41 ) || ( pid != 0x42 ))) {
    //Serial.println(F("ACK CMD Can't find OV2640 module!"));
    return -1;
  }

  return 0;
}


int mArduCAM_OV2640::start_capture(void)
{
  return I2C_W8bAd8bVa(i2c_addr, ARDUCHIP_FIFO, FIFO_CLEAR_MASK);
}
int mArduCAM_OV2640::flush_fifo(void)
{
  return I2C_W8bAd8bVa(i2c_addr, ARDUCHIP_FIFO, FIFO_START_MASK);
}
int mArduCAM_OV2640::clear_fifo_flag(void )
{
  return I2C_W8bAd8bVa(i2c_addr, ARDUCHIP_FIFO, FIFO_CLEAR_MASK);
}
uint32_t mArduCAM_OV2640::read_fifo_length(void )
{
  uint32_t len1, len2, len3, length = 0;
  len1 = SPI_Get8b(SPI_REG_FIFO_SIZE1);
  len2 = SPI_Get8b(SPI_REG_FIFO_SIZE2);
  len3 = SPI_Get8b(SPI_REG_FIFO_SIZE3) & 0x7f;
  length = ((len3 << 16) | (len2 << 8) | len1) & 0x07fffff;
  return length;
}


int mArduCAM_OV2640::set_fifo_burst_end()
{
  
  return 0;
}
int mArduCAM_OV2640::set_fifo_burst_begin(uint32_t *fifoL)
{
  SPI_CS_EN(1);
  int ret=0;
  do{
    uint32_t len = read_fifo_length();
  
    byte dat = SPI_REG_BURST_FIFO_READ;
    SPI_Transfer(&dat);
  
    if( len == 0 )
    {
      ret=-1;
      break;
    }
  
    //Find fifo header and depelete residue
    uint8_t temp = 0, temp_last = 0;
    temp=0;
    SPI_Transfer(&temp);
    len --;
    while ( len-- )
    {
      temp_last = temp;
      temp=0;
      SPI_Transfer(&temp);
      if ((temp == 0xD8) & (temp_last == 0xFF))
      {
        break;
      }
    }
  
    if( len == 0 )
    {
      ret=-1;
      break;
    }
  
  
    if(fifoL) 
      *fifoL=len;
    ret = 0;
  }while(0);
  
  SPI_CS_EN(0);
  return ret;
}

int mArduCAM_OV2640::fifo_burst_recv(byte* buff, int recvL)
{
  
  SPI_CS_EN(1);
  int ret= SPI_Transfer(buff,recvL);
  
  SPI_CS_EN(0);
  return ret;
}
int mArduCAM_OV2640::get_vid_pid( uint8_t *vid, uint8_t *pid)
{
  int ret = 0;
  if ((ret = I2C_W8bAd8bVa(i2c_addr, 0xff, 0x01)) != 0)return ret;
  if ((ret = I2C_R8bAd8bVa(i2c_addr, OV2640_CHIPID_HIGH, vid)) != 0)return ret;
  if ((ret = I2C_R8bAd8bVa(i2c_addr, OV2640_CHIPID_LOW, pid)) != 0)return ret;
  return 0;
}

mArduCAM_OV2640::mArduCAM_OV2640(int CS_PIN)
{
  i2c_addr = 0x30;
  SPI_INIT(CS_PIN);

}
