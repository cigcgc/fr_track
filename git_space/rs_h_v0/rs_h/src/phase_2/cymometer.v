module cymometer(
    //system clock and reset
	input               clk         , // 系统时钟 100MHz
	input               rst_n       , // 异步低电平复位
	//cymometer interface
	input               pulse_in    , // 被测脉冲
    output  reg         valid       , // 输出有效信号              
	output  reg	[31:0]  period_cnt_reg,        
	output  reg [31:0]  freq_out,      // 被测脉冲频率 10Hz~1000Hz
    output  reg signed[31:0]  delta_T_ns  // 一个周期的持续时间，单位为纳秒
    );	

// 信号滤波
reg    [2:0]    pulse_in_filt;
reg             pulse_data;
reg [31:0]  freq_out_tem;
always @(posedge clk or negedge rst_n)
    if (!rst_n) begin
        pulse_in_filt <= 3'd0;
        pulse_data <= 1'b0;
    end    
    else begin
        pulse_in_filt <= {pulse_in_filt[1:0], pulse_in};
        if (pulse_in_filt == {3{pulse_in_filt[1]}})
            pulse_data <= pulse_in_filt[1];
    end    
	
// 被测脉冲边沿检测
reg     [1:0]    pulse_in_ff;
wire             pos_pulse_in;
wire             neg_pulse_in;

always @(posedge clk or negedge rst_n)
    if (!rst_n) 
   	    pulse_in_ff <= 2'd0;
	else
        pulse_in_ff <= {pulse_in_ff[0], pulse_data};//pulse_in};
		
assign pos_pulse_in = !pulse_in_ff[1] && pulse_in_ff[0]; // 被测脉冲上升沿
assign neg_pulse_in = pulse_in_ff[1] && !pulse_in_ff[0]; // 被测脉冲下降沿		

// 被测脉冲频率
reg    [31:0]    period_cnt;      // 脉冲周期时间计数
reg [31:0]   period_cnt_dev_100;
localparam    IDLE    = 3'b001,   // 空闲态
              HPERI   = 3'b010,   // 测量高电平时间
			  ALLPERI = 3'b100;   // 测量周期时间
reg    [2:0]     state;			  // 状态机

always @(posedge clk or negedge rst_n)
    if (!rst_n) begin
	    freq_out <= 17'd0;
		period_cnt_reg <= 32'd0;
		valid <= 1'd0;
        period_cnt <= 'd0;
		state <= IDLE;
    end
    else
        case (state)
		    IDLE : begin
                period_cnt <= 'd1;
				valid <= 0;		
			    if (pos_pulse_in) // 被测脉冲上升沿
				    state <= HPERI;
			end
			HPERI : begin
			    period_cnt <= period_cnt + 1'b1;
				if (neg_pulse_in) // 被测脉冲下降沿  
				    state <= ALLPERI;
			end
			ALLPERI : begin
			    period_cnt <= period_cnt + 1'b1;	
				if (pos_pulse_in) begin // 被测脉冲上升沿
                    period_cnt_dev_100 <= period_cnt/100;  //时间缩小100倍，
                    freq_out_tem <= (100000000/period_cnt_dev_100);   //扩大100倍	，保留小数点后两位	
                    freq_out <= freq_out_tem /100;
                    period_cnt_reg <= period_cnt;
                    delta_T_ns <= period_cnt * 10;  // 将周期计数值转换为纳秒
					valid <= 1;
				    state <= IDLE;
				end
			end
	        default : state <= IDLE;
        endcase	
	
endmodule
	