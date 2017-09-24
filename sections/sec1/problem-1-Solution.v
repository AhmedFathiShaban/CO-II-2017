module shift_reg(input wire clk, input wire newBit, input wire reset, output reg [3:0] p_out );

//p_out is parallel_out
always @(reset)
begin
p_out <= 0;
end

always @ (posedge clk)
begin
	p_out <= {p_out[2], p_out[1], p_out[0], newBit} ;
end
endmodule

module seq_det(input wire clk, input wire reset, input wire newBit, output wire[3:0] shift_reg_out ,output reg ok );
parameter A = 0;
parameter B = 1;
parameter C = 2;
parameter D = 3;

reg [1:0] currentState;
reg [1:0] nextState;

always @(posedge clk)
begin
	if(reset)
	   currentState <= A;
	else
	   currentState <= nextState;
end

always@(newBit,currentState)
begin
	case (currentState)
	 	A: 
		begin 
			case (newBit)
			0:
			begin
				nextState <=A;
				ok <= 1'b0;
			end
			1:
			begin
				nextState <= B;
				ok <=1'b0;
			end
			endcase
		end

		B:
		begin 
			case (newBit)
			0:
			begin
			nextState <=C;
			ok <=1'b0;
			end
			1:
			begin
			nextState <=B;
			ok <=1'b0;

			end
			endcase

		end

		C:
		begin 
			case (newBit)
			0:
			begin
			nextState <=A;
			ok <= 1'b0;
			end
			1:
			begin
			nextState <=D;
			ok <= 1'b0;
			end
			endcase

		end

		D:
		begin 
			case (newBit)
			0:
			begin
			nextState <= C;
			ok <= 1'b0;
			end
			1:
			begin
			 nextState <=B;
			 ok <= 1'b1;
			end
			endcase

		end
	endcase


end

shift_reg first (clk, newBit, reset, shift_reg_out);

endmodule

module checker(input wire ok1, input wire ok2, input wire [3:0] n1, input wire [3:0] n2,  output wire [1:0] mode, output wire[3:0] r);
assign r = n1 ^ n2;
assign mode = (ok1 & ok2)? 2'b10 : (ok1 | ok2)? 2'b01 : 2'b00;
endmodule

module top_module(input clk, input reset, input seq1, input seq2, output wire [1:0] mode, output wire[3:0] result);
wire [3:0] n1;
wire [3:0] n2;
wire ok1;
wire ok2;
seq_det seqDet1 (clk, reset, seq1, n1, ok1);
seq_det seqDet2 (clk, reset, seq2, n2, ok2);
checker meChecker(ok1,ok2,n1,n2,mode, result);

endmodule


module tb();

reg clk;
reg reset;
reg [31:0] seq1 = 32'b1001_1011_1011_1010_1010_1011_1011_1001;
reg [31:0] seq2 = 32'b1010_1011_1010_1010_1011_1011_1011_1011;

wire[1:0] mode;
wire [3:0] result;

top_module meTopModule(clk, reset, seq1[31], seq2[31], mode, result);

always 
#10 clk = ~ clk;

always @(posedge clk)
begin
if(!reset)
begin
	seq1 <= seq1 << 1 ;
	seq2 <= seq2 << 1 ;
end
end

initial begin

$monitor("%b %b", result, mode);
reset <=1 ;
clk <= 0;
#30 reset <=0;

end

endmodule