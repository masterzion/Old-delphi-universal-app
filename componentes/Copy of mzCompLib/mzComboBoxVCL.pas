unit mzComboBoxVCL;

interface

uses
  SysUtils, Classes, Controls, StdCtrls, Graphics, mzCompLibvcl;

type
  TmzComboBoxvcl = class(TComboBox)
  private
    { Private declarations }
    InLabel    : TmzBoundLabel;
    nDistancia : Integer;
    sFieldName : string;
    procedure SetaDistancia(Valor:integer);
  protected
    { Protected declarations }
    procedure SetParent(AParent: TWinControl); override;
    function GetIndexValue:Integer; virtual;
    procedure SetIndexValue(InValue:Integer); virtual;
  public
    { Public declarations }
    procedure _AdjustLabel;
    procedure SetBounds(ALeft: Integer; ATop: Integer; AWidth: Integer; AHeight: Integer); override;
    constructor Create(AOwner: TComponent); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  published
    { Published declarations }
    property Align;
    property ValueIndex:Integer         read GetIndexValue write SetIndexValue;
    property FieldName: String          read sFieldName write sFieldName;
    property TextLabel : TmzBoundLabel  read InLabel    write InLabel;
    property TextLabelSpacing : Integer read nDistancia write SetaDistancia;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
  end;

procedure Register;

implementation

procedure TmzComboBoxvcl.SetaDistancia(Valor:integer);
begin
  nDistancia := Valor;
  _AdjustLabel;
end;


procedure TmzComboBoxvcl._AdjustLabel;
begin
   InLabel.SetBounds(Self.Left, Self.Top - InLabel.Height-nDistancia, InLabel.Width, InLabel.Height);
end;

procedure TmzComboBoxvcl.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if InLabel = nil then exit;
  InLabel.Parent := AParent;
  InLabel.Visible := True;
end;

constructor TmzComboBoxvcl.Create(AOwner : TComponent);
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

procedure TmzComboBoxvcl.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  _AdjustLabel;
end;

procedure TmzComboBoxvcl.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent = InLabel) and (Operation = opRemove) then
    InLabel := nil;
end;

function TmzComboBoxvcl.GetIndexValue:Integer;
begin
  Result := ItemIndex;
end;

procedure TmzComboBoxvcl.SetIndexValue(InValue:Integer);
begin
  ItemIndex := InValue;
end;



procedure Register;
begin
  RegisterComponents('Master', [TmzComboBoxvcl]);
end;

end.
