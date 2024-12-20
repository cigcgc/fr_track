
//将输入量模糊化

module fuzzification_2(
	input clk,
	input rst,
    input [15:0] EC, // 16-bit input for EC
    output reg [4:0] fuzzy_EC // 4-bit fuzzy output for EC
);
	
always @(posedge clk or negedge rst) begin
	if(!rst)begin
		fuzzy_EC <= 0;
	end
	else begin

        // 模糊化EC
        if (EC <= -16'd80)
            fuzzy_EC <= 5'd0; // NBB (负超大)
        else if (EC <= -16'd70)
            fuzzy_EC <= 5'd1; // NBS (负大)
        else if (EC <= -16'd60)
            fuzzy_EC <= 5'd2; // NM (负中)
        else if (EC <= -16'd50)
            fuzzy_EC <= 5'd3; // NS (负小)
        else if (EC <= -16'd40)
            fuzzy_EC <= 5'd4; // NS (负小)
        else if (EC <= -16'd30)
            fuzzy_EC <= 5'd5; // ZE (接近0)
        else if (EC <= -16'd20)
            fuzzy_EC <= 5'd6; // PS (正小)
        else if (EC <= -16'd15)
            fuzzy_EC <= 5'd7; // PM (正中)
        else if (EC <= 16'd15)
            fuzzy_EC <= 5'd8; // PSB (正中大)
        else if (EC <= 16'd20)
            fuzzy_EC <= 5'd9; // ZE (接近0)
        else if (EC <= 16'd30)
            fuzzy_EC <= 5'd10; // PS (正小)
        else if (EC <= 16'd40)
            fuzzy_EC <= 5'd11; // PM (正中)
        else if (EC <= 16'd50)
            fuzzy_EC <= 5'd12; // PSB (正中大)
        else if (EC <= 16'd60)
            fuzzy_EC <= 5'd13; // PS (正小)
        else if (EC <= 16'd70)
            fuzzy_EC <= 5'd14; // PM (正中)
        else if (EC <= 16'd80)
            fuzzy_EC <= 5'd15; // PSB (正中大)
        else
            fuzzy_EC <= 5'd16; // PBB (正超大)
    end
end
	
	
endmodule
