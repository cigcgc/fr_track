//基于零点法计算相位差

module phase_calculate_time(
	input clk,//采样时钟
	input rst,
	input v_square,
    input i_square,
    input freq_valid,
    input [31:0] period_cnt_reg,
  
    
	output reg signed  [15:0]  m_phase_difference
   
);
   // wire        v_square      ;
    wire        ch1_data_pulse      ;
  //  wire        freq_valid          ;  // 频率有效信号
    reg         xor_pulse_tem;
    reg        xor_pulse           ;  // 异或脉冲
    reg         v_clean_d    ;  // 信号0打拍
    wire        v_clean_up   ;  // 信号0上升??
    reg         i_clean_d    ;  // 信号0打拍
    wire        i_clean_up   ;  // 信号0上升??
    wire        v_clean_down   ;
    wire        i_clean_down   ;
    reg         first_flag          ;  // 仅计算一次的标志??
    reg         out_signed          ;  // 相位差的符号
    reg [15:0]  cnt_per             ;  // 计数异或信号高电平的
    reg         xor_pulse_d         ;  // 异或信号打拍
    wire        xor_pulse_up        ;  // ??测异或信号上升沿
    wire        xor_pulse_down      ;  // ??测异或信号下降沿
    reg [15:0]  t_diff              ;
    reg [31:0]  T                   ;
    reg    [14:0]  phase_diff_r    ;
    reg    [14:0]  phase_diff_tem;
    //wire    [31:0]  period_cnt_reg  ;
    reg [31:0] T_dev100;
    wire [11:0] max_v;       // 输出最大值
    wire [11:0] max_i;       // 输出最大值
    wire [11:0] min_i;       // 输出最小值
    wire [12:0] mid_i;        // 输出最大值和最小值之和的平均值
    wire [12:0] shifted_signal_v;
    wire [12:0] shifted_signal_i;
    wire  [31:0] fre_out_tem;

    reg [7:0] counter_v;         // 计数器，跟踪 v_square 信号稳定时间
    reg [7:0] counter_i;         // 计数器，跟踪 i_square 信号稳定时间
    reg stable_v, stable_i;      // 当前信号的稳定状态
    reg v_clean,i_clean ;
    reg xor_active;                // 异或信号是否有效
     reg pluse_high;                // 控制高电平的时间窗口
    parameter DEBOUNCE_TIME = 100; // 1 微秒去抖时间窗口，适合100MHz时钟
 always @(posedge clk or negedge rst) begin
        if (!rst) begin
            counter_v <= 0;
            stable_v <= 0;
            v_clean <= 0;
        end else begin
            if (v_square != stable_v) begin
                // 如果输入信号 v_square 与当前稳定信号不同，开始计时
                counter_v <= counter_v + 1;
                if (counter_v >= DEBOUNCE_TIME) begin
                    // 如果信号保持稳定超过去抖时间窗口，则更新稳定信号
                    stable_v <= v_square;
                    v_clean <= v_square;
                    counter_v <= 0;
                end
            end else begin
                // 如果信号没有变化，重置计数器
                counter_v <= 0;
            end
        end
    end
 // 去抖动 i_square 信号
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            counter_i <= 0;
            stable_i <= 0;
            i_clean <= 0;
        end else begin
            if (i_square != stable_i) begin
                // 如果输入信号 i_square 与当前稳定信号不同，开始计时
                counter_i <= counter_i + 1;
                if (counter_i >= DEBOUNCE_TIME) begin
                    // 如果信号保持稳定超过去抖时间窗口，则更新稳定信号
                    stable_i <= i_square;
                    i_clean <= i_square;
                    counter_i <= 0;
                end
            end else begin
                // 如果信号没有变化，重置计数器
                counter_i <= 0;
            end
        end
    end

// 在时钟的每一个上升沿，保存 v_clean 和 i_clean 的前一个状态
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            v_clean_d <= 0;
            i_clean_d <= 0;
        end else begin
            v_clean_d <= v_clean;
            i_clean_d <= i_clean;
        end
    end


    // 检测 v_clean 和 i_clean 的上升沿
    assign v_clean_up = (!v_clean_d && v_clean);  // 当前为高电平，前一个周期为低电平，说明上升沿
    assign i_clean_up = (!i_clean_d && i_clean);  // 同样方法检测 i_clean 上升沿
    assign v_clean_down = (v_clean_d && !v_clean); // v_clean 的下降沿
    assign i_clean_down = (i_clean_d && !i_clean); // i_clean 的下降沿
    reg v_clean_up_d,i_clean_up_d;
    wire v_clean_up_up,i_clean_up_up,v_clean_down_down,i_clean_down_down;
// 在时钟的每一个上升沿，保存 v_clean_up 和 i_clean_up 的前一个状态
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            v_clean_up_d <= 0;
            i_clean_up_d <= 0;
        end else begin
            v_clean_up_d <= v_clean_up;
            i_clean_up_d <= i_clean_up;
        end
    end

 // 检测 v_clean 和 i_clean 的上升沿
    assign v_clean_up_up = (!v_clean_up_d && v_clean_up);  // 当前为高电平，前一个周期为低电平，说明上升沿
    assign i_clean_up_up = (!i_clean_up_d && i_clean_up);  // 同样方法检测 i_clean 上升沿
    assign v_clean_down_down = (v_clean_up_d && !v_clean_up); // v_clean 的下降沿
    assign i_clean_down_down = (i_clean_up_d && !i_clean_up); // i_clean 的下降沿

 // 状态定义
 localparam        IDLE = 2'b00;              // 空闲状态
 localparam        WAIT_FOR_I_CLEAN_DOWN = 2'b01;  // 等待 i_clean 下降沿
 localparam        WAIT_FOR_V_CLEAN_DOWN = 2'b10;   // 等待 v_clean 下降沿
  reg [1:0] current_state, next_state; // 当前状态和下一个状态
// 状态机控制 pluse_high 的状态
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state; // 更新状态
        end
    end

    // 状态转换逻辑
    always @(*) begin
        next_state = current_state; // 默认保持当前状态
        case (current_state)
            IDLE: begin
                // 检测 v_clean 的上升沿，进入等待 i_clean 下降沿的状态
                if (v_clean_up_up) begin
                    next_state = WAIT_FOR_I_CLEAN_DOWN;
                    pluse_high = 1; // 在该状态下，pluse_high 保持高电平
                end
                // 检测 i_clean 的上升沿，进入等待 v_clean 下降沿的状态
                else if (i_clean_up_up) begin
                    next_state = WAIT_FOR_V_CLEAN_DOWN;
                    pluse_high = 1;
                end else begin
                    pluse_high = 0; // 初始状态下，pluse_high 置为低电平
                end
            end

            WAIT_FOR_I_CLEAN_DOWN: begin
                // 当检测到 i_clean 下降沿，进入 IDLE 状态
                if (i_clean_down_down) begin
                    next_state = IDLE;
                    pluse_high = 0; // pluse_high 置为低电平
                end else begin
                    pluse_high = 1; // 等待状态下，保持 pluse_high 为高电平
                end
            end

            WAIT_FOR_V_CLEAN_DOWN: begin
                // 当检测到 v_clean 下降沿，进入 IDLE 状态
                if (v_clean_down_down) begin
                    next_state = IDLE;
                    pluse_high = 0;
                end else begin
                    pluse_high = 1; // 等待状态下，保持 pluse_high 为高电平
                end
            end

            default: begin
                next_state = IDLE;
                pluse_high = 0;
            end
        endcase
    end

    // 当 pluse_high 为高电平时，进行异或操作
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            xor_pulse <= 0;
        end else if (pluse_high) begin
            xor_pulse <= v_clean ^ i_clean; // 当 pluse_high 为高电平时，进行异或操作
        end else begin
            xor_pulse <= 0; // 否则保持为低电平
        end
    end
   
    assign xor_pulse_up = xor_pulse && !xor_pulse_d;
    assign xor_pulse_down = !xor_pulse && xor_pulse_d;
    always @ (posedge clk or negedge rst) begin
        if (!rst)
            xor_pulse_d <= 0;
        else
            xor_pulse_d <= xor_pulse;
    end

    always @ (posedge clk or negedge rst) begin
        if (!rst)
            first_flag <= 0;
        else if (v_clean_up)
            first_flag <= 1;
    end

    always @ (posedge clk or negedge rst) begin
        if (!rst)
            out_signed <= 0;
        else if (!first_flag && v_clean_up)
            out_signed <= !ch1_data_pulse;  // 当ch0上升沿若ch1??0则认为相位差为正，否则认为相位差为负
    end

    // 3 计算相位

    // 偏移量计
    always @ (posedge clk or negedge rst) begin
        if (!rst) begin
            cnt_per <= 0;
            t_diff <= 0;
        end else begin
         if (xor_pulse_down) begin
            t_diff <= cnt_per;
            cnt_per <= 0;
        end else if (xor_pulse)begin
            cnt_per <= cnt_per + 1;
        end
     end
end
   

    // 信号周期计算
    always @ (posedge clk or negedge rst) begin
        if (!rst) begin
            T <= 1; 
            T_dev100 <= 0;
            m_phase_difference <= 0;
            phase_diff_tem <= 0;
        end else  if (freq_valid) begin
            T <= period_cnt_reg;
            T_dev100 <= T/100;
            phase_diff_tem <=  t_diff * 360 / T_dev100;

            phase_diff_r <=  phase_diff_tem /100;
            m_phase_difference <= out_signed ? {out_signed, (~phase_diff_r)+1} : {out_signed, phase_diff_r};
        end

            
    end
    // 相位差计
   
    assign valid = freq_valid;


/*
    assign origin_data = v_square ^ ch1_data_pulse;
    reg state;             // 当前状态，0为低电平，1为高电平
    reg modify_data;
    reg [31:0] t1, t, t2;  // 用于存储高电平持续时间的寄存器
    reg [31:0] counter;     // 计数器用于测量高电平持续时间
    reg prev_origin_data;   // 用于存储上一个时钟周期的origin_data
    reg delay_origin_data;  // 延迟一个周期的origin_data
    reg modify_flag;        // 用于指示modify_data信号是否需要修改

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            t1 <= 0;
            t <= 0;
            t2 <= 0;
            counter <= 0;
            prev_origin_data <= 0;
            delay_origin_data <= 0;
            modify_data <= 0;
            modify_flag <= 0;
        end else begin
            prev_origin_data <= origin_data;
            delay_origin_data <= prev_origin_data; // 延迟一个时钟周期

            if (origin_data && !prev_origin_data) begin
                // 检测到上升沿，开始计数
                counter <= 1;
            end else if (!origin_data && prev_origin_data) begin
                // 检测到下降沿，计数结束
                t <= counter;       // 将当前计数值存储为t
                t2 <= counter;      // 准备下一周期的t2值
                counter <= 0;       // 复位计数器

                // 判断是否需要修改modify_data
                if (t1 != 0 && t != 0 && t2 != 0) begin
                    if (t <= t1 && t <= t2) begin
                        modify_flag <= 0; // 保持原信号
                    end else begin
                        modify_flag <= 1; // 修改为低电平
                    end
                end

                t1 <= t; // 更新t1为上一个周期的时间
            end else if (origin_data) begin
                // 如果在高电平，继续计数
                counter <= counter + 1;
            end

            // 输出modify_data信号，基于延迟的origin_data和modify_flag
            if (modify_flag) begin
                modify_data <= 0;
            end else begin
                modify_data <= delay_origin_data;
            end
        end
    end

assign xor_pulse_output = modify_data;



    assign v_square_up = v_square && !v_square_d;

    always @(posedge clk or negedge rst) begin
    if (!rst)
        v_square_d <= 0;
    else
        v_square_d <= v_square;
end

    assign xor_pulse_test = !xor_pulse_output;
    assign xor_pulse_down = !xor_pulse_output && xor_pulse_output_d;
    always @ (posedge clk or negedge rst) begin
        if (!rst)
            xor_pulse_output_d <= 0;
        else
            xor_pulse_output_d <= xor_pulse_output;
    end

    always @ (posedge clk or negedge rst) begin
        if (!rst)
            first_flag <= 0;
        else if (v_square_up)
            first_flag <= 1;
    end

    always @ (posedge clk or negedge rst) begin
        if (!rst)
            out_signed <= 0;
        else if (!first_flag && v_square_up)
            out_signed <= !ch1_data_pulse;  // 当ch0上升沿若ch1??0则认为相位差为正，否则认为相位差为负
    end

    // 2 计算脉冲信号的频率
    
  cymometer u_cymometer(
        .clk       ( clk        ),
        .rst_n     ( rst       ),
        .pulse_in  ( v_square ),  // 仅测量一个信号的频率即可
        .valid     ( freq_valid     ),
        .period_cnt_reg (period_cnt_reg),
        .freq_out  ( fre_out_tem       ),
        .delta_T_ns(delta_T_ns)
    );


    always @ (posedge clk or negedge rst) begin
        if (!rst)begin
            fre_out <= 0;
       end  else begin
            fre_out <= fre_out_tem;
       end
    end


    // 3 计算相位

    reg [31:0] counter_phase;
    reg signal_in_d;
    reg [31:0] high_time; // 高电平持续时间
    // 偏移量计
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            counter_phase <= 32'd0;
            high_time <= 32'd0;
            xor_pulse_output_d <= 1'b0;
        end else begin
            xor_pulse_output_d <= xor_pulse_output;

            if (xor_pulse_output && !xor_pulse_output_d) begin
                // 检测到上升沿，开始计时
                counter_phase <= 32'd0;
            end else if (xor_pulse_output) begin
                // 高电平期间，计数器递增
                counter_phase <= counter_phase + 1;
            end else if (!xor_pulse_output && xor_pulse_output_d) begin
                // 检测到下降沿，记录高电平时间
                high_time <= counter_phase;
            end
        end
    end

    

    // 信号周期计算
    always @ (posedge clk or negedge rst) begin
        if (!rst)
            T <= 1;  
        else if (freq_valid)
            T <= period_cnt_reg;
            
    end
always @ (posedge clk or negedge rst) begin
        if (!rst)
            T_dev100 <= 0;  
        else if (freq_valid)
            T_dev100 <= T/100;
            
    end
    // 相位差计
    assign phase_diff_r =  high_time * 360 / T_dev100;
    assign m_phase_difference = out_signed ? {out_signed, (~phase_diff_r)+1} : {out_signed, phase_diff_r};
    assign valid = freq_valid;
*/
endmodule