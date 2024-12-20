module gen_rfi_i(
input clk,
input rst,
output reg rfi_i



);


always @(posedge clk or negedge rst) begin
		if(!rst) begin
			rfi_i <= 0;
		end 
		else begin
			rfi_i <= 1;
		end
end

endmodule