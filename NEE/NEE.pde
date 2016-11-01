
class s_neuron{
  public float latestVar;
  
  
  public int post_neuron_L;
  public s_neuron post_neuron_list[];
  public float W[];
  
  public int pre_neuron_L;
  public s_neuron pre_neuron_list[];
    
    
  s_neuron()
  {
    this(0);
  }
  s_neuron(int defaultNum)
  {
    pre_neuron_L = 0;
    post_neuron_L = 0;
    pre_neuron_list = new s_neuron[defaultNum];
    post_neuron_list = new s_neuron[defaultNum];
    W = new float[post_neuron_list.length];
  }
  
  void add_pre_neuron(s_neuron pre_neuron,float weight)
  {
    if(pre_neuron_list.length<(pre_neuron_L+1))
    {
      float oldW[] = W;
      s_neuron oldList[] = pre_neuron_list;
      pre_neuron_list = new s_neuron[oldList.length*2];//extend L
      W = new float[pre_neuron_list.length];//extend L
      
      for(int i=0;i<pre_neuron_L;i++)
      {
        pre_neuron_list[i]=oldList[i];
        W[i]=oldW[i];
      }
      oldList = null;//clean
      oldW = null;
    }
    pre_neuron_list[pre_neuron_L]=pre_neuron;//append
    pre_neuron.add_post_neuron(this);
    W[pre_neuron_L]=weight;
    pre_neuron_L++;
  }
  
  void aggregateValue()
  {
    if(pre_neuron_L == 0)return;
    latestVar = 0;
    for(int i=0;i<pre_neuron_L;i++)
    {
      latestVar+=pre_neuron_list[i].latestVar*W[i];
    }
    latestVar=(float)exciteF(latestVar);
  }
  protected void add_post_neuron(s_neuron post_neuron)
  {
    if(post_neuron_list.length<(post_neuron_L+1))
    {
      s_neuron oldList[] = post_neuron_list;
      post_neuron_list = new s_neuron[oldList.length*2];//extend L
      
      for(int i=0;i<post_neuron_L;i++)
      {
        post_neuron_list[i]=oldList[i];
      }
      oldList = null;//clean
    }
    post_neuron_list[post_neuron_L]=post_neuron;//append
    post_neuron_L++;
  }
  public double exciteF(double x) {
    return (1/( 1 + Math.pow(Math.E,(-1*x))))*2-1;
  }
  
  public double d_exciteF(double sigmoid_var) {
    
    sigmoid_var=(sigmoid_var+1)/2;
    return sigmoid_var*(1-(sigmoid_var))+0.05;
  }
}

class s_neuron_net{
  ArrayList <s_neuron[]> ns;
  s_neuron ones[]=new s_neuron[3];
  s_neuron input[] =new s_neuron[1];
  s_neuron hidden[] =new s_neuron[5];
  public s_neuron hidden2[] =new s_neuron[5];
  public s_neuron output[] =new s_neuron[1];
  
  float XRand()
  {
    float rand=random(0,1);
    return random(0,1)>0.5?rand:-rand;
  }
  s_neuron_net()
  {
    
    for(int i=0;i<ones.length;i++)
    {
      ones[i] = new s_neuron(1);
      ones[i].latestVar = 1;
    }
    
    
    
    ns = new ArrayList <s_neuron[]>();
    
    for(int i=0;i<input.length;i++)
    {
      input[i] = new s_neuron(1);
      input[i].latestVar = 1;
    }
    ns.add(input);
    
    
    for(int i=0;i<hidden.length;i++)
    {
      hidden[i] = new s_neuron(1);
      for(int j=0;j<input.length;j++)
      {
        hidden[i].add_pre_neuron(input[j],XRand());
      }
      hidden[i].add_pre_neuron(ones[0],XRand());
    }
    ns.add(hidden);
    
    
    
    for(int i=0;i<hidden2.length;i++)
    {
      hidden2[i] = new s_neuron(1);
      for(int j=0;j<hidden.length;j++)
      {
        hidden2[i].add_pre_neuron(hidden[j],XRand());
      }
      hidden2[i].add_pre_neuron(ones[1],XRand());
    }
    ns.add(hidden2);
    
    
    for(int i=0;i<output.length;i++)
    {
      output[i] = new s_neuron(1);
      for(int j=0;j<hidden2.length;j++)
      {
        output[i].add_pre_neuron(hidden2[j],XRand());
      }
      output[i].add_pre_neuron(ones[2],XRand());
    }
    ns.add(output);
    
  }
  
  float [] Train_1(s_neuron layer[],float Error[])
  {
    //     Y=XW 
    // X -W--> |Sig| ->Z
    //                 expect output d  
    //                 P=-0.5*(d-Z)^2
    //
    //dP/dW = dP/dZ* dZ/dY*dY/dW
    //
    //dP/dZ = d-Z
    //dZ/dY = Sigmoid(Y)'
    //dY/dW = X
    
    //System.out.printf("Error.length %d  layer.length %d",Error.length,layer.length);
    if(Error.length!=layer.length)return null;
    
    float PErr[] = new float[layer[0].pre_neuron_L-1];
    
    for(int i=0;i<PErr.length;i++)PErr[i]=0;
    
    float lRate;
    float limit = 5/layer[0].pre_neuron_L;
    for (int i=0;i<Error.length;i++) {
      float dPdZ = Error[i];
      
      lRate = dPdZ*limit;
      if(lRate<0)lRate=-lRate;
      if(lRate>limit)lRate=limit;
      float dropO=1;//random(0, 1)>0.005? 1:0.4;
      lRate=limit*dropO;//(float)Math.log(limit*dropO+1);
      
      
      float dZdY = (float)layer[i].d_exciteF(layer[i].latestVar);
      for (int j=0;j<layer[i].pre_neuron_L;j++)
      {
        float dYdW = layer[i].pre_neuron_list[j].latestVar;
        
        float updateWVar = dPdZ*dZdY*dYdW*lRate;
        
        if(j!=layer[i].pre_neuron_L-1)
        {
          PErr[j]+=dPdZ*dZdY*(layer[i].W[j]);
        }
        else
        {
          updateWVar/=2;
        }
        layer[i].W[j]+=updateWVar;
        
      }
    }
    return PErr;
  }
  
  void Train_S(float expected_output[])
  {
    if(output.length!=expected_output.length)return;
    float Error[] = new float[expected_output.length];
    for (int i=0;i<Error.length;i++)
    {
      Error[i] = expected_output[i] - output[i].latestVar;
    }
    
    
    
    for (int i=this.ns.size()-1;i!=0;i--)
    {
      
      Error = Train_1(this.ns.get(i),Error);
    }
    
  }
  
  
  void calc()
  {
    //System.out.printf(">>W>> ");
    int x=0;
    for (s_neuron[] layer : this.ns) {
      for (int i=0;i<layer.length;i++)
      {
        /*for (int j=0;j<layer[i].pre_neuron_L;j++)
        {
          System.out.printf("%f ",layer[i].W[j]);
          
        }*/
        layer[i].aggregateValue();
      }
      x++;
    }
    //System.out.printf("\n");
  }
  
  float calcError(float expected_output[])
  {
    float out=0;
    for (int i=0;i<expected_output.length;i++)
    {
      float tmp = expected_output[i] - output[i].latestVar;
      
      out += tmp*tmp;
    }
    return -out/2;
    
  }
  
  float TestTrain(float InX[],float OuY[],int iter)
  {
    float maxErr=0;
    float expectedOut[]=new float[output.length];
    for(int i=0;i<iter;i++)
    {
      maxErr=0;
      int maxErrIdx=InX.length/2;
      for(int j=0;j<InX.length;j++)
      {
        int idx=i;//(int)Math.floor(random(0,InX.length-0.0001));
        input[0].latestVar=InX[idx];
        expectedOut[0]=OuY[idx];
        
        this.calc();
        
        float ErrorPow=-calcError(expectedOut);
        if(ErrorPow>maxErr){
          maxErr=ErrorPow;
          maxErrIdx = idx;
        }
        //System.out.printf("------Error:%f\n",ErrorPow);*/
        Train_S(expectedOut);
      }
     
      for(int j=0;j<0;j++)
      {
        
        input[0].latestVar=InX[maxErrIdx];
        expectedOut[0]=OuY[maxErrIdx];
        this.calc();
        Train_S(expectedOut);
      }
    }
    
    return -maxErr;
    
   /* for(int j=0;j<InX.length;j++)
    {
      input[0].latestVar=InX[j];
      expectedOut[0]=OuY[j];
      
      this.calc();
      
      float ErrorPow=calcError(expectedOut);
      System.out.printf("------Error:%f\n",ErrorPow);
      this.printStruct();
      System.out.printf("------OuY[j]:%f\n",OuY[j]);
    
      System.out.printf("=========================\n\n");
    }*/
   
    
    
  }
  void SetCalcNeuronInputData(float x)
  {
    
    input[0].latestVar=x;
    
    this.calc();
  }
  
  void printOut()
  {
    for(int i=0;i<output.length;i++)
    {
      System.out.printf("[%2d]:%f ",i,output[i].latestVar);
    }
    System.out.printf("\n");
  }
  
  
  void printStruct()
  {
    System.out.printf("\ninput::\n");
    for(int i=0;i<input.length;i++)
    {
      System.out.printf("[%2d]:%f  ",i,input[i].latestVar);
    }
    System.out.printf("\nhidden::\n");
    for(int i=0;i<hidden.length;i++)
    {
      System.out.printf("[%2d]:%f ",i,hidden[i].latestVar);
    }
    System.out.printf("\nhidden2::\n");
    for(int i=0;i<hidden2.length;i++)
    {
      System.out.printf("[%2d]:%f ",i,hidden2[i].latestVar);
    }
    System.out.printf("\noutput::\n");
    for(int i=0;i<output.length;i++)
    {
      System.out.printf("[%2d]:%f ",i,output[i].latestVar);
    }
    System.out.printf("\n");
  }
  
}


s_neuron_net nn = new s_neuron_net();

float InX[]=new float[70];
float OuY[]=new float[InX.length];
  
void setup() {
  size(640, 360);
  background(255);
  //noLoop();
  
  
  
  for(int i=0;i<InX.length;i++)
  {
    InX[i]=0.5*i/InX.length;
    OuY[i]=(i>(InX.length/6)&&i<(InX.length*5/6))?sin(InX[i]*InX[i]*150-TrainCount/7000.0)*0.4+0.4: 0;//(i>(InX.length/5)&&i<(InX.length*4/5))?(InX[i]-0.2)*4: 0;
  }
  
  
}

int TrainCount=0;
void draw() {
  strokeWeight(3);
  background(0);
  int hH=height/2;
  
  
  float err=nn.TestTrain(InX,OuY,50);
  TrainCount+=50;
  
  float preVar_hidden[]=new float[nn.hidden.length];
  
  float preVar_hidden2[]=new float[nn.hidden2.length];
  float preVar=0;
  for (int i = 0; i < width; i += 5) {
    nn.SetCalcNeuronInputData(i*0.5/width);
    
    float tmp;
    for(int n=0;n<preVar_hidden.length;n++)
    {
      //stroke((n+5)*255/(preVar_hidden.length+5),0,0);
      stroke(255,0,0,129);
      tmp=nn.hidden[n].latestVar*100;
      line(i,preVar_hidden[n]+hH,i+5,-tmp+hH);
      preVar_hidden[n]=-tmp;
    }
    
    for(int n=0;n<preVar_hidden2.length;n++)
    {
      //stroke((n+5)*255/(preVar_hidden.length+5),0,0);
      stroke(0,255,255,129);
      tmp=nn.hidden2[n].latestVar*100;
      line(i,preVar_hidden2[n]+hH,i+5,-tmp+hH);
      preVar_hidden2[n]=-tmp;
    }
    
    stroke(250);
    tmp=nn.output[0].latestVar*100;
    line(i,preVar+hH,i+5,-tmp+hH);
    preVar=-tmp;
  }
  
  
  
  stroke(100);
  for (int i = 1; i < InX.length; i ++) {
    line(InX[i-1]*width/0.5,-OuY[i-1]*100+hH,InX[i]*width/0.5,-OuY[i]*100+hH);
  }
  
  System.out.printf("ERR:%1.5f C:%05d\n",err,TrainCount);
  if(err>-0.005)noLoop();
}