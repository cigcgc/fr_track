module phase_cal(
    input clk,
    input rst,
    input v_square,  // 电压信号
    input i_square,  // 电流信号
    input square_done,

    output reg [15:0] frequency_v,  // 电压信号频率输出
    output reg [15:0] frequency_i,  // 电流信号频率输出
    output reg signed[31:0] v_edge_time,  // 电压信号边沿时间输出
    output reg signed[31:0] i_edge_time,  // 电流信号边沿时间输出
    output reg signed[31:0] v_period_time, // 电压信号周期时间输出
    output reg signed[31:0] i_period_time,
    output reg signed[31:0] last_edge_time, // 上一个周期的边沿时间
    output reg signed[31:0] edge_time_valid,
    output reg fre_done,
    output reg signed [15:0] phase_diff, // 相位差输出
    output reg signed[31:0] delta_t,              // 时间间隔 Δt 输出
    output reg m_phase_done
);

reg signed[31:0] v_edge_times[1:0];  // 存储电压信号的两个上升沿时间
reg signed[31:0] i_edge_times[1:0];  // 存储电流信号的两个上升沿时间
parameter SYS_CLOCK_FREQ = 100_000_000; // 系统时钟频率（单位：100MHz）

reg signed[31:0] v_edge_time_1, v_edge_time_2;
reg signed[31:0] i_edge_time_1, i_edge_time_2;

reg [3:0] v_edge_count, i_edge_count;
reg prev_v_square, prev_i_square;
reg signed[31:0] time_counter;
reg signed [31:0] phase_diff_32;
reg v_calculated, i_calculated,v_flag;
reg signed [31:0] mult_result;
reg phase_calculated; // 用于标记相位差是否已经计算
reg [2:0]phase_flag;
reg v_valid, i_valid;  // 标记是否为有效上升沿
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        v_edge_time_1 <= 0;
        v_edge_time_2 <= 0;
        v_period_time <= 0;
        v_edge_count <= 0;
        prev_v_square <= 0;
        frequency_v <= 0;
        v_edge_time <= 0;

        i_edge_time_1 <= 0;
        i_edge_time_2 <= 0;
        i_period_time <= 0;
        i_edge_count <= 0;
        prev_i_square <= 0;
        frequency_i <= 0;
        i_edge_time <= 0;
         v_flag <= 0;
        time_counter <= 0;
        last_edge_time <= 0;
        edge_time_valid <= 0;
        v_calculated <= 0;
        i_calculated <= 0;
        fre_done <= 0;
        m_phase_done <= 0;
        phase_flag <= 0;
    end else begin
        if (square_done) begin
            prev_v_square <= v_square;
            prev_i_square <= i_square;

            // 检测电压信号的上升沿并计算频率
            
            if (prev_v_square == 0 && v_square == 1) begin
                if (v_edge_count < 5) begin
                    v_edge_count <= v_edge_count + 1;
                    if (v_edge_count == 1) begin
                        v_edge_time_1 <= time_counter;
                    end else begin
                        v_edge_time_2 <= time_counter;
                        v_period_time <= v_edge_time_2 - v_edge_time_1;
                        v_edge_time_1 <= v_edge_time_2;
                    end
                end else begin
                    v_edge_time_2 <= time_counter;
                    v_period_time <= v_edge_time_2 - v_edge_time_1;
                    frequency_v <= SYS_CLOCK_FREQ / v_period_time;
                    v_edge_time_1 <= v_edge_time_2;
                    v_edge_time <= v_edge_time_1;  // 输出边沿时间
                    v_calculated <= 1; // 标记电压频率计算完成
                    v_valid <= 1; // 标记为有效的上升沿
                    time_counter <= 0; // 重置时间计数器
                end
             
               
               end else if (prev_v_square == 1 && v_square == 0) begin
                v_valid <= 0; // 检测到下降沿，标记为无效
            end

            // 检测电流信号的上升沿并计算频率
            if (prev_i_square == 0 && i_square == 1) begin
                
                if (i_edge_count < 5) begin
                    i_edge_count <= i_edge_count + 1;
                    if (i_edge_count == 1) begin
                        i_edge_time_1 <= time_counter;
                    end else begin
                        i_edge_time_2 <= time_counter;
                        i_period_time <= i_edge_time_2 - i_edge_time_1;
                        i_edge_time_1 <= i_edge_time_2;
                    end
                end else begin
                    i_edge_time_2 <= time_counter;
                    i_period_time <= i_edge_time_2 - i_edge_time_1;
                    frequency_i <= SYS_CLOCK_FREQ / i_period_time;
                    i_edge_time_1 <= i_edge_time_2;
                    i_edge_time <= i_edge_time_1;  // 输出边沿时间
                    i_calculated <= 1; // 标记电流频率计算完成
                    i_valid <= 1; // 标记为有效的上升沿
                    time_counter <= 0; // 重置时间计数器
                end
                
               end else if (prev_i_square == 1 && i_square == 0) begin
                    i_valid <= 0; // 检测到下降沿，标记为无效
            end


            
            time_counter <= time_counter + 1;
            fre_done <= 1;
        end
    

     if (i_calculated && v_calculated && v_valid && i_valid) begin
        // 在 last_edge_time 时刻计算相位差
        
           if(i_edge_time > v_edge_time) begin
            phase_flag <= 1;
            delta_t <= i_edge_time - v_edge_time;
            mult_result <= delta_t * 360;
            phase_diff_32 <= mult_result / i_period_time;
            phase_diff <= phase_diff_32[15:0];
           end else   begin
            phase_flag <= 2;
            delta_t <= v_edge_time - i_edge_time;
            mult_result <= delta_t * 360;
            phase_diff_32 <= -(mult_result / v_period_time);
            phase_diff <= phase_diff_32[15:0];
           end
        
        m_phase_done <= 1;
        //flag <= 0;
     end 
   
     if (m_phase_done) begin
        // 在相位差计算完成后，复位 phase_calculated
       // phase_calculated <= 0;
        m_phase_done <= 0;
        i_calculated <= 0;
        v_calculated <= 0;
     end



    end

  end





endmodule
