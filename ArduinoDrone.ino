
#include "MPU6050.hpp"
#include "ApproMath.hpp"
#include "Orientation_Fusion.hpp"
#include "MPU6050_DMP6/MPU6050_6Axis_MotionAppsT.h"

MPU6050 mpu;
bool dmpReady = false;  // set true if DMP init was successful
uint8_t packetSize;
void driveMotor(int pin,int16_t T)
{
  if(T<0)T=0;
  digitalWrite(pin, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(1);
  delayMicroseconds(T);
  digitalWrite(pin, LOW);    // turn the LED off by making the voltage LOW
}
void driveMotorS(int pin,int16_t T)
{
  if(T<0)T=0;
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

  
  setup_6050();

  for(i=0;i<7*1000/20;i++)
  {
    
    driveMotor(13,0);
    driveMotor(12,0);
    delay(19);
  }

  //while(1);
}

float controller(const OriFus_EulerAngle *euler_sys_Angle,const OriFus_EulerAngle *con_Angle)
{
  float e_roll = euler_sys_Angle->roll-con_Angle->roll;
  static float pre_e_Roll = e_roll;
  static float Inte_e_Roll = 0;
  Inte_e_Roll+=e_roll;
  if(Inte_e_Roll>10000)Inte_e_Roll=10000;
  else if(Inte_e_Roll<-10000)Inte_e_Roll=-10000;

  float Ts=0.01;
//1.4,3.7,0.7
//1.1,3.7,0.8
  float Pout = e_roll*1;
  float Iout = Inte_e_Roll*3.5*Ts;
  float Dout = (e_roll - pre_e_Roll)*0.7/Ts;
  pre_e_Roll=e_roll;
  return Pout+Dout+Iout;
}

unsigned long preLoop = 0;
void loop() {
  read_6050();
  
}

unsigned long XX=0;
// the loop function runs over and over again forever
const float RAD2DEG=180.0 / M_PI;

OriFus_EulerAngle control_Angle={25,0,0};
//volatile uint16_t dfdf[3000];
void GetNewIMUData(Quaternion *q)
{
  
      float ypr[3];           // [yaw, pitch, roll]   yaw/pitch/roll container and gravity vector
      static float period=0;
      unsigned long nowLoop= millis();
      static long preLoop=nowLoop;
      period=(0.8*period+0.2*(nowLoop-preLoop)/1000.0);
      preLoop= nowLoop; 

      //Serial.print(1/period);Serial.print(" ");
      
      mpu.dmpGetEuler(ypr, q);
      
      OriFus_EulerAngle euler_sys_Angle={0,0,0};
    
      euler_sys_Angle.yaw  =ypr[0] * 180/M_PI;
      euler_sys_Angle.pitch=ypr[1] * 180/M_PI;
      euler_sys_Angle.roll =ypr[2] * 180/M_PI;


      static float TestX=0;
      float CC=controller(&euler_sys_Angle,&control_Angle);
      int16_t QCC=CC;
      uint16_t thrust = 200;
      
      driveMotorS(13,thrust-QCC);
      driveMotorS(12,thrust+QCC);
      driveMotorS(11,thrust-QCC);
      driveMotorS(10,thrust+QCC);
      if(1)
      {
    
        char BUF[30];
        //Serial.print(1/period);Serial.print(" ");
        sprintf(BUF,"%03d  %4d %4d %4d",
        (int)(1/period),
        (int)(control_Angle.roll*100),
        (int)(QCC),
        (int)(euler_sys_Angle.roll*100));
        Serial.println(BUF);
        /*Serial.print((float)CC);Serial.print(" ");
        //Serial.print(euler_sys_Angle.pitch);Serial.print(" ");
        //Serial.print(euler_sys_Angle.roll);Serial.print(" ");
        //Serial.print(euler_sys_Angle.yaw);
        Serial.println();*/
      }

      /*if((XX&(1024-1))==1)
      {
        //control_Angle.roll=-control_Angle.roll;
        TestX=-TestX;
      }*/
      TestX=(sin(XX*3.14/180 /3)>0.97)?30:-30;;
      
      //control_Angle.roll=(sin(XX*3.14/180 /3)>0.97)?20:-20;//((XX*2)%1000)/10.0-50;
      control_Angle.roll=((XX%1000)/500.0-1)*30;
      XX++;
}


void read_6050() {
    uint8_t fifoBuffer[64]; // FIFO storage buffer
    // if programming failed, don't try to do anything
    if (!dmpReady) return;


    // reset interrupt flag and get INT_STATUS byte
    uint8_t mpuIntStatus = mpu.getIntStatus();

    // get current FIFO count
    uint16_t fifoCount = mpu.getFIFOCount();

    // check for overflow (this should never happen unless our code is too inefficient)
    if ((mpuIntStatus & 0x10) || fifoCount == 1024) {
        // reset so we can continue cleanly
        mpu.resetFIFO();
        Serial.println(F("FIFO overflow!"));

    // otherwise, check for DMP data ready interrupt (this should happen frequently)
    } else if (mpuIntStatus & 0x2){

      // wait for correct available data length, should be a VERY short wait
      while (fifoCount < packetSize) fifoCount = mpu.getFIFOCount();
      

      mpu.getFIFOBytes(fifoBuffer, packetSize);
      fifoCount -= packetSize;
      /*while(fifoCount>=packetSize){
        mpu.getFIFOBytes(fifoBuffer, packetSize);
        fifoCount -= packetSize;
      }*/

      
      Quaternion q;           // [w, x, y, z]         quaternion container
      mpu.dmpGetQuaternion(&q, fifoBuffer);
      GetNewIMUData(&q);
  }
}






void setup_6050() {
    // join I2C bus (I2Cdev library doesn't do this automatically)
    Wire.begin();
    Wire.setClock(400000); // 400kHz I2C clock. Comment this line if having compilation difficulties

    Serial.println(F("Initializing I2C devices..."));
    mpu.initialize();
    //pinMode(INTERRUPT_PIN, INPUT);

    // verify connection
    Serial.println(F("Testing device connections..."));
    Serial.println(mpu.testConnection() ? F("MPU6050 connection successful") : F("MPU6050 connection failed"));

    // load and configure the DMP
    Serial.println(F("Initializing DMP..."));
    uint8_t devStatus = mpu.dmpInitialize();
    mpu.setXGyroOffset(1);
    mpu.setYGyroOffset(13);
    mpu.setZGyroOffset(-6);
    mpu.setZAccelOffset(800);
    // make sure it worked (returns 0 if so)
    if (devStatus == 0) {
        // turn on the DMP, now that it's ready
        Serial.println(F("Enabling DMP..."));
        mpu.setDMPEnabled(true);
 
        // enable Arduino interrupt detection
        Serial.println(F("Enabling interrupt detection (Arduino external interrupt 0)..."));
        
        //attachInterrupt(digitalPinToInterrupt(INTERRUPT_PIN), dmpDataReady, RISING);
        
        uint8_t mpuIntStatus = mpu.getIntStatus();

        // set our DMP Ready flag so the main loop() function knows it's okay to use it
        Serial.println(F("DMP ready! Waiting for first interrupt..."));
        dmpReady = true;

        // get expected DMP packet size for later comparison
        packetSize = mpu.dmpGetFIFOPacketSize();
    } else {
        // ERROR!
        // 1 = initial memory load failed
        // 2 = DMP configuration updates failed
        // (if it's going to break, usually the code will be 1)
        Serial.print(F("DMP Initialization failed (code "));
        Serial.print(devStatus);
        Serial.println(F(")"));
    }
}

