module  pid_increse(
	input		signed [15:0]		  ek0	, // e(k)
	input		signed [15:0]		  ek1	, // e(k-1)
	input		signed [15:0]		  ek2	, // e(k-2)
	input		[11:0]		  kp	, // 比例系数
	input	    [11:0]		  ki	, // 积分系数
	input		[11:0]		  kd	, // 微分系数
	output		signed [15:0]		 d_uk	  // pid增量
);
 
assign  d_uk = (kp*(ek0 -ek1) + ki*ek0 + kd*((ek0 - ek1)-(ek1 - ek2)))/1000; // 计算pid增量
 
endmodule