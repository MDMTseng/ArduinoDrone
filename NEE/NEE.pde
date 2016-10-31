
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
    return (1/( 1 + Math.pow(Math.E,(-1*x))))-0.5;
  }
  
  public double d_exciteF(double sigmoid_var) {
    sigmoid_var+=0.5;
    return sigmoid_var*(1-(sigmoid_var));
  }
}

class s_neuron_net{
  ArrayList <s_neuron[]> ns;
  s_neuron input[] =new s_neuron[1];
  s_neuron hidden[] =new s_neuron[5];
  s_neuron hidden2[] =new s_neuron[5];
  s_neuron output[] =new s_neuron[1];
  
  s_neuron_net()
  {
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
        hidden[i].add_pre_neuron(input[j],random(-1,1));
      }
    }
    ns.add(hidden);
    
    
    
    for(int i=0;i<hidden2.length;i++)
    {
      hidden2[i] = new s_neuron(1);
      for(int j=0;j<hidden.length;j++)
      {
        hidden2[i].add_pre_neuron(hidden[j],random(-1,1));
      }
    }
    ns.add(hidden2);
    
    
    for(int i=0;i<output.length;i++)
    {
      output[i] = new s_neuron(1);
      for(int j=0;j<hidden2.length;j++)
      {
        output[i].add_pre_neuron(hidden2[j],random(-1, 1));
      }
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
    if(Error.length!=layer.length)return null;
    
    float PErr[] = new float[layer[0].pre_neuron_L];
    
    for(int i=0;i<PErr.length;i++)PErr[i]=0;
    
    float lRate;
    float limit = 100/layer[0].pre_neuron_L;
    for (int i=0;i<Error.length;i++) {
      float dPdZ = Error[i];
      lRate = dPdZ*limit;
      if(lRate<0)lRate=-lRate;
      if(lRate>limit)lRate=limit;
      float dropO=(random(0.0, 1)>0.8)?1:0.5;
      lRate*=dropO;
      //System.out.printf("lRate:%f\n",lRate);
      float dZdY = (float)layer[i].d_exciteF(layer[i].latestVar);
      for (int j=0;j<layer[i].pre_neuron_L;j++)
      {
        float dYdW = layer[i].pre_neuron_list[j].latestVar;
        
        PErr[j]+=dPdZ*dZdY*layer[i].W[j];
        
        layer[i].W[j]+=dPdZ*dZdY*dYdW*lRate;
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
  
  void TestTrain(float InX[],float OuY[])
  {
    
    float expectedOut[]=new float[output.length];
    for(int i=0;i<10000;i++)
    {
      float maxErr=0;
      int maxErrIdx=-1;
      for(int j=0;j<InX.length;j++)
      {
        input[0].latestVar=InX[j];
        expectedOut[0]=OuY[j];
        
        this.calc();
        
        float ErrorPow=-calcError(expectedOut);
        if(ErrorPow>maxErr){
          maxErr=ErrorPow;
          maxErrIdx = j;
        }
        //System.out.printf("------Error:%f\n",ErrorPow);*/
        Train_S(expectedOut);
      }
      
      input[0].latestVar=InX[maxErrIdx];
      expectedOut[0]=OuY[maxErrIdx];
      this.calc();
      Train_S(expectedOut);
      
    }
    
    
    for(int j=0;j<InX.length;j++)
    {
      input[0].latestVar=InX[j];
      expectedOut[0]=OuY[j];
      
      this.calc();
      
      float ErrorPow=calcError(expectedOut);
      System.out.printf("------Error:%f\n",ErrorPow);
      this.printStruct();
      System.out.printf("------OuY[j]:%f\n",OuY[j]);
    
      System.out.printf("=========================\n\n");
    }
   
    
    
  }
  float TestTrainxx(float x)
  {
    input[0].latestVar=x;
    
    this.calc();
    return output[0].latestVar;
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

float InX[]=new float[50];
float OuY[]=new float[InX.length];
  
void setup() {
  size(640, 360);
  background(255);
  noLoop();
  
  
  for(int i=0;i<InX.length;i++)
  {
    InX[i]=0.4*i/InX.length;
    OuY[i]=(sin(InX[i]*15)+1)/15;//(i>(InX.length/5)&&i<(InX.length*4/5))? 0.4: 0;
  }
  
  nn.TestTrain(InX,OuY);
  
  
}

void draw() {
  strokeWeight(3);
  stroke(250);
  background(0);
  int hH=height/2;
  float preVar=0;
  for (int i = 0; i < width; i += 5) {
    float tmp=nn.TestTrainxx(i*0.5/width)*1000;
    line(i,preVar+hH,i+5,-tmp+hH);
    preVar=-tmp;
  }
  
  
  
  stroke(100);
  for (int i = 1; i < InX.length; i ++) {
    
    line(InX[i-1]*width/0.5,-OuY[i-1]*1000+hH,InX[i]*width/0.5,-OuY[i]*1000+hH);
  }
  
}