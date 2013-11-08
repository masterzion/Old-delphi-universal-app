{*******************************************************}
{                                                       }
{       Report Manager                                  }
{                                                       }
{       rpwizard                                        }
{       Creatin of reports from user provided informat. }
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

unit rpwizard;

interface

{$I rpconf.inc}

uses Classes,SysUtils,rpprintitem,rpmdconsts,rpeval,db,
 rptypeval,rptypes,rpmunits,rpbasereport,rpreport,rpsection,rpsubreport,
 rplabelitem,
{$IFNDEF USEVARIANTS}
 windows,
{$ENDIF}
{$IFDEF USEVARIANTS}
 Types,Variants,
{$ENDIF}
 rpmetafile;


const
 HEADER_HEIGHT=700;
 FOOTER_HEIGHT=700;
Type
 TRpReportStyle=(rpstyledetail,rpstylelabel,rpstylegroups);

 TRpWizardOptions=class(TObject)
  public
   Title:WideString;
   DetailWidth:Integer;
   DefaultWidth:Integer;
   PageHeader:Boolean;
   PageFooter:Boolean;
   tables:TStrings;
   fields:array of TStrings;
   groups:array of TStrings;
   groupsums:array of TStrings;
   constructor Create;
   destructor Destroy;override;
 end;

 procedure GenerateReport(reportstyle:TRpReportStyle;report:TRpReport;
   options:TRpWizardOptions);

implementation

const
 AlignmentFlags_SingleLine=64;
 AlignmentFlags_AlignHCenter = 4 { $4 };
 AlignmentFlags_AlignHJustify = 1024 { $400 };
 AlignmentFlags_AlignTop = 8 { $8 };
 AlignmentFlags_AlignBottom = 16 { $10 };
 AlignmentFlags_AlignVCenter = 32 { $20 };
 AlignmentFlags_AlignLeft = 1 { $1 };
 AlignmentFlags_AlignRight = 2 { $2 };


procedure GenerateDetailReport(report:TRpReport;options:TRpWizardOptions);
var
 asub:TRpSubReport;
 asec:TRpSection;
 i:integer;
begin
 // The first subreport is linked to the main dataset
 // Add a group with repeteable header
 asub:=report.Subreports.Items[0].Subreport;
 asub.AddGroup('TOTAL');
 asec:=asub.Sections.Items[asub.FirstDetail-1].Section;
 asec.Height:=290;
 if High(options.fields)<0 then
  exit;
 for i:=0 to options.fields[0].Count-1 do
 begin

 end;
end;

procedure GenerateReport(reportstyle:TRpReportStyle;report:TRpReport;
  options:TRpWizardOptions);
var
 freeoptions:boolean;
 asub:TRpSubReport;
 asec:TRpSection;
 adata:TDataset;
 i:integer;
 alabel:TRpLabel;
 aexpre:TRpExpression;
begin
 if report.DataInfo.Count<1 then
  Raise Exception.Create('No datasets');
 freeoptions:=false;
 if not assigned(options) then
 begin
  options:=TRpWizardOptions.Create;
  freeoptions:=true;
 end;
 try
  if freeoptions then
  begin
   // Try adding all the fields of first dataset
   options.tables.Add(report.datainfo.Items[0].Alias);
   report.datainfo.Items[0].Connect(report.databaseinfo,report.params);
   adata:=report.datainfo.Items[0].Dataset;
   SetLength(options.fields,1);
   options.fields[0]:=TStringList.Create;
   for i:=0 to adata.fields.count-1 do
   begin
    options.fields[0].Add(adata.fields[i].FieldName);
   end;
   options.pageheader:=true;
   options.Title:=report.datainfo.Items[0].Alias;
  end;
  report.AddSubReport;
  asub:=report.SubReports.Items[0].SubReport;
  asub.Alias:=report.datainfo.Items[0].Alias;
  if Options.PageHeader then
  begin
   asec:=asub.AddPageHeader;
   asec.Global:=true;
   asec.Height:=HEADER_HEIGHT;

   // Page counting
   alabel:=TRpLabel.Create(report);
   Generatenewname(alabel);
   asec.Components.Add.Component:=alabel;
   alabel.Width:=1000;
   alabel.PosX:=asec.Width-alabel.Width-alabel.Width;
   alabel.Height:=290;
   alabel.Text:=SRpPage;
   aexpre:=TRpExpression.Create(report);
   GenerateNewName(aexpre);
   asec.Components.Add.Component:=aexpre;
   aexpre.Expression:='Page';
   aexpre.Width:=1000;
   aexpre.Height:=290;
   aexpre.DisplayFormat:='##,##0';
   aexpre.PosX:=asec.Width-aexpre.Width;
   aexpre.Alignment:=AlignmentFlags_AlignRight;
   // Report Title
   alabel:=TRpLabel.Create(report);
   Generatenewname(alabel);
   asec.Components.Add.Component:=alabel;
   alabel.Width:=asec.Width;
   alabel.PosY:=300;
   alabel.Height:=290;
   alabel.Text:=options.Title;
   alabel.Alignment:=AlignmentFlags_AlignHCenter;
  end;
  case reportstyle of
   rpstyledetail:
    begin
      GenerateDetailReport(report,options);
    end;
   rpstylelabel:
    begin

    end;
   rpstylegroups:
    begin

    end;
  end;
 finally
  if freeoptions then
   options.free;
 end;
end;

constructor TRpWizardOptions.Create;
begin
 tables:=TStringList.Create;
end;


destructor TRpWizardOptions.Destroy;
var
 i:integer;
begin
 tables.free;
 for i:=0 to High(Fields) do
 begin
  Fields[i].free;
 end;
 for i:=0 to High(Groups) do
 begin
  Groups[i].free;
 end;
 for i:=0 to High(GroupSums) do
 begin
  GroupSums[i].free;
 end;

 inherited destroy;
end;

end.

