unit formSplash;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, QExtCtrls, QButtons;

const
  ESPACOS : string = '                                                                                                                  ';

type
  TfrmSplash = class(TForm)
    Panel1: TPanel;
    ImageSplash: TImage;
    LabelInfo: TLabel;
    LabelEdition: TLabel;
    LabelVersion: TLabel;
    btnFechar: TSpeedButton;
    Timer1: TTimer;
    procedure btnFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    Texto : string;
  public
    { Public declarations }
    Registro : string;
  end;

var
  frmSplash: TfrmSplash;

implementation

{$R *.xfm}

procedure TfrmSplash.btnFecharClick(Sender: TObject);
begin
 Close;
end;

procedure TfrmSplash.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 Timer1.Enabled := False;
 Action := caFree;
end;

procedure TfrmSplash.Timer1Timer(Sender: TObject);
begin
  if (Length(Texto) = 0) then
    Texto := ESPACOS+Registro
  else
    Texto := copy(Texto, 2, Length(Texto));

  LabelInfo.Caption := Texto;
end;

end.
