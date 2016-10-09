#include <stdint.h>


#ifndef _APPRO_MATH_LIB_H_
#define _APPRO_MATH_LIB_H_
uint16_t appro_root2(uint32_t x);
uint16_t appro_root_T(uint16_t x);
uint16_t appro_atan(uint16_t x);
uint16_t appro_TableInterpolation(uint16_t *table, uint16_t tableL_log2 ,uint16_t x);
//return -32768~32767 => mapped range -180~180- degree
int16_t appro_atan2(int16_t y, int16_t x);


int16_t EulerAngleY(int16_t accelX,int16_t accelY,int16_t accelZ);
int16_t EulerAngleX(int16_t accelX,int16_t accelY,int16_t accelZ);

#endif
