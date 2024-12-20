`timescale 1ns/1ps
// vector_iterate_degree
module init_time(clk, rst,cordic_rst, cnt_startDly,cnt_over);

input clk;
input rst;
output cordic_rst;
output cnt_startDly;
output cnt_over;

parameter SIM =0;
wire cordic_rst;
// key_rst 
reg [15:0] counter;
reg clk_en;
reg [7:0]delay_rst;
wire reset_temp;
always @(posedge clk)
    if(counter==15'd49999) begin
	   counter <= 15'd0;
	   clk_en <= 1'b1;
	end else begin
	   counter <= counter + 1;
	   clk_en <= 1'b0;	 
	end	
always @(posedge clk) 
    if(clk_en) begin
	   delay_rst <= {delay_rst[6:0],rst};
	end

assign reset_temp = &{delay_rst[5],!delay_rst[4],!delay_rst[3],!delay_rst[2],!delay_rst[1],!delay_rst[0]};
assign cordic_rst = SIM ? rst : ~reset_temp;



//ip cordic
wire  [16:0]      theta_i=0;
wire [16:0]       x_o,y_o;
wire cnt_last;
//counter
reg [4:0]   cnt =0;
reg         cnt_startDly =0;
wire        cnt_over;
wire        cnt_start;

//address
wire        addr_over;
reg [7:0] addr=0;


//copmare
reg sinOk_r =1;
wire sinCmpOk;
//===========================================================================



//counter
assign cnt_over         = cnt == 18;
assign cnt_start        = cnt == 0;
assign cnt_last         = cnt == 17;



//=============================================================================
//counter
always@(posedge clk)begin
    if(cordic_rst)
        cnt <= 0;
    else if(cnt_over)
        cnt <= 0;
    else
        cnt <= cnt +1;
end

always@(posedge clk)begin
    if(cordic_rst)
        cnt_startDly <= 0;
    else
        cnt_startDly <= cnt_start;
end











endmodule