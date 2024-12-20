// DESCRIPTION	:	2-port RAM

`timescale 1 ns / 1 ps
  

module RAM2x256C( 
                 CLK,
					  ED,
					  WE,
					  ODD,
					  ADDRW,
					  ADDRR,
					  DR,
					  DI,
					  DOR,
					  DOI);
					  
	parameter nb=12;	
	
	
	output [nb-1:0] DOR ;
	wire [nb-1:0] DOR ;
	output [nb-1:0] DOI ;
	wire [nb-1:0] DOI ;
	input CLK ;
	wire CLK ;
	input ED ;
	wire ED ;
	input WE ;	     //write enable
	wire WE ;
	input ODD ;	  // RAM part switshing
	wire ODD ;
	input [7:0] ADDRW ;
	wire [7:0] ADDRW ;
	input [7:0] ADDRR ;
	wire [7:0] ADDRR ;
	input [nb-1:0] DR ;
	wire [nb-1:0] DR ;
	input [nb-1:0] DI ;
	wire [nb-1:0] DI ;	
	
	reg	oddd,odd2;
	always @( posedge CLK) begin //switch which reswiches the RAM parts
			if (ED)	begin
					oddd<=ODD;
					odd2<=oddd;
				end
		end 
	`ifdef 	FFT256bufferports1
	//One-port RAMs are used
	wire we0,we1;
	wire	[nb-1:0] dor0,dor1,doi0,doi1;
	wire	[7:0] addr0,addr1;		   
	
	
	
	assign	addr0 =ODD?  ADDRW: ADDRR;		//MUXA0
	assign	addr1 = ~ODD? ADDRW:ADDRR;	// MUXA1
	assign	we0   =ODD?  WE: 0;		     // MUXW0: 
	assign	we1   =~ODD? WE: 0;			 // MUXW1:
	
	//1-st half - write when odd=1	 read when odd=0
	RAM256 #(nb) URAM0(.CLK(CLK),.ED(ED),.WE(we0), .ADDR(addr0),.DI(DR),.DO(dor0)); // 
	RAM256 #(nb) URAM1(.CLK(CLK),.ED(ED),.WE(we0), .ADDR(addr0),.DI(DI),.DO(doi0));	 
	
	//2-d half
	RAM256 #(nb) URAM2(.CLK(CLK),.ED(ED),.WE(we1), .ADDR(addr1),.DI(DR),.DO(dor1));//	  
	RAM256 #(nb) URAM3(.CLK(CLK),.ED(ED),.WE(we1), .ADDR(addr1),.DI(DI),.DO(doi1));		
	
	assign	DOR=~odd2? dor0 : dor1;		 // MUXDR: 
	assign	DOI=~odd2? doi0 : doi1;	//  MUXDI:
	
	`else 		
	//Two-port RAM is used
	wire [8:0] addrr2 = {ODD,ADDRR};
	wire [8:0] addrw2 = {~ODD,ADDRW};
	wire [2*nb-1:0] di= {DR,DI} ;	

	//wire [2*nb-1:0] doi;	
	reg [2*nb-1:0] doi;	
	
	reg [2*nb-1:0] ram [511:0];
	reg [8:0] read_addra;
	always @(posedge CLK) begin
			if (ED)
				begin
					if (WE)
						ram[addrw2] <= di;
					read_addra <= addrr2;	
				   doi = ram[read_addra];			
				end
		end
	//assign 	 
	
	assign	DOR=doi[2*nb-1:nb];		 // Real read data 
	assign	DOI=doi[nb-1:0];		 // Imaginary read data
	
	
	`endif 	
endmodule
