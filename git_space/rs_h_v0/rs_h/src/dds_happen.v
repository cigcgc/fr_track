module dds_happen(
	input clk,
	input rst,
	input en,
	input [31:0] fword,
	input [10:0] pword,
	
	output [10:0] dds_out
);


reg [31:0] fre_acc;
always@(posedge clk or negedge rst)begin
	if(!rst)
		fre_acc <= 32'd0;
	else if(!en)
		fre_acc <= 32'd0;
	else 
		fre_acc <= fre_acc + fword;
end
reg [10:0] rom_addr;
always@(posedge clk or negedge rst)begin
	if(!rst)
		rom_addr <= 12'd0;
	else if(!en)
		rom_addr <= 12'd0;
	else 
		rom_addr <= fre_acc[31:21] + pword;
end




    Gowin_pROM rom_2048_11(
        .dout(dds_out), //output [10:0] dout
        .clk(clk), //input clk
        .oce(1), //input oce
        .ce(en), //input ce
        .reset(~rst), //input reset
        .ad(rom_addr) //input [10:0] ad
    );


endmodule