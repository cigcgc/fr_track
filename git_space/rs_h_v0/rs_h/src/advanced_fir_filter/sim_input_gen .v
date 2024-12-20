module sim_input_gen (
    clk,
    rstn, 
    rfi_i, 
    sim_valid_o,
    sim_sync_o
);

//**********************************************************************
// --- Parameter
//**********************************************************************
    parameter NUM_CHN = 4;       // 通道数量
    parameter NUM_CYCLE = 4;     // 每个通道的周期数
    
    localparam CYCLE_WIDTH = (NUM_CYCLE > 1) ? $clog2(NUM_CYCLE) : 1;
    localparam CHN_WIDTH = (NUM_CHN > 1) ? $clog2(NUM_CHN) : 1;

//**********************************************************************
// --- Input/Output Declaration
//**********************************************************************
// --- input
    input                       clk;
    input                       rstn;
    input                       rfi_i;

// --- output
    output reg                  sim_valid_o;
    output reg                  sim_sync_o;

//**********************************************************************
// --- Internal Signal Declaration
//**********************************************************************
    reg rfi_r0;
    wire rfi_posedge;
    
    reg [CYCLE_WIDTH:0] cnt_cycle;
    reg [CHN_WIDTH-1:0] cnt_chn;

//**********************************************************************
// --- Main core
//**********************************************************************
    // Detect rfi_i posedge
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            rfi_r0 <= 0;
        end 
        else begin
            rfi_r0 <= rfi_i;
        end
    end
    assign rfi_posedge = rfi_i & ~rfi_r0;

    // Cycle counter
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            cnt_cycle <= NUM_CYCLE;
        end
        else if (rfi_posedge == 1'b1 || (rfi_i == 1'b1 && cnt_cycle == NUM_CYCLE-1)) begin
            cnt_cycle <= 0;
        end
        else if ((cnt_cycle == NUM_CYCLE || cnt_cycle == NUM_CYCLE-1) && cnt_chn == NUM_CHN-1) begin
            cnt_cycle <= cnt_cycle;
        end
        else begin
            cnt_cycle <= cnt_cycle + 1'b1;
        end
    end

    // Channel counter
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            cnt_chn <= NUM_CHN-1;
        end
        else if (rfi_posedge == 1'b1 || (rfi_i == 1'b1 && cnt_chn == NUM_CHN-1 && cnt_cycle == NUM_CYCLE-1)) begin
            cnt_chn <= 0;
        end
        else if (cnt_chn == NUM_CHN-1) begin
            cnt_chn <= cnt_chn;
        end
        else if (cnt_cycle == NUM_CYCLE-1) begin
            cnt_chn <= cnt_chn + 1'b1;
        end
    end

    // Generate sim_valid and sim_sync signals
    assign sim_valid = (cnt_cycle == 0) ? 1'b1 : 1'b0;
    assign sim_sync = (cnt_cycle == 0 && cnt_chn == 0) ? 1'b1 : 1'b0;

    // sim_valid_o and sim_sync_o outputs
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            sim_valid_o <= 0;
            sim_sync_o <= 0;
        end
        else begin
            sim_valid_o <= sim_valid;
            sim_sync_o <= sim_sync;
        end
    end

endmodule
