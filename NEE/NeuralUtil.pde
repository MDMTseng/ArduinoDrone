
class s_neuron{
  public float SumVar;
  public float latestVar;
  
  
  public int post_neuron_L;
  public s_neuron post_neuron_list[];
  public float W[];
  
  public int pre_neuron_L_BK;
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
  
  void SetDisable(boolean disable)
  {
    if(disable)
    {
      latestVar = 0;
      pre_neuron_L=0;
    }
    else
    {
      pre_neuron_L=pre_neuron_L_BK;
    }
  }
  int GetActual_pre_neuron_L()
  {
    return pre_neuron_L_BK;
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
    pre_neuron_L_BK=pre_neuron_L;
  }
  
  void aggregateValue()
  {
    if(pre_neuron_L == 0)return;
    latestVar = 0;
    SumVar = 0;
    for(int i=0;i<pre_neuron_L;i++)
    {
      SumVar+=pre_neuron_list[i].latestVar*W[i];
    }
    latestVar=(float)exciteF(SumVar);
  }
  
  
  float CosSimilarW(s_neuron node)
  {
    if(pre_neuron_L!=node.pre_neuron_L)
      return 0;
    float absW=0,absW2=0,XX=0;
    //CosSim = v1.*v2./(|v1||v2|)
    for(int i=0;i<pre_neuron_L;i++)
    {
      absW+=W[i]*W[i];
      absW2+=node.W[i]*node.W[i];
      XX+=node.W[i]*W[i];
    }
    absW=(float)Math.sqrt(absW);
    absW2=(float)Math.sqrt(absW2);
    
    XX = XX/(absW*absW2);
    absW=(absW>absW2)?absW/absW2:absW2/absW;
    return XX/absW;
  }
  
  float XSimilarW(s_neuron node)
  {
    if(pre_neuron_L!=node.pre_neuron_L)
      return 0;
    float absW=0,absW2=0,XX=1;
    //CosSim = v1.*v2./(|v1||v2|)
    for(int i=0;i<pre_neuron_L;i++)
    {
      absW=W[i]*W[i];
      absW2=node.W[i]*node.W[i];
      if(W[i]*node.W[i]<0)return 1000;
      XX*=(absW>absW2)?absW/absW2:absW2/absW;
    }
    
    return XX;
  }
  float rmsW()
  {
    float sumW=0;
    //CosSim = v1.*v2./(|v1||v2|)
    for(int i=0;i<pre_neuron_L;i++)
    {
      sumW+=W[i]*W[i];
    }
    return (float)Math.sqrt(sumW/pre_neuron_L);
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
    double slop=2*sigmoid_var*(1-(sigmoid_var));
    return (slop+0.2)/1.1;
  }
}

class s_neuron_net{
  ArrayList <s_neuron[]> ns;
  s_neuron ones[]=new s_neuron[4];
  s_neuron input[] =new s_neuron[1];
  s_neuron hidden[] =new s_neuron[3];
  public s_neuron hidden2[] =new s_neuron[12];
  public s_neuron hidden3[] =new s_neuron[12];
  public s_neuron output[] =new s_neuron[2];
  
  float XRand(float x1,float x2)
  {
    float rand=random(x1,1);
    return random(0,1)>x2?rand:-rand;
  }
  s_neuron_net(int netDim[])
  {
    
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
    
    s_neuron prelayer[]=input;
    s_neuron currentlayer[]=hidden;
    
    
    for(int i=0;i<currentlayer.length;i++)
    {
      currentlayer[i] = new s_neuron(1);
      for(int j=0;j<prelayer.length;j++)
      {
        currentlayer[i].add_pre_neuron(prelayer[j],XRand(0,0.5)*2);
      }
      currentlayer[i].add_pre_neuron(ones[0],XRand(0,0.5)*2);
    }
    ns.add(currentlayer);
    
    
    prelayer=hidden;
    currentlayer=hidden2;
    for(int i=0;i<currentlayer.length;i++)
    {
      currentlayer[i] = new s_neuron(1);
      for(int j=0;j<prelayer.length;j++)
      {
        currentlayer[i].add_pre_neuron(prelayer[j],XRand(0,0.5)*2);
      }
      currentlayer[i].add_pre_neuron(ones[1],XRand(0,0.5));
    }
    ns.add(currentlayer);
    
    
    
    prelayer=hidden2;
    currentlayer=hidden3;
    for(int i=0;i<hidden3.length;i++)
    {
      currentlayer[i] = new s_neuron(1);
      for(int j=0;j<prelayer.length;j++)
      {
        currentlayer[i].add_pre_neuron(prelayer[j],XRand(0,0.5)*2);
      }
      currentlayer[i].add_pre_neuron(ones[2],XRand(0,0.5));
    }
    ns.add(currentlayer);
    
    
    
    prelayer=hidden3;
    currentlayer=output;
    for(int i=0;i<output.length;i++)
    {
      currentlayer[i] = new s_neuron(1);
      for(int j=0;j<prelayer.length;j++)
      {
        currentlayer[i].add_pre_neuron(prelayer[j],XRand(0,0.5)*2);
      }
      currentlayer[i].add_pre_neuron(ones[3],XRand(0,0.5));
    }
    ns.add(currentlayer);
    
  }
  void TrimSimNode(s_neuron layer[])
  {
    
    if(layer[0].pre_neuron_L>2)
    for (int i=0;i<layer.length;i++)
    {
      //if(layer[i].rmsW()<1)continue;
      for (int j=i+1;j<layer.length;j++) 
      {
        //if(layer[j].rmsW()<1)continue;
        float CosSim=layer[i].CosSimilarW(layer[j]);
        float xSim=CosSim;
        xSim=(xSim-0.92)/(1-0.92);
        xSim=(xSim>0)?xSim:0;
        float absCos = xSim>0?xSim:-xSim;
        xSim=(float)Math.pow(absCos,1);
        float rand=random(0,1);
        if(xSim>rand)
        {
          System.out.printf(">>>:%f..%f..\n ",CosSim,xSim);
          for (int k=0;k<layer[j].GetActual_pre_neuron_L();k++)
          {
            System.out.printf("%f,%f  ",layer[j].W[k],layer[i].W[k]);
            layer[j].W[k]=(layer[i].W[k]+layer[j].W[k])/2;
            layer[i].W[k]= XRand(0,0.5);
          }
          System.out.printf("\n ");
          
          for (int k=0;k<layer[j].post_neuron_L;k++)
          {
            s_neuron pnode=layer[j].post_neuron_list[k];
            int n1_idx=-1,n2_idx=-1;
            for(int m=0;m<pnode.GetActual_pre_neuron_L()-1&&(n1_idx==-1||n2_idx==-1);m++)
            {
              if(layer[j]==pnode.pre_neuron_list[m])
                n1_idx = m;
              else if(layer[i]==pnode.pre_neuron_list[m])
                n2_idx = m;
            }
            pnode.W[n1_idx]+=(CosSim>0)?pnode.W[n2_idx]:-pnode.W[n2_idx];
            pnode.W[n2_idx]=XRand(0,0.5);
          }
        }
      }
        
    }
    
  }
  
  
  
    void TrimSimNode3(s_neuron layer[])
  {
    
    if(layer[0].pre_neuron_L>1)
    for (int i=0;i<layer.length;i++)
    {
      if(layer[i].rmsW()<1)continue;
      for (int j=i+1;j<layer.length;j++) 
      {
        //if(layer[j].rmsW()<1)continue;
        float CosSim=layer[i].CosSimilarW(layer[j]);
        float xSim=CosSim;
        xSim=(xSim-0.88)/(1-0.88);
        xSim=(xSim>0)?xSim:0;
        //float absCos = cosSim>0?cosSim:-cosSim;
        xSim=(float)Math.pow(xSim,1);
        float rand=random(0,1);
        if(xSim>rand)
        {
          System.out.printf("Die::Reborn...cs:%f..%f..\n ",CosSim,xSim);
          for (int k=0;k<layer[j].GetActual_pre_neuron_L();k++)
          {
            System.out.printf("%f,%f  ",layer[j].W[k],layer[i].W[k]);
            layer[j].W[k]=(layer[i].W[k]+layer[j].W[k])/2;
            layer[i].W[k]=layer[j].W[k]*(k%2==1?-1:1)*0.01;
          }
          System.out.printf("\n ");
          
          for (int k=0;k<layer[j].post_neuron_L;k++)
          {
            s_neuron pnode=layer[j].post_neuron_list[k];
            int n1_idx=-1,n2_idx=-1;
            for(int m=0;m<pnode.GetActual_pre_neuron_L()-1&&(n1_idx==-1||n2_idx==-1);m++)
            {
              if(layer[j]==pnode.pre_neuron_list[m])
                n1_idx = m;
              else if(layer[i]==pnode.pre_neuron_list[m])
                n2_idx = m;
            }
            pnode.W[n1_idx]+=pnode.W[n2_idx];
            pnode.W[n2_idx]=pnode.W[n2_idx]*-0.01;
          }
        }
      }
    }
  }
  
  //BufferL = Train_1(this.ns.get(i),Error,ErrorL,Buffer);
  int Train_1(s_neuron layer[],float Error[],int ErrorL,float Buffer[])
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
    if(ErrorL!=layer.length)return -1;
    
    //float PErr[] = new float[layer[0].pre_neuron_L-1];
    
    int BufferL=layer[0].pre_neuron_L-1;
    for(int i=0;i<BufferL;i++)Buffer[i]=0;
    
    float limit =0.03;
    float lRate=limit;
    
    
    
    float WAve =0;
    
    for (int i=0;i<ErrorL;i++) 
    {
     for (int j=0;j<layer[i].GetActual_pre_neuron_L()-1;j++)
      {
          float alphaX=0.999995;
          layer[i].W[j]=(layer[i].W[j]*alphaX-WAve*(1-alphaX));//+random(-0.001,0.001);
          //layer[i].W[j]*=alphaX;
          
      }
    }
    for (int i=0;i<ErrorL;i++) {
      float dPdZ = Error[i];
      
     /* lRate = dPdZ*limit;
      if(lRate<0)lRate=-lRate;
      float dropO=1;//random(0, 1)>0.005? 1:0.4;*/
      
     // lRate=limit;//*(random(0.5, 1.1));//(float)Math.log(limit*dropO+1);
      
      
      float dZdY = (float)layer[i].d_exciteF(layer[i].latestVar);
      float dPdY = dPdZ*dZdY;
      for (int j=0;j<layer[i].pre_neuron_L;j++)
      {
        float dYdW = layer[i].pre_neuron_list[j].latestVar;
        
        if(j!=layer[i].pre_neuron_L-1)
        {
          Buffer[j]+=dPdY*(layer[i].W[j]);
          WAve+=layer[i].W[j];
        }
        layer[i].W[j]+=dPdY*dYdW*lRate;
      }
    }
    WAve/=ErrorL*(layer[0].pre_neuron_L-1);
    
    
    
    return BufferL;
  }
  
  void Train_S(float expected_output[])
  {
    if(output.length!=expected_output.length)return;
    float Error[] = new float[50];
    int ErrorL=0;
    float Buffer[] = new float[50];
    int BufferL=0;
    
    ErrorL = output.length;
    for (int i=0;i<output.length;i++)
    {
      Error[i] = expected_output[i] - output[i].latestVar;
      //float absErr=Error[i]>0?Error[i]:-Error[i];
      //Error[i]=(float)Math.exp(absErr*absErr*absErr)/5*(Error[i]>0?1:-1);
    }
    
    for (int i=this.ns.size()-1;i!=0;i--)
    {
      BufferL = Train_1(this.ns.get(i),Error,ErrorL,Buffer);
      if(BufferL<=0)break;
      float TmpBuf[];
      TmpBuf=Buffer;
      Buffer=Error;
      Error=TmpBuf;
      
      int TmpBufL;
      TmpBufL=BufferL;
      BufferL=ErrorL;
      ErrorL=TmpBufL;
      
    }
    for (int i=this.ns.size()-2;i!=0;i--)
    {
      TrimSimNode(this.ns.get(i));
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
  
  void RandomDropOut(float dropoutChance)
  {
    for (int i=1;i<this.ns.size()-1;i++)//Only dropout hidden layer
    {
      s_neuron[] layer = this.ns.get(i);
      for(int j=0;j<layer.length;j++)
      {
        if(random(0,1)<dropoutChance)
        {
          layer[j].SetDisable(true);
        }
        else
        {
          layer[j].SetDisable(false);
        }
      }
    }
  }
  
  float TestTrain(float InX[],float OuY[][],int iter)
  {
     // RandomDropOut(0.003);
    float maxErr=0;
    float expectedOut[]=new float[output.length];
    for(int i=0;i<iter;i++)
    {
      maxErr=0;
      int maxErrIdx=InX.length/2;
      for(int j=InX.length-1;j!=0;j--)
      {
        int idx=j;//(int)Math.floor(random(0,InX.length-0.0001));
        if(InX[idx]==Float.NEGATIVE_INFINITY)continue;
        input[0].latestVar=InX[idx];
        for(int k=0;k<OuY.length;k++)
          expectedOut[k]=OuY[k][idx];
        
        this.calc();
        
        float ErrorPow=-calcError(expectedOut);
        if(ErrorPow>maxErr){
          maxErr=ErrorPow;
          maxErrIdx = idx;
        }
        //System.out.printf("------Error:%f\n",ErrorPow);*/
        Train_S(expectedOut);
      }
     
    }
    
    return -maxErr;
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