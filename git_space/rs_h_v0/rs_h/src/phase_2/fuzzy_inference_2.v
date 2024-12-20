
//模糊推理规则

module fuzzy_inference_2(
    input [4:0] fuzzy_EC,
    output reg [4:0] fuzzy_df
);
    always @(*) begin
        case ( fuzzy_EC)
          
            5'd0: fuzzy_df <= 5'd0;  // ZE, NBB -> NS
            5'd1: fuzzy_df <= 5'd1;  // ZE, NBS -> NS
            5'd2: fuzzy_df <= 5'd2;  // ZE, NM -> ZE
            5'd3: fuzzy_df <= 5'd3;  // ZE, NS -> ZE
            5'd4: fuzzy_df <= 5'd4;  // ZE, ZE -> ZE
            5'd5: fuzzy_df <= 5'd5;  // ZE, PS -> ZE
            5'd6: fuzzy_df <= 5'd6;  // ZE, PM -> ZE
            5'd7: fuzzy_df <= 5'd7;  // ZE, PSB -> PS
            5'd8: fuzzy_df <= 5'd8;  // ZE, PBB -> PS
            5'd9: fuzzy_df <= 5'd9;  // ZE, NBB -> NS
            5'd10: fuzzy_df <= 5'd10;  // ZE, NBS -> NS
            5'd11: fuzzy_df <= 5'd11;  // ZE, NM -> ZE
            5'd12: fuzzy_df <= 5'd12;  // ZE, NS -> ZE
            5'd13: fuzzy_df <= 5'd13;  // ZE, ZE -> ZE
            5'd14: fuzzy_df <= 5'd14;  // ZE, PS -> ZE
            5'd15: fuzzy_df <= 5'd15;  // ZE, PM -> ZE
            5'd16: fuzzy_df <= 5'd16;  // ZE, PSB -> PS
          
            

            default: fuzzy_df <= 5'd7; // Default to ZE
        endcase
    end
endmodule
