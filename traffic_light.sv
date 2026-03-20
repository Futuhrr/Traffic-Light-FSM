module traffic_fsm (
    input  logic clk,
    input  logic reset,
    input  logic TAORB,
    output logic [2:0] LA,
    output logic [2:0] LB
);

    typedef enum logic [1:0] {
        S0, S1, S2, S3
    } state_t;

    state_t state, next_state;

    logic [2:0] timer;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= S0;
        else
            state <= next_state;
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            timer <= 0;
        else if (state == S1 || state == S3)
            timer <= timer + 1;
        else
            timer <= 0;
    end

    always_comb begin
        next_state = state; 

        case (state)
            S0: begin
                if (~TAORB)
                    next_state = S1;
            end

            S1: begin
                if (timer == 5)
                    next_state = S2;
            end

            S2: begin
                if (TAORB)
                    next_state = S3;
            end

            S3: begin
                if (timer == 5)
                    next_state = S0;
            end

            default: next_state = S0;
        endcase
    end

    always_comb begin
        LA = 3'b000;
        LB = 3'b000;

        case (state)
            S0: begin
                LA = 3'b100; // A Green
                LB = 3'b001; // B Red
            end

            S1: begin
                LA = 3'b010; // A Yellow
                LB = 3'b001; // B Red
            end

            S2: begin
                LA = 3'b001; // A Red
                LB = 3'b100; // B Green
            end

            S3: begin
                LA = 3'b001; // A Red
                LB = 3'b010; // B Yellow
            end
        endcase
    end

endmodule