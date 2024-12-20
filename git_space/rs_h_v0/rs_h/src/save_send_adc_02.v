module save_send_adc_02(
	input clk_w,
	input rst,
	input clk_r,
	input [15:0]v_data,
	
	input [15:0]read_cmd,
	input [15:0]delete_cmd,
	
	
	output reg save_over,
	output reg [15:0] data_out_v

);
wire [15:0] data_out_v_1;
    Gowin_SDPB_02 rom_adc1(
        .dout(data_out_v_1), //output [15:0] dout
        .clka(clk_w), //input clka
        .cea(cea_i), //input cea
        .reseta(reseta_i), //input reseta
        .clkb(clkb_i), //input clkb
        .ceb(1), //input ceb
        .resetb(0), //input resetb
        .oce(1), //input oce
        .ada(v_data), //input [9:0] ada
        .din(din_i), //input [15:0] din
        .adb(adb_i) //input [9:0] adb
    );
reg [3:0] sta_save;	
always@(posedge clk_w or negedge rst)begin
	if(!rst)begin
		sta_save <= 0;
	end
	else begin
		
	end
end	
endmodule