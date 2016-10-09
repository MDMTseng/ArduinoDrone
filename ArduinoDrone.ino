
#include "MPU6050.hpp"
#include "ApproMath.hpp"
#include "Orientation_Fusion.hpp"

void driveMotor(int pin,uint16_t T)
{
  digitalWrite(pin, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(1);
  delayMicroseconds(T);
  digitalWrite(pin, LOW);    // turn the LED off by making the voltage LOW
}
void driveMotorS(int pin,uint16_t T)
{
  if(T>700)T=700;
  digitalWrite(pin, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(1);
  delayMicroseconds(T);
  digitalWrite(pin, LOW);    // turn the LED off by making the voltage LOW
}
// the setup function runs once when you press reset or power the board
void setup() {
  Serial.begin(115200);
  // initialize digital pin 13 as an output.
  pinMode(13, OUTPUT);
  pinMode(12, OUTPUT);


  int16_t i;

  

  MPU6050_Init(NULL, NULL);
  

  /*for(i=0;i<15*1000/20;i++)
  {
    
    driveMotor(13,1000);
    driveMotor(12,01000);
    delay(19);
  }*/
  
  for(i=0;i<1*1000/20;i++)
  {
    
    driveMotor(13,0);
    driveMotor(12,0);
    delay(19);
  }

  //while(1);
}

int16_t controller(const OriFus_EulerAngle *euler_sys_Angle)
{
  float e_roll = euler_sys_Angle->roll-0;
  static float pre_e_Roll = e_roll;
  static float Inte_e_Roll = 0;
  Inte_e_Roll+=e_roll/100;
  if(Inte_e_Roll>100)Inte_e_Roll=100;
  else if(Inte_e_Roll<-100)Inte_e_Roll=-100;

  
  /*float Pout = e_roll*4;
  float Dout = (e_roll - pre_e_Roll)*300;
  float Iout = Inte_e_Roll*5;*/
  float Pout = e_roll*6.5;
  float Dout = (e_roll - pre_e_Roll)*300;
  float Iout = Inte_e_Roll*0;
  pre_e_Roll=e_roll;
  return Pout+Dout+Iout;
}


unsigned long XX=0;
// the loop function runs over and over again forever
const float RAD2DEG=180.0 / M_PI;
OriFus_EulerAngle euler_sys_Angle={0,0,0};
//volatile uint16_t dfdf[3000];
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


  int16_t CC=controller(&euler_sys_Angle);
  uint16_t thrust = 600;
  
  driveMotorS(13,thrust-CC);
  driveMotorS(12,thrust+CC);
  driveMotorS(11,200-euler_sys_Angle.roll*4);
  driveMotorS(10,200+euler_sys_Angle.roll*4);
  if((XX&(32-1))==1)
  {
    Serial.print(1/period);Serial.print(" ");
    Serial.print((float)CC);Serial.print(" ");
    //Serial.print(euler_sys_Angle.pitch);Serial.print(" ");
    //Serial.print(euler_sys_Angle.roll);Serial.print(" ");
    //Serial.print(euler_sys_Angle.yaw);
    Serial.println();
  }
  delay(1);
}
