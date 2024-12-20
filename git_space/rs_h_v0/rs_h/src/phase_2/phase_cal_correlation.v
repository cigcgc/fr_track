//使用互相关法计算相位差


module phase_cal_correlation(
    input clk,                      // 时钟信号
    input rst,                      // 重置信号
    input signed [11:0] signal_1,    // 电压信号输入
    input signed [11:0] signal_2,    // 电流信号输入
    output reg signed [15:0] phase_diff  // 输出相位差，单位为度，16位存储
);

    parameter N = 1024;  // 采样点数
    reg signed [31:0] Rxy;        // 当前的互相关值
    reg signed [31:0] max_Rxy;    // 最大互相关值
    reg [9:0] max_index;          // 最大互相关值对应的索引
    reg [9:0] i, n;               // 循环变量

    reg signed [11:0] signal_1_reg [N-1:0];  // 存储电压信号采样数据
    reg signed [11:0] signal_2_reg [N-1:0];  // 存储电流信号采样数据

    // 采样信号并计算互相关值
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            phase_diff <= 0;
            max_Rxy <= 0;
            max_index <= 0;
            i <= 0;  // 初始化循环变量
            n <= 0;
            Rxy <= 0;
           
        end else begin
            // 每个时钟周期采样信号
            if (n < N) begin
                signal_1_reg[n] <= signal_1;
                signal_2_reg[n] <= signal_2;
                n <= n + 1;  // 使用非阻塞赋值更新采样计数器
            end else begin
                // 计算互相关值，分多时钟周期完成
                if (i < N) begin
                    Rxy <= signal_1_reg[i] * signal_2_reg[(i + n) % N];
                    if (Rxy > max_Rxy) begin
                        max_Rxy <= Rxy;
                        max_index <= i;
                    end
                    i <= i + 1;  // 使用非阻塞赋值更新循环变量
                end else begin
                    // 当所有互相关值计算完成后，计算相位差
                    if (max_index < N/2) begin
                        // 电压信号超前电流信号，计算负相位差
                        phase_diff <= -((max_index * 32767) >> 10);  // 使用右移代替除法，N = 1024，右移10位
                    end else begin
                        // 电流信号超前电压信号，计算正相位差
                        phase_diff <= ((N - max_index) * 32767) >> 10;
                    end
                end
            end
        end
    end
endmodule
