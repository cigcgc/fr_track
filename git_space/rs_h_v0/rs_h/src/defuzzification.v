//输出量解模糊化
module defuzzification(
    input [6:0] fuzzy_df,
    output reg signed [7:0] df
);
    always @(*) begin
        case (fuzzy_df)
            7'd0: df <= 8'd40;  
            7'd1: df <= 8'd35;  
            7'd2: df <= 8'd30;  
            7'd3: df <= 8'd29;  
            7'd4: df <= 8'd28;  
            7'd5: df <= 8'd27;  
            7'd6: df <= 8'd26;  
            7'd7: df <= 8'd25;  
            7'd8: df <= 8'd24;  
            7'd9: df <= 8'd23;  
            7'd10: df<= 8'd22;  
            7'd11: df<= 8'd21;  
            7'd12: df<= 8'd20;  
            7'd13: df<= 8'd15;  
            7'd14: df<= 8'd14;  
            7'd15: df<= 8'd13;  
            7'd16: df<= 8'd12;  
            7'd17: df<= 8'd11;  
            7'd18: df<= 8'd10;  
            7'd19: df<= 8'd9;  
            7'd20: df<= 8'd8;  
            7'd21: df<= 8'd7;  
            7'd22: df<= 8'd6; 
            7'd23: df<= 8'd5;
            7'd24: df<= -8'sd5;
            7'd25: df<= -8'sd6;
            7'd26: df<= -8'sd8;
            7'd27: df<= -8'sd10;
            7'd28: df<= -8'sd11;
            7'd29: df<= -8'sd12;
            7'd30: df<= -8'sd13;
            7'd31: df<= -8'sd14;
            7'd32: df<= -8'sd15;
            7'd33: df<= -8'sd16;
            7'd34: df<= -8'sd17;
            7'd35: df<= -8'sd18;
            7'd36: df<= -8'sd19;
            7'd37: df<= -8'sd20;
            7'd38: df<= -8'sd21;
            7'd39: df<= -8'sd22;
            7'd40: df<= -8'sd23;
            7'd41: df<= -8'sd24;
            7'd42: df<= -8'sd25;
            7'd43: df<= -8'sd26;
            7'd44: df<= -8'sd27;
            7'd45: df<= -8'sd28;
            7'd46: df<= -8'sd29;
            7'd47: df<= -8'sd30;
            7'd48: df<= -8'sd35;
            default: df = 8'd23; // ZE
        endcase
    end
endmodule
