/*
module adc_data(
    input clk,
    input rst,
    input [11:0] ad_out,
    
    output reg [31:0] sample_time // 用于记录采样时刻
);

reg [31:0] clk_counter; // 时钟计数器

// 文件句柄
integer file;

initial begin
    // 打开文件用于写入
    file = $fopen("D:\\Joy\\project\\Gowin_project\\rs_h_v0.3\\rs_h\\data\\adc_sample_data.txt", "w");
    if (file == 0) begin
        $display("Error: Could not open file.");
        $finish;
    end
end

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        clk_counter <= 32'd0;
        sample_time <= 32'd0;
    end else begin
        clk_counter <= clk_counter + 1;
        sample_time <= clk_counter;

        // 将采样数据和时间写入文件
        $fwrite(file, "Sampled Data: %d, Time: %d\n", ad_out, sample_time);
    end
end

// 关闭文件
always @(negedge rst) begin
    if (!rst) begin
        $fclose(file);
    end
end

endmodule
*/