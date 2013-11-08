unit Unit1;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, DCPcrypt2, DCPrc4, DCPsha1, DCPmd5;

var
  senha :string = 'teste';

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    DCP_RC4: TDCP_rc4;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.xfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  DCP_RC4.InitStr(senha, TDCP_md5);
  Memo1.Lines.Text := DCP_RC4.EncryptString(Memo1.Lines.Text);
  DCP_RC4.Burn;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  DCP_RC4.InitStr(senha, TDCP_md5);
  Memo1.Lines.Text := DCP_RC4.DecryptString(Memo1.Lines.Text);
  DCP_RC4.Burn;
end;

end.
