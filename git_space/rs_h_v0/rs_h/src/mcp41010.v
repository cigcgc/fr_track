`timescale 1ns / 1ns
module mcp41010(
	input clk,
	input rst,
	input tx_en,
	input [7:0] data_in,//电位器命令，，由串口输入，，      0001 0001 八位编码  2进制
						//							   0000 0000 八位编码  2进制
						//  						   01   01    _ _;	   16进制					
	output  reg tx_done,
	output  reg mosi,
	output  reg sclk,
	output  reg cs
);
reg [5:0] spi_sta;
reg [5:0] sta;

always@(posedge clk)begin
	if(!rst)begin
		mosi <= 0;
		sclk <= 0;
		cs <= 1;
		tx_done <= 1;
		spi_sta <= 0;
		sta <= 0;
	end
	else begin
		case(spi_sta)
			0:begin
				cs <= 1;
				if(tx_en)begin
					spi_sta <= 1;
				end
				else begin
					spi_sta <= 0;
					cs <= 1;
					tx_done <= 0;
					sclk <= 0;
					mosi <= 0;
					sta <= 0;
				end
			end
			1:begin
				spi_sta <= 2;
				sta <= 0;
			end
			2:begin
				cs <= 0;
				case(sta)
					6'd1,6'd3,6'd5,6'd7,6'd9,6'd11,6'd13,6'd15,6'd17,6'd19,
					6'd21,6'd23,6'd25,6'd27,6'd29:begin
						sclk <= 1;
						sta <= sta + 1; 
						tx_done <= 0;
					end
					0:begin
						mosi <= 1'b0;//data_in[15];
						sclk <= 0;
						sta <= sta + 1;
						tx_done <= 0;
					end
					2:begin
						mosi <= 1'b0;//data_in[14];
						sclk <= 0;
						sta <= sta + 1;
						tx_done <= 0;						
					end
					4:begin
						mosi <= 1'b0;//data_in[13];
						sclk <= 0;
						sta <= sta + 1;
						tx_done <= 0;						
					end
					6:begin
						mosi <= 1'b1;//data_in[12];
						sclk <= 0;
						sta <= sta + 1;
						tx_done <= 0;						
					end
					8:begin
						mosi <= 1'b0;//data_in[11];
						sclk <= 0;
						sta <= sta + 1;
						tx_done <= 0;						
					end
					10:begin
						mosi <= 1'b0;//data_in[10];
						sclk <= 0;
						sta <= sta + 1;
						tx_done <= 0;						
					end
					12:begin
						mosi <= 1'b0;//data_in[9];
						sclk <= 0;
						sta <= sta + 1;
						tx_done <= 0;						
					end
					14:begin
						mosi <= 1'b1;//data_in[8];
						sclk <= 0;
						sta <= sta + 1;
						tx_done <= 0;						
					end
					16:begin
						mosi <= data_in[7];
						sclk <= 0;
						sta <= sta + 1;
						tx_done <= 0;						
					end
					18:begin
						mosi <= data_in[6];
						sclk <= 0;
						sta <= sta + 1;
						tx_done <= 0;						
					end
					20:begin
						mosi <= data_in[5];
						sclk <= 0;
						sta <= sta + 1;
						tx_done <= 0;						
					end
					22:begin
						mosi <= data_in[4];
						sclk <= 0;
						sta <= sta + 1;
						tx_done <= 0;						
					end
					24:begin
						mosi <= data_in[3];
						sclk <= 0;
						sta <= sta + 1;
						tx_done <= 0;						
					end
					26:begin
						mosi <= data_in[2];
						sclk <= 0;
						sta <= sta + 1;
						tx_done <= 0;						
					end
					28:begin
						mosi <= data_in[1];
						sclk <= 0;
						sta <= sta + 1;
						tx_done <= 0;						
					end
					30:begin
						mosi <= data_in[0];
						sclk <= 0;
						sta <= sta + 1;
						tx_done <= 0;						
					end
					31:begin
						sclk <= 1;
						tx_done <= 1;
						sta <= sta;
						spi_sta <= 0;
					end
				default:sta <= 0;
				endcase
			end
		default:spi_sta <= 0;
		endcase
	end
end
endmodule