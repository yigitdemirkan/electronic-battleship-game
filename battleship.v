module battleship (
  input            clk  ,
  input            rst  ,
  input            start,
  input      [1:0] X    ,
  input      [1:0] Y    ,
  input            pAb  ,
  input            pBb  ,
  output reg [7:0] disp0,
  output reg [7:0] disp1,
  output reg [7:0] disp2,
  output reg [7:0] disp3,
  output reg [7:0] led
);

reg[3:0]    state;
reg[15:0]   mapA;
reg[15:0]   mapB;
reg[2:0]    Score_A;
reg[2:0]    Score_B;
reg[1:0]    counter;
reg[2:0]    led_counter;
reg[1:0]    input_count;
reg         control;
reg         Z;
reg         SW0;
reg         SW1;
reg         SW2;
reg         SW3;

parameter LIMIT = 3;
parameter IDLE = 4'b0000;
parameter SHOW_A = 4'b0001;
parameter A_IN = 4'b0010;
parameter ERROR_A = 4'b0011;
parameter SHOW_B = 4'b0100;
parameter B_IN = 4'b0101;
parameter ERROR_B = 4'b0110;
parameter SHOW_SCORE = 4'b0111;
parameter A_SHOOT = 4'b1000;
parameter A_SINK = 4'b1001;
parameter A_WIN = 4'b1010;
parameter B_SHOOT = 4'b1011;
parameter B_SINK = 4'b1100;
parameter B_WIN = 4'b1101;
parameter zero = 2'b00;
parameter one = 2'b01;
parameter two = 2'b10;
parameter three = 2'b11;


always@(posedge clk or posedge rst) begin
  SW0 = Y[0];
  SW1 = Y[1];
  SW2 = X[0];
  SW3 = X[1];
end

always @(posedge clk or posedge rst) begin
  if(rst) begin
    state <= IDLE;
  end
  else begin
    case(state)
        IDLE:begin
          if(start) begin
             state <= SHOW_A;
          end
          else begin
            state <= IDLE;
          end
        end

        SHOW_A:begin 
          if (counter < LIMIT) begin
            state <= SHOW_A;
            counter <= counter + 1;
          end
          else begin
            state <= A_IN;
          end
        end
        A_IN: begin
          if(pAb) begin
            if(mapA[{Y,X}]) begin
              state <= ERROR_A;
            end
            else begin
              if(input_count > 2) begin
                state <= SHOW_B;
                mapA[{Y,X}] <= 1;
                input_count <= 0;
              end
              else begin
                state <= A_IN;
                mapA[{Y,X}] <= 1;
                input_count <= input_count+1;
              end
            end
          end
          else begin
            state <= A_IN;
          end
        end

        ERROR_A: begin
          if(counter < LIMIT) begin
            state <= ERROR_A;
            counter <= counter + 1;
          end
          else begin
            state <= A_IN;
          end
        end

        SHOW_B:begin
          if(counter < LIMIT) begin
            state <= SHOW_B;
            counter <= counter + 1;
          end
          else begin
            state <= B_IN;
          end
        end

        B_IN: begin
          if(pBb) begin
            if(mapB[{Y,X}]) begin
              state <= ERROR_B;
            end
            else begin
              if(input_count > 2) begin
                state <= SHOW_SCORE;
                mapB[{Y,X}] <= 1;
              end
              else begin
                state <= B_IN;
                mapB[{Y,X}] <= 1;
                input_count <= input_count + 1;
              end
            end
          end
          else begin
            state <= B_IN;
          end
        end

        ERROR_B: begin
          if(counter < LIMIT) begin
            state <= ERROR_B;
            counter <= counter + 1;
          end
          else begin
            state <= B_IN;
          end
        end

        SHOW_SCORE: begin
          if(counter < LIMIT) begin
            state <= SHOW_SCORE;
            counter <= counter + 1;
          end
          else begin 
            state <= A_SHOOT;
          end
        end

        A_SHOOT: begin
          if(pAb) begin
            if(mapB[{Y,X}]) begin
              state <= A_SINK;
              Score_A <= Score_A + 1;
              Z <= 1;
              mapB[{Y,X}] <= 0;
            end
            else begin
              state <= A_SINK;
              Score_A <= Score_A;
              Z <= 0;
            end
          end
          else begin
            state <= A_SHOOT;
          end
        end

        A_SINK: begin
          if(counter < LIMIT) begin
            counter <= counter + 1;
            if(Z) begin
              state <= A_SINK;
              led <= 8'b11111111;
            end
            else begin
              state <= A_SINK;
              led <= 8'b00000000;
            end
          end
          else begin
            if(Score_A > 3) begin
              state <= A_WIN;
            end
            else begin
              state <= B_SHOOT;
            end
          end
        end

        A_WIN: begin
          state <= A_WIN;
        end

        B_SHOOT:begin
          if(pBb) begin
            if(mapA[{Y,X}]) begin
              state <= B_SINK;
              Score_B <= Score_B + 1;
              Z <= 1;
              mapA[{Y,X}] <= 0;
            end
            else begin
              state <= B_SINK;
              Score_B <= Score_B;
              Z <= 0;
            end
          end
          else begin
            state <= B_SHOOT;
          end
        end

        B_SINK: begin
          if(counter < LIMIT) begin
            counter <= counter + 1;
            if(Z) begin
              state <= B_SINK;
              led <= 8'b11111111;
            end
            else begin
              state <= B_SINK;
              led <= 8'b00000000;
            end
          end
          else begin
            if(Score_B > 3) begin
              state <= B_WIN;
            end
            else begin
              state <= A_SHOOT;
            end
          end
        end

        B_WIN:begin
          state <= B_WIN;
        end

          
    endcase
  end

  end

  always@(posedge clk or posedge rst) begin
    if(rst) begin
      mapA <= 0;
      mapB <= 0;
      Score_A <= 0;
      Score_B <= 0;
      counter <= 0;
      input_count <= 0;
      led <= 8'b10011001;
      disp0 <= 8'b01111001;
      disp1 <= 8'b00111000;
      disp2 <= 8'b01011110;
      disp3 <= 8'b00000110;
      Z <= 0;
    end
    else begin
      case(state)

        IDLE: begin end
        SHOW_A: begin
          disp0 <= 0;
          disp1 <= 0;
          disp2 <= 0;
          disp3 <= 8'b01110111;
        end
        A_IN: begin
          disp3 <= 8'b00000000;
          disp2 <= 8'b00000000;
          if({SW3,SW2} == zero)begin
            disp1 <= 8'b00111111;
          end
          else if({SW3,SW2} == one)begin
            disp1 <= 8'b00000110;
          end
          else if({SW3,SW2} == two)begin
            disp1 <= 8'b01011011;
          end
          else begin
            disp1 <= 8'b01001111;
          end

          if({SW1,SW0} == zero)begin
            disp0 <= 8'b00111111;
          end
          else if({SW1,SW0} == one)begin
            disp0 <= 8'b00000110;
          end
          else if({SW1,SW0} == two)begin
            disp0 <= 8'b01011011;
          end
          else begin
            disp0 <= 8'b01001111;
          end
          led <= 8'b10000000;
          led[5:4] <= input_count;
          counter <= 0;
        end
        
        ERROR_A: begin
          disp0 <= 8'b01011100;
          disp1 <= 8'b01010000;
          disp2 <= 8'b01010000;
          disp3 <= 8'b01111001;
          led <= 8'b10011001;
        end
        
        SHOW_B: begin 
          disp3 <= 8'b01111100;
          disp2 <= 0;
          disp1 <= 0;
          disp0 <= 0;
          led <= 8'b10011001;
        end
        
        B_IN: begin
          disp3 <= 8'b00000000;
          disp2 <= 8'b00000000;
          if({SW3,SW2} == zero)begin
            disp1 <= 8'b00111111;
          end
          else if({SW3,SW2} == one)begin
            disp1 <= 8'b00000110;
          end
          else if({SW3,SW2} == two)begin
            disp1 <= 8'b01011011;
          end
          else begin
            disp1 <= 8'b01001111;
          end

          if({SW1,SW0} == zero)begin
            disp0 <= 8'b00111111;
          end
          else if({SW1,SW0} == one)begin
            disp0 <= 8'b00000110;
          end
          else if({SW1,SW0} == two)begin
            disp0 <= 8'b01011011;
          end
          else begin
            disp0 <= 8'b01001111;
          end
          led <= 8'b00000001;
          led[3:2] <= input_count;
          counter <= 0;
        end
        
        ERROR_B:begin
          disp0 <= 8'b01011100;
          disp1 <= 8'b01010000;
          disp2 <= 8'b01010000;
          disp3 <= 8'b01111001;
          led <= 8'b10011001;
        end

        SHOW_SCORE: begin
          disp3 <= 0;
          disp2 <= 8'b00111111;
          disp1 <= 8'b01000000;
          disp0 <= 8'b00111111;
          led <= 8'b10011001;
        end
        A_SHOOT: begin
          disp3 <= 8'b00000000;
          disp2 <= 8'b00000000;
          if({SW3,SW2} == zero)begin
            disp1 <= 8'b00111111;
          end
          else if({SW3,SW2} == one)begin
            disp1 <= 8'b00000110;
          end
          else if({SW3,SW2} == two)begin
            disp1 <= 8'b01011011;
          end
          else begin
            disp1 <= 8'b01001111;
          end

          if({SW1,SW0} == zero)begin
            disp0 <= 8'b00111111;
          end
          else if({SW1,SW0} == one)begin
            disp0 <= 8'b00000110;
          end
          else if({SW1,SW0} == two)begin
            disp0 <= 8'b01011011;
          end
          else begin
            disp0 <= 8'b01001111;
          end
          led <= 8'b10000000;
          led[5:4] <= Score_A;
          led[3:2] <= Score_B;
          counter <= 0;
        end

        A_SINK: begin
          if(Score_A == zero)begin
            disp2 <= 8'b00111111;
          end
          else if(Score_A == one)begin
            disp2 <= 8'b00000110;
          end
          else if(Score_A == two)begin
            disp2 <= 8'b01011011;
          end
          else if(Score_A == three)begin
            disp2 <= 8'b01001111;
          end
          else begin
            disp2 <= 8'b01100110;
          end
          disp1 <= 8'b01000000;
          if(Score_B == zero)begin
            disp0 <= 8'b00111111;
          end
          else if(Score_B == one)begin
            disp0 <= 8'b00000110;
          end
          else if(Score_B == two)begin
            disp0 <= 8'b01011011;
          end
          else if(Score_B == three)begin
            disp0 <= 8'b01001111;
          end
          else begin
            disp0 <= 8'b01100110;
          end
        end

        A_WIN: begin
          disp3 <= 8'b01110111;
          if(Score_A == zero)begin
            disp2 <= 8'b00111111;
          end
          else if(Score_A == one)begin
            disp2 <= 8'b00000110;
          end
          else if(Score_A == two)begin
            disp2 <= 8'b01011011;
          end
          else if(Score_A == three)begin
            disp2 <= 8'b01001111;
          end
          else begin
            disp2 <= 8'b01100110;
          end
          disp1 <= 8'b01000000;
          if(Score_B == zero)begin
            disp0 <= 8'b00111111;
          end
          else if(Score_B == one)begin
            disp0 <= 8'b00000110;
          end
          else if(Score_B == two)begin
            disp0 <= 8'b01011011;
          end
          else if(Score_B == three)begin
            disp0 <= 8'b01001111;
          end
          else begin
            disp0 <= 8'b01100110;
          end
        end

        B_SHOOT: begin
          disp3 <= 8'b00000000;
          disp2 <= 8'b00000000;
          if({SW3,SW2} == zero)begin
            disp1 <= 8'b00111111;
          end
          else if({SW3,SW2} == one)begin
            disp1 <= 8'b00000110;
          end
          else if({SW3,SW2} == two)begin
            disp1 <= 8'b01011011;
          end
          else begin
            disp1 <= 8'b01001111;
          end

          if({SW1,SW0} == zero)begin
            disp0 <= 8'b00111111;
          end
          else if({SW1,SW0} == one)begin
            disp0 <= 8'b00000110;
          end
          else if({SW1,SW0} == two)begin
            disp0 <= 8'b01011011;
          end
          else begin
            disp0 <= 8'b01001111;
          end
          led <= 8'b00000001;
          led[5:4] <= Score_A;
          led[3:2] <= Score_B;
          counter <= 0;
        end

        B_SINK: begin
          if(Score_A == zero)begin
            disp2 <= 8'b00111111;
          end
          else if(Score_A == one)begin
            disp2 <= 8'b00000110;
          end
          else if(Score_A == two)begin
            disp2 <= 8'b01011011;
          end
          else if(Score_A == three)begin
            disp2 <= 8'b01001111;
          end
          else begin
            disp2 <= 8'b01100110;
          end
          disp1 <= 8'b01000000;
          if(Score_B == zero)begin
            disp0 <= 8'b00111111;
          end
          else if(Score_B == one)begin
            disp0 <= 8'b00000110;
          end
          else if(Score_B == two)begin
            disp0 <= 8'b01011011;
          end
          else if(Score_B == three)begin
            disp0 <= 8'b01001111;
          end
          else begin
            disp0 <= 8'b01100110;
          end
        end

        B_WIN: begin
          disp3 <= 8'b01111100;
          if(Score_A == zero) begin
            disp2 <= 8'b00111111;
          end
          else if(Score_A == one) begin
            disp2 <= 8'b00000110;
          end
          else if(Score_A == two)begin
            disp2 <= 8'b01011011;
          end
          else if(Score_A == three)begin
            disp2 <= 8'b01001111;
          end
          else begin
            disp2 <= 8'b01100110;
          end
          disp1 <= 8'b01000000;
          if(Score_B == zero) begin
            disp0 <= 8'b00111111;
          end
          else if(Score_B == one)begin
            disp0 <= 8'b00000110;
          end
          else if(Score_B == two)begin
            disp0 <= 8'b01011011;
          end
          else if(Score_B == three)begin
            disp0 <= 8'b01001111;
          end
          else begin
            disp0 <= 8'b01100110;
          end
        end

      endcase
    end
  end

  always @(posedge clk or posedge rst) begin
    if(rst) begin
      led_counter <= 0;
      led <= 0;
    end
    else if((state == A_WIN) || (state == B_WIN)) begin
      if(led_counter < LIMIT) begin
        led <= 8'b11111111;
        led_counter <= led_counter + 1;
      end
      else if (led_counter < 2*LIMIT)begin
        led <= 0;
        led_counter <= led_counter + 1;
        if(led_counter == 5) begin
          led_counter <= 0;
        end
      end
    end
  end


endmodule