
#ifndef _ORI_FUS_LIB_H_
#define _ORI_FUS_LIB_H_

typedef struct __OriFus_EulerAngle
{
  float pitch;
  float roll;
  float yaw;
}OriFus_EulerAngle;



inline float OriFus_EulerAngle_Pitch(int16_t accelX,int16_t accelY,int16_t accelZ);
inline float OriFus_EulerAngle_Roll(int16_t accelX,int16_t accelY,int16_t accelZ);


void OriFus_EulerAngle_Conv(OriFus_EulerAngle* eulerAngle,int16_t accelX,int16_t accelY,int16_t accelZ);
void OriFus_ComplementaryFilter(OriFus_EulerAngle* sys_eulerAngle,const OriFus_EulerAngle* acc_eulerAngle, const OriFus_EulerAngle* gyro_Angle) ;



#endif
