{
Trabalho final de MATA37 - Equipe 1: Jean, Luisa e Nanci
Projeto: Combate
}

program stratego;
uses CRT;

type
   no_pecas = ^pecas;
   pecas  = record {lista de pe�as}
               nome    : string[13];
               rank    : integer; {rank da pe�a - vai de 0 a 11}
               qtde    : integer;
               jogador : integer;
               prox    : no_pecas;
            end;       
   
var
   jog1, jog2, lago                                  : no_pecas;
   tabuleiro                                         : array [1..10, 1..10] of no_pecas;
   controle_pecas                                    : array [0..11] of integer;
   jogador, linha_atual, linha, coluna_atual, coluna : integer;
                                                     
{Cria��o da lista de pe�as}
procedure lista_pecas(var inicio : no_pecas; nome : string; rank, jogador : integer);
var aux1, aux2 : no_pecas;
begin
   new(aux1);
   aux1^.nome := nome;
   aux1^.rank := rank;
   aux1^.jogador := jogador;
   aux1^.qtde := 0; {quantidade posicionada de pe�as -> come�a com 0}
   if (inicio = nil) then
      inicio := aux1
   else
   begin
      aux2 := inicio;
      while (aux2^.prox <> nil) do
         aux2 := aux2^.prox;
      aux2^.prox := aux1;
   end;
end; { lista_pecas }

{O procedimento a seguir insere os dados das pe�as do jogo na lista}
procedure dados_pecas(inicio : no_pecas; jogador : integer);
begin
   lista_pecas(inicio, 'bomba', 0, jogador);
   lista_pecas(inicio, 'espiao', 1, jogador);
   lista_pecas(inicio, 'soldado', 2, jogador);
   lista_pecas(inicio, 'cabo-armeiro', 3, jogador);
   lista_pecas(inicio, 'sargento', 4, jogador);
   lista_pecas(inicio, 'tenente', 5, jogador);
   lista_pecas(inicio, 'capitao', 6, jogador);
   lista_pecas(inicio, 'major', 7, jogador);
   lista_pecas(inicio, 'coronel', 8, jogador);
   lista_pecas(inicio, 'general', 9, jogador);
   lista_pecas(inicio, 'marechal', 10, jogador);
   lista_pecas(inicio, 'bomba', 11, jogador);
end; { dados_pecas }

{Procedimento para preencher os vetores dos jogadores com as quantidades de cada pe�a -> as fun��es devem alterar esse valor}
procedure pecas_jogadores;
begin
   controle_pecas[0] := 1;
   controle_pecas[1] := 1;
   controle_pecas[2] := 8;
   controle_pecas[3] := 5;
   controle_pecas[4] := 4;
   controle_pecas[5] := 4;
   controle_pecas[6] := 4;
   controle_pecas[7] := 3;
   controle_pecas[8] := 2;
   controle_pecas[9] := 1;
   controle_pecas[10] := 1;
   controle_pecas[11] := 6;
end; { pecas_jogadores }


procedure preenche_lago;
begin
   tabuleiro[5][3] := lago;
   tabuleiro[5][4] := lago;
   tabuleiro[6][3] := lago;
   tabuleiro[6][4] := lago;
   tabuleiro[5][7] := lago;
   tabuleiro[5][8] := lago;
   tabuleiro[6][7] := lago;
   tabuleiro[6][8] := lago;
end; { preenche_lago }

procedure imprime_tabuleiro;
var i, j : integer;
begin
   for i := 1 to 10 do
   begin
      for j := 1 to 10 do
         if (tabuleiro[i][j] = nil) then
            write('__ ')
         else
            if (tabuleiro[i][j] = lago) then
               write('XX ')
            else
               write(tabuleiro[i][j]^.rank:2, ' ');
      writeln;
   end;
end; { imprime_tabuleiro }

{Fun��o para localizar o rank na lista, se ele for v�lido}
function acha_rank(inicio : no_pecas; rank : integer): no_pecas;
var aux : no_pecas;
begin
   aux := inicio;
   while (aux^.rank <> rank) and (aux <> nil) do
   begin
      aux := aux^.prox;
   end;
   acha_rank := aux;
end;
      
{Procedimento para dispor as pe�as de determinado jogador (a ou b) no tabuleiro}   
procedure dispor_pecas(inicio : no_pecas);
var q, linha, coluna, rank : integer;
   checagem                : boolean;
   aux                     : no_pecas;
begin
   q := 0;
   repeat
      writeln('Digite o rank de uma pe�a. Use 11 para bomba e 0 para bandeira');
      readln(rank);
      aux := acha_rank(inicio, rank);
      {Se o jogador digitar um rank inv�lido ele ter� que digitar novamente}
      while (aux <> nil) or (aux^.qtde < controle_pecas[rank]) do
      begin
         writeln('Pe�a indispon�vel. Por favor, digite novamente o rank');
         readln(rank);
         aux := acha_rank(inicio, rank);
      end;
      checagem := false; {Vari�vel para verificar se o jogador digitou uma posi��o v�lida no tabuleiro}
      repeat   
         writeln('Digite a posi��o da pe�a');
         readln(linha, coluna);
         if (aux^.jogador = 1) then
         begin
            if (linha < 0) or (linha > 4) then
               writeln('Posi��o inv�lida')
            else
               checagem := true;
         end
         else
            if (linha > 20) or (linha < 17) then
               writeln('Posi��o inv�lida')
            else
               checagem := true;
      until (checagem = true);
      tabuleiro[linha][coluna] := aux;
      inc(aux^.qtde); {Incrementa o n�mero de pe�as j� alocadas na lista do jogador}
      inc(q);
      imprime_tabuleiro;
   until (q = 2); {XXX: q = 40}
end; { dispor_pecas }

procedure remove_peca(peca : no_pecas);
begin
   {Decrementa o vetor que diz a quantidade de cada pe�a}
   dec(peca^.qtde);
end; { remove_peca }

{
Fun��o de combate: ela checa qual pe�a ganha no combate direto
Valores de retorno:
0 para empate -> exclus�o das duas pe�as
1 para vit�ria do atacante -> exclus�o do atacado
-1 para vit�ria do atacado -> exclus�o do atacante
}

function combate(linha1, coluna1, linha2, coluna2 : integer) : integer;
var atacante, atacado : no_pecas;
begin
   atacante := tabuleiro[linha1][coluna1];
   atacado := tabuleiro[linha2][coluna2];
   {Exce��o 1: cabo-armeiro desarma a bomba}
   if (atacante^.rank = 3) and (atacado^.rank = 11) then
   begin
      remove_peca(atacado);
      tabuleiro[linha2][coluna2] := tabuleiro[linha1][coluna1];      
   end
   else
      {Exce��o 2: se o espi�o atacar o marechal ele ganha}
      if (atacante^.rank = 1) and (atacado^.rank = 10) then
      begin
         remove_peca(atacado);
         tabuleiro[linha2][coluna2] := tabuleiro[linha1][coluna1];
      end
      else
         {Regra: ganha quem tiver maior rank}
         if (atacante^.rank > atacado^.rank) then
         begin
            remove_peca(atacado);
            tabuleiro[linha2][coluna2] := tabuleiro[linha1][coluna1];
            combate := 1;
         end
         else
            if (atacante^.rank = atacado^.rank) then
            begin
               remove_peca(atacado);
               remove_peca(atacante);
               tabuleiro[linha2][coluna2] := nil;
               combate:=0;
            end
            else
            begin
               remove_peca(atacante);
               combate:=-1;
            end;
   {O lugar da pe�a atacante sempre vai ficar vazio -> ou ela toma outro lugar ou ela � derrotada}
   tabuleiro[linha1][coluna1] := nil;
end; { combate }

function valida_movimento(linha_atual, coluna_atual, linha, coluna : integer) : boolean;
var aux : boolean;
   rank : integer;
begin
   aux := false;
   rank := tabuleiro[linha_atual][coluna_atual]^.rank;
   if (linha > 0) and (linha <= 10) and (coluna > 0) and (coluna <= 10) then
   begin
      if ((linha = linha_atual + 1) and (coluna = coluna_atual)) or ((linha = linha_atual -1) and (coluna = coluna_atual)) or ((coluna = coluna_atual + 1) and (linha = linha_atual)) or ((coluna = coluna_atual - 1) and (linha = linha_atual)) then
         aux := true;
      {Regra de movimento de 1 casa horizontal ou vertical v�lida para todas as pe�as, exceto 2}
      if (rank = 2) then
      begin
         if (linha = linha_atual) then
         begin
            if (coluna <> coluna_atual) and (tabuleiro[linha][coluna] = nil) then
               aux := true;
         end
         else
            if (coluna = coluna_atual) then
            begin
               if (linha <> linha_atual) and (tabuleiro[linha][coluna] = nil) then
                  aux := true;
            end;
      end;
   end;
   valida_movimento := aux;
end; { valida_movimento }

{Procedimento para cuidar dos movimentos das pe�as -> linha_atual e coluna_atual s�o as coordenadas da pe�a, j � o inteiro que representa o jogador 1 ou 2, linha e coluna s�o as coordenadas que o jogador pretende mover a pe�a}

function move_peca(jogador, linha_atual, coluna_atual, linha, coluna : integer) : boolean;
var espaco1, espaco2 : integer;
begin
   {XXX: checar se a pe�a de origem � do jogador }
   espaco1 := tabuleiro[linha_atual][coluna_atual]^.jogador;
   espaco2 := tabuleiro[linha][coluna]^.jogador;
   
   {Checagem de movimentos inv�lidos}
   if (tabuleiro[linha_atual][coluna_atual]^.rank = 0) or (tabuleiro[linha_atual][coluna_atual]^.rank = 11) then
      writeln('Movimento inv�lido: pe�a im�vel. Por favor, tente novamente')
   else
      if (espaco1 = espaco2) then
         writeln('Movimento inv�lido: pe�a do mesmo jogador. Por favor, tente novamente.')
      else
         if (tabuleiro[linha][coluna]^.rank = -1) then
            writeln('Movimento inv�lido: �rea intransit�vel. Por favor, tente novamente.')  
   else
   begin
      if valida_movimento(linha_atual, coluna_atual, linha, coluna) then
         {Se o lugar estiver vazio...}
         if (tabuleiro[linha][coluna] = nil) then
         begin
            tabuleiro[linha][coluna] := tabuleiro[linha_atual][coluna_atual];
            tabuleiro[linha_atual][coluna_atual] := nil;
         end
         else
            combate(linha_atual, coluna_atual, linha, coluna);
   end
   
end; { move_peca }                      

function final_jogo(jogador : integer) : boolean;
var aux   : boolean;
   inicio : no_pecas;
begin
   {Verificar condi��es de final de jogo: advers�rio im�vel, se a �ltima pe�a ataca foi a bandeira...}
   aux := false;
   final_jogo := aux;
end;

var
   final : boolean;

{Programa principal}
begin
   {preenchimento da �rea do lago... como temos uma matriz de ponteiros, temos um ponteiro para o lago ser inserido no tabuleiro}
   new(lago);
   lago^.rank := -1;
   lago^.nome := 'lago';
   lago^.jogador := 0;
   preenche_lago;
   new(jog1);
   new(jog2);
   {Cria��o de lista para os dois jogadores}
   dados_pecas(jog1, 1);
   dados_pecas(jog2, 2);
   pecas_jogadores;
   {Disp�e pe�as para os dois jogadores}
   dispor_pecas(jog1);
   dispor_pecas(jog2);
   jogador := 1;
   {Inicio do jogo}
   repeat
      writeln('Informe as coordenadas da pe�a que deseja mover');
      readln(linha_atual, coluna_atual);
      writeln('Informe as coordenadas do espa�o desejado');
      readln(linha, coluna);
      move_peca(jogador, linha_atual, coluna_atual, linha, coluna);
      final := final_jogo(jogador);
      jogador := (jogador mod 2) + 1;
   until (final);
end.