module fft_max_1024(
    input clk,              // 采样时钟
    input rst,              // 复位信号
    input [31:0] f_out,     // FFT 输出，包括实部和虚部
    input opd_o,            // FFT 变换输出数据有效信号
    input [9:0] idx_o,     // FFT 输出索引
    
    
    output reg [31:0] f_sample,    // 采样频率输出
    output reg [15:0] max_re,      // 最大频率分量的实部
    output reg [15:0] max_im       // 最大频率分量的虚部
);

reg [31:0] r1_oData, r2_oData, r3_oData, r4_oData;
wire [31:0] new_data;
assign new_data = (f_out[31] == 1) ? (~f_out) : f_out;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        r1_oData <= 0;
        r2_oData <= 0;
    end else begin
        r1_oData <= new_data;
        r2_oData <= r1_oData;
    end
end

// 定义状态机相关的寄存器
reg [3:0] sta;
reg [10:0] n;
reg [9:0] r_n;
reg [31:0] max_data;
reg [31:0] final_max_data;  // 比较过程中暂存的最大值
reg [9:0] final_r_n;       // 临时存储的最大值索引
reg eoud_flag;
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        sta <= 0;
        r3_oData <= 0;
        r4_oData <= 0;
        n <= 0;
        r_n <= 0;
        f_sample <= 0;
        max_data <= 0;
        max_re <= 0;        // 最大实部
        max_im <= 0;        // 最大虚部
        eoud_flag <= 0;
    end else begin
        case(sta)
			0:begin //等待FFT 数据有效信号
				if(opd_o == 1)begin
					sta <= 1;
				end
				else begin
					sta <= 0;
				end
			end
			1:begin  //等待 FFT 数据的索引达到 2
				if(idx_o == 10'd2)begin
					sta <= 2;
				end
				else begin
					sta <= 1;
				end
			end
			2:begin //比较 FFT 输出数据，寻找最大值
				if((r1_oData > r2_oData)&&(r1_oData > r3_oData))begin
					r3_oData <= r1_oData;  //更新r3_oData
					sta <= 3;
				end
				else if(idx_o > 10'd1022)begin
					r4_oData <= r4_oData;  //// 更新 r4_oData
					max_data <= r4_oData;  // 存储最大数据
                    max_re <= max_data[31:16];
                    max_im <= max_data[15:0];
					r_n <= n;   // 记录当前最大值的索引
					sta <= 5;
				end
				else begin
					r3_oData <= r3_oData;
					sta <= 2;
				end
			end
			3:begin //更新最大值
				if(r1_oData > r3_oData)begin
					r3_oData <= r1_oData;
					sta <= 4;
				end
				else begin
					r3_oData <= r3_oData;
					sta <= 4;
				end
			end
			4:begin  //继续更新最大数据和索引
				r4_oData <= r3_oData;
				n <= idx_o;
				sta <= 2;
			end
			5:begin
                
				f_sample <= (r_n - 1)*1000000/2048;
				if(opd_o == 0)begin
					r3_oData <= 0;
					sta <= 0;
					n <= 0;
				end
				else begin
					sta <= 5;
				end
				
			end
		default:sta <= 0;
		endcase
	end
end

endmodule
