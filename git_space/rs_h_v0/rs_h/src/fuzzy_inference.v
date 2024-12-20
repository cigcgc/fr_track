
//模糊推理规则

module fuzzy_inference(
    input [6:0] fuzzy_EC,
    output reg [6:0] fuzzy_df
);
    always @(*) begin
        case ( fuzzy_EC)
          
            7'd0: fuzzy_df <= 7'd0;  // ZE, NBB -> NS
            7'd1: fuzzy_df <= 7'd1;  // ZE, NBS -> NS
            7'd2: fuzzy_df <= 7'd2;  // ZE, NM -> ZE
            7'd3: fuzzy_df <= 7'd3;  // ZE, NS -> ZE
            7'd4: fuzzy_df <= 7'd4;  // ZE, ZE -> ZE
            7'd5: fuzzy_df <= 7'd5;  // ZE, PS -> ZE
            7'd6: fuzzy_df <= 7'd6;  // ZE, PM -> ZE
            7'd7: fuzzy_df <= 7'd7;  // ZE, PSB -> PS
            7'd8: fuzzy_df <= 7'd8;  // ZE, PBB -> PS
            7'd9: fuzzy_df <= 7'd9;  // ZE, NBB -> NS
            7'd10: fuzzy_df <= 7'd10;  // ZE, NBS -> NS
            7'd11: fuzzy_df <= 7'd11;  // ZE, NM -> ZE
            7'd12: fuzzy_df <= 7'd12;  // ZE, NS -> ZE
            7'd13: fuzzy_df <= 7'd13;  // ZE, ZE -> ZE
            7'd14: fuzzy_df <= 7'd14;  // ZE, PS -> ZE
            7'd15: fuzzy_df <= 7'd15;  // ZE, PM -> ZE
            7'd16: fuzzy_df <= 7'd16;  // ZE, PSB -> PS
            7'd17: fuzzy_df <= 7'd17;  // ZE, NBB -> NS
            7'd18: fuzzy_df <= 7'd18;  // ZE, NBS -> NS
            7'd19: fuzzy_df <= 7'd19;  // ZE, NM -> ZE
            7'd20: fuzzy_df <= 7'd20;  // ZE, NS -> ZE
            7'd21: fuzzy_df <= 7'd21;  // ZE, ZE -> ZE
            7'd22: fuzzy_df <= 7'd22;  // ZE, PS -> ZE
            7'd23: fuzzy_df <= 7'd23;  // ZE, PM -> ZE
            7'd24: fuzzy_df <= 7'd24;  // ZE, PSB -> PS
            7'd25: fuzzy_df <= 7'd25;  // ZE, PBB -> PS
            7'd26: fuzzy_df <= 7'd26;  // ZE, NBB -> NS
            7'd27: fuzzy_df <= 7'd27;  // ZE, NBS -> NS
            7'd28: fuzzy_df <= 7'd28;  // ZE, NM -> ZE
            7'd29: fuzzy_df <= 7'd29;  // ZE, NS -> ZE
            7'd30: fuzzy_df <= 7'd30;  // ZE, ZE -> ZE
            7'd31: fuzzy_df <= 7'd31;  // ZE, PS -> ZE
            7'd32: fuzzy_df <= 7'd32;  // ZE, PM -> ZE
            7'd33: fuzzy_df <= 7'd33;  // ZE, PSB -> PS
            7'd34: fuzzy_df <= 7'd34;  // ZE, NBB -> NS
            7'd35: fuzzy_df <= 7'd35;  // ZE, NBS -> NS
            7'd36: fuzzy_df <= 7'd36;  // ZE, NM -> ZE
            7'd37: fuzzy_df <= 7'd37;  // ZE, NS -> ZE
            7'd38: fuzzy_df <= 7'd38;  // ZE, ZE -> ZE
            7'd39: fuzzy_df <= 7'd39;  // ZE, PS -> ZE
            7'd40: fuzzy_df <= 7'd40;  // ZE, PM -> ZE
            7'd41: fuzzy_df <= 7'd41;  // ZE, PSB -> PS
            7'd42: fuzzy_df <= 7'd42;  // ZE, PBB -> PS
            7'd43: fuzzy_df <= 7'd42;  // ZE, NBB -> NS
            7'd44: fuzzy_df <= 7'd44;  // ZE, NBS -> NS
            7'd45: fuzzy_df <= 7'd45;  // ZE, NM -> ZE
            7'd46: fuzzy_df <= 7'd45;  // ZE, NS -> ZE
            7'd47: fuzzy_df <= 7'd47;  // ZE, ZE -> ZE
            7'd48: fuzzy_df <= 7'd48;
          
            default: fuzzy_df <= 5'd23; // Default to ZE
        endcase
    end
endmodule
