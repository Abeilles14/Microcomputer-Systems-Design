module bit_extend_oreg (
	output logic [7:0] crx_out,
	output logic [7:0] cry_out,
	output logic [7:0] ctl_out
);

assign crx_out = 8'b0010_0100;	// 40
assign cry_out = 8'b0001_0100;  // 20
assign ctl_out = 8'b1111_0010;

endmodule