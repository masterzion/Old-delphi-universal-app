unit mzlib;

interface

uses {$IFDEF MSWINDOWS}
        Windows,
    {$ENDIF}

    {$IFDEF LINUX}
      SysUtils,
    {$ENDIF}

    SysUtils, Classes, mzComboBoxClx,  QForms, QActnList, QMenus;

type
  TpArStr = array of pchar;
  TArStr        = array of string;
  TProcedureExterna = procedure(var VariantArray : pchar); stdcall;

  TConnectItem = packed record
     sTabelaOrigem, sTabelaDestino, sCampoOrigem, sCampoDestino : String;
  end;
  TListArray = array of TStringList;
  TConnectArray = array of TConnectItem;

const
   SQL_PARM : string = ' :';
   S_AP           = '''';
   ASSQL          = ' AS ';
   PWDSQL         = 'password';
   BOOLEAN_TRUE   = 'Y';
   BOOLEAN_FALSE  = 'F';
   sNow           = ' now() ';
   sDateAntes     = ' DATE_FORMAT(';
   sDateDepois    = ', '+S_AP+'%d/%m/%y'+S_AP+')';
   sDataExpirada  = ' date_add(dPasswd , interval nValidade day) >= '+sNow+ASSQL+' Validade  ';
   sData_FALSE     = '-1';
   CaminhoRel    = 'rels\';


   CODIGO_EMPRESA = 'nIDEmpresa';
   CAMPO_BUSCA    = 'sCampoBusca';

   RETUNR_KEY  : word = 4100;
   RETUNR_KEY2 : word = 4101;
   PGDOWN_KEY  : word = 4113;

   {$IFDEF LINUX}
      S_DIR : string = '/';
      S_EXT : string = '.so';
   {$ENDIF}

   {$IFDEF MSWINDOWS}
      S_DIR : string = '\';
      S_EXT : string = '.dll';
   {$ENDIF}


    stConfig           : string = ' Carregando configura��es...';
    stConecta          : string = ' Conectando ao banco de dados...';
    stListaModulos     : string = ' Listando modulos...';
    stCarregaPlugins   : string = ' Carregando plugins...';
    stVerificaUsuarios : string = ' Verificando usuarios...';
    stCarregando       : string = ' Carregando';

    mzQuerySave       : Integer = 0;
    mzQueryLocalizar  : Integer = 1;
    mzQueryExecutar   : Integer = 2;
    mzQueryExcluir    : Integer = 3;
    mzQueryTravar     : Integer = 4;
    mzQueryDestravar  : Integer = 5;
    mzQueryLoad       : Integer = 6;
    mzQueryCampoChave : Integer = 7;
    mzQuerySaveChild  : Integer = 8;
    mzCarregaAcesso    : Integer = 9;

    // ***************************
    // *     Filtro de Erros     *
    // ***************************
    ErroSalvar        : string = 'N�o foi possivel gravar os dados!';
    ErroSalvarFilhas  : string = 'N�o foi possivel gravar os dados das tabelas filhas!';
    ErroLocalizar     : string = 'N�o foi possivel localizar os dados!';
    ErroExecutar      : string = 'N�o foi possivel executar altera��es na base de dados!';
    ErroExcluir       : string = 'N�o foi possivel excluir os dados!';
    ErroCampoChave    : string = 'N�o foi possivel Localizar o campo chave!';
    ErroTravar        : string = 'N�o foi possivel travar a tabela ';
    ErroDestravar     : string = 'N�o foi possivel destravar a tabela ';
    ErroAcesso        : string = 'Este usuario n�o tem permiss�o para executar essa a��o!'+#13+'Opera��o cancelada!';
    ErroLoad          : string = 'N�o foi possivel carregar o formul�rio!';
    ErroConectaBD     : string = 'N�o foi possivel conectar ao banco de dados!';
    ErroCamposChave   : string = 'N�o foi possivel obter Campo Chave!'+#13+'O numero do campo � maior q o numero de colunas na consulta!';

    ErroSenhaInvalida    : string = '  Senha invalida!!!';
    ErroSenhaExpirada    : string = '  Senha Expirada!!!'+#13+'Entre em contato com o Administrador.';
    ErroCampoObrigatorio : string = 'Existem campos obrigat�rios n�o preenchidos.';
    ErroChaveVazio       : string = 'Existem campos chaves n�o preenchidos.';
    ExcluirDados         : string = 'Aten��o!!! Os Dados ser�o excluidos definitivamente, deseja continuar?';
    CarregaAcesso        : string = 'Aten��o!!! N�o foi possivel Carregar as permiss�es de Acesso';
    sHOJE                : string = 'Hoje';
    sExcluido            : string = 'Excluido!!!';
    sAbrir               : string = 'Abrir';

    msgErrSemDestino     : string = 'Selecione um destinat�rio!';
    msgErrEmBranco       : string = 'A mensagem est� em branco!';
    msgEnviada           : string = 'A mensagem foi enviada com sucesso!';
    msgNova              : string = 'Mensagem';



   function iif(Value:Boolean; RetTrue, RetFalse:String):String; overload;
   function iif(Value:Boolean; RetTrue, RetFalse:Integer):Integer; overload;
   function iif(Value:Boolean; RetTrue, RetFalse:Real):Real; overload;
   
   function RemoveChar(Texto:String; sChar:Char):String;


   function AddConnectInArray(ConnectItem : TConnectItem; ConnectArray :TConnectArray ):TConnectArray;
   function AddListaInArray(Lista : TStringList; ListArray : TListArray):TListArray;

   procedure ChamaProcedure(const NomeDLL, ProcName :string;var Parametros, Resultado: pchar);
   procedure ObtemTabelaCampo(const sCampoTabela:string; ListaArray :TListArray ;var cmbField, cmbTable: TmzComboBoxClx);
   procedure ApagaCaracteres(var Texto: String); overload;
   procedure ApagaCaracteres(var Texto: String; const ApagaPorcento:Boolean); overload;
   function TiraAspas(Texto:String):String;
   function VirgulaPraPonto(texto:String):String;
   function LimpaCaption(Sender:TObject):string;

implementation

procedure ObtemTabelaCampo(const sCampoTabela:string;ListaArray :TListArray ;var cmbField, cmbTable: TmzComboBoxClx);
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

procedure ChamaProcedure(const NomeDLL, ProcName :string;var Parametros, Resultado: pchar);
var
  Handle: THandle;
  ProcedureExterna : TProcedureExterna;
begin
  Handle := LoadLibrary(pchar(NomeDLL));
  if Handle <> 0 then begin
    @ProcedureExterna := GetProcAddress(Handle, pchar(ProcName));
    if @ProcedureExterna <> nil then ProcedureExterna(Parametros);
    StrNew(Resultado);
    strpcopy(Resultado, Parametros);
    FreeLibrary(Handle);
  end;
end;


function RemoveChar(Texto:String; sChar:Char):String;
begin
  Result := Texto;
  while pos(sChar,Result) <> 0  do delete(Result, pos(sChar,Result), 1);
end;

procedure ApagaCaracteres(var Texto: String);
begin
  Texto := RemoveChar(Texto, '"');
  Texto := RemoveChar(Texto, S_AP);
  Texto := RemoveChar(Texto, '\');
end;

procedure ApagaCaracteres(var Texto: String; const ApagaPorcento:Boolean);
begin
  ApagaCaracteres(Texto);
  if ApagaPorcento then
    Texto := RemoveChar(Texto, '%');
end;

function TiraAspas(Texto:String):String;
var
 sTemp:String;
begin
  sTemp := Texto;
  Texto := RemoveChar(Texto, '"');
  Result := sTemp;
end;

function VirgulaPraPonto(Texto:String):String;
var
 sTemp:String;
begin
  sTemp := Texto;
  if (pos(',', sTemp) <> 0) then sTemp[pos(',', sTemp)] := '.';
  while pos(',', sTemp) <> 0 do delete(sTemp, pos(',', sTemp), 1);
  Result := sTemp;
end;

function LimpaCaption(Sender:TObject):string;
var
 Texto : String;
begin
  Texto := 'Erro';
  if (Sender is TCustomAction) then Texto := (Sender as TCustomAction).Caption;
  if (Sender is TMenuItem)     then Texto := (Sender as TMenuItem).Caption;
  Result := RemoveChar(Texto, '&');
end;

end.
