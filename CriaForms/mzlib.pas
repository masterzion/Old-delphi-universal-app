unit mzlib;

interface
uses Classes, mzComboBoxClx, SysUtils, QDialogs, QControls;

{$include configura.inc}

type
  TConnectItem = packed record
     sTabelaOrigem, sTabelaDestino, sCampoOrigem, sCampoDestino : String;
  end;
  TListArray = array of TStringList;
  TConnectArray = array of TConnectItem;

   TmzQueryObject = class(TComponent)
   public
      ListaTabelas : TStringList;
      ListArray    : TListArray;
      CamposChaves : TStringList;
      ConnectArray : TConnectArray;
      NomeModulo   : String;
      ConsultaChave : String;
      {$IFDEF corporate}
        FiltraEmpresa:Boolean;
      {$ENDIF}
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
   end;

const
   SQL_PARM    : string = ' :';
   S_AP        = '''';
   PWDSQL      = 'password';
   ASSQL       = ' AS ';

   FILTRO_EMPRESA = 'nIDEmpresa';

   RETUNR_KEY  = 4100;
   RETUNR_KEY2 = 4101;
   NONE_TEXT   = '[none]';


   ErroConectaBD : string = 'Não foi possivel conectar ao banco de dados!';

   ErroSemCampos   : string = 'É nescessário escolher uma ou mais campo chave.';
   ErroSemNome     : string = 'É nescessário escolher um nome para esse módulo.';
   ErroSemConsulta : string = 'É nescessário uma consulta para obter o código do campo chave.';

   msgApagaForm       : string = 'Esse formulario sera excluido permanentemente! Deseja Continua?';
   msgExcluido        : string = 'Excluido!';
   NomeCampo          : string = 'Digite o nome do campo virtual';
   Campo              : string = 'Campo:';
   NomeCampoBranco    : string = 'Nome do campo não pode ser vazio!';
   ErrNomeCampoExiste : string = 'Já exite um campo com esse nome!';
   ErrQuery           : string = 'Consulta invalida!';
   msgOK              : string = 'OK';

   NomeRelatorio      : string = 'Digite o nome do relatorio';
   Nome               : string = 'Nome:';
   msgApagaRel        : string = 'Esse relatorio sera excluido permanentemente! Deseja Continua?';
   CaminhoRel         : string = 'rels\';
   constExcluir       : string = 'Excluir';
   constEditar        : string = 'Editar';
   sAbrir             : string = 'Abrir';

     function iif(Value:Boolean; RetTrue, RetFalse:String):String; overload;
     function iif(Value:Boolean; RetTrue, RetFalse:Integer):Integer; overload;
     function iif(Value:Boolean; RetTrue, RetFalse:Real):Real; overload;

     function AddConnectInArray(ConnectItem : TConnectItem; ConnectArray :TConnectArray ):TConnectArray;
     function AddListaInArray(Lista : TStringList; ListArray : TListArray):TListArray;
     procedure LimpaLista(var Lista : string);

//     function  CriaListaArray(const ListaTabelas, sListaTemp : TStringlist ): TListArray;
     procedure ObtemTabelaCampo(const sCampoTabela:string; ListaArray :TListArray ;var cmbField, cmbTable: TmzComboBoxClx);
     procedure CriaConnectArray(const sConnection: String;var  ConnectArray : TConnectArray);
     function msgSimNao(Texto : string):boolean;
implementation


procedure ObtemTabelaCampo(const sCampoTabela:string; ListaArray :TListArray ;var cmbField, cmbTable: TmzComboBoxClx);
var
 nTemp : Integer;
 sCampo, sTabela : string;
begin
  if (sCampoTabela <> '') then begin
    nTemp   := pos('.', sCampoTabela);
    sTabela := copy(sCampoTabela, 0, nTemp-1);
    sCampo := copy(sCampoTabela, nTemp+1, Length(sCampoTabela));
    cmbTable.ItemIndex := cmbTable.Items.IndexOf(sTabela);
    cmbField.Items     := ListaArray[cmbTable.ItemIndex];
    cmbField.ItemIndex := cmbField.Items.IndexOf(sCampo);
  end;
end;

function AddConnectInArray(ConnectItem : TConnectItem; ConnectArray :TConnectArray ):TConnectArray;
var
 n, nTamanho    : Integer;
 InConnectArray : TConnectArray;
begin
  nTamanho := Length(ConnectArray);
  Setlength(InConnectArray, nTamanho+1);
  for n := 0 to nTamanho-1 do InConnectArray[n] := ConnectArray[n];
  InConnectArray[nTamanho] := ConnectItem;
  Result := InConnectArray;
end;

function AddListaInArray(Lista : TStringList; ListArray : TListArray):TListArray;
var
 n, nTamanho    : Integer;
 InListArray    : TListArray;
 InLista        : TStringList;
begin
  nTamanho := Length(ListArray);
  Setlength(InListArray, nTamanho+1);
  for n := 0 to nTamanho-1 do begin
     InLista  := TStringList.Create;
     InLista.Text := ListArray[n].Text;
     InListArray[n] := InLista;
  end;

  InLista  := TStringList.Create;
  InLista.Text := Lista.Text;

  InListArray[nTamanho] := InLista;
  Result := InListArray;
end;


function iif(Value:Boolean; RetTrue, RetFalse:String):String;
begin
  if Value then
    Result := RetTrue
  else
    Result := RetFalse;
end;

function iif(Value:Boolean; RetTrue, RetFalse:Integer):Integer;
begin
  if Value then
    Result := RetTrue
  else
    Result := RetFalse;
end;

function iif(Value:Boolean; RetTrue, RetFalse:Real):Real; overload;
begin
  if Value then
    Result := RetTrue
  else
    Result := RetFalse;
end;

procedure CriaConnectArray(const sConnection: String;var  ConnectArray : TConnectArray);
  function ContaVirgulas(Texto:String):integer;
  var
    n:Integer;
  begin
    result := 0;
    for n := 1 to Length(Texto) do
      if (Texto[n] = ',') then Result := Result+1
  end;


var
  nItemsCount, N, nTemp : Integer;
  sTemp : String;
  ConnectionItem : TConnectItem;
begin
  sTemp := trim(sConnection);
  setlength(ConnectArray, 0);
  nItemsCount := (ContaVirgulas(sConnection) div 4);
  for n := 0 to nItemsCount-1 do begin
    // Tabela Origem
    nTemp := pos(',', sTemp);
    ConnectionItem.sTabelaOrigem := trim(copy(sTemp, 0, nTemp-1));
    sTemp := trim(copy(sTemp, nTemp+1, Length(sTemp)));

    // Tabela Destino
    nTemp := pos(',', sTemp);
    ConnectionItem.sTabelaDestino := trim(copy(sTemp, 0, nTemp-1));
    sTemp := copy(sTemp, nTemp+1, Length(sTemp));

    // Campo Origem
    nTemp := pos(',', sTemp);
    ConnectionItem.sCampoOrigem := trim(copy(sTemp, 0, nTemp-1));
    sTemp := copy(sTemp, nTemp+1, Length(sTemp));


    // Campo Origem
    nTemp := pos(',', sTemp);
    ConnectionItem.sCampoDestino := trim(copy(sTemp, 0, nTemp-1));
    sTemp := copy(sTemp, nTemp+1, Length(sTemp));

    ConnectArray := AddConnectInArray(ConnectionItem, ConnectArray);
  end;

end;

procedure LimpaLista(var Lista : string);
var
 n: integer;
 InLista : TStringlist;
begin
 InLista := TStringlist.Create;
 InLista.Text := Lista;
 for n := InLista.Count-1 downto 0 do
   if (InLista.Strings[n] = '') then InLista.Delete(n);
 Lista := InLista.Text;
 InLista.Destroy

end;


function msgSimNao(Texto : string):boolean;
var
 sTemp: widestring;
begin
  sTemp := Texto;
  Result := MessageDlg(sTemp,  mtConfirmation, [mbYes, mbNo], 0) = mrNo;
end;

{
function CriaListaArray(const ListaTabelas, Query : TSQLQuery ): TListArray;
var
  n1, n2, N, nTamanho : Integer;
  Lista : TStringList;
  sTemp : string;
begin
  nTamanho := ListaTabelas.Count;
  Setlength(Result, 0);

  for n := 0 to nTamanho-1 do begin
     Lista := TStringList.Create;
     Result := AddListaInArray(Lista, Result);
  end;


  for n1 := 0 to sListaTemp.Count-1 do begin
     for n2 := 0 to nTamanho-1 do begin
       sTemp := copy(sListaTemp.Strings[n1] , 0 , pos('.', sListaTemp.Strings[n1] ) -1 );
       if (sTemp = ListaTabelas.Strings[n2] ) then
         Result[n2].add(copy(sListaTemp.Strings[n1] , pos('.', sListaTemp.Strings[n1] ) +1, Length(sListaTemp.Strings[n1]) ));
    end;
  end;

end;
}

constructor TmzQueryObject.Create(AOwner: TComponent);
begin
  inherited;
  ListaTabelas  := TStringList.Create;
  CamposChaves  := TStringList.Create;
 {$IFDEF corporate}
  FiltraEmpresa := True;
  {$ENDIF}
  NomeModulo   := '';
  Setlength(ListArray,0);
  Setlength(ConnectArray, 0);
end;

destructor TmzQueryObject.Destroy;
begin
  ListaTabelas.Destroy;
  CamposChaves.Destroy;

inherited;
end;

end.
