#include <stdint.h>




uint16_t appro_root(uint32_t a_nInput)
{
    uint32_t op  = a_nInput;
    uint32_t res = 0;
    uint32_t one = 1uL << (sizeof(uint32_t)*8-2); // The second-to-top bit is set: use 1u << 14 for uint16_t type; use 1uL<<30 for uint32_t type


    // "one" starts at the highest power of four <= than the argument.
    while (one > op)
    {
        one >>= 2;
        //printf("> ");
    }

    while (one != 0)
    {
        if (op >= res + one)
        {
            op = op - (res + one);
            res = res +  ( one<<1);
        }
        res >>= 1;
        one >>= 2;
    }

    /* Do arithmetic rounding to nearest integer */
    if (op > res)
    {
        res++;
    }
    return res;
}


//x = |   integer:tableL_log2    |  fraction:16-tableL_log2 (for interpolation) |
//IMPORTANT   ***** the real length of the table must be  2^tableL_log2 + 1 *****
uint16_t appro_TableInterpolation(uint16_t *table, uint8_t tableL_log2 ,uint16_t x){
  #define res_xRawBitNum (sizeof(uint16_t)*8 - tableL_log2)
  uint16_t res_x = (x &( (uint16_t)((uint16_t)-1)>>tableL_log2 ));
  uint16_t idx_x  = (x>> res_xRawBitNum );

  uint16_t L_val = table[idx_x];
  uint16_t H_val = table[idx_x+1];

  return L_val+ (((uint32_t)H_val - L_val)*(res_x)/ ((1<<res_xRawBitNum) -1));
}


#define TABLE_SQRT_L_LOG2  5
uint16_t TABLE_SQRT[(1<<TABLE_SQRT_L_LOG2)+1]=
  {0,11585,16384,20066,23171,25906,28378,30652,32768,34756,36636,38424,40133,41771,43348,44870,46341,47768,49152,50499,51811,53091,54340,55561,56756,57927,59074,60199,61304,62389,63455,64504,65535};
uint16_t appro_root_T(uint16_t a_nInput)
{
    uint16_t Mask4  = (uint16_t)((uint16_t)-1)<<(sizeof(uint16_t)*8-2);//1100000...
    uint16_t Mask16 = (uint16_t)((uint16_t)-1)<<(sizeof(uint16_t)*8-4);//1111000...
    uint16_t Mask64 = (uint16_t)((uint16_t)-1)<<(sizeof(uint16_t)*8-6);//1111110...


    uint8_t RShift=4;//scaling level, larger the value the small input will have lower error
    uint16_t MaskX  = (uint16_t)((uint16_t)-1)<<(sizeof(uint16_t)*8-(RShift*2));//1100000...
    while(RShift)
    {
        if((a_nInput&MaskX) == 0)
        {
            break;
        }
        MaskX<<=2;
        RShift--;
    }
    a_nInput<<=2*RShift;


    uint16_t res = appro_TableInterpolation(TABLE_SQRT,TABLE_SQRT_L_LOG2 ,a_nInput );
    /*if(RShift)
    {
        res=(res)>>(RShift-1);
        if(res&1)
            res=(res>>1)+1;
        else
            res=(res>>1);
    }*/

    res=(res>>RShift);

    return res;
}







#define TABLE_ATAN_L_LOG2  3
//max error 0.05 degree, RMSE=0.019955 in degree (in linear interpolation)
uint16_t TABLE_ATAN[(1<<TABLE_ATAN_L_LOG2)+1]=
  {0, 10397,20480,29990,38753,46684,53773,60062,65535};

/*
#define TABLE_ATAN_L_LOG2  4
//max error 0.009 degree, RMSE=0.0049092 in degree (in linear interpolation)
uint16_t TABLE_ATAN[(1<<TABLE_ATAN_L_LOG2)+1]=
  {0,5211,10381,15473,20451,25284,29949,34427,38703,42771,46628,50274,53714,56953,60000,62864,65535};
*/


//length has to be 8
//input 0~1 => 0~65535
//ouput 0~pi/4 => 0~65535
uint16_t appro_atan(uint16_t x){
  return appro_TableInterpolation(TABLE_ATAN,TABLE_ATAN_L_LOG2 , x);
}


int16_t appro_atan2(int16_t y, int16_t x){
  uint16_t abs_x = (x>0)? x:-x;
  uint16_t abs_y = (y>0)? y:-y;
  uint16_t atanProX;
  if(abs_x>abs_y)
  {
    //space range 0~45 value range 0~45 degree
    atanProX =  appro_TableInterpolation(TABLE_ATAN,TABLE_ATAN_L_LOG2 ,(uint32_t)abs_y * 65535/abs_x );
    //space range 0~90 value range 0~45 degree
    atanProX >>=1;
  }
  else
  {
    //space range 0~45 value range 0~45 degree
    atanProX = appro_TableInterpolation(TABLE_ATAN,TABLE_ATAN_L_LOG2 ,(uint32_t)abs_x * 65535/abs_y );
    //space range 0~90 value range 0~45 degree
    atanProX >>=1;
    //space range 0~90 value range 45~90 degree
    atanProX = ~atanProX;
  }
  //space range -180~180 value range 0~90 degree
  //           -32768(-180) ~ 32767(180-)
  int16_t atanProXs = atanProX>>2;

  if(x<0)
  {
    //exp 20deg => 160 deg = 180 - 20
    atanProXs = (32767) - atanProXs;
  }

  if(y<0)
  {
    //exp 160deg => -160 deg
    atanProXs =  - atanProXs;
  }
  return(atanProXs);
}




int int16_tDigit(int16_t input)
{
    uint8_t digit=0;
    while(input)
    {
        input>>=2;
        digit+=2;
    }
    return digit;
}





int16_t EulerAngleY(int16_t accelX,int16_t accelY,int16_t accelZ)
{
    uint32_t tarInput=(int32_t)accelY*accelY+(int32_t)accelZ*accelZ;
    uint32_t rootV;
#ifdef edfe
    int scaleS=(int16_tDigit(tarInput>>16)/2);

    uint16_t X2Z2_scaled=tarInput>>(2*scaleS);
     rootV = (appro_root_T(X2Z2_scaled)<<scaleS)>>7;
    //

    if(rootV&1)
        rootV=(rootV>>1)+1;
    else
        rootV=(rootV>>1);
#else
    rootV = appro_root(tarInput);
#endif

    return appro_atan2(-accelX,rootV);
}
int16_t EulerAngleX(int16_t accelX,int16_t accelY,int16_t accelZ)
{
    return appro_atan2(accelY,accelZ);
}

