
`timescale 1 ns / 1 ps
module fft256( 
              CLK,
				  RST,
				  ED,
				  START,
				  SHIFT,
				  DR,
				  DI,
				  RDY,
				  OVF1,
				  OVF2,
				  ADDR,
				  o_fft_abs,
                  DOR,
                  DOI
				  );
				  
	parameter nb=12;	  	 		//nb is the data bit width

	input CLK ;        			//Clock signal is less than 300 MHz for the Xilinx Virtex5 FPGA        
	input RST ;				//Reset signal, is the synchronous one with respect to CLK
	input ED ;					//=1 enables the operation (eneabling CLK)
	input START ;  			// its falling edge starts the transform or the serie of transforms  
	input [3:0] SHIFT ;		// bits 1,0 -shift left code in the 1-st stage
	input [nb-1:0] DR ;		// Real part of the input data,  0-th data goes just after 
	input [nb-1:0] DI ;		//Imaginary part of the input data
	
	
	output RDY ;   			// in the next cycle after RDY=1 the 0-th result is present 
	output OVF1 ;			// 1 signals that an overflow occured in the 1-st stage 
	output OVF2 ;			// 1 signals that an overflow occured in the 2-nd stage 
	output [7:0] ADDR ;	//result data address/number
	
	output[27:0]o_fft_abs;
	
	output [nb+3:0] DOR ;//Real part of the output data, 
	output [nb+3:0] DOI ;//Imaginary part of the output data
	
	

	wire RDY ;
	wire OVF1 ;
	wire OVF2 ;
	wire [7:0] ADDR ;
	wire [nb+3:0] DOR ;	 // the bit width is nb+4, can be decreased when instantiating the core 
	wire [nb+3:0] DOI ;
	
	wire [3:0] SHIFT ;	   	// bits 3,2 -shift left code in the 2-nd stage
	wire [nb-1:0] DR ;	    // the START signal or after 255-th data of the previous transform
	wire [nb-1:0] DI ;
	wire START ;			 	// and resets the overflow detectors
	wire ED ;
	wire RST ;
	wire CLK ;
	
	
	wire [nb-1:0] dr1,di1;
	wire [nb+1:0] dr3,di3,dr4,di4, dr5,di5 ;
	wire [nb+3:0] dr2,di2;
	wire [nb+5:0] dr6,di6; 	
	wire [nb+3:0] dr7,di7,dr8,di8;   
	wire rdy1,rdy2,rdy3,rdy4,rdy5,rdy6,rdy7,rdy8;			 
	reg [7:0] addri ;
												    // input buffer =8-bit inversion ordering
	BUFRAM256C #(nb) U_BUF1(.CLK(CLK), .RST(RST), .ED(ED),	.START(START),
	.DR(DR),	.DI(DI),			.RDY(rdy1),	.DOR(dr1), .DOI(di1));	   
	
	//1-st stage of FFT
	FFT16 #(nb) U_FFT1(.CLK(CLK), .RST(RST), .ED(ED),
		.START(rdy1),.DIR(dr1),.DII(di1),
		.RDY(rdy2),	.DOR(dr2),.	DOI(di2));	
	
	wire	[1:0] shiftl=	 SHIFT[1:0]; 
	CNORM #(nb) U_NORM1( .CLK(CLK),	.ED(ED),  //1-st normalization unit
		.START(rdy2),	// overflow detector reset
		.DR(dr2),	.DI(di2),
		.SHIFT(shiftl), //shift left bit number
		.OVF(OVF1),
		.RDY(rdy3),
		.DOR(dr3),.DOI(di3));	
		
	// rotator to the angles proportional to PI/32
	ROTATOR64 #(nb+2) U_MPU (.CLK(CLK),.RST(RST),.ED(ED),
		.START(rdy3),. DR(dr3),.DI(di3),
		.RDY(rdy4), .DOR(dr4),	.DOI(di4));
	
	BUFRAM256C #(nb+2) U_BUF2(.CLK(CLK),.RST(RST),.ED(ED),	// intermediate buffer =8-bit inversion ordering
		.START(rdy4),. DR(dr4),.DI(di4),
		.RDY(rdy5), .DOR(dr5),	.DOI(di5));	 
	
	//2-nd stage of FFT
	FFT16 #(nb+2) U_FFT2(.CLK(CLK), .RST(RST), .ED(ED),
		.START(rdy5),. DIR(dr5),.DII(di5),
		.RDY(rdy6), .DOR(dr6),	.DOI(di6));
	
	wire	[1:0] shifth=	 SHIFT[3:2]; 
	//2-nd normalization unit
	CNORM #(nb+2) U_NORM2 ( .CLK(CLK),	.ED(ED),
		.START(rdy6),	// overflow detector reset
		.DR(dr6),	.DI(di6),
		.SHIFT(shifth), //shift left bit number
		.OVF(OVF2),
		.RDY(rdy7),
		.DOR(dr7),	.DOI(di7));


		BUFRAM256C  #(nb+4) 	Ubuf3(.CLK(CLK),.RST(RST),.ED(ED),	// intermediate buffer =8-bit inversion ordering
		.START(rdy7),. DR(dr7),.DI(di7),
		.RDY(rdy8), .DOR(dr8),	.DOI(di8));	 	

	

	
//	`ifdef FFT256parambuffers3  	 	// 3-data buffer configuratiion 		   
	always @(posedge CLK)	begin	//POINTER to the result samples
			if (RST)
				addri<=8'b0000_0000;
			else if (rdy8==1 )  
				addri<=8'b0000_0000;
			else if (ED)
				addri<=addri+1; 
		end
	
		assign ADDR=  addri ;
	assign	DOR=dr8;
	assign	DOI=di8;
	assign	RDY=rdy8;	

 //ABS
wire [13:0] DOR20 = (DOR[13] == 1'b0)?DOR:~DOR+1'b1;//Real part of the output data, 
wire [13:0] DOI20 = (DOI[13] == 1'b0)?DOI:~DOI+1'b1;//Imaginary part of the output data
 
 
 
wire [27:0] DOR2 = DOR20*DOR20;//Real part of the output data, 
wire [27:0] DOI2 = DOI20*DOI20;//Imaginary part of the output data
assign o_fft_abs   =DOR2 +DOI2;
endmodule
