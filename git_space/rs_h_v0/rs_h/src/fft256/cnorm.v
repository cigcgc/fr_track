 
`timescale 1 ns / 1 ps		 
 
module CNORM ( CLK ,ED ,START ,DR ,DI ,SHIFT ,OVF ,RDY ,DOR ,DOI );
	parameter nb=12;
	
	output OVF ;
	reg OVF ;
	output RDY ;
	reg RDY ;
	output [nb+1:0] DOR ;
	wire [nb+1:0] DOR ;
	output [nb+1:0] DOI ;
	wire [nb+1:0] DOI ;
	
	input CLK ;
	wire CLK ;
	input ED ;
	wire ED ;
	input START ;
	wire START ;
	input [nb+3:0] DR ;
	wire [nb+3:0] DR ;
	input [nb+3:0] DI ;
	wire [nb+3:0] DI ;
	input [1:0] SHIFT ;			  //shift left code to 0,1,2,3 bits
	wire [1:0] SHIFT ;
	
wire signed [nb+3:0]	 diri,diii;
assign diri = DR << SHIFT;
assign diii = DI << SHIFT;	 

reg [nb+3:0]	dir,dii;

`ifdef FFT256round 			//rounding
    always @( posedge CLK )    begin
			if (ED)	  begin
					dir<=diri;
     				dii<=diii;
		end 
	end  
	
`else								 //truncation	 
    always @( posedge CLK )    begin
		if (ED)	  begin	
			if (diri[nb+3] && ~diri[0])	// <0 with LSB=00 
				dir<=diri; 
			else   dir<=diri+2; 
			if (diii[nb+3] && ~diii[0])
				dii<=diii; 
			else   dii<=diii+2; 
		end 
	end  
	
	`endif
	
 always @( posedge CLK ) 	begin
		  	if (ED)	  begin
				RDY<=START;
				if (START) 
					OVF<=0;
				else   
					case (SHIFT) 
					2'b01 : OVF<= (DR[nb+3] != DR[nb+2]) || (DI[nb+3] != DI[nb+2]);
					2'b10 : OVF<= (DR[nb+3] != DR[nb+2]) || (DI[nb+3] != DI[nb+2]) ||
						(DR[nb+3] != DR[nb+1]) || (DI[nb+3] != DI[nb+1]);
					2'b11 : OVF<= (DR[nb+3] != DR[nb+2]) || (DI[nb+3] != DI[nb+2])||
						(DR[nb+3] != DR[nb]) || (DI[nb+3] != DI[nb]) ||
						(DR[nb+3] != DR[nb+1]) || (DI[nb+3] != DI[nb+1]);
					endcase						
				end
			end 
			
	assign DOR= dir[nb+3:2];
	assign DOI= dii[nb+3:2];
	
endmodule
