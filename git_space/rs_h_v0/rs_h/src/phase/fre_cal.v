//频率计算模块
//公式：（被测信号个数/时间窗内参考信号个数 ）*参考信号频率
module fre_cal  
         (
         input clk           ,  //50MHZ 
         input rst_n         ,   //复位
         input  cal_en       ,
         input [29:0] cnt     ,//被测信号个数
         output [29:0] fre_out   //-被测信号频率

        );        
 
reg [29:0]  mult_temp ;
                        
always@(posedge clk or negedge rst_n)
  if(!rst_n)       
       mult_temp <= 26'd0;
   else if(cal_en)//如果0.5s的时间窗计数完成，此时时间窗内的计数值乘以2便是在1s内的计数值
      mult_temp <= cnt; 
 
//参考信号500ms产生一个时间窗，被测信号的频率是1s内记录的次数，因此乘以2
assign fre_out = mult_temp<<1;             
endmodule
