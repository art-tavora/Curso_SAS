/*
Cria um Alias para o diretório físico da tabela de dados
 - Máximo de 8 caracteres
 - Diretório deve estar entre aspas
*/

libname Curso "/home/u63796413/Curso Alura";

/*
Cria um procedimento comum no SAS
 - datasets serve para listar as caracteristicas das tabelas do diretório ou LIBNAME
*/
proc datasets
	lib=Curso;
run;

/*
 - Observações são linhas
 - Variáveis são colunas
 - Proc são passos de procedimentos
 - Data são passos de manipulação de dados 
*/

/*
Cria um procedimento comum no SAS
 - contents serve para listar as características das variáveis(colunas) de uma tabela
 - data serve para escolher a tabela que será avaliada
*/
proc contents
	data=curso.cadastro_produto;
run;

/*
Cria um procedimento comum no SAS
 - print serve para listar as observações(linhas) de uma tabela
 - data serve para escolher a tabela que será avaliada
*/
proc print
	data=curso.cadastro_produto;
run;

/*
Cria um procedimento comum no SAS
 - freq serve para agrupar as observações(linhas) iguais e contá-las (frequência em que aparecem na lista)
 - table cria uma tabela com o resultado da frequência, utilizando como chave de busca os campos que forem descritos como parâmetros
 - nlevels conta o número de categorias dentro de uma variável(coluna)
*/
proc freq
	data=curso.cadastro_produto nlevels;
	table genero plataforma nome;
run;

/*
Cria uma nova base de dados chamada resultado para manipular a saída do procedimento freq anterior
 - data serve para criar uma nova base ou tabela que vai receber as modificações manipuladas
 - set indica qual será a base que vai dar origem ou que será manipulada pelos comandos a seguir
 - if é o comando condicional que resulta na criação de uma nova variável(coluna) na nova base
*/

data resultado;
	set curso.cadastro_produto;
	if data > 201606 
		then lancamento = 1;
		else lancamento = 0;
run;

/*
Imprime a nova base criada após as condições aplicadas
 - noobs omite a coluna de observação na base gerada
*/
proc print
	data=resultado noobs;
run;

/*
Agrupa os resultados da nova  tabela resultado indicando a frequencia(agrupando) de lançamentos 
*/
proc freq
	data=resultado;
	table lancamento;
run;

/*
Cruza os dados para saber quantos jogos de lançamentos estão presentes em cada classe do gênero
 - * é usado para relacionar as variáveis da base, neste caso informa quantos lançamentos e não lançamentos em cada tipo(classe) de gênero
 - /norow nocol nopercent nocum suprime do resultado os dados de quantidade por linha, por coluna e a porcentagem de cada tipo de gênero.
*/

proc freq
	data=resultado;
	table genero*lancamento /norow nocol nopercent; 
run;


/*
Cruza os dados para saber se o nome de um jogo está presentes em mais de uma cada classe do gênero
 - list altera a exibição de matriz para lista e pode facilitar a visualização
*/
proc freq
	data=curso.cadastro_produto nlevels;
	table nome*genero /norow nocol nopercent nocum list;
run;

/*
Salva o resultado das tabelas criadas e manipuladas em um arquivo físico na pasta do projeto, criando uma base chamada resultados na pasta curso
 - rename troca o nome das variáveis(colunas)
 - label inclui uma etiqueta para a coluna com alguma explicação ou nome mais amigável
*/
data curso.resultados;
	set resultado;
	rename lancamento = flag_lancamento;
	label lancamento = "0 para jogos antigos e 1 para jogos lançamentos";
	label Genero = "Gênero";
run;

/*
Cria uma nova base verificaData a partir da base de resultados e busca as observações(linhas) em que a data está vazia, nula ou faltante
 - where é o comando condicional que executa uma comparação. Lê-se: Onde a Data é nula.
*/

data verificaData;
	set curso.resultados;
	where data is null;
run;

/*
Cria uma nova base localizaData a partir da base de resultados e busca as observações(linhas) em que constam os jogos que não tem data de lançamento cadastrada. Foram apurados na tabela verificaData
*/
data localizaData;
	set curso.resultados;
	where nome in ("Soccer", "Forgotten Echo", "Fireshock");
run;

/*
Cruza os dados de nome e data da tabela localizaData para que seja possível descobrir a data de lançamento de outro título com o mesmo nome
 - missing inclui como uma categoria no resultado as observações que não possuem valor na variável data
*/

proc freq
	data = localizaData;
	table nome*data /norow nocol nopercent nocum list missing;
run;

/*
Faz a mesma função do que acima, porém sem criar tabelas intermediárias
*/

proc freq 
	data=localizaData
		(where=(nome in ("Soccer", "Forgotten Echo", "Fireshock")));
	table nome*data /norow nocol nopercent nocum list missing;
run;

/*
Cria a base corrigeData para realizar a correção das datas para as observações que estão sem o campo preenchido
 - then do é complemento ao if que vai checar todas as condições listadas antes de sair da execução do if
*/

data corrigeData;
	set curso.resultados;
		if data = . then do;
			if nome = ("Fireshock") then data = 201706; else
			if nome = ("Forgotten Echo") then data = 201411; else
			if nome = ("Soccer") then data = 201709;
		end;
run;


/*
Cria a base corrigeData para realizar a correção das datas das observações que estão sem o campo preenchido porém utiliza o Select
 - select executado dentro do if seleciona qualquer variável(coluna) que estiver a disposição após o atendimento da primeira condição.
 - otherwise significa caso contrário e pode ser encerrado sem nenhuma ação.
*/


data corrigeData;
	set curso.resultados;
		if data = . then do;
			select(nome);
				when ("Fireshock")  	data = 201706; 
				when ("Forgotten Echo") data = 201411; 
				when ("Soccer") 		data = 201709;
				otherwise;
			end;
		end;
run;


/*
Verifica a base corrigeData em busca de erros de associação da flag de lançamento utilizando a relaçao entre as variáveis(colunas) nome, data e flag_lancamento
*/

proc freq 
	data=corrigeData
		(where=(nome in ("Soccer", "Forgotten Echo", "Fireshock")));
	table nome*data*flag_lancamento /norow nocol nopercent nocum list missing;
run;

/*
Realiza a correção das observações(linhas) encontradas na freq anterior utilizando o select e criando a nova base corrigeLancamento
 - Primeiro: Testa se o registro é de data compatível com lançamentos
 - Segundo: Seleciona a variável flag_lançamento e atribui a ela o valor compatível com lançamento "1"
 - Terceiro: Testa se o registro não é de data compatível com lançamentos
 - Quarto: Seleciona a variável flag_lançamento e atribui a ela o valor compatível "0"
*/

data corrigeLancamento;
	set corrigeData;
		if data >= 201606 then do;
			select(flag_lancamento);
				when ("0") flag_lancamento = 1;
				otherwise;
			end;
		end;
		
		if data =< 201606 then do;
			select(flag_lancamento);
				when ("1") flag_lancamento = 0;
				otherwise;
			end;
		end;
run;

/*
Verifica se os erros foram corrigidos na base corrigeLancamento utilizando a relaçao entre as variáveis(colunas) nome, data e flag_lancamento
*/

proc freq 
	data=corrigeLancamento
		(where=(nome in ("Soccer", "Forgotten Echo", "Fireshock")));
	table nome*data*flag_lancamento /norow nocol nopercent nocum list missing;
run;

/*
Salva o resultado da tabela corrigeLancamento em um arquivo físico na pasta do projeto, criando uma base chamada cadastro_produto_corrigida na pasta curso
*/

data curso.cadastro_produto_corrigida;
	set corrigeLancamento;
run;

/*
Verifica os dados da base cadastro_cliente;
*/
proc contents
	data=curso.cadastro_cliente;
run;

/*
Cria a base verificaCep para realizar a inclusão do estado no cadstro de cada cliente.
 - keep indica que só deve ser mantida as variáveis declaradas em seguida. Também pode ser incluído como parâmetro  na chamada do set (keep xxx)
 - drop pode ser utilizada para se retirar a variável especificada. Também pode ser incluído como parâmetro  na chamada do set (drop xxx)
 - format indica qual é o formato que a nova variável(estado) deve assumir.
 - length indica qual é o tamanho que a nova variável(estado) deve ter.
Características de formatos:
 - Ao declarar uma variável(coluna), nova, do tipo CHAR e realizar a atribuição direta, o SAS entende que o formato dela vai ser exatamente igual a atrbuição da primeira observação incluída na coluna.
 - Ao declarar uma variável(coluna), nova, do tipo NUM e realizar a atribuição direta, o SAS entende que o formato dela vai ser exatamente 3.
 - O menor valor possível para uma variável tipo NUM é 3 caracteres.
*/

data verificaCep;
	keep cep;
	format Estado $20.;
	label Estado = "Estado";
	set curso.cadastro_cliente;
		if "01000-000" <= cep <= "09999-999" then Estado = "SP"; else
		if "10000-000" <= cep <= "19999-999" then Estado = "SP-Interior"; else
		if "20000-000" <= cep <= "29999-999" then Estado = "RJ"; else
		if "30000-000" <= cep <= "39999-999" then Estado = "MG"; else
		if "80000-000" <= cep <= "89999-999" then Estado = "PR"; else
		Estado = "Outros";
run;		


proc freq
	data = verificaCep;
	table Estado /norow nocol nopercent nocum list missing;
run;
	
	
proc contents
	data=verificaCep;
run;
	
/*
Recria a base verificaCEP, incluindo uma nova variável chamada precep que vai armazenar os dois primeiros dígitos da variável cep e utilizando a função substr.
Para armazenar a variável como sendo do tipo NUM, a extração está sendo realizada dentro da função input.
 - substr (variável de origem, início do corte, tamanho do corte)
 - input (origem da análise, tipo do novo formato)
*/	
	
data verificaCep;
	set verificaCep;
	Precep = input(substr(cep,1,2),2.);
	label Precep = "Extração dos 2 primeiros dígitos do CEP";
run;
		
proc print
	data = verificaCep;
run;	

proc contents
	data=verificaCep;
run;

/*
Realiza a criação de uma variável chamada Estado a partir do desmembramento da variável CEP e aplicando-se um formato personalizado
 - value é o nome que será dado ao novo formato
 - cada faixa numérica ou range terá a label declarada. Pode-se comparar ao label de CHOICE.
 - other é o label que será aplicado quando o valor não estiver no range.
*/
proc format;
	VALUE estados_
		01 - 09 = "SP"
		10 - 19 = "SP - Interior"
		20 - 29 = "RJ"
		30 - 39 = "MG"
		80 - 89 = "PR"
		OTHER 	= "Outros";
run;	


/*
Realiza a criação de uma base chamada verificaCap2 com uma nova variável chamada Estado a partir do desmembramento da variável CEP e aplicando-se um formato personalizado
 - put converte uma observação(linha) de uma variável(coluna) do tipo NUM em CHAR.
 - put(variavel do tipo num, formato que será aplicado)
*/
data verificaCep2;
	set curso.cadastro_cliente;
    *explicação (cria var numerica precep),formato  );
	Estado = put(input(substr(cep,1,2),2.),estados_.);
run;

proc contents
	data=verificaCep2;
run;

proc print
	data = verificaCep2;
run;	

/*
Salva o resultado da tabela verificaCep2 em um arquivo físico na pasta do projeto, criando uma base chamada cadastro_cliente_corrigida na pasta curso
*/

data curso.cadastro_cliente_corrigido;
	set verificacep2;
run;

		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		

