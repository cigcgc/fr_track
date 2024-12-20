module phase_diff_cal (
    input wire clk,              // 系统时钟 (100MHz)
    input wire rstn,             // 复位信号，低电平复位
    input wire square_wave_1,    // 方波信号1
    input wire square_wave_2,    // 方波信号2
    input wire [31:0] f_signal,  // 方波信号频率，单位Hz
    output reg [15:0] phase_diff // 相位差，单位为度
);

// 内部信号
wire xor_pulse;
wire xor_filtered;
reg [31:0] time_counter;        // 用于记录时间
reg [31:0] t_diff;              // 记录时间差
reg measure_start;

localparam f_clk = 100_000_000;  // 时钟频率为100MHz

// 1. 异或运算
assign xor_pulse = square_wave_1 ^ square_wave_2;

// 2. 与运算只保留上升沿或下降沿
assign xor_filtered = xor_pulse & square_wave_1;  // 只保留上升沿触发

// 3. 计时逻辑，用于计算相位差
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        time_counter <= 0;
        t_diff <= 0;
        phase_diff <= 0;
        measure_start <= 0;
    end
    else begin
        // 计时器增加
        time_counter <= time_counter + 1;

        // 检测 square_wave_1 的上升沿，开始测量
        if (square_wave_1 && !measure_start) begin
            measure_start <= 1;
            time_counter <= 0; // 重置计时器
        end
        // 在 xor_filtered 信号有效时，计算时间差
        else if (xor_filtered && measure_start) begin
            t_diff <= time_counter;   // 记录时间差
            measure_start <= 0;       // 停止测量
        end

        // 计算相位差 (基于系统时钟和方波信号频率)
        // phase_diff = (t_diff * f_signal * 360) / f_clk
        if (f_signal > 0) begin
            phase_diff <= (t_diff * f_signal * 360) / f_clk;
        end
    end
end

endmodule
