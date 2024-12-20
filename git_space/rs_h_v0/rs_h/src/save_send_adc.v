
module save_send_adc(
	input clk_w,
	input rst,
	input clk_r,
	input [15:0] v_data,
	input [15:0] i_data,
	input [15:0] read_cmd,//temp[]    temp[47:32];
	input [15:0] delete_cmd,  //针对MCU读取数据不足1024，FPGA端状态机会卡在某一状态
	input r_en_stm32,
	
	
	output reg save_over,
	output reg save_over_i,
	output reg [15:0] data_out_v,
	output reg [15:0] data_out_i
	
	
);
wire read_en;
wire read_en_i;
reg read_over;
reg  read_start;

assign read_en = (read_cmd == 16'h00cc)?1:0;//标志位 //00aa开始缓存，，00cc开始读取电压，00dd读取完成，00ee读取电流数据    
assign read_en_i = (read_cmd == 16'h00ee)?1:0;
//assign read_over = (read_cmd == 16'h00dd)?1:0;
//assign read_start = (read_cmd == 16'h00aa)?1:0;
reg [2:0]sta;
reg [10:0] cnt_read;
always@(posedge clk_r)begin
	if(~rst)begin
		read_start <= 0;
		sta <= 0;
		cnt_read <= 0;
	end
	else begin
		case(sta)
			3'd0:begin
				if(read_cmd == 16'h00aa)begin
					read_start <= 1;
					sta <= 3'd1;
				end
				else begin
					sta <= 3'd0;
					read_start <= 0;
				end
			end
			3'd1:begin
				if(cnt_read >= 11'd200)begin
					sta <= 3'd2;
					read_start <= 0;
					cnt_read <= 0;
				end
				else begin
					cnt_read <= cnt_read + 1'd1;
					sta <= 3'd1;
				end
			end
			3'd2:begin
				read_start <= 0;
				if(read_cmd == 16'h00cc)begin
					sta <= 3'd0;
				end
				else begin
					sta <= 3'd2;	
				end
			end
		default:sta <= 0;
		endcase
	end
end
reg [3:0] sta0;
reg [9:0] cnt0;
always@(posedge clk_r )begin
	if(!rst)begin
		sta0 <= 0;
		cnt0 <= 0;
		read_over <= 0;
	end
	else begin
		case(sta0)
			4'd0:begin
				if(read_cmd == 16'h00dd)begin
					read_over <= 1;
					sta0 <= 4'd1;
				end
				else begin
					read_over <= 0;
					sta0 <= 4'd0;
				end
			end
			4'd1:begin
				if(cnt0 >= 11'd200)begin
					sta0 <= 4'd2;
					read_over <= 0;
					cnt0 <= 0;
				end
				else begin
					cnt0 <= cnt0 + 1'd1;
					sta0 <= 4'd1;
				end				
			end
			4'd2:begin
				read_over <= 0;
				if(read_cmd == 16'h00aa)begin
					sta0 <= 3'd0;
				end
				else begin
					sta0 <= 3'd2;	
				end
			end
		default:sta0 <= 0;
		endcase
	end
end

/*reg [9:0] addr_in_v_1;
reg [9:0] addr_in_v_2;
reg [9:0] addr_out_v_1;
reg [9:0] addr_out_i_1;*///old
reg [11:0] addr_in_v_1;
reg [11:0] addr_in_v_2;
reg [11:0] addr_out_v_1;
reg [11:0] addr_out_i_1;
wire [15:0] data_out_v_1;
wire [15:0] data_out_i_1;
reg flag_v_save_ok_1;
reg flag_v_save_ok_2;
reg cea_v_1,cea_v_2;
reg ceb_v_1,ceb_v_2;
reg resetb_rom;
//收到接收完成指令，输出数据为16'h0000;
always@(posedge clk_r or negedge rst)begin
	if(!rst)begin
		resetb_rom <= 1;
	end
	else begin
		if(delete_cmd == 16'h00dd)begin
			resetb_rom <= 1;
		end
		else begin
			resetb_rom <= 0;
		end
	end
end


 /*   Gowin_SDPB_adc_data v_adc_data1(
        .dout(data_out_v_1), //output [15:0] dout
        .clka(clk_w), //input clka
        .cea(1), //input cea
        .reseta(0), //input reseta
        .clkb(clk_r), //input clkb
        .ceb(1), //input ceb
        .resetb(0), //input resetb
        .oce(1), //input oce
        .ada(addr_in_v_1), //input [9:0] ada
        .din(v_data), //input [15:0] din
        .adb(addr_out_v_1) //input [9:0] adb
    );	
	
    Gowin_SDPB_adc_data i_adc_data1(
        .dout(data_out_i_1), //output [15:0] dout
        .clka(clk_w), //input clka
        .cea(1), //input cea
        .reseta(0), //input reseta
        .clkb(clk_r), //input clkb
        .ceb(1), //input ceb
        .resetb(0), //input resetb
        .oce(1), //input oce
        .ada(addr_in_v_1), //input [9:0] ada
        .din(i_data), //input [15:0] din
        .adb(addr_out_i_1) //input [9:0] adb
    );		*/
	
   Gowin_SDPB_2048 v_adc_data1(
        .dout(data_out_v_1),     //output [11:0] dout
        .clka(clk_w),     //input clka
        .cea(1),       //input cea
        .reseta(0), //input reseta
        .clkb(clk_r),     //input clkb
        .ceb(1),       //input ceb
        .resetb(0), //input resetb
        .oce(1),       //input oce
        .ada(addr_in_v_1), 	   //input [10:0] ada
        .din(v_data), 	   //input [15:0] din
        .adb(addr_out_v_1) 	   //input [10:0] adb
    );
	
	   Gowin_SDPB_2048 i_adc_data1(
        .dout(data_out_i_1), //output [11:0] dout
        .clka(clk_w), //input clka
        .cea(1), //input cea
        .reseta(0), //input reseta
        .clkb(clk_r), //input clkb
        .ceb(1), //input ceb
        .resetb(0), //input resetb
        .oce(1), //input oce
        .ada(addr_in_v_1), //input [10:0] ada
        .din(i_data), //input [15:0] din
        .adb(addr_out_i_1) //input [10:0] adb
    );



reg [3:0] sta_save;	
always@(posedge clk_w or negedge rst)begin
	if(!rst)begin
		sta_save <= 0;
		addr_in_v_1 <= 0;
		flag_v_save_ok_1 <= 0;
		save_over  <= 0; 
	end
	else begin
		case(sta_save)
			4'd0:begin
				save_over <= 0;
				if(read_start == 1)begin
					sta_save <= 4'd1;
				end
				else begin
					sta_save <= 4'd0;
				end
			end
			4'd1:begin
				if(addr_in_v_1 == 12'd2047)begin//存储使用一个地址
					//老版：1023  新版：2047
					sta_save <= 4'd2;
					flag_v_save_ok_1 <= 1;
					save_over <= 1;
					cea_v_1 <= 0;
					addr_in_v_1 <= 0;
				end
				else begin
					sta_save <= 4'd1;
					flag_v_save_ok_1 <= 0;
					addr_in_v_1 <= addr_in_v_1 + 1'b1;
				end				
			end
			4'd2:begin
				if(read_over == 1)begin
					sta_save <= 4'd0;
				end
				else begin
					sta_save <= 4'd2;
				end
			end
			
		default:sta_save <= 0;
		endcase
	end
end
reg [3:0] sta_send;
reg [9:0] cnt_send;
reg [9:0] cnt_send_i;
always@(posedge clk_r or negedge rst)begin
	if(!rst)begin
		sta_send <= 0;
		cnt_send <= 0;
		addr_out_v_1 <= 0;
		cnt_send_i <= 0;
		addr_out_i_1 <= 0; 
	end
	else begin
		case(sta_send)
			4'd0:begin
				if(read_en == 1)begin
					sta_send <= 4'd1;
				end
				else begin
					sta_send <= 4'd0;
				end
			end
			4'd1:begin
				if(r_en_stm32 == 0)begin
					sta_send <= 4'd2;
				end
				else begin
					sta_send <= 4'd1;
				end
			end
			4'd2:begin
				if(cnt_send >=10'd5)begin
					sta_send <= 4'd3;
					cnt_send <= 0;
				end
				else begin
					cnt_send <= cnt_send + 1'b1;
					sta_send <= 4'd2;
				end
			end
			4'd3:begin
				if(addr_out_v_1 == 12'd2047)begin
					addr_out_v_1 <= 0;
					//sta_send <= 4'd10;
					//电压数据发送完成，开始发送电流数据  
					//老版：1023  新版：2047
					sta_send <= 4'd6;
				end
				else begin
					sta_send <= 4'd4;
				end
			end
			4'd4:begin
				 data_out_v <= data_out_v_1;
				 sta_send <= 4'd5;
			end
			4'd5:begin
				if(r_en_stm32 == 1)begin
					addr_out_v_1 <= addr_out_v_1 + 1'b1;
					sta_send <= 4'd1;
				end
				else begin
					sta_send <= 4'd5;
				end
			end
			//这里读电流数据
			
			4'd6:begin
				if(read_en == 1)begin
					sta_send <= 4'd7;
				end
				else begin
					sta_send <= 4'd6;
				end			
			end
			4'd7:begin
				if(r_en_stm32 == 0)begin
					sta_send <= 4'd8;
				end
				else begin
					sta_send <= 4'd7;
				end			
			end
			4'd8:begin
				if(cnt_send_i >=10'd5)begin
					sta_send <= 4'd9;
					cnt_send_i <= 0;
				end
				else begin
					cnt_send_i <= cnt_send_i + 1'b1;
					sta_send <= 4'd8;
				end			
			
			end
			4'd9:begin
				if(addr_out_i_1 == 12'd2047)begin//老版：1023  新版：2047
					addr_out_i_1 <= 0;
					sta_send <= 4'd10;
				end
				else begin
					sta_send <= 4'd11;
				end			
			end
			4'd11:begin
				 data_out_i <= data_out_i_1;
				 sta_send <= 4'd12;			
			end
			4'd12:begin
				if(r_en_stm32 == 1)begin
					addr_out_i_1 <= addr_out_i_1 + 1'b1;
					sta_send <= 4'd7;
				end
				else begin
					sta_send <= 4'd12;
				end			
			end
			
			4'd10:begin
				if(read_over == 1)begin
					sta_send <= 4'd0;
				end
				else begin
					sta_send <= 4'd10;
				end
			end
			
			
		default:sta_send <= 0;
		endcase
	end
end

endmodule
