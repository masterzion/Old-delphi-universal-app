{*******************************************************}
{                                                       }
{       Report Manager                                  }
{                                                       }
{       rpvgraphutils                                   }
{       Utilities for Windows GDI printer driver        }
{       can be used only for windows                    }
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

{$I rpconf.inc}

unit rpvgraphutils;

interface

uses Classes,SysUtils,Windows,Graphics,rpmunits,Printers,WinSpool,
 rpmdconsts,rptypes,Forms,
{$IFNDEF DOTNETD}
 jpeg,
{$ENDIF}
{$IFDEF DOTNETD}
 System.Runtime.InteropServices,
{$ENDIF}
 ComCtrls;
const
 // Max bitmap size for tile result operation
 MAX_BITMAP_SIZE=20*1024*1024;

type
 TRpNodeInfo=class(TObject)
  public
   Node:TTreeNode;
   ReportName:WideString;
   Group_Code:Integer;
   Parent_Group:integer;
   Path:String;
  end;

 TGDIPageSize=record
  // -1 default, 0 user defined, 1 A4...
  PageIndex:integer;
  // Custom size in user defined type
  // 1000 units = 1 Inch
  Width:integer;
  Height:integer;
  papername:string;
  papersource:integer;
  duplex:integer;
  ForcePaperName:String;
  FormWidth,FormHeight:Integer;
  landscape:boolean;
 end;


 TPrinterForm=class(TObject)
   public
    Forminfo:Form_Info_1;
    name:string;
    sizex:double;
    sizey:double;
  end;

procedure DrawBitmap (Destination:TCanvas; Bitmap:TBitmap; Rec,RecSrc:TRect);
procedure DrawBitmapMosaic (canvas:TCanvas; rec:TRect; bitmap:TBitmap);
procedure DrawBitmapMosaicSlow(canvas:TCanvas;rec:Trect;bitmap:TBitmap;dpi:Integer);
function GetPhysicPageSizeTwips:TPoint;
function GetPageSizeTwips:TPoint;
function GetPageMarginsTWIPS:TRect;
function QtPageSizeToGDIPageSize (qtsize:TPageSizeQt):TGDIPageSize;
function GDIPageSizeToQtPageSize (gdisize:TGDIPageSize):TPageSizeQt;
//function FindIndexPaperName (device, name:string):integer;
procedure SetCurrentPaper (apapersize:TGDIPageSize);
procedure SetPrinterCopies(copies:integer);
procedure SetPrinterCollation(collation:boolean);
function GetPrinterCopies:Integer;
function GetPrinterCollation:Boolean;
function PrinterSupportsCollation:Boolean;
function PrinterSupportsCopies(copies:integer):Boolean;
function GetCurrentPaper:TGDIPageSize;
procedure SendControlCodeToPrinter (S: string);
{$IFNDEF DOTNETD}
procedure JPegStreamToBitmapStream(AStream:TMemoryStream);
{$ENDIF}
function FindFormNameFromSize(width,height:integer):String;
function PrinterMaxCopiesSupport:Integer;
procedure FillTreeView (ATree:TTreeView;alist:TStringList);
function GetFullFileName(ANode:TTreeNode;dirseparator:char):String;
function GetFontData(Font:TFont):TMemoryStream;
function GetPageSizeFromDevMode:TPoint;


implementation

var
 FPrinters:TStringList;


function GetFontData(Font:TFont):TMemoryStream;
var
 astream:TMemoryStream;
 asize:DWord;
 abit:TBitmap;
begin
 astream:=nil;
 abit:=TBitmap.Create;
 try
  abit.Height:=20;
  abit.Width:=20;
  abit.Canvas.Font.Name:=Font.Name;
  abit.Canvas.Font.Size:=Font.Size;
  abit.Canvas.TextOut(0,0,'Hola');

  asize:=Windows.GetFontData(abit.Canvas.Handle,0,0,nil,0);
  if asize>0 then
  begin
   astream:=TMemoryStream.Create;
   try
    astream.SetSize(asize);
    if asize<>Windows.GetFontData(abit.Canvas.Handle,0,0,astream.Memory,asize) then
     RaiseLastOsError;
   except
    astream.free;
   end;
  end;
 finally
  abit.free;
 end;
 result:=astream;
end;


{$IFNDEF DOTNETD}
procedure JPegStreamToBitmapStream(AStream:TMemoryStream);
var
 jpegimage:TJPegImage;
 bitmap:TBitmap;
begin
 bitmap:=TBitmap.Create;
 try
  bitmap.PixelFormat:=pf32bit;
  bitmap.HandleType:=bmDIB;
  AStream.Seek(0,soFromBeginning);
  jpegimage:=TJPegImage.Create;
  try
   jpegimage.LoadFromStream(AStream);
   bitmap.Assign(jpegimage);
   AStream.Clear;
   bitmap.SaveToStream(AStream);
   AStream.Seek(0,soFromBeginning);
  finally
   jpegimage.Free;
  end;
 finally
  bitmap.Free;
 end;
end;
{$ENDIF}

// Bitmap print routine
{$IFNDEF DOTNETD}
(*procedure DrawBitmap (Destination:TCanvas;Bitmap:TBitmap;Rec,RecSrc:TRect);
var
  Info:PBitmapInfo;
  InfoSize:DWORD;
  Image:Pointer;
  ImageSize:DWORD;
begin
 With Bitmap do
 begin
  Graphics.GetDIBSizes(Handle,InfoSize,ImageSize);
  Info:=AllocMem(InfoSize);
  try
   Image:=AllocMem(Imagesize);
   try
    GetDIB(Handle,Palette,Info^,Image^);
    if not Monochrome then
     SetStretchBltMode(Destination.handle,STRETCH_DELETESCANS);
    with info^.bmiHeader do
     StretchDIBits(Destination.Handle,rec.Left,rec.Top,rec.Right-rec.Left+1,
        rec.Bottom-rec.Top+1,recsrc.Left,recsrc.Top,
         recsrc.Right-recsrc.Left+1,recsrc.Bottom-recsrc.Top+1,Image,Info^,
        DIB_RGB_COLORS,SRCCOPY);
   finally
    {$R-}
    Dispose(Image);
    {$R+}
   end;
  finally
   FreeMem(Info,InfoSize);
  end;
 end;
end;
*)
// Bitmap print routine
// Bugfix sent by Walter de Boer
procedure DrawBitmap (Destination:TCanvas;Bitmap:TBitmap;Rec,RecSrc:TRect);
type
  PPalEntriesArray = ^TPalEntriesArray; {for palette re-construction}
  TPalEntriesArray = array[0..0] of TPaletteEntry;
var
  dc: hdc;                             {screen dc}
  IsPaletteDevice: bool;               {if the device uses palettes}
  IsDestPaletteDevice: bool;           {if the device uses palettes}
  BitmapInfoSize: Integer;             {sizeof the bitmapinfoheader}
  lpBitmapInfo: PBitmapInfo;           {the bitmap info header}
  hBm: hBitmap;                        {handle to the bitmap}
  hPal: hPalette;                      {handle to the palette}
  OldPal: hPalette;                    {temp palette}
  hBits: THandle;                      {handle to the DIB bits}
  pBits: pointer;                      {pointer to the DIB bits}
  lPPalEntriesArray: PPalEntriesArray; {palette entry array}
  NumPalEntries: Integer;              {number of palette entries}
  i: Integer;                          {looping variable}
begin
  {$IFOPT R+}
  {$DEFINE CKRANGE}
  {$R-}
  {$ENDIF}
  dc := GetDc(0);
  IsPaletteDevice := GetDeviceCaps(dc, RASTERCAPS) and RC_PALETTE = RC_PALETTE;

  ReleaseDc(0, dc);

  if IsPaletteDevice then
    BitmapInfoSize := sizeof(TBitmapInfo) + (sizeof(TRGBQUAD) * 255)
  else
    BitmapInfoSize := sizeof(TBitmapInfo);
  GetMem(lpBitmapInfo, BitmapInfoSize);
  try
    FillChar(lpBitmapInfo^, BitmapInfoSize, #0);
    lpBitmapInfo^.bmiHeader.biSize := sizeof(TBitmapInfoHeader);
    lpBitmapInfo^.bmiHeader.biWidth := Bitmap.Width;
    lpBitmapInfo^.bmiHeader.biHeight := Bitmap.Height;
    lpBitmapInfo^.bmiHeader.biPlanes := 1;
    if IsPaletteDevice then
      lpBitmapInfo^.bmiHeader.biBitCount := 8
    else
      lpBitmapInfo^.bmiHeader.biBitCount := 24;
    lpBitmapInfo^.bmiHeader.biCompression := BI_RGB;
    lpBitmapInfo^.bmiHeader.biSizeImage :=
      ((lpBitmapInfo^.bmiHeader.biWidth * Longint(lpBitmapInfo^.bmiHeader.biBitCount)) div 8) *
      lpBitmapInfo^.bmiHeader.biHeight;
    lpBitmapInfo^.bmiHeader.biXPelsPerMeter := 0;
    lpBitmapInfo^.bmiHeader.biYPelsPerMeter := 0;
    if IsPaletteDevice then
    begin
      lpBitmapInfo^.bmiHeader.biClrUsed := 256;
      lpBitmapInfo^.bmiHeader.biClrImportant := 256;
    end
    else
    begin
      lpBitmapInfo^.bmiHeader.biClrUsed := 0;
      lpBitmapInfo^.bmiHeader.biClrImportant := 0;
    end;
    hBm := Bitmap.ReleaseHandle;
    hPal := Bitmap.ReleasePalette;
    dc := GetDc(0);
    OldPal:=0;
    if IsPaletteDevice then
    begin
      OldPal := SelectPalette(dc, hPal, True);
      RealizePalette(dc);
    end;
    GetDiBits(dc, hBm, 0, lpBitmapInfo^.bmiHeader.biHeight, Nil,
      TBitmapInfo(lpBitmapInfo^), DIB_RGB_COLORS);
    hBits := GlobalAlloc(GMEM_MOVEABLE, lpBitmapInfo^.bmiHeader.biSizeImage);
    pBits := GlobalLock(hBits);
    try
      GetDiBits(dc, hBm, 0,lpBitmapInfo^.bmiHeader.biHeight, pBits,
        TBitmapInfo(lpBitmapInfo^), DIB_RGB_COLORS);
      if IsPaletteDevice then
      begin
        GetMem(lPPalEntriesArray, sizeof(TPaletteEntry) * 256);
        try
         {$IFDEF VER100}
         NumPalEntries := GetPaletteEntries(hPal, 0, 256,   lPPalEntriesArray^);
         {$ELSE}
         NumPalEntries := GetSystemPaletteEntries(dc, 0,256,lPPalEntriesArray^);
         {$ENDIF}
         for i := 0 to (NumPalEntries - 1) do
         begin
           lpBitmapInfo^.bmiColors[i].rgbRed := lPPalEntriesArray^[i].peRed;
           lpBitmapInfo^.bmiColors[i].rgbGreen := lPPalEntriesArray^[i].peGreen;
           lpBitmapInfo^.bmiColors[i].rgbBlue := lPPalEntriesArray^[i].peBlue;
         end;
        finally
         FreeMem(lPPalEntriesArray, sizeof(TPaletteEntry) * 256);
        end;
      end;
      if IsPaletteDevice then
      begin
        SelectPalette(dc, OldPal, True);
        RealizePalette(dc);
      end;
      ReleaseDc(0, dc);

      IsDestPaletteDevice := GetDeviceCaps(Destination.Handle, RASTERCAPS) and RC_PALETTE = RC_PALETTE;
      if IsPaletteDevice then
      begin
        OldPal := SelectPalette(Destination.Handle, hPal, True);
        RealizePalette(Destination.Handle);
      end;
      StretchDiBits(
        Destination.Handle,
        rec.Left,rec.Top,rec.Right-rec.Left+1, rec.Bottom-rec.Top+1,
        recsrc.Left,recsrc.Top, recsrc.Right-recsrc.Left+1,recsrc.Bottom-recsrc.Top+1,
        pBits, lpBitmapInfo^, DIB_RGB_COLORS, SrcCopy
      );
      if IsDestPaletteDevice then
      begin
        SelectPalette(Destination.Handle, OldPal, True);
        RealizePalette(Destination.Handle);
      end;
    finally
     GlobalUnLock(hBits);
     GlobalFree(hBits);
    end;
  finally
   FreeMem(lpBitmapInfo, BitmapInfoSize);
  end;
  Bitmap.Handle := hBm;
  Bitmap.Palette := hPal;
  {$IFDEF CKRANGE}
  {$UNDEF CKRANGE}
  {$R+}
  {$ENDIF}
end;

{$ENDIF}

// Bitmap print routine
{$IFDEF DOTNETD}
procedure DrawBitmap (Destination:TCanvas;Bitmap:TBitmap;Rec,RecSrc:TRect);
var
 abitmap:TBitmap;
 arec:TRect;
begin
 abitmap:=TBitmap.Create;
 try
  abitmap.Width:=RecSrc.Right-RecSrc.Left;
  abitmap.Height:=RecSrc.Bottom-RecSrc.Top;
  arec.Top:=0;
  arec.Left:=0;
  arec.Bottom:=abitmap.Height-1;
  arec.Right:=abitmap.Width-1;
  abitmap.Canvas.CopyRect(arec,bitmap.canvas,recsrc);
  Destination.StretchDraw(rec,abitmap);
 finally
  abitmap.free;
 end;
end;
{$ENDIF}


procedure DrawBitmapMosaic(canvas:TCanvas;rec:Trect;bitmap:TBitmap);
var
 x,y:integer;
 aheight,awidth:integer;
 source,destination:Trect;
begin
 x:=rec.Left;
 y:=rec.Top;
 aheight:=bitmap.height;
 awidth:=bitmap.width;
 Canvas.Draw(x,y,bitmap);
 While ((y+aheight<rec.Bottom) or (x+awidth<rec.Right)) do
 begin
  // Copy the bitmap to three positions
  source.left:=x;
  source.top:=y;
  source.right:=awidth;
  source.bottom:=aheight;
  // Right
  destination.Left:=x+awidth;
  destination.top:=y;
  destination.right:=x+awidth+awidth;
  destination.bottom:=y+aheight;
  Canvas.CopyRect(destination,canvas,source);
  // Down
  destination.Left:=x;
  destination.top:=y+aheight;
  destination.right:=x+awidth;
  destination.bottom:=y+aheight+aheight;
  Canvas.CopyRect(destination,canvas,source);
  // Down-Right
  destination.Left:=x+awidth;
  destination.top:=y+aheight;
  destination.right:=x+awidth+awidth;
  destination.bottom:=y+aheight+aheight;
  Canvas.CopyRect(destination,canvas,source);

  // NextStep
  aheight:=aheight*2;
  awidth:=awidth*2;
 end;
end;

procedure DrawBitmapMosaicSlow(canvas:TCanvas;rec:Trect;bitmap:TBitmap;dpi:Integer);
var
 arec,recsrc:TRect;
 abitmap:TBitmap;
 bitmapwidth,bitmapheight:integer;
 dopatblt:boolean;
 aresult:integer;
 abrush:HBrush;
 oldobj:THandle;
 xdpi,ydpi:integer;
begin
 abitmap:=TBitmap.Create;
 try
{$IFNDEF DOTNETD}
   abitmap.PixelFormat:=pf32bit;
   abitmap.HandleType:=bmDIB;
{$ENDIF}
  if dpi<=0 then
  begin
   abitmap.Assign(bitmap);
  end
  else
  begin
   // Redraw the bitmap to the new dpi
   xdpi:=GetDeviceCaps(Canvas.Handle,LOGPIXELSX);
   ydpi:=GetDeviceCaps(Canvas.Handle,LOGPIXELSY);
   abitmap.Width:=bitmap.Width*xdpi div dpi;
   abitmap.Height:=bitmap.Width*ydpi div dpi;
   arec.Top:=0;
   arec.Left:=0;
   arec.Bottom:=abitmap.Height;
   arec.Right:=abitmap.Width;
   abitmap.Canvas.StretchDraw(arec,bitmap);
  end;
  dopatblt:=false;
  if IsWindowsNT then
  begin
   dopatblt:=true;
   aresult:=GetDevicecaps(Canvas.Handle,RASTERCAPS);
   if ((aresult AND RC_BITBLT)=0) then
    dopatblt:=false;
  end;
  if dopatblt then
  begin
   abrush:=CreatePatternBrush(abitmap.handle);
   if abrush=0 then
    dopatblt:=false
   else
   begin
    try
     oldobj:=SelectObject(Canvas.handle,abrush);
     try
      PatBlt(Canvas.Handle,rec.Left,rec.Top,rec.Right-rec.Left,rec.Bottom-rec.Top,PATCOPY);
     finally
      SelectObject(Canvas.Handle,oldobj);
     end;
    finally
     DeleteObject(abrush);
    end;
   end;
  end;
  if not dopatblt then
  begin
    arec.Left:=0;
    arec.Top:=0;
    arec.Bottom:=rec.Bottom-rec.Top;
    arec.Right:=rec.Right-rec.Left;
    bitmapwidth:=rec.Right-rec.Left+1;
    bitmapheight:=rec.Bottom-rec.Top+1;
    // Must reduce te bitmap size to maximum bitmap size
    while bitmapheight*bitmapwidth*4>MAX_BITMAP_SIZE do
    begin
     bitmapheight:=bitmapheight div 2;
     bitmapwidth:=bitmapwidth div 2;
    end;

    abitmap.Width:=rec.Right-rec.Left+1;
    abitmap.Height:=rec.Bottom-rec.Top+1;
    DrawBitmapMosaic(abitmap.Canvas,arec,bitmap);
    recsrc.Left:=0;
    recsrc.Top:=0;
    recsrc.Right:=aBitmap.Width-1;
    recsrc.Bottom:=aBitmap.Height-1;
    DrawBitmap(Canvas,aBitmap,rec,recsrc)
  end;
 finally
  abitmap.free;
 end;
end;




{procedure DrawBitmapMosaicSlow(canvas:TCanvas;rec:Trect;bitmap:TBitmap);
var
 x,y:integer;
 arec,recsrc:TRect;
begin
 recsrc.Left:=0;
 recsrc.Top:=0;
 recsrc.Right:=Bitmap.Width-1;
 recsrc.Bottom:=Bitmap.Height-1;
 x:=rec.Left;
 y:=rec.Top;
 While y<rec.Bottom do
 begin
  While x<rec.right do
  begin
   arec.Left:=x;
   arec.Top:=y;
   arec.Bottom:=y+bitmap.Height-1;
   arec.Right:=x+bitmap.Width-1;
   DrawBitmap(Canvas,Bitmap,arec,recsrc);
   x:=x+bitmap.width;
  end;
  x:=rec.left;
  y:=y+bitmap.Height;
 end;
end;
}

function GetPageMarginsTWIPS:TRect;
var rec:TRect;
    DC:HDC;
    pagesize:TPoint;
    physical:TPoint;
    offset:TPoint;
    dpix,dpiy:integer;
    apagewidth,apageheight:integer;
    printererror:boolean;
begin
 if Printer.printers.count<1 then
 begin
  result.Left:=0;
  result.Top:=0;
  result.Bottom:=16637;
  result.Right:=12047;
  exit;
 end;
 DC:=0;
 // Printer selected not valid error
 printererror:=false;
 try
  DC:=Printer.handle;
 except
  printererror:=true;
 end;
 if printererror then
 begin
  result.Left:=0;
  result.Top:=0;
  result.Bottom:=16637;
  result.Right:=12047;
  exit;
 end;

 dpix:=GetDeviceCaps(DC,LOGPIXELSX); //  printer.XDPI;
 dpiy:=GetDeviceCaps(DC,LOGPIXELSY);  // printer.YDPI;

 if dpix<1 then
  Raise Exception.Create(SRpWrongREsult+'GetDeviceCaps(DC,LOGPIXELSX)'+
   ':GetPageMarginsTwips');
 if dpiy<1 then
  Raise Exception.Create(SRpWrongREsult+'GetDeviceCaps(DC,LOGPIXELSY)'+
   ':GetPageMarginsTwips');

 apagewidth:=GetDeviceCaps(DC,HORZRES);
 apageheight:=GetDeviceCaps(DC,VERTRES);
 if ((apagewidth<1) or (apageheight<1)) then
 begin
  // Gets the page size from devmode
  pagesize:=GetPageSizeFromDevMode;
 end
 else
 begin
  // Bugfix for axiom printers
  if apageheight<10 then
   apageheight:=apagewidth;

  pagesize.x:=Round(apagewidth/dpix*TWIPS_PER_INCHESS);
  pagesize.y:=Round(apageheight/dpiy*TWIPS_PER_INCHESS);
 end;


 physical:=GetPhysicPageSizeTwips;
// physical.x:=GetDeviceCaps(DC,PHYSICALWIDTH);
// physical.y:=GetDeviceCaps(DC,PHYSICALHEIGHT);
 // Bugfix for axiom printers
 if physical.y<10 then
  physical.y:=physical.x;
 // Transform to twips
// physical.X:=Round(physical.X/dpix*TWIPS_PER_INCHESS);
// physical.Y:=Round(physical.Y/dpiy*TWIPS_PER_INCHESS);

 // Gets top/left offser
 offset.x:=GetDeviceCaps(DC,PHYSICALOFFSETX);
 offset.y:=GetDeviceCaps(DC,PHYSICALOFFSETY);
 // Transform to twips
 offset.X:=Round(offset.X/dpix*TWIPS_PER_INCHESS);
 offset.Y:=Round(offset.Y/dpiy*TWIPS_PER_INCHESS);

 rec.Left:=offset.X;
 rec.Top:=offset.Y;
 rec.Right:=physical.X-(physical.X-pagesize.X-offset.X);
 rec.Bottom:=physical.Y-(physical.Y-pagesize.Y-offset.Y);

 Result:=rec;
end;


function GetPageSizeTwips:TPoint;
var
 DC:HDC;
 dpix,dpiy:integer;
 apagewidth,apageheight:integer;
 printererror:boolean;
begin
 if Printer.printers.count<1 then
 begin
  result.y:=16637;
  result.x:=12047;
  exit;
 end;
 DC:=0;
 // Printer selected not valid error
 printererror:=false;
 try
  DC:=Printer.handle;
 except
  printererror:=true;
 end;
 if printererror then
 begin
  result.y:=16637;
  result.x:=12047;
  exit;
 end;
 // Get the device units of
 dpix:=GetDeviceCaps(DC,LOGPIXELSX); //  printer.XDPI;
 dpiy:=GetDeviceCaps(DC,LOGPIXELSY);  // printer.YDPI;

 if dpix<1 then
  Raise Exception.Create(SRpWrongREsult+'GetDeviceCaps(DC,LOGPIXELSX)'+
   ':GetPageSizeTwips');
 if dpiy<1 then
  Raise Exception.Create(SRpWrongREsult+'GetDeviceCaps(DC,LOGPIXELSY)'+
   ':GetPageSizeTwips');

 apagewidth:=GetDeviceCaps(DC,HORZRES);
 apageheight:=GetDeviceCaps(DC,VERTRES);
 if ((apagewidth<1) or (apageheight<1)) then
  Result:=GetPagesizeFromDevMode
 else
 begin
  Result.x:=Round(apagewidth/dpix*TWIPS_PER_INCHESS);
  Result.y:=Round(apageheight/dpiy*TWIPS_PER_INCHESS);
 end;
end;



function GetPhysicPageSizeTwips:TPoint;
var
 DC:HDC;
 dpix,dpiy:integer;
 printererror:boolean;
begin
 if Printer.printers.count<1 then
 begin
  result.y:=16637;
  result.x:=12047;
  exit;
 end;
 // Printer selected not valid error
 DC:=0;
 printererror:=false;
 try
  DC:=Printer.handle;
 except
  printererror:=true;
 end;
 if printererror then
 begin
  result.y:=16637;
  result.x:=12047;
  exit;
 end;
 // Get the device units of
 dpix:=GetDeviceCaps(DC,LOGPIXELSX); //  printer.XDPI;
 dpiy:=GetDeviceCaps(DC,LOGPIXELSY);  // printer.YDPI;

 if dpix<1 then
  Raise Exception.Create(SRpWrongREsult+'GetDeviceCaps(DC,LOGPIXELSX)'+
   ':GetPhysicPageSizeTwips');
 if dpiy<1 then
  Raise Exception.Create(SRpWrongREsult+'GetDeviceCaps(DC,LOGPIXELSY)'+
   ':GetPhysicPageSizeTwips');

 Result.x:=GetDeviceCaps(DC,PHYSICALWIDTH);
 Result.y:=GetDeviceCaps(DC,PHYSICALHEIGHT);
 if ((Result.x<1) or (Result.y<1)) then
 begin
  // Gets the page size from devmode
  Result:=GetPageSizeFromDevMode;
//  Raise Exception.Create(SRpWrongREsult+':'+'GetDeviceCaps(DC,PHYSICALWIDTH)');
 end
 else
 begin
  // Bugfix for axiom printers
  if Result.y<10 then
   Result.y:=Result.x;
  // Transform to twips
  Result.X:=Round(Result.X/dpix*TWIPS_PER_INCHESS);
  Result.Y:=Round(Result.Y/dpiy*TWIPS_PER_INCHESS);
 end;
end;


{    (
      (Width: 8268; Height: 11693),  // psA4
      (Width: 7165; Height: 10118),  // psB5
      (Width: 8500; Height: 11000),  // psLetter
      (Width: 8500; Height: 14000),  // psLegal
      (Width: 7500; Height: 10000),  // psExecutive
      (Width: 33110; Height: 46811), // psA0
      (Width: 23386; Height: 33110), // psA1
      (Width: 16535; Height: 23386), // psA2
      (Width: 11693; Height: 16535), // psA3
      (Width: 5827; Height: 8268),   // psA5
      (Width: 4134; Height: 5827),   // psA6
      (Width: 2913; Height: 4134),   // psA7
      (Width: 2047; Height: 2913),   // psA8
      (Width: 1457; Height: 2047),   // psA9
      (Width: 40551; Height: 57323), // psB0
      (Width: 28661; Height: 40551), // psB1
      (Width: 1260; Height: 1772),   // psB10
      (Width: 20276; Height: 28661), // psB2
      (Width: 14331; Height: 20276), // psB3
      (Width: 10118; Height: 14331), // psB4
      (Width: 5039; Height: 7165),   // psB6
      (Width: 3583; Height: 5039),   // psB7
      (Width: 2520; Height: 3583),   // psB8
      (Width: 1772; Height: 2520),   // psB9
      (Width: 6417; Height: 9016),   // psC5E
      (Width: 4125; Height: 9500),   // psComm10E
      (Width: 4331; Height: 8661),   // psDLE
      (Width: 8250; Height: 13000),  // psFolio
      (Width: 17000; Height: 11000), // psLedger
      (Width: 11000; Height: 17000), // psTabloid
      (Width: -1; Height: -1)        // psNPageSize
    );
}

//  DMPAPER_LETTER      = 1;  { Letter 8 12 x 11 in               }
//  DMPAPER_TABLOID     = 3;  { Tabloid 11 x 17 in                }
//  DMPAPER_LEDGER      = 4;  { Ledger 17 x 11 in                 }
//  DMPAPER_LEGAL       = 5;  { Legal 8 12 x 14 in                }
//  DMPAPER_EXECUTIVE   = 7;  { Executive 7 14 x 10 12 in         }
//  DMPAPER_A3      = 8;      { A3 297 x 420 mm                     }
//  DMPAPER_A4      = 9;      { A4 210 x 297 mm                     }
//  DMPAPER_A5      = 11;     { A5 148 x 210 mm                     }
//  DMPAPER_B4      = 12;     { B4 (JIS) 250 x 354                  }
//  DMPAPER_FOLIO   = 14;     { Folio 8 12 x 13 in                  }
//  DMPAPER_B5      = 13;     { B5 (JIS) 182 x 257 mm               }
//  DMPAPER_A6                  = 70;  { A6 105 x 148 mm                 }
//  DMPAPER_ENV_C5  = 28;     { Envelope C5 162 x 229 mm            }
//  DMPAPER_ENV_10  = 20;     { Envelope #10 4 18 x 9 12            }
//  DMPAPER_ENV_DL  = 27;     { Envelope DL 110 x 220mm             }
//  DMPAPER_A2            = 66;     { A2 420 x 594 mm                     }
(*

  DMPAPER_LETTERSMALL = 2;  { Letter Small 8 12 x 11 in         }
  DMPAPER_STATEMENT   = 6;  { Statement 5 12 x 8 12 in          }
  DMPAPER_A4SMALL = 10;     { A4 Small 210 x 297 mm               }
  DMPAPER_QUARTO  = 15;     { Quarto 215 x 275 mm                 }
  DMPAPER_10X14   = 16;     { 10x14 in                            }
  DMPAPER_11X17   = 17;     { 11x17 in                            }
  DMPAPER_NOTE    = 18;     { Note 8 12 x 11 in                   }
  DMPAPER_ENV_9   = 19;     { Envelope #9 3 78 x 8 78             }
  DMPAPER_ENV_11  = 21;     { Envelope #11 4 12 x 10 38           }
  DMPAPER_ENV_12  = 22;     { Envelope #12 4 \276 x 11            }
  DMPAPER_ENV_14  = 23;     { Envelope #14 5 x 11 12              }
  DMPAPER_CSHEET  = 24;     { C size sheet                        }
  DMPAPER_DSHEET  = 25;     { D size sheet                        }
  DMPAPER_ESHEET  = 26;     { E size sheet                        }
  DMPAPER_ENV_C3  = 29;     { Envelope C3  324 x 458 mm           }
  DMPAPER_ENV_C4  = 30;     { Envelope C4  229 x 324 mm           }
  DMPAPER_ENV_C6  = 31;     { Envelope C6  114 x 162 mm           }
  DMPAPER_ENV_C65  = 32;    { Envelope C65 114 x 229 mm           }
  DMPAPER_ENV_B4   = 33;    { Envelope B4  250 x 353 mm           }
  DMPAPER_ENV_B5   = 34;    { Envelope B5  176 x 250 mm           }
  DMPAPER_ENV_B6   = 35;    { Envelope B6  176 x 125 mm           }
  DMPAPER_ENV_ITALY          = 36;  { Envelope 110 x 230 mm               }
  DMPAPER_ENV_MONARCH        = 37;  { Envelope Monarch 3.875 x 7.5 in     }
  DMPAPER_ENV_PERSONAL       = 38;  { 6 34 Envelope 3 58 x 6 12 in        }
  DMPAPER_FANFOLD_US         = 39;  { US Std Fanfold 14 78 x 11 in        }
  DMPAPER_FANFOLD_STD_GERMAN = 40;  { German Std Fanfold 8 12 x 12 in    }
  DMPAPER_FANFOLD_LGL_GERMAN = 41;  { German Legal Fanfold 8 12 x 13 in  }
  DMPAPER_ISO_B4             = 42;  { B4 (ISO) 250 x 353 mm               }
  DMPAPER_JAPANESE_POSTCARD  = 43;  { Japanese Postcard 100 x 148 mm      }
  DMPAPER_9X11               = 44;  { 9 x 11 in                           }
  DMPAPER_10X11              = 45;  { 10 x 11 in                          }
  DMPAPER_15X11              = 46;  { 15 x 11 in                          }
  DMPAPER_ENV_INVITE         = 47;  { Envelope Invite 220 x 220 mm        }
  DMPAPER_RESERVED_48        = 48;  { RESERVED--DO NOT USE                }
  DMPAPER_RESERVED_49        = 49;  { RESERVED--DO NOT USE                }
  DMPAPER_LETTER_EXTRA       = 50;  { Letter Extra 9 \275 x 12 in         }
  DMPAPER_LEGAL_EXTRA        = 51;  { Legal Extra 9 \275 x 15 in          }
  DMPAPER_TABLOID_EXTRA      = 52;  { Tabloid Extra 11.69 x 18 in         }
  DMPAPER_A4_EXTRA           = 53;  { A4 Extra 9.27 x 12.69 in            }
  DMPAPER_LETTER_TRANSVERSE  = 54;  { Letter Transverse 8 \275 x 11 in    }
  DMPAPER_A4_TRANSVERSE      = 55;  { A4 Transverse 210 x 297 mm          }
  DMPAPER_LETTER_EXTRA_TRANSVERSE = 56;     { Letter Extra Transverse 9\275 x 12 in  }
  DMPAPER_A_PLUS        = 57;     { SuperASuperAA4 227 x 356 mm       }
  DMPAPER_B_PLUS        = 58;     { SuperBSuperBA3 305 x 487 mm       }
  DMPAPER_LETTER_PLUS   = 59;     { Letter Plus 8.5 x 12.69 in          }
  DMPAPER_A4_PLUS       = 60;     { A4 Plus 210 x 330 mm                }
  DMPAPER_A5_TRANSVERSE = 61;     { A5 Transverse 148 x 210 mm          }
  DMPAPER_B5_TRANSVERSE = 62;     { B5 (JIS) Transverse 182 x 257 mm    }
  DMPAPER_A3_EXTRA      = 63;     { A3 Extra 322 x 445 mm               }
  DMPAPER_A5_EXTRA      = $40;    { A5 Extra 174 x 235 mm               }
  DMPAPER_B5_EXTRA      = 65;     { B5 (ISO) Extra 201 x 276 mm         }
  DMPAPER_A3_TRANSVERSE = 67;     { A3 Transverse 297 x 420 mm          }
  DMPAPER_A3_EXTRA_TRANSVERSE = 68;     { A3 Extra Transverse 322 x 445 mm    }
  DMPAPER_DBL_JAPANESE_POSTCARD = 69; { Japanese Double Postcard 200 x 148 mm }
  DMPAPER_JENV_KAKU2          = 71;  { Japanese Envelope Kaku #2       }
  DMPAPER_JENV_KAKU3          = 72;  { Japanese Envelope Kaku #3       }
  DMPAPER_JENV_CHOU3          = 73;  { Japanese Envelope Chou #3       }
  DMPAPER_JENV_CHOU4          = 74;  { Japanese Envelope Chou #4       }
  DMPAPER_LETTER_ROTATED      = 75;  { Letter Rotated 11 x 8 1/2 11 in }
  DMPAPER_A3_ROTATED          = 76;  { A3 Rotated 420 x 297 mm         }
  DMPAPER_A4_ROTATED          = 77;  { A4 Rotated 297 x 210 mm         }
  DMPAPER_A5_ROTATED          = 78;  { A5 Rotated 210 x 148 mm         }
  DMPAPER_B4_JIS_ROTATED      = 79;  { B4 (JIS) Rotated 364 x 257 mm   }
  DMPAPER_B5_JIS_ROTATED      = 80;  { B5 (JIS) Rotated 257 x 182 mm   }
  DMPAPER_JAPANESE_POSTCARD_ROTATED = 81; { Japanese Postcard Rotated 148 x 100 mm }
  DMPAPER_DBL_JAPANESE_POSTCARD_ROTATED = 82; { Double Japanese Postcard Rotated 148 x 200 mm }
  DMPAPER_A6_ROTATED          = 83;  { A6 Rotated 148 x 105 mm         }
  DMPAPER_JENV_KAKU2_ROTATED  = 84;  { Japanese Envelope Kaku #2 Rotated}
  DMPAPER_JENV_KAKU3_ROTATED  = 85;  { Japanese Envelope Kaku #3 Rotated}
  DMPAPER_JENV_CHOU3_ROTATED  = 86;  { Japanese Envelope Chou #3 Rotated}
  DMPAPER_JENV_CHOU4_ROTATED  = 87;  { Japanese Envelope Chou #4 Rotated}
  DMPAPER_B6_JIS              = 88;  { B6 (JIS) 128 x 182 mm           }
  DMPAPER_B6_JIS_ROTATED      = 89;  { B6 (JIS) Rotated 182 x 128 mm   }
  DMPAPER_12X11               = 90;  { 12 x 11 in                      }
  DMPAPER_JENV_YOU4           = 91;  { Japanese Envelope You #4        }
  DMPAPER_JENV_YOU4_ROTATED   = 92;  { Japanese Envelope You #4 Rotated}
  DMPAPER_P16K                = 93;  { PRC 16K 146 x 215 mm            }
  DMPAPER_P32K                = 94;  { PRC 32K 97 x 151 mm             }
  DMPAPER_P32KBIG             = 95;  { PRC 32K(Big) 97 x 151 mm        }
  DMPAPER_PENV_1              = 96;  { PRC Envelope #1 102 x 165 mm    }
  DMPAPER_PENV_2              = 97;  { PRC Envelope #2 102 x 176 mm    }
  DMPAPER_PENV_3              = 98;  { PRC Envelope #3 125 x 176 mm    }
  DMPAPER_PENV_4              = 99;  { PRC Envelope #4 110 x 208 mm    }
  DMPAPER_PENV_5              = 100; { PRC Envelope #5 110 x 220 mm    }
  DMPAPER_PENV_6              = 101; { PRC Envelope #6 120 x 230 mm    }
  DMPAPER_PENV_7              = 102; { PRC Envelope #7 160 x 230 mm    }
  DMPAPER_PENV_8              = 103; { PRC Envelope #8 120 x 309 mm    }
  DMPAPER_PENV_9              = 104; { PRC Envelope #9 229 x 324 mm    }
  DMPAPER_PENV_10             = 105; { PRC Envelope #10 324 x 458 mm   }
  DMPAPER_P16K_ROTATED        = 106; { PRC 16K Rotated                 }
  DMPAPER_P32K_ROTATED        = 107; { PRC 32K Rotated                 }
  DMPAPER_P32KBIG_ROTATED     = 108; { PRC 32K(Big) Rotated            }
  DMPAPER_PENV_1_ROTATED      = 109; { PRC Envelope #1 Rotated 165 x 102 mm}
  DMPAPER_PENV_2_ROTATED      = 110; { PRC Envelope #2 Rotated 176 x 102 mm}
  DMPAPER_PENV_3_ROTATED      = 111; { PRC Envelope #3 Rotated 176 x 125 mm}
  DMPAPER_PENV_4_ROTATED      = 112; { PRC Envelope #4 Rotated 208 x 110 mm}
  DMPAPER_PENV_5_ROTATED      = 113; { PRC Envelope #5 Rotated 220 x 110 mm}
  DMPAPER_PENV_6_ROTATED      = 114; { PRC Envelope #6 Rotated 230 x 120 mm}
  DMPAPER_PENV_7_ROTATED      = 115; { PRC Envelope #7 Rotated 230 x 160 mm}
  DMPAPER_PENV_8_ROTATED      = 116; { PRC Envelope #8 Rotated 309 x 120 mm}
  DMPAPER_PENV_9_ROTATED      = 117; { PRC Envelope #9 Rotated 324 x 229 mm}
  DMPAPER_PENV_10_ROTATED     = 118; { PRC Envelope #10 Rotated 458 x 324 mm }
*)
function GDIPageSizeToQtPageSize (gdisize:TGDIPageSize):TPageSizeQt;
begin
 Result.papersource:=gdisize.papersource;
 Result.duplex:=gdisize.duplex;
 SetForcePaperName(REsult,gdisize.forcepapername);
 Result.Custom:=False;
 case gdisize.PageIndex of
  DMPAPER_LETTERSMALL,// = 2;  { Letter Small 8 12 x 11 in         }
  DMPAPER_STATEMENT,//   = 6;  { Statement 5 12 x 8 12 in          }
  DMPAPER_A4SMALL,// = 10;     { A4 Small 210 x 297 mm               }
  DMPAPER_QUARTO..DMPAPER_ENV_9, //   = 19;     { Envelope #9 3 78 x 8 78             }
  DMPAPER_ENV_11..24,
  30..65,
  67..DMPAPER_DBL_JAPANESE_POSTCARD,// = 69; { Japanese Double Postcard 200 x 148 mm }
  DMPAPER_JENV_KAKU2..DMPAPER_PENV_10_ROTATED://     = 118; { PRC Envelope #10 Rotated 458 x 324 mm }
   Result.Indexqt:=30+gdisize.PageIndex;
  DMPAPER_A4:
   Result.Indexqt:=0;
  DMPAPER_B5:
   Result.Indexqt:=1;
  DMPAPER_LETTER:
   Result.Indexqt:=2;
  DMPAPER_LEGAL:
   Result.Indexqt:=3;
  DMPAPER_EXECUTIVE:
   Result.Indexqt:=4;
  DMPAPER_A2:
   Result.Indexqt:=7;
  DMPAPER_A3:
   Result.Indexqt:=8;
  DMPAPER_A5:
   Result.Indexqt:=9;
  DMPAPER_A6:
   Result.Indexqt:=10;
  DMPAPER_B4:
   Result.Indexqt:=19;
  DMPAPER_ENV_C5:
   Result.Indexqt:=24;
  DMPAPER_ENV_10:
   Result.Indexqt:=25;
  DMPAPER_ENV_DL:
   Result.Indexqt:=26;
  DMPAPER_FOLIO:
   Result.Indexqt:=27;
  DMPAPER_LEDGER:
   Result.Indexqt:=28;
  DMPAPER_TABLOID:
   Result.Indexqt:=29;
  else
  begin
   if gdisize.PageIndex>=0 then
   begin
    Result.Custom:=True;
    // Converts to twips
    Result.Indexqt:=0;
    Result.CustomWidth:=Round(gdisize.Width/100/CMS_PER_INCHESS*TWIPS_PER_INCHESS);
    Result.CustomHeight:=Round(gdisize.Height/100/CMS_PER_INCHESS*TWIPS_PER_INCHESS);
   end
   else
   begin
    Result.indexqt:=0;
    Result.Custom:=False;
   end;
  end;
 end;
end;

function QtPageSizeToGDIPageSize(qtsize:TPageSizeQt):TGDIPageSize;
begin
 Result.papersource:=qtsize.papersource;
 Result.Duplex:=qtsize.duplex;
 Result.ForcePaperName:=qtsize.ForcePaperName;
 if qtsize.Custom then
 begin
  Result.PageIndex:=0;
  // Converts to decs of milimeter
  Result.Width:=Round(qtsize.CustomWidth/TWIPS_PER_INCHESS*CMS_PER_INCHESS*100);
  Result.Height:=Round(qtsize.CustomHeight/TWIPS_PER_INCHESS*CMS_PER_INCHESS*100);
 end
 else
 if qtsize.indexqt>30 then
 begin
  Result.PageIndex:=qtsize.indexqt-30;
 end
 else
 begin
  case qtsize.indexqt of
   0:
    Result.PageIndex:=DMPAPER_A4;
   1:
    Result.PageIndex:=DMPAPER_B5;
   2:
    Result.PageIndex:=DMPAPER_LETTER;
   3:
    Result.PageIndex:=DMPAPER_LEGAL;
   4:
    Result.PageIndex:=DMPAPER_EXECUTIVE;
   5: // A0
    begin
     Result.PageIndex:=0;
     Result.Width:= 33110;
     Result.Height:= 46811;
    end;
   6: // A1
    begin
     Result.PageIndex:=0;
     Result.Width:= 23386;
     Result.Height:= 33110;
    end;
   7:
    Result.PageIndex:=DMPAPER_A2;
   8:
    Result.PageIndex:=DMPAPER_A3;
   9:
    Result.PageIndex:=DMPAPER_A5;
   10:
    Result.PageIndex:=DMPAPER_A6;
   11: // A7
    begin
     Result.PageIndex:=0;
     Result.Width:= 2913;
     Result.Height:= 4134;
    end;
   12: // A8
    begin
     Result.PageIndex:=0;
     Result.Width:= 2047;
     Result.Height:= 2913;
    end;
   13: // A9
    begin
     Result.PageIndex:=0;
     Result.Width:= 1457;
     Result.Height:= 2047;
    end;
   14: // B0
    begin
     Result.PageIndex:=0;
     Result.Width:= 40551;
     Result.Height:= 57323;
    end;
   15: // B1
    begin
     Result.PageIndex:=0;
     Result.Width:= 28661;
     Result.Height:= 40551;
    end;
   16: // B10
    begin
     Result.PageIndex:=0;
     Result.Width:= 1260;
     Result.Height:= 1772;
    end;
   17: // B2
    begin
     Result.PageIndex:=0;
     Result.Width:= 20276;
     Result.Height:= 28661;
    end;
   18: // B3
    begin
     Result.PageIndex:=0;
     Result.Width:= 14331;
     Result.Height:= 20276;
    end;
   19:
    Result.PageIndex:=DMPAPER_B4;
   20: // B6
    begin
     Result.PageIndex:=0;
     Result.Width:= 5039;
     Result.Height:= 7165;
    end;
   21: // B7
    begin
     Result.PageIndex:=0;
     Result.Width:= 3583;
     Result.Height:= 5039;
    end;
   22: // B8
    begin
     Result.PageIndex:=0;
     Result.Width:= 2520;
     Result.Height:= 3583;
    end;
   23: // B9
    begin
     Result.PageIndex:=0;
     Result.Width:= 1772;
     Result.Height:= 2520;
    end;
   24:
    Result.PageIndex:=DMPAPER_ENV_C5;
   25:
    Result.PageIndex:=DMPAPER_ENV_10;
   26:
    Result.PageIndex:=DMPAPER_ENV_DL;
   27:
    Result.PageIndex:=DMPAPER_FOLIO;
   28:
    Result.PageIndex:=DMPAPER_LEDGER;
   29:
    Result.PageIndex:=DMPAPER_TABLOID;
   else
    Result.PageIndex:=DMPAPER_A4;
  end;
  if Result.PageIndex=0 then
  begin
   // Converts to decs of milimeter
   Result.Width:=Round(Result.Width*1000/2540);
   Result.Height:=Round(Result.Height*1000/2540);
  end
  else
  begin
   Result.Width:=0;
   Result.Height:=0;
  end;
 end;
end;


function GetPageSizeFromDevMode:TPoint;
var
 gdipage:TGDIPageSize;
begin
 gdipage:=GetCurrentPaper;
 Result.x:=Round(gdipage.FormWidth/100/CMS_PER_INCHESS*TWIPS_PER_INCHESS);
 Result.y:=Round(gdipage.FormHeight/100/CMS_PER_INCHESS*TWIPS_PER_INCHESS);
end;

(*
function GetCurrentPaper:TGDIPageSize;
var
 FPrinterHandle:THandle;
{$IFNDEF DOTNETD}
 DeviceMode: THandle;
 Device, Driver, Port: array[0..1023] of char;
 pdevmode:^DEVMODE;
{$ENDIF}
{$IFDEF DOTNETD}
 DeviceMode: IntPtr;
 PDevMode :  TDeviceMode;
 Device, Driver, Port:String;
{$ENDIF}
 printererror:Boolean;
 PrinterName:String;
 asize:Integer;
begin
 if printer.printers.count<1 then
 begin
  Result.PageIndex:=DMPAPER_A4;
  Result.Width:=0;
  Result.Height:=0;
  Result.FormWidth:=2100;
  Result.FormHeight:=2970;
  exit;
 end;
 // Printer selected not valid error
 printererror:=false;
 try
  Printer.GetPrinter(Device, Driver, Port, DeviceMode);
  PrinterName := Format('%s', [Device]);
 except
  printererror:=true;
 end;
{$IFNDEF DOTNETD}
 if DeviceMode=0 then
{$ENDIF}
{$IFDEF DOTNETD}
 if Not Assigned(DeviceMode) then
{$ENDIF}
  printererror:=true;
 if printererror then
 begin
  Result.PageIndex:=DMPAPER_A4;
  Result.Width:=0;
  Result.Height:=0;
  Result.FormWidth:=2100;
  Result.FormHeight:=2970;
  exit;
 end;
 Result.FormWidth:=0;
 Result.FormHeight:=0;
 if OpenPrinter(Device,fprinterhandle,nil) then
 begin
  try
   pdevmode:=AllocMem(sizeof(devmode));
   try
    asize:=DocumentProperties(0,fprinterhandle,Device,pdevmode^,pdevmode^,0);
    if asize>0 then
    begin
     FreeMem(pdevmode);
     pdevmode:=AllocMem(asize);
     if IDOK=DocumentProperties(0,fprinterhandle,Device,pdevmode^,pdevmode^,DM_OUT_BUFFER) then
     begin
      // Orientation
      if (pdevmode^.dmFields AND DM_ORIENTATION)>0 then
      begin
       if pdevmode^.dmOrientation=1 then
        Result.landscape:=false
       else
       if pdevmode^.dmOrientation=2 then
        Result.landscape:=true
      end;
      if PDevMode.dmPapersize>=256 then
      begin
       Result.PageIndex:= 0;     { User defined (custom page size) }
       Result.Height:=PDevMode.dmPaperlength;
       Result.Width:=PDevMode.dmPaperwidth;
       Result.papername:=PDevmode.dmFormName;
       Result.FormWidth:=PDevMode.dmPaperwidth;
       Result.FormHeight:=PDevMode.dmPaperLength;
      end
      else
      begin
       REsult.PageIndex:=PDevMode.dmPaperSize;
       Result.Height:=0;
       Result.Width:=0;
       Result.FormWidth:=PdevMode.dmPaperwidth;
       Result.FormHeight:=PdevMode.dmPaperLength;
       Result.papername:=PDevmode.dmFormName;
      end;
     end
     else
     begin
      Result.PageIndex:=DMPAPER_A4;
      Result.Width:=0;
      Result.Height:=0;
      Result.FormWidth:=PDevMode.dmPaperwidth;
      Result.FormHeight:=PDevMode.dmPaperLength;
     end;
    end;
   finally
    FreeMem(pdevmode);
   end;
  finally
   ClosePrinter(fprinterhandle);
  end;
 end;
end;
*)

// Gets current paper page size old version
// That checks for existent forms
function GetCurrentPaper:TGDIPageSize;
var
{$IFNDEF DOTNETD}
  DeviceMode: THandle;
  PDevMode :  ^TDeviceMode;
  Device, Driver, Port: array[0..1023] of char;
  pforminfo:^Form_info_1;
{$ENDIF}
{$IFDEF DOTNETD}
  DeviceMode: IntPtr;
  PDevMode :  TDeviceMode;
  Device, Driver, Port:String;
  pforminfo:Form_info_1;
  apforminfo:IntPtr;
{$ENDIF}
  printererror:boolean;
  Handle:THandle;
  printername:String;
  laste:integer;
  needed:DWord;
begin
 if printer.printers.count<1 then
 begin
  Result.PageIndex:=DMPAPER_A4;
  Result.Width:=0;
  Result.Height:=0;
  Result.FormWidth:=2100;
  Result.FormHeight:=2970;
  exit;
 end;
 // Printer selected not valid error
 printererror:=false;
 try
  Printer.GetPrinter(Device, Driver, Port, DeviceMode);
  PrinterName := Format('%s', [Device]);
 except
  printererror:=true;
 end;
{$IFNDEF DOTNETD}
 if DeviceMode=0 then
{$ENDIF}
{$IFDEF DOTNETD}
 if Not Assigned(DeviceMode) then
{$ENDIF}
  printererror:=true;
 if printererror then
 begin
  Result.PageIndex:=DMPAPER_A4;
  Result.Width:=0;
  Result.Height:=0;
  Result.FormWidth:=2100;
  Result.FormHeight:=2970;
  exit;
 end;
 Result.FormWidth:=0;
 Result.FormHeight:=0;
{$IFNDEF DOTNETD}
 PDevMode := GlobalLock(DeviceMode);
{$ENDIF}
{$IFDEF DOTNETD}
 PDevMode := TDeviceMode(Marshal.PtrToStructure(GlobalLock(Integer(DeviceMode)),TypeOf(TDeviceMode)));
{$ENDIF}
 // Warning the custom page size does not work in all drivers
 // especially in Windows NT drivers
 Result.landscape:=false;
 if (PDevMode.dmFields AND DM_ORIENTATION>0) then
 begin
  Result.landscape:=PDevMode.dmOrientation=2;
 end;
 if PDevMode.dmPapersize>=256 then
 begin
  Result.PageIndex:= 0;     { User defined (custom page size) }
  Result.Height:=PDevMode.dmPaperlength;
  Result.Width:=PDevMode.dmPaperwidth;
  Result.papername:=PDevmode.dmFormName;
  if ((PDevMode.dmFields AND DM_FORMNAME)>0) then
  begin
   Result.FormWidth:=PDevmode.dmPaperWidth;
   Result.FormHeight:=PDevmode.dmPaperLength;
  end;
  if Length(Result.PaperName)>0 then
  begin
{$IFDEF DOTNETD}
   if not OpenPrinter(PrinterName, Handle, nil) then
{$ENDIF}
{$IFNDEF DOTNETD}
   if not OpenPrinter(PChar(PrinterName), Handle, nil) then
{$ENDIF}
    RaiseLastOSError;
   try
{$IFNDEF DOTNETD}
    pforminfo:=allocmem(sizeof(form_info_1));
    try
     if Not GetForm(handle,Pchar(Result.papername),1,pforminfo,sizeof(Form_info_1),needed) then
{$ENDIF}
{$IFDEF DOTNETD}
    apforminfo:=Marshal.AllocHGlobal(needed);
    pforminfo:=Form_info_1(Marshal.PtrToStructure(apforminfo,TypeOf(form_info_1)));
    try
     if Not GetForm(handle,Result.papername,1,pforminfo,needed,needed) then
{$ENDIF}
     begin
      laste:=GetLasterror;
      if ((laste<>122) AND (Laste<>123) AND (laste<>1902)) then
       RaiseLastOSError
      else
      begin
       if laste<>1902 then
       begin
        if needed>0 then
        begin
{$IFNDEF DOTNETD}
         freemem(pforminfo);
         pforminfo:=AllocMem(needed);
         if Not GetForm(handle,Pchar(Result.papername),1,pforminfo,needed,needed) then
{$ENDIF}
{$IFDEF DOTNETD}
         Marshal.FreeHGlobal(apforminfo);
         apforminfo:=Marshal.AllocHGlobal(needed);
         pforminfo:=Form_info_1(Marshal.PtrToStructure(apforminfo,TypeOf(form_info_1)));
         if Not GetForm(handle,Result.papername,1,pforminfo,needed,needed) then
{$ENDIF}
          RaiseLastOSError;
         Result.Height:=pforminfo.Size.cy div 100;
         Result.Width:=pforminfo.Size.cx div 100;
        end;
       end;
      end;
     end
     else
     begin
      Result.Height:=pforminfo.Size.cy div 100;
      Result.Width:=pforminfo.Size.cx div 100;
     end;
    finally
{$IFNDEF DOTNETD}
     freemem(pforminfo);
{$ENDIF}
{$IFDEF DOTNETD}
     Marshal.FreeHGlobal(apforminfo);
{$ENDIF}
    end;
   finally
    ClosePrinter(Handle);
   end;
  end;
 end
 else
 begin
  REsult.PageIndex:=PDevMode.dmPaperSize;
  Result.Height:=0;
  Result.Width:=0;
  Result.papername:=PDevmode.dmFormName;
 end;
 Result.papersource:=PDevMode.dmDefaultSource;
 Result.duplex:=PDevMode.dmDuplex;
{$IFNDEF DOTNETD}
 GlobalUnLock(DeviceMode);
{$ENDIF}
{$IFDEF DOTNETD}
 GlobalUnLock(Integer(DeviceMode));
{$ENDIF}
end;




{$IFNDEF DOTNETD}
procedure SendControlCodeToPrinter(S: string);
var
 Handle, hDeviceMode: THandle;
 N: DWORD;
 DocInfo1: TDocInfo1;
 Device, Driver, Port: array[0..255] of char;
 PrinterName: string;
 buf:pchar;
 lbuf:integer;
begin
 Printer.GetPrinter(Device, Driver, Port, hDeviceMode);
 PrinterName := Format('%s', [Device]);
 if not OpenPrinter(PChar(PrinterName), Handle, nil) then
   RaiseLastOSError;
 try
  with DocInfo1 do
  begin
   pDocName := 'Control';
   pOutputFile := nil;
   pDataType := 'RAW';
  end;
  StartDocPrinter(Handle, 1, @DocInfo1);
  try
//   StartPagePrinter(Handle);
   lbuf:=length(s);
   buf:=Allocmem(lbuf+2);
   try
    copymemory(buf,Pchar(s),lbuf);
    if not WritePrinter(Handle, buf, lbuf, N) then
     RaiseLastOSError;
   finally
    freemem(buf);
   end;
//   EndPagePrinter(Handle);
  finally
   EndDocPrinter(Handle);
  end;
 finally
  ClosePrinter(Handle);
 end;
end;


function GetPrinters: TStrings;
var
  Buffer, PrinterInfo: PChar;
  Flags, Count, NumInfo: DWORD;
  I: Integer;
  Level: Byte;
begin
  if FPrinters = nil then
  begin
    FPrinters := TStringList.Create;
    Result := FPrinters;
    try
      if Win32Platform = VER_PLATFORM_WIN32_NT then
      begin
        Flags := PRINTER_ENUM_CONNECTIONS or PRINTER_ENUM_LOCAL;
        Level := 4;
      end
      else
      begin
        Flags := PRINTER_ENUM_LOCAL;
        Level := 5;
      end;
      Count := 0;
      EnumPrinters(Flags, nil, Level, nil, 0, Count, NumInfo);
      if Count = 0 then Exit;
      GetMem(Buffer, Count);
      try
        if not EnumPrinters(Flags, nil, Level, PByte(Buffer), Count, Count, NumInfo) then
          Exit;
        PrinterInfo := Buffer;
        for I := 0 to NumInfo - 1 do
        begin
          if Level = 4 then
            with PPrinterInfo4(PrinterInfo)^ do
            begin
              FPrinters.Add(pPrinterName);
              Inc(PrinterInfo, sizeof(TPrinterInfo4));
            end
          else
            with PPrinterInfo5(PrinterInfo)^ do
            begin
              FPrinters.Add(pPrinterName);
              Inc(PrinterInfo, sizeof(TPrinterInfo5));
            end;
        end;
      finally
        FreeMem(Buffer, Count);
      end;
    except
      FPrinters.Free;
      FPrinters := nil;
      raise;
    end;
  end;
  Result := FPrinters;
end;

function FindFormNameFromSize(width,height:integer):String;
var
 pforms,p:^Form_info_1;
 needed,received:dword;
 fprinterhandle:THandle;
 buf:Pchar;
 i:integer;
 cadenaimp:String;
 forminfo:Form_info_1;
begin
 cadenaimp:=GetPrinters[Printer.PrinterIndex];
 buf:=Pchar(cadenaimp);
 Result:='';
 if Not OpenPrinter(buf,fprinterhandle,nil) then
   Raise Exception.create(SRpError+Strpas(buf));
 try
  pforms:=nil;
  if Not EnumForms(fprinterhandle,1,pforms,0,needed,received) then
    if GetLastError<>122 then
     RaiseLastOSError;
  pforms:=Allocmem(needed);
  try
   if NOt EnumForms(fprinterhandle,1,pforms,needed,needed,received) then
    RaiseLastOSError;
   for i:=0 to received-1 do
   begin
    p:=Pointer(integer(pforms)+sizeof(Form_info_1)*i);
    forminfo:=p^;
    if forminfo.Size.cx=width*100 then
     if forminfo.Size.cy=height*100 then
     begin
      Result:=StrPas(forminfo.pName);
     end;
   end;
  finally
   Freemem(pforms);
  end;
 finally
  ClosePrinter(fprinterhandle);
 end;
end;

procedure SetCurrentPaper(apapersize:TGDIPageSize);
var
  Device, Driver, Port: array[0..1023] of char;
  DeviceMode: THandle;
  PDevmode:^TDevicemode;
  pforminfo:^Form_info_1;
  printername,apapername:string;
  FPrinterHandle:THandle;
  foundpaper:boolean;
  forcepapername:boolean;
  needed:DWord;
  printererror:boolean;
  laste:integer;
begin
 if printer.Printers.count<1 then
  exit;
 apapername:='';
 // Printer selected not valid error
 printererror:=false;
 try
  Printer.GetPrinter(Device, Driver, Port, DeviceMode);
 except
  printererror:=true;
 end;
 if DeviceMode=0 then
  printererror:=true;
 if printererror then
  exit;
 PDevMode := GlobalLock(DeviceMode);
 try
  // Custom page size, warning not all drivers supports it
  // especially Windows NT drivers
  // In Windows NT only Administrator has rights to add a
  // custom paper once added it's stored until the print driver
  // is removed
  if (apapersize.PageIndex=0) then
  begin
   if Not IsWIndowsNT then
   begin
    // If is not Windows NT select custom paper
    PDevMode.dmPaperSize := 256;
    PDevMode.dmPaperlength := apapersize.Height;
    PDevMode.dmPaperwidth  := apapersize.Width;
   end
   else
   begin
    foundpaper:=false;
    forcepapername:=false;
    // In Windows NT we must search or create a form
    if Length(apapersize.ForcePaperName)>0 then
    begin
     apapername:=apapersize.ForcePaperName;
     foundpaper:=true;
     forcepapername:=true;
    end
    else
     apapername:=FindFormNameFromSize(apapersize.Width,apapersize.Height);
    if Length(apapername)>0 then
     foundpaper:=true;
    if not foundpaper then
    begin
     // Busquem un form que s'adapti
     apapername:='User ('+
     IntToStr(apapersize.Width)+'x'+
     IntToStr(apapersize.Height)+')';
    end;
    PrinterName := Format('%s', [Device]);
    if not OpenPrinter(PChar(PrinterName), FPrinterHandle, nil) then
     RaiseLastOSError;
    try
     if Not forcepapername then
     begin
      pforminfo:=allocmem(sizeof(form_info_1));
      try
       if Not GetForm(FPrinterhandle,Pchar(apapername),1,pforminfo,sizeof(Form_info_1),needed) then
       begin
        laste:=GetLasterror;
        if ((laste<>122) AND (Laste<>123) AND (laste<>1902)) then
         RaiseLastOSError
        else
        begin
         if laste<>1902 then
         begin
          if needed>0 then
          begin
           freemem(pforminfo);
           pforminfo:=AllocMem(needed);
           if Not GetForm(FPrinterhandle,Pchar(apapername),1,pforminfo,needed,needed) then
            RaiseLastOSError;
          if pforminfo^.pname<>nil then
           foundpaper:=true;
          // Si l'ha trobat trobem el seu index
          end;
         end;
        end;
       end;
       if Not foundpaper then
       begin
        pforminfo^.pname:=Pchar(apapername);
        pforminfo^.Flags:=FORM_USER;
        pforminfo^.Size.cx:=apapersize.Width*100;
        pforminfo^.size.cy:=apapersize.Height*100;
        pforminfo^.ImageableArea.Top:=0;
        pforminfo^.ImageableArea.left:=0;
        pforminfo^.ImageableArea.Right:=pforminfo^.Size.cx;
        pforminfo^.ImageableArea.Bottom:=pforminfo^.size.cy;
        try
         if not AddForm(fprinterhandle,1,pforminfo) then
          RaiseLastOSError;
        except
         on E:Exception do
         begin
          E.Message:=SRpErrorCreatingPaper+apapername+#10+E.Message;
          Raise;
         end;
        end;
       end;
      finally
       freemem(pforminfo);
      end;
     end;
     // Select by name
     StrPCopy(PDevMode.dmFormName,Copy(apapername,1,32));
     PDevMode.dmFields:=PDevMode.dmFields or dm_formname;
     PDevMode.dmFields:=PDevMode.dmFields AND (NOT dm_papersize);
    finally
     ClosePrinter(FPrinterhandle);
    end;
   end;
  end
  else
  begin
   PDevMode.dmFields:=PDevMode.dmFields or dm_papersize;
   PDevMode.dmPaperSize :=apapersize.PageIndex;
   PDevMode.dmPaperlength := apapersize.Height;
   PDevMode.dmPaperwidth  := apapersize.Width;
  end;
  if apapersize.papersource>0 then
  begin
   PDevMode.dmFields:=PDevMode.dmFields or dm_defaultsource;
   PDevMode.dmDefaultSource:=apapersize.papersource;
  end;
  if apapersize.duplex>0 then
  begin
   PDevMode.dmFields:=PDevMode.dmFields or dm_duplex;
   PDevMode.dmDuplex:=apapersize.duplex;
  end;
 finally
  GlobalUnLock(DeviceMode);
 end;
 if not printer.Printing then
  Printer.SetPrinter(Device, Driver, Port, DeviceMode)
 else
 begin
  DocumentProperties(0,Printer.Handle,Device, PDevMode^,
        PDevMode^, DM_MODIFY);
  ResetDC(Printer.Handle,PDevMode^);
 end;
end;


{$ENDIF}
{$IFDEF DOTNETD}
procedure SendControlCodeToPrinter(S: string);
var
 hDeviceMode: IntPtr;
 Handle:THandle;
 N: DWORD;
 DocInfo1: TDocInfo1;
 pdocinfo: IntPtr;
 Device, Driver, Port: String;
 PrinterName: string;
 lbuf:integer;
 buf:IntPtr;
begin
 Printer.GetPrinter(Device, Driver, Port, hDeviceMode);
 PrinterName := Format('%s', [Device]);
 if not OpenPrinter(PrinterName, Handle, nil) then
   RaiseLastOSError;
 try
  with DocInfo1 do
  begin
   pDocName := 'Control';
   pOutputFile := nil;
   pDataType := 'RAW';
  end;
  pdocinfo:=Marshal.AllocHGlobal(sizeof(TDocInfo1));
  Marshal.StructureToPtr(DocInfo1,pdocinfo,true);
  StartDocPrinter(Handle, 1, pdocinfo);
  try
//   StartPagePrinter(Handle);
   buf:=Marshal.StringToHGlobalAnsi(s);
   lbuf:=length(s);
   if not WritePrinter(Handle, buf, lbuf, N) then
    RaiseLastOSError;
//   EndPagePrinter(Handle);
  finally
   EndDocPrinter(Handle);
  end;
 finally
  ClosePrinter(Handle);
 end;
end;


function GetPrinters: TStrings;
var
 i:integer;
begin
 if FPrinters = nil then
 begin
  FPrinters.Assign(Printer.Printers);
 end;
 Result:=FPrinters;
end;


procedure SetCurrentPaper(apapersize:TGDIPageSize);
var
  Device, Driver, Port: String;
  DeviceMode: IntPtr;
  PDevmode:TDevicemode;
  pforms:IntPtr;
  pforminfo:Form_info_1;
  printername,apapername:string;
  FPrinterHandle:THandle;
  foundpaper:boolean;
  needed:DWord;
  printererror:boolean;
  laste:integer;
begin
 if printer.Printers.count<1 then
  exit;
 // Printer selected not valid error
 printererror:=false;
 try
  Printer.GetPrinter(Device, Driver, Port, DeviceMode);
 except
  printererror:=true;
 end;
{$IFNDEF DOTNETD}
 if DeviceMode=0 then
{$ENDIF}
{$IFDEF DOTNETD}
 if Not Assigned(DeviceMode) then
{$ENDIF}
  printererror:=true;
 if printererror then
  exit;
 PDevMode := TDeviceMode(Marshal.PtrToStructure(GlobalLock(Integer(DeviceMode)),TypeOf(TDeviceMode)));
 try
  // Custom page size, warning not all drivers supports it
  // especially Windows NT drivers
  // In Windows NT only Administrator has rights to add a
  // custom paper once added it's stored until the print driver
  // is removed
  if apapersize.PageIndex=0 then
  begin
   if Not IsWIndowsNT then
   begin
    // If is not Windows NT select custom paper
    PDevMode.dmPaperSize := 256;
    PDevMode.dmPaperlength := apapersize.Height;
    PDevMode.dmPaperwidth  := apapersize.Width;
   end
   else
   begin
    foundpaper:=false;
    // In Windows NT we must search or create a form
    apapername:=FindFormNameFromSize(apapersize.Width,apapersize.Height);
    if Length(apapername)>0 then
     foundpaper:=true;
    if not foundpaper then
    begin
     // Busquem un form que s'adapti
     apapername:='User ('+
     IntToStr(apapersize.Width)+'x'+
     IntToStr(apapersize.Height)+')';
    end;
    PrinterName := Format('%s', [Device]);
    if not OpenPrinter(PrinterName, FPrinterHandle, nil) then
     RaiseLastOSError;
    try
     if Not GetForm(FPrinterhandle,apapername,1,pforminfo,sizeof(Form_info_1),needed) then
     begin
      laste:=GetLasterror;
      if ((laste<>122) AND (Laste<>123) AND (laste<>1902)) then
       RaiseLastOSError
      else
      begin
       if laste<>1902 then
       begin
        if needed>0 then
        begin
         pforminfo:=Form_info_1(Marshal.PtrToStructure(Marshal.AllocHGlobal(needed),TypeOf(form_info_1)));
         if Not GetForm(FPrinterhandle,apapername,1,pforminfo,needed,needed) then
          RaiseLastOSError;
        if pforminfo.pname<>nil then
         foundpaper:=true;
        // Si l'ha trobat trobem el seu index
        end;
       end;
      end;
     end;
     if Not foundpaper then
     begin
      pforminfo.pname:=apapername;
      pforminfo.Flags:=FORM_USER;
      pforminfo.Size.cx:=apapersize.Width*100;
      pforminfo.size.cy:=apapersize.Height*100;
      pforminfo.ImageableArea.Top:=0;
      pforminfo.ImageableArea.left:=0;
      pforminfo.ImageableArea.Right:=pforminfo.Size.cx;
      pforminfo.ImageableArea.Bottom:=pforminfo.size.cy;
      try
       if not AddForm(fprinterhandle,1,pforminfo) then
        RaiseLastOSError;
      except
       on E:Exception do
       begin
        Raise Exception.Create(SRpErrorCreatingPaper+apapername+#10+E.Message);
       end;
      end;
     end;
     // Select by name
{$IFDEF DOTNETD}
     PDevMode.dmFormName:=Copy(apapername,1,32);
{$ENDIF}
{$IFNDEF DOTNETD}
     StrPCopy(PDevMode.dmFormName,Copy(apapername,1,32));
{$ENDIF}
     PDevMode.dmFields:=PDevMode.dmFields or dm_formname;
     PDevMode.dmFields:=PDevMode.dmFields AND (NOT dm_papersize);
    finally
     ClosePrinter(FPrinterhandle);
    end;
   end;
  end
  else
  begin
   PDevMode.dmPaperSize :=apapersize.PageIndex;
   PDevMode.dmPaperlength := apapersize.Height;
   PDevMode.dmPaperwidth  := apapersize.Width;
  end;
  if apapersize.papersource>0 then
   PDevMode.dmDefaultSource:=apapersize.papersource;
  if apapersize.papersource>0 then
  begin
   PDevMode.dmFields:=PDevMode.dmFields or dm_defaultsource;
   PDevMode.dmDefaultSource:=apapersize.papersource;
  end;
  if apapersize.duplex>0 then
  begin
   PDevMode.dmFields:=PDevMode.dmFields or dm_duplex;
   PDevMode.dmDuplex:=apapersize.duplex;
  end;
 finally
  GlobalUnLock(Integer(DeviceMode));
 end;
 Printer.SetPrinter(Device, Driver, Port, DeviceMode);
end;


function FindFormNameFromSize(width,height:integer):String;
var
// pforms,p:^Form_info_1;
 pforms,p:IntPtr;
 needed,received:dword;
 fprinterhandle:THandle;
 aprintername:String;
 i:integer;
 cadenaimp:String;
 forminfo:Form_info_1;
begin
 aprintername:=GetPrinters[Printer.PrinterIndex];
 Result:='';
 if Not OpenPrinter(aprintername,fprinterhandle,nil) then
   Raise Exception.create(SRpError+aprintername);
 try
  pforms:=nil;
  if Not EnumForms(fprinterhandle,1,pforms,0,needed,received) then
    if GetLastError<>122 then
     RaiseLastOSError;
  pforms:=Marshal.AllocHGlobal(needed);
  try
   if NOt EnumForms(fprinterhandle,1,pforms,needed,needed,received) then
    RaiseLastOSError;
   for i:=0 to received-1 do
   begin
    p:=IntPtr(Integer(pforms)+sizeof(Form_info_1)*i);
//    forminfo:=p^;
    forminfo:=Form_info_1(Marshal.PtrToStructure(p,TypeOf(form_info_1)));
    if forminfo.Size.cx=width*100 then
     if forminfo.Size.cy=height*100 then
     begin
      Result:=forminfo.pName;
     end;
   end;
  finally
   Marshal.FreeHGlobal(pforms);
  end;
 finally
  ClosePrinter(fprinterhandle);
 end;
end;

{$ENDIF}



{procedure FillFormsList(FormsList:TStringList);
var
 pforms,p:^Form_info_1;
 buf:Pchar;
 fprinterhandle:THandle;
 needed,received:dword;
 forminfo:Form_info_1;
 i:integer;
 indexprint:integer;
 llistaf:TStringList;
 cadenaimp:string;
 formobject:TPrinterForm;
begin
 FormsList.clear;
 for indexprint:=0 to printer.Printers.count-1 do
 begin
  cadenaimp:=GetPrinters[indexprint];
  buf:=Pchar(cadenaimp);
  if Not OpenPrinter(buf,fprinterhandle,nil) then
    Raise Exception.create(SRpError+Strpas(buf));
  try
   // Creeem un objecte de llista de forms
   llistaf:=TStringList.Create;
   FormsList.AddObject(cadenaimp,llistaf);
   pforms:=nil;
   if Not EnumForms(fprinterhandle,1,pforms,0,needed,received) then
    if GetLastError<>122 then
     RaiseLastOSError;
   pforms:=Allocmem(needed);
   try
    if NOt EnumForms(fprinterhandle,1,pforms,needed,needed,received) then
     RaiseLastOSError;
    for i:=0 to received-1 do
    begin
     p:=Pointer(integer(pforms)+sizeof(Form_info_1)*i);
     forminfo:=p^;
     formobject:=TPrinterForm.Create;
     formobject.Forminfo:=forminfo;
     formobject.name:=StrPas(forminfo.pName);
     llistaf.AddObject(formobject.name,formobject);
    end;
   finally
    Freemem(pforms);
   end;
  finally
   ClosePrinter(fprinterhandle);
  end;
 end;
end;
}

function PrinterSupportsCollation:Boolean;
var
{$IFDEF DOTNETD}
  Device, Driver, Port: String;
  DeviceMode: IntPtr;
{$ENDIF}
{$IFNDEF DOTNETD}
  Device, Driver, Port: array[0..1023] of char;
  DeviceMode: THandle;
{$ENDIF}
  printererror:boolean;
  aresult:DWord;
begin
 Result:=false;
 if printer.Printers.count<1 then
  exit;
 // Printer selected not valid error
 printererror:=false;
 try
  Printer.GetPrinter(Device, Driver, Port, DeviceMode);
 except
  printererror:=true;
 end;
{$IFNDEF DOTNETD}
 if DeviceMode=0 then
{$ENDIF}
{$IFDEF DOTNETD}
 if Not Assigned(DeviceMode) then
{$ENDIF}
  printererror:=true;
 if printererror then
  exit;
 try
  aresult:=DeviceCapabilities(Device,Port,DC_COLLATE,nil,nil);
  // Function fail =-1
  if aresult>0 then
    Result:=true;
 except
 end;
end;


function PrinterMaxCopiesSupport:Integer;
var
{$IFDEF DOTNETD}
  Device, Driver, Port: String;
  DeviceMode: IntPtr;
{$ENDIF}
{$IFNDEF DOTNETD}
  Device, Driver, Port: array[0..1023] of char;
  DeviceMode: THandle;
{$ENDIF}
  printererror:boolean;
  maxcopies:integer;
begin
 Result:=1;
 if printer.Printers.count<1 then
  exit;
 maxcopies:=1;
 // Printer selected not valid error
 printererror:=false;
 try
  Printer.GetPrinter(Device, Driver, Port, DeviceMode);
 except
  printererror:=true;
 end;
{$IFNDEF DOTNETD}
 if DeviceMode=0 then
{$ENDIF}
{$IFDEF DOTNETD}
 if Not Assigned(DeviceMode) then
{$ENDIF}
  printererror:=true;
 if printererror then
  exit;
 try
   maxcopies:=DeviceCapabilities(Device,Port,DC_COPIES,nil,nil);
   if maxcopies<0 then
    maxcopies:=1;
 except
 end;
 Result:=maxcopies;
end;

function PrinterSupportsCopies(copies:integer):Boolean;
var
 maxcopies:integer;
begin
 maxcopies:=PrinterMaxCopiesSupport;
 Result:=maxcopies>copies;
end;

procedure SetPrinterCopies(copies:integer);
var
{$IFDEF DOTNETD}
  DeviceMode: IntPtr;
  PDevMode :  TDeviceMode;
  Device, Driver, Port: String;
{$ENDIF}
{$IFNDEF DOTNETD}
  DeviceMode: THandle;
  PDevMode :  ^TDeviceMode;
  Device, Driver, Port: array[0..1023] of char;
{$ENDIF}
  printererror:boolean;
begin
 if printer.Printers.count<1 then
  exit;
 // Printer selected not valid error
 printererror:=false;
 try
  Printer.GetPrinter(Device, Driver, Port, DeviceMode);
 except
  printererror:=true;
 end;
{$IFNDEF DOTNETD}
 if DeviceMode=0 then
{$ENDIF}
{$IFDEF DOTNETD}
 if Not Assigned(DeviceMode) then
{$ENDIF}
  printererror:=true;
 if printererror then
  exit;
{$IFDEF DOTNETD}
 PDevMode := TDeviceMode(Marshal.PtrToStructure(GlobalLock(Integer(DeviceMode)),TypeOf(TDeviceMode)));
{$ENDIF}
{$IFNDEF DOTNETD}
 PDevMode := GlobalLock(DeviceMode);
{$ENDIF}
 try
  PDevMode.dmCopies:=copies;
 finally
{$IFNDEF DOTNETD}
  GlobalUnLock(DeviceMode);
{$ENDIF}
{$IFDEF DOTNETD}
  GlobalUnLock(Integer(DeviceMode));
{$ENDIF}
 end;
 Printer.SetPrinter(Device, Driver, Port, DeviceMode);
end;

function GetPrinterCopies:Integer;
var
{$IFDEF DOTNETD}
  Device, Driver, Port: String;
  DeviceMode: IntPtr;
  PDevmode:TDevicemode;
{$ENDIF}
{$IFNDEF DOTNETD}
  Device, Driver, Port: array[0..1023] of char;
  DeviceMode: THandle;
  PDevmode:^TDevicemode;
{$ENDIF}
  printererror:boolean;
begin
 Result:=1;
 if printer.Printers.count<1 then
  exit;
 // Printer selected not valid error
 printererror:=false;
 try
  Printer.GetPrinter(Device, Driver, Port, DeviceMode);
 except
  printererror:=true;
 end;
{$IFNDEF DOTNETD}
 if DeviceMode=0 then
{$ENDIF}
{$IFDEF DOTNETD}
 if Not Assigned(DeviceMode) then
{$ENDIF}
  printererror:=true;
 if printererror then
  exit;
{$IFDEF DOTNETD}
 PDevMode := TDeviceMode(Marshal.PtrToStructure(GlobalLock(Integer(DeviceMode)),TypeOf(TDeviceMode)));
{$ENDIF}
{$IFNDEF DOTNETD}
 PDevMode := GlobalLock(DeviceMode);
{$ENDIF}
 try
  Result:=PDevMode.dmCopies;
 finally
{$IFNDEF DOTNETD}
  GlobalUnLock(DeviceMode);
{$ENDIF}
{$IFDEF DOTNETD}
  GlobalUnLock(Integer(DeviceMode));
{$ENDIF}
 end;
 Printer.SetPrinter(Device, Driver, Port, DeviceMode);
end;

procedure SetPrinterCollation(collation:boolean);
var
{$IFDEF DOTNETD}
  Device, Driver, Port: String;
  DeviceMode: IntPtr;
  PDevmode:TDevicemode;
{$ENDIF}
{$IFNDEF DOTNETD}
  Device, Driver, Port: array[0..1023] of char;
  DeviceMode: THandle;
  PDevmode:^TDevicemode;
{$ENDIF}
  printererror:boolean;
begin
 if printer.Printers.count<1 then
  exit;
 // Printer selected not valid error
 printererror:=false;
 try
  Printer.GetPrinter(Device, Driver, Port, DeviceMode);
 except
  printererror:=true;
 end;
{$IFNDEF DOTNETD}
 if DeviceMode=0 then
{$ENDIF}
{$IFDEF DOTNETD}
 if Not Assigned(DeviceMode) then
{$ENDIF}
  printererror:=true;
 if printererror then
  exit;
{$IFDEF DOTNETD}
 PDevMode := TDeviceMode(Marshal.PtrToStructure(GlobalLock(Integer(DeviceMode)),TypeOf(TDeviceMode)));
{$ENDIF}
{$IFNDEF DOTNETD}
 PDevMode := GlobalLock(DeviceMode);
{$ENDIF}
 try
  if collation then
   PDevMode.dmCollate:=DMCOLLATE_TRUE
  else
   PDevMode.dmCollate:=DMCOLLATE_FALSE;
 finally
{$IFNDEF DOTNETD}
  GlobalUnLock(DeviceMode);
{$ENDIF}
{$IFDEF DOTNETD}
  GlobalUnLock(Integer(DeviceMode));
{$ENDIF}
 end;
 Printer.SetPrinter(Device, Driver, Port, DeviceMode);
end;

function GetPrinterCollation:Boolean;
var
{$IFDEF DOTNETD}
  Device, Driver, Port: String;
  DeviceMode: IntPtr;
  PDevmode:TDevicemode;
{$ENDIF}
{$IFNDEF DOTNETD}
  Device, Driver, Port: array[0..1023] of char;
  DeviceMode: THandle;
  PDevmode:^TDevicemode;
{$ENDIF}
  printererror:boolean;
begin
 Result:=false;
 if printer.Printers.count<1 then
  exit;
 // Printer selected not valid error
 printererror:=false;
 try
  Printer.GetPrinter(Device, Driver, Port, DeviceMode);
 except
  printererror:=true;
 end;
{$IFNDEF DOTNETD}
 if DeviceMode=0 then
{$ENDIF}
{$IFDEF DOTNETD}
 if Not Assigned(DeviceMode) then
{$ENDIF}
  printererror:=true;
 if printererror then
  exit;
{$IFDEF DOTNETD}
 PDevMode := TDeviceMode(Marshal.PtrToStructure(GlobalLock(Integer(DeviceMode)),TypeOf(TDeviceMode)));
{$ENDIF}
{$IFNDEF DOTNETD}
 PDevMode := GlobalLock(DeviceMode);
{$ENDIF}
 try
  Result:=PDevMode.dmCollate=DMCOLLATE_TRUE;
 finally
{$IFNDEF DOTNETD}
  GlobalUnLock(DeviceMode);
{$ENDIF}
{$IFDEF DOTNETD}
  GlobalUnLock(Integer(DeviceMode));
{$ENDIF}
 end;
 Printer.SetPrinter(Device, Driver, Port, DeviceMode);
end;



function SearchnodeInt(ATree:TTreeView;astring:String;anode:TTreeNode):TTreeNode;
var
 i:integer;
 firstname:string;
begin
 firstname:=GetFirstName(astring);
 Result:=nil;
 for i:=0 to anode.Count-1 do
 begin
  if firstname=anode.Item[i].Text then
  begin
   if firstname=astring then
   begin
    Result:=anode.Item[i];
   end
   else
    Result:=Searchnodeint(ATree,Copy(astring,length(firstname)+2,length(astring)),anode.Item[i]);
  end;
 end;
 if Not Assigned(Result) then
 begin
  Result:=ATree.Items.AddChild(anode,firstname);
  Result.ImageIndex:=2;
  if firstname<>astring then
  begin
   Result:=Searchnodeint(ATree,Copy(astring,length(firstname)+2,length(astring)),Result);
  end;
 end;
end;

function Searchnode(FTopItems:TStringList;ATree:TTreeView;astring:String):TTreeNode;
var
 i:integer;
 firstname:string;
begin
 firstname:=GetFirstName(astring);
 Result:=nil;
 for i:=0 to FTopItems.Count-1 do
 begin
  if firstname=FTopItems.Strings[i] then
  begin
   if firstname=astring then
   begin
    Result:=TTreeNode(FTopItems.Objects[i]);
   end
   else
    Result:=Searchnodeint(ATree,Copy(astring,length(firstname)+2,length(astring)),TTreeNode(FTopItems.Objects[i]));
  end;
 end;
 if Not Assigned(Result) then
 begin
  Result:=ATree.Items.AddChild(nil,firstname);
  Result.ImageIndex:=2;
  FTopItems.AddObject(firstname,Result);
  if firstname<>astring then
  begin
   Result:=Searchnodeint(ATree,Copy(astring,length(firstname)+2,length(astring)),Result);
  end;
 end;
end;



procedure FillTreeView(ATree:TTreeView;alist:TStringList);
var
 newitem,anode:TTreeNode;
 astring:string;
 repname,dirname:String;
 i:integer;
 FTopItems:TStringList;
begin
 FTopitems:=TStringList.Create;
 try
  for i:=0 to alist.count-1 do
  begin
   if Length(alist.Strings[i])<1 then
    continue;
   astring:=alist.Strings[i];
   repname:=GetLastName(astring);
   dirname:=GetPathName(astring);
   anode:=SearchNode(FTopItems,ATree,dirname);
   newitem:=ATree.Items.AddChild(anode,repname);
   newitem.ImageIndex:=3;
  end;
 finally
  FTopItems.Free;
 end;
end;


function GetFullFileName(ANode:TTreeNode;dirseparator:char):String;
begin
 if Assigned(ANode.Parent) then
  Result:=GetFullFileName(ANode.Parent,dirseparator)+dirseparator+ANode.Text
 else
  Result:=ANode.Text;
end;


end.
