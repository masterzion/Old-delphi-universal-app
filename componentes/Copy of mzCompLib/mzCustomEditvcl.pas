unit mzCustomEditvcl;

{
Name: Jairo M. de Barros Júnior
E-Mail: master@mortal.co.uk
http://www.centraljairo.hpg.com.br
}
interface

uses
  SysUtils, Classes, Controls, StdCtrls, Graphics, Mask, mzCompLibvcl;

const mskTipos : string = 'LlAaCc09#';

type
  TmzCustomEditvcl = class(TMaskEdit)
  private
  protected
    sFieldName : string;
    InLabel : TmzBoundLabel;
    nDistancia : Integer;
    Branco  : Boolean;
    Cor : Integer;
    procedure SetaDistancia(Valor:integer);
    procedure SetNullData(Val : Boolean);
    function  RemoveMask(InTexto,InMask:string):String;
    procedure Change; override;
    procedure SetParent(Value: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetBounds(ALeft: Integer; ATop: Integer; AWidth: Integer; AHeight: Integer); override;
    procedure UpdateColor;
    procedure _AdjustLabel;
    function IsEmpty:Boolean;
    property Align;
//    property EchoMode;
    property FieldName: String          read sFieldName write sFieldName;
    property TextLabel : TmzBoundLabel  read InLabel write InLabel;
    property TextLabelSpacing : Integer read nDistancia write SetaDistancia;
    property NullData : Boolean         read Branco write SetNullData;
    property OnChange;
  end;

implementation
uses  mzDBLabelvcl;

// ***************** Edit x Label  *****************
constructor TmzCustomEditvcl.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  Cor := Color;
  Branco := True;

  InLabel := TmzBoundLabel.Create(Self);
  InLabel.AutoSize  := True;
  InLabel.Parent := Self.Parent;
  InLabel.Transparent := True;
  InLabel.Caption := 'Caption';
  InLabel.FocusControl := Self;
  InLabel.Name := 'SubLabel';
  InLabel.Font.Color := clNavy;
  InLabel.Font.Name  := 'Helvetica';
  InLabel.Font.Style := [fsBold];
  nDistancia := 2;
  InLabel.FreeNotification(Self);
  _AdjustLabel;
end;

procedure TmzCustomEditvcl._AdjustLabel;
begin
   InLabel.SetBounds(Self.Left, Self.Top - InLabel.Height-nDistancia, InLabel.Width, InLabel.Height);
end;

procedure TmzCustomEditvcl.SetaDistancia(Valor:integer);
begin
  nDistancia := Valor;
  _AdjustLabel;
end;

procedure TmzCustomEditvcl.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  _AdjustLabel;
end;

procedure TmzCustomEditvcl.SetParent(Value: TWinControl);
begin
  inherited SetParent(Value);
  if InLabel = nil then exit;
  InLabel.Parent := Value;
  InLabel.Visible := True;
end;


procedure TmzCustomEditvcl.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent = InLabel) and (Operation = opRemove) then
    InLabel := nil;
end;

// ***************** Edit  *****************
procedure TmzCustomEditvcl.SetNullData(Val : Boolean);
begin
  Branco := Val;
  UpdateColor;
end;

procedure TmzCustomEditvcl.Change;
begin
  inherited;
  UpdateColor;
end;

function TmzCustomEditvcl.IsEmpty:Boolean;
var
 Texto : string;
begin
  Texto := RemoveMask(Self.Text, Self.EditMask);
  Result := (Texto = '');
end;

procedure TmzCustomEditvcl.UpdateColor;
begin
  if (not Branco) and IsEmpty and (not ReadOnly) then
    Color := clRed
  else
    Color := Cor;
end;

function TmzCustomEditvcl.RemoveMask(InTexto,InMask:string):String;
var
  sResultado, NewMask,sMask:String;
  IgnoreNext : Boolean;
  n: Integer;
begin
  if (InMask = '') then begin
    Result := InTexto;
    exit;
  end;

  sMask := InMask;
  sMask := copy(sMask,0,pos(';',sMask)-1);
  IgnoreNext := False;

  for n := 1 to Length(sMask) do
     if (pos(sMask[n], '><!') <> 0) then delete(sMask,n,1);

  for n := 1 to Length(sMask) do
   if IgnoreNext then
      IgnoreNext := False
   else begin
      if sMask[n] = '\' then begin
         NewMask := NewMask+sMask[n+1];
         IgnoreNext := True;
       end
       else begin
          if pos(sMask[n], mskTipos) <> 0 then
            NewMask := NewMask+' '
          else
            NewMask := NewMask+sMask[n];
       end;
   end;

   if (Length(InTexto) > 0) then
    for n := 1 to length(NewMask) do
     if (NewMask[n] = ' ') then
      sResultado := sResultado + InTexto[n];

  Result := trim(sResultado);
end;



end.
