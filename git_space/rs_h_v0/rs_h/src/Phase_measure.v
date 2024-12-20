module	Phase_measure(
    input clk,
    input rst_n,
	input in_signal1,
	input in_signal2,
	input [7:0]start,
	output Done,
	output sta,
	output [14:0] r_phase
    );
        


 //异或XOR信号
    wire  XOR_OUT0;

    parameter CNT_TIMES = 8'd8;


 //计算高低电平宽度
 reg[7:0]       on_cnt      =8'b0;              //用来对XOR_OUT0高电平计数，设置CNT_TIMES可以增加计数值
 reg            flag_on     =1'b0;              //flag_on=1时对XOR_OUT0计数
 reg            state       =1'b0;              //state=1,前180度，state=0,后180度

 
 assign	XOR_OUT0 = in_signal1^in_signal2;       //新状态




 //计数CNT_TIMES个信号源的时间  不好修改，提高高频测量精度可以修改CNT_TIMES的值
 always @(posedge in_signal1)
    begin
        if(! rst_n)
            begin
                on_cnt<=8'd0;
            end
        else if(on_cnt<=CNT_TIMES-2)                    //CNT_TIMES个信号1次
                on_cnt <= on_cnt+1'b1;
        else
            begin
                on_cnt<=8'd0;
                flag_on<=~flag_on;
            end        
    end
 //判断相位差范围
always @(negedge flag_on or negedge rst_n) 
    begin
        if(! rst_n)
            state <=1'b0;
        else if(XOR_OUT0)
            state <=1'b1;           //状态1相位差在180内
        else
            state <=1'b0;           //状态0相位差在180外
    end
assign sta = state;
//
reg r1_1,r1_2,r1_3,r1_4;
reg r2_1,r2_2,r2_3,r2_4;
always @(posedge clk or negedge rst_n)
		if (rst_n == 1'b0)
			begin
				r1_1 <= 1'b0;
				r1_2 <= 1'b0;
				r1_3 <= 1'b0;
				r1_4 <= 1'b0;
			end
		else
			begin
				r1_1 <= in_signal1;
				r1_2 <= r1_1;
				r1_3 <= r1_2;
				r1_4 <= r1_3;
end	
always @(posedge clk or negedge rst_n)
		if (rst_n == 1'b0)
			begin
				r2_1 <= 1'b0;
				r2_2 <= 1'b0;
				r2_3 <= 1'b0;
				r2_4 <= 1'b0;
			end
		else
			begin
				r2_1 <= in_signal2;
				r2_2 <= r2_1;
				r2_3 <= r2_2;
				r2_4 <= r2_3;
end

reg signal;
always @(posedge clk or negedge rst_n)
		if (rst_n == 1'b0)
			signal <= 1'd0;
		else 
			signal <= (r1_4 ^ r2_4);

	reg [23:0] cnt;
	reg [35:0] t_r;
	reg done;
	reg[3:0]ct;

always @(posedge clk or negedge rst_n)begin
		if (rst_n == 1'b0) begin
			cnt <= 24'd0;
			t_r <= 36'd0;
			done<=1'b0;
			ct <= 0;
	 	end
		else begin
			case(ct) 
				0:begin
					if ((signal == 1'b1) & 1)begin
						cnt <= cnt + 1'b1;
						done<=1'b0;
					end
					else
						ct<=1;
					end
		  	
				1:begin 
					t_r <= cnt+ 1'b1;//+ 1'b1; //* 4'd10+36'd20; 
					ct<=2;
				end
				2:begin 
					if(signal == 1'b1)begin 
						cnt <= 24'd0;
						ct<=3;
					end 
					else  
						done<=1'b1; 
					end
				3:begin 
					ct<=0;
					done<=1'b0;
				end
			endcase	
		end	
end

wire [35:0]t;			
assign Done=done;
assign  t = t_r;	


//assign r_phase = (t > 8'hefff)?(t>>1):t;	
//assign r_phase = (start == 8'h22)?(t[14:0]):0;
assign r_phase = t[14:0];

	
/*
always @ (posedge clk)//高电平时间计数   flag_on的一次高电平时间，完成一次测量
 begin
    if(! rst_n)
        Pon_cnt  <=32'd0;
	else if(flag_on ==1 && XOR_OUT0 ==1 )
        Pon_cnt  <= Pon_cnt  + 1'b1;
    else if(flag_on == 0)
		Pon_cnt  <= 32'd0;
    else
        Pon_cnt  <=Pon_cnt;

 end

always @ (posedge clk)
 begin
    if(! rst_n)
        Poff_cnt  <= 32'd0;
	else if(flag_on ==1 && XOR_OUT0==0)
        Poff_cnt <= Poff_cnt + 1'b1;
    else if(flag_on == 0)
		Poff_cnt  <= 32'd0;
    else
        Poff_cnt  <=Poff_cnt;  
 end

reg [63:0] r_out_date;
always @(negedge flag_on or negedge rst_n)
        if(!rst_n)begin
            Pon_num  <= 32'd0;         
            Poff_num <= 32'd0; 
            r_out_date <= 0;
        end
		else begin
            Pon_num  <= Pon_cnt;        //保存计数器值
            Poff_num <= Poff_cnt;       //保存计数器值
           // r_out_date <={state,Pon_num[30:0],Poff_num[31:0]};
           r_out_date <={Pon_num[31:0],Poff_num[31:0]};
		end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
			out_date <= 0;
	end
	else begin
    out_date <= {state,r_out_date[62:0]};
	end
end
*/
 //assign out_date={state,Pon_num[30:0],Poff_num[31:0]};    //将状态和计数值发送给stm32处理

endmodule	
