 class reC
  {
    float in_X;
    float inout_mem[]=new float[3];
    
    float ou_Y;
    
    s_neuron_net nn = new s_neuron_net(new int[]{1+inout_mem.length,15,1+inout_mem.length});
    float InX[][]=new float[50][nn.input.length];
    float OuY[][]=new float[InX.length][nn.output.length];
    
  
    reC()
    {
      init();
    }
      
    void init()
    {
      in_X=0;
      ou_Y=0;
      for(int i=0;i<inout_mem.length;i++)
      {
        inout_mem[i]=0;
      }
      for(int i=0;i<InX.length;i++)
        for(int j=0;j<InX[i].length;j++)
      {
        InX[i][j]=0;
      }
      
      
      for(int i=0;i<OuY.length;i++)
        for(int j=0;j<OuY[i].length;j++)
      {
        OuY[i][j]=0;
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
      
      for(int j=0;j<inout_mem.length;j++)
      {
        InX[InoutIdx][i++]=inout_mem[j];
      }
      
      //print("II:::\n");
      
      
      for(int j=0;j<InX[InoutIdx].length;j++)
      {
        nn.input[j].latestVar=InX[InoutIdx][j];
        //print(nn.input[j].latestVar+"   ");
      }
      nn.calc();
     // print("\nOO:::\n");
      for(int j=0;j<OuY[InoutIdx].length;j++)
      {
        OuY[InoutIdx][j]=nn.output[j].latestVar;
        
       // print(OuY[InoutIdx][j]+"   ");
      }
     // print("\n");
      
      
      
      i=0;
      ou_Y=OuY[InoutIdx][i++];
      for(int j=0;j<inout_mem.length;j++)
      {
        inout_mem[j]=OuY[InoutIdx][i+j];
      }
      i+=inout_mem.length;
    }
   

    float training(float InX[][],float OuY[][],int timeback,float lRate)
    {
      float memLoopTrain=1;
      
      for(int i=0;i<memLoopTrain;i++)
      {
        
        //nn.PreTrainProcess(lRate);
        nn.TestTrainRecNNx(InX,OuY,InoutIdx,timeback,lRate,false,inout_mem.length);
      }
      
      return  0;
    }
    
   void SetOuY(float ouY[])
    {
      for(int i=0;i<ouY.length-inout_mem.length;i++)
      {
        OuY[InoutIdx][i]=ouY[i];
        
      }
    } 
    float training(int timeback,float lRate)
    {
          training(InX,OuY,timeback, lRate);
      return  0;
    }
  }
  
  
  class reCTest
  {
    
    Draw_s_neuron_net drawNN=new Draw_s_neuron_net();
    reC rec=new reC();
    float InX[]=new float[rec.nn.input.length];
    float OuY[]=new float[rec.nn.output.length];
    
    reCTest()
    {
      init();
    }
    void init()
    {
      for(int i=0;i<InX.length;i++)InX[i]=0;
      for(int i=0;i<OuY.length;i++)OuY[i]=0;
      for(int i=0;i<MEMHist.length;i++)MEMHist[i]=new HistDataDraw(100);
    }
    

    HistDataDraw TarHist=new HistDataDraw(100);
    HistDataDraw OutHist=new HistDataDraw(100);
    HistDataDraw InHist=new HistDataDraw(100);
    HistDataDraw ADssHist=new HistDataDraw(100);
    HistDataDraw MEMHist[]=new HistDataDraw[rec.inout_mem.length];
    
    boolean trainStop=false;
    float t=1;
    
    int SKIPC=0;
    float lRate=0.1;
    int spikePos=5;
    void update()
    {
      //if(SKIPC++%2!=0)return;
      strokeWeight(3);
      background(0);
      //if(!trainStop)
      int seqL=20;
      
      /*if(SKIPC++%5==0)
      {
        spikePos+=1;
        spikePos%=(seqL-5);
      }*/
      rec.init();
      OuY[0]=0;
      //InX[0]=(t%(1))*2-1;
      float outX=0;
      t=0;
      for(int i=0;i<seqL;i++)
      {
        
        t+=0.1;
        rec.in_X=i==(spikePos)?1:-1;
        if(rec.in_X==1)outX=1;
        else outX/=1.5;
        OuY[0]=outX*2-1;
        //OuY[0]=i==(spikePos+3)?1:-1;
        rec.UpdateNeuronInput();
        rec.SetOuY(OuY);
        TarHist.DataPush(OuY[0]*50);
        OutHist.DataPush(rec.ou_Y*50);
        InHist.DataPush(rec.in_X*50);
        
        for(int j=0;j<MEMHist.length;j++)
          MEMHist[j].DataPush(rec.inout_mem[j]*10);
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
      for(int i=0;i<MEMHist.length;i++)
        MEMHist[i].Draw(0,200+i*20,width,100);
      
      
      drawNN.drawNN(rec.nn,10,10,550,350);
      
      if(!trainStop)
        rec.training(seqL,lRate);
      
      
      
      
    }
    void keyPressed()
    {
      
      if (key == CODED) {
        if (keyCode == UP) {
         lRate*=1.01;
        } else if (keyCode == DOWN) {
         lRate/=1.01;
        }
      } else {
        trainStop=!trainStop;
      }
    } 
  }