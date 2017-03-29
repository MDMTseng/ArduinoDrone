#ifndef mARDUCAM_SPI_H
#define mARDUCAM_SPI_H
#include "mArduCAM.hpp"
#include <SPI.h>
#include <pins_arduino.h>
//#include <avr/pgmspace.h>


#define cbi(reg, bitmask) *reg &= ~bitmask
#define sbi(reg, bitmask) *reg |= bitmask

class mArduCAM_SPI
{
  public:


  
  static int SPI_Transfer(void *buf_io_swap, size_t bufL)
  {
    SPI.transfer(buf_io_swap,bufL);
    return 0;
  };
  
  static int SPI_Transfer(uint8_t *dat_io_swap)
  {
    return SPI_Transfer(dat_io_swap,sizeof(*dat_io_swap));
  };
  static int SPI_Transfer(uint16_t *dat_io_swap)
  {
    return SPI_Transfer(dat_io_swap,sizeof(*dat_io_swap));
  };
  static uint8_t SPI_Get8b(uint8_t addr)
  {
    uint8_t dat[]={addr,0};
    SPI_Transfer(dat,sizeof(dat));
    return dat[1];
  };

  protected:
  void SPI_CS_EN(uint8_t en)
  { //active low
    if (en)
      cbi(P_CS, B_CS);
    else
      sbi(P_CS, B_CS);
  }
  void SPI_INIT(int CS_PIN)
  {
    
    pinMode(CS_PIN, OUTPUT);
    P_CS  = portOutputRegister(digitalPinToPort(CS_PIN));
    B_CS  = digitalPinToBitMask(CS_PIN);
  }

  volatile uint8_t *P_CS;
  uint8_t B_CS;
};
#endif



