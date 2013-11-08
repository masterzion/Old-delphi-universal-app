unit formPluginsAbout;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms, 
  QDialogs, QStdCtrls, QExtCtrls, QComCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Controle: TToolBar;
    btnFechar: TToolButton;
    TextBrowser1: TTextBrowser;
    procedure btnFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.xfm}

procedure TForm1.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 Action := caFree;
end;

end.
