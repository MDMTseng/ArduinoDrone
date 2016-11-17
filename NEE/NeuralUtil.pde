
class s_neuron{
  public float SumVar;
  public float latestVar;
  public float trainError;
  
  
  public int post_neuron_L;
  public s_neuron post_neuron_list[];
  public float W[];
  public float ADss[];
  
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
    ADss = new float[W.length];
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
      
      ADss = new float[W.length];
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
  
  float rmsW_noDC()
  {
    float sumW=0;
    //CosSim = v1.*v2./(|v1||v2|)
    for(int i=0;i<pre_neuron_L-1;i++)
    {
      sumW+=W[i]*W[i];
    }
    return (float)Math.sqrt(sumW/(pre_neuron_L-1));
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
    //return (x>0)?x:0.01*x;
  }
  
  public double d_exciteF(double sigmoid_var) {
    sigmoid_var=(sigmoid_var+1)/2;
    double slop=2*sigmoid_var*(1-(sigmoid_var));
    return (slop+0.02)/1.01;
    
    //return sigmoid_var>0? 1:0.01;
    
  }
}

class s_neuron_net{
  ArrayList <s_neuron[]> ns;
  s_neuron ones[];
  s_neuron input[];
  s_neuron hidden[][];
  s_neuron output[];
  
  float XRand(float x1,float x2)
  {
    float rand=random(x1,1);
    return random(0,1)>x2?rand:-rand;
  }
  s_neuron_net(int netDim[])
  {
    if(netDim.length<2)
      return;
    ones =  new s_neuron[netDim.length-1]; 
    ns = new ArrayList <s_neuron[]>();
    
    
    hidden=new s_neuron[netDim.length-2][];
    input=new s_neuron[netDim[0]];
    s_neuron prelayer[]=null;
    s_neuron currentlayer[]=input;
    for(int i=0;i<currentlayer.length;i++)
    {
      currentlayer[i] = new s_neuron(1);
    }
    ns.add(currentlayer);
    
    for(int i=1;i<netDim.length;i++)
    {
      prelayer=currentlayer;
      currentlayer=new s_neuron[netDim[i]];
      
      ones[i-1]=new s_neuron(1);
      ones[i-1].latestVar=1;
      
      for(int j=0;j<currentlayer.length;j++)
      {
        currentlayer[j] = new s_neuron(1);
        for(int k=0;k<prelayer.length;k++)
        {
          currentlayer[j].add_pre_neuron(prelayer[k],XRand(0,0.5)*2);
        }
        currentlayer[j].add_pre_neuron(ones[i-1] ,XRand(0,0.5)*2);
      }
      ns.add(currentlayer);
    }
    
    for(int i=1;i<ns.size()-1;i++)
    {
      hidden[i-1]=ns.get(i);
    }
    
    
    output=ns.get(ns.size()-1);
    
  }
  
  
    
  void NeuronNodeRevive(s_neuron layer[],float maxW_threshold)
  {
    for (int i=0;i<layer.length;i++)
    {
      if(layer[i].rmsW_noDC()>maxW_threshold)continue;
      for (int j=0;j<layer[i].GetActual_pre_neuron_L()-1;j++) 
      {
        layer[i].W[j]*=random(1.0,1.1);
      }
    }
    
  }
  
  
  void NeuronNodePolarizing(s_neuron layer[],float maxW_threshold)
  {
    for (int i=0;i<layer.length;i++)
    {
      if(layer[i].rmsW_noDC()>maxW_threshold)continue;
      
      for (int j=0;j<layer[i].GetActual_pre_neuron_L()-1;j++) 
      {
        float tmpX=layer[i].W[j];
        if(tmpX<0)tmpX=-tmpX;
        if(tmpX>maxW_threshold)
          layer[i].W[j]*=random(1.0,1.1);
        else
          layer[i].W[j]/=random(1.0,1.1);
      }
    }
    
  }
  
  void AttractSimNode(s_neuron layer[],float CosSimValve,float alpha)
  {
    
    if(layer[0].pre_neuron_L>2)
    for (int i=0;i<layer.length;i++)
    {
      if(layer[i].rmsW()<2)continue;
      for (int j=i+1;j<layer.length;j++) 
      {
        float CosSim=layer[i].CosSimilarW(layer[j]);
        if(CosSim>CosSimValve)
        {
          float tmp=(CosSim-CosSimValve)*(1-CosSimValve);
          float attractAlpha=1-(1-alpha)*tmp*tmp;
          
          System.out.printf("C%02d:%f...\n ",layer[j].GetActual_pre_neuron_L(),CosSim);
          for (int k=0;k<layer[j].GetActual_pre_neuron_L();k++)
          {
            tmp = layer[j].W[k];
            layer[j].W[k]=tmp*attractAlpha+layer[i].W[k]*(1-attractAlpha);
            layer[i].W[k]=layer[i].W[k]*attractAlpha+tmp*(1-attractAlpha);
          }
        }
      }
        
    }
    
  }
  void TrimSimNode(s_neuron layer[],float CosSimValve)
  {
    
    if(layer[0].pre_neuron_L>2)
    for (int i=0;i<layer.length;i++)
    {
      //if(layer[i].rmsW()<1)continue;
      for (int j=i+1;j<layer.length;j++) 
      {
        //if(layer[j].rmsW()<1)continue;
        float CosSim=layer[i].CosSimilarW(layer[j]);
        if(CosSim>CosSimValve)
        {
          //System.out.printf(">>>:%f...\n ",CosSim);
          for (int k=0;k<layer[j].GetActual_pre_neuron_L();k++)
          {
            //System.out.printf("%f,%f  ",layer[j].W[k],layer[i].W[k]);
            layer[j].W[k]=(layer[i].W[k]+layer[j].W[k])/2;
            layer[j].ADss[k]=(layer[j].ADss[k]+layer[i].ADss[k])/2;
            layer[i].W[k]= XRand(0,0.5)/2;
            //layer[i].ADss[k]=0;
          }
          //System.out.printf("\n ");
          
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
            pnode.W[n2_idx]=0;
            pnode.ADss[n2_idx]=5;
          }
          break;
        }
      }
        
    }
    
  }
  int CCCC=0;
  void SupressS(s_neuron layer[],float alpha)
  {
    CCCC++;
    for (int i=0;i<layer.length;i++)
    {
      for (int j=0;j<layer[i].pre_neuron_L-1;j++)
      {
        float d=layer[i].W[j];
        //int k=(CCCC/6)%(layer.length);
        
        //layer[i].W[j]=(i==k)?(cos(2*(i*j)*PI/(layer[i].pre_neuron_L-1)/layer.length)):0;
        layer[i].W[j]=d*(alpha)+(1-alpha)*d*(cos(2*(i*j)*PI/(layer[i].pre_neuron_L-1)/layer.length)+1)/2;
          
      }
    }
    
  }
  void SupressL2(s_neuron layer[],float alpha)
  {
    for (int i=0;i<layer.length;i++)
    {
      for (int j=0;j<layer[i].pre_neuron_L-1;j++)
      {
        float d=layer[i].W[j];
        //int k=(CCCC/6)%(layer.length);
        
        //layer[i].W[j]=(i==k)?(cos(2*(i*j)*PI/(layer[i].pre_neuron_L-1)/layer.length)):0;
        layer[i].W[j]=d*(alpha);
          
      }
    }
    
  }
  
  void SupressL1X(s_neuron layer[],float rate)
  {
    for (int i=0;i<layer.length;i++)
    {
      float xr=0;
      for (int j=0;j<layer[i].pre_neuron_L-1;j++)
      {
        float d=layer[i].W[j];
       
        xr+=(d>0)?d:-d;
          
      }
      
      xr/=layer[i].pre_neuron_L-1;
      for (int j=0;j<layer[i].pre_neuron_L-1;j++)
      {
        float d=layer[i].W[j];
        if(d<0) layer[i].W[j]+=rate*xr;
        else    layer[i].W[j]-=rate*xr;
        
        if(layer[i].W[j]*d<0)layer[i].W[j]=0;
          
      }
    }
    
  }
  void PreTrainProcess()
  {
   // RandomDropOut(0.01);
    
    for (int i=this.ns.size()-2;i!=1;i--)
    {
      SupressL2(this.ns.get(i),0.99);
      SupressL1X(this.ns.get(i),0.001);
    }
    
    for (int i=this.ns.size()-2;i!=0;i--)
    {
      AttractSimNode(this.ns.get(i),0.50,0.80);
      TrimSimNode(this.ns.get(i),0.99);
      //NeuronNodePolarizing(this.ns.get(i),0.9);
      NeuronNodeRevive(this.ns.get(i),0.9);
    }
  }
  
  //BufferL = Train_1(this.ns.get(i),Error,ErrorL,Buffer);
  void Train_1(s_neuron layer[],boolean crossEn,float learningRate)
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
    
    
    float lRate=learningRate;
    
    
    float WAve =0;

    for (int i=0;i<layer.length;i++) {
      float dPdZ = layer[i].trainError;
      
     /* lRate = dPdZ*limit;
      if(lRate<0)lRate=-lRate;
      float dropO=1;//random(0, 1)>0.005? 1:0.4;*/
      
     // lRate=limit;//*(random(0.5, 1.1));//(float)Math.log(limit*dropO+1);
      
      
      float dZdY = crossEn?1:(float)layer[i].d_exciteF(layer[i].latestVar);
      float dPdY = dPdZ*dZdY;
      for (int j=0;j<layer[i].pre_neuron_L;j++)
      {
        float dYdW = layer[i].pre_neuron_list[j].latestVar;
        layer[i].pre_neuron_list[j].trainError+=dPdY*(layer[i].W[j])/(layer.length-1);
        
        float dX=dPdY*dYdW;//AdaGrad kind of
        layer[i].ADss[j]+=dX*dX;
        float sqrtAdss=sqrt(layer[i].ADss[j]);
        if(sqrtAdss!=0)
        {
          layer[i].W[j]+=lRate*dX/sqrtAdss;
          dX=sqrtAdss;
          if(dX>1)dX=1;
          //dX=1-dX;
          //dX=dX*dX;
          dX=dX*dX*dX*0.000001;
          layer[i].ADss[j]*=1-dX;
        }
        else
        {
          layer[i].W[j]+=lRate*dX;
        }
      }
    }
    //WAve/=ErrorL*(layer[0].pre_neuron_L-1);
    
    
    
    return;
  }
  
  void softMax()
  {
    float sum=0;
    for (int i=0;i<output.length;i++)
    {
      sum+=(output[i].latestVar+1)/2;
      //float absErr=Error[i]>0?Error[i]:-Error[i];
      //Error[i]=(float)Math.exp(absErr*absErr*absErr)/5*(Error[i]>0?1:-1);
    }
    
    for (int i=0;i<output.length;i++)
    {
      output[i].latestVar=((output[i].latestVar+1)/sum)-1;
      //float absErr=Error[i]>0?Error[i]:-Error[i];
      //Error[i]=(float)Math.exp(absErr*absErr*absErr)/5*(Error[i]>0?1:-1);
    }
    
  }
  
  void Train_S(float lRate,boolean crossEn)
  {
    // softMax();
    
    
    for (int i=this.ns.size()-1;i!=0;i--)
    {
      Train_1(this.ns.get(i),crossEn&&(i==this.ns.size()-1),lRate);
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
  
  float calcError()
  {
    float out=0;
    for (int i=0;i<output.length;i++)
    {
      float tmp = output[i].trainError;
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
  
  float TestTrain(float InXSet[][],float OuYSet[][],int iter,float lRate)
  {
    return TestTrain( InXSet, OuYSet, iter, lRate, false);
  }
  
  float TestTrain(float InXSet[][],float OuYSet[][],int iter,float lRate,boolean crossEn)
  {
    float aveErr=0;
    float aveErrC=0;

    for(int i=0;i<iter;i++)
    {
      for(int j=0;j<InXSet.length;j++)
      {
        aveErr+=TestTrain( InXSet[j], OuYSet[j], lRate, crossEn);
      }
    }
    
    return aveErr/aveErrC;
  }
  float TestTrain(float InX[],float OuY[],float lRate,boolean crossEn)
  {
    //if(InX[idx]==Float.NEGATIVE_INFINITY)continue;
    
    for(int k=0;k<InX.length;k++)
    {
      input[k].latestVar=InX[k];
    }
    this.calc();
    
    for (int i=this.ns.size()-2;i>=0;i--)//last layer will be set later
    {
      s_neuron layer[]=this.ns.get(i);
      for (int j=0;j<layer.length;j++)
      {
        layer[j].trainError = 0;
      }
    }
    
    for(int k=0;k<OuY.length;k++)
    {
      output[k].trainError=OuY[k]-output[k].latestVar;
    }
    
    float ErrorPow=-calcError();
    Train_S(lRate,crossEn);
    
    return ErrorPow;
  }
  
 
  
    void TestTrainRecNN(float InX[],float OuY[],float lRate,boolean crossEn,int RecTrainIter,int memNum)
    {
      //if(InX[idx]==Float.NEGATIVE_INFINITY)continue;
      
      for(int k=0;k<InX.length;k++)
        input[k].latestVar=InX[k];
      calc();
      
      //float ErrorPow=-calcError();

      /*
       
           ____________
       ----|           |---
       ----|           |---
    mem----|___________|--- mem
         |               |
         |_____mem_______|
  
      inErr(tmp) = DestOut - outVar (only mem)
      loop{
        outVar = DestOut -inErr(tmp)   (only mem)
        Clear all trainError
        outErr = DestOut - outVar     (ALL)  => mem's outErr will be inErr
        TRAIN...
      }
      */

      for(int k=0;k<memNum;k++)
      {
        input[input.length-1-k].trainError=OuY[output.length-1-k];
      }
      
      for(int j=0;j<RecTrainIter;j++)
      {
        for(int k=0;k<memNum;k++)
        {
          output[output.length-1-k].latestVar=input[input.length-1-k].trainError;
        }
        for (int i=ns.size()-2;i>=0;i--)//last layer will be set later
        {
          s_neuron layer[]=ns.get(i);
          for (int k=0;k<layer.length;k++)
          {
            layer[k].trainError = 0;
          }
        }
        for(int k=0;k<OuY.length;k++)
        {
          output[k].trainError=OuY[k]-output[k].latestVar;
          //print(output[k].trainError+" , ");
        }
          //println();
        
        //softMax();
        
        Train_S(lRate,crossEn);
        
        
      }
      
    }
  
    
    int RetRandomSel(float chance[])
    {
      int maxIdx=0;
      float maxNum=0;
      
      for(int i=0;i<chance.length;i++)
      {
        float tmp=random(0,chance[i]);
        if(maxNum<tmp)
        {
          maxIdx=i;
          maxNum=tmp;
        }
      }
      return maxIdx;
      
    }
    
    boolean GeneticCrossNN(s_neuron_net parents[],float fitness[])
    {//no dynamic node change
    
      for (int i=ns.size()-1;i>=0;i--)
      {
        s_neuron layer[]=ns.get(i);
        for (int k=0;k<layer.length;k++)
        {
          s_neuron node=layer[k];
          int selIdx=RetRandomSel(fitness);
          for (int m=0;m<node.pre_neuron_L;m++)
          {
            node.W[m]=parents[selIdx].ns.get(i)[k].W[m];
          }
          layer[k].trainError = 0;
        }
      }
      return false;
    }
    void AddNNNoise(float noiseLevel)
    {//no dynamic node change
    
      for (int i=ns.size()-1;i>=0;i--)
      {
        s_neuron layer[]=ns.get(i);
        for (int k=0;k<layer.length;k++)
        {
          s_neuron node=layer[k];
          for (int m=0;m<node.pre_neuron_L;m++)
          {
            node.W[m]+=random(-noiseLevel,noiseLevel);
          }
        }
      }
    }
    void AddNNmutate(float mutateChance)
    {//no dynamic node change
    
      for (int i=ns.size()-1;i>=0;i--)
      {
        s_neuron layer[]=ns.get(i);
        for (int k=0;k<layer.length;k++)
        {
          s_neuron node=layer[k];
          for (int m=0;m<node.pre_neuron_L;m++)
          {
            if(random(0,1)<mutateChance)
              node.W[m]=random(-node.W[m]*1,node.W[m]*1);
          }
        }
      }
    }
}