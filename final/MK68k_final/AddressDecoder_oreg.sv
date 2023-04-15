module AddressDecoder_oreg (
	input logic clk,
	input logic reset_L, 				// active low
	input logic VGA_crx_sel,
	input logic VGA_cry_sel,
	input logic VGA_ctl_sel,
	input logic [7:0] Data_Ctrl,
	output logic [7:0] crx_out,
	output logic [7:0] cry_out,
	output logic [7:0] ctl_out
);

always_ff @(posedge clk or negedge reset_L) begin
	if (!reset_L) begin
		crx_out <= 8'b0010_0100;	// 40
		cry_out <= 8'b0001_0100;    // 20
		ctl_out <= 8'b1111_0010;
	end
	else begin
		if (VGA_crx_sel) begin
			crx_out <= Data_Ctrl;
		end
		else if (VGA_cry_sel) begin
			cry_out <= Data_Ctrl;
		end
		else if (VGA_ctl_sel) begin
			ctl_out <= Data_Ctrl;
		end
	end
end

endmodule

// module AddressDecoder_oreg (
// 	input logic clk,
// 	input logic reset_L, 				// active low
// 	input logic [1:0] Address_Ctrl,
// 	input logic [7:0] Data_Ctrl,
// 	output logic [7:0] crx_out,
// 	output logic [7:0] cry_out,
// 	output logic [7:0] ctl_out
// );

// // logic crx_enable, cry_enable, ctl_enable; 	// 1, 2, 3

// // assign crx_enable = (Address_Ctrl == 2'b01) ? 1'b1 : 1'b0;
// // assign cry_enable = (Address_Ctrl == 2'b10) ? 1'b1 : 1'b0;
// // assign ctl_enable = (Address_Ctrl == 2'b11) ? 1'b1 : 1'b0;

// // assign crx_out = 8'b0010_0100;	// 40
// //assign cry_out = 8'b0001_0100;    // 20
// assign ctl_out = 8'b1111_0010;

// always_ff @(posedge clk or negedge reset_L) begin
// 	if (!reset_L) begin
// 		crx_out <= 8'b0010_0100;	// 40
// 		cry_out <= 8'b0001_0100;    // 20
// 		// ctl_out <= 8'b1111_0010;
// 	end
// 	else begin
// 		if (Address_Ctrl == 2'b01) begin
// 			crx_out <= Data_Ctrl;
// 		end
// 		else if (Address_Ctrl == 2'b10) begin
// 			cry_out <= Data_Ctrl;
// 		end
// 		// else if (Address_Ctrl == 2'b11) begin
// 		// 	ctl_out <= Data_Ctrl;
// 		// end
// 	end
// end

// endmodule