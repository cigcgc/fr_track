module data_origin(
    input clk,
    input rst,
    input [11:0] adc_in_data,
    input [11:0] mid_value,
    output reg [11:0] adc_in_origin
);
    
    always @ (posedge clk or negedge rst) begin
        if (!rst)
            adc_in_origin <= 0;
        else
            adc_in_origin <= adc_in_data - mid_value;
    end
endmodule
