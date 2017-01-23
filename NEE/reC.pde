 class reC
  {
    float in_X;
    
    float ou_Y;
    
    s_neuron_net nn=null;
    float InX[][]= null;
    float ExpY[][]= null;
    float DesY[][]= null;
    
  
    reC()
    {
      init();
    }
      
    s_neuron_actFunc actFun_tanh=new s_neuron_actFunc_tanh();
    s_neuron_actFunc actFun_ReLU=new s_neuron_actFunc_ReLU();
    s_neuron_actFunc actFun_LeakyReLU=new s_neuron_actFunc_LeakyReLU();
    s_neuron_actFunc actFun_sigmoid=new s_neuron_actFunc_sigmoid();
  
    void networkDef()
    {
      s_neuron netX[][]=new s_neuron[4][];
      
      int lc=0;
      netX[lc]=new s_neuron[1];
      netX[lc][0] = new s_neuron(actFun_tanh);
      
      lc++;
      netX[lc]=new s_neuron[5];
      for(int i=0;i<netX[lc].length;i++)
      {
        netX[lc][i] = new s_neuron_rec(1,actFun_LeakyReLU);
      }
      
      lc++;
      netX[lc]=new s_neuron[5];
      for(int i=0;i<netX[lc].length;i++)
      {
        netX[lc][i] = new s_neuron_rec(1,actFun_LeakyReLU);
      }

      
      lc++;
      
      netX[lc]=new s_neuron[1];
      netX[lc][0] = new s_neuron(actFun_sigmoid);
      
      nn = new s_neuron_net(netX);
      
    }
      
    void init()
    {
      networkDef();
      
      
      
      InX= new float[50][nn.input.length];
      ExpY= new float[InX.length][nn.output.length];
      DesY= new float[InX.length][nn.output.length];
      
      in_X=0;
      ou_Y=0;
      
      for(int i=0;i<InX.length;i++)
        for(int j=0;j<InX[i].length;j++)
      {
        InX[i][j]=0;
      }
      
      
      for(int i=0;i<ExpY.length;i++)
        for(int j=0;j<ExpY[i].length;j++)
      {
        DesY[i][j]=
        ExpY[i][j]=0;
      }
      InoutIdx=InX.length-1;
    }
    
    
    int skipIdx=0;
        
    int InoutIdx=0;
    void UpdateNeuronInput()
    {
      skipIdx=(skipIdx+1)%1;
      if(skipIdx==0)
      {
        InoutIdx++;
        InoutIdx%=InX.length;
      }
      int i=0;
      
      InX[InoutIdx][i++]=in_X;
      
      
      //print("II:::\n");
      
      
      for(int j=0;j<InX[InoutIdx].length;j++)
      {
        nn.input[j].latestVar=InX[InoutIdx][j];
        //print(nn.input[j].latestVar+"   ");
      }
      nn.calc();
     // print("\nOO:::\n");
      for(int j=0;j<ExpY[InoutIdx].length;j++)
      {
        ExpY[InoutIdx][j]=nn.output[j].latestVar;
      }
     // print("\n");
      
      
      
      i=0;
      ou_Y=ExpY[InoutIdx][i++];
    }
   
    void SetOuY(float ouY[])
    {
      for(int i=0;i<ouY.length;i++)
      {
        DesY[InoutIdx][i]=ouY[i];
      }
    } 
    int CCCX=0;
    float training(int timeback,float lRate)
    {
      CCCX++;
      nn.PreTrainProcess(lRate/2);
      nn.BPTT(InX,ExpY,DesY,InoutIdx,timeback,lRate,false);
      nn.Update_dW(lRate);
      
      return  0;
    }
  }
  
  
  class reCTest
  {
    
    Draw_s_neuron_net drawNN=new Draw_s_neuron_net();
    reC rec=new reC();
    float InX[];
    float OuY[];
    reCTest()
    {
      init();
    }
    void init()
    {
      rec.init();
      InX=new float[rec.nn.input.length];
      OuY=new float[rec.nn.output.length];
      for(int i=0;i<InX.length;i++)InX[i]=0;
      for(int i=0;i<OuY.length;i++)OuY[i]=0;
    }
    

    HistDataDraw TarHist=new HistDataDraw(100);
    HistDataDraw OutHist=new HistDataDraw(100);
    HistDataDraw InHist=new HistDataDraw(100);
    HistDataDraw ADssHist=new HistDataDraw(100);
    
    boolean trainStop=false;
    float t=1;
    
    int SKIPC=0;
    float lRate=0.5;
    int spikePos=2;
    int seqL=10;
    void update()
    {
      //if(SKIPC++%2!=0)return;
      strokeWeight(3);
      background(0);
      if(trainStop)return;
      
      //if(seqL++>20)seqL=1;
      if(SKIPC++%120==0)
      {
        spikePos+=1;
        spikePos%=(seqL-5);
        if(spikePos==0)spikePos+=2;
      }
      OuY[0]=0;
      //InX[0]=(t%(1))*2-1;
      float outX=0;
      t=0;
      for(int i=0;i<seqL;i++)
      {
        
        t+=0.1;
        if(i==spikePos)
        {
          rec.in_X=1;
        }
        else if(i==spikePos+5)
        {
          rec.in_X=0.0;
        }
        else
        {
          rec.in_X=0;
        }
        
        
        if(rec.in_X>0)
        {
          outX=rec.in_X;
          t=0;
        }
        else outX/=1.1;
        OuY[0]=outX<1.9&&outX>0.6?1:0;//cos(10*t)*outX;
        //OuY[0]=i>=(spikePos)&&i<=(spikePos+4)?1:-1;
        rec.UpdateNeuronInput();
        rec.SetOuY(OuY);
        TarHist.DataPush(OuY[0]*50);
        OutHist.DataPush(rec.ou_Y*50);
        InHist.DataPush(rec.in_X*50);
        
        //for(int j=0;j<MEMHist.length;j++)
          //MEMHist[j].DataPush(rec.inout_mem[j]*10);
      }
      
      stroke(0,255,0);
      TarHist.Draw(0,600,width,100);
      
      stroke(255,255,0);
      OutHist.Draw(0,600,width,100);
      stroke(255,255,0);
      InHist.Draw(0,500,width,100);
      
      stroke(255,255,255);
      ADssHist.Draw(rec.nn.hidden[0][1].ADss[2]*10,0,700,width,100);
      // println(rec.nn.hidden[0][1].ADss[2]);
      stroke(255,0,0);
      //for(int i=0;i<MEMHist.length;i++)
        //MEMHist[i].Draw(0,200+i*20,width,100);
      
      
      drawNN.drawNN(rec.nn,10,10,550,350);
      rec.training(seqL,lRate);
      
      
      //trainStop=true;
    }
    void keyPressed()
    {
      
      if (key == CODED) {
        if (keyCode == UP) {
         lRate*=1.05;
        } else if (keyCode == DOWN) {
         lRate/=1.05;
        }
      } else {
        trainStop=!trainStop;
      }
      println(lRate+",");
    } 
  }