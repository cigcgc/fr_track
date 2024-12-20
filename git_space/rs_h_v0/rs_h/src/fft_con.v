module fft_con(
	input clk,//采样时钟
	input rst,
	input [31:0]f_out,
	input opd_o,
	input [10:0]idx_o,
    
	
	output reg [31:0] f_sample

);

reg [31:0]r1_oData,r2_oData,r3_oData,r4_oData;
wire [31:0] new_data;
assign  new_data = (f_out[31] == 1)?(~f_out):f_out;
always@(posedge clk or negedge rst)begin
	if(!rst)begin
		r1_oData <= 0;
		r2_oData <= 0;
	end
	else begin
		r1_oData <= new_data;
		r2_oData <= r1_oData;
	end
end

reg [3:0] sta;
reg [10:0] n;
reg [10:0] r_n;
reg [31:0] max_data;

always@(posedge clk or negedge rst)begin
	if(!rst)begin
		sta <= 0;
		r3_oData <= 0;
		r4_oData <= 0;
		n <= 0;
		r_n <= 0;
		f_sample <= 0;
		max_data <= 0;
	end
	else begin
		case(sta)
			0:begin
				if(opd_o == 1)begin
					sta <= 1;
				end
				else begin
					sta <= 0;
				end
			end
			1:begin
				if(idx_o == 11'd2)begin
					sta <= 2;
				end
				else begin
					sta <= 1;
				end
			end
			2:begin
				if((r1_oData > r2_oData)&&(r1_oData > r3_oData))begin
					r3_oData <= r1_oData;
					sta <= 3;
				end
				else if(idx_o > 11'd1024)begin
					r4_oData <= r4_oData;
					max_data <= r4_oData;
					r_n <= n;
					sta <= 5;
				end
				else begin
					r3_oData <= r3_oData;
					sta <= 2;
				end
			end
			3:begin
				if(r1_oData > r3_oData)begin
					r3_oData <= r1_oData;
					sta <= 4;
				end
				else begin
					r3_oData <= r3_oData;
					sta <= 4;
				end
			end
			4:begin
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