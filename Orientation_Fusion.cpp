#include <stdint.h>
#include <math.h>
#include <Arduino.h>
#include "Orientation_Fusion.hpp"

inline float OriFus_EulerAngle_Pitch(int16_t accelX,int16_t accelY,int16_t accelZ)
{
    return atan2(accelX,sqrt((int32_t)accelY*accelY+(int32_t)accelZ*accelZ));
}
inline float OriFus_EulerAngle_Roll(int16_t accelX,int16_t accelY,int16_t accelZ)
{
    return atan2(accelY,sqrt((int32_t)accelX*accelX+(int32_t)accelZ*accelZ));
    //return atan2(accelY,accelZ);
}

void OriFus_EulerAngle_Conv(OriFus_EulerAngle* eulerAngle,int16_t accelX,int16_t accelY,int16_t accelZ)
{
  eulerAngle->roll = OriFus_EulerAngle_Roll(accelX, accelY, accelZ);
  eulerAngle->pitch= OriFus_EulerAngle_Pitch(accelX, accelY, accelZ);
}

void OriFus_ComplementaryFilter(OriFus_EulerAngle* sys_eulerAngle,const OriFus_EulerAngle* acc_eulerAngle, const OriFus_EulerAngle* gyro_Angle) {
  
  float P_CompCoeff= 0.99;
  
  sys_eulerAngle->roll=
    P_CompCoeff*(sys_eulerAngle->roll+gyro_Angle->roll)+(1-P_CompCoeff)*(acc_eulerAngle->roll);
  
  sys_eulerAngle->pitch=
    P_CompCoeff*(sys_eulerAngle->pitch+gyro_Angle->pitch)+(1-P_CompCoeff)*(acc_eulerAngle->pitch);

  sys_eulerAngle->yaw=(sys_eulerAngle->yaw+gyro_Angle->yaw);

}
