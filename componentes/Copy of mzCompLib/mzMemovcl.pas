unit mzMemovcl;

interface

uses
  SysUtils, Classes, Controls, StdCtrls, Graphics, mzCompLibvcl;

type

  TmzMemovcl = class(TMemo)
  private
    { Private declarations }
    InLabel    : TmzBoundLabel;
    nDistancia : Integer;
    sFieldName : string;
    procedure SetaDistancia(Valor:integer);
  protected
    { Protected declarations }
    procedure SetParent(Value: TwinControl); override;
  public
    { Public declarations }
    procedure   _AdjustLabel;
    procedure   SetBounds(ALeft: Integer; ATop: Integer; AWidth: Integer; AHeight: Integer); override;
    constructor Create(AOwner: TComponent); override;
    procedure   Notification(AComponent: TComponent; Operation: TOperation); override;
  published
    { Published declarations }
    property Align;
    property FieldName: String          read sFieldName write sFieldName;
    property TextLabel : TmzBoundLabel  read InLabel    write InLabel;
    property TextLabelSpacing : Integer read nDistancia write SetaDistancia;
  end;

procedure Register;

implementation

constructor TmzMemovcl.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
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



procedure TmzMemovcl._AdjustLabel;
begin
   InLabel.SetBounds(Self.Left, Self.Top - InLabel.Height-nDistancia, InLabel.Width, InLabel.Height);
end;

procedure TmzMemovcl.SetParent(Value: TWinControl);
begin
  inherited SetParent(Value);
  if InLabel = nil then exit;
  InLabel.Parent := Value;
  InLabel.Visible := True;
end;


procedure TmzMemovcl.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  _AdjustLabel;
end;

procedure TmzMemovcl.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent = InLabel) and (Operation = opRemove) then
    InLabel := nil;
end;

procedure TmzMemovcl.SetaDistancia(Valor:integer);
begin
  nDistancia := Valor;
  _AdjustLabel;
end;


procedure Register;
begin
  RegisterComponents('Master', [TmzMemovcl]);
end;

end.
