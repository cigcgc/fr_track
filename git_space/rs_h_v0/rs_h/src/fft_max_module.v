module FFT_Max_Module (
    input wire clk,
    input wire rst,
    input wire opd_o,               // fft变换输出数据有效信号
    input wire soud_o,              //  fft变换输出数据结束信号
    input wire [9:0] idx,
    input wire [15:0] xk_re,
    input wire [15:0] xk_im,
    output reg [15:0] max_re,
    output reg [15:0] max_im,
    output reg [9:0] max_idx,
    output reg max_done
);

    reg [63:0] current_mod_sq;     // 当前模的平方 
    reg [15:0] max_re_tem; // 最大模值的实部
    reg [15:0] max_im_tem; // 最大模值的虚部
    reg [9:0] max_idx_tem;  // 最大模值的索引 
    reg [63:0] max_mod_sq;                  // 最大模的平方
    reg max_calculated;               // 标志位，表示最大值是否已经计算过
    reg fft_flag_max ;   //测试临时最大模的时刻
     reg fft_flag_index ; //测试是否避开第一个直流分量
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            max_mod_sq <= 0;
            max_re <= 0;
            max_im <= 0;
            max_idx <= 0;
            max_calculated <= 0;
            max_done <= 0 ;
            fft_flag_max <= 0;
            fft_flag_index <= 0;
        end else begin
            if (opd_o && !max_calculated) begin
              if (idx!=0) begin
                // 开始计算最大模值，初始化变量
                 fft_flag_index <= 1;
                current_mod_sq <= xk_re * xk_re + xk_im * xk_im;
                if (current_mod_sq > max_mod_sq) begin
                    fft_flag_max <= 1;
                    max_mod_sq <= current_mod_sq;
                    max_re_tem <= xk_re;
                    max_im_tem <= xk_im;
                    max_idx_tem <= idx;
                end
              end
                     if(soud_o)begin
                        max_re <= max_re_tem;
                        max_im <= max_im_tem;
                        max_idx <= max_idx_tem;
                        max_done <= 1;
                        max_calculated <= 1;  // 标志位置1，表示计算完成
                     end
               

                
            end else if (!opd_o) begin
                // 当 rd_dout_en 变低时，重置标志位，准备下一次计算
                max_calculated <= 0;
                max_done <= 0;
                fft_flag_max <= 0;
                 fft_flag_index <= 0;
            end
        end
    end
endmodule