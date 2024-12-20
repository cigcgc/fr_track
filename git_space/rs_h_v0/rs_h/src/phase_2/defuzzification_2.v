//输出量解模糊化
module defuzzification_2(
    input [3:0] fuzzy_df,
    output reg signed [7:0] df
);
    always @(*) begin
        case (fuzzy_df)
            5'd0: df <= 8'd8;  
            5'd1: df <= 8'd7;  
            5'd2: df <= 8'd6;  
            5'd3: df <= 8'd5;  
            5'd4: df <= 8'd4;  
            5'd5: df <= 8'd3;  
            5'd6: df <= 8'd2;  
            5'd7: df <= 8'd1;  
            5'd8: df <= -8'd1;  
            5'd9: df <= -8'd2;  
            5'd10: df <= -8'd3;  
            5'd11: df <= -8'd4;  
            5'd12: df <= -8'd5;  
            5'd13: df <= -8'd6;  
            5'd14: df <= -8'd7;  
            5'd15: df <= -8'd8;  
            5'd16: df <= -8'd9;  
          
            default: df = 8'd1; // ZE
        endcase
    end
endmodule
