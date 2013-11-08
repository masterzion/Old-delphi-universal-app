unit fomrMsg;

interface
{$include configura.inc}

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, principal, FMTBcd, DB, SqlExpr, QButtons,
  mzComboBoxClx, mzDBComboBoxClx, QMask, mzCustomEdit, mzNumEditclx,
  QExtCtrls, QComCtrls;

type
  TForm1 = class(TForm)
    Controle: TToolBar;
    btnEnviar: TToolButton;
    btnResponder: TToolButton;
    ToolButton8: TToolButton;
    btnFechar: TToolButton;
    PanelUsuario: TPanel;
    edtUsuario: TNumEditclx;
    edtData: TNumEditclx;
    Panel1: TPanel;
    Panel2: TPanel;
    ListBox1: TListBox;
    cmbUsuario: TmzDBComboBoxClx;
    cmbGrupo: TmzDBComboBoxClx;
    AddUsr: TSpeedButton;
    AddGrupo: TSpeedButton;
    DelUser: TSpeedButton;
    memoMsg: TMemo;
    SQLDataSe1: TSQLDataSet;
  private
    { Private declarations }
  {$IFDEF corporate}
    sCodEmpresa : string;
  {$ENDIF}
    nCodUsuario : Integer;
  public
    procedure Enviar(bEnviar:Boolean);
    { Public declarations }
  end;
var
  Form1: TForm1;

implementation

{$R *.xfm}

procedure TfrmMsg.Enviar(bEnviar:Boolean);
var
 InEnviar: Boolean;
begin
    InEnviar := not bEnviar;

    btnResponder.Enabled := InEnviar;
    btnResponder.Visible := InEnviar;

    PanelUsuario.Enabled := InEnviar;
    PanelUsuario.Visible := InEnviar;

    memoMsg.ReadOnly     := InEnviar;

    PanelEnviar.Enabled  := bEnviar;
    PanelEnviar.Visible  := bEnviar;

    btnEnviar.Enabled  := bEnviar;
    btnEnviar.Visible  := bEnviar;
end;



end.
 