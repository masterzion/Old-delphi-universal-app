unit Principal;

{$include configura.inc}

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, DBXpress, FMTBcd, QMenus, DB, SqlExpr, QImgList,
  QMask, IniFiles, mzlib, QStyle, DCPcrypt2, DCPrc4, DCPmd5, QExtCtrls;


const
   AppName    : string = 'Universal';
   AppVer     : string = '1.2.2'; //Version, Release, Build

{$IFDEF corporate}
   AppEdition : string = 'Corporate Edition';
{$ENDIF}

{$IFDEF personal}
   AppEdition : string = 'Personal Edition';
{$ENDIF}

type
  TfrmPrincipal = class(TForm)
    SQLConnection1: TSQLConnection;
    MainMenu1: TMainMenu;
    Arquivo1: TMenuItem;
    Novo1: TMenuItem;
    Sair1: TMenuItem;
    DataSet: TSQLDataSet;
    ImageList1: TImageList;
    Editar1: TMenuItem;
    N2: TMenuItem;
    DCP_RC4: TDCP_rc4;
    ImageList2: TImageList;
    Ajuda1: TMenuItem;
    Topicos1: TMenuItem;
    N3: TMenuItem;
    Sobre1: TMenuItem;
    Opes1: TMenuItem;
    Configurar2: TMenuItem;
    procedure Sair1Click(Sender: TObject);
    procedure Novo1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditFormClick(Sender: TObject);
    procedure Topicos1Click(Sender: TObject);
    procedure Configurar2Click(Sender: TObject);
    procedure Sobre1Click(Sender: TObject);
  private
    { Private declarations }
    PalavraChave, Caminho : string;
    procedure AbreConfig;
    procedure DrawMenuItem(Sender, Source: TObject; Canvas: TCanvas; Highlighted, Enabled: Boolean; const Rect: TRect; Checkable: Boolean; CheckMaxWidth, LabelWidth: Integer);
  public
    DataBaseName, RegEmp     : string;
    function Descodificar(const Texto:string):string;
    function Codificar(const Texto:string):string;
    procedure CarregaMenu;
    procedure CarregaConfig;
    function AppPath:string;
    procedure ShowFormQuery  (const QueryObject : TmzQueryObject);
    procedure ShowFormChave  (const QueryObject : TmzQueryObject);
    procedure ShowFormEditor (const QueryObject : TmzQueryObject);
    procedure CopyFile(Origem, Destino:String);
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses QueryEditor, ChaveEditor, FormEditor, formConfigura, formSplash;

{$R *.xfm}

procedure TfrmPrincipal.CopyFile(Origem, Destino:String);
var
  Msg: string;
  NewFile: TFileStream;
  OldFile: TFileStream;
begin
  OldFile := TFileStream.Create(Origem, fmOpenRead or fmShareDenyWrite);

  try
    NewFile := TFileStream.Create(Destino, fmCreate or fmShareDenyRead);

    try
      NewFile.CopyFrom(OldFile, OldFile.Size);
    finally
      FreeAndNil(NewFile);
    end;

  finally
    FreeAndNil(OldFile);
  end;
end;


function TfrmPrincipal.AppPath:string;
begin
   Result := Caminho;
end;

procedure TfrmPrincipal.AbreConfig;
var
 frmConfigura: TfrmConfigura;
begin
 frmConfigura := TfrmConfigura.Create(self);
 frmConfigura.ShowModal;
end;

procedure TfrmPrincipal.Sair1Click(Sender: TObject);
begin
 Close;
end;

procedure TfrmPrincipal.Novo1Click(Sender: TObject);
var
  QueryObject  : TmzQueryObject;
begin
 QueryObject := TmzQueryObject.Create(Self);
 ShowFormQuery(QueryObject);
end;


// Exibe tela de query
procedure TfrmPrincipal.ShowFormQuery(const QueryObject:TmzQueryObject);
begin
 frmQueryEditor := TfrmQueryEditor.Create(self);
 frmQueryEditor.QueryObject := QueryObject;
 frmQueryEditor.Show;
end;


// Exibe tela de campos chaves
procedure  TfrmPrincipal.ShowFormChave(const QueryObject: TmzQueryObject);
begin
 frmChaveEditor := TfrmChaveEditor.Create(self);
 frmChaveEditor.QueryObject := QueryObject;
 frmChaveEditor.SetVars(QueryObject.ListaTabelas, QueryObject.ListArray);
 frmChaveEditor.Show;
end;


// Exibe tela de edição de formularios
procedure TfrmPrincipal.ShowFormEditor(const QueryObject: TmzQueryObject);
begin
    frmFormEditor := TfrmFormEditor.Create(Self);
    frmFormEditor.Caption := QueryObject.NomeModulo;
    frmFormEditor.SetVars(QueryObject.ListaTabelas, QueryObject.ListArray, QueryObject.ConnectArray, QueryObject.CamposChaves.Text, QueryObject.ConsultaChave);
    {$IFDEF corporate}
     if QueryObject.FiltraEmpresa then frmFormEditor.sCampoEmpresa := FILTRO_EMPRESA;
    {$ENDIF}
    frmFormEditor.Show;
    QueryObject.Destroy;
end;

procedure TfrmPrincipal.CarregaMenu;
var
  n : Integer;
  MenuItem : TMenuItem;
begin
  for n := 0 to Editar1.Count-1 do Editar1.Delete(0);
  with DataSet do begin
    Close;
    CommandText := 'select nIDForm, sTitulo from tbForm';
    Open;
    for n := RecordCount-1 downto 0 do begin
      MenuItem := TMenuItem.Create(self);
      MenuItem.Caption := FieldbyName('sTitulo').AsString;
      MenuItem.Tag := FieldbyName('nIDForm').AsInteger;
      MenuItem.ImageIndex := 0;
      MenuItem.OnClick := EditFormClick;
      Editar1.Add(MenuItem);
      Next;
    end;
  end;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
var
  s : String;
begin
  PalavraChave := AppName+AppEdition;
  Application.Style.AfterDrawMenuItem := DrawMenuItem;
  Caminho := ExtractFilePath(Application.Exename);
//  CarregaConfig;

 try
   SQLConnection1.Connected := True;
 except
   ShowMessage(ErroConectaBD);
   AbreConfig;
 end;

  s:= AppName+' ['+AppEdition+'] Ver '+AppVer;
  Self.Caption := s;
  Application.Title := s;
  CarregaMenu;
end;

procedure TfrmPrincipal.CarregaConfig;
var
 Ini           : TIniFile;
 strParams     : TStringList;
 nIdioma       : Integer;
 sTemp, sSenha : string;
begin
  Ini := TIniFile.Create(Caminho+'mzconfig.ini');

  strParams := TStringList.Create;
  SQLConnection1.ConnectionName := 'cadastral';
  sTemp := Ini.ReadString('db', 'DriverName', 'MySQL');
  with strParams do begin
    Add('DriverName'+'='+ sTemp );
    Add('HostName'+'='+   Ini.ReadString('db', 'HostName',   'localhost') );
    Add('Database'+'='+   Ini.ReadString('db', 'Database',   'cadastro') );
    Add('User_Name'+'='+  Ini.ReadString('db', 'User_Name',  'root') );
    Add('Password'+'='+   Descodificar(Ini.ReadString('db', 'Password',   '') ) );
    Add('BlobSize=-1');
    Add('ErrorResourceFile=./DbxMySqlErr.msg');
    Add('LocaleCode=0000');
  end;
  SQLConnection1.Params.Text :=  strParams.Text;
  strParams.Destroy;
  SQLConnection1.DriverName := Stemp;

  if uppercase(sTemp) = 'MYSQL'     then begin
     {$IFDEF MSWINDOWS}
        SQLConnection1.LibraryName   := 'dbexpmysql.dll';
        SQLConnection1.GetDriverFunc := 'getSQLDriverMYSQL';
        SQLConnection1.VendorLib     := 'libmysql.dll';
     {$ENDIF}
     {$IFDEF LINUX}
        SQLConnection1.LibraryName :=  'libsqlmy.so';
        SQLConnection1.GetDriverFunc := 'getSQLDriverMYSQL';
        SQLConnection1.VendorLib   :=  'libmysqlclient.so';
     {$ENDIF}
  end;

  if uppercase(sTemp) = 'INTERBASE' then begin
     {$IFDEF MSWINDOWS}
        SQLConnection1.LibraryName := 'dbexpmysql.dll';
        SQLConnection1.GetDriverFunc := 'getSQLDriverINTERBASE';
        SQLConnection1.VendorLib   := 'libmysql.dll';
     {$ENDIF}
     {$IFDEF LINUX}
        SQLConnection1.LibraryName :=  'libsqlib.so';
        SQLConnection1.GetDriverFunc := 'getSQLDriverINTERBASE';
        SQLConnection1.VendorLib   :=  'libgds.so';
     {$ENDIF}
  end;

  if uppercase(sTemp) = 'ORCACLE' then begin
     {$IFDEF MSWINDOWS}
        SQLConnection1.LibraryName := 'dbexpmysql.dll';
        SQLConnection1.GetDriverFunc := 'getSQLDriverMYSQL';
        SQLConnection1.VendorLib   := 'libmysql.dll';
     {$ENDIF}
     {$IFDEF LINUX}
        SQLConnection1.LibraryName :=  'libsqlora.so';
        SQLConnection1.GetDriverFunc := 'getSQLDriverMYSQL';
        SQLConnection1.VendorLib   :=  'libsqlora.so';
     {$ENDIF}
  end;

  nIdioma := Ini.ReadInteger('Aparencia', 'Idioma', 0);
  Application.Style.DefaultStyle := TDefaultStyle(Ini.ReadInteger('Aparencia', 'Estilo', 0));

  Ini.Free;
end;

procedure TfrmPrincipal.EditFormClick(Sender: TObject);
begin
    frmFormEditor := TfrmFormEditor.Create(Self);
    frmFormEditor.Caption := (Sender as TMenuItem).Caption;
    frmFormEditor.CarregaForm( (Sender as TMenuItem).Tag );
    frmFormEditor.Show;
end;

function TfrmPrincipal.Codificar(const Texto:string):string;
begin
  DCP_RC4.InitStr(PalavraChave, TDCP_md5);
  Result := DCP_RC4.EncryptString(Texto);
  DCP_RC4.Burn;
end;

function TfrmPrincipal.Descodificar(const Texto:string):string;
begin
  Result := '';
  DCP_RC4.InitStr(PalavraChave, TDCP_MD5);
  Result := DCP_RC4.DecryptString(Texto);
  DCP_RC4.Burn;
end;

procedure TfrmPrincipal.DrawMenuItem(Sender, Source: TObject; Canvas: TCanvas; Highlighted, Enabled: Boolean; const Rect: TRect; Checkable: Boolean; CheckMaxWidth, LabelWidth: Integer);
var
 MenuItem     : TMenuItem;
 R : TRect;
begin
 R := Rect;
 MenuItem := (source as TMenuItem);
 if (MenuItem.Caption <> '-') then
   if Highlighted then
     Frame3D(Canvas, R, clLight, clShadow,2)
   else
     Frame3D(Canvas, R, clButton, clButton, 1);
end;


procedure TfrmPrincipal.Topicos1Click(Sender: TObject);
begin
  Application.HelpFile := Caminho+'CRIAFORMS.HLP';
  Application.HelpSystem.ShowContextHelp(0, Application.HelpFile);
end;

procedure TfrmPrincipal.Configurar2Click(Sender: TObject);
begin
 AbreConfig;
end;

procedure TfrmPrincipal.Sobre1Click(Sender: TObject);
var
  frmSplash : TfrmSplash;
begin
  frmSplash := TfrmSplash.Create(self);

  with frmSplash do begin
      LabelVersion.Caption := AppName+' '+AppVer;
      LabelEdition.Caption := AppEdition;
      LabelInfo.Caption := '';
      Registro := AppName+' ['+AppEdition+'] '+AppVer;
      btnFechar.Visible := True;
      Timer1.Enabled := True;
      ImageSplash.Picture.LoadFromFile(Caminho+'splash.bmp');
      ShowModal;
  end;
end;

end.
