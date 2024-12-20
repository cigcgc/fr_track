//基于fft变换和cordic算法计算相位差


module  phase_calculate_fft(
        input clk_1M,
        input clk_2M,
        input rst,
        input [24:0] adc_data_v_25,
        input [24:0] adc_data_i_25,
        input [15:0] stm32_en,
        output reg signed[15:0] phase

);


//fft变换


wire [9:0] idx_v, idx_i;
wire [27:0] xk_re_v,xk_im_v,xk_re_i,xk_im_i;
wire sod_v,ipd_v,eod_v,busy_v,soud_v,opd_v,eoud_v;
wire sod_i,ipd_i,eod_i,busy_i,soud_i,opd_i,eoud_i;



       
FFT_Top_24 FFT_Top_24_v(
		.idx(idx_v), //output [9:0] idx
		.xk_re(xk_re_v), //output [27:0] xk_re
		.xk_im(xk_im_v), //output [27:0] xk_im
		.sod(sod_v), //output sod
		.ipd(ipd_v), //output ipd
		.eod(eod_v), //output eod
		.busy(busy_v), //output busy
		.soud(soud_v), //output soud
		.opd(opd_v), //output opd
		.eoud(eoud_v), //output eoud
		.xn_re(adc_data_v_25), //input [24:0] xn_re
		.xn_im(0), //input [24:0] xn_im
		.start(1), //input start
		.clk(clk_1M), //input clk
		.rst(~rst) //input rst
	);

FFT_Top_24 FFT_Top_new_i(
		.idx(idx_i), //output [9:0] idx
		.xk_re(xk_re_i), //output [27:0] xk_re
		.xk_im(xk_im_i), //output [27:0] xk_im
		.sod(sod_i), //output sod
		.ipd(ipd_i), //output ipd
		.eod(eod_i), //output eod
		.busy(busy_i), //output busy
		.soud(soud_i), //output soud
		.opd(opd_i), //output opd
		.eoud(eoud_i), //output eoud
		.xn_re(adc_data_i_25), //input [24:0] xn_re
		.xn_im(0), //input [24:0] xn_im
		.start(1), //input start
		.clk(clk_1M), //input clk
		.rst(~rst) //input rst
	);

    wire [27:0] max_re_v; // 电压最大模值的实部
    wire [27:0] max_im_v; // 电压最大模值的虚部
    wire [9:0] max_idx_v; // 电压最大模值的索引
    wire [27:0] max_re_i; // 电流最大模值的实部
    wire [27:0] max_im_i; // 电流最大模值的虚部
    wire [9:0] max_idx_i;  // 电流最大模值的索引

 fft_max_for_cordic fft_max_v(
	.clk(clk_2M),//采样时钟
	.rst(rst),
	.fft_real(xk_re_v),  //input [27:0] fft_real,
    .fft_imag(xk_im_v),  //input [27:0] fft_imag,
	.opd_o(opd_v),
	.idx_o(idx_v),
	.max_idx_result(max_idx_v),  //  output reg [9:0]  max_idx_result
    .max_re_result(max_re_v),    //  output reg [27:0] max_re_result
    .max_im_result(max_im_v)     //  output reg [27:0] max_im_result

);
 fft_max_for_cordic fft_max_i(
	.clk(clk_2M),//采样时钟
	.rst(rst),
	.fft_real(xk_re_i),
    .fft_imag(xk_im_i),
	.opd_o(opd_i),
	.idx_o(idx_i),
	.max_idx_result(max_idx_i),
    .max_re_result(max_re_i),
    .max_im_result(max_im_i)       

);
parameter FFT_MAX_WIDTH = 27;
parameter FFT_WHOLE_WIDTH = 24;
parameter FFT_FRACTION_WIDTH = 3;
parameter EXTEND_WIDTH = 7;
wire fft_re_signed_v,  fft_im_signed_v, fft_re_signed_i,  fft_im_signed_i;
wire [FFT_WHOLE_WIDTH-1:0] fft_re_whole_num_v,fft_im_whole_num_v,fft_re_whole_num_i,fft_im_whole_num_i;
wire [30:0] fft_re_whole_extend_v,fft_im_whole_extend_v,fft_re_whole_extend_i,fft_im_whole_extend_i;
wire [31:0] cordic_re_num_v,cordic_im_num_v,cordic_re_num_i,cordic_im_num_i;

assign fft_re_signed_v = max_re_v[FFT_MAX_WIDTH];
assign fft_im_signed_v = max_im_v[FFT_MAX_WIDTH];
assign fft_re_signed_i = max_re_i[FFT_MAX_WIDTH];
assign fft_im_signed_i = max_im_i[FFT_MAX_WIDTH];
assign fft_re_fraction_i = max_re_i[FFT_FRACTION_WIDTH-1:0];
assign fft_im_fraction_i = max_im_i[FFT_FRACTION_WIDTH-1:0];
assign fft_re_whole_num_v = max_re_v[FFT_MAX_WIDTH-1:FFT_FRACTION_WIDTH];
assign fft_im_whole_num_v = max_im_v[FFT_MAX_WIDTH-1:FFT_FRACTION_WIDTH];
assign fft_re_whole_num_i = max_re_i[FFT_MAX_WIDTH-1:FFT_FRACTION_WIDTH];
assign fft_im_whole_num_i = max_im_i[FFT_MAX_WIDTH-1:FFT_FRACTION_WIDTH];
assign fft_re_whole_extend_v = { {EXTEND_WIDTH{1'b0}}, fft_re_whole_num_v } ;     
assign fft_im_whole_extend_v = { {EXTEND_WIDTH{1'b0}}, fft_im_whole_num_v } ;    
assign fft_re_whole_extend_i = { {EXTEND_WIDTH{1'b0}}, fft_re_whole_num_i }  ;   
assign fft_im_whole_extend_i = { {EXTEND_WIDTH{1'b0}}, fft_im_whole_num_i }  ;
assign cordic_re_num_v = {fft_re_signed_v,fft_re_whole_extend_v};
assign cordic_im_num_v = {fft_im_signed_v,fft_im_whole_extend_v};
assign cordic_re_num_i = {fft_re_signed_i,fft_re_whole_extend_i};
assign cordic_im_num_i = {fft_im_signed_i,fft_im_whole_extend_i};
  
wire [31:0]  phase_v,mo_value_v,phase_i,mo_value_i;
wire cordic_valid_v,cordic_valid_i;
MY_CORDIC MY_CORDIC_v(
          .sys_clk(clk_1M) ,
          .sys_rst(rst) ,

          .x  (cordic_re_num_v)     ,
          .y  (cordic_im_num_v)    ,

          .phase (phase_v)  ,
          .mo_value(mo_value_v),
          .valid(cordic_valid_v)
);
MY_CORDIC MY_CORDIC_i(
          .sys_clk(clk_1M) ,
          .sys_rst(rst) ,

          .x  (cordic_re_num_i)     ,
          .y  (cordic_im_num_i)    ,

          .phase (phase_i)  ,
          .mo_value(mo_value_i),
          .valid(cordic_valid_i)
);
wire [14:0]angle_degree_v,angle_degree_i;

assign angle_degree_v = phase_v[14:0];
assign angle_degree_i = phase_i[14:0] ;
reg   [14:0] phase_v_i_unsigned;
//reg   [9:0] phase_tem;

 reg         out_signed          ;  // 相位差的符号
 always @ (posedge clk_1M or negedge rst) begin
        if (!rst) begin
             out_signed <= 0;
        end else begin
            if(stm32_en) begin
              if (angle_degree_v > angle_degree_i)begin
                phase_v_i_unsigned <= angle_degree_v - angle_degree_i;
                //phase_tem <= phase_v_i_unsigned[15:8];
                out_signed <= 1;  
             end else if (angle_degree_v < angle_degree_i)begin
                phase_v_i_unsigned <= angle_degree_i - angle_degree_v;
                //phase_tem <= phase_v_i_unsigned[15:8];
                out_signed <= 0;
             end
            
               // phase <= out_signed ? {out_signed, (~phase_v_i_unsigned)+1} : {out_signed, phase_v_i_unsigned};
                  phase <= {out_signed,phase_v_i_unsigned};

            end
       end
end

endmodule