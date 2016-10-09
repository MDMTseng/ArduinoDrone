
#include "MPU6050.hpp"
#include "ApproMath.hpp"
#include "Orientation_Fusion.hpp"


// the setup function runs once when you press reset or power the board
void setup() {
  Serial.begin(115200);
  // initialize digital pin 13 as an output.
  pinMode(13, OUTPUT);


  int16_t i;

  

  MPU6050_Init(NULL, NULL);
  

  
  for(i=0;i<3*1000/20;i++)
  {
    
    digitalWrite(13, HIGH);   // turn the LED on (HIGH is the voltage level)
    delay(1);
    digitalWrite(13, LOW);    // turn the LED off by making the voltage LOW
    delay(19);
  }

  
}

void driveMotor(uint16_t T)
{
  if(T>200)T=200;
  digitalWrite(13, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(1);
  delayMicroseconds(15+T);
  digitalWrite(13, LOW);    // turn the LED off by making the voltage LOW
}

unsigned long XX=0;
// the loop function runs over and over again forever
const float RAD2DEG=180.0 / M_PI;
OriFus_EulerAngle euler_sys_Angle={0,0,0};
volatile uint16_t dfdf[3000];
unsigned long preLoop = 0;
void loop() {
  XX++;
  //dfdf[XX]=XX;
  unsigned long nowLoop= millis();
  static float period=0;
  period=(0.8*period+0.2*(nowLoop-preLoop)/1000.0);
  preLoop= nowLoop; 
  
  accel_t_gyro_union data;
  MPU6050_AquireRawData(&data);
  char BUF[300];

  OriFus_EulerAngle euler_acc_Angle;
  OriFus_EulerAngle_Conv(&euler_acc_Angle,data.value.x_accel,data.value.y_accel,data.value.z_accel);
  euler_acc_Angle.pitch*=RAD2DEG;
  euler_acc_Angle.roll*=RAD2DEG;
  euler_acc_Angle.yaw*=RAD2DEG;
  
  OriFus_EulerAngle euler_gyro_Angle;
  float gyroFactor = period/16.4;//16.4 is the sensitivity factor when MPU6050_GYRO_CONFIG=>0001 1000

  /*static float SUM=0;
  SUM+=data.value.z_gyro;*/

  euler_gyro_Angle.roll=((float)data.value.x_gyro-0.5)*gyroFactor;
  euler_gyro_Angle.pitch=((float)data.value.y_gyro-10.88)*gyroFactor;
  euler_gyro_Angle.yaw=((float)data.value.z_gyro-3.95)*gyroFactor;
  
  /*sprintf(BUF,"G:%d %d %d\n",
    data.value.x_accel,
    data.value.y_accel,
    data.value.z_accel);
  Serial.print(BUF);*/
  OriFus_ComplementaryFilter(&euler_sys_Angle,&euler_acc_Angle, &euler_gyro_Angle);

  driveMotor(100-euler_sys_Angle.roll*2);
  if((XX&(8-1))==1)
  {
    Serial.print(1/period);Serial.print(" ");
    Serial.print(euler_sys_Angle.pitch);Serial.print(" ");
    Serial.print(euler_sys_Angle.roll);Serial.print(" ");
    Serial.print(euler_sys_Angle.yaw);
    Serial.println();
  }
  delay(10);
}
