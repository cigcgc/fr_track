  module top(
	input FPGA_CLK,
	input RST,
	//output led4,
	output led3,
	output led2,
	output led1,
	//FSMC
	//FSMC
	input CS32,
	input W_32,
	input R_32,
	input [7:0] addr_stm32,
	
	//input [15:0] data_stm32,          //数据位，仿真时需要改变输入输出属性
	inout [15:0] data_stm32,          //数据位，仿真时需要改变输入输出属性
	
	
	
	input PD7,
	input PG9,
	input PG12,
/*
	//电位器幅度控制
	output mcp41010_mosi1 ,
	output mcp41010_sck1  ,
	output mcp41010_cs1   ,
	output mcp41010_mosi2 ,
	output mcp41010_sck2  ,
	output mcp41010_cs2	,
*/
	//adc
	input [11:0] adc_in_v,//
	output ad1_clk,
	output ad1_oe,
	
	input [11:0] adc_in_i,
	output ad2_clk,
	output ad2_oe,
	//相位检测
	input V_PHASE,
	input I_PHASE
	//测试端口
	//input [15:0] delete_cmd,
	//test
	//硬件版本号
	/*input v0,
	input v1,
	input v2*/
    //测试的adc
	//仿真测试
	//input [15:0]read_cmd
    
    
		
);
//assign cs_32_in = cs_stm32;
assign ad1_oe = 0;  
assign ad2_oe = 0;



wire rst;
wire clk_100M;


    Gowin_rPLL_100M pll_100(
        .clkout(clk_100M), //output clkout
        .lock(rst), //output lock
        .reset(~RST), //input reset
        .clkin(FPGA_CLK) //input clkin
    );



wire clk_10M;
    Gowin_CLKDIV10 your_instance_name(
        .clkout(clk_10M), //output clkout
        .hclkin(FPGA_CLK), //input hclkin
        .resetn(rst) //input resetn
    );
wire clk_5M;
    Gowin_CLKDIV5M clkdiv_5M(
        .clkout(clk_5M), //output clkout
        .hclkin(clk_10M), //input hclkin
        .resetn(rst) //input resetn
    );	
wire clk_2M;
    Gowin_CLKDIV500k clkdiv2M(
        .clkout(clk_2M), //output clkout
        .hclkin(clk_10M), //input hclkin
        .resetn(rst) //input resetn
    );	
wire clk_2M5;
    Gowin_CLKDIV_2M5 clkdiv_2M5(
        .clkout(clk_2M5), //output clkout
        .hclkin(clk_5M), //input hclkin
        .resetn(rst) //input resetn
    );
wire clk_500k;
    Gowin_CLKDIV500k clkdiv500k(
        .clkout(clk_500k), //output clkout
        .hclkin(clk_2M5), //input hclkin
        .resetn(rst) //input resetn
    );
wire clk_1M;
    Gowin_CLKDIV500k clkdiv1M(
        .clkout(clk_1M), //output clkout
        .hclkin(clk_5M), //input hclkin
        .resetn(rst) //input resetn
    );
reg cs_stm32;
reg w_en_stm32;
reg r_en_stm32;
reg r1,r2,r3,r4,r5,r6;
always@(posedge clk_100M)begin
	if(!rst)begin
		cs_stm32 <= 1;
		w_en_stm32 <= 1;
		r_en_stm32 <= 1;
		r1  <= 1;
		r2  <= 1;
		r3  <= 1;
		r4  <= 1;
		r5  <= 1;
		r6  <= 1;
	end
	else begin
		r1 <= CS32;
		cs_stm32 <= r1;
		
		r2 <= W_32;
		w_en_stm32 <= r2;
		
		r3 <= R_32;
		r_en_stm32 <= r3;
	end
end
reg [23:0] cnt_led;	
always@(posedge clk_10M or negedge rst)begin
	if(!rst)begin
		cnt_led <= 0;
	end
	else if(cnt_led <= 26'd10000000)begin
		cnt_led <= cnt_led + 1;
	end
	else begin
		cnt_led <= 0;
	end
end
//assign led1 = (cnt_led <= 5000000)?1:0;





wire [200:0]temp;
reg [7:0]phase_done;
wire [15:0]phase_v_i;
wire [7:0]adc_save_done;
wire [15:0]adc_data_v; //数据有save模块输出
wire [15:0]adc_data_i;
wire [15:0]fft_v;
wire [15:0]fft_i;
wire [15:0]d_phase_v_i;
wire save_over;//
wire save_over_i;//
//wire adc_save_done;
//assign adc_save_done = {2'b0,save_over,1'b0,2'b0,save_over,1'b0}；
wire [15:0]fifo_adc_v_data;
wire [15:0]fifo_adc_i_data;
wire [2:0] Version_Number;

wire [15:0] start_frequency_low;
wire [15:0] start_frequency_high;
wire [15:0] drive_dds_frequency_low;
wire [15:0] drive_dds_frequency_high;

wire [15:0]stm32_en;
wire [15:0] phase_diff_32;
wire [3:0] phase_sta;
reg [15:0] drive_frequency_low;
reg [15:0] drive_frequency_high;
reg [15:0] drive_frequency_high_tem,drive_frequency_low_tem; 
reg frequency_done;
reg signed [15:0] delta_Q,absolute_delta_Q;
reg signed [15:0] delta_Q_threshold;	
reg signed[31:0] drive_frequency;
wire [15:0]stm32_stop;
reg start_pid_control;
reg start_fuzzy_pid_control;
wire [11:0] r_adc_data_v;//数据输入到save模块  
wire [11:0] r_adc_data_i;
save_fsmc save_fsmc_inist(
	.clk(clk_100M),
	.rst(rst),
	.cs(cs_stm32),
	.w_en(w_en_stm32),
	.r_en(r_en_stm32),
	.addr(addr_stm32),
	.data_in(data_stm32),
    //.start_frequency_low(start_frequency_low),
	//.start_frequency_high(start_frequency_high),

	.temp(temp),
	.phase_done(phase_done),        //根据使能，完成相位检测后，标志为1，
	.phase_v_i(phase_v_i),//phase_v_i      相位检测模块
	.adc_save_done({2'b0,save_over,1'b0,2'b0,save_over,1'b0}),//save_over  保存完成信号，v_i通道同步进行，使用一个即可
	.adc_data_v(adc_data_v),
	.adc_data_i(adc_data_i),
	.fft_v(16'h9658),
	.fft_i(16'h7458),
	.d_phase_v_i(16'hcdaa),
	.Version_Number(Version_Number),

    .phase_diff(phase_diff),
    .drive_frequency_low(drive_frequency_low),
    .drive_frequency_high(drive_frequency_high),
    .frequency_done(frequency_done), //完成频率计算后，标志为1
    .start_fuzzy_pid_control(start_fuzzy_pid_control),
    .start_pid_control(start_pid_control),
    .frequency_v(frequency_v),
    .r_adc_data_v(r_adc_data_v),
    .r_adc_data_i(r_adc_data_i)
   
); 

//从stm32获取的谐振频率
assign start_frequency_low  = temp[127:112];
assign start_frequency_high = temp[143:128];
//从stm32获取的驱动频率
assign drive_dds_frequency_high = temp[175:160];
assign drive_dds_frequency_low = temp [159:144];
//从stm32获取的使能信号
assign stm32_en = temp[79:64];

//从stm32获取的相位差
assign phase_diff_32 = temp[181:176];

wire [31:0] drive_dds_frequency;
assign drive_dds_frequency = {drive_dds_frequency_high,drive_dds_frequency_low};
//数字电位器
wire [7:0]dwq_spi1;
wire [7:0]dwq_spi2;
mcp41010 mcp41010_inist1(
	.clk(clk_5M),
	.rst(rst),
	.tx_en(1),
	.data_in(temp[39:32]),//电位器命令，，由串口输入，，      0001 0001 八位编码  2进制      dwq_spi1
						//							          0000 0000 八位编码  2进制
						//  						          01   01    _ _;	   16进制					
	.mosi(mcp41010_mosi1),
	.sclk(mcp41010_sck1),
	.cs(mcp41010_cs1)
);
mcp41010 mcp41010_inist2(
	.clk(clk_5M),
	.rst(rst),
	.tx_en(1),
	.data_in(temp[47:40]),//电位器命令，，由串口输入，，      0001 0001 八位编码  2进制           dwq_spi2
						//							          0000 0000 八位编码  2进制
						//  						          01   01    _ _;	   16进制		

			
	.mosi(mcp41010_mosi2),
	.sclk(mcp41010_sck2),
	.cs(mcp41010_cs2)
);

//相位检测
wire phase_fuhao;
wire [14:0]r_phase;
wire phase_ok;

Phase_measure Phase_measure_inist(
    .clk(clk_100M),
    .rst_n(rst),
	.start(temp[7:0]),
	.in_signal1(I_PHASE),
	.in_signal2(V_PHASE),
	.Done(phase_ok),
	.sta(phase_fuhao),
	.r_phase(r_phase)
    );
assign	phase_v_i ={phase_fuhao,r_phase};//相位检测结果实时更新
always@(posedge clk_100M or negedge rst)begin
	if(!rst)begin
		phase_done <= 8'h00;
	end
	else begin
		if(phase_ok == 1)begin
			phase_done <= 8'h22;
		end
		else begin
			phase_done <= 8'h00;
		end
	end
end
//数据采集
//ad804

wire [31:0] sample_time_v;
wire [31:0] sample_time_i;
adc_ads804e  adc_v(
	.clk(clk_2M),
	.rst(rst),
	
	.ad_in(adc_in_v),//输入数据
	
	.ad_clk(ad1_clk),//输出时钟
	.ad_out(r_adc_data_v),//采样数据
    .sample_time(sample_time_v)
);
adc_ads804e  adc_i(
	.clk(clk_2M),//改为2m采样
	.rst(rst),
	
	.ad_in(adc_in_i),//输入数据
	
	.ad_clk(ad2_clk),//输出时钟
	.ad_out(r_adc_data_i),//采样数据
    .sample_time(sample_time_i)
);
wire [15:0] adc_data_v_16;
wire [24:0] adc_data_v_25;
wire [15:0] adc_data_i_16;
wire [24:0] adc_data_i_25;
 assign adc_data_v_16 = {4'b0,r_adc_data_v};
 assign adc_data_v_25 = {13'b0,r_adc_data_v};
 assign adc_data_i_16 = {4'b0,r_adc_data_i};
 assign adc_data_i_25 = {13'b0,r_adc_data_i};

//输出采样数据和采样时刻
//wire [31:0] sample_time;
/*
adc_data adc_data_inist (
    .clk(clk_2M),
    .rst(rst),
    .ad_out(r_adc_data_v),
    .sample_time(sample_time)
);
*/

//保存数据
//加入cs片选控制，CS为低，数据有效
/*
reg read_cmd;
reg [3:0] sta_f;
always@(posedge clk_100M or negedge rst)begin
	if(!rst)begin
		read_cmd <= 0;
	end
	else begin
		case(sta_f)
			0:begin
				
			end
		default:read_cmd <= 0;;
		endcase
	end
end*/
save_send_adc save_send_adc(
	.clk_w(clk_2M),
	.rst(rst),
	.clk_r(clk_100M),
	.v_data({4'b0,r_adc_data_v}),
	
	.i_data({4'b0,r_adc_data_i}),
	.read_cmd(temp[31:16]),//temp[]    ;
	.r_en_stm32(r_en_stm32),
	.delete_cmd(delete_cmd),//加入一个输入端口来模拟： temp[63:48]
	.save_over(save_over),
	.save_over_i(save_over_i),
	.data_out_v(adc_data_v),
	.data_out_i(adc_data_i)
);
//DDS测试fft
wire [10:0] dds_out;
dds_happen dds_happen(
	.clk(FPGA_CLK),
	.rst(rst),
	.en(1),
	.fword(32'h00418937),
	.pword(0),
	
	.dds_out(dds_out)
);
reg [15:0] fft_in;
/*
always@(posedge clk_1M or negedge rst)begin
	if(!rst)begin
		fft_in <= 0;
	end
	else begin
		fft_in <={0,0,0,0,0,dds_out} ;
	end
end
*/

wire [31:0] test_fre;
assign test_fre = 32'd55000;
wire pwm_out;
dds_drive dds_drive_u (
        .clk(clk_100M),         // 连接系统时钟
        .rst(rst),         // 连接复位信号
        .freq_val(test_fre),// 连接频率值
        .pwm_out(pwm_out), // PWM输出
        .led1(led1),       // 连接LED1
        .led2(led2)        // 连接LED2
    );

     wire [6:0] fuzzy_EC ;
	 wire [6:0] fuzzy_df;
	 wire signed [7:0]  df  ; 

     wire signed [15:0] d_uk;// pid增量
     wire signed[15:0] ek0,ek1,ek2;
     wire signed [15:0] frequency_adjustment;


	
	// 使用模糊PID控制
            // 模糊化处理
            fuzzification fuzzification_inist (
				.clk(clk_2M),
				.rst(rst),
                .EC(phase_diff_32),
                .fuzzy_EC(fuzzy_EC)
            );

            // 模糊推理
            fuzzy_inference fuzzy_inference_inist (
                .fuzzy_EC(fuzzy_EC),
                .fuzzy_df(fuzzy_df)
            );

            // 解模糊化
            defuzzification defuzzification_inist (
                .fuzzy_df(fuzzy_df),
                .df(df)
            );
			
   // 使用增量式PID控制
        pid_controller DUT(
	.clk(FPGA_CLK),
	.rst_n(rst),
	.setpoint(0),
	.feedback(phase_diff),
	.Kp(250),
	.Ki(30),
	.Kd(50),
	.clk_prescaler(1),
	.control_signal(frequency_adjustment)
	);
    	
	
        // 计算相位差ΔQ绝对值
    always @(posedge FPGA_CLK or negedge rst) begin
            if (!rst) begin
                delta_Q <= 16'd0;
            end else begin
                delta_Q = phase_diff;
                absolute_delta_Q <= (delta_Q < 0) ? -delta_Q : delta_Q;
                
            end
    end

    // 设置ΔQ 阈值
    always @(posedge FPGA_CLK or negedge rst) begin
        if (!rst) begin
            delta_Q_threshold <= 16'd0;
        end else begin
            delta_Q_threshold <= 16'd10;
        end
    end

// 定义状态
localparam IDLE = 2'b00;
localparam WAIT_FOR_START_FREQ = 2'b01;
localparam CALCULATE_FREQ = 2'b10;
localparam DONE = 2'b11;

reg [1:0] state; //状态机状态
reg first_time_flag; // 标志信号，跟踪是否是第一次使用start_frequency
reg signed[31:0] start_frequency;
       

always @(posedge FPGA_CLK or negedge rst) begin
    if (!rst) begin
    start_frequency <= 0;
    end else begin
        if (stm32_en) begin
            start_frequency <= {start_frequency_high,start_frequency_low}; // 获取start_frequency
        end
    end
end





reg signed [31:0] fr_value;
always @(posedge FPGA_CLK or negedge rst) begin
    if (!rst) begin
        fr_value <= 0;
    end else begin
         if (absolute_delta_Q >= delta_Q_threshold) begin
                         fr_value <= 10*df;
         end else begin
                         fr_value <= frequency_adjustment;
         end
    end 
  end

// 采样逻辑
    reg sampling_flag;
    reg [31:0] prev_signal;           // 用于存储上一次的信号值

    always @(posedge FPGA_CLK or negedge rst) begin
        if (!rst) begin
            prev_signal <= 16'h0;      // 复位时清零
            sampling_flag <= 1'b0;     // 复位时 sampling_flag 清零
        end else begin
            if (fr_value != prev_signal) begin
                // 检测到信号变化，拉高 sampling_flag
                sampling_flag <= 1'b1;
            end else begin
                // 保证 sampling_flag 只拉高一个时钟周期
                sampling_flag <= 1'b0;
            end
            // 更新上一次的信号值
            prev_signal <= fr_value;
        end
    end


always @(posedge FPGA_CLK or negedge rst) begin
    if (!rst) begin
        state <= IDLE;
        drive_frequency <= 0;
        frequency_done <= 0;
        start_pid_control <= 0;
        start_fuzzy_pid_control <= 0;
        first_time_flag <= 0;
        drive_frequency_high_tem <= 0;
        drive_frequency_low_tem <= 0;
    end else begin
        

        case (state)
            IDLE: begin
                frequency_done <= 0;
                if (stm32_en) begin
                    state <= WAIT_FOR_START_FREQ;
                end else begin
                    state <= IDLE;
                end
            end
            
            WAIT_FOR_START_FREQ: begin
                if (stm32_en) begin
                    if (!first_time_flag) begin // 第一次检测到stm32_en为真  
                        drive_frequency <= start_frequency*10;
                        first_time_flag <= 1; // 标志为已执行
                    end else begin
                        // 非第一次时，直接根据 df 或 frequency_adjustment进行增减
                        if (sampling_flag) begin
                            drive_frequency <= drive_frequency + fr_value; 
                            state <= CALCULATE_FREQ;
                        end else begin
                            drive_frequency <= drive_frequency ;  
                        end


                    end
                end
            end

            CALCULATE_FREQ: begin
                // 限制 drive_frequency 的范围
                if (drive_frequency <= 32'd552000) begin 
                    drive_frequency = 32'd552000;
                end else if  (drive_frequency >= 32'd556000) begin 
                   drive_frequency = 32'd556000;
                end else
                   drive_frequency = drive_frequency;
            

                
                // 更新 drive_frequency 的高低位
                drive_frequency_low_tem = drive_frequency[15:0];
                drive_frequency_high_tem = drive_frequency[31:16];
              
             
                state <= DONE;
            end

            DONE: begin
                frequency_done <= 1; // 计算完成，置频率完成信号
                start_fuzzy_pid_control <= 0;
                start_pid_control <= 0;
                state <= IDLE;  // 返回初始状态，等待下次启动
            end

            default: begin
                state <= IDLE;
            end
        endcase
    end
end

wire [31:0] dr_frequency_tem,dr_frequency;
assign dr_frequency_tem ={drive_frequency_high_tem,drive_frequency_low_tem};
assign dr_frequency = dr_frequency_tem;
    always @(posedge FPGA_CLK or negedge rst) begin
            if (!rst) begin
                drive_frequency_high <= 0;
                drive_frequency_low <= 0;
            end else begin
                drive_frequency_high <= dr_frequency[31:16];
                drive_frequency_low  <= dr_frequency[15:0];    
            end 
    end


endmodule