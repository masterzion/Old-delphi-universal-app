unit principal;

interface

{$include configura.inc}

uses
  SysUtils, Types, Classes, QGraphics, QControls, QForms, QDialogs,
  QStdCtrls, QMenus, QTypes, QComCtrls, QImgList, IniFiles, QStyle,
  DBXpress, DB, SqlExpr, FMTBcd, QActnList, mzlib, QExtCtrls, formMensagens,
  DCPcrypt2, DCPmd5, DCPrc4, mzDBCheckBox, QStdActns, HelpIntfs, mzDBLabel, Variants;

const
//   AppName    : string = 'Universal';
   AppName    : string = 'Cadastral';
{$IFDEF corporate}
   AppEdition : string = 'Corporate Edition';
{$ENDIF}

{$IFDEF personal}
   AppEdition : string = 'Personal Edition';
{$ENDIF}

   AppVer     : string = '1.2.5'; //Version, Release, Build


type
  TfrmPrincipal = class(TForm)
    MainMenu1: TMainMenu;
    Arquivo1: TMenuItem;
    Sair1: TMenuItem;
    Cadastro1: TMenuItem;
    Ajuda1: TMenuItem;
    Sobre1: TMenuItem;
    ImageList1: TImageList;
    Configuracoes1: TMenuItem;
    ControledeGrupos: TMenuItem;
    ControledeUsuarios: TMenuItem;
    Configurcoes: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    SQLConnection1: TSQLConnection;
    ActionList1: TActionList;
    SQLDataSet1: TSQLDataSet;
    N3: TMenuItem;
    PlugInshelp: TMenuItem;
    Plugins: TMenuItem;
    AlterarLogin1: TMenuItem;
    StatusBar: TStatusBar;
    AlterarSenha: TMenuItem;
    Conteudo1: TMenuItem;
    TimerHora: TTimer;
    Ferramentas1: TMenuItem;
    Calendrio1: TMenuItem;
    Calculadora1: TMenuItem;
    Mensagens: TMenuItem;
    N4: TMenuItem;
    DCP_RC4: TDCP_rc4;
    TimerVMensagem: TTimer;
    TimerPiscaMensagem: TTimer;
    ActCalendario: TAction;
    ActCalculadora: TAction;
    ActMensagems: TAction;
    ActAlteraSenha: TAction;
    ActAlteraLogin: TAction;
    ActSair: TAction;
    ActJanelaCascata: TWindowCascade;
    ActJanelaFechar: TWindowClose;
    ActMinimizarJanelas: TWindowMinimizeAll;
    ActjanelaLado: TWindowTile;
    Janelas1: TMenuItem;
    LadoaLado1: TMenuItem;
    Cascata1: TMenuItem;
    MinimizarTodas1: TMenuItem;
    FecharJanela1: TMenuItem;
    ActSobre: TAction;
    ActSobrePlugins: TAction;
    ActAjudaConteudo: THelpContents;
    N5: TMenuItem;
    ActCopiar: TEditCopy;
    ActColar: TEditPaste;
    ActDesfazer: TEditUndo;
    Editar1: TMenuItem;
    Copiar1: TMenuItem;
    Colar1: TMenuItem;
    Desfazer1: TMenuItem;
    ActRefazer: TEditRedo;
    Refazer1: TMenuItem;
    N6: TMenuItem;
    ActConfiguracoes: TAction;
    ActGrupo: TAction;
    ActUsuarios: TAction;
    SQLQueryMsg: TSQLQuery;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Sobre1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OpenForm1Click(Sender: TObject);
    procedure TimerHoraTimer(Sender: TObject);
    procedure TimerVMensagemTimer(Sender: TObject);
    procedure TimerPiscaMensagemTimer(Sender: TObject);
    procedure ActCalendarioExecute(Sender: TObject);
    procedure ActCalculadoraExecute(Sender: TObject);
    procedure ActMensagemsExecute(Sender: TObject);
    procedure ActAlteraSenhaExecute(Sender: TObject);
    procedure ActAlteraLoginExecute(Sender: TObject);
    procedure ActSairExecute(Sender: TObject);
    procedure ActSobreExecute(Sender: TObject);
    procedure StatusBarDblClick(Sender: TObject);
    procedure ActConfiguracoesExecute(Sender: TObject);
    procedure ActGrupoExecute(Sender: TObject);
    procedure ActUsuariosExecute(Sender: TObject);
    procedure ActAjudaConteudoExecute(Sender: TObject);
  private
    { Private declarations }
    nSomaMensagem: Integer;
    sNomeEmpresa, sCodEmpresa, PalavraChave : string;
    procedure AtualizaSeguranca;
//    procedure CarregaPlugins;
    procedure AbreConfig;
    {$IFDEF corporate}
    procedure CarregaNomeEmpresa;
    {$ENDIF}
    procedure DrawMenuItem(Sender, Source: TObject; Canvas: TCanvas; Highlighted, Enabled: Boolean; const Rect: TRect; Checkable: Boolean; CheckMaxWidth, LabelWidth: Integer);
  public
    { Public declarations }
    Caminho, sNomeUsuario : String;
    nCodUsuario  : Integer;
     function Codigo_Empresa  : string;


    procedure AbreMensagens(Consulta:String);

    procedure CarregaConfig;
    procedure VerificaMensagem;
    procedure CarregaMenu;
    function Descodificar2(const Texto:string; chave:string):string;
    function Descodificar(const Texto:string):string;
    function Codificar(const Texto:string):string;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses padrao, formLogin, formGrupo, formMudaPasswd, formUsuario, formSplash,formCalendario, formConfigura, formCalculadora;

{$R *.xfm}

procedure TfrmPrincipal.VerificaMensagem;
begin
    with SQLQueryMsg do begin
      Close;
      SQL.Text       := ' select '+
                     '     Max(nIDMensagem) '+ASSQL+' contagem'+
                     ' from tbMensagem '+
                     ' where '+
                     {$IFDEF corporate}
                     CODIGO_EMPRESA+' = '+sCodEmpresa+' and '+
                     {$ENDIF}
                     ' nIDUsuario = '+IntToStr(frmPrincipal.nCodUsuario);
      Open;

      if (nSomaMensagem <> FieldByName('contagem').AsInteger ) then begin
        nSomaMensagem := FieldByName('contagem').AsInteger;
        TimerPiscaMensagem.Enabled := True;
      end;
    end;
end;

procedure TfrmPrincipal.CarregaConfig;
var
 Ini       : TIniFile;
 strParams : TStringList;
 nIdioma   : Integer;
 sTemp     : string;
begin
  Ini := TIniFile.Create   ('mzconfig.ini');

   sNomeEmpresa  := Ini.ReadString('Configuracao', 'Empresa', '1');
  {$IFDEF corporate}
     sCodEmpresa  := Ini.ReadString('Configuracao', 'Empresa', '1');
  {$ENDIF}

  PalavraChave := AppName+AppEdition;
//  PalavraChave := 'teste';

  strParams := TStringList.Create;
  SQLConnection1.ConnectionName := AppName;
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
  sTemp   := Ini.ReadString ('Aparencia', 'WallPaper', '');
  Application.Style.DefaultStyle := TDefaultStyle(Ini.ReadInteger('Aparencia', 'Estilo', 0));
  Application.Style.AfterDrawMenuItem := DrawMenuItem;

  if (sTemp = '') then
    Self.Bitmap := nil
  else
    if FileExists(sTemp) then
      Self.Bitmap.loadFromFile(sTemp)
     else
      Self.Bitmap := nil;

  Ini.Free;
end;





procedure TfrmPrincipal.AbreMensagens(Consulta:String);
begin
  TimerPiscaMensagem.Enabled := False;
  StatusBar.Panels[3].Text := '';
  frmMensagens := TfrmMensagens.Create(self);
  with ActMensagems do begin
    Visible := False;
    Enabled  := False;
  end;

  with N4 do begin
    Visible := False;
    Enabled  := False;
  end;

  with frmMensagens do begin
    sQuery := Consulta;
    AtualizaMensagens;
    Caption := LimpaCaption(Mensagens);
    ShowModal;
  end;
end;


procedure TfrmPrincipal.AbreConfig;
var
 frmConfigura: TfrmConfigura;
begin
 frmConfigura := TfrmConfigura.Create(self);
 if not SQLConnection1.Connected then frmConfigura.Top := frmConfigura.Top+20;
 frmConfigura.ShowModal;
end;

{
procedure TfrmPrincipal.CarregaPlugins;
var
 sr             : TSearchRec;
 MenuItem       : TMenuItem;
 params, result : pchar;
begin
  FindFirst(Caminho+'plugins'+S_DIR+'*'+S_EXT, faAnyFile, sr);
  repeat
    if (sr.Name <> '.') and (sr.Name <> '..') then begin
      params := '1.0';

      ChamaProcedure(Caminho+'plugins'+S_DIR+sr.Name, 'PluginName',  params, result );
      // Adiciona no menu
      MenuItem := TMenuItem.Create(self);
      MenuItem.ImageIndex := 0;
      MenuItem.Caption := result;
      Plugins.Add(MenuItem);

      // Adiciona no About
      MenuItem := TMenuItem.Create(self);
      MenuItem.ImageIndex := 0;
      MenuItem.Caption := result;
      PlugInshelp.Add(MenuItem);

      // Adiciona em Array Arquivo/Nome
      //
    end;
  until (FindNext(sr) <> 0);

end;
}

procedure TfrmPrincipal.CarregaMenu;
var
  n : Integer;
  MenuItem  : TMenuItem;
begin
  for n := 0 to Cadastro1.Count-1 do Cadastro1.Delete(0);

  with SQLDataSet1 do begin
    Close;
    CommandText := 'select nIDForm, sTitulo from tbForm';
    Open;
    for n := RecordCount-1 downto 0 do begin
      MenuItem := TMenuItem.Create(self);
      MenuItem.Caption := FieldbyName('sTitulo').AsString;
      MenuItem.Tag := FieldbyName('nIDForm').AsInteger;
      MenuItem.ImageIndex := 3;
      MenuItem.OnClick := OpenForm1Click;
      Cadastro1.Add(MenuItem);
      Next;
    end;
  end;
end;

{$IFDEF corporate}
procedure TfrmPrincipal.CarregaNomeEmpresa;
begin
  with SQLDataSet1 do begin
    Close;
    CommandText := 'select sNomeEmpresa from tbEmpresa where '+CODIGO_EMPRESA+' = '+sCodEmpresa;
    Open;
    sNomeEmpresa := FieldbyName('sNomeEmpresa').AsString;
  end;
end;
{$ENDIF}

procedure TfrmPrincipal.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Application.Terminate;
end;

// ******* Outras telas *******

procedure TfrmPrincipal.Sobre1Click(Sender: TObject);
begin

end;


// ******* Telas de Configuração *******
procedure TfrmPrincipal.AtualizaSeguranca;
var
 root:boolean;
begin
    root := (sNomeUsuario = 'ROOT');

    // Torna visivel
    ActUsuarios.Visible        := root;
    ActGrupo.Visible           := root;
    N1.Visible                 := root;
    N2.Visible                 := root;
    ActConfiguracoes.Visible   := root;

    // Torna abilita
    ActUsuarios.Enabled        := root;
    ActGrupo.Enabled           := root;
    N1.Enabled                 := root;
    N2.Enabled                 := root;
    ActConfiguracoes.Enabled   := root;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
var
 sTemp     : string;
{$IFDEF newapp}
  frmSplash : TfrmSplash;
  FormLogin : TFrmLogin;
  n : Integer;
  bFormMovido : boolean;
{$ENDIF}
begin

  // Titulos...
  sTemp := AppName+' ['+AppEdition+'] Ver '+AppVer;
  Self.Caption := sTemp;
  Application.Title := sTemp;
  Caminho := ExtractFilePath(Application.ExeName);

  Application.HelpFile := Caminho+'UNIVERSAL.HLP';
{$IFDEF newapp}
  bFormMovido := False;
  frmSplash := TfrmSplash.Create(self);
  frmSplash.LabelInfo.Caption := stCarregando;
  frmSplash.LabelVersion.Caption := AppName+' '+AppVer;
  frmSplash.LabelEdition.Caption := AppEdition;
  try
  frmSplash.ImageSplash.Picture.LoadFromFile(Caminho+'splash.bmp');
  except
  Application.Terminate;
  end;
  frmSplash.Show;
  frmSplash.Repaint;
{$ENDIF}

{$IFDEF newapp}
  frmSplash.LabelInfo.Caption := stConfig;
{$ENDIF}

  CarregaConfig;

{$IFDEF newapp}
  frmSplash.LabelInfo.Caption := stConecta;
{$ENDIF}

 try
   SQLConnection1.Connected   := True;
 except
   {$IFDEF newapp}
     frmSplash.Top := frmSplash.Top-210;
     bFormMovido := True;
   {$ENDIF}
   ShowMessage(ErroConectaBD);
   AbreConfig;
 end;

{$IFDEF corporate}
 CarregaNomeEmpresa;
{$ENDIF}

 // Carrega Lista de Forms...
{$IFDEF newapp}
  frmSplash.LabelInfo.Caption := stListaModulos;
{$ENDIF}

  CarregaMenu;

  // Carrega plugins....
{$IFDEF newapp}
  frmSplash.LabelInfo.Caption := stCarregaPlugins;
{$ENDIF}
//  CarregaPlugins;

{$IFDEF newapp}
  if not bFormMovido then
     for n := 0 to 20 do
        frmSplash.Top := frmSplash.Top-10;
{$ENDIF}

  // Carrega Login...
{$IFDEF newapp}
  frmSplash.LabelInfo.Caption := stVerificaUsuarios;
  FormLogin := TFrmLogin.Create(self);
  {$IFDEF corporate}
  FormLogin.sCodEmpresa := sCodEmpresa;
  {$ENDIF}
  FormLogin.ShowModal;
{$ENDIF}

{$IFNDEF newapp}
  sNomeUsuario := 'ROOT';
  nCodUsuario  := 1;
{$ENDIF}

 StatusBar.Panels[0].Text := sNomeUsuario;
 AtualizaSeguranca;

 VerificaMensagem;
 TimerVMensagem.Enabled := True;
{$IFDEF newapp}
  frmSplash.Close;
{$ENDIF}
  Self.WindowState := wsMaximized;
end;

procedure TfrmPrincipal.OpenForm1Click(Sender: TObject);
var
 Padrao : TtbPadrao;
begin
 Padrao := TtbPadrao.Create(self);
 Padrao.MenuItem := (Sender as TMenuItem);

 with (Sender as TMenuItem) do begin
   StatusBar.Panels[2].Text := stCarregando+' ['+LimpaCaption(Sender)+']';
   {$IFDEF corporate}
     Padrao.sCodEmpresa := sCodEmpresa;
   {$ENDIF}
   Padrao.CarregaForm(Tag);
   Padrao.btnNovo.Click;
   Enabled := False;
   Visible := False;
   StatusBar.Panels[2].Text := '';
 end;

end;

procedure TfrmPrincipal.TimerHoraTimer(Sender: TObject);
begin
  StatusBar.Panels[1].Text := TimeToStr(now)+'   '+DateToStr(now);
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

function TfrmPrincipal.Codigo_Empresa: string;
begin
 Result := sCodEmpresa;
end;


function TfrmPrincipal.Codificar(const Texto:string):string;
begin
  DCP_RC4.InitStr(PalavraChave, TDCP_md5);
  Result := DCP_RC4.EncryptString(Texto);
  DCP_RC4.Burn;
end;


function TfrmPrincipal.Descodificar2(const Texto:string; chave:string):string;
begin
      Result := '';
      DCP_RC4.InitStr(chave, TDCP_MD5);
      Result := DCP_RC4.DecryptString(Texto);
      DCP_RC4.Burn;
end;



function TfrmPrincipal.Descodificar(const Texto:string):string;
begin
  Result := Descodificar2(Texto, PalavraChave);
end;

procedure TfrmPrincipal.TimerVMensagemTimer(Sender: TObject);
begin
 VerificaMensagem;
end;

procedure TfrmPrincipal.TimerPiscaMensagemTimer(Sender: TObject);
begin
  if (StatusBar.Panels[3].Text = '') then
     StatusBar.Panels[3].Text := msgNova
  else
     StatusBar.Panels[3].Text := '';
end;

procedure TfrmPrincipal.ActCalendarioExecute(Sender: TObject);
var
  frmCalendario: TfrmCalendario;
begin
 frmCalendario := TfrmCalendario.Create(self);
 frmCalendario.Show;
 frmCalendario.Caption := LimpaCaption(Sender);
end;

procedure TfrmPrincipal.ActCalculadoraExecute(Sender: TObject);
var
 frmCalculadora : TfrmCalculadora;
begin
 frmCalculadora := TfrmCalculadora.Create(self);
 frmCalculadora.Show;
 frmCalculadora.mzCalc.SetFocus;
 frmCalculadora.Caption := LimpaCaption(Sender);
end;

procedure TfrmPrincipal.ActMensagemsExecute(Sender: TObject);
var
 sTemp : string;
begin
 sTemp := ' select '+
           '     nIDMensagem'+ASSQL+' Mensagem, '+
           '     sOrigem'+ASSQL+' Usuario, '+
           '     dHora'+ASSQL+' Hora '+
           ' from tbMensagem '+
           ' where '+
           {$IFDEF corporate}
           CODIGO_EMPRESA+' = '+sCodEmpresa+' and '+
           {$ENDIF}
           ' nIDUsuario = '+IntToStr(frmPrincipal.nCodUsuario)+
           ' order by dHora';

 AbreMensagens(sTemp);
end;

procedure TfrmPrincipal.ActAlteraSenhaExecute(Sender: TObject);
var
  frmAlteraSenha: TfrmAlteraSenha;
begin
  frmAlteraSenha := TfrmAlteraSenha.Create(self);
  frmAlteraSenha.ShowModal;
  with ActAlteraSenha do begin
    Visible := False;
    Enabled  := False;
  end;
end;


procedure TfrmPrincipal.ActAlteraLoginExecute(Sender: TObject);
var
 FormLogin : TFrmLogin;
begin
 FormLogin := TFrmLogin.Create(self);
 FormLogin.MudaLogin := True;
 {$IFDEF corporate}
  FormLogin.sCodEmpresa :=sCodEmpresa;
 {$ENDIF}
 FormLogin.ShowModal;
 StatusBar.Panels[0].Text := sNomeUsuario;
 AtualizaSeguranca;
 VerificaMensagem;
end;

procedure TfrmPrincipal.ActSairExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmPrincipal.ActSobreExecute(Sender: TObject);
var
  frmSplash : TfrmSplash;
begin
  frmSplash := TfrmSplash.Create(self);

  with frmSplash do begin
      LabelInfo.Caption := stCarregando;
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

procedure TfrmPrincipal.StatusBarDblClick(Sender: TObject);
begin
  if TimerPiscaMensagem.Enabled then ActMensagems.Execute;
end;

procedure TfrmPrincipal.ActConfiguracoesExecute(Sender: TObject);
begin
 AbreConfig;
end;

procedure TfrmPrincipal.ActGrupoExecute(Sender: TObject);
var
  frmGrupo: TfrmGrupo;
begin
  frmGrupo := TfrmGrupo.Create(self);
  frmGrupo.Show;
  with ActGrupo do begin
    Visible := False;
    Enabled  := False;
  end;
end;

procedure TfrmPrincipal.ActUsuariosExecute(Sender: TObject);
var
  frmUsuario: TfrmUsuario;
begin
  frmUsuario := TfrmUsuario.Create(self);
  {$IFDEF corporate}
     frmUsuario.sCodEmpresa := sCodEmpresa;
  {$ENDIF}
  frmUsuario.ShowModal;
  with ActUsuarios do begin
    Visible := False;
    Enabled  := False;
  end;
end;

procedure TfrmPrincipal.ActAjudaConteudoExecute(Sender: TObject);
begin
  Application.HelpFile := Caminho+'cadastral.HLP';
  Application.HelpSystem.ShowContextHelp(1, Application.HelpFile);
end;


end.
