module save_fsmc(
	input clk,
	input rst,
	input cs,
	input w_en,
	input r_en,
	input [7:0] addr,
	inout [15:0] data_in,
	//output reg [15:0] start_frequency_low,
    //output reg [15:0] start_frequency_high,
	output [175:0]temp,
	
	
	/*
	//ARM写入的数据
	output phase_start,
	output adc_start_save,
	output adc_start_read,
	output [7:0] mcp41010_1,
	output [7:0] mcp41010_2,
	*/
	//ARM读取的数据
	input [7:0]  phase_done,
	input [15:0] phase_v_i,
	input [7:0]  adc_save_done,
	input [15:0] adc_data_v,
	input [15:0] adc_data_i,
	input [15:0] fft_v,
	input [15:0] fft_i,
	input [15:0] d_phase_v_i,
	input [2:0]Version_Number,
 	
	input [15:0] phase_diff,
    input [15:0] drive_frequency_low,
    input [15:0] drive_frequency_high,
    input  frequency_done,
    input start_fuzzy_pid_control,
    input start_pid_control,
    input  [31:0] frequency_v,
    input  [11:0] r_adc_data_v,
    input  [11:0] r_adc_data_i
    

);
reg [15:0] out_data_0,out_data_10,out_data_20,out_data_30;
reg [15:0] out_data_1,out_data_11,out_data_21,out_data_31;
reg [15:0] out_data_2,out_data_12,out_data_22,out_data_32;
reg [15:0] out_data_3,out_data_13,out_data_23,out_data_33;
reg [15:0] out_data_4,out_data_14,out_data_24,out_data_34;
reg [15:0] out_data_5,out_data_15,out_data_25,out_data_35;
reg [15:0] out_data_6,out_data_16,out_data_26,out_data_36;
reg [15:0] out_data_7,out_data_17,out_data_27,out_data_37;
reg [15:0] out_data_8,out_data_18,out_data_28,out_data_38;
reg [15:0] out_data_9,out_data_19,out_data_29,out_data_39;
reg [15:0] out_data_40;
reg rd;
reg wr;
reg [15:0] indata;
//assign rd =cs && r_en; //get rd pulse  ____|~~~~|______
//assign wr =cs && w_en ; //get wr pulse  ____|~~~~|______

always@(posedge clk or negedge rst)begin
	if(!rst)begin
		rd <= 0;
		wr <= 0;
	end
	else begin
		if(cs == 0)begin
			if(w_en == 0)begin
				wr = 1;
			end
			else if(r_en == 0)begin
				rd <= 1;
			end
			else begin
				rd <= 0;
				wr <= 0;
			end
		end
		else begin
			rd <= 0;
			wr <= 0;		
		end	
	end
end
assign data_in = rd? indata:16'hzzzz;
reg [3:0] sta;
reg [10:0] cnt;

//写操作逻辑
always@(negedge clk or negedge rst)begin
	if(!rst)begin
			out_data_0  <=0;  
			out_data_1  <=0;  
            out_data_2  <=0;  
            out_data_3  <=0;  
            out_data_4  <=0;  
            out_data_5  <=0;  
			sta <= 0;
			cnt <= 0;
	end
	else begin
		case(sta)
			4'd0:begin
				if(wr == 1)begin
					sta <= 1;
				end
				else begin
					sta <= 0;
				end
			end
			4'd1:begin//延迟计算，等待数据稳定
				if(cnt <= 10)begin
					cnt <= cnt + 1;
					sta <= 1;
				end
				else begin
					cnt <= 0;
					sta <= 2;
				end
			end
			4'd2:begin
				sta <= 3;
				case (addr)            
					8'h00: out_data_0   <= data_in;//0~15      相位检测temp[15:0]
					8'h01: out_data_1   <= data_in;//16~31     adc读取
					8'h02: out_data_2   <= data_in;//32~47	   dds幅度控制
					8'h03: out_data_3   <= data_in;//48~63     adc数据读取完成
					8'h04: out_data_4   <= data_in;//64~79     stm32发送开始信号   1:代表开始   0：代表暂停 
					8'h05: out_data_5   <= data_in;//80~95   
                    8'h06: out_data_6   <= data_in;//96~111
                    8'h07: out_data_7  <=  data_in;//112~127     从stm32获取初始的低16位谐振频率
					8'h08: out_data_8  <= data_in; //128~143     从stm32获取初始的高16位谐振频率
                    8'h09: out_data_9   <= data_in;//144~159     传输给dds的低16位谐振频率
                    8'h10: out_data_10   <= data_in;//160~175    传输给dds的高16位谐振频率
                    8'h11: out_data_11   <= data_in;//176~181    传输给dds的高16位谐振频率
					default:;
				endcase				
			end
			4'd3:begin
				if(wr == 0)begin
					sta <= 0;
				end
				else begin
					sta <= 3;
				end
			end
		default:sta = 0;
		endcase
	end
end

//将数据放到大的temp里面，方便解析指令						  
assign temp = {out_data_9,out_data_8,out_data_7,out_data_6,out_data_5,out_data_4,out_data_3,out_data_2,out_data_1,out_data_0};						  					  
reg [3:0] sta_r;
reg [9:0] cnt_r;

always@(posedge clk or negedge rst)begin
	if(!rst)begin
		indata <= 16'hzzzz;
		sta_r <= 0;
		cnt_r <= 0;
	end
	else begin
		case(sta_r)
			4'd0:begin
				if(rd == 1)begin                           
					sta_r <= 2;                            
				end                                       
				else begin
					sta_r <= 0;
				end			
			end
			4'd2:begin
				case (addr)
					8'h81:begin indata <= {8'b0,phase_done};        sta_r <= 4'd3;    end
					//8'h81:begin indata <= 16'h0022;                sta_r <= 4'd3;    end
					8'h82:begin indata <= phase_v_i;                sta_r <= 4'd3;    end
					//8'h82:begin indata <= 16'ha578;                sta_r <= 4'd3;    end
					
					8'h83:begin indata <= {8'b0,adc_save_done};     sta_r <= 4'd3;    end
					
					8'h84:begin indata <= adc_data_v;               sta_r <= 4'd3;    end
					8'h85:begin indata <= adc_data_i;               sta_r <= 4'd3;    end
					8'h86:begin indata <= fft_v;                    sta_r <= 4'd3;    end
					8'h87:begin indata <= fft_i;                    sta_r <= 4'd3;    end
					8'h88:begin indata <= d_phase_v_i;              sta_r <= 4'd3;    end	
					8'h89:begin indata <= 16'ha5d4;                 sta_r <= 4'd3;    end	
					8'h90:begin indata <= {13'b0,Version_Number};                 sta_r <= 4'd3;    end
					
                    8'h91:begin indata <= phase_diff;               sta_r <= 4'd3;    end       //发送给stm32 的数据
                    8'h92:begin indata <= drive_frequency_low;      sta_r <= 4'd3;    end  ////发送给stm32 的低16位频率
                    8'h93:begin indata <= drive_frequency_high;     sta_r <= 4'd3;    end  //发送给stm32 的高16位频率
                    8'h94:begin indata <= frequency_done;           sta_r <= 4'd3;    end       //频率计算完成标志
                    8'h95:begin indata <= start_fuzzy_pid_control;  sta_r <= 4'd3;    end 
                    8'h96:begin indata <= start_pid_control;        sta_r <= 4'd3;    end 
                    8'h97:begin indata <= frequency_v;              sta_r <= 4'd3;    end
                    8'h98:begin indata <= r_adc_data_v;             sta_r <= 4'd3;    end
                    8'h99:begin indata <= r_adc_data_i;             sta_r <= 4'd3;    end

                    default:begin

						sta_r <= 4'd3;
						indata <= 6'h98;
					end
					endcase			
			end
			4'd3:begin
				if(rd == 0)begin
					sta_r <= 0;
				end
				else begin
					sta_r <= 3;
				end			
			end
		default:sta_r <= 0;
		endcase
	end
end	

/*
					8'd6: out_data_6   <= data_in;
					8'd7: out_data_7   <= data_in;
					8'd8: out_data_8   <= data_in;
					8'd9: out_data_9   <= data_in;
					8'd10:out_data_10    <= data_in;
					8'd11:out_data_11    <= data_in;
					8'd12:out_data_12    <= data_in;
					8'd13:out_data_13    <= data_in;
					8'd14:out_data_14    <= data_in;
					8'd15:out_data_15    <= data_in;
					8'd16:out_data_16    <= data_in;
					8'd17:out_data_17    <= data_in;
					8'd18:out_data_18    <= data_in;
					8'd19:out_data_19    <= data_in;
					8'd20:out_data_20    <= data_in;
					8'd21:out_data_21    <= data_in;
					8'd22:out_data_22    <= data_in;
					8'd23:out_data_23    <= data_in;
					8'd24:out_data_24    <= data_in;
					8'd25:out_data_25    <= data_in;
					8'd26:out_data_26    <= data_in;
					8'd27:out_data_27    <= data_in;
					8'd28:out_data_28    <= data_in;
					8'd29:out_data_29    <= data_in;
					8'd30:out_data_30    <= data_in;
					8'd31:out_data_31    <= data_in;
					8'd32:out_data_32    <= data_in;
					8'd33:out_data_33    <= data_in;
					8'd34:out_data_34    <= data_in;
					8'd35:out_data_35    <= data_in;
					8'd36:out_data_36    <= data_in;
					8'd37:out_data_37    <= data_in;
					8'd38:out_data_38    <= data_in;
					8'd39:out_data_39    <= data_in;
					
					8'd40:out_data_40    <= data_in;
					8'd41:out_data_41    <= data_in;
					8'd42:out_data_42    <= data_in;
					8'd43:out_data_43    <= data_in;
					8'd44:out_data_44    <= data_in;
					8'd45:out_data_45    <= data_in;
					8'd46:out_data_46    <= data_in;
					8'd47:out_data_47    <= data_in;
					8'd48:out_data_48    <= data_in;
					8'd49:out_data_49    <= data_in;
					
					8'd50:out_data_50    <= data_in;
					8'd51:out_data_51    <= data_in;
					8'd52:out_data_52    <= data_in;
					8'd53:out_data_53    <= data_in;
					8'd54:out_data_54    <= data_in;
					8'd55:out_data_55    <= data_in;
					8'd56:out_data_56    <= data_in;
					8'd57:out_data_57    <= data_in;
					8'd58:out_data_58    <= data_in;
					8'd59:out_data_59    <= data_in;		

					8'd60:out_data_60    <= data_in;
					8'd61:out_data_61    <= data_in;
					8'd62:out_data_62    <= data_in;
					8'd63:out_data_63    <= data_in;
					8'd64:out_data_64    <= data_in;
					8'd65:out_data_65    <= data_in;
					8'd66:out_data_66    <= data_in;
					8'd67:out_data_67    <= data_in;
					8'd68:out_data_68    <= data_in;
					8'd69:out_data_69    <= data_in;	

					8'd70:out_data_70    <= data_in;
					8'd71:out_data_71    <= data_in;
					8'd72:out_data_72    <= data_in;
					8'd73:out_data_73    <= data_in;
					8'd74:out_data_74    <= data_in;
					8'd75:out_data_75    <= data_in;
					8'd76:out_data_76    <= data_in;
					8'd77:out_data_77    <= data_in;
					8'd78:out_data_78    <= data_in;
					8'd79:out_data_79    <= data_in;					
					
					8'd80:out_data_80    <= data_in;
					8'd81:out_data_81    <= data_in;
					8'd82:out_data_82    <= data_in;
					8'd83:out_data_83    <= data_in;
					8'd84:out_data_84    <= data_in;
					8'd85:out_data_85    <= data_in;
					8'd86:out_data_86    <= data_in;
					8'd87:out_data_87    <= data_in;
					8'd88:out_data_88    <= data_in;
					8'd89:out_data_89    <= data_in;		

					8'd90:out_data_90    <= data_in;
					8'd91:out_data_91    <= data_in;
					8'd92:out_data_92    <= data_in;
					8'd93:out_data_93    <= data_in;
					8'd94:out_data_94    <= data_in;
					8'd95:out_data_95    <= data_in;
					8'd96:out_data_96    <= data_in;
					8'd97:out_data_97    <= data_in;
					8'd98:out_data_98    <= data_in;
					8'd99:out_data_99    <= data_in;	

					8'd100:out_data_100    <= data_in;
					8'd101:out_data_101    <= data_in;
					8'd102:out_data_102    <= data_in;
					8'd103:out_data_103    <= data_in;
					8'd104:out_data_104    <= data_in;
					8'd105:out_data_105    <= data_in;
					8'd106:out_data_106    <= data_in;
					8'd107:out_data_107    <= data_in;
					8'd108:out_data_108    <= data_in;
					8'd109:out_data_109    <= data_in;	
					
					8'd110:out_data_110    <= data_in;
					8'd111:out_data_111    <= data_in;
					8'd112:out_data_112    <= data_in;
					8'd113:out_data_113    <= data_in;
					8'd114:out_data_114    <= data_in;
					8'd115:out_data_115    <= data_in;
					8'd116:out_data_116    <= data_in;
					8'd117:out_data_117    <= data_in;
					8'd118:out_data_118    <= data_in;
					8'd119:out_data_119    <= data_in;

					8'd120:out_data_120    <= data_in;
					8'd121:out_data_121    <= data_in;
					8'd122:out_data_122    <= data_in;
					8'd123:out_data_123    <= data_in;
					8'd124:out_data_124    <= data_in;
					8'd125:out_data_125    <= data_in;
					8'd126:out_data_126    <= data_in;
					8'd127:out_data_127    <= data_in;
					8'd128:out_data_128    <= data_in;
						
*/

/*
					8'h89:begin indata <= 16'haa89;             sta_r <= 4'd3;                      end
					8'h8a:begin indata <= 16'haa8a;             sta_r <= 4'd3;                      end
					8'h8b:begin indata <= 16'haa8b;             sta_r <= 4'd3;                      end
					8'h8c:begin indata <= 16'haa8c;             sta_r <= 4'd3;                      end
					8'h8d:begin indata <= 16'haa8d;             sta_r <= 4'd3;                      end
					8'h8e:begin indata <= 16'haa8e;             sta_r <= 4'd3;                      end
					8'h8f:begin indata <= 16'haa8f;             sta_r <= 4'd3;                      end
					8'h90:begin indata <= 16'haa90;             sta_r <= 4'd3;                      end
					8'h91:begin indata <= 16'haa91;             sta_r <= 4'd3;                      end
					8'h92:begin indata <= 16'haa92;             sta_r <= 4'd3;                      end
					8'h93:begin indata <= 16'haa93;             sta_r <= 4'd3;                      end
					8'h94:begin indata <= 16'haa94;             sta_r <= 4'd3;                      end
					8'h95:begin indata <= 16'haa95;             sta_r <= 4'd3;                      end
					8'h96:begin indata <= 16'haa96;             sta_r <= 4'd3;                      end
					8'h97:begin indata <= 16'haa97;             sta_r <= 4'd3;                      end
					8'h98:begin indata <= 16'haa98;             sta_r <= 4'd3;                      end
					8'h99:begin indata <= 16'haa99;             sta_r <= 4'd3;                      end
					8'h9a:begin indata <= 16'haa9a;             sta_r <= 4'd3;                      end
					8'h9b:begin indata <= 16'haa9b;             sta_r <= 4'd3;                      end
					8'h9c:begin indata <= 16'haa9c;             sta_r <= 4'd3;                      end
					8'h9d:begin indata <= 16'haa9d;             sta_r <= 4'd3;                      end
					8'h9e:begin indata <= 16'haa9e;             sta_r <= 4'd3;                      end
					8'h9f:begin indata <= 16'haa9f;             sta_r <= 4'd3;                      end
					
					8'ha0:begin indata <= 16'haaa0;             sta_r <= 4'd3;                     end
					8'ha1:begin indata <= 16'haaa1;             sta_r <= 4'd3;                     end
					8'ha2:begin indata <= 16'haaa2;             sta_r <= 4'd3;                     end
					8'ha3:begin indata <= 16'haaa3;             sta_r <= 4'd3;                     end
					8'ha4:begin indata <= 16'haaa4;             sta_r <= 4'd3;                     end
					8'ha5:begin indata <= 16'haaa5;             sta_r <= 4'd3;                     end
					8'ha6:begin indata <= 16'haaa6;             sta_r <= 4'd3;                     end
					8'ha7:begin indata <= 16'haaa7;             sta_r <= 4'd3;                     end
					8'ha8:begin indata <= 16'haaa8;             sta_r <= 4'd3;                     end
					8'ha9:begin indata <= 16'haaa9;             sta_r <= 4'd3;                     end
					8'haa:begin indata <= 16'haaaa;             sta_r <= 4'd3;                     end
					8'hab:begin indata <= 16'haaab;             sta_r <= 4'd3;                     end
					8'hac:begin indata <= 16'haaac;             sta_r <= 4'd3;                     end
					8'had:begin indata <= 16'haaad;             sta_r <= 4'd3;                     end
					8'hae:begin indata <= 16'haaae;             sta_r <= 4'd3;                     end
					8'haf:begin indata <= 16'haaaf;             sta_r <= 4'd3;                     end
					
					8'hb0:begin indata <= 16'haab0;             sta_r <= 4'd3;                     end
					8'hb1:begin indata <= 16'haab1;             sta_r <= 4'd3;                     end
					8'hb2:begin indata <= 16'haab2;             sta_r <= 4'd3;                     end
					8'hb3:begin indata <= 16'haab3;             sta_r <= 4'd3;                     end
					8'hb4:begin indata <= 16'haab4;             sta_r <= 4'd3;                     end
					8'hb5:begin indata <= 16'haab5;             sta_r <= 4'd3;                     end
					8'hb6:begin indata <= 16'haab6;             sta_r <= 4'd3;                     end
					8'hb7:begin indata <= 16'haab7;             sta_r <= 4'd3;                     end
					8'hb8:begin indata <= 16'haab8;             sta_r <= 4'd3;                     end
					8'hb9:begin indata <= 16'haab9;             sta_r <= 4'd3;                     end
					8'hba:begin indata <= 16'haaba;             sta_r <= 4'd3;                     end
					8'hbb:begin indata <= 16'haabb;             sta_r <= 4'd3;                     end
					8'hbc:begin indata <= 16'haabc;             sta_r <= 4'd3;                     end
					8'hbd:begin indata <= 16'haabd;             sta_r <= 4'd3;                     end
					8'hbe:begin indata <= 16'haabe;             sta_r <= 4'd3;                     end
					8'hbf:begin indata <= 16'haabf;             sta_r <= 4'd3;                     end	

					8'hc0:begin indata <= 16'haac0;             sta_r <= 4'd3;                     end
					8'hc1:begin indata <= 16'haac1;             sta_r <= 4'd3;                     end
					8'hc2:begin indata <= 16'haac2;             sta_r <= 4'd3;                     end
					8'hc3:begin indata <= 16'haac3;             sta_r <= 4'd3;                     end
					8'hc4:begin indata <= 16'haac4;             sta_r <= 4'd3;                     end
					8'hc5:begin indata <= 16'haac5;             sta_r <= 4'd3;                     end
					8'hc6:begin indata <= 16'haac6;             sta_r <= 4'd3;                     end
					8'hc7:begin indata <= 16'haac7;             sta_r <= 4'd3;                     end
					8'hc8:begin indata <= 16'haac8;             sta_r <= 4'd3;                     end
					8'hc9:begin indata <= 16'haac9;             sta_r <= 4'd3;                     end
					8'hca:begin indata <= 16'haaca;             sta_r <= 4'd3;                     end
					8'hcb:begin indata <= 16'haacb;             sta_r <= 4'd3;                     end
					8'hcc:begin indata <= 16'haacc;             sta_r <= 4'd3;                     end
					8'hcd:begin indata <= 16'haacd;             sta_r <= 4'd3;                     end
					8'hce:begin indata <= 16'haace;             sta_r <= 4'd3;                     end
					8'hcf:begin indata <= 16'haacf;             sta_r <= 4'd3;                     end		

					8'hd0:begin indata <= 16'haad0;             sta_r <= 4'd3;                     end
					8'hd1:begin indata <= 16'haad1;             sta_r <= 4'd3;                     end
					8'hd2:begin indata <= 16'haad2;             sta_r <= 4'd3;                     end
					8'hd3:begin indata <= 16'haad3;             sta_r <= 4'd3;                     end
					8'hd4:begin indata <= 16'haad4;             sta_r <= 4'd3;                     end
					8'hd5:begin indata <= 16'haad5;             sta_r <= 4'd3;                     end
					8'hd6:begin indata <= 16'haad6;             sta_r <= 4'd3;                     end
					8'hd7:begin indata <= 16'haad7;             sta_r <= 4'd3;                     end
					8'hd8:begin indata <= 16'haad8;             sta_r <= 4'd3;                     end
					8'hd9:begin indata <= 16'haad9;             sta_r <= 4'd3;                     end
					8'hda:begin indata <= 16'haada;             sta_r <= 4'd3;                     end
					8'hdb:begin indata <= 16'haadb;             sta_r <= 4'd3;                     end
					8'hdc:begin indata <= 16'haadc;             sta_r <= 4'd3;                     end
					8'hdd:begin indata <= 16'haadd;             sta_r <= 4'd3;                     end
					8'hde:begin indata <= 16'haade;             sta_r <= 4'd3;                     end
					8'hdf:begin indata <= 16'haadf;             sta_r <= 4'd3;                     end	

					8'he0:begin indata <= 16'haae0;             sta_r <= 4'd3;                     end
					8'he1:begin indata <= 16'haae1;             sta_r <= 4'd3;                     end
					8'he2:begin indata <= 16'haae2;             sta_r <= 4'd3;                     end
					8'he3:begin indata <= 16'haae3;             sta_r <= 4'd3;                     end
					8'he4:begin indata <= 16'haae4;             sta_r <= 4'd3;                     end
					8'he5:begin indata <= 16'haae5;             sta_r <= 4'd3;                     end
					8'he6:begin indata <= 16'haae6;             sta_r <= 4'd3;                     end
					8'he7:begin indata <= 16'haae7;             sta_r <= 4'd3;                     end
					8'he8:begin indata <= 16'haae8;             sta_r <= 4'd3;                     end
					8'he9:begin indata <= 16'haae9;             sta_r <= 4'd3;                     end
					8'hea:begin indata <= 16'haaea;             sta_r <= 4'd3;                     end
					8'heb:begin indata <= 16'haaeb;             sta_r <= 4'd3;                     end
					8'hec:begin indata <= 16'haaec;             sta_r <= 4'd3;                     end
					8'hed:begin indata <= 16'haaed;             sta_r <= 4'd3;                     end
					8'hee:begin indata <= 16'haaee;             sta_r <= 4'd3;                     end
					8'hef:begin indata <= 16'haaef;             sta_r <= 4'd3;                     end

					8'hf0:begin indata <= 16'haaf0;             sta_r <= 4'd3;                     end
					8'hf1:begin indata <= 16'haaf1;             sta_r <= 4'd3;                     end
					8'hf2:begin indata <= 16'haaf2;             sta_r <= 4'd3;                     end
					8'hf3:begin indata <= 16'haaf3;             sta_r <= 4'd3;                     end
					8'hf4:begin indata <= 16'haaf4;             sta_r <= 4'd3;                     end
					8'hf5:begin indata <= 16'haaf5;             sta_r <= 4'd3;                     end
					8'hf6:begin indata <= 16'haaf6;             sta_r <= 4'd3;                     end
					8'hf7:begin indata <= 16'haaf7;             sta_r <= 4'd3;                     end
					8'hf8:begin indata <= 16'haaf8;             sta_r <= 4'd3;                     end
					8'hf9:begin indata <= 16'haaf9;             sta_r <= 4'd3;                     end
					8'hfa:begin indata <= 16'haafa;             sta_r <= 4'd3;                     end
					8'hfb:begin indata <= 16'haafb;             sta_r <= 4'd3;                     end
					8'hfc:begin indata <= 16'haafc;             sta_r <= 4'd3;                     end
					8'hfd:begin indata <= 16'haafd;             sta_r <= 4'd3;                     end
					8'hfe:begin indata <= 16'haafe;             sta_r <= 4'd3;                     end
					8'hff:begin indata <= 16'haaff;             sta_r <= 4'd3;                     end	
*/
















	
/*						  
always @(rd or !rst)begin
        if(!rst)
			indata <= 16'h0000;
        else  begin
			case (addr)
				8'd129:indata <= {8'b0,4'b0010,0,0,phase_done,0};//要写入的数据  0022h表示数据可读
				8'd130:indata <= phase;//
				8'd131:indata <= {8'b0,4'b0010,0,0,rms_done,0};//
				8'd132:indata <= rms;//
				8'd133:indata <= {8'b0,4'b0010,0,0,adc_h_done,0};//
				8'd134:indata <= adc_h_data;//
				8'd135:indata <= {8'b0,4'b0010,0,0,eeprom_done,0};//
				8'd136:indata <= bianhao[31:16];//
				8'd137:indata <= bianhao[15:0];//
				8'd138:indata <= {8'b0,cishu};//
				8'd139:indata <= cuowuma[63:48];//
				8'd140:indata <= cuowuma[47:32];//
				8'd141:indata <= cuowuma[31:16];//
				8'd142:indata <= cuowuma[15:0];//
				8'd143:indata <= 0;//
				8'd144:indata <= 0;//
				8'd145:indata <= 0;//
				8'd146:indata <= 0;//
				8'd147:indata <= 0;//
				8'd148:indata <= 0;//
				8'd149:indata <= 0;//
				8'd150:indata <= 0;//
				8'd151:indata <= 0;//
				8'd152:indata <= 0;//
				8'd153:indata <= 0;//
				8'd154:indata <= 0;//
				8'd155:indata <= 0;//
				8'd156:indata <= 0;//
				8'd157:indata <= 0;//
				8'd158:indata <= 0;//
				8'd159:indata <= 0;//
				8'd160:indata <= 0;//
				default:;
			endcase
        end
end	
*/


	/*
always @(posedge wr or negedge rst)begin
        if(!rst)begin
			out_data_0  <=0;   out_data_11  <=0;   out_data_21  <=0;
			out_data_1  <=0;   out_data_12  <=0;   out_data_22  <=0;
            out_data_2  <=0;   out_data_13  <=0;   out_data_23  <=0;
            out_data_3  <=0;   out_data_14  <=0;   out_data_24  <=0;
            out_data_4  <=0;   out_data_15  <=0;   out_data_25  <=0;
            out_data_5  <=0;   out_data_16  <=0;   out_data_26  <=0;
            out_data_6  <=0;   out_data_17  <=0;   out_data_27  <=0;
            out_data_7  <=0;   out_data_18  <=0;   out_data_28  <=0;
            out_data_8  <=0;   out_data_19  <=0;   out_data_29  <=0;
            out_data_9  <=0;   out_data_20  <=0;   out_data_30  <=0;
		    out_data_10 <=0;
        end    
		else  begin
			case (addr)            
				8'd0: out_data_0   <= data_in;
				8'd1: out_data_1   <= data_in;
				8'd2: out_data_2   <= data_in;
				8'd3: out_data_3   <= data_in;
				8'd4: out_data_4   <= data_in;
				8'd5: out_data_5   <= data_in;
				8'd6: out_data_6   <= data_in;
				8'd7: out_data_7   <= data_in;
				8'd8: out_data_8   <= data_in;
				8'd9: out_data_9   <= data_in;
				8'd10:out_data_10    <= data_in;
				8'd11:out_data_11    <= data_in;
				8'd12:out_data_12    <= data_in;
				8'd13:out_data_13    <= data_in;
				8'd14:out_data_14    <= data_in;
				8'd15:out_data_15    <= data_in;
				8'd16:out_data_16    <= data_in;
				8'd17:out_data_17    <= data_in;
				8'd18:out_data_18    <= data_in;
				8'd19:out_data_19    <= data_in;
				8'd20:out_data_20    <= data_in;
				8'd21:out_data_21    <= data_in;
				8'd22:out_data_22    <= data_in;
				8'd23:out_data_23    <= data_in;
				8'd24:out_data_24    <= data_in;
				8'd25:out_data_25    <= data_in;
				8'd26:out_data_26    <= data_in;
				8'd27:out_data_27    <= data_in;
				8'd28:out_data_28    <= data_in;
				8'd29:out_data_29    <= data_in;
				8'd30:out_data_30    <= data_in;
				default:;
			endcase
        end
end
*/

	/*
            8'd31:out_data <= data_in;
            8'd32:out_data <= data_in;
            8'd33:out_data <= data_in;
            8'd34:out_data <= data_in;
            8'd35:out_data <= data_in;
            8'd36:out_data <= data_in;
            8'd37:out_data <= data_in;
            8'd38:out_data <= data_in;
            8'd39:out_data <= data_in;
            8'd40:out_data <= data_in;
            8'd41:out_data <= data_in;
            8'd42:out_data <= data_in;
            8'd43:out_data <= data_in;
            8'd44:out_data <= data_in;
            8'd45:out_data <= data_in;
            8'd46:out_data <= data_in;
            8'd47:out_data <= data_in;
            8'd48:out_data <= data_in;
            8'd49:out_data <= data_in;
            8'd50:out_data <= data_in;
            8'd51:out_data <= data_in;
            8'd52:out_data <= data_in;
            8'd53:out_data <= data_in;
            8'd54:out_data <= data_in;
            8'd55:out_data <= data_in;
            8'd56:out_data <= data_in;
            8'd57:out_data <= data_in;
            8'd58:out_data <= data_in;
            8'd59:out_data <= data_in;
            8'd60:out_data <= data_in;
            8'd61:out_data <= data_in;
            8'd62:out_data <= data_in;
            8'd63:out_data <= data_in;
            8'd64:out_data <= data_in;
            8'd65:out_data <= data_in;
            8'd66:out_data <= data_in;
            8'd67:out_data <= data_in;
            8'd68:out_data <= data_in;
            8'd69:out_data <= data_in;
            8'd70:out_data <= data_in;	
	*/
endmodule