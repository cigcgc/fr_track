//FPGA/MATLAB/simulink仿真工作室
//微信公众号：matworld
`timescale 1 ns / 1 ps
  
module BUFRAM256C ( CLK ,RST ,ED ,START ,DR ,DI ,RDY ,DOR ,DOI );
	parameter nb=12;
	output RDY ;
	reg RDY ;
	output [nb-1:0] DOR ;
	wire [nb-1:0] DOR ;
	output [nb-1:0] DOI ;
	wire [nb-1:0] DOI ;
	
	input CLK ;
	wire CLK ;
	input RST ;
	wire RST ;
	input ED ;
	wire ED ;
	input START ;
	wire START ;
	input [nb-1:0] DR ;
	wire [nb-1:0] DR ;
	input [nb-1:0] DI ;
	wire [nb-1:0] DI ;
	
	wire odd, we;
	wire [7:0] addrw,addrr;
	reg [8:0] addr;
	reg [9:0] ct2;		//counter for the RDY signal		 		  
	
	always @(posedge CLK)	//   CTADDR
		begin
			if (RST) begin
					addr<=8'b0000_0000;
					ct2<= 9'b10000_0001;  
				RDY<=1'b0; end
			else if (START) begin 
					addr<=8'b0000_0000;
					ct2<= 8'b0000_0000;  
				RDY<=1'b0;end
			else if (ED)	begin
				RDY<=1'b0;
					addr<=addr+1; 
					if (ct2!=257) 
					ct2<=ct2+1;
					if (ct2==256) 
					 RDY<=1'b1;
				end 
		end
			
	
assign	addrw=	addr[7:0];
assign	odd=addr[8];	   			// signal which switches the 2 parts of the buffer
assign	addrr={addr[3 : 0], addr[7 : 4]};	  // 16-th inverse output address
assign	we = ED;	  
	
	RAM2x256C #(nb)	URAM(.CLK(CLK),.ED(ED),.WE(we),.ODD(odd),
	.ADDRW(addrw),	.ADDRR(addrr),
	.DR(DR),.DI(DI),
	.DOR(DOR),	.DOI(DOI));	   
	
endmodule
