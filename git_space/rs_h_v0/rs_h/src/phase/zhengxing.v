//整型模块
module zhengxing 
        (
         input clk          ,  //100Mhz主时钟          
         input rst        ,  //异步低有效复位       
         input [11:0] data_in0, //被测信号0         
         input [11:0] data_in1,  //被测信号1   
         input [11:0] data_yuzhi0, //被测信号0的过零点       
         input [11:0] data_yuzhi1, //被测信号1的过零点  
         input       data_valid,  //max_min模块的数据有效位信号            
         
         output reg fangbo0, //被测信号0整型后的方波信号
         output reg fangbo1  //被测信号1整型后的方波信号
         );
         
always@(posedge clk or negedge rst) //当电压值超过过零点电压值，将方波信号置1，否则将方波信号置0
	 if(!rst)        
        fangbo0 <= 1'b0;  
    else if(data_valid)//计数完1s后，信号有效位置高电平
    begin
			if(data_in0 >= data_yuzhi0)
				 fangbo0 <= 1'b1;
			else
				 fangbo0 <= 1'b0;
    end   
    else
        fangbo0 <= 1'b0;
        
 always@(posedge clk or negedge rst)//当电压值超过过零点电压值，将方波信号置1，否则将方波信号置0
	 if(!rst)        
        fangbo1 <= 1'b0;      
    else if(data_valid)   
    begin
			if(data_in1 >= data_yuzhi1)
				 fangbo1 <= 1'b1;
			else
				 fangbo1 <= 1'b0;
    end  
    else
        fangbo1 <= 1'b0;        
             
endmodule        
         