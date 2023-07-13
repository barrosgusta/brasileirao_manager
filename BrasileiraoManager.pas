//Nome := 'Gustavo Barros da Silveira';
//Optei em fazer todo o c�digo em ingl�s por ser uma boa pr�tica,
//por�m coloquei v�rios coment�rios para auxiliar n� an�lise.
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
	
	SERIE_A_TEAMS : array[0..19] of string = ('Botafogo','Palmeiras','S�o Paulo','Atl�tico-MG','Gr�mio','Cruzeiro','Flamengo','Fluminense','Fortaleza','Bragantino',
	                 'Athletico-PR','Santos','Internacional','Corinthians','Cuiab�','Bahia','Goi�s','Vasco','Am�rica-MG','Coritiba');
	                
	SERIE_B_TEAMS : array[0..19] of string = ('Vit�ria','Novorizontino','Vila Nova','Crici�ma','Mirassol','Botafogo-SP','Atl�tico-GO','Guarani','Sport','Cear�',
	                 'Juventude','Ituano','Londrina','Ponte Preta','Chapecoense','Sampaio Corr�a','Ava�','Tombense','CRB','ABC');

type
	PTeamNode = ^TTeamNode;
	TTeamNode = record
		Next      : PTeamNode;              //Endere�o do pr�ximo registro
		Last      : PTeamNode;              //Endere�o do registro anterior
		Index     : integer;                //�ndice ou posi��o na tabela
		Name      : string;                 //Nome da sele��o
		ChangeLog : array[1..50] of string; //Array com o hist�rico de posi��es e suas observa��es
		Title     : array[1..50] of string; //Array com os t�tulos da sele��o
	end;
	
var
//"Cabe�a do n�" e "Cauda do n�" - Duplamente encadeado
	HeadNodeSerieA, TailNodeSerieA : PTeamNode; 
	HeadNodeSerieB, TailNodeSerieB : PTeamNode;

{PROCEDIMENTOS DE CRIA��O E MANIPULA��O DA LISTA ENCADEADA}

//Cria um "n�" e encadeia-o no final como uma estrutura de pilha/fila	
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

//Cria todos os "n�s" dos times da S�rie A
procedure FillSerieA;
var I : integer;
begin
  for I := 0 to 19 do
		CreateTeamNode(HeadNodeSerieA, TailNodeSerieA, SERIE_A_TEAMS[I]);
end;

//Cria todos os "n�s" dos times da S�rie B
procedure FillSerieB;
var I : integer;
begin
  for I := 0 to 19 do
		CreateTeamNode(HeadNodeSerieB, TailNodeSerieB, SERIE_B_TEAMS[I]);
end;

//Fun��o que filtra as letras da string e deixa s� os n�meros
{O objetivo dessa fun��o � implementar-lo nas escolhas das op��es, afim de n�o "estourar" exception quando uma letra(string) � informada nos campos de n�mero(integer)"}
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

//Retorna o ponteiro da sele��o pelo �ndice/posi��o e a "cabe�a do n�"
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

//Conserta os furos do array, A.K.A ReIndexa��o
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

//Verifica se a opera��o est� entre as op��es v�lidas (Tr�s op��es sem op��o de cancelar)
function IsThreeOptionOperationValid(iOperation: integer): Boolean;
begin
	IsThreeOptionOperationValid := False;
	if iOperation in [1,2,3] then
		IsThreeOptionOperationValid := True;
end;

//Verifica se a opera��o est� entre as op��es v�lidas (Duas op��es e uma op��o de cancelar)
function IsTwoOptionOperationValid(iOperation : integer): Boolean;
begin
	IsTwoOptionOperationValid := False;
	if iOperation in [1,2,10{10 - Cancelar}] then
		IsTwoOptionOperationValid := True;
end;

//Verifica se o �ndice do time escolhido est� entre os v�lidos
function IsTeamIndexValid(iTeamIndex : integer): Boolean;
begin
	IsTeamIndexValid := False;
	if (iTeamIndex <= 20) and (iTeamIndex >= 1) then
		IsTeamIndexValid := True;
end;

//Verifica se o �ndice do t�tulo escolhido est� entre os v�lidos
function IsTitleIndexValid(iTitleIndex, MaxIndex : integer): Boolean;
begin
	IsTitleIndexValid := False;
	if (iTitleIndex <= MaxIndex) and (iTitleIndex >= 1) then
		IsTitleIndexValid := True;
end;

{GETTERS}

//Retorna o maior �ndice dentre os t�tulos que possuem uma descri��o preenchida
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

//Retorna o maior �ndice dentre as altera��es preenchidas
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

//Retorna a data e o hor�rio
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

//Retorna o n�mero referente � opera��o
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

//Retorna o n�mero referente � s�rie
function GetSerie: integer;
var iSerie : integer;
    sSerie : string;
begin
	while not IsTwoOptionOperationValid(iSerie) do
	begin
		writeln('1 - S�rie A, 2 - S�rie B:');
	  read(sSerie);
		iSerie := GetNumbersFromString(sSerie);
	end;
	
	GetSerie := iSerie;
end;

//Retorna o �ndice do time
function GetTeamIndex: integer;
var iTeamIndex : integer;
    sTeamIndex : string;
begin
	while not IsTeamIndexValid(iTeamIndex) do
	begin
		writeln('Escolha o �ndice do time:');
	  read(sTeamIndex);
	  iTeamIndex := GetNumbersFromString(sTeamIndex);
	end;
	
	GetTeamIndex := iTeamIndex;
end;

//Retorna o n�mero referente a op��o da opera��o atual
function GetOperationOption(iOperation : integer): integer;
var iOperationOption : integer;
    sOperationOption : string;
begin
	if iOperation <> PROMOTION_RELEGATION_OP_OPTION then
		while not IsTwoOptionOperationValid(iOperationOption) do
		begin
			writeln('1 - T�tulo, 2 - Acesso/Promo��o ou Rebaixamento, 3 - Time, 10 - Cancelar Opera��o:');
		  read(sOperationOption);
		  
		  iOperationOption := GetNumbersFromString(sOperationOption);
		  
			if iOperationOption = TEAM_OP_OPTION then
				writeln('Para cadastrar ou remover um time, primeiro um time deve ser desclassificado da S�rie B cadastrando seus rebaixamentos para outro subst�tu�lo.');
		end
	else
	begin
	  while (iOperationOption <> TITLE_OP_OPTION) and (iOperationOption <> CANCEL_OP_OPTION) do
		begin
			writeln('1 - T�tulo, 3 - Time, 10 - Cancelar Opera��o:');
		  read(sOperationOption);
		  
		  iOperationOption := GetNumbersFromString(sOperationOption);
		  
			if iOperationOption = TEAM_OP_OPTION then
				writeln('Para cadastrar ou remover um time, primeiro um time deve ser desclassificado da S�rie B cadastrando seus rebaixamentos para outro subst�tu�lo.');
		end;
	end;

	GetOperationOption := iOperationOption;
end;

//Retorna o n�mero referente a escolha da opera��o de promover ou rebaixar um time
function GetPromotiorOrRelegation: integer;
var iPromotiorOrRelegationOption : integer;
    sPromotionOrRelegationOption : string;
begin
	while not IsTwoOptionOperationValid(iPromotiorOrRelegationOption) do
	begin
		writeln('1 - Acesso/Promo��o, 2 - Rebaixamento:');
	  read(sPromotionOrRelegationOption);
	  
		iPromotiorOrRelegationOption := GetNumbersFromString(sPromotionOrRelegationOption);
	end;
	
	GetPromotiorOrRelegation := iPromotiorOrRelegationOption;
end;

{LISTAGEM DAS INFORMA��ES}

//Mostra os times na tela
procedure PrintTeams(_HeadNodeSerieA, _HeadNodeSerieB : PTeamNode);
var
	CurrentNode : PTeamNode;
	Y : integer;
begin
  Y:= 1;
	inc(Y);
	gotoxy(1,Y);
  write('|-|=============||S�rie-A||=============|-|');
  
	CurrentNode := _HeadNodeSerieA;
	
	while CurrentNode <> nil do
	begin
		inc(Y);
		gotoxy(1, Y);
		writeln('|-| Ind�ce :', CurrentNode^.Index, '; Time:', CurrentNode^.Name);
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
  write('|-|=============||S�rie-B||=============|-|');
  
	CurrentNode := _HeadNodeSerieB;
	
	while CurrentNode <> nil do
	begin
		inc(Y);
		gotoxy(43, Y);
		writeln('|-| Ind�ce :', CurrentNode^.Index, '; Time:', CurrentNode^.Name);
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

//Lista todos os t�tulos cadastrados
procedure PrintTitles(iTeamIndex : integer; HeadNode : PTeamNode);
var CurrentNode : PTeamNode;
    I, MaxIndex : integer;
begin
	CurrentNode := GetTeamStructAddressByIndex(iTeamIndex, HeadNode);
	MaxIndex    := GetMaxTitleIndex(iTeamIndex, HeadNode);

	if MaxIndex >= 1 then
	begin
		writeln('T�tulos:');
		
		for I := 1 to 50 do
		begin
			if CurrentNode^.Title[I] <> '' then
				writeln('�ndice: ', I, '; Descri��o: ', CurrentNode^.Title[I]);
		end;
	end
	else
		writeln('N�o existem t�tulos cadastrados para o time "', CurrentNode^.Name, '"!');
end;

//Lista todas as altera��es
procedure PrintChangeLog(iTeamIndex : integer; HeadNode : PTeamNode);
var CurrentNode : PTeamNode;
    I, MaxIndex : integer;
begin
	CurrentNode := GetTeamStructAddressByIndex(iTeamIndex, HeadNode);
	MaxIndex    := GetMaxChangeLogIndex(iTeamIndex, HeadNode);

	if MaxIndex >= 1 then
	begin
		writeln('Hist�rico de altera��es na divis�o:');
		
		for I := 1 to 50 do
		begin
			if CurrentNode^.ChangeLog[I] <> '' then
				writeln(CurrentNode^.ChangeLog[I]);
		end;
	end
	else
		writeln('N�o existem altera��es na divis�o cadastrados para o time "', CurrentNode^.Name, '"!');
end;

{CADASTROS E INSER��ES}

//Insere um t�tulo no array da estrutura do time
procedure InsertTitle(iTeamIndex : integer; HeadNode : PTeamNode);
var CurrentNode : PTeamNode;
    I : integer;
    S, sTitle : string;
begin
	CurrentNode := GetTeamStructAddressByIndex(iTeamIndex, HeadNode);

	writeln('Escreva uma descri��o do t�tulo para o time "', CurrentNode^.Name, '":');
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

//Insere a observa��o no historico de altera��es de divis�o
procedure InsertChangeLog(IsPromotion : Boolean; iTeamIndex, iNewIndex, iCurrentDivision, iNewDivision : integer; HeadNode : PTeamNode);
var CurrentNode : PTeamNode;
    I : integer;
    S, sChangeLog, sCurrentDivision, sNewDivision, sCurrentIndex, sNewIndex : string;
begin
	CurrentNode := GetTeamStructAddressByIndex(iTeamIndex, HeadNode);

	if iCurrentDivision = SERIE_A then
		sCurrentDivision := 'S�rie A'
	else
		sCurrentDivision := 'S�rie B';

	if iNewDivision = SERIE_A then
		sNewDivision := 'S�rie A'
	else
		sNewDivision := 'S�rie B';

	str(iTeamIndex, sCurrentIndex);
	str(iNewIndex, sNewIndex);

	if IsPromotion then
	begin
		writeln('Escreva uma observa��o para o acesso/promo��o da sele��o "', CurrentNode^.Name, '":');
		read(sChangeLog);
		
		S := 'Acesso/Promo��o | Data: ' + '"' + GetDataHora + '" | Altera��o: "' + sCurrentDivision + '/' + sCurrentIndex + '� -> ' + sNewDivision + '/' + sNewIndex + '�" | Observa��o: ' + sChangeLog;
	end
	else
	begin
		writeln('Escreva uma observa��o para o rebaixamento da sele��o "', CurrentNode^.Name, '":');
		read(sChangeLog);
		
    S := 'Rebaixamento | Data: ' + '"' + GetDataHora + '" | Altera��o: "' + sCurrentDivision + '/' + sCurrentIndex + '� -> ' + sNewDivision + '/' + sNewIndex + '�" | Observa��o: ' + sChangeLog;
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
  //Cria um "N�" auxiliar
	new(AuxiliaryNode);

	case iSerie of
		SERIE_A :
		begin
			//Pega o endere�o do time da S�rie A que vai ser promovido
			CurrentNodeSerieA := GetTeamStructAddressByIndex(iTeamIndex, _HeadNodeSerieA);

			//N�o promove pois j� est� em primeiro da divis�o mais alta
			if iTeamIndex = 1 then
			begin
				writeln('O time "', CurrentNodeSerieA^.Name, '" est� um primeiro!');
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
		  //Pega o endere�o do time da S�rie B que vai ser promovido
			CurrentNodeSerieB := GetTeamStructAddressByIndex(iTeamIndex, _HeadNodeSerieB);

			//Promo��o para S�rie A
			if iTeamIndex = 1 then
			begin
				InsertChangeLog(True, iTeamIndex, 20, SERIE_B, SERIE_A, _HeadNodeSerieB);
				InsertChangeLog(False, 20, iTeamIndex, SERIE_A, SERIE_B, _HeadNodeSerieA);
				
				//Pega o endere�o do �ltimo time da S�rie A que ser� rebaixado
				CurrentNodeSerieA := GetTeamStructAddressByIndex(20, _HeadNodeSerieA);

				//Passa os dados do �ltimo da S�rie A para uma estrutura auxiliar
				AuxiliaryNode^.Name          := CurrentNodeSerieA^.Name;
				AuxiliaryNode^.ChangeLog     := CurrentNodeSerieA^.ChangeLog;
				AuxiliaryNode^.Title         := CurrentNodeSerieA^.Title;

				//Passa os dados do time da S�rie B para S�rie A
				CurrentNodeSerieA^.Name      := CurrentNodeSerieB^.Name;
				CurrentNodeSerieA^.ChangeLog := CurrentNodeSerieB^.ChangeLog;
				CurrentNodeSerieA^.Title     := CurrentNodeSerieB^.Title;

				//Passa os dados da estrutura auxiliar (Time Rebaixado) para S�rie B
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

  //Limpa o "N�" auxiliar da mem�ria
  dispose(AuxiliaryNode);
end;

//Rebaixa o time
procedure GiveRelegation(iSerie, iTeamIndex : integer; _HeadNodeSerieA, _HeadNodeSerieB : PTeamNode);
var sNewTeam : string;
		CurrentNodeSerieA, CurrentNodeSerieB, AuxiliaryNode : PTeamNode;
begin
  //Cria um "N�" auxiliar
	new(AuxiliaryNode);

	case iSerie of
		SERIE_A :
		begin
			//Pega o endere�o do time da S�rie A que vai ser rebaixado
			CurrentNodeSerieA := GetTeamStructAddressByIndex(iTeamIndex, _HeadNodeSerieA);

		  //Rebaixa para S�rie B
			if iTeamIndex = 20 then
			begin
				InsertChangeLog(False, iTeamIndex, 1, SERIE_A, SERIE_B, _HeadNodeSerieA);
				InsertChangeLog(True, 1, iTeamIndex, SERIE_B, SERIE_A, _HeadNodeSerieB);
				
				//Pega o endere�o do primeiro time da S�rie B que ser� promovido
				CurrentNodeSerieB := GetTeamStructAddressByIndex(1, _HeadNodeSerieB);

				//Passa os dados do �ltimo da S�rie A para uma estrutura auxiliar
				AuxiliaryNode^.Name          := CurrentNodeSerieA^.Name;
				AuxiliaryNode^.ChangeLog     := CurrentNodeSerieA^.ChangeLog;
				AuxiliaryNode^.Title         := CurrentNodeSerieA^.Title;

				//Passa os dados do time da S�rie B para S�rie A
				CurrentNodeSerieA^.Name      := CurrentNodeSerieB^.Name;
				CurrentNodeSerieA^.ChangeLog := CurrentNodeSerieB^.ChangeLog;
				CurrentNodeSerieA^.Title     := CurrentNodeSerieB^.Title;

				//Passa os dados da estrutura auxiliar (Time Rebaixado) para S�rie B
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

			//Desclassifica o �ltimo time da S�rie B e cadastra um novo no lugar
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

  //Limpa o "N�" auxiliar da mem�ria
  dispose(AuxiliaryNode);
end;

{REMO��ES}

//Remove um t�tulo do time
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
			writeln('Qual t�tulo deseja remover? Escolha pelo �ndice!');
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

{PROCESSAMENTO PRINCIPAL E ROTAS DAS FUN��ES}

//Executa o procedimento de acordo com os par�metros
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