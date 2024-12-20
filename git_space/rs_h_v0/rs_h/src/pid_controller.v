module pid_controller (
    input  wire clk,
    input  wire rst_n,
    input  wire [15:0] setpoint,        // 目标值
    input  wire [15:0] feedback,        // 系统反馈值
    input  wire signed[15:0] Kp,              // 比例增益
    input  wire signed[15:0] Ki,              // 积分增益
    input  wire signed[15:0] Kd,              // 微分增益
    input  wire [15:0] clk_prescaler,   // 时钟分频因子
    output reg  signed[15:0] control_signal   // 控制输出
);

    // 内部寄存器
    reg signed[15:0] prev_error;              // 上一次误差
    reg signed [31:0] integral;         // 积分值（扩大位宽以避免溢出）
    reg signed [15:0] derivative;       // 微分值
    reg [15:0] clk_divider;             // 分频计数器
    reg sampling_flag;                  // 采样标志
	reg signed [15:0] error;
	reg signed[15:0] tem_signal ;
    
    
    // 采样逻辑,当error发生变化时，才计算prev_error
    reg [15:0] prev_signal;           // 用于存储上一次的信号值

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prev_signal <= 16'h0;      // 复位时清零
            sampling_flag <= 1'b0;     // 复位时 sampling_flag 清零
        end else begin
            if (feedback != prev_signal) begin
                // 检测到信号变化，拉高 sampling_flag
                sampling_flag <= 1'b1;
            end else begin
                // 保证 sampling_flag 只拉高一个时钟周期
                sampling_flag <= 1'b0;
            end
            // 更新上一次的信号值
            prev_signal <= feedback;
        end
    end


    reg signed [15:0] delta_Q,absolute_delta_Q;
    always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                delta_Q <= 16'd0;
            end else begin
                delta_Q = feedback;
                absolute_delta_Q <= (delta_Q < 0) ? -delta_Q : delta_Q;
                
            end
        end

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            prev_error <= 16'sh0; // 复位时清零
        end else if (sampling_flag) begin
            prev_error <= error;  // 仅在采样标志拉高时更新 prev_error
        end
    end

    reg signed [15:0] pid_p,pid_i,pid_d;


    // PID 控制逻辑
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            // 复位所有寄存器
            integral <= 32'sh00000000;
            derivative <= 16'sh0000;
            control_signal <= 16'sh0000;
            pid_p <= 16'sh0000;
            pid_i <= 16'sh0000;
            pid_d <= 16'sh0000;
            tem_signal <= 16'sh0000;
        end else if (sampling_flag) begin
            if (absolute_delta_Q < 10)begin
                // 计算误差
                error = setpoint - feedback;

                // 计算积分
                integral <= integral +  error;

                // 防止积分溢出（饱和逻辑）
                if (integral > 32'sh7FFF_FFFF) 
                    integral <= 32'sh7FFF_FFFF;
                else if (integral < -32'sh7FFF_FFFF) 
                    integral <= -32'sh7FFF_FFFF;

                // 计算微分
                derivative <= error - prev_error;

                // 计算控制信号
                pid_p <= Kp * error;
                pid_i <= Ki * integral;
                pid_d <= Kd *derivative;
                tem_signal <= (Kp * error + integral*Ki + Kd *derivative);
                control_signal <= (Kp * error + integral*Ki + Kd *derivative)/100;

                // 防止控制信号溢出（饱和逻辑）
                if (control_signal > 16'sh7FFF)
                    control_signal <= 16'sh7FFF;
                else if (control_signal < -16'sh8000)
                    control_signal <= -16'sh8000;
            end else begin
                integral <= 32'sh00000000;
                derivative <= 16'sh0000;
                control_signal <= 16'sh0000;
                error <= 16'sh0000; 
                pid_p <= 16'sh0000;
                pid_i <= 16'sh0000;
                pid_d <= 16'sh0000;   
            end
        end
    end

endmodule
