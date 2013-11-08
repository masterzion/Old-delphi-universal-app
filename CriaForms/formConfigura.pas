unit formConfigura;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, principal, QMask, mzCustomEdit, mzNumEditclx,
  mzComboBoxClx, QComCtrls, IniFiles, QStyle, mzCustomBtnEditclx,mzlib,
  mzFileEdit;

type
  TfrmConfigura = class(TForm)
    Controle: TToolBar;
    btnSalvar: TToolButton;
    ToolButton8: TToolButton;
    btnFechar: TToolButton;
    PageControl1: TPageControl;
    TabDB: TTabSheet;
    TabSheetAparencia: TTabSheet;
    cmbDriverName: TmzComboBoxClx;
    edtHost: TNumEditclx;
    edtDataBase: TNumEditclx;
    edtUserName: TNumEditclx;
    edtPass: TNumEditclx;
    cmbEstilo: TmzComboBoxClx;
    cmbIdioma: TmzComboBoxClx;
    fdWallPaper: TmzFileEdit;
    procedure btnSalvarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure SalvaConfig;
    procedure CarregaConfig;
  public
    { Public declarations }
  end;

var
  frmConfigura: TfrmConfigura;

implementation

{$R *.xfm}

procedure TfrmConfigura.CarregaConfig;
var
 Ini       : TIniFile;
begin
  Ini := TIniFile.Create   ('mzconfig.ini');
  edtHost.Text        := Ini.ReadString('db', 'HostName',   'localhost');
  edtDataBase.Text    := Ini.ReadString('db', 'Database',   'cadastro');
  edtUserName.Text    := Ini.ReadString('db', 'User_Name',  'root');
  edtPass.Text        := frmPrincipal.Descodificar(Ini.ReadString('db', 'Password',   '123'));
  cmbEstilo.ItemIndex := Ini.ReadInteger ('Aparencia', 'Estilo', 1);
  cmbIdioma.ItemIndex := Ini.ReadInteger ('Aparencia', 'Idioma', 1);
  fdWallPaper.Text    := Ini.ReadString  ('Aparencia', 'WallPaper', '');
  Ini.ReadString('db', 'DriverName', 'MySQL');
  Ini.Destroy;
end;


procedure TfrmConfigura.SalvaConfig;
var
 Ini       : TIniFile;
begin
  Ini := TIniFile.Create   ('mzconfig.ini');
  Ini.WriteString('db', 'DriverName', cmbDriverName.Text);
  Ini.WriteString('db', 'HostName',   edtHost.Text);
  Ini.WriteString('db', 'Database',   edtDataBase.Text);
  Ini.WriteString('db', 'User_Name',  edtUserName.Text);
  Ini.WriteString('db', 'Password',   frmPrincipal.Codificar(edtPass.Text));

  Ini.WriteInteger('Aparencia', 'Estilo', cmbEstilo.ItemIndex);
  Ini.WriteInteger('Aparencia', 'Idioma', cmbIdioma.ItemIndex);
  Ini.WriteString('Aparencia', 'WallPaper', fdWallPaper.Text);

  Ini.Destroy;
end;

procedure TfrmConfigura.btnSalvarClick(Sender: TObject);
begin
  SalvaConfig;
  frmPrincipal.CarregaConfig;
  try
    frmPrincipal.SQLConnection1.Connected := False;
    frmPrincipal.SQLConnection1.Connected := True;
    frmPrincipal.CarregaMenu;
    CarregaConfig;
  except
    ShowMessage(ErroConectaBD);
  end;
end;

procedure TfrmConfigura.FormCreate(Sender: TObject);
var
 I : TDefaultStyle;
begin
  PageControl1.ActivePage := TabDB;
  cmbEstilo.Clear;

  for i := low(TDefaultStyle)  to High(TDefaultStyle) do
    if (cStyles[i] <> '') then
      cmbEstilo.Items.Add(cStyles[i]);

  cmbDriverName.ItemIndex := 0;
  cmbEstilo.ItemIndex     := 0;
  cmbIdioma.ItemIndex     := 0;
  CarregaConfig;
  fdWallPaper.DialogTitle := sAbrir;

end;

procedure TfrmConfigura.btnFecharClick(Sender: TObject);
begin
 Close;
end;

procedure TfrmConfigura.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if frmPrincipal.SQLConnection1.Connected then
    Action := caFree
  else
    Application.Terminate;
end;

end.
