#ifndef M_ARDU_CAM_HPP
#define M_ARDU_CAM_HPP

#include <arduino.h>


struct sensor_reg {
  uint16_t reg;
  uint16_t val;
};



struct SPI_reg {
  uint8_t addr;
  uint16_t val;
};

class mArduCAM_proto
{
  public:
  mArduCAM_proto();
  /*I2S*/
  int Init( void );
  int get_vid_pid( uint8_t *vid, uint8_t *pid);

  
  int flush_fifo(void);
  int clear_fifo_flag(void);
  int start_capture(void);

  /*SPI*/
  int read_fifo_length(void);

  
  /*
  uint8_t read_fifo(void);
  
  uint8_t read_reg(uint8_t addr);
  void write_reg(uint8_t addr, uint8_t data); 
  
  uint32_t read_fifo_length(void);
  void set_fifo_burst(void);
  
  void set_mode(uint8_t mode);
 
  uint8_t bus_write(int address, int value);
  uint8_t bus_read(int address);  
 
  void set_JPEG_size(uint8_t size);
  void set_format(byte fmt);
  
  void transferBytes(uint8_t * out, uint8_t * in, uint32_t size);
  
  protected:
  regtype *P_CS;
  regsize B_CS;
  byte m_fmt;
  byte sensor_model;*/
  static int I2C_WArr(byte devAddr,const byte *dat,int datL);
  static int I2C_W8bAd8bVa(byte devAddr,byte addr,byte value);
  static int I2C_WRegSet_PROGMEM_8b(byte devAddr,const struct sensor_reg *sreg_set,int reg_setL );
  static int I2C_RArr(byte devAddr,byte *read_buff,size_t readL);
  static int I2C_R8bAd8bVa(byte devAddr,byte addr, byte *rd);


  static int SPI_Transfer(void *buf, size_t bufL);
  static int SPI_Transfer(uint8_t *dat_io_swap);
  static int SPI_Transfer(uint16_t *dat_io_swap);
  static uint8_t SPI_Get8b(uint8_t addr);

  
  unsigned char i2c_addr;
};






#define ARDUCHIP_FIFO          0x04  //FIFO and I2C control
#define FIFO_CLEAR_MASK       0x01
#define FIFO_START_MASK       0x02
#define FIFO_RDPTR_RST_MASK     0x10
#define FIFO_WRPTR_RST_MASK     0x20



#define SPI_REG_FIFO_SIZE1        0x42  //Camera write FIFO size[7:0] for burst to read
#define SPI_REG_FIFO_SIZE2        0x43  //Camera write FIFO size[15:8]
#define SPI_REG_FIFO_SIZE3        0x44  //Camera write FIFO size[18:16]





#endif
