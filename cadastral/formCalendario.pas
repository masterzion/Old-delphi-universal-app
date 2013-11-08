unit formCalendario;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, Principal, mzDatePicker, QComCtrls, mzlib;

type
  TfrmCalendario = class(TForm)
    Controle: TToolBar;
    btnFechar: TToolButton;
    mzCalendar: TmzCalendar;
    procedure FormCreate(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mzCalendarDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCalendario: TfrmCalendario;

implementation

{$R *.xfm}

procedure TfrmCalendario.FormCreate(Sender: TObject);
begin
  mzCalendar.TodayLabelCaption := sHOJE+':';
  mzCalendar.Date := now;
end;

procedure TfrmCalendario.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCalendario.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmCalendario.mzCalendarDblClick(Sender: TObject);
var
 sTemp : string;
begin
 sTemp :=  ' select '+
           '     nIDMensagem'+ASSQL+' Mensagem, '+
           '     sOrigem'+ASSQL+' Usuario, '+
           '     dHora'+ASSQL+' Hora '+
           ' from tbMensagem '+
           ' where '+
           {$IFDEF corporate}
           CODIGO_EMPRESA+' = '+sCodEmpresa+' and '+
           {$ENDIF}
           ' nIDUsuario = '+IntToStr(frmPrincipal.nCodUsuario)+
           ' and '+sDateAntes+'dHora'+sDateDepois+' = '+S_AP+datetostr(mzCalendar.Date)+S_AP;

 frmPrincipal.AbreMensagens(sTemp);
end;


end.
