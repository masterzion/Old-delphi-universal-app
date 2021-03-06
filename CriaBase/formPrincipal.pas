unit formPrincipal;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, QButtons, QComCtrls, QExtCtrls, IniFiles, DBXpress,
  DB, SqlExpr, FMTBcd, QCheckLst;

const
  ErroConectaBd : string = 'Erro ao conectar ao banco de dados!';
  AppName       : string = 'Universal';
type
  TfrmPrincipal = class(TForm)
    Panel1: TPanel;
    StatusBar1: TStatusBar;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Memo: TMemo;
    Query: TSQLQuery;
    PanelConecta: TPanel;
    ImgConectaErro: TImage;
    Label1: TLabel;
    ProgressBar1: TProgressBar;
    PanelApagaTabela: TPanel;
    Image7: TImage;
    ImgApagaErro: TImage;
    ImgApagaOK: TImage;
    chkApagarTabelas: TCheckBox;
    Image2: TImage;
    ImgAdicionaErro: TImage;
    ImgAdicionaOK: TImage;
    chkAdicionarDados: TCheckBox;
    PanelCriarTabela: TPanel;
    Image4: TImage;
    ImgCriaErro: TImage;
    ImgCriaOK: TImage;
    chkCriarTabelas: TCheckBox;
    PanelAdiciona: TPanel;
    ImgConectaOK: TImage;
    Image1: TImage;
    Panel5: TPanel;
    btnIniciar: TSpeedButton;
    btnSalvar: TSpeedButton;
    btnSair: TSpeedButton;
    Panel6: TPanel;
    chklstTabelas: TCheckListBox;
    Panel7: TPanel;
    Panel8: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SaveDialog: TSaveDialog;
    SQLConnection1: TSQLConnection;
    procedure btnIniciarClick(Sender: TObject);
    procedure btnSairClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure chkApagarTabelasClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure ImgConectaErroClick(Sender: TObject);
  private
    { Private declarations }
   Atual, nContaErro, nTotalErros : Integer;
   Apagando, bDebug : Boolean;
   Caminho, sLastError : string;
   sArquivo : TStringList;
   fLog : TextFile;
   procedure CarregaConfig;
   procedure Seleciona(Tipo:Boolean);
   function FiltraNome(nome:string):String;
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.xfm}

function TfrmPrincipal.FiltraNome(nome:string):String;
var
  sTemp : String;
begin
  sTemp := nome;
  delete(sTemp, 1, pos('_',sTemp) );
  Result := sTemp;
end;

procedure TfrmPrincipal.CarregaConfig;
var
 Ini       : TIniFile;
 strParams : TStringList;
 nIdioma   : Integer;
 sTemp     : string;
begin
  Ini := TIniFile.Create   ('mzconfig.ini');


  strParams := TStringList.Create;
  SQLConnection1.ConnectionName := AppName;
  sTemp := Ini.ReadString('db', 'DriverName', 'MySQL');
  with strParams do begin
    Add('DriverName'+'='+ sTemp );
    Add('HostName'+'='+   Ini.ReadString('db', 'HostName',   '127.0.0.1') );
    Add('Database'+'='+   Ini.ReadString('db', 'Database',   'cadastro') );
    Add('User_Name'+'='+  Ini.ReadString('db', 'User_Name',  'root') );
    Add('Password'+'='+   Ini.ReadString('db', 'Password',   '123') );
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

  if (sTemp = '') then
    Self.Bitmap := nil
  else
    if FileExists(sTemp) then
      Self.Bitmap.loadFromFile(sTemp)
     else
      Self.Bitmap := nil;

  Ini.Free;
end;



procedure TfrmPrincipal.btnIniciarClick(Sender: TObject);

  procedure Log(Linha:String; Cor:TColor);
  begin
     Memo.Lines.Add(Linha);
     Memo.SetFocus;
     Application.ProcessMessages;
  end;

  procedure PreparaErro(var Imagem:TImage);
  begin
    nTotalErros := nTotalErros+1;
    StatusBar1.SimpleText := 'Erros :'+IntToStr(nTotalErros);
    if not Imagem.Visible then Imagem.Visible := True;
    if Imagem.Tag = 0 then begin
      Memo.SelStart := Memo.SelStart-2;
      Imagem.Tag := Memo.SelStart;
    end;
    Application.ProcessMessages;
  end;

  procedure LogLinha;
  begin
     Log('', clNavy);
  end;

  procedure LogTracos;
  begin
      Log('---------------',clNavy);
  end;

  function AbreConsulta:Boolean;
  var
    sTemp : string;
  begin
    Result := False;
   try
    Query.ExecSQL;
    Log('Resultado: ok!!!', clTeal); ;
    Result := True;
   except
       on E : EDatabaseError do begin
         sTemp := 'Resultado:  ERRO!!!  '+E.Message;
         Log(sTemp, clRed);
         if bDebug then begin
             writeln(fLog, Query.SQL.Text);
             writeln(fLog, sTemp);
             writeln(fLog, '-----------------------------------');
         end;
       end;
   end;
  end;

  function AbreConsulta2:Boolean;
  begin
    Result := False;
   try
    Query.ExecSQL;
    Result := True;
   except
       on E : EDatabaseError do begin
         if bDebug then begin
             writeln(fLog, Query.SQL.Text);
             writeln(fLog, E.Message);
             writeln(fLog, '-----------------------------------');
         end
         else begin
           nContaErro  := nContaErro + 1;
           sLastError := E.Message;
         end;
       end;
   end;
  end;


  procedure ApagaTabela(Tabela:String);
  var
      sTemp : String;
  begin
   with Query do begin
      Log('+++ Excluindo "'+Tabela+'" +++', clBlack);
      sTemp := 'drop table '+FiltraNome(Tabela);
      Log(sTemp, clBlack);
      SQL.Text := sTemp;
      if not AbreConsulta then
        PreparaErro(ImgApagaErro);
      LogTracos;
   end;
  end;

  procedure CriaTabela(Tabela:String);
  var
    sTemp : String;
  begin
   Screen.Cursor := crHourGlass;
   LogLinha;
   LogLinha;
   sTemp := Caminho+'tabelas/'+Tabela+'.txt';


   if not FileExists(sTemp) then exit;
   sArquivo.LoadFromFile(sTemp);
    with Query do begin
      Log('+++ Criando "'+Tabela+'" +++', clTeal);
      sTemp := 'create table '+FiltraNome(Tabela)+' '+sArquivo.Text;
      log(sArquivo.Text,clNavy);
      SQL.Text := sTemp;
      LogTracos;
      Application.ProcessMessages;
      if not AbreConsulta then PreparaErro(ImgCriaErro);
    end;
   Screen.Cursor := crDefault;
  end;

  procedure AddData(Tabela:String);
  var
   sCabecalho  : String;
   n, nTemp : Integer;

  begin
   if (FileExists(Caminho+'data/'+Tabela+'.dbinf') and FileExists(Caminho+'data/'+Tabela+'.txt')) then begin
      nContaErro := 0;
      Screen.Cursor := crHourGlass;
      sArquivo.LoadFromFile(Caminho+'/data/'+Tabela+'.dbinf');

      sCabecalho := 'insert into '+FiltraNome(Tabela)+' '+sArquivo.Strings[0]+' values ';
      sArquivo.LoadFromFile(Caminho+'/data/'+Tabela+'.txt');

     ProgressBar1.Visible := True;
     nTemp := sArquivo.Count;
     ProgressBar1.Max := nTemp;
     Log('+++ Inserindo '+inttostr(nTemp)+' dados na tabela "'+Tabela+'" +++ ', clNavy);

     for n := 0 to nTemp-1 do begin
         ProgressBar1.Position := N;
         Query.SQL.Text := sCabecalho+ sArquivo.Strings[n];
         if not AbreConsulta2 then PreparaErro(ImgAdicionaErro);
        Application.ProcessMessages;
     end;

     if (not bDebug) and (nContaErro > 0) then  Log('Resultado:  ERRO!!!  '+sLastError, clRed);
     sArquivo.Clear;
     ProgressBar1.Visible := False;
     Log('Concluido!!!',clNavy);
     Screen.Cursor := crDefault;
   end;
  end;

    procedure PreparaControles(Tipo, Imagens:Boolean);
    begin
      //Oculta Imagens....
      if Imagens then begin
        ImgConectaOK.Visible   := Tipo;
        ImgApagaOK.Visible     := Tipo;
        ImgCriaOK.Visible      := Tipo;
        ImgAdicionaOK.Visible  := Tipo;

        ImgConectaErro.Visible   := Tipo;
        ImgApagaErro.Visible     := Tipo;
        ImgCriaErro.Visible      := Tipo;
        ImgAdicionaErro.Visible  := Tipo;
      end;

      //Desabilita Controles
      btnIniciar.Enabled := Tipo;
      btnSalvar.Enabled  := Tipo;
      btnSair.Enabled    := Tipo;

      chkApagarTabelas.Enabled  := Tipo;
      chkCriarTabelas.Enabled   := Tipo;
      chkAdicionarDados.Enabled := Tipo;
      chklstTabelas.Enabled     := Tipo;
    end;

var
  n : Integer;

begin
    if bDebug then begin
      Assignfile(fLog, caminho+'err.log');
      rewrite(fLog);
    end;

    nTotalErros := 0;
    Memo.Clear;
    StatusBar1.SimpleText := '';
    Log('------=============================------', clNavy);
    Log('------========= Iniciando =========------', clNavy);
    Log('------=============================------', clNavy);
    Atual := 0;


    LogLinha;
    LogLinha;
    Log('Preparando....', clNavy);
    PreparaControles(False,True);

    sArquivo := TStringList.Create;

    sArquivo.Clear;
    Log('', clNavy);
    Log('', clNavy);
    Log('+++ Conectando a base de dados +++', clNavy);
    Query.SQL.Text := ' select (1 = 1) as teste ';
    if not AbreConsulta then begin
      PreparaErro(ImgConectaErro);
      PreparaControles(True,False);
      exit;
    end;
    ImgConectaOK.Visible := True;
    LogLinha;
    LogLinha;
    Application.ProcessMessages;


    // ******      Apaga Tabelas      ******
    if chkApagarTabelas.Checked then begin
      for n := 0 to chklstTabelas.Items.Count-1 do
        if chklstTabelas.Checked[n] then
          ApagaTabela( chklstTabelas.Items.Strings[n] );
      ImgApagaOK.Visible := True;
      Application.ProcessMessages;
    end;

    // ****** Tabelas a serem criadas ******
    if chkCriarTabelas.Checked then begin
      for n := 0 to chklstTabelas.Items.Count-1 do
        if chklstTabelas.Checked[n] then
          CriaTabela(chklstTabelas.Items.Strings[n]);
      ImgCriaOK.Visible := True;
      Application.ProcessMessages;
    end;


    // *********  Adiciona Dados *********
    if chkAdicionarDados.Checked then begin
      for n := 0 to chklstTabelas.Items.Count-1 do
        if chklstTabelas.Checked[n] then
         AddData( chklstTabelas.Items.Strings[n] );
        ImgAdicionaOK.Visible := True;
      Application.ProcessMessages;
    end;

    PreparaControles(True,False);
    //   ******         Fim          ******


    LogLinha;
    LogLinha;
    Log('Total de Erros: '+IntToStr(nTotalErros), clRed);
    LogLinha;
    LogLinha;
    LogLinha;
    if bDebug then CloseFile(fLog);
    Log('------========= Concluido!!! =========------', clNavy);
end;





procedure TfrmPrincipal.btnSairClick(Sender: TObject);
begin
 Close;
end;

procedure TfrmPrincipal.btnSalvarClick(Sender: TObject);
begin
  if SaveDialog.Execute then Memo.Lines.SaveToFile(SaveDialog.FileName);
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
var
 sr:TSearchRec;
 Arquivo, sTemp : string;
begin
  bdebug := (paramstr(1) = '--debug');
//  CarregaConfig;
  chklstTabelas.Clear;
  Caminho := ExtractFilePath(Application.ExeName);
  FindFirst(Caminho+'tabelas/*.txt', faAnyFile, SR);
  while not (Arquivo = SR.Name) do begin
    sTemp := SR.Name;
    if (sTemp <> '.') and (sTemp <> '..') then
      chklstTabelas.Items.Add(copy(ExtractFileName(sTemp), 0, length(sTemp)-4));
    Arquivo:=SR.Name;
    FindNext(SR);
  end;
  Seleciona(True);
  Apagando := True;
end;

procedure TfrmPrincipal.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 Application.Terminate;
end;

procedure TfrmPrincipal.chkApagarTabelasClick(Sender: TObject);
begin
if chkApagarTabelas.Checked then
 if Apagando then begin
   chkApagarTabelas.Checked := (MessageDlg('Isso excluira todos os dados das tabelas!'+#13+ 'Deseja Continuar?', mtWarning, [mbYes, mbNo], 0) = mrYes);
   Apagando := False;
 end;
end;

procedure TfrmPrincipal.Seleciona(Tipo:Boolean);
var
 n : Integer;
begin
  for n := 0 to chklstTabelas.Items.Count-1 do
    chklstTabelas.Checked[n] := Tipo;
end;



procedure TfrmPrincipal.SpeedButton1Click(Sender: TObject);
begin
 Seleciona(True);
end;

procedure TfrmPrincipal.SpeedButton2Click(Sender: TObject);
begin
 Seleciona(False);
end;

procedure TfrmPrincipal.ImgConectaErroClick(Sender: TObject);
begin
  Memo.SelStart := (Sender as TImage).Tag;
  Memo.SetFocus;
end;

end.

