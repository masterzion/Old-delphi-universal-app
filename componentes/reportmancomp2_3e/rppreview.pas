{*******************************************************}
{                                                       }
{       Report Manager                                  }
{                                                       }
{       rppreview                                       }
{       Preview the report                              }
{                                                       }
{                                                       }
{       Copyright (c) 1994-2002 Toni Martir             }
{       toni@pala.com                                   }
{                                                       }
{       This file is under the MPL license              }
{       If you enhace this file you must provide        }
{       source code                                     }
{                                                       }
{                                                       }
{*******************************************************}

unit rppreview;

interface

{$I rpconf.inc}

uses
  SysUtils,
{$IFDEF MSWINDOWS}
  windows,
{$ENDIF}
{$IFDEF LINUX}
  Libc,
{$ENDIF}
  Types, Classes, QGraphics, QControls, QForms, QDialogs,
  QStdCtrls,rpbasereport,rpreport,rpmetafile, QComCtrls,
  rpqtdriver, QExtCtrls,rptypes,rptextdriver,rphtmldriver,
  rppagesetup,rpsvgdriver,rpcsvdriver,
  QActnList, QImgList,QPrinters,rpmdconsts,Qt, QMask, rpmaskeditclx;


type
  TFRpPreview = class(TForm)
    BToolBar: TToolBar;
    ImageContainer: TScrollBox;
    AImage: TImage;
    ImageList1: TImageList;
    ActionList1: TActionList;
    AFirst: TAction;
    APrevious: TAction;
    ANext: TAction;
    ALast: TAction;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    EPageNum: TRpCLXMaskEdit;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    APrint: TAction;
    ToolButton6: TToolButton;
    ASave: TAction;
    SaveDialog1: TSaveDialog;
    ToolButton7: TToolButton;
    ACancel: TAction;
    BCancel: TButton;
    PBar: TProgressBar;
    AExit: TAction;
    BExit: TToolButton;
    ToolButton8: TToolButton;
    AParams: TAction;
    AScale100: TAction;
    AScaleWide: TAction;
    AScaleFull: TAction;
    AScaleLess: TAction;
    AScaleMore: TAction;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton5: TToolButton;
    ToolButton10: TToolButton;
    ToolButton9: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    APageSetup: TAction;
    AMailTo: TAction;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton18: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure AFirstExecute(Sender: TObject);
    procedure ANextExecute(Sender: TObject);
    procedure APreviousExecute(Sender: TObject);
    procedure ALastExecute(Sender: TObject);
    procedure EPageNumKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure APrintExecute(Sender: TObject);
    procedure ASaveExecute(Sender: TObject);
    procedure BCancelClick(Sender: TObject);
    procedure ACancelExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AExitExecute(Sender: TObject);
    procedure AParamsExecute(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure AScale100Execute(Sender: TObject);
    procedure AScaleWideExecute(Sender: TObject);
    procedure AScaleFullExecute(Sender: TObject);
    procedure AScaleLessExecute(Sender: TObject);
    procedure AScaleMoreExecute(Sender: TObject);
    procedure AImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure ImageContainerMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure AMailToExecute(Sender: TObject);
    procedure APageSetupExecute(Sender: TObject);
  private
    { Private declarations }
    cancelled:boolean;
    printed:boolean;
    enableparams:boolean;
    fmodified:Boolean;
{$IFDEF LINUX}
    usekprinter:boolean;
{$ENDIF}
    procedure AppIdle(Sender:TObject;var done:boolean);
    procedure RepProgress(Sender:TRpBaseReport;var docancel:boolean);
    procedure MetProgress(Sender:TRpMetafileReport;Position,Size:int64;page:integer);
    procedure DisableControls(enablebar:boolean);
    procedure EnableControls;
    procedure PlaceImagePosition;
  public
    { Public declarations }
    systemprintdialog:boolean;
    pagenum:integer;
    report:TRpReport;
    qtdriver:TRpQtDriver;
    aqtdriver:IRpPrintDriver;
    bitmap:TBitmap;
    procedure PrintPage;
    property modified:Boolean read fmodified;
  end;


function ShowPreview(report:TRpReport;caption:string;systemprintdialog:boolean;var modified:boolean):boolean;

implementation

uses rprfparams,
    rpprintdia,
    rppdfdriver;

{$R *.xfm}

function ShowPreview(report:TRpReport;caption:string;systemprintdialog:boolean;var modified:boolean):boolean;
var
 dia:TFRpPreview;
 oldprogres:TRpProgressEvent;
 hasparams:boolean;
 i:integer;
begin
 modified:=false;
 dia:=TFRpPreview.Create(Application);
 try
  dia.caption:=caption;
  oldprogres:=report.OnProgress;
  try
   dia.report:=report;
   hasparams:=false;
   for i:=0 to report.params.count-1 do
   begin
    if report.params.items[i].Visible then
    begin
     hasparams:=true;
     break;
    end;
   end;
   dia.systemprintdialog:=systemprintdialog;
   dia.AParams.Enabled:=hasparams;
   dia.enableparams:=hasparams;
   dia.AScale100.Checked:=False;
   dia.AScaleFull.Checked:=False;
   dia.AScaleWide.Checked:=False;
   case report.PreviewStyle of
    spNormal:
     begin
      dia.AScale100.Checked:=True;
      dia.qtdriver.PreviewStyle:=spNormal;
     end;
    spEntirePage:
     begin
      dia.AScaleFull.Checked:=True;
      dia.qtdriver.PreviewStyle:=spEntirePage;
     end
    else
      dia.AScaleWide.Checked:=True;
   end;
   report.OnProgress:=dia.RepProgress;
   Application.OnIdle:=dia.AppIdle;
   dia.ShowModal;
   modified:=dia.Modified;
   Result:=dia.printed;
  finally
   report.OnProgress:=oldprogres;
  end;
 finally
  dia.Free;
 end;
end;

procedure TFRpPreview.PrintPage;
var
 oldwidth,oldheight:integer;
begin
 oldwidth:=AImage.Width;
 oldheight:=AImage.Height;
 try
  if report.Metafile.PageCount>=pagenum then
  begin
   report.Metafile.CurrentPage:=pagenum-1;
  end
  else
  begin
   if Not report.LastPage then
   begin
    cancelled:=false;
    DisableControls(false);
    try
     while report.Metafile.PageCount<pagenum do
     begin
      // Can be canceled
      if report.PrintNextPage then
      begin
       report.EndPrint;
       break;
      end;
     end;
    finally
     EnableControls;
    end;
   end;
   if report.Metafile.PageCount<pagenum then
    pagenum:=report.Metafile.PageCount;
   report.Metafile.CurrentPage:=pagenum-1;
  end;
  report.metafile.DrawPage(qtdriver);
  if Assigned(qtdriver.bitmap) then
  begin
   AImage.Width:=Round(qtdriver.bitmap.Width);
   AImage.Height:=Round(qtdriver.bitmap.Height);
   AImage.Picture.Bitmap.Assign(qtdriver.bitmap);
   AImage.Invalidate;
  end;
  EPageNum.Text:=IntToStr(PageNum);
 except
  EPageNum.Text:='0';
  raise;
 end;
 if ((oldwidth<>AImage.Width) or (oldheight<>AImage.Height)) then
  PlaceImagePosition;
end;

procedure TFRpPreview.AppIdle(Sender:TObject;var done:boolean);
var
 drivername:string;
 istextonly:boolean;
begin
 done:=false;
 Application.OnIdle:=nil;
 try
  drivername:=Trim(GetPrinterEscapeStyleDriver(report.PrinterSelect));
  istextonly:=Length(drivername)>0;
  if istextonly then
  begin
   qtdriver.FontDriver:=TRpTextDriver.Create;
  end;
  if report.PreviewWindow=spwMaximized then
   WindowState:=wsMaximized;
  report.OnProgress:=RepProgress;
  DisableControls(false);
  if report.TwoPass then
  begin
   if Not CalcReportWidthProgress(report) then
    SysUtils.Abort;
  end
  else
  begin
   report.BeginPrint(qtdriver);
  end;
  pagenum:=1;
  qtdriver.NewDocument(report.Metafile,1,false);
  PrintPage;
  printed:=true;
  EnableControls;
  ActiveControl:=EPageNum;
 except
  on E:Exception do
  begin
   Close;
   Raise;
  end;
 end;
end;

procedure TFRpPreview.FormCreate(Sender: TObject);
begin
{$IFDEF LINUX}
 usekprinter:=GetEnvironmentVariable('REPMANUSEKPRINTER')='true';
{$ENDIF}


 BToolBar.ButtonHeight:=EPageNum.Height;
 APrevious.ShortCut:=Key_PageUp;
 ANext.ShortCut:=Key_PageDown;
 AFirst.ShortCut:=Key_Home;
 ALast.ShortCut:=Key_End;
 qtdriver:=TRpQtDriver.Create;
 aqtdriver:=qtdriver;
 bitmap:=TBitmap.Create;
 bitmap.PixelFormat:=pf32bit;
 AImage.Picture.Bitmap:=bitmap;
{$IFDEF VCLFILEFILTERS}
 SaveDialog1.Filter:=SRpRepMetafile+'|*.rpmf|'+
   SRpPDFFile+'|*.pdf|'+
   SRpPDFFileUn+'|*.pdf|'+
   SRpPlainFile+'|*.txt|'+
   SRpBitmapFile+'|*.bmp|'+
   SRpHtmlFile+'|*.html|'+
   SRpSVGFile+'|*.svg|'+
   SRpCSVFile+'|*.csv|'+
   SRpTXTProFile+'|*.txt';
{$IFDEF MSWINDOWS}
 SaveDialog1.Filter:=SaveDialog1.Filter+'|'+SRpExeMetafile+'|*.exe';
{$ENDIF}
{$ENDIF}
{$IFNDEF VCLFILEFILTERS}
 SaveDialog1.Filter:=SRpRepMetafile+' (*.rpmf)|'+
   SRpPDFFile+' (*.pdf)|'+
   SRpPDFFileUn+' (*.pdf)|'+
   SRpPlainFile+' (*.txt)|'+
   SRpBitmapFile+' (*.bmp)|'+
   SRpHtmlFile+' (*.html)|'+
   SRpSVGFile+' (*.svg)|'+
   SRpCSVFile+' (*.csv)|'+
   SRpTXTProFile+' (*.txt)';
{$IFDEF MSWINDOWS}
  SaveDialog1.Filter:=SaveDialog1.Filter+'|'+SRpExeMetafile+' (*.exe)';
{$ENDIF}
{$ENDIF}

 Caption:=TranslateStr(215,Caption);
 SaveDialog1.Title:=TranslateStr(216,SaveDialog1.Title);
 ACancel.Caption:=TranslateStr(94,ACancel.Caption);
 ACancel.Hint:=TranslateStr(218,ACancel.Hint);
 APrint.Caption:=TranslateStr(52,APrint.Caption);
 APrint.Hint:=TranslateStr(53,APrint.Hint);
 ASave.Caption:=TranslateStr(46,ASave.Caption);
 ASave.Hint:=TranslateStr(217,ASave.Hint);
 AMailTo.Caption:=TranslateStr(1230,AMailTo.Caption);
 AMailTo.Hint:=TranslateStr(1231,AMailTo.Hint);
 AExit.Caption:=TranslateStr(44,AExit.Caption);
 AExit.Hint:=TranslateStr(219,AExit.Hint);
 AParams.Caption:=TranslateStr(135,Aparams.Caption);
 AParams.Hint:=TranslateStr(136,Aparams.Hint);
 AFirst.Caption:=TranslateStr(220,AFirst.Caption);
 AFirst.Hint:=TranslateStr(221,AFirst.Hint);
 APrevious.Caption:=TranslateStr(222,APrevious.Caption);
 APrevious.Hint:=TranslateStr(223,APrevious.Hint);
 ANext.Caption:=TranslateStr(224,ANext.Caption);
 ANext.Hint:=TranslateStr(225,ANext.Hint);
 ALast.Caption:=TranslateStr(226,ALast.Caption);
 ALast.Hint:=TranslateStr(227,ALast.Hint);
 AScale100.Caption:=TranslateStr(228,AScale100.Caption);
 AScale100.Hint:=TranslateStr(229,AScale100.Hint);
 AScaleWide.Caption:=TranslateStr(230,AScaleWide.Caption);
 AScaleWide.Hint:=TranslateStr(231,AScaleWide.Hint);
 AScaleFull.Caption:=TranslateStr(232,AScaleFull.Caption);
 AScaleFull.Hint:=TranslateStr(233,AScaleFull.Hint);
 AScaleLess.Caption:=TranslateStr(234,AScaleLess.Caption);
 AScaleLess.Hint:=TranslateStr(235,AScaleLess.Hint);
 AScaleMore.Caption:=TranslateStr(236,AScaleMore.Caption);
 AScaleMore.Hint:=TranslateStr(237,AScaleMore.Hint);
 APageSetup.Caption:=TranslateStr(50,APageSetup.Caption);
 APageSetup.Hint:=TranslateStr(51,APageSetup.Hint);

 ActiveControl:=EPageNum;


 SaveDialog1.FilterIndex:=2;
 SetInitialBounds;
end;

procedure TFRpPreview.FormDestroy(Sender: TObject);
begin
 report.EndPrint;
 bitmap.free;
 qtdriver.free;
end;

procedure TFRpPreview.AFirstExecute(Sender: TObject);
begin
 pagenum:=1;
 PrintPage;
end;

procedure TFRpPreview.ANextExecute(Sender: TObject);
begin
 inc(pagenum);
 PrintPage;
end;

procedure TFRpPreview.APreviousExecute(Sender: TObject);
begin
 dec(pagenum);
 if pagenum<1 then
  pagenum:=1;
 PrintPage;
end;

procedure TFRpPreview.ALastExecute(Sender: TObject);
begin
 pagenum:=MaxInt;
 PrintPage;
end;

procedure TFRpPreview.EPageNumKeyPress(Sender: TObject; var Key: Char);
begin
 if Key=chr(13) then
 begin
  pagenum:=StrToInt(EPageNum.Text);
  PrintPage;
 end;
end;

procedure TFRpPreview.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 qtdriver:=nil;
end;

procedure TFRpPreview.APrintExecute(Sender: TObject);
var
 adone:boolean;
 allpages,collate:boolean;
 frompage,topage,copies:integer;
begin
 allpages:=true;
 collate:=report.CollateCopies;
 frompage:=1; topage:=999999;
 copies:=report.Copies;
{$IFDEF LINUX}
 if usekprinter then
 begin
   ALastExecute(Self);
   // Use kprinter to print the file
   PrintMetafileUsingKPrinter(report.metafile);
 end
 else
{$ENDIF}
 begin
  if systemprintdialog then
  begin
  if Not rpqtdriver.DoShowPrintDialog(allpages,frompage,topage,copies,collate) then
   exit;
  end
  else
  begin
   if Not rpprintdia.DoShowPrintDialog(allpages,frompage,topage,copies,collate) then
    exit;
  end;
 // report.EndPrint;
 // PrintReport(report,Caption,true,allpages,frompage,topage,copies,collate);
  if not allpages then
  begin
   pagenum:=topage+1;
   PrintPage;
  end
  else
   ALastExecute(Self);
  PrintMetafile(report.Metafile,Caption,true,allpages,frompage,topage,copies,
   collate,report.PrinterSelect,'');
 end;
 AppIdle(Self,adone);
end;

procedure TFRpPreview.ASaveExecute(Sender: TObject);
var
 oldonprogress:TRpMetafileStreamProgres;
 adone,mono:boolean;
 horzres,vertres:integer;
 abitmap:TBitmap;
begin
 // Saves the metafile
 if SaveDialog1.Execute then
 begin
  oldonprogress:=report.Metafile.OnProgress;
  try
   report.Metafile.OnProgress:=MetProgress;
   DisableControls(true);
   try
    case SaveDialog1.FilterIndex of
     1:
      begin
       ALastExecute(Self);
       report.Metafile.SaveToFile(SaveDialog1.Filename)
      end;
     2,3:
      begin
       ALastExecute(Self);
       SaveMetafileToPDF(report.Metafile,SaveDialog1.FileName,SaveDialog1.FilterIndex=2);
 //      report.EndPrint;
 //      ExportReportToPDF(report,SaveDialog1.Filename,true,true,1,32000,
 //       true,SaveDialog1.Filename,SaveDialog1.FilterIndex=2);
       AppIdle(Self,adone);
      end;
     5:
      begin
       horzres:=100;
       vertres:=100;
       mono:=true;
       if AskBitmapProps(horzres,vertres,mono) then
       begin
        ALastExecute(Self);
        abitmap:=MetafileToBitmap(report.Metafile,true,mono,horzres,vertres);
        try
         if assigned(abitmap) then
          abitmap.SaveToFile(SaveDialog1.FileName);
        finally
         abitmap.free;
        end;
       end;
      end;
     6:
      begin
       ALastExecute(Self);
       ExportMetafileToHtml(report.Metafile,Caption,SaveDialog1.FileName,
        true,true,1,9999);
       AppIdle(Self,adone);
      end;
     7:
      begin
       ALastExecute(Self);
       ExportMetafileToSVG(report.Metafile,Caption,SaveDialog1.FileName,
        true,true,1,9999);
       AppIdle(Self,adone);
      end;
     8:
      begin
       ALastExecute(Self);
       ExportMetafileToCSV(report.metafile,SaveDialog1.Filename,true,true,
        1,9999);
       AppIdle(Self,adone);
      end;
     9:
      begin
       ALastExecute(Self);
       ExportMetafileToTextPro(report.metafile,SaveDialog1.Filename,true,true,
        1,9999);
       AppIdle(Self,adone);
      end;
{$IFDEF MSWINDOWS}
     10:
      begin
       ALastExecute(Self);
       MetafileToExe(report.metafile,SaveDialog1.Filename);
      end;
{$ENDIF}
     else
     begin
      // Plain text file
      ALastExecute(Self);
      SaveMetafileToTextFile(report.Metafile,SaveDialog1.FileName);
      AppIdle(Self,adone);
     end;
    end;
   finally
    EnableControls;
   end;
  finally
   report.Metafile.OnProgress:=oldonprogress;
  end;
 end;
end;

procedure TFRpPreview.RepProgress(Sender:TRpBaseReport;var docancel:boolean);
begin
 BCancel.Caption:=IntToStr(Sender.CurrentSubReportIndex)+' '+SRpPage+':'+
  FormatFloat('####,####',report.PageNum)+':'
  +FormatFloat('####,####',report.RecordCount)+'-'+SRpCancel;
{$IFDEF MSWINDOWS}
 if ((GetAsyncKeyState(VK_ESCAPE) AND $8000)<>0) then
  cancelled:=true;
{$ENDIF}
 Application.ProcessMessages;
 if cancelled then
  docancel:=true;
end;

procedure TFRpPreview.BCancelClick(Sender: TObject);
begin
 cancelled:=true;
end;

procedure TFRpPreview.ACancelExecute(Sender: TObject);
begin
 cancelled:=true;
end;

procedure TFRpPreview.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 if Not ANext.Enabled then
 begin
  cancelled:=true;
 end;
end;

procedure TFRpPreview.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
 increment:integer;
begin
 if (ssShift in Shift) then
  increment:=1
 else
  increment:=ImageContainer.VertScrollBar.Increment;
 if Key=Key_Down then
 begin
  if ImageContainer.VertScrollBar.Position+increment>ImageContainer.VertScrollBar.Range-ImageContainer.Height then
   ImageContainer.VertScrollBar.Position:=ImageContainer.VertScrollBar.Range-ImageContainer.Height+increment
  else
   ImageContainer.VertScrollBar.Position:=ImageContainer.VertScrollBar.Position+Increment;
 end;
 if Key=Key_Up then
 begin
  ImageContainer.VertScrollBar.Position:=ImageContainer.VertScrollBar.Position-Increment;
 end;
 if Key=Key_Right then
 begin
  if ImageContainer.HorzScrollBar.Position+increment>ImageContainer.HorzScrollBar.Range-ImageContainer.Width then
   ImageContainer.HorzScrollBar.Position:=ImageContainer.HorzScrollBar.Range-ImageContainer.Width+increment
  else
   ImageContainer.HorzScrollBar.Position:=ImageContainer.HorzScrollBar.Position+Increment;
 end;
 if Key=Key_Left then
 begin
  ImageContainer.HorzScrollBar.Position:=ImageContainer.HorzScrollBar.Position-Increment;
 end;
 if Key=Key_Space then
 begin
  AImageMouseDown(Self,mbLeft,[],0,0);
  Key:=0;
 end;
end;

procedure TFRpPreview.DisableControls(enablebar:boolean);
begin
 BCancel.Left:=BExit.Left+BExit.Width;
 BCancel.Visible:=true;
 AScale100.Enabled:=false;
 AScaleFull.Enabled:=false;
 AScaleWide.Enabled:=false;
 AScaleLess.Enabled:=False;
 AScaleMore.Enabled:=False;
 AFirst.Enabled:=false;
 ALast.Enabled:=false;
 APrint.Enabled:=false;
 ANext.Enabled:=false;
 APrevious.Enabled:=false;
 EPageNum.Enabled:=false;
 ASave.Enabled:=false;
 AMailTo.Enabled:=false;
 APageSetup.Enabled:=false;
 AParams.Enabled:=false;
 PBar.Position:=0;
 PBar.Visible:=enablebar;
 AExit.Enabled:=false;
end;

procedure TFRpPreview.EnableControls;
begin
 BCancel.Visible:=false;
 AScale100.Enabled:=true;
 AScaleFull.Enabled:=true;
 AScaleWide.Enabled:=true;
 AScaleLess.Enabled:=true;
 AScaleMore.Enabled:=true;
 AFirst.Enabled:=true;
 ALast.Enabled:=true;
 APrint.Enabled:=true;
 ANext.Enabled:=true;
 APrevious.Enabled:=true;
 EPageNum.Enabled:=true;
 ASave.Enabled:=true;
 AMailTo.Enabled:=true;
 APageSetup.Enabled:=true;
 AParams.Enabled:=enableparams;
 PBar.Visible:=false;
 AExit.Enabled:=true;
end;


procedure TFRpPreview.MetProgress(Sender:TRpMetafileReport;Position,Size:int64;page:integer);
begin
 BCancel.Caption:=SRpPage+':'+FormatFloat('####,#####',page)+
  ' -'+FormatFloat('######,####',Position div 1024)+SRpKbytes+' '+SrpCancel;
 if Position=size then
 begin
  PBar.Position:=page;
  PBar.Max:=Sender.PageCount;
 end
 else
 begin
  PBar.Position:=Position;
  PBar.Max:=Size;
 end;
 Application.ProcessMessages;
{$IFDEF MSWINDOWS}
 if ((GetAsyncKeyState(VK_ESCAPE) AND $8000)<>0) then
  cancelled:=true;
{$ENDIF}
 if cancelled then
  Raise Exception.Create(SRpOperationAborted);
end;


procedure TFRpPreview.AExitExecute(Sender: TObject);
begin
 Close;
end;

procedure TFRpPreview.AParamsExecute(Sender: TObject);
var
 adone:boolean;
begin
 if ShowUserParams(report.params) then
 begin
  // Reexecutes the report
  AppIdle(Self,adone);
 end;
end;


procedure TFRpPreview.PlaceImagePosition;
var
 AWidth:integeR;
 Aheight:integer;
begin
 ImageContainer.HorzScrollBar.Position:=0;
 ImageContainer.VertScrollBar.Position:=0;
 AImage.Left:=0;
 AImage.Top:=0;
 ImageContainer.HorzScrollBar.Position:=0;
 ImageContainer.VertScrollBar.Position:=0;

 AWidth:=ImageContainer.Width-SCROLLBAR_VX;
 AHeight:=ImageContainer.Height-SCROLLBAR_HX;

 if AImage.Width>AWidth then
  AImage.Left:=0
 else
  AImage.Left:=(AWidth-AImage.Width) div 2;
 if AImage.Height>AHeight then
  AImage.Top:=0
 else
  AImage.Top:=((AHeight-AImage.Height) div 2);
 // A bug in the refresh in Windows
{$IFDEF MSWINDOWS}
 ImageContainer.Visible:=False;
 ImageContainer.Visible:=True;
 {$ENDIF}
end;



procedure TFRpPreview.FormResize(Sender: TObject);
begin
 if BCancel.Visible then
  exit;
 // Sets the driver widths and redraw accordingly
 AScaleFull.Checked:=false;
 AScaleWide.Checked:=false;
 AScale100.Checked:=false;
 if Assigned(qtdriver) then
 begin
  qtdriver.clientwidth:=ImageContainer.Width;
  qtdriver.clientHeight:=ImageContainer.Height;
  case qtdriver.PreviewStyle of
   spWide:
    AScaleWide.Checked:=True;
   spEntirePage:
    AScaleFull.Checked:=True;
   spNormal:
    AScale100.Checked:=True;
  end;
  if pagenum>=1 then
   PrintPage;
 end;
end;

procedure TFRpPreview.AScale100Execute(Sender: TObject);
begin
 qtdriver.PreviewStyle:=spNormal;
 FormResize(Self);
end;

procedure TFRpPreview.AScaleWideExecute(Sender: TObject);
begin
 qtdriver.PreviewStyle:=spWide;
 FormResize(Self);
end;

procedure TFRpPreview.AScaleFullExecute(Sender: TObject);
begin
 qtdriver.PreviewStyle:=spEntirePage;
 FormResize(Self);
end;

procedure TFRpPreview.AScaleLessExecute(Sender: TObject);
begin
 qtdriver.PreviewStyle:=spCustom;
 qtdriver.Scale:=qtdriver.scale-0.10;
 FormResize(Self);
end;

procedure TFRpPreview.AScaleMoreExecute(Sender: TObject);
begin
 qtdriver.PreviewStyle:=spCustom;
 qtdriver.Scale:=qtdriver.scale+0.10;
 FormResize(Self);
end;

procedure TFRpPreview.AImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
 relx:Extended;
 rely:Extended;
 posx,migx:Extended;
 posy,migy:Extended;
 punt:Tpoint;
begin
 // When clic in image scale to 100% and scroll to the
 // clicked section
 if qtdriver.PreviewStyle=spEntirePage then
 begin
  punt.X:=X;
  punt.y:=Y;
  relx:=punt.X;
  rely:=punt.Y;
  relx:=relx/AImage.Width;
  rely:=rely/AImage.Height;
  AScale100.Execute;
  // looks the limit
  posx:=ImageContainer.HorzScrollBar.Range*relx;
  posy:=ImageContainer.VertScrollBar.Range*rely;
  // To the center
  Migx:=PosX-(ImageContainer.ClientWidth div 2);
  Migy:=PosY-(ImageContainer.ClientHeight div 2);

  ImageContainer.HorzScrollBar.Position:=Trunc(migX);
  ImageContainer.VertScrollBar.Position:=Trunc(MigY);
 end
 else
  AScaleFull.Execute;
end;

procedure TFRpPreview.FormMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
 if (ssCtrl in Shift) then
  ImageContainer.HorzScrollBar.Position:=ImageContainer.HorzScrollBar.Position+GetWheelInc(Shift)
 else
  ImageContainer.VertScrollBar.Position:=ImageContainer.VertScrollBar.Position+GetWheelInc(Shift);
 Handled:=true;
end;

procedure TFRpPreview.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
 if (ssCtrl in Shift) then
  ImageContainer.HorzScrollBar.Position:=ImageContainer.HorzScrollBar.Position-GetWheelInc(Shift)
 else
  ImageContainer.VertScrollBar.Position:=ImageContainer.VertScrollBar.Position-GetWheelInc(Shift);
 Handled:=true;
end;

procedure TFRpPreview.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
 Handled:=false;
end;

procedure TFRpPreview.ImageContainerMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
 Handled:=false;
end;


procedure TFRpPreview.AMailToExecute(Sender: TObject);
var
 afilename:String;
begin
 ALastExecute(Self);
 afilename:=ChangeFileExt(RpTempFileName,'.pdf');
 SaveMetafileToPDF(report.Metafile,afilename,true);
 rptypes.SendMail('',Caption,'',afilename);
end;

procedure TFRpPreview.APageSetupExecute(Sender: TObject);
var
 adone:boolean;
begin
 if ExecutePageSetup(report) then
 begin
  fModified:=true;
  // Reexecutes the report
  AppIdle(Self,adone);
 end;
end;

end.
