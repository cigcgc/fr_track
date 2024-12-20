module phase_calculate(
        input wire clk,
        input wire rst,
        input wire fre_done,
        input wire [31:0] last_edge_time,
        input wire [31:0] v_edge_time,    // 来自电压的边沿时间
        input wire [31:0] i_edge_time,    // 来自电流的边沿时间
        input wire [31:0] v_period_time,  // 电压信号的周期时间
        input  [2:0] edge_time_valid,
        output frequency_done,
        output reg signed [31:0] phase_diff, // 相位差输出
        output reg signed[31:0] delta_t,              // 时间间隔 Δt 输出
        output reg m_phase_done

);
reg signed [31:0] mult_result;
reg signed [31:0] phase_diff_temp;
//reg [2:0] flag;

reg phase_calculated; // 用于标记相位差是否已经计算

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        phase_diff <= 0;
        delta_t <= 0;
        phase_calculated <= 0;
        m_phase_done <= 0;
        mult_result <= 0;
        phase_diff_temp <= 0;
        //flag <= 0;
    end else if (fre_done&&edge_time_valid) begin
        // 在 last_edge_time 时刻计算相位差
        
           if(i_edge_time > v_edge_time) begin
            delta_t <= i_edge_time - v_edge_time;
            mult_result <= delta_t * 360;
            phase_diff<= mult_result / v_period_time;
           end else   begin
            delta_t <= v_edge_time - i_edge_time;
            mult_result <= delta_t * 360;
            phase_diff <= -(mult_result / v_period_time);
           end
        
        m_phase_done <= 1;
        //flag <= 0;
    end else if (m_phase_done) begin
        // 在相位差计算完成后，复位 phase_calculated
       // phase_calculated <= 0;
        m_phase_done <= 0;
    end
end

endmodule