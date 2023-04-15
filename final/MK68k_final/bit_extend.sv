module bit_extend (
	input logic in1,
	output logic [7:0] out8
);

assign out8 = in1 ? 8'b1111_1111 : 8'b0;

endmodule