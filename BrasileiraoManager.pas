//Nome := 'Gustavo Barros da Silveira';
//Optei em fazer todo o código em inglês por ser uma boa prática,
//porém coloquei vários comentários para auxiliar ná análise.
Program TeamsManager;

const
	SERIE_A = 1;
	SERIE_B = 2;
	
	INSERT_OP = 1;
	REMOVE_OP = 2;
	PRINT_OP  = 3;

	TITLE_OP_OPTION = 1;
	PROMOTION_RELEGATION_OP_OPTION = 2;
	TEAM_OP_OPTION = 3;
	CANCEL_OP_OPTION = 10;
	
	PROMOTION_OP_OPTION = 1;
	RELEGATION_OP_OPTION = 2;
	
	SERIE_A_TEAMS : array[0..19] of string = ('Botafogo','Palmeiras','São Paulo','Atlético-MG','Grêmio','Cruzeiro','Flamengo','Fluminense','Fortaleza','Bragantino',
	                 'Athletico-PR','Santos','Internacional','Corinthians','Cuiabá','Bahia','Goiás','Vasco','América-MG','Coritiba');
	                
	SERIE_B_TEAMS : array[0..19] of string = ('Vitória','Novorizontino','Vila Nova','Criciúma','Mirassol','Botafogo-SP','Atlético-GO','Guarani','Sport','Ceará',
	                 'Juventude','Ituano','Londrina','Ponte Preta','Chapecoense','Sampaio Corrêa','Avaí','Tombense','CRB','ABC');

type
	PTeamNode = ^TTeamNode;
	TTeamNode = record
		Next      : PTeamNode;              //Endereço do próximo registro
		Last      : PTeamNode;              //Endereço do registro anterior
		Index     : integer;                //Índice ou posição na tabela
		Name      : string;                 //Nome da seleção
		ChangeLog : array[1..50] of string; //Array com o histórico de posições e suas observações
		Title     : array[1..50] of string; //Array com os títulos da seleção
	end;
	
var
//"Cabeça do nó" e "Cauda do nó" - Duplamente encadeado
	HeadNodeSerieA, TailNodeSerieA : PTeamNode; 
	HeadNodeSerieB, TailNodeSerieB : PTeamNode;

{PROCEDIMENTOS DE CRIAÇÃO E MANIPULAÇÃO DA LISTA ENCADEADA}

//Cria um "nó" e encadeia-o no final como uma estrutura de pilha/fila	
procedure CreateTeamNode(var HeadNode, TailNode : PTeamNode; TeamName : string);
var
	CurrentNode, NewNode : PTeamNode;
begin
	new(NewNode);
	
	NewNode^.Index := 1;
	NewNode^.Name  := TeamName;
	NewNode^.Next  := nil;
	NewNode^.Last  := nil;

	if HeadNode = nil then
	begin
		HeadNode := NewNode;
		TailNode := NewNode;
	end
	else
	begin
		CurrentNode := HeadNode;
		
		while CurrentNode^.Next <> nil do
		begin
			CurrentNode := CurrentNode^.Next;
		end;
		
		NewNode^.Last     := CurrentNode;
		NewNode^.Index    := CurrentNode^.Index + 1;
		CurrentNode^.Next := NewNode;
		TailNode          := NewNode;
	end
end;

//Cria todos os "nós" dos times da Série A
procedure FillSerieA;
var I : integer;
begin
  for I := 0 to 19 do
		CreateTeamNode(HeadNodeSerieA, TailNodeSerieA, SERIE_A_TEAMS[I]);
end;

//Cria todos os "nós" dos times da Série B
procedure FillSerieB;
var I : integer;
begin
  for I := 0 to 19 do
		CreateTeamNode(HeadNodeSerieB, TailNodeSerieB, SERIE_B_TEAMS[I]);
end;

//Função que filtra as letras da string e deixa só os números
{O objetivo dessa função é implementar-lo nas escolhas das opções, afim de não "estourar" exception quando uma letra(string) é informada nos campos de número(integer)"}
function GetNumbersFromString(S : string): integer;
var I, Result : integer;
    sAux : string;
begin
	for I := 1 to Length(S) do
	begin
		if S[I] in ['0'..'9'] then
			sAux := sAux + S[I];
	end;

	val(sAux, Result, I);
	GetNumbersFromString := Result;
end;

//Retorna o ponteiro da seleção pelo índice/posição e a "cabeça do nó"
function GetTeamStructAddressByIndex(Index : integer; HeadNode : PTeamNode): PTeamNode;
var CurrentNode : PTeamNode;
begin
	CurrentNode := HeadNode;
	
	while CurrentNode <> nil do
	begin
		if CurrentNode^.Index = Index then
			break;

		CurrentNode := CurrentNode^.Next;
	end;

	GetTeamStructAddressByIndex := CurrentNode;
end;

//Limpa os arrays da estrutura para a entrada de um novo time
procedure CleanStringArrays(iTeamIndex : integer; HeadNode : PTeamNode);
var CurrentNode : PTeamNode;
		I : integer;
begin
	CurrentNode := GetTeamStructAddressByIndex(iTeamIndex, HeadNode);

	for I := 1 to 50 do
	begin
	  CurrentNode^.ChangeLog[I] := '';
	  CurrentNode^.Title[I]     := '';
	end;
end;

//Conserta os furos do array, A.K.A ReIndexação
procedure ReIndexTitles(iTeamIndex : integer; HeadNode : PTeamNode);
var CurrentNode : PTeamNode;
	  I, J : integer;
begin
	CurrentNode := GetTeamStructAddressByIndex(iTeamIndex, HeadNode);

	for I := 1 to 50 do
	begin
		if CurrentNode^.Title[I] = '' then
			for J := I to 49 do
			begin
				CurrentNode^.Title[J]   := CurrentNode^.Title[J+1];
				CurrentNode^.Title[J+1] := '';
			end;
	end;
end;

{VALIDADORES DOS CAMPOS}

//Verifica se a operação está entre as opções válidas (Três opções sem opção de cancelar)
function IsThreeOptionOperationValid(iOperation: integer): Boolean;
begin
	IsThreeOptionOperationValid := False;
	if iOperation in [1,2,3] then
		IsThreeOptionOperationValid := True;
end;

//Verifica se a operação está entre as opções válidas (Duas opções e uma opção de cancelar)
function IsTwoOptionOperationValid(iOperation : integer): Boolean;
begin
	IsTwoOptionOperationValid := False;
	if iOperation in [1,2,10{10 - Cancelar}] then
		IsTwoOptionOperationValid := True;
end;

//Verifica se o índice do time escolhido está entre os válidos
function IsTeamIndexValid(iTeamIndex : integer): Boolean;
begin
	IsTeamIndexValid := False;
	if (iTeamIndex <= 20) and (iTeamIndex >= 1) then
		IsTeamIndexValid := True;
end;

//Verifica se o índice do título escolhido está entre os válidos
function IsTitleIndexValid(iTitleIndex, MaxIndex : integer): Boolean;
begin
	IsTitleIndexValid := False;
	if (iTitleIndex <= MaxIndex) and (iTitleIndex >= 1) then
		IsTitleIndexValid := True;
end;

{GETTERS}

//Retorna o maior índice dentre os títulos que possuem uma descrição preenchida
function GetMaxTitleIndex(iTeamIndex : integer; HeadNode : PTeamNode): integer;
var CurrentNode : PTeamNode;
    I : integer;
begin
	CurrentNode := GetTeamStructAddressByIndex(iTeamIndex, HeadNode);

	for I := 1 to 50 do
	begin
		if CurrentNode^.Title[I] = '' then
			break;
	end;

	GetMaxTitleIndex := I - 1;
end;

//Retorna o maior índice dentre as alterações preenchidas
function GetMaxChangeLogIndex(iTeamIndex : integer; HeadNode : PTeamNode): integer;
var CurrentNode : PTeamNode;
    I : integer;
begin
	CurrentNode := GetTeamStructAddressByIndex(iTeamIndex, HeadNode);

	for I := 1 to 50 do
	begin
		if CurrentNode^.ChangeLog[I] = '' then
			break;
	end;

	GetMaxChangeLogIndex := I - 1;
end;

//Retorna a data e o horário
function GetDataHora: string;
var iAno, iMes, iDia, iDiaSemana,
    iHora, iMinuto, iSegundo, iMsegundo : integer;
    sAno, sMes, sDia, sDiaSemana,
    sHora, sMinuto, sSegundo, sMSegundo : string;
begin
	getDate(iAno, iMes, iDia, iDiaSemana);
	getTime(iHora, iMinuto, iSegundo, iMSegundo);
	
	str(iAno, sAno);
	str(iMes, sMes);
	str(iDia, sDia);
	str(iDiaSemana, sDiaSemana);
	str(iHora, sHora);
	str(iMinuto, sMinuto);

	GetDataHora := sDia + '/' + sMes + '/' + sAno + ' - ' + sHora + ':' + sMinuto;
end;

//Retorna o número referente à operação
function GetOperation: integer;
var iOperation : integer;
    sOperation : string;
begin
	while not IsThreeOptionOperationValid(iOperation) do
	begin
		writeln('1 - Cadastrar, 2 - Remover, 3 - Listar:');
	  readln(sOperation);
	  iOperation := GetNumbersFromString(sOperation);
	end;
	
	GetOperation := iOperation;
end;

//Retorna o número referente à série
function GetSerie: integer;
var iSerie : integer;
    sSerie : string;
begin
	while not IsTwoOptionOperationValid(iSerie) do
	begin
		writeln('1 - Série A, 2 - Série B:');
	  read(sSerie);
		iSerie := GetNumbersFromString(sSerie);
	end;
	
	GetSerie := iSerie;
end;

//Retorna o índice do time
function GetTeamIndex: integer;
var iTeamIndex : integer;
    sTeamIndex : string;
begin
	while not IsTeamIndexValid(iTeamIndex) do
	begin
		writeln('Escolha o índice do time:');
	  read(sTeamIndex);
	  iTeamIndex := GetNumbersFromString(sTeamIndex);
	end;
	
	GetTeamIndex := iTeamIndex;
end;

//Retorna o número referente a opção da operação atual
function GetOperationOption(iOperation : integer): integer;
var iOperationOption : integer;
    sOperationOption : string;
begin
	if iOperation <> PROMOTION_RELEGATION_OP_OPTION then
		while not IsTwoOptionOperationValid(iOperationOption) do
		begin
			writeln('1 - Título, 2 - Acesso/Promoção ou Rebaixamento, 3 - Time, 10 - Cancelar Operação:');
		  read(sOperationOption);
		  
		  iOperationOption := GetNumbersFromString(sOperationOption);
		  
			if iOperationOption = TEAM_OP_OPTION then
				writeln('Para cadastrar ou remover um time, primeiro um time deve ser desclassificado da Série B cadastrando seus rebaixamentos para outro substítuílo.');
		end
	else
	begin
	  while (iOperationOption <> TITLE_OP_OPTION) and (iOperationOption <> CANCEL_OP_OPTION) do
		begin
			writeln('1 - Título, 3 - Time, 10 - Cancelar Operação:');
		  read(sOperationOption);
		  
		  iOperationOption := GetNumbersFromString(sOperationOption);
		  
			if iOperationOption = TEAM_OP_OPTION then
				writeln('Para cadastrar ou remover um time, primeiro um time deve ser desclassificado da Série B cadastrando seus rebaixamentos para outro substítuílo.');
		end;
	end;

	GetOperationOption := iOperationOption;
end;

//Retorna o número referente a escolha da operação de promover ou rebaixar um time
function GetPromotiorOrRelegation: integer;
var iPromotiorOrRelegationOption : integer;
    sPromotionOrRelegationOption : string;
begin
	while not IsTwoOptionOperationValid(iPromotiorOrRelegationOption) do
	begin
		writeln('1 - Acesso/Promoção, 2 - Rebaixamento:');
	  read(sPromotionOrRelegationOption);
	  
		iPromotiorOrRelegationOption := GetNumbersFromString(sPromotionOrRelegationOption);
	end;
	
	GetPromotiorOrRelegation := iPromotiorOrRelegationOption;
end;

{LISTAGEM DAS INFORMAÇÕES}

//Mostra os times na tela
procedure PrintTeams(_HeadNodeSerieA, _HeadNodeSerieB : PTeamNode);
var
	CurrentNode : PTeamNode;
	Y : integer;
begin
  Y:= 1;
	inc(Y);
	gotoxy(1,Y);
  write('|-|=============||Série-A||=============|-|');
  
	CurrentNode := _HeadNodeSerieA;
	
	while CurrentNode <> nil do
	begin
		inc(Y);
		gotoxy(1, Y);
		writeln('|-| Indíce :', CurrentNode^.Index, '; Time:', CurrentNode^.Name);
		gotoxy(41, Y);
		write('|-|');
		CurrentNode := CurrentNode^.Next;
	end;
	
	inc(Y);
	gotoxy(1,Y);
	write('|=========================================|');

	Y:= 1;
	inc(Y);
	gotoxy(43,Y);
  write('|-|=============||Série-B||=============|-|');
  
	CurrentNode := _HeadNodeSerieB;
	
	while CurrentNode <> nil do
	begin
		inc(Y);
		gotoxy(43, Y);
		writeln('|-| Indíce :', CurrentNode^.Index, '; Time:', CurrentNode^.Name);
		gotoxy(83, Y);
		write('|-|');
		CurrentNode := CurrentNode^.Next;
	end;
	
	inc(Y);
	gotoxy(43,Y);
	write('|=========================================|');
	inc(Y);
	gotoxy(1,Y+1);
end;

//Lista todos os títulos cadastrados
procedure PrintTitles(iTeamIndex : integer; HeadNode : PTeamNode);
var CurrentNode : PTeamNode;
    I, MaxIndex : integer;
begin
	CurrentNode := GetTeamStructAddressByIndex(iTeamIndex, HeadNode);
	MaxIndex    := GetMaxTitleIndex(iTeamIndex, HeadNode);

	if MaxIndex >= 1 then
	begin
		writeln('Títulos:');
		
		for I := 1 to 50 do
		begin
			if CurrentNode^.Title[I] <> '' then
				writeln('Índice: ', I, '; Descrição: ', CurrentNode^.Title[I]);
		end;
	end
	else
		writeln('Não existem títulos cadastrados para o time "', CurrentNode^.Name, '"!');
end;

//Lista todas as alterações
procedure PrintChangeLog(iTeamIndex : integer; HeadNode : PTeamNode);
var CurrentNode : PTeamNode;
    I, MaxIndex : integer;
begin
	CurrentNode := GetTeamStructAddressByIndex(iTeamIndex, HeadNode);
	MaxIndex    := GetMaxChangeLogIndex(iTeamIndex, HeadNode);

	if MaxIndex >= 1 then
	begin
		writeln('Histórico de alterações na divisão:');
		
		for I := 1 to 50 do
		begin
			if CurrentNode^.ChangeLog[I] <> '' then
				writeln(CurrentNode^.ChangeLog[I]);
		end;
	end
	else
		writeln('Não existem alterações na divisão cadastrados para o time "', CurrentNode^.Name, '"!');
end;

{CADASTROS E INSERÇÕES}

//Insere um título no array da estrutura do time
procedure InsertTitle(iTeamIndex : integer; HeadNode : PTeamNode);
var CurrentNode : PTeamNode;
    I : integer;
    S, sTitle : string;
begin
	CurrentNode := GetTeamStructAddressByIndex(iTeamIndex, HeadNode);

	writeln('Escreva uma descrição do título para o time "', CurrentNode^.Name, '":');
	read(sTitle);

	for I := 1 to 50 do
	begin
		if CurrentNode^.Title[I] = '' then
		begin
		  CurrentNode^.Title[I] := sTitle;
		  break;
		end;
	end;
end;

//Insere a observação no historico de alterações de divisão
procedure InsertChangeLog(IsPromotion : Boolean; iTeamIndex, iNewIndex, iCurrentDivision, iNewDivision : integer; HeadNode : PTeamNode);
var CurrentNode : PTeamNode;
    I : integer;
    S, sChangeLog, sCurrentDivision, sNewDivision, sCurrentIndex, sNewIndex : string;
begin
	CurrentNode := GetTeamStructAddressByIndex(iTeamIndex, HeadNode);

	if iCurrentDivision = SERIE_A then
		sCurrentDivision := 'Série A'
	else
		sCurrentDivision := 'Série B';

	if iNewDivision = SERIE_A then
		sNewDivision := 'Série A'
	else
		sNewDivision := 'Série B';

	str(iTeamIndex, sCurrentIndex);
	str(iNewIndex, sNewIndex);

	if IsPromotion then
	begin
		writeln('Escreva uma observação para o acesso/promoção da seleção "', CurrentNode^.Name, '":');
		read(sChangeLog);
		
		S := 'Acesso/Promoção | Data: ' + '"' + GetDataHora + '" | Alteração: "' + sCurrentDivision + '/' + sCurrentIndex + '° -> ' + sNewDivision + '/' + sNewIndex + '°" | Observação: ' + sChangeLog;
	end
	else
	begin
		writeln('Escreva uma observação para o rebaixamento da seleção "', CurrentNode^.Name, '":');
		read(sChangeLog);
		
    S := 'Rebaixamento | Data: ' + '"' + GetDataHora + '" | Alteração: "' + sCurrentDivision + '/' + sCurrentIndex + '° -> ' + sNewDivision + '/' + sNewIndex + '°" | Observação: ' + sChangeLog;
	end;

	for I := 1 to 50 do
	begin
		if CurrentNode^.ChangeLog[I] = '' then
		begin
		  CurrentNode^.ChangeLog[I] := S;
		  break;
		end;
	end;
end;

//Promove a time
procedure GivePromotion(iSerie, iTeamIndex : integer; _HeadNodeSerieA, _HeadNodeSerieB: PTeamNode);
var CurrentNodeSerieA, CurrentNodeSerieB, AuxiliaryNode : PTeamNode;
begin
  //Cria um "Nó" auxiliar
	new(AuxiliaryNode);

	case iSerie of
		SERIE_A :
		begin
			//Pega o endereço do time da Série A que vai ser promovido
			CurrentNodeSerieA := GetTeamStructAddressByIndex(iTeamIndex, _HeadNodeSerieA);

			//Não promove pois já está em primeiro da divisão mais alta
			if iTeamIndex = 1 then
			begin
				writeln('O time "', CurrentNodeSerieA^.Name, '" está um primeiro!');
			end
			else
			begin
				InsertChangeLog(True, iTeamIndex, iTeamIndex - 1, SERIE_A, SERIE_A, _HeadNodeSerieA);
				InsertChangeLog(False, iTeamIndex - 1, iTeamIndex, SERIE_A, SERIE_A, _HeadNodeSerieA);

				//Passa os dados do time acima para uma estrutura auxiliar
				AuxiliaryNode^.Name                := CurrentNodeSerieA^.Last^.Name;
				AuxiliaryNode^.ChangeLog           := CurrentNodeSerieA^.Last^.ChangeLog;
				AuxiliaryNode^.Title               := CurrentNodeSerieA^.Last^.Title;

				//Passa os dados do time abaixo para o de cima
				CurrentNodeSerieA^.Last^.Name      := CurrentNodeSerieA^.Name;
				CurrentNodeSerieA^.Last^.ChangeLog := CurrentNodeSerieA^.ChangeLog;
				CurrentNodeSerieA^.Last^.Title     := CurrentNodeSerieA^.Title;

				//Passa os dados do estrutura auxiliar (Time Rebaixado) para o atual
				CurrentNodeSerieA^.Name      := AuxiliaryNode^.Name;
				CurrentNodeSerieA^.ChangeLog := AuxiliaryNode^.ChangeLog;
				CurrentNodeSerieA^.Title     := AuxiliaryNode^.Title;
			end;
		end;
		
		SERIE_B :
		begin
		  //Pega o endereço do time da Série B que vai ser promovido
			CurrentNodeSerieB := GetTeamStructAddressByIndex(iTeamIndex, _HeadNodeSerieB);

			//Promoção para Série A
			if iTeamIndex = 1 then
			begin
				InsertChangeLog(True, iTeamIndex, 20, SERIE_B, SERIE_A, _HeadNodeSerieB);
				InsertChangeLog(False, 20, iTeamIndex, SERIE_A, SERIE_B, _HeadNodeSerieA);
				
				//Pega o endereço do último time da Série A que será rebaixado
				CurrentNodeSerieA := GetTeamStructAddressByIndex(20, _HeadNodeSerieA);

				//Passa os dados do último da Série A para uma estrutura auxiliar
				AuxiliaryNode^.Name          := CurrentNodeSerieA^.Name;
				AuxiliaryNode^.ChangeLog     := CurrentNodeSerieA^.ChangeLog;
				AuxiliaryNode^.Title         := CurrentNodeSerieA^.Title;

				//Passa os dados do time da Série B para Série A
				CurrentNodeSerieA^.Name      := CurrentNodeSerieB^.Name;
				CurrentNodeSerieA^.ChangeLog := CurrentNodeSerieB^.ChangeLog;
				CurrentNodeSerieA^.Title     := CurrentNodeSerieB^.Title;

				//Passa os dados da estrutura auxiliar (Time Rebaixado) para Série B
				CurrentNodeSerieB^.Name      := AuxiliaryNode^.Name;
				CurrentNodeSerieB^.ChangeLog := AuxiliaryNode^.ChangeLog;
				CurrentNodeSerieB^.Title     := AuxiliaryNode^.Title;
			end
			else
			begin
				InsertChangeLog(True, iTeamIndex, iTeamIndex - 1, SERIE_B, SERIE_B, _HeadNodeSerieB);
				InsertChangeLog(False, iTeamIndex - 1, iTeamIndex, SERIE_B, SERIE_B, _HeadNodeSerieA);

				//Passa os dados do time acima para uma estrutura auxiliar
				AuxiliaryNode^.Name                := CurrentNodeSerieB^.Last^.Name;
				AuxiliaryNode^.ChangeLog           := CurrentNodeSerieB^.Last^.ChangeLog;
				AuxiliaryNode^.Title               := CurrentNodeSerieB^.Last^.Title;

				//Passa os dados do time abaixo para o de cima
				CurrentNodeSerieB^.Last^.Name      := CurrentNodeSerieB^.Name;
				CurrentNodeSerieB^.Last^.ChangeLog := CurrentNodeSerieB^.ChangeLog;
				CurrentNodeSerieB^.Last^.Title     := CurrentNodeSerieB^.Title;

				//Passa os dados do estrutura auxiliar (Time Rebaixado) para o atual
				CurrentNodeSerieB^.Name            := AuxiliaryNode^.Name;
				CurrentNodeSerieB^.ChangeLog       := AuxiliaryNode^.ChangeLog;
				CurrentNodeSerieB^.Title           := AuxiliaryNode^.Title;
			end;
		end;
	end;

  //Limpa o "Nó" auxiliar da memória
  dispose(AuxiliaryNode);
end;

//Rebaixa o time
procedure GiveRelegation(iSerie, iTeamIndex : integer; _HeadNodeSerieA, _HeadNodeSerieB : PTeamNode);
var sNewTeam : string;
		CurrentNodeSerieA, CurrentNodeSerieB, AuxiliaryNode : PTeamNode;
begin
  //Cria um "Nó" auxiliar
	new(AuxiliaryNode);

	case iSerie of
		SERIE_A :
		begin
			//Pega o endereço do time da Série A que vai ser rebaixado
			CurrentNodeSerieA := GetTeamStructAddressByIndex(iTeamIndex, _HeadNodeSerieA);

		  //Rebaixa para Série B
			if iTeamIndex = 20 then
			begin
				InsertChangeLog(False, iTeamIndex, 1, SERIE_A, SERIE_B, _HeadNodeSerieA);
				InsertChangeLog(True, 1, iTeamIndex, SERIE_B, SERIE_A, _HeadNodeSerieB);
				
				//Pega o endereço do primeiro time da Série B que será promovido
				CurrentNodeSerieB := GetTeamStructAddressByIndex(1, _HeadNodeSerieB);

				//Passa os dados do último da Série A para uma estrutura auxiliar
				AuxiliaryNode^.Name          := CurrentNodeSerieA^.Name;
				AuxiliaryNode^.ChangeLog     := CurrentNodeSerieA^.ChangeLog;
				AuxiliaryNode^.Title         := CurrentNodeSerieA^.Title;

				//Passa os dados do time da Série B para Série A
				CurrentNodeSerieA^.Name      := CurrentNodeSerieB^.Name;
				CurrentNodeSerieA^.ChangeLog := CurrentNodeSerieB^.ChangeLog;
				CurrentNodeSerieA^.Title     := CurrentNodeSerieB^.Title;

				//Passa os dados da estrutura auxiliar (Time Rebaixado) para Série B
				CurrentNodeSerieB^.Name      := AuxiliaryNode^.Name;
				CurrentNodeSerieB^.ChangeLog := AuxiliaryNode^.ChangeLog;
				CurrentNodeSerieB^.Title     := AuxiliaryNode^.Title;
			end
			else
			begin
				InsertChangeLog(False, iTeamIndex, iTeamIndex + 1, SERIE_A, SERIE_A, _HeadNodeSerieA);
				InsertChangeLog(True, iTeamIndex + 1, iTeamIndex, SERIE_A, SERIE_A, _HeadNodeSerieA);

				//Passa os dados do time acima para uma estrutura auxiliar 
				AuxiliaryNode^.Name                := CurrentNodeSerieA^.Next^.Name;
				AuxiliaryNode^.ChangeLog           := CurrentNodeSerieA^.Next^.ChangeLog;
				AuxiliaryNode^.Title               := CurrentNodeSerieA^.Next^.Title;
				
				//Passa os dados do time abaixo para o de cima
				CurrentNodeSerieA^.Next^.Name      := CurrentNodeSerieA^.Name;
				CurrentNodeSerieA^.Next^.ChangeLog := CurrentNodeSerieA^.ChangeLog;
				CurrentNodeSerieA^.Next^.Title     := CurrentNodeSerieA^.Title;
				
				//Passa os dados do estrutura auxiliar (Time Rebaixado) para o atual
				CurrentNodeSerieA^.Name        	   := AuxiliaryNode^.Name;
				CurrentNodeSerieA^.ChangeLog       := AuxiliaryNode^.ChangeLog;
				CurrentNodeSerieA^.Title           := AuxiliaryNode^.Title;
			end; 	
		end;
		
		SERIE_B :
		begin
			CurrentNodeSerieB := GetTeamStructAddressByIndex(iTeamIndex, _HeadNodeSerieB);

			//Desclassifica o último time da Série B e cadastra um novo no lugar
			if iTeamIndex = 20 then
			begin
				writeln('Time "', CurrentNodeSerieB^.Name, '" desclassificado!');
				
				writeln('Digite o nome do novo time:');
				read(sNewTeam);
				
				CurrentNodeSerieB^.Name := sNewTeam;
				
				CleanStringArrays(iTeamIndex, _HeadNodeSerieB);
			end
			else
			begin
				InsertChangeLog(False, iTeamIndex, iTeamIndex + 1, SERIE_B, SERIE_B, _HeadNodeSerieB);
				InsertChangeLog(True, iTeamIndex + 1, iTeamIndex, SERIE_B, SERIE_B, _HeadNodeSerieB);
				
				//Passa os dados do time acima para uma estrutura auxiliar 
				AuxiliaryNode^.Name                := CurrentNodeSerieB^.Next^.Name;
				AuxiliaryNode^.ChangeLog           := CurrentNodeSerieB^.Next^.ChangeLog;
				AuxiliaryNode^.Title               := CurrentNodeSerieB^.Next^.Title;
				
				//Passa os dados do time abaixo para o de cima
				CurrentNodeSerieB^.Next^.Name      := CurrentNodeSerieB^.Name;
				CurrentNodeSerieB^.Next^.ChangeLog := CurrentNodeSerieB^.ChangeLog;
				CurrentNodeSerieB^.Next^.Title     := CurrentNodeSerieB^.Title;
				
				//Passan os dados do estrutura auxiliar (Time Rebaixado) para o atual
				CurrentNodeSerieB^.Name            := AuxiliaryNode^.Name;
				CurrentNodeSerieB^.ChangeLog       := AuxiliaryNode^.ChangeLog;
				CurrentNodeSerieB^.Title           := AuxiliaryNode^.Title;
			end;
		end;
	end;

  //Limpa o "Nó" auxiliar da memória
  dispose(AuxiliaryNode);
end;

{REMOÇÕES}

//Remove um título do time
procedure RemoveTitle(iTeamIndex : integer; HeadNode : PTeamNode);
var I, MaxIndex, iTitleIndex : integer;
    CurrentNode : PTeamNode;
begin
	PrintTitles(iTeamIndex, HeadNode);
	writeln('');
	
	MaxIndex := GetMaxTitleIndex(iTeamIndex, HeadNode);
	if MaxIndex >= 1 then
	begin
		while not IsTitleIndexValid(iTitleIndex, MaxIndex) do
		begin
			writeln('Qual título deseja remover? Escolha pelo índice!');
			read(iTitleIndex);
		end;

		CurrentNode := GetTeamStructAddressByIndex(iTeamIndex, HeadNode);

		for I := 1 to 50 do
		begin
			if I = iTitleIndex then
			begin
				CurrentNode^.Title[I] := '';
				ReIndexTitles(iTeamIndex, HeadNode);
			end;
		end;  		
	end;
end;

{PROCESSAMENTO PRINCIPAL E ROTAS DAS FUNÇÕES}

//Executa o procedimento de acordo com os parâmetros
procedure PerformOperations(iOperation, iSerie, iTeamIndex : integer; HeadNode : PTeamNode);
begin
	case iOperation of
    INSERT_OP:
    begin
      case GetOperationOption(iOperation) of
        TITLE_OP_OPTION : InsertTitle(iTeamIndex, HeadNode);
					
        PROMOTION_RELEGATION_OP_OPTION: 
        begin
          case GetPromotiorOrRelegation of
            PROMOTION_OP_OPTION  : GivePromotion(iSerie, iTeamIndex, HeadNodeSerieA, HeadNodeSerieB);
            RELEGATION_OP_OPTION : GiveRelegation(iSerie, iTeamIndex, HeadNodeSerieA, HeadNodeSerieB);
            CANCEL_OP_OPTION     : exit;          		
          end;
        end;
      end;
    end;
			
    REMOVE_OP:     
    begin
      case GetOperationOption(iOperation) of
        TITLE_OP_OPTION  : RemoveTitle(iTeamIndex, HeadNode);
        CANCEL_OP_OPTION : exit;
      end;
    end;
			
    PRINT_OP:
    begin
      case GetOperationOption(iOperation) of
        TITLE_OP_OPTION                : PrintTitles(iTeamIndex, HeadNode);
        PROMOTION_RELEGATION_OP_OPTION : PrintChangeLog(iTeamIndex, HeadNode);
      end;
    end;
	end;		
end;

//Processo principal
procedure MainProcessLoop;
begin
	while true do
	begin
		clrscr;
		PrintTeams(HeadNodeSerieA, HeadNodeSerieB);

		case GetSerie of
			SERIE_A : PerformOperations(GetOperation, SERIE_A, GetTeamIndex, HeadNodeSerieA);
			SERIE_B : PerformOperations(GetOperation, SERIE_B, GetTeamIndex, HeadNodeSerieB);
		end;

		readkey;
	end;
end;

begin
	FillSerieA;
  FillSerieB;
	MainProcessLoop;
end.