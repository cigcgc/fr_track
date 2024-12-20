module incremental_pid_control(
    input clk,            // 时钟信号
    input rst,            // 复位信号
    input wire signed [15:0] phase_diff, // 当前相位差 (Δφ)
    input    wire 	  [31:0]  period_cnt_reg,
    output reg signed [31:0] frequency_adjustment // 输出频率调整量
);
// 参数定义
parameter signed [15:0] Kp = 32'd52625; // 比例增益，放大2^16倍
parameter signed [15:0] Ki = 32'd3431;  // 积分增益
parameter signed [15:0] Kd = 32'd5719;  // 微分增益
parameter signed [31:0] MAX_ADJUSTMENT = 32'd200;  // 调整量的上限
parameter signed [31:0] MIN_ADJUSTMENT = -32'd200; // 调整量的下限
   // 状态变量
reg signed [31:0] pre_error;       // 上一次误差
reg signed [31:0] error;           // 当前误差
reg signed [31:0] derivative;      // 微分值
reg signed [63:0] integral;        // 积分值
reg [31:0] clk_counter;            // 时钟计数器
reg [3:0] period_counter;          // 记录累积的period_cnt_reg数量
reg [31:0] dt;                     // 累计10个period_cnt_reg的总时间
reg signed [31:0] pid_output;      // PID输出的未限制调整量
reg pid_flag ;


always @(posedge clk or negedge rst) begin
    if (!rst) begin
        // 异步复位，将所有状态变量清零
        pre_error <= 32'd0;
        integral <= 64'd0;
        clk_counter <= 32'd0;
        period_counter <= 4'd0;
        dt <= 32'd0;
        pid_flag <= 0; 
    end else begin
                pid_flag <=1;
                // 计算误差，使用累积的相位差
                error <= 0 - phase_diff;

                // 计算误差积分值，考虑 dt
                integral <= (integral + error)*0 ;

                // 计算误差微分值，考虑 dt
                derivative <= (error - pre_error);

                // 计算 PID 输出
                pid_output <= (Kp * error) >>> 16 + (Ki * integral) >>> 16 + (Kd * derivative) >>> 16;

                // 将PID输出限制在最大和最小调整量之间
                if (pid_output > MAX_ADJUSTMENT) begin
                    frequency_adjustment <= MAX_ADJUSTMENT;
                end else if (pid_output < MIN_ADJUSTMENT) begin
                    frequency_adjustment <= MIN_ADJUSTMENT;
                end else begin
                    frequency_adjustment <= pid_output;
                end

                // 更新上一次误差值
                pre_error <= error;
      
    end
end 
/*
 // 参数定义
    parameter signed [15:0] Kp = 32'd52625; // 比例增益    46*pi/180 = 0.80285    系数扩大2^16倍
    parameter signed [15:0] Ki = 32'd3431;  // 积分增益    3*pi/180 = 0.05235
    parameter signed [15:0] Kd = 32'd5719;  // 微分增益    5*pi/180 = 0.0872664
    parameter signed [31:0] MAX_ADJUSTMENT = 32'd200;  // 调整量的上限
    parameter signed [31:0] MIN_ADJUSTMENT = -32'd200; // 调整量的下限
    // 状态变量
    reg signed [31:0] pre_error;      // 上一次误差
    reg signed [31:0] error;          // 当前误差
    reg signed [31:0] derivative;     // 微分值
    reg signed [63:0] integral  ;
    // 时钟计数器
    reg [31:0] clk_counter;
    reg [63:0] frequency_adjustment_p;
    reg [63:0] frequency_adjustment_i;
    reg [63:0] frequency_adjustment_d;
    reg signed [31:0] pid_output;       // PID输出的未限制调整量
    reg integral_flag ;


    // dt 计算（1ms 的时间间隔对应的时钟周期数）
    //localparam [31:0] dt_cycles = 32'd100000; // 1ms 对应 100000 个时钟周期

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // 异步复位，将所有状态变量清零
            pre_error <= 32'd0;
            integral <= 64'd0;
           // phase_diff <= 32'd0;
            clk_counter <= 32'd0;
            integral_flag <= 0;
        end else begin
            // 计算误差
            error <= 0 - phase_diff;

            // 实时更新误差积分值
            integral <= integral + error;
            if (clk_counter == 32'd0) begin
                integral_flag <= 1'b1; // 拉高标志，开始计算
            end
            // 计算误差微分值
            derivative <= (error - pre_error);

            // 1ms 触发计算 PID 输出
            if (clk_counter >= period_cnt_reg) begin
                clk_counter <= 32'd0;

                frequency_adjustment_p <= (Kp * error) >>> 16;
                frequency_adjustment_i <= (Ki * integral) >>> 16;
                frequency_adjustment_d <= (Kd * derivative) >>> 16;
                pid_output <= frequency_adjustment_p + frequency_adjustment_i + frequency_adjustment_d;

                // 将PID输出限制在最大和最小调整量之间
                if (pid_output > MAX_ADJUSTMENT) begin
                    frequency_adjustment <= MAX_ADJUSTMENT;
                end else if (pid_output < MIN_ADJUSTMENT) begin
                    frequency_adjustment <= MIN_ADJUSTMENT;
                end else begin
                    frequency_adjustment <= pid_output;
                end

                // 更新上一次误差值
                pre_error <= error;
                integral_flag <= 1'b0; // 拉低标志，结束计算
            end else begin
                clk_counter <= clk_counter + 1;
            end
        end
    end
*/
/*
reg [31:0] ms_counter; // 1毫秒计数器
    reg [63:0] frequency_adjustment_p;
    reg [63:0] frequency_adjustment_i;
    reg [63:0] frequency_adjustment_d;
    parameter CYCLES_PER_MS = 100_000; // 1毫秒的时钟周期数
    // PID 参数
    parameter signed [15:0] Kp = 32'd52625; // 比例增益    46*pi/180 = 0.80285    系数扩大2^16倍
    parameter signed [15:0] Ki = 32'd3431;  // 积分增益    3*pi/180 = 0.05235
    parameter signed [15:0] Kd = 32'd5719;  // 微分增益    5*pi/180 = 0.0872664
    parameter signed [31:0] MAX_ADJUSTMENT = 32'd200;  // 调整量的上限
    parameter signed [31:0] MIN_ADJUSTMENT = -32'd200; // 调整量的下限

    // 中间变量
    reg signed [31:0] error;            // 当前误差项
    reg signed [31:0] integral;         // 积分项
    reg signed [31:0] derivative;       // 微分项
    reg signed [15:0] prev_phase_diff;  // 前一时刻的相位差
    reg signed [31:0] pid_output;       // PID输出的未限制调整量
    reg [31:0] ms_counter;              // 1毫秒计数器
     reg pid_flag ;
  

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // 复位信号，清零所有状态
            error <= 32'd0;
            integral <= 32'd0;
            derivative <= 32'd0;
            prev_phase_diff <= 16'd0;
            frequency_adjustment <= 32'd0;
            ms_counter <= 32'd0;
            pid_flag <= 0;
        end else begin
            // 1毫秒计时器
            if (ms_counter < CYCLES_PER_MS) begin
                ms_counter <= ms_counter + 1;
                pid_flag <= 0;  // 在计时未达到1ms时保持为0
            end else begin
                ms_counter <= 0;
                pid_flag <= 1;  // 当计时达到1ms时置为1
                
                // 计算当前误差项：目标值为0，因此误差为相位差的负值
                error <= 0 - phase_diff;

                // 计算积分项：累积误差，1ms间隔更新
                integral <= integral + error;

                // 计算微分项：相位差的变化率
                derivative <= error - prev_phase_diff;

                // 保存当前误差为下一次的前误差
                prev_phase_diff <= error;

                // 计算PID输出
                frequency_adjustment_p <= (Kp * phase_diff) >>> 16;
                frequency_adjustment_i <= (Ki * integral) >>> 16;
                frequency_adjustment_d <= (Kd * derivative) >>> 16;
                pid_output <= frequency_adjustment_p + frequency_adjustment_i + frequency_adjustment_d;

                // 将PID输出限制在最大和最小调整量之间
                if (pid_output > MAX_ADJUSTMENT) begin
                    frequency_adjustment <= MAX_ADJUSTMENT;
                end else if (pid_output < MIN_ADJUSTMENT) begin
                    frequency_adjustment <= MIN_ADJUSTMENT;
                end else begin
                    frequency_adjustment <= pid_output;
                end
            end
        end
    end
*/
           
endmodule
