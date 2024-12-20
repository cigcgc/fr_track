module jiema_fsmc(
	input clk,
	input rst,
	input [79:0]temp,
	
	output [15:0] phase_en,
	output [15:0]adc_sample_en,
	output [15:0]adc_read_en,
	output [15:0] mcp41010
);
always@(posedge clk or negedge rst)begin
	if(!rst)begin
		phase_en      <= 0;
		adc_sample_en <= 0;
		adc_read_en   <= 0;
		mcp41010      <= 0;
	end
	else begin
		phase_en <= temp[15:0];
		adc_sample_en <= temp[31:16];
		adc_read_en <= temp[47:32];
		mcp41010  <= temp[63:48];
	end
end
endmodule