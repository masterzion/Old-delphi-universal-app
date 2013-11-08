{*******************************************************}
{                                                       }
{       Report Manager                                  }
{                                                       }
{       rphtmldriver                                    }
{       Exports a metafile to HTML CSS                  }
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

// To do, provide page breaks using <p style="page-break-before: always">


unit rphtmldriver;

interface

{$I rpconf.inc}

uses
 Classes,sysutils,rpmetafile,rpmdconsts,
 rpmunits,rppdffile,
{$IFDEF USEVARIANTS}
 types,Variants,
{$ENDIF}
{$IFNDEF FORWEBAX}
 rpbasereport,rppdfdriver,
{$ENDIF}
 rptypes;



function ExportMetafileToHtml (metafile:TRpMetafileReport;caption,filename:string;
 showprogress,allpages:boolean; frompage,topage:integer):boolean;
function MetafilePageToHtml(metafile:TRpMetafileReport;index:integer;Stream:TStream;caption,filename:String):boolean;
function ColorToHTMLColor(color:integer):String;
{$IFNDEF FORWEBAX}
procedure ExportReportToHtml(report:TRpBaseReport;filename:String;progress:Boolean);
{$ENDIF}

implementation

function ColorToHTMLColor(color:integer):String;
var
 acolor:string;
begin
 acolor:=Format('%.8x', [Color]);
 Result:=Copy(acolor,7,2)+Copy(acolor,5,2)+Copy(acolor,3,2);
end;

const
 AlignmentFlags_SingleLine=64;
 AlignmentFlags_AlignHCenter = 4 { $4 };
 AlignmentFlags_AlignHJustify = 1024 { $400 };
 AlignmentFlags_AlignTop = 8 { $8 };
 AlignmentFlags_AlignBottom = 16 { $10 };
 AlignmentFlags_AlignVCenter = 32 { $20 };
 AlignmentFlags_AlignLeft = 1 { $1 };
 AlignmentFlags_AlignRight = 2 { $2 };


function TextToHtml(astring:String):String;
begin
 Result:=astring;
end;


function ObjectToStyle(page:TRpMetafilePage;obj:TRpMetaObject):String;
begin
 Result:='{ ';
 case obj.Metatype of
  rpMetaText:
   begin
    Result:=Result+'FONT-FAMILY:"'+page.GetWFontName(obj)+'","'+
     page.GetLFontName(obj)+'";';
    Result:=Result+'COLOR:'+ColorToHTMLColor(obj.FontColor)+';';
    if obj.Transparent then
     Result:=Result+'BACKGROUND-COLOR:TRANSPARENT;'
    else
     Result:=Result+'BACKGROUND-COLOR:'+ColorToHTMLColor(obj.BackColor)+';';

    Result:=Result+'FONT-SIZE:'+IntToStr(obj.FontSize)+'PT;';
    if ((obj.Fontstyle and 1)>0) then
     Result:=Result+'FONT-WEIGHT:BOLD;'
    else
     Result:=Result+'FONT-WEIGHT:NORMAL;';
    if (obj.Fontstyle and (1 shl 1))>0 then
     Result:=Result+'FONT-STYLE:ITALIC;'
    else
     Result:=Result+'FONT-STYLE:NORMAL;';
    if (obj.FontStyle and (1 shl 2))>0 then
     Result:=Result+'TEXT-DECORATION:UNDERLINE;';
     if (obj.FontStyle and (1 shl 3))>0 then
      Result:=Result+'TEXT-DECORATION:LINE-THROUGHT;'
     else
      Result:=Result+'TEXT-DECORATION:NONE;';
   end;
  rpMetaDraw:
   begin
   end;
  rpMetaImage:
   begin
   end;
 end;
 Result:=Result+'}';
end;

function ObjectToHtmlText(apage:TrpMetafilePage;pageindex:integer;obj:TRpMetaObject;filename:string;index:integer):String;
var
 imafilename:String;
 isjpeg:Boolean;
 fimagestream:TMemoryStream;
 bitmapwidth,bitmapheight,imagesize:Integer;
begin
 Result:='';
 case obj.Metatype of
  rpMetaText:
   begin
    Result:=TextToHtml(apage.GetText(obj));
   end;
  rpMetaDraw:
   begin

   end;
  rpMetaImage:
   begin
    // Saves the object as objectindex
    try
     // Get information and save the image
     imafilename:=ChangeFileExt(filename,'');
     imafilename:=imafilename+'page'+IntToStr(pageindex)+'obj'+IntToStr(index);
     fimagestream:=apage.GetStream(obj);
     isjpeg:=GetJPegInfo(fimagestream,bitmapwidth,bitmapheight);
     if isjpeg then
     begin
      // Read image dimensions
      imafilename:=ChangeFileExt(imafilename,'.jpg');
     end
     else
     begin
      fimagestream.Seek(0,soFromBeginning);
      GetBitmapInfo(fimagestream,bitmapwidth,bitmapheight,imagesize,FImageStream);
      imafilename:=ChangeFileExt(imafilename,'.bmp');
     end;
     fimagestream.Seek(0,soFromBeginning);
     fimagestream.SaveToFile(imafilename);
     Result:='<IMG SRC="'+imafilename+'" HEIGHT='+IntToStr(bitmapheight)+
      ' WIDTH='+IntToStr(bitmapwidth)+' BORDER=0>';
    except
     // Omit image processing errors?
     on E:Exception do
     begin
      Result:=TextToHtml(E.Message);
     end;
    end;
   end;
 end;
end;


function TwipsToPX(twips:Integer):String;
var
 sizepoints:double;
begin
 sizepoints:=twips*72/1440;
 // Adjust size beacuse IE custom sizing?
 sizepoints:=sizepoints*1.3;
 Result:=IntToStr(Round(sizepoints));
end;

function ObjectBounds(page:TRpMetafilePage;obj:TRpMetaObject;filename:String;index:integer):String;
begin
 Result:='';
 case obj.Metatype of
  rpMetaText:
   begin
    Result:='"';
    Result:=Result+'left:'+TwipsToPX(obj.Left)+'PX;'+
    'top:'+TwipsToPX(obj.Top)+'PX;'+
    'width:'+TwipsToPX(obj.Width)+'PX;'+
    'height:'+TwipsToPX(obj.Height)+'PX;';
    if  ((obj.Alignment AND AlignmentFlags_AlignRight)>0) then
     Result:=Result+'text-align:right;'
    else
     if (obj.Alignment AND AlignmentFlags_AlignHCenter)>0 then
      Result:=Result+'text-align:center;'
     else
      if  ((obj.Alignment AND AlignmentFlags_AlignHJustify)>0) then
       Result:=Result+'text-align:justify;'
      else
       Result:=Result+'text-align:left;';
    if (obj.AlignMent AND AlignmentFlags_AlignBottom)>0 then
     Result:=Result+'vertical-align:bottom;'
    else
     if (obj.AlignMent AND AlignmentFlags_AlignVCenter)>0 then
      REsult:=Result+'vertical-align:middle;';
    Result:=Result+'"';
   end;
  rpMetaDraw:
   begin
    case TRpShapeType(obj.DrawStyle) of
     rpsRectangle:
      begin
       Result:=Result+'''display:svg-rect'' '+'x="'+TwipsToPX(obj.Left)+
        'px" y="'+TwipsToPX(obj.Top)+'px" width="'+TwipsToPX(obj.Width)+
        'px" height="'+TwipsToPX(obj.Height)+'px"';
      end;
    end;
   end;
  rpMetaImage:
   begin
    Result:='"';
    Result:=Result+'left:'+TwipsToPX(obj.Left)+'PX;'+
    'top:'+TwipsToPX(obj.Top)+'PX;'+
    'width:'+TwipsToPX(obj.Width)+'PX;'+
    'height:'+TwipsToPX(obj.Height)+'PX;';
    Result:=Result+'"';
   end;
 end;
end;


procedure ExportPageToHtml(metafile:TRpMetafileReport;page:TrpMetafilePage;pageindex:integer;Stream:TStream;caption,filename:String);
var
 astring:String;
 pstyles:array of Integer;
 astyle:String;
 pstyledescriptions:TStringList;
 i,index:integer;
 singleline:Boolean;
begin
 astring:='<HTML>';
 if page.ObjectCount>0 then
 begin
  astring:=astring+LINE_FEED+'<STYLE>';
  astring:=astring+LINE_FEED+'.pg{position:absolute;top:0px;left:0px;height:'+
   twipstopx(metafile.CustomY)+'px;width:'+twipstopx(metafile.CustomX)+'px;}';
  astring:=astring+LINE_FEED+'DIV {position:absolute}';
  SetLength(pstyles,page.ObjectCount);
  pstyledescriptions:=TStringList.Create;
  try
   // Generates a style for each report component
   pstyledescriptions.Sorted:=true;
   for i:=0 to page.ObjectCount-1 do
   begin
    astyle:=ObjectToStyle(page,page.Objects[i]);
    index:=pstyledescriptions.IndexOf(astyle);
    if index>=0 then
     pstyles[i]:=Integer(pstyledescriptions.Objects[index])
    else
    begin
     astring:=astring+LINE_FEED+'.fc'+IntToStr(i)+' '+
      astyle;
     pstyledescriptions.AddObject(astyle,TObject(i));
     pstyles[i]:=i;
    end;
   end;
  finally
   pstyledescriptions.free;
  end;
  astring:=astring+LINE_FEED+'</STYLE>';
 end;
 astring:=astring+LINE_FEED+'<TITLE>'+TextToHtml(Caption)+'</TITLE>';
 if page.ObjectCount>0 then
 begin
  astring:=astring+LINE_FEED+'<BODY  BGCOLOR="'+
   ColorToHTMLColor(metafile.BackColor)   +'" LEFTMARGIN=0 TOPMARGIN=0 BOTTOMMARGIN=0 RIGHTMARGIN=0>';
  // This line defines the page size
  //astring:=astring+LINE_FEED+'<DIV CLASS="pg"></DIV>';
  for i:=0 to page.ObjectCount-1 do
  begin
   singleline:=(page.Objects[i].Alignment AND AlignmentFlags_SingleLine)>0;
   astring:=astring+LINE_FEED+'<DIV style='+
    ObjectBounds(page,page.Objects[i],filename,i)+
    '><span class="fc'+IntToStr(pstyles[i])+'">';
   if singleline then
    astring:=astring+'<NOBR>';
   astring:=astring+ObjectToHtmlText(page,pageindex,page.Objects[i],filename,i);
   if singleline then
    astring:=astring+'</NOBR>';
   astring:=astring+'</span></DIV>';
  end;
  astring:=astring+LINE_FEED+'</BODY>';
 end;
 astring:=astring+LINE_FEED+'</HTML>';
 WriteStringToStream(astring,stream);
end;

function ExportMetafileToHtml (metafile:TRpMetafileReport; caption,filename:string;
 showprogress,allpages:boolean; frompage,topage:integer):boolean;
var
 i:integer;
 oldext,nfilename:String;
 astream:TMemoryStream;
begin
 if allpages then
 begin
  frompage:=0;
  topage:=metafile.PageCount-1;
 end
 else
 begin
  frompage:=frompage-1;
  topage:=topage-1;
  if topage>metafile.PageCount-1 then
   topage:=metafile.PageCount-1;
 end;
 oldext:=ExtractFileExt(filename);
 for i:=frompage to topage do
 begin
  astream:=TMemoryStream.Create;
  try
   ExportPageToHtml(metafile,metafile.Pages[i],i,astream,caption,filename);
   nfilename:=ChangeFileExt(filename,'');
   nfilename:=nfilename+IntToStr(i);
   nfilename:=ChangeFileExt(nfilename,oldext);
   astream.Seek(0,soFromBeginning);
   astream.SaveToFile(nfilename);
  finally
   astream.free;
  end;
 end;
 Result:=true;
end;

function MetafilePageToHtml(metafile:TRpMetafileReport;index:integer;Stream:TStream;caption,filename:String):boolean;
begin
 ExportPageToHtml(metafile,metafile.pages[index],index,stream,Caption,filename);
 Result:=true;
end;

{$IFNDEF FORWEBAX}
procedure ExportReportToHtml(report:TRpBaseReport;filename:String;progress:Boolean);
var
 pdfdriver:TRpPDFDriver;
 apdfdriver:IRpPrintDriver;
 oldprogres:TRpProgressEvent;
 astream:TMemoryStream;
 oldtwopass:boolean;
begin
 pdfdriver:=TRpPDFDriver.Create;
 pdfdriver.compressed:=true;
 astream:=TMemoryStream.Create;
 try
  pdfdriver.DestStream:=aStream;
  apdfdriver:=pdfdriver;
  // If report progress must print progress
  oldprogres:=report.OnProgress;
  try
   if progress then
    report.OnProgress:=pdfdriver.RepProgress;
   oldtwopass:=report.TwoPass;
   try
    report.TwoPass:=true;
    report.PrintAll(apdfdriver);
    ExportMetafileToHtml(report.metafile,filename,filename,true,true,1,99999);
   finally
    report.TwoPass:=oldtwopass;
   end;
  finally
   report.OnProgress:=oldprogres;
  end;
 finally
  astream.free;
 end;
end;
{$ENDIF}

end.

