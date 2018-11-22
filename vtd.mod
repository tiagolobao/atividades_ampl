
/* DADOS DO PROBLEMA */

set V; # nós da rede

set ENLACES within (V cross V); # enlaces da rede
set C within (V cross V); #Capacidade do enlace i,j

set w_bw; #custo da rede
set w_dpi; #custo de licensa
set w_cpu; #cursto por vCPU

set LIGHTPATHS within (V cross V);
set LIGHTPATHSxENLACES:= LIGHTPATHS cross LIGHTPATHS;
set LIGHTPATHSxENLACESS:= LIGHTPATHS cross ENLACES;
set LIGHTPATHSxV:= LIGHTPATHS cross V;

param P{(s,d) in LIGHTPATHS}; # fluxo de pacotes do par s-d (fonte-destino) dado pela Matriz de Tráfego


/* VARIÁVEIS DO PROBLEMA */
var COST >= 0 integer; # custo total da rede
var x{ (s,d,i,j) in LIGHTPATHSxENLACES } >= 0; # fluxo do par s-d que passa pelo enlace  i-j (ANTES DO DPI)
var y{ (s,d,i,j) in LIGHTPATHSxENLACES } >= 0; # fluxo do par s-d que passa pelo enlace i-j (DEPOIS DO DPI)
var dpi { (s,d,i) in LIGHTPATHSxV } binary; # indica a existencia de um DPI ou não
var vCPU{ i in V } >= 0; # quantidade de vCPU ativos


# Função objetivo (Minimizar o Custo)
minimize M_OBJETIVO: COST;

/* RESTRIÇÃO DO CUSTO */
subject to the_cost:
sum{ (i,j) in ENLACES , (s,d) in LIGHTPATHS }( fsize*w_bw*(x[s,d,i,j]+y[s,d,j,i] ) +
sum{ i in V } dpi[i]*w_dpi +
sum{ i in V } vCPU[i]*w_cpu
= COST;

/* RESTRIÇÔES PARA X */
subject to demanda_x {(s,d) in LIGHTPATHS}:
sum{ (i,j) in ENLACES: i=s  }(x[s,d,i,j] + dpi[s,d,i]) = 1;

subject to conserv_x {(s,d) in LIGHTPATHS}:
sum{ (i,j) in ENLACES: i!=s }(x[s,d,i,j] + dpi[s,d,i]) = sum{ (i,j) in LIGHTPATHS: i!=s }x[s,d,j,i];


/* RESTRIÇÕES PARA Y */
subject to demanda_y {(s,d) in LIGHTPATHS}:
sum{ (i,j) in ENLACES: i=s  }(y[s,d,i,j] + dpi[s,d,i]) = 1;

subject to conserv_y {(s,d) in LIGHTPATHS}:
sum{ (i,j) in ENLACES: i!=s }(y[s,d,i,j] + dpi[s,d,i]) = sum{ (i,j) in LIGHTPATHS: i!=s }y[s,d,j,i];


/* OUTRAS RESTRIÇÔES */
subject to capacidade_link {(i,j) in ENLACES }:
sum{(s,d) in LIGHTPATHS}( fs*( x[s,d,i,j]+y[s,d,j,i] ) ) <= C[i,j];

subject to unicidade_sonda {(s,d) in LIGHTPATHS}:
sum{ i in V }dpi[s,d,i] = 1;

subject to abertura_cpu {(s,d) in LIGHTPATHS}:
sum{ i in V }( fs*dpi[s,d,i] ) <= C[i,j]*vCPU[i];

subject to abertura_site {(s,d) in LIGHTPATHS, i in V}:
dpi[s,d,i] <= dpi[i];


end;
