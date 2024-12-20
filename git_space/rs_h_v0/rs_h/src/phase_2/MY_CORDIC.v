module MY_CORDIC(
    input                   sys_clk ,
    input                   sys_rst ,

    input   signed  [31:0]   x       ,  // 最高位代表符号位
    input   signed  [31:0]   y       ,  // 最高位代表符号位

    output  reg [31:0]       phase   , // 计算的结果在 [0, 360] 之间
    output  reg [31:0]       mo_value,
    output  reg              valid   // 输出结果有效信号
);

// 旋转角度查找表
wire   [31:0]rot[15:0];

assign  rot[0]  = 32'd2949120 ;     // 45.0000度*2^16
assign  rot[1]  = 32'd1740992 ;     // 26.5651度*2^16
assign  rot[2]  = 32'd919872  ;     // 14.0362度*2^16
assign  rot[3]  = 32'd466944  ;     // 7.1250度*2^16
assign  rot[4]  = 32'd234368  ;     // 3.5763度*2^16
assign  rot[5]  = 32'd117312  ;     // 1.7899度*2^16
assign  rot[6]  = 32'd58688   ;     // 0.8952度*2^16
assign  rot[7]  = 32'd29312   ;     // 0.4476度*2^16
assign  rot[8]  = 32'd14656   ;     // 0.2238度*2^16
assign  rot[9]  = 32'd7360    ;     // 0.1119度*2^16
assign  rot[10] = 32'd3648    ;     // 0.0560度*2^16
assign  rot[11] = 32'd1856    ;     // 0.0280度*2^16
assign  rot[12] = 32'd896     ;     // 0.0140度*2^16
assign  rot[13] = 32'd448     ;     // 0.0070度*2^16
assign  rot[14] = 32'd256     ;     // 0.0035度*2^16
assign  rot[15] = 32'd128     ;     // 0.0018度*2^16

// FSM_parameter
localparam IDLE = 2'd0;
localparam WORK = 2'd1;
localparam ENDO = 2'd2; 

reg     [1:0]   state       ;
reg     [1:0]   next_state  ;
reg     [3:0]   cnt;

// 提取实际数据部分（[31:0]），符号由[32]位表示
wire signed [30:0] x_data = x[30:0];
wire signed [30:0] y_data = y[30:0];
wire x_sign = x[31];
wire y_sign = y[31];

reg signed [31:0] x_shift;
reg signed [31:0] y_shift;
reg signed [31:0] z_rot;

always @(posedge sys_clk or negedge sys_rst) begin
    if (!sys_rst)
        next_state <= IDLE;
    else begin
        state <= next_state;
        case (state)
            IDLE: next_state <= WORK;
            WORK: next_state <= (cnt == 15) ? ENDO : WORK;
            ENDO: next_state <= IDLE;
            default: next_state <= IDLE;
        endcase
    end
end

wire D_sign;
assign D_sign = ~y_shift[31];

always @(posedge sys_clk) begin
    case (state)
        IDLE:
        begin
            x_shift <= x_data;  // 使用实际数据 [31:0]
            y_shift <= y_data;  // 使用实际数据 [31:0]
            z_rot <= 0;
            valid <= 0; // IDLE状态时，valid信号为0
        end
        
        WORK:
        if (D_sign) begin
            x_shift <= x_shift + (y_shift >>> cnt);
            y_shift <= y_shift - (x_shift >>> cnt);
            z_rot   <= z_rot + rot[cnt];
        end
        else begin
            x_shift <= x_shift - (y_shift >>> cnt);
            y_shift <= y_shift + (x_shift >>> cnt);
            z_rot   <= z_rot - rot[cnt];
        end
        
        ENDO:
        begin
            valid <= 1; // 结果计算完成，valid信号置为1
            // 根据最高位符号判断象限并调整相位
            if (x_sign == 0 && y_sign == 0) begin  // 第一象限
                phase <= z_rot >>> 16; // 只有在valid有效时才输出phase
            end
            else if (x_sign == 1 && y_sign == 0) begin  // 第二象限
                phase <=  (32'd180 - (z_rot >>> 16)) ;  // 从 180° 向左回旋
            end
            else if (x_sign == 1 && y_sign == 1) begin  // 第三象限
                phase <= (32'd180 + (z_rot >>> 16));  // 从 180° 向下继续旋转
            end
            else if (x_sign == 0 && y_sign == 1) begin  // 第四象限
                phase <= (32'd360 - (z_rot >>> 16));  // 从 360° 回旋
            end

            mo_value <= (x_shift >>> 16) * 3963 >>> 22;
            
        end
        
        default :;
    endcase
end

always @(posedge sys_clk or negedge sys_rst) begin
    if (!sys_rst)
        cnt <= 4'd0;
    else if (state == IDLE && next_state == WORK)
        cnt <= 4'd0;
    else if (state == WORK) begin
        if (cnt < 4'd15)
            cnt <= cnt + 1'b1;
        else
            cnt <= cnt;
    end
    else
        cnt <= 4'd0;
end

endmodule
