/*
Cria um Alias para o diretório físico da tabela de dados
 - Máximo de 8 caracteres
 - Diretório deve estar entre aspas
*/

libname curso '/home/u63796413/Curso Alura';

proc contents
	data=curso.cadastro_cliente_corrigido;
run;

/*
Cria uma nova base chamada corrigeDataNasc para alterar o formato da variável(coluna) Nascimento, para tipo NUM que seja possível realizar operações
 - YYMMDD10. é o formato padrão de data com 10 dígitos e separador de traço (2024-06-15)
 - YYMMDD. é o formato padrão de data com 08 dígitos e separador de traço (24-06-15)
 - DDMMYY10. é o formato padrão de data com 10 dígitos e separador de barra (15/06/2024)
 - DDMMYY. é o formato padrão de data com 08 dígitos e separador de barra (15/06/24)
 - DATE9. é o formato padrão de data com 09 dígitos sem separador e mês com letras (06MAR1991)
 - YYMMDDN. é o formato padrão de data com 08 dígitos sem separador (20240615)

Criar uma variável com a data de hoje e configurar o seu formato
 - today() atribui a uma variável a data de hoje no formato de dias após 01/01/1960, não é necessário passar parâmetros. É preciso converter o formato usando o comando put.
 - mdy() atribui a uma variável a data descrita nos parâmetros (Mês, Dia, Ano) contados em dias após 01/01/1960. É preciso converter o formato usando o comando put.
 - intck() realiza os cálculos de passagem do tempo entre a data do segundo e terceiro parâmetro. O primeiro parâmetro é relativo ao intervalo e o quarto define o tipo de contagem:
 	- YEAR, MONTH, QTR(bimestre), SEMIYEAR(semestre), WEEK.
 	- Tipo de contagem: "C" Contínua e "D" Discreta
 	(https://documentation.sas.com/doc/en/lefunctionsref/3.2/p1md4mx2crzfaqn14va8kt7qvfhr.htm)
*/

data corrigeDataNasc;
	set curso.cadastro_cliente_corrigido;
	nova_data_nasc = input(nascimento, YYMMDD10.);
	format nova_data_nasc YYMMDDN.;
	hoje = put(today(), YYMMDD10.);
   	data_forcada = put(mdy(6,15,2024),YYMMDD10.);
   	idade = intck('year',input(nascimento, YYMMDD10.),mdy(2,25,2024),'c');
run;

proc print
	data=corrigeDataNasc;
run;

/*
Cria um gráfico utilizando a base de dados corrigeDataNasc, com os dados da variável(coluna) "estado".
 - sgplot é um procedimento de criação de gráficos
 - Parâmetros:
  	- title é título do gráfico
 	- vline é o gráfico de linhas
 	- vbar é o gráfico de barras verticais
 	- hbar é o gráfico de barras horizontais
 	- fillattrs são atributos do gráfico como as cores e fontes
 	- yaxis são configurações do eixo y
 		- values valores de série do eixo
 		- grid são as linhas de referência
 		- minor ativa os marcadores adicionais, sem rótulos, no eixo
 		- minorcount define a quantidade de marcadores adicionais, sem rótulos, no eixo
*/

title "Quantidade de clientes por estado";
proc sgplot
	data=corrigeDataNasc;
	vbar estado / fillattrs=(color=green);
		yaxis 
			label="Quantidade de clientes"
			values=(0 to 35 by 5)
			grid
			minor
			minorcount=4
		;
run;
