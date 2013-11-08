unit formCalculadora;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, principal, mzCalcEdit, QComCtrls, QExtCtrls, mzlib;

type
  TfrmCalculadora = class(TForm)
    Controle: TToolBar;
    btnFechar: TToolButton;
    ListBox: TListBox;
    btnLimpar: TToolButton;
    Panel1: TPanel;
    mzCalc: TmzCalc;
    ToolButton1: TToolButton;
    procedure btnFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnLimparClick(Sender: TObject);
    procedure mzCalcEndCalc(Calc: String);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCalculadora: TfrmCalculadora;

implementation

{$R *.xfm}

procedure TfrmCalculadora.btnFecharClick(Sender: TObject);
begin
 Close;
end;

procedure TfrmCalculadora.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmCalculadora.btnLimparClick(Sender: TObject);
begin
 ListBox.Clear;
end;

procedure TfrmCalculadora.mzCalcEndCalc(Calc: String);
begin
  ListBox.Items.Add(Calc);
  ListBox.Refresh;
  ListBox.Itemindex := ListBox.Items.Count-1;
  ListBox.ScrollBy(0, ListBox.Items.Count*10);
end;

procedure TfrmCalculadora.FormCreate(Sender: TObject);
begin
 mzCalc.Clear;
end;

end.
