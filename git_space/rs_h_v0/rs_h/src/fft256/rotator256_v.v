 
`timescale 1ns / 1ps
  
module ROTATOR64(
                 CLK,
					  RST,
					  ED,
					  START, 
					  DR,
					  DI, 
					  DOR, 
					  DOI,
					  RDY  
					  );
					  
parameter nb=12;
parameter nw=12;
	
input RST;
input CLK;
input ED ; //operation enable
input [nb-1:0]DI;  //Imaginary part of data
input [nb-1:0]  DR ; //Real part of data
input START ;		   //1-st Data is entered after this impulse 
	
	
output [nb-1:0]  DOI ; //Imaginary part of data
output [nb-1:0]  DOR ; //Real part of data
output RDY ;	   //repeats START impulse following the output data
		 
	
wire RST ;
wire CLK ;
	
wire [nb-1:0]  DI ;
wire [nb-1:0]  DR ;
wire START ;	
wire [nb-1:0]  DOI ;	
wire [nb-1:0]  DOR ;	
reg RDY ;		
	
	
	reg [7:0] addrw;
	reg sd1,sd2;
	always	@( posedge CLK)	  //address counter for twiddle factors
		begin
			if (RST) begin
					addrw<=0;
					sd1<=0;
					sd2<=0;
				end
			else if (START && ED)  begin
					addrw[7:0]<=0;
					sd1<=START;
					sd2<=0;		 
				end
			else if (ED) 	  begin
					addrw<=addrw+1; 
					sd1<=START;
					sd2<=sd1;
					RDY<=sd2;	 
				end
		end			  

		wire signed [nw-1:0] wr,wi; //twiddle factor coefficients
	//twiddle factor ROM
	WROM256 UROM( .ADDR(addrw),	.WR(wr),.WI(wi) );	
		
		
	reg signed [nb-1 : 0] drd,did;
	reg signed [nw-1 : 0] wrd,wid;
	wire signed [nw+nb-1 : 0] drri,drii,diri,diii;
	reg signed [nb:0] drr,dri,dir,dii,dwr,dwi;
	
	assign  	drri=drd*wrd;  
	assign	diri=did*wrd;  
	assign	drii=drd*wid;
	assign	diii=did*wid;  
	
	always @(posedge CLK)	 //complex multiplier	 
		begin
			if (ED) begin	
					drd<=DR;
					did<=DI;
					wrd<=wr;
					wid<=wi;
					drr<=drri[nw+nb-1 :nw-1]; //msbs of multiplications are stored
					dri<=drii[nw+nb-1 : nw-1];
					dir<=diri[nw+nb-1 : nw-1];
					dii<=diii[nw+nb-1 : nw-1];
					dwr<=drr - dii;				
					dwi<=dri + dir;  
				end	 
		end 		
	assign DOR=dwr[nb:1];       
	assign DOI=dwi[nb:1];
	
endmodule
