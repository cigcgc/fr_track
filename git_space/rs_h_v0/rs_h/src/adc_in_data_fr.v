module adc_in_data_fr(
    input wire [11:0] adc_in_v,
    input wire [11:0] adc_in_i,
    output wire [11:0] adc_in_v_fr,
    output wire [11:0] adc_in_i_fr
);
    // 减去 1228
    assign adc_in_v_fr = adc_in_v - 16'd1228;
    assign adc_in_i_fr = adc_in_i - 16'd1228;
endmodule
