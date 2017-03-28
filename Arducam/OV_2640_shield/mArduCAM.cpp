#include "mArduCAM.hpp"
#include <Wire.h>
#include <SPI.h>


int mArduCAM_proto::I2C_WArr(byte devAddr,const byte *dat,int datL)
{
  int ret=0;
  Wire.beginTransmission(devAddr);
  byte i=0;
  ret=Wire.write(dat,datL);
  if(ret!=datL)ret=-1;//error,but endTransmission would return error as well
  else ret=0;
  if ((ret=Wire.endTransmission())!=0)
  {
    return ret;
  }
  return 0;
}
int mArduCAM_proto::I2C_RArr(byte devAddr,byte *read_buff,size_t readL)
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
int mArduCAM_proto::I2C_R8bAd8bVa(byte devAddr,byte addr, byte *rd)
{
  byte buff[1]={addr};
  I2C_WArr(devAddr,buff,1);
  return I2C_RArr( devAddr,rd,1);
}

int mArduCAM_proto::I2C_W8bAd8bVa(byte devAddr,byte addr,byte value)
{
  byte buf[]={addr,value};
  return I2C_WArr(devAddr,buf,sizeof(buf));
}

  // Write 8 bit values to 8 bit register address
int mArduCAM_proto::I2C_WRegSet_PROGMEM_8b(byte devAddr,const struct sensor_reg *reg_set,int reg_setL )
{
  
  
    int err = 0;
    uint8_t reg_addr = 0;
    uint8_t reg_val = 0;
    const struct sensor_reg *next = reg_set;
    while ((reg_addr != 0xff) | (reg_val != 0xff))
    {
      reg_addr = (uint8_t)pgm_read_word(&next->reg);
      reg_val = (uint8_t)pgm_read_word(&next->val);
      err = I2C_W8bAd8bVa( devAddr,reg_addr,reg_val);
      if(err!=0)return err;
      next++;
    }
    return 0;
}



int mArduCAM_proto::SPI_Transfer(void *buf_io_swap, size_t bufL)
{
  SPI.transfer(buf_io_swap,bufL);
  return 0;
}

int mArduCAM_proto::SPI_Transfer(uint8_t *dat_io_swap)
{
  return SPI_Transfer(dat_io_swap,sizeof(*dat_io_swap));
}
int mArduCAM_proto::SPI_Transfer(uint16_t *dat_io_swap)
{
  return SPI_Transfer(dat_io_swap,sizeof(*dat_io_swap));
}
uint8_t mArduCAM_proto::SPI_Get8b(uint8_t addr)
{
  uint8_t dat[]={addr,0};
  SPI_Transfer(dat,sizeof(dat));
  return dat[1];
}








mArduCAM_proto::mArduCAM_proto()
{}



int mArduCAM_proto::Init()
{
  return 0; 
}
int mArduCAM_proto::flush_fifo(void)
{
  return -1;
}
int mArduCAM_proto::clear_fifo_flag(void )
{
  return -1;
}
int mArduCAM_proto::read_fifo_length(void )
{
  return 0;
}

int mArduCAM_proto::start_capture(void)
{
  return -1;
}





int mArduCAM_proto::get_vid_pid( uint8_t *vid, uint8_t *pid)
{
  return -1;
}

