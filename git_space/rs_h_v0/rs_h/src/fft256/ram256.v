// DESCRIPTION	:	1-port synchronous RAM
`timescale 1 ns / 1 ps
  
module RAM256( 
              CLK, 
				  ED,
				  WE,
				  ADDR,
				  DI,
				  DO
				  );
				  
	parameter nb=12; 
	
	output [nb-1:0] DO ;
	input CLK ;
	input ED;
	input WE ;
	input [7:0] ADDR ;
	input [nb-1:0] DI ;
	
	wire CLK ;
	wire WE ;
	wire [7:0] ADDR ;
	wire [nb-1:0] DI ;
	reg [nb-1:0] mem [255:0];
	reg [7:0] addrrd;		  
	reg [nb-1:0] DO ;
	
	
	always @(posedge CLK) 
	begin
		if(ED) 
		begin
			if(WE)		
			mem[ADDR] <= DI;
			
			addrrd <= ADDR;	         //storing the address
			DO <= mem[addrrd];	   // registering the read datum
		end	  
		
	end
	
	
endmodule
