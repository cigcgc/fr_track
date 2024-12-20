module fre_calculate(
    input wire clk,
    input wire rst,
    input wire  v_square,     // 电压方波信号输入
    input wire  i_square,     // 电流方波信号输入
    input wire square_done,
    output reg [15:0] frequency_v,  // 电压信号频率输出
    output reg [15:0] frequency_i,  // 电流信号频率输出
    output reg [31:0] v_edge_time,  // 电压信号边沿时间输出
    output reg [31:0] i_edge_time,  // 电流信号边沿时间输出
    output reg [31:0] v_period_time, // 电压信号周期时间输出
    output reg [31:0] last_edge_time, // 上一个周期的边沿时间
    output reg [2:0] edge_time_valid,       // 边沿时间有效标志
    output reg fre_done
);

parameter SYS_CLOCK_FREQ = 100_000_000; // 系统时钟频率（单位：100MHz）

reg [31:0] v_edge_time_1, v_edge_time_2;
reg [31:0] i_edge_time_1, i_edge_time_2;
reg [31:0] i_period_time;
reg [3:0] v_edge_count, i_edge_count;
reg prev_v_square, prev_i_square;
reg [31:0] time_counter;
reg v_calculated, i_calculated,v_flag;
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
                end
                
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
                end
                
            end

            // 更新 last_edge_time 和 edge_time_valid
            if (v_calculated ==1 && i_calculated == 1) begin
                edge_time_valid <= 1;
                end
              
            


            time_counter <= time_counter + 1;
            fre_done <= 1;
        end
    end
end

endmodule
