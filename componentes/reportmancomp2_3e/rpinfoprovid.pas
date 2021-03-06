{*******************************************************}
{                                                       }
{       Report Manager                                  }
{                                                       }
{       TRpInfoProvider  Base class                     }
{       Provides information about fonts and bitmaps    }
{                                                       }
{       Copyright (c) 1994-2002 Toni Martir             }
{       toni@pala.com                                   }
{                                                       }
{                                                       }
{*******************************************************}

unit rpinfoprovid;


interface

{$I rpconf.inc}

uses Classes,SysUtils,
{$IFDEF USEVARIANTS}
 Types,
{$ENDIF}
{$IFNDEF USEVARIANTS}
 Windows,
{$ENDIF}
 rptypes;

type
 TWinAnsiWidthsArray=array [32..255] of integer;
 PWinAnsiWidthsArray= ^TWinAnsiWidthsArray;

 TRpPDFFont=class(TObject)
  public
   Name:TRpType1Font;
   WFontName:WideString;
   LFontName:WideString;
   fontname:String;
   Size:integer;
   Color:integer;
   Style:Integer;
   Italic:Boolean;
   Underline:boolean;
   Bold:boolean;
   StrikeOut:boolean;
   constructor Create;
  end;



 TRpTTFontData=class(TObject)
  embedded:Boolean;
  fontdata:TMemoryStream;
  postcriptname:String;
  Encoding:String;
  Ascent,Descent,Leading,CapHeight,Flags,FontWeight:integer;
  MaxWidth:integer;
  AvgWidth:integer;
  StemV:double;
  FontFamily:String;
  FontStretch:String;
  ItalicAngle:double;
  FontBBox:TRect;
  FamilyName:String;
  FullName:String;
  FaceName:String;
  StyleName:String;
  type1:boolean;
  havekerning:Boolean;
  ObjectName:String;
  ObjectIndex:integer;
  ObjectIndexParent:integer;
  DescriptorIndex:Integer;
  loadedkernings:array [0..65535] of TStringList;
  loadedglyphs:array [0..65535] of WideChar;
  loadedg:array [0..65535] of boolean;
  loadedk:array [0..65535] of boolean;
  loadedwidths:array [0..65535] of integer;
  loaded:array [0..65535] of boolean;
  fdata:TObject;
  firstloaded,lastloaded:integer;
  kerningsadded:TStringList;
  IsUnicode:boolean;
  constructor Create;
  destructor Destroy;override;
 end;

 IRpInfoProvider=interface
  ['{59F66653-ACEC-4FC9-B918-C22136F576F1}']
  procedure FillFontData(pdffont:TRpPDFFont;data:TRpTTFontData);
  function GetCharWidth(pdffont:TRpPDFFont;data:TRpTTFontData;charcode:widechar):Integer;
  function GetKerning(pdffont:TRpPDFFont;data:TRpTTFontData;leftchar,rightchar:widechar):integer;
 end;


implementation

constructor TRpTTFontData.Create;
begin
 inherited Create;

 kerningsadded:=TStringList.Create;
 kerningsadded.sorted:=true;
 firstloaded:=65536;
 lastloaded:=-1;
end;

destructor TRpTTFontData.Destroy;
var
 i:integer;
begin
 for i:=0 to kerningsadded.count-1 do
 begin
  loadedkernings[StrToInt(kerningsadded.Strings[i])].Free;
 end;
 kerningsadded.free;

 inherited;
end;

constructor TrpPdfFont.Create;
begin
 inherited Create;

 Name:=poCourier;
 Size:=10;
end;

end.
