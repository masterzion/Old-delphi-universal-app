unit ullistats;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  rpcompobase, rpvclreport, rpalias, StdCtrls;

type
  TFLlistats = class(TForm)
    RpAlias1: TRpAlias;
    llistat: TVCLReport;
    ELlistats: TListBox;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure mostrallistats;

implementation

{$R *.DFM}

procedure mostrallistats;
var
 dia:TFLlistats;
begin
 dia:=TFLlistats.Create(Application);
 try
  dia.showmodal;
 finally
  dia.free;
 end;
end;


procedure TFLlistats.Button1Click(Sender: TObject);
begin
 case ELlistats.ItemIndex of
  0:
   LListat.ReportName:='Resum tracables';
  1:
   LListat.ReportName:='Detalle sin lote';
  2:
   Llistat.ReportName:='Resum guies sense carga';
 end;
 if llistat.ShowParams then
  llistat.Execute;
end;

end.
