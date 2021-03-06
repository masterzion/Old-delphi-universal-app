{*******************************************************}
{                                                       }
{       Report Manager                                  }
{                                                       }
{       rprfvarams                                      }
{                                                       }
{       User parameters form (VCL version)              }
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

unit rprfvparams;

interface

{$I rpconf.inc}

uses SysUtils, Classes,
  Graphics, Forms,
  Buttons, ExtCtrls, Controls, StdCtrls,
  rpmdconsts,rptypes,ComCtrls,rpmaskedit,
{$IFDEF USEVARIANTS}
  Variants,
{$ENDIF}
  rpparams;

const
  CONS_LEFTGAP=3;
  CONS_LABELTOPGAP=2;
  CONS_CONTROLGAP=5;
  CONS_RIGHTBARGAP=25;
  CONS_NULLWIDTH=50;
  CONS_MAXCLIENTHEIGHT=400;
type
  TFRpRTParams = class(TForm)
    PModalButtons: TPanel;
    BOK: TButton;
    BCancel: TButton;
    MainScrollBox: TScrollBox;
    PParent: TPanel;
    Splitter1: TSplitter;
    PLeft: TPanel;
    PRight: TPanel;
    procedure BOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    fparams:TRpParamList;
    dook:boolean;
    lnulls,lcontrols:TStringList;
    procedure SetParams(avalue:TRpParamList);
    procedure SaveParams;
  public
    { Public declarations }
    procedure CheckNullClick(Sender:TObject);
    property params:TRpParamList read fparams write Setparams;
  end;


function ShowUserParams(params:TRpParamList):boolean;

implementation

{$R *.dfm}

function ShowUserParams(params:TRpParamList):boolean;
var
 dia:TFRpRTParams;
 oneparam:boolean;
 i:integer;
begin
 Result:=false;
 oneparam:=false;
 for i:=0 to params.count-1 do
 begin
  if (params.items[i].Visible and (not params.items[i].NeverVisible)) then
  begin
   oneparam:=true;
   break;
  end;
 end;
 if not oneparam then
 begin
  Result:=true;
  exit;
 end;
 dia:=TFRpRTParams.Create(Application);
 try
  dia.params:=Params;
  dia.showmodal;
  if dia.dook then
  begin
   params.Assign(dia.Params);
   Result:=true;
  end;
 finally
  dia.Free;
 end;
end;

procedure TFRpRTParams.BOKClick(Sender: TObject);
begin
 SaveParams;
 dook:=true;
 close;
end;

procedure TFRpRTParams.FormCreate(Sender: TObject);
begin
 fparams:=TRpParamList.Create(Self);
 lcontrols:=TStringList.Create;
 lnulls:=TStringList.Create;
 BOK.Caption:=TranslateStr(93,BOK.Caption);
 BCancel.Caption:=TranslateStr(94,BCancel.Caption);
 Caption:=TranslateStr(238,Caption);
end;

procedure TFRpRTParams.SetParams(avalue:TRpParamList);
var
 i:integer;
 alabel:TLabel;
 acontrol:TControl;
 posy:integer;
 aparam:TRpParam;
 TotalWidth:integer;
 achecknull:TCheckBox;
 NewClientHeight:integer;
begin
 acontrol:=nil;
 fparams.assign(avalue);
 TotalWidth:=PRight.Width-CONS_NULLWIDTH-CONS_RIGHTBARGAP;
 posy:=CONS_CONTROLGAP;
 // Creates all controls from params
 for i:=0 to fparams.Count-1 do
 begin
  aparam:=fparams.Items[i];
  if ((aparam.Visible) and (not aparam.NeverVisible)) then
  begin
   alabel:=TLabel.Create(Self);
   alabel.Caption:=aparam.Description;
   aLabel.Left:=CONS_LEFTGAP;
   aLabel.Top:=posy+CONS_LABELTOPGAP;
   aLabel.Hint:=aparam.Hint;
   alabel.Parent:=PLeft;
   achecknull:=TCheckBox.Create(Self);
   achecknull.Left:=TotalWidth-CONS_NULLWIDTH;
   achecknull.Top:=posy;
   achecknull.Tag:=i;
   achecknull.Width:=CONS_NULLWIDTH;
   achecknull.Left:=TotalWidth;
   achecknull.Caption:=SRpNull;
   achecknull.Parent:=PRight;
   achecknull.Anchors:=[akTop,akRight];
   achecknull.OnClick:=CheckNullClick;
   achecknull.Visible:=aparam.AllowNulls;
   lnulls.AddObject(aparam.Name,acheckNull);
   case aparam.ParamType of
    rpParamString,rpParamExpreA,rpParamExpreB,rpParamSubst,rpParamUnknown:
     begin
      acontrol:=TEdit.Create(Self);
      if aparam.IsReadOnly then
      begin
       TEdit(acontrol).Color:=Self.Color;
      end;
      acontrol.tag:=i;
      lcontrols.AddObject(aparam.Name,acontrol);
      TEdit(acontrol).Text:='';
      if aparam.Value=Null then
      begin
       achecknull.Checked:=true;
      end
      else
      begin
       TEdit(acontrol).Text:=aparam.Value;
      end;
     end;
   rpParamInteger,rpParamDouble,rpParamCurrency:
     begin
      acontrol:=TRpMaskEdit.Create(Self);
      if aparam.IsReadOnly then
      begin
       TRpMaskEdit(acontrol).Color:=Self.Color;
      end;
      acontrol.tag:=i;
      lcontrols.AddObject(aparam.Name,acontrol);
      TEdit(acontrol).Text:='0';
      TRpMaskEdit(acontrol).DisplayMask:='####,##0.##';
      if aparam.ParamType=rpParamInteger then
       TRpMaskEdit(acontrol).EditType:=teInteger
      else
       TRpMaskEdit(acontrol).EditType:=teCurrency;
      if aparam.Value=Null then
      begin
       achecknull.Checked:=true;
      end
      else
      begin
       TEdit(acontrol).Text:=VarToStr(aparam.Value);
      end;
     end;
   rpParamDate:
     begin
      acontrol:=TDateTimePicker.Create(Self);
      if aparam.IsReadOnly then
      begin
       TDateTimePicker(acontrol).Color:=Self.Color;
      end;
      TDateTimePicker(acontrol).Kind:=dtkDate;
      acontrol.tag:=i;
      lcontrols.AddObject(aparam.Name,acontrol);
      if aparam.Value=Null then
      begin
       achecknull.Checked:=true;
      end
      else
      begin
{$IFNDEF DOTNETD}
       TDateTimePicker(acontrol).Date:=TDateTime(aparam.Value);
{$ENDIF}
{$IFDEF DOTNETD}
       TDateTimePicker(acontrol).Date:=TDate(aparam.Value);
{$ENDIF}
      end;
     end;
   rpParamTime:
     begin
      acontrol:=TDateTimePicker.Create(Self);
      if aparam.IsReadOnly then
      begin
       TDateTimePicker(acontrol).Color:=Self.Color;
      end;
      TDateTimePicker(acontrol).Kind:=dtkTime;
      acontrol.tag:=i;
      lcontrols.AddObject(aparam.Name,acontrol);
      if aparam.Value=Null then
      begin
       achecknull.Checked:=true;
      end
      else
      begin
{$IFDEF DOTNETD}
       TDateTimePicker(acontrol).Time:=TTime(aparam.Value);
{$ENDIF}
{$IFNDEF DOTNETD}
       TDateTimePicker(acontrol).Time:=TDateTime(aparam.Value);
{$ENDIF}
      end;
     end;
   rpParamDateTime:
     begin
      acontrol:=TEdit.Create(Self);
      if aparam.IsReadOnly then
      begin
       TEdit(acontrol).Color:=Self.Color;
      end;
      acontrol.tag:=i;
      lcontrols.AddObject(aparam.Name,acontrol);
      TEdit(acontrol).Text:=DateTimeToStr(now);
      if aparam.Value=Null then
      begin
       achecknull.Checked:=true;
      end
      else
      begin
       TEdit(acontrol).Text:=DateTimeToStr(aparam.Value);
      end;
     end;
   rpParamBool:
     begin
      acontrol:=TComboBox.Create(Self);
      if aparam.IsReadOnly then
      begin
       TComboBox(acontrol).Color:=Self.Color;
      end;
      TComboBox(acontrol).Style:=csDropDownList;
      acontrol.tag:=i;
      lcontrols.AddObject(aparam.Name,acontrol);
      // Can't add items without a parent
      acontrol.parent:=MainScrollBox;
      TComboBox(acontrol).Items.Add(BoolToStr(false,true));
      TComboBox(acontrol).Items.Add(BoolToStr(true,true));
      TComboBox(acontrol).ItemIndex:=0;
      if aparam.Value=Null then
      begin
       achecknull.Checked:=true;
      end
      else
      begin
       if Boolean(aparam.value) then
        TComboBox(acontrol).ItemIndex:=1
       else
        TComboBox(acontrol).ItemIndex:=0;
      end;
     end;
   rpParamList:
     begin
      acontrol:=TComboBox.Create(Self);
      if aparam.IsReadOnly then
      begin
       TComboBox(acontrol).Color:=Self.Color;
      end;
      TComboBox(acontrol).Style:=csDropDownList;
      acontrol.tag:=i;
      lcontrols.AddObject(aparam.Name,acontrol);
      // Can't add items without a parent
      acontrol.parent:=MainScrollBox;
      TComboBox(acontrol).Items.Assign(aparam.Items);
      if aparam.Value=Null then
      begin
       achecknull.Checked:=true;
      end
      else
      begin
       TComboBox(acontrol).ItemIndex:=aparam.Values.IndexOf(aparam.Value);
      end;
     end;
   end;
   acontrol.Top:=Posy;
   acontrol.Hint:=aparam.Hint;
   if aparam.IsReadOnly then
   begin
    acontrol.Enabled:=false;
   end;
   acontrol.Left:=CONS_LEFTGAP;
   acontrol.Width:=TotalWidth-acontrol.Left;
   if aparam.allownulls then
    if VarIsNull(aparam.Value) then
     acontrol.Visible:=false;
   acontrol.parent:=PRight;
   acontrol.Anchors:=[akLeft,akTop,akRight];
   if Not assigned(ActiveControl) then
    ActiveControl:=TWinControl(acontrol);
   Posy:=PosY+acontrol.Height+CONS_CONTROLGAP;
  end
  else
  begin
   lcontrols.AddObject('',nil);
   lnulls.AddObject('',nil);
  end;
 end;
 PParent.Height:=PosY;
 // Set the height of the form
 NewClientHeight:=PModalButtons.Height+PosY+CONS_CONTROLGAP;
 if  NewClientHeight>CONS_MAXCLIENTHEIGHT then
  NewClientHeight:=CONS_MAXCLIENTHEIGHT;
 ClientHeight:=NewClientHeight;
end;

procedure TFRpRTParams.FormDestroy(Sender: TObject);
begin
 lcontrols.free;
 lnulls.free;
end;

procedure TFRpRTParams.CheckNullClick(Sender:TObject);
begin
 if TCheckBox(Sender).Checked then
 begin
  TControl(lcontrols.Objects[TCheckBox(Sender).Tag]).Visible:=false;
 end
 else
 begin
  TControl(lcontrols.Objects[TCheckBox(Sender).Tag]).Visible:=true;
 end;
end;

procedure TFRpRTParams.SaveParams;
var
 i,index:integer;
begin
 for i:=0 to fparams.Count-1 do
 begin
  if fparams.items[i].Visible then
  begin
   if TCheckBox(Lnulls.Objects[i]).Checked then
   begin
    fparams.items[i].Value:=Null;
   end
   else
   begin
    case fparams.Items[i].ParamType of
     rpParamString:
      begin
       fparams.items[i].Value:=TEdit(LControls.Objects[i]).Text;
      end;
     rpParamInteger:
      begin
       fparams.items[i].Value:=StrToInt(TEdit(LControls.Objects[i]).Text);
      end;
     rpParamDouble:
      begin
       fparams.items[i].Value:=StrToFloat(TEdit(LControls.Objects[i]).Text);
      end;
     rpParamCurrency:
      begin
       fparams.items[i].Value:=StrtoCurr(TEdit(LControls.Objects[i]).Text);
      end;
     rpParamDate:
      begin
       fparams.items[i].Value:=Variant(TDateTimePicker(LControls.Objects[i]).Date);
      end;
     rpParamTime:
      begin
       fparams.items[i].Value:=Variant(TDateTimePicker(LControls.Objects[i]).Time);
      end;
     rpParamDateTime:
      begin
       fparams.items[i].Value:=StrtoDateTime(TEdit(LControls.Objects[i]).Text);
      end;
     rpParamBool:
      begin
       fparams.items[i].Value:=StrtoBool(TComboBox(LControls.Objects[i]).Text);
      end;
     rpParamList:
      begin
       index:=TComboBox(LControls.Objects[i]).ItemIndex;
       if index<fparams.items[i].Values.Count then
        fparams.items[i].Value:=fparams.items[i].Values.Strings[index]
       else
        fparams.items[i].Value:='';
      end;
      else
      begin
       fparams.items[i].Value:=TEdit(LControls.Objects[i]).Text;
      end;
    end;
   end;
  end;
 end;
end;

end.
