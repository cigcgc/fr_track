module init_cordic_time(
    input wire clk,      // 1MHz时钟信号
    input wire rst,      // 复位信号
    output reg pulse_out // 输出脉冲信号
);

    // 定义参数
    localparam HIGH_TIME = 200; // 高电平持续时间200us（对应200个时钟周期）
    localparam LOW_TIME = 200;   // 低电平持续时间50us（对应50个时钟周期）
    
    reg [7:0] cnt;             // 计数器，用于计数时钟周期
    reg state;                 // 状态机，0表示低电平，1表示高电平

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            cnt <= 0;
            state <= 1'b0;
            pulse_out <= 1'b0;
        end else begin
            if (state == 1'b1) begin
                // 高电平阶段
                if (cnt < HIGH_TIME - 1) begin
                    cnt <= cnt + 1;
                end else begin
                    cnt <= 0;
                    state <= 1'b0;    // 切换到低电平
                    pulse_out <= 1'b0;
                end
            end else begin
                // 低电平阶段
                if (cnt < LOW_TIME - 1) begin
                    cnt <= cnt + 1;
                end else begin
                    cnt <= 0;
                    state <= 1'b1;    // 切换到高电平
                    pulse_out <= 1'b1;
                end
            end
        end
    end

endmodule
