/*-------------------------------------
-------Instancias de los Módulos-------
-------------------------------------*/

module Instancias_D(input [0:0] clk,
                  input [0:0] reset,
                  input [3:0] dft, // Filas del Teclado
                  output [3:0] bt, // Columnas y Barrido del Teclado
                  //output [2:0] bd,
                  output [6:0] dd); // Salida a 7 Segmentos 
    
    logic [3:0] td; //Bits codificados del Teclado 
    logic [3:0] ft; //Tecla luego del Flip-Flop
    logic [3:0] OP; //Tecla luego del Flip-Flop
    logic [3:0] E_N; // 
    logic [0:0] et; //Enable flip-flop Teclado
    logic [0:0] a; // Enable Total
    logic [0:0] a_d; //Enable de OP
    logic [3:0] Va; //Variable a
    logic [3:0] Vb; //Variable b
    logic [3:0] y; //Variable a
      
    BarridoTeclado BT1 (clk, reset, bt);
    DecoTeclado DT1 ({dft,bt}, td);
    CompuertaOR_T COR (dft, et);            //Activación de flip-flop desde el teclado
    flopenr ff1 (clk, reset, et, td, ft);   //Flip-Flop Tecla guardada.
    CompuertaOR COR1 (td, a); //Enable General
    CompuertaOR_D COR2 (ft, a_d); //Enable de Operación 
    SeleccionadorNumero SN (clk, reset, a_d, a, ft, Va, Vb); //Selecciona Número a pasar
    flopenr ff2 (clk, reset, a_d, td, OP); //Flip-Flop con Operación Guardada.
    Operador OP1 (ft, a, Va, Vb, y);    
    sevenseg DSS (y, dd);
     
endmodule

--------------------------------------

/*-------------------------------------
--------Decodificador de 7Seg----------
-------------------------------------*/

module sevenseg(input logic[3:0] data, 
		        output logic[6:0] segments);

always_comb
case(data)
// 		          abc_defg
 0: segments = 7'b000_0001;
 1: segments = 7'b100_1111;
 2: segments = 7'b001_0010;
 3: segments = 7'b000_0110;
 4: segments = 7'b100_1100;
 5: segments = 7'b010_0100;
 6: segments = 7'b010_0000;
 7: segments = 7'b000_1111;
 8: segments = 7'b000_0000;
 9: segments = 7'b000_1100;
10: segments = 7'b000_1000; //A
11: segments = 7'b110_0000; //B
12: segments = 7'b011_0001; //C
13: segments = 7'b100_0010; //D
14: segments = 7'b011_0000; //E
15: segments = 7'b011_1000; //F

default: segments = 7'b111_1111;

endcase
endmodule

/*-------------------------------------
----------Barrido del Teclado----------
-------------------------------------*/

module BarridoTeclado (input logic clk,
		               input logic reset,
    		           output logic [3:0]bt);

    typedef enum logic [2:0]{S0,S1,S2,S3} statetype;
    statetype state, nextstate;

    always_ff@(posedge clk, posedge reset)
    	if (reset) state <= S0;
    	else 	   state <= nextstate;
    
    always_comb
     case(state)
        S0: nextstate=S1;
        S1: nextstate=S2;
        S2: nextstate=S3;
	    S3: nextstate=S0;
    default nextstate=S0;
     endcase

    always_comb
        case(state)
        S0: bt=4'b1110;
        S1: bt=4'b1101;
        S2: bt=4'b1011;
	    S3: bt=4'b0111;
    default bt=4'b1110;
    endcase  
endmodule


/*-------------------------------------
---------Barrido del Display-----------
-------------------------------------*/

/*module BarridoDisplay (input logic clk,
		                 input logic reset,
    		             output logic [2:0]b);

    typedef enum logic [1:0]{S0,S1,S2} statetype;
    statetype state,nextstate;

    always_ff@(posedge clk, posedge reset)
    	if (reset) state <= S0;
    	else 	   state <= nextstate;
    
    always_comb
    case(state)
        S0: nextstate=S1;
        S1: nextstate=S2;
        S2: nextstate=S0;
	default nextstate=S0;
     endcase

    always_comb
    case(state)
        S0: b=3'b110;
        S1: b=3'b101;
        S2: b=3'b011;
	default b=3'b110;
    endcase  
endmodule*/


/*-------------------------------------
-------Decodificador del Teclado-------
-------------------------------------*/

module DecoTeclado (input logic [7:0]a,
           output logic [3:0]y);
  
    always_comb
     case(a)

    // Row__Col
    8'b1110_1110: y = 4'b0001; //1
    8'b1110_1101: y = 4'b0010; //2
    8'b1110_1011: y = 4'b0011; //3 
    8'b1110_0111: y = 4'b1010; //A
    //
    8'b1101_1110: y = 4'b0100; //4
    8'b1101_1101: y = 4'b0101; //5
    8'b1101_1011: y = 4'b0110; //6
    8'b1101_0111: y = 4'b1011; //B
    //
    8'b1011_1110: y = 4'b0111; //7
    8'b1011_1101: y = 4'b1000; //8
    8'b1011_1011: y = 4'b1001; //9
    8'b1011_0111: y = 4'b1100; //C
    //
    8'b0111_1110: y = 4'b0000; //0
    8'b0111_1101: y = 4'b1111; //F 
    8'b0111_1011: y = 4'b1110; //E 
    8'b0111_0111: y = 4'b1101; //D
    //
    default:      y = 4'bxxxx;
    endcase
endmodule

/*-------------------------------------
----------Flip-Flop Activable----------
-------------------------------------*/

module flopenr(input logic clk,
               input logic reset,
               input logic en,
               input logic [3:0] d,
               output logic [3:0] q);

	always_ff@(posedge clk, posedge reset)
		if (reset) q <= 4'b0;
		else if(en) q <= d;
endmodule


/*-------------------------------------
------------Compuerta OR---------------
-------------------------------------*/

module CompuertaOR(input logic [3:0]f_d_t,
                   output logic a);
                   
    always_comb
    case(f_d_t)
    
    4'b1110: a = 1'b1;
    default: a = 1'b0;
    
    endcase                 

endmodule

/*-------------------------------------
-----------Compuerta OR 2--------------
-------------------------------------*/

module CompuertaOR_D(input logic [3:0]OP,
                     output logic a);
                   
    always_comb
    case(OP)
    
    4'b1010: a = 1'b1;
    4'b1011: a = 1'b1;
    4'b1100: a = 1'b1;
    
    default: a = 1'b0;
    
    endcase                 

endmodule

/*-------------------------------------
-----------Compuerta ORT---------------
-------------------------------------*/

module CompuertaOR_T(input logic [3:0]f_d_t,
                   output logic a);
                   
    assign   a = ~f_d_t[3] | ~f_d_t[2] | ~f_d_t[1] | ~f_d_t[0];                   

endmodule

//*********************************//

/*-------------------------------------
---------Maquina de Números------------
-------------------------------------*/

module SeleccionadorNumero (input logic clk,
		                 input logic reset,
                         input logic OP,E,
                         input logic [3:0] n,
    		             output logic [3:0] a,
			             output logic [3:0] b);

    typedef enum logic [0:0]{S0,S1} statetype;
    statetype state,nextstate;

    always_ff@(posedge clk, posedge reset)
    	if (reset) state <= S0;
    	else 	   state <= nextstate;
    
    always_comb
    case(state)
        S0: if (OP) nextstate = S1;
  	        else nextstate = S0;
        S1: if (E) nextstate = S0;
	        else nextstate = S1;
        default nextstate = S0;
     endcase

    always_comb
    case(state)
        S0: a=n;
        S1: b=n;
    default {a,b} = 4'b0000; 
    endcase  
endmodule

/*-------------------------------------
--------------Operador-----------------
-------------------------------------*/

module Operador(input logic [3:0] OP,
	       //input logic cin,
	       input logic E,
	       input logic [3:0] a,
	       input logic [3:0] b, 	  
	       //output logic cout,
	       output logic [3:0] y);


	always_comb
	case(OP)
		// SUMA //
		4'b1010: 
			if (E) y = a+b;

		// RESTA //
		4'b1011: 
			if (E) y = a-b;

		// MULTIPLICACION //
		4'b1100: 
			if (E) y = a*b;

		// DIVISION //
		4'b1101: 
			if (E) y = a/b;

		default: y = 4'b0000;		
	endcase
endmodule
