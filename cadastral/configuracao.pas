unit configuracao;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QStdCtrls, QButtons, QComCtrls, QExtCtrls,
  IniFiles, QStyle {$IFDEF LINUX}, Libc {$ENDIF}, NumEditclx  ;

type
  TfrmConfiguracao = class(TForm)
    PageControl1: TPageControl;
    Panel1: TPanel;
    TabSheet1: TTabSheet;
    BitBtn1: TBitBtn;
    ComboBox1: TComboBox;
    Label1: TLabel;
    TabSheet2: TTabSheet;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    ComboBox2: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    ComboBox3: TComboBox;
    Label4: TLabel;
    NumEditCLX1: TNumEditCLX;
    Label5: TLabel;
    NumEditCLX2: TNumEditCLX;
    NumEditCLX3: TNumEditCLX;
    Label6: TLabel;
    TabSheet3: TTabSheet;
    Label8: TLabel;
    Label9: TLabel;
    NumEditCLX5: TNumEditCLX;
    NumEditCLX6: TNumEditCLX;
    Label10: TLabel;
    BitBtn4: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
  private
    Ini: TIniFile;
    Home : String;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmConfiguracao: TfrmConfiguracao;

implementation

uses principal;

{$R *.xfm}

procedure TfrmConfiguracao.FormCreate(Sender: TObject);
var
 n : TDefaultStyle;
 {$IFDEF LINUX}
   info :PPasswordRecord;
 {$ENDIF}
begin
{$IFDEF MSWINDOWS}
  Ini := TIniFile.Create('mzconfig.ini');
{$ENDIF}

{$IFDEF LINUX}
  info := getpwuid(getuid);
  with info^ do Home := String(pw_dir);
  Ini := TIniFile.Create(Home+'/mzconfig.ini');
{$ENDIF}

 For n := low(TDefaultStyle) to High(TDefaultStyle) do
   if (cStyles[n] <> '') then ComboBox1.Items.Add(cStyles[n]);

 ComboBox1.ItemIndex := Ini.ReadInteger('Aparencia', 'Estilo', 0);
 Ini.Free;
end;

procedure TfrmConfiguracao.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  with frmPrincipal.Configurcoes1 do begin
    Visible := True;
    Enabled  := True;
  end;
  Action := caFree;
end;

procedure TfrmConfiguracao.BitBtn1Click(Sender: TObject);
begin
 Close;
end;

procedure TfrmConfiguracao.BitBtn2Click(Sender: TObject);
begin
 Application.Style.DefaultStyle := TDefaultStyle(ComboBox1.ItemIndex);
end;

procedure TfrmConfiguracao.BitBtn3Click(Sender: TObject);
var
 F:TextFile;
begin
 try
  {$IFDEF MSWINDOWS}
    Ini := TIniFile.Create('mzconfig.ini');
    Ini.WriteString('Aparencia', 'Estilo', inttostr(ComboBox1.ItemIndex));
    Ini.Free;
  {$ENDIF}

  {$IFDEF LINUX}
    AssignFile(F, Home+'/mzconfig.ini');
    if FileExists(Home+'/mzconfig.ini') then erase(F);
    Rewrite(F);
    Writeln(F, '[Aparencia]');
    Writeln(F, 'Estilo=' + inttostr(ComboBox1.ItemIndex));
    CloseFile(F);
  {$ENDIF}

  except On E:Exception do
    ShowMessage(concat('Erro! ',E.ClassName, ' : ', E.Message));
  end;
end;

end.
