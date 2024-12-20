module max_min  
(
    input clk          ,  //50Mhz主时钟          
    input rst        ,  //异步低有效复位       
    input [11:0] data_in0, //被测信号0          
    input [11:0] data_in1, //被测信号1         
            
    output [11:0] data_out0,
    output [11:0] data_out1,

    output data_valid 
);  
wire [31:0] MAX_1MS;
reg [29:0]cnt;//定时器计数
reg cnt_en;//计数使能
reg flag;//计数标志位   
reg [11:0] data_in0_max; //0路信号中电压的最大值
reg [11:0] data_in1_max; //1路信号中电压的最大值
reg [11:0] data_in0_min; //0路信号中电压的最小值
reg [11:0] data_in1_min; //1路信号中电压的最小值
reg [11:0] data_in0_add; //最大值+最小值
reg [11:0] data_in1_add; //最大值+最小值

 assign MAX_1MS  = 100_000;//100Mhz的计数频率，所以计数完后是1ms

always@(posedge clk or negedge rst)
  if(!rst)       
       cnt <= 30'd0;//复位后计数值清零
   else 
	    cnt <=cnt+1'b1; //每一个时钟上升沿后，计数值加1

always@(posedge clk or negedge rst)
  if(!rst)       
       cnt_en <= 1'd0;
   else if(cnt==MAX_1MS-1)
       cnt_en <= 1'd1;//完成一次计数后，计数完成标志信号使能

always@(posedge clk or negedge rst)
  if(!rst) //复位信号置低电平      
       data_in0_max <= 12'd0;//将最大值初始置0
   else if(cnt_en && (data_in0_max<data_in0))//计数完1s后再比较
       data_in0_max <= data_in0;

always@(posedge clk or negedge rst)
  if(!rst)       
       data_in0_min <= 12'd0;//将最小值初始置0
   else if(cnt_en && (data_in0_min>data_in0))//如果采集的值比最小值要小的话
       data_in0_min <= data_in0;//为其赋值

always@(posedge clk or negedge rst)
  if(!rst)       
       data_in1_max <= 12'd0;
   else if(cnt_en && (data_in1_max<data_in1))//复位完1s后开始进行比较
       data_in1_max <= data_in1;

always@(posedge clk or negedge rst)
  if(!rst)       
       data_in1_min <= 12'd255;
   else if(cnt_en && (data_in1_min>data_in1))
       data_in1_min <= data_in1;


//always@(posedge clk or negedge rst_n)
//  if(!rst_n)
//       flag <= 1'd0;
//   else if(cnt==MAX_200MS-1)
//       flag <=  1'd1;
 

always@(posedge clk or negedge rst)
  if(!rst)       
       data_in0_add <= 12'd0;//如果复位，数据相加的结果置0
   else 
       data_in0_add <= data_in0_max+data_in0_min;//否则等于最大值+最小值

always@(posedge clk or negedge rst)
  if(!rst)       
       data_in1_add <= 12'd0;
   else 
       data_in1_add <= data_in1_max+data_in1_min;


assign data_out0=data_in0_add[11:1];//二进制右移一位：除以2
assign data_out1=data_in1_add[11:1];//二进制右移一位：除以2

assign data_valid= cnt_en;//计数1s后，将数据有效位置高


endmodule
