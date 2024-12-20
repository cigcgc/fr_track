/*
module peak_det(input            clk,
                input            rst_n,
					 input            sink_sop_a,
					 input            sink_eop_a,
					 input            sink_valid_a,
					 input	[15:0]	sink_real_a,
	             input	[15:0]	sink_imag_a,
					 input            sink_sop_b,
					 input            sink_eop_b,
					 input            sink_valid_b,
					 input	[15:0]	sink_real_b,
	             input	[15:0]	sink_imag_b,
					 output [15:0]    peak_real_a,
					 output [15:0]    peak_imag_a,
					 output [15:0]    peak_real_b,
					 output [15:0]    peak_imag_b
					 );
wire [31:0] mod_a,mod_b;
reg [31:0]  mod_a_temp,mod_b_temp;
wire [31:0] real_a_2,real_b_2,imag_a_2,imag_b_2;
reg [15:0] peak_real_a_r,peak_imag_a_r,peak_real_b_r,peak_imag_b_r;
reg [15:0] peak_real_a_temp,peak_imag_a_temp,peak_real_b_temp,peak_imag_b_temp;
reg        valid_a_r,valid_b_r;
assign mod_a = real_a_2+imag_a_2;
assign mod_b = real_b_2+imag_b_2;
assign peak_real_a = peak_real_a_r;
assign peak_imag_a = peak_imag_a_r;
assign peak_real_b = peak_real_b_r;
assign peak_imag_b = peak_imag_b_r;
reg peak_flag_1,peak_flag_2,peak_flag_3;
always@(posedge clk or negedge rst_n)begin
if(!rst_n) begin
	 peak_real_a_r <= 16'd0;
	 peak_imag_a_r <= 16'd0;
	 peak_real_a_temp <= 16'd0;
	 peak_imag_a_temp <= 16'd0;
	 mod_a_temp       <= 0;
	 
	 peak_real_b_r <= 16'd0;
	 peak_imag_b_r <= 16'd0;
	 peak_real_b_temp <= 16'd0;
	 peak_imag_b_temp <= 16'd0;
	 mod_b_temp       <= 0;
     //peak_flag_1 <= 0;
    // peak_flag_2 <= 0;
     peak_flag_3 <= 0;
	 end
 else
    begin
	  if(sink_valid_a)
	     begin
          peak_flag_3 <= 1;
		  mod_a_temp       <= (mod_a > mod_a_temp)?mod_a:mod_a_temp;
		  peak_real_a_temp <= (mod_a > mod_a_temp)?sink_real_a:peak_real_a_temp;
		  peak_imag_a_temp <= (mod_a > mod_a_temp)?sink_imag_a:peak_imag_a_temp;
		  
		  mod_b_temp       <= (mod_b > mod_b_temp)?mod_b:mod_b_temp;
		  peak_real_b_temp <= (mod_b > mod_b_temp)?sink_real_b:peak_real_b_temp;
		  peak_imag_b_temp <= (mod_b > mod_b_temp)?sink_imag_b:peak_imag_b_temp;
          
          peak_real_a_r <= peak_real_a_temp;
		  peak_imag_a_r <= peak_imag_a_temp;
		  
		  peak_real_b_r <= peak_real_b_temp;
		  peak_imag_b_r <= peak_imag_b_temp;
		  end
	 end
end

Integer_Multiplier_Top mult_u0(
    .mul_a(sink_real_a),
    .mul_b(sink_real_a),
    .product(real_a_2)
);
Integer_Multiplier_Top mult_1(
    .mul_a(sink_real_b),
    .mul_b(sink_real_b),
    .product(real_b_2)
);
Integer_Multiplier_Top mult_2(
    .mul_a(sink_imag_a),
    .mul_b(sink_imag_a),
    .product(imag_a_2)
);
Integer_Multiplier_Top mult_3(
    .mul_a(sink_imag_b),
    .mul_b(sink_imag_b),
    .product(imag_b_2)
);
endmodule 
*/