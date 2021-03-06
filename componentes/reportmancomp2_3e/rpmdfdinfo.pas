{*******************************************************}
{                                                       }
{       Report Manager                                  }
{                                                       }
{       Rpmdfdinfo                                      }
{                                                       }
{       Copyright (c) 1994-2003 Toni Martir             }
{       toni@pala.com                                   }
{                                                       }
{       This file is under the MPL license              }
{       If you enhace this file you must provide        }
{       source code                                     }
{                                                       }
{                                                       }
{*******************************************************}
unit rpmdfdinfo;

interface

{$I rpconf.inc}

uses
 Classes,sysutils,QDialogs,QControls,QGraphics,QForms,rpmdconsts,
{$IFDEF USEVARIANTS}
 types,
{$ENDIF}
 rptypes,rpdatainfo,rpreport,
 rpmdfdatasets,rpmdfconnection,
 QStdCtrls, QExtCtrls,QComCtrls;

type
  TFRpDInfo = class(TForm)
    PBottom: TPanel;
    BOk: TButton;
    BCancel: TButton;
    PControl: TPageControl;
    TabConnections: TTabSheet;
    TabDatasets: TTabSheet;
    procedure FormCreate(Sender: TObject);
    procedure PControlChange(Sender: TObject);
    procedure BOkClick(Sender: TObject);
    procedure BCancelClick(Sender: TObject);
  private
    { Private declarations }
    freport:TRpReport;
    fdatasets:TFRpDatasets;
    fconnections:TFRpConnection;
    procedure SetReport(value:TRpReport);
  public
    { Public declarations }
    property report:TRpReport read FReport write SetReport;
  end;


procedure ShowDataConfig(report:TRpReport);


implementation

uses rpdbxconfig;


{$R *.xfm}

procedure TFRpDInfo.SetReport(value:TRpReport);
begin
 freport:=value;
 fconnections:=TFRpConnection.Create(Self);
 fconnections.Parent:=TabConnections;
 fdatasets:=TFRpDatasets.Create(Self);
 fdatasets.Parent:=TabDatasets;
 fdatasets.Datainfo:=report.DataInfo;
 fdatasets.Databaseinfo:=report.DatabaseInfo;
 fconnections.Databaseinfo:=report.DatabaseInfo;
 fdatasets.params:=report.params;
 if report.DatabaseInfo.Count>0 then
  PControl.ActivePage:=TabDatasets
 else
  PControl.ActivePage:=TabConnections;
end;

procedure ShowDataConfig(report:TRpReport);
var
 dia:TFRpDInfo;
begin
 dia:=TFRpDInfo.Create(Application);
 try
  dia.report:=report;
  dia.showmodal;
 finally
  dia.free;
 end;
end;



procedure TFRpDInfo.FormCreate(Sender: TObject);
begin
 BOK.Caption:=TranslateStr(93,BOK.Caption);
 BCancel.Caption:=TranslateStr(94,BCancel.Caption);
 Caption:=TranslateStr(1097,Caption);
 TabConnections.Caption:=TranslateStr(142,TabConnections.Caption);
 TabDatasets.Caption:=TranslateStr(148,TabDatasets.Caption);

 SetInitialBounds;
end;






procedure TFRpDInfo.PControlChange(Sender: TObject);
begin
 fdatasets.Databaseinfo:=fconnections.DatabaseInfo;
end;

procedure TFRpDInfo.BOkClick(Sender: TObject);
begin
 fdatasets.Databaseinfo:=fconnections.Databaseinfo;
 freport.DatabaseInfo.Assign(fdatasets.Databaseinfo);
 freport.DataInfo.Assign(fdatasets.Datainfo);
 freport.Params.Assign(fdatasets.Params);
 Close;
end;

procedure TFRpDInfo.BCancelClick(Sender: TObject);
begin
 Close;
end;

end.

