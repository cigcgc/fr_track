module dds_drive (
    input wire clk,              // 系统时钟
    input wire rst,              // 复位信号
    input wire [31:0] freq_val,  // 给定频率值 (单位Hz)
    output reg pwm_out,          // 输出方波，占空比为50%
    output wire led1,            // LED1输出，当pwm_out为高电平时亮
    output wire led2             // LED2输出，当pwm_out为低电平时亮
);

    reg [31:0] clk_cnt;         // 时钟计数器
    reg [31:0] period_cnt;      // 一个周期的时钟数
    reg [31:0] half_period_cnt; // 半周期的时钟数

    // 系统时钟频率，假设为100MHz (即10ns每个周期)
    parameter CLK_FREQ = 100_000_000;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            clk_cnt <= 32'd0;
            pwm_out <= 1'b0;
            period_cnt <= CLK_FREQ / freq_val; // 计算周期时钟数
            half_period_cnt <= (CLK_FREQ / freq_val) / 2; // 计算半周期时钟数
        end else begin
            if (clk_cnt < period_cnt - 1) begin
                clk_cnt <= clk_cnt + 1;
            end else begin
                clk_cnt <= 32'd0;
            end

            // 输出方波，占空比为50%
            if (clk_cnt < half_period_cnt) begin
                pwm_out <= 1'b1; // 高电平
            end else begin
                pwm_out <= 1'b0; // 低电平
            end
        end
    end

    // LED 控制逻辑
    assign led1 = pwm_out;  // 当 pwm_out 为高电平时 led1 亮
    assign led2 = ~pwm_out; // 当 pwm_out 为低电平时 led2 亮

endmodule
