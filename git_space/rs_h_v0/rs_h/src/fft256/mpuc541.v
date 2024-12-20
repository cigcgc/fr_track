
// DESCRIPTION	:	 Complex Multiplier by 0.5411

module MPUC541 ( CLK,EI ,ED, MPYJ,DR,DI ,DOR ,DOI);
	parameter nb=12;
	
	input CLK ;
	wire CLK ;
	input EI ;
	wire EI ;
	input ED; 					//data strobe
	input MPYJ ;				//the result is multiplied by -j
	wire MPYJ ;
	input [nb-1:0] DR ;
	wire signed [nb-1:0] DR ;
	input [nb-1:0] DI ;
	wire signed [nb-1:0] DI ;	   
	
	output [nb-1:0] DOR ;
	reg [nb-1:0] DOR ;	
	output [nb-1:0] DOI ;
	reg [nb-1:0] DOI ;	 
	
	reg signed [nb :0] dx5;	 
	reg signed [nb :0] dx3;	 
	reg signed [nb-1 :0] dii;	 
	reg signed	[nb-1 : 0] dt;		   
	wire signed [nb+1 : 0]  dx5p; 
	wire  signed  [nb+1 : 0] dot;	
	reg edd,edd2, edd3;        		//delayed data enable impulse        
	reg mpyjd,mpyjd2,mpyjd3;
	reg [nb-1:0] doo ;	
	reg [nb-1:0] droo ;	
	
	always @(posedge CLK)
		begin
			if (EI) begin	  
					edd<=ED;
					edd2<=edd;	
					edd3<=edd2;	
					mpyjd<=MPYJ;
					mpyjd2<=mpyjd;
					mpyjd3<=mpyjd2;					
					if (ED)	 begin				   		//	 0_1000_1010_1000_11 	
							dx5<=DR+(DR >>>2);	 //multiply by 5 
							dx3<=DR+(DR >>>1);	 //multiply by 3, 
							dt<=DR;	  
							dii<=DI;
						end
					else	 begin
							dx5<=dii+(dii >>>2);	 //multiply by 5
							dx3<=dii +(dii >>>1);	 //multiply by  3 
							dt<=dii;
						end
					doo<=dot >>>2;	
					droo<=doo;	
					if (edd3) 	 
						if (mpyjd3) begin
								DOR<=doo;
							DOI<= - droo; end
						else begin
								DOR<=droo;
							DOI<=  doo; end					
				end 
		end		
	
	assign	dx5p=(dt<<1)+(dx5>>>3);		// multiply by  0_1000_101 
	
	`ifdef FFT256bitwidth_coef_high 
	assign   dot=	(dx5p+(dt>>>7) +(dx3>>>11));// multiply by //	 0_1000_1010_1000_11 
	`else	                               
	assign    dot= 	dx5p+(dt>>>7);  	   
	`endif	 	
	
	
	
endmodule
