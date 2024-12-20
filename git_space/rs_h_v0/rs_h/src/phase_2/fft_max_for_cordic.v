

module fft_max_for_cordic(
    input clk,              // 采样时钟
    input rst,              // 复位信号
    input [27:0] fft_real,     // FFT 输出，实部
    input [27:0] fft_imag,   // FFT 输出，虚部
    input opd_o,            // FFT 变换输出数据有效信号
    input [9:0] idx_o,      // FFT 输出索引
    
    output reg [9:0]  max_idx_result,     // 采样频率输出        延长输出结果的持续时间
    output reg [27:0] max_re_result,      // 最大频率分量的实部
    output reg [27:0] max_im_result       // 最大频率分量的虚部
);
parameter MAX_WIDTH = 27;
reg [9:0] max_idx;     // 最大索引输出       临时变量
reg [MAX_WIDTH:0] max_re;     // 最大频率分量的实部
reg [MAX_WIDTH:0] max_im;     // 最大频率分量的虚部

// 定义状态机相关的寄存器
reg [3:0] state;
reg [63:0] max_square;        // 最大模的平方
reg [63:0] current_square;    // 当前模的平方
reg max_real_signed,max_imag_signed; //最大模实部和虚部的符号位
reg [63:0] re_square, im_square;   // 实部和虚部的平方
wire [MAX_WIDTH-1:0] fft_imag_16,fft_real_16;
wire [MAX_WIDTH-1:3] fft_real_whole,fft_imag_whole;
wire [2:0] fft_real_fraction,fft_imag_fraction;

wire fft_real_signed,fft_imag_signed;
reg [9:0]  final_max_idx;     // 最大索引输出        实际的计算结果
reg [MAX_WIDTH:0] final_max_re;      // 最大频率分量的实部
reg [MAX_WIDTH:0] final_max_im;      // 最大频率分量的虚部

assign fft_real_16 = fft_real[MAX_WIDTH-1:0];
assign fft_imag_16 = fft_imag[MAX_WIDTH-1:0];
assign fft_real_whole =  fft_real[MAX_WIDTH-1:3];  // 截断fft变换结果，无符号数
assign fft_imag_whole =  fft_imag[MAX_WIDTH-1:3];
assign fft_real_fraction = fft_real[2:0];
assign fft_imag_fraction = fft_imag[2:0];


assign fft_real_signed =fft_real[MAX_WIDTH];  //提取fft变换结果符号位
assign fft_imag_signed =fft_imag[MAX_WIDTH];

reg debug_transition_update,debug_transition_final,debug_transition_compare;
reg opd_o_prev;  // 用于检测 opdo_o 的上升和下降沿
reg debug_transition_final_prev;
//reg [MAX_WIDTH:0] max_re_result;

// 状态机定义
localparam WAIT_OPD = 0,      // 等待 FFT 数据有效信号
           CHECK_IDX = 1,     // 检查 FFT 索引
           CALC_SQUARE = 2,   // 计算模平方
           COMPARE  = 3,      // 比较当前数据模值
           UPDATE   = 4,      // 更新最大模值及对应信息
           FINALIZE = 5;      // 计算最终结果

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        // 初始化寄存器
        state <= WAIT_OPD;
        max_square <= 0;
        current_square <= 0;
        max_idx <= 0;
        //f_sample <= 0;
        max_re <= 0;
        max_im <= 0;
        debug_transition_update <= 0;
        debug_transition_final <= 0;
        debug_transition_compare <= 0;
        opd_o_prev <= 0;  // 初始化前一个 opd_o
        debug_transition_final_prev <= 0; 
    end else begin
      // 记录前一个时钟周期的 opd_o 状态
        opd_o_prev <= opd_o;
        debug_transition_final_prev <= debug_transition_final;
     
        // 检测 opd_o 下降沿
        if (opd_o_prev == 1 && opd_o == 0) begin
            state <= WAIT_OPD;  // 在 opd_o 从 1 变为 0 时，返回 WAIT_OPD
        end
      if (opd_o == 1) begin
        // 每次状态机进入新状态之前，将调试信号清零
            debug_transition_update <= 0;
            debug_transition_final <= 0;
            debug_transition_compare <= 0;
         case (state)
            WAIT_OPD: begin
                if (opd_o == 1) begin
                    state <= CHECK_IDX;
                end else begin
                    state <= WAIT_OPD;
                end
            end

            CHECK_IDX: begin
                // 检查索引是否等于 2
                if (idx_o == 10'd2) begin
                    state <= CALC_SQUARE;
                end else begin
                    state <= CHECK_IDX;
                end
            end

            CALC_SQUARE: begin
                // 计算实部和虚部的平方
                re_square <= fft_real_whole * fft_real_whole + fft_real_fraction*fft_real_fraction + 2*fft_real_whole*fft_real_fraction;
                im_square <= fft_imag_whole * fft_imag_whole + fft_imag_fraction*fft_imag_fraction + 2*fft_imag_whole*fft_imag_fraction;

                // 计算当前模的平方
                current_square <= re_square + im_square;

                // 转到比较状态
                state <= COMPARE;
            end

            COMPARE: begin
                 debug_transition_compare <= 1;
                // 强制检查 idx_o 是否等于 1023
                if (idx_o > 10'd1020) begin
                    state <= FINALIZE;  // 直接跳转到 FINALIZE
                end else if (current_square > max_square) begin
                    state <= UPDATE;    // 如果当前模值大于最大值，跳转到 UPDATE
                end else begin
                    state <= CALC_SQUARE;  // 否则继续计算
                end
            end

            UPDATE: begin
                debug_transition_update <= 1;
                // 更新最大模的平方和对应的实部、虚部及索引
                max_square <= current_square;
                max_real_signed <= fft_real_signed;
                max_imag_signed <= fft_imag_signed;
                max_re <= {max_real_signed,fft_real_16};
                max_im <= {max_imag_signed,fft_imag_16};
                max_idx <= idx_o;
                
                // 继续比较下一数据
                state <= CALC_SQUARE;
            end

            FINALIZE: begin
                // 计算采样频率并输出结果
                //f_sample <= (max_idx - 1) * 1000000 / 2048;
                debug_transition_final <= 1;
                final_max_idx <= max_idx;
                final_max_re <= max_re;
                final_max_im <= max_im;
                 
                // 检测 debug_transition_final 的上升沿
                    if (!debug_transition_final_prev && debug_transition_final) begin
                        max_re_result <= final_max_re;  // 在上升沿时更新 max_re_result
                        max_im_result <= final_max_im;
                        max_idx_result <= final_max_idx;
                    end
            end

            default: state <= WAIT_OPD;
         endcase
     end else begin 
     final_max_idx <= 0;
     debug_transition_final <= 0;
     debug_transition_compare <=0;
     final_max_re <= 0;
     final_max_im <= 0;
     debug_transition_update <= 0;
  end

 end
end
endmodule
