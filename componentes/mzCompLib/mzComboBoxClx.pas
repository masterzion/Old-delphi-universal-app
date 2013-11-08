unit mzComboBoxClx;

interface

uses
  SysUtils, Classes, QControls, QStdCtrls, QGraphics, mzCompLib;

type
  TmzComboBoxClx = class(TComboBox)
  private
    { Private declarations }
    InLabel    : TmzBoundLabel;
    nDistancia : Integer;
    sFieldName : string;
    procedure SetaDistancia(Valor:integer);
  protected
    { Protected declarations }
    procedure SetParent(const Value: TWidgetControl); override;
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

procedure TmzComboBoxClx.SetaDistancia(Valor:integer);
begin
  nDistancia := Valor;
  _AdjustLabel;
end;


procedure TmzComboBoxClx._AdjustLabel;
begin
   InLabel.SetBounds(Self.Left, Self.Top - InLabel.Height-nDistancia, InLabel.Width, InLabel.Height);
end;

procedure TmzComboBoxClx.SetParent(const Value: TWidgetControl);
begin
  inherited SetParent(Value);
  if InLabel = nil then exit;
  InLabel.Parent := Value;
  InLabel.Visible := True;
end;

constructor TmzComboBoxClx.Create(AOwner : TComponent);
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

procedure TmzComboBoxClx.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  _AdjustLabel;
end;

procedure TmzComboBoxClx.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent = InLabel) and (Operation = opRemove) then
    InLabel := nil;
end;

function TmzComboBoxClx.GetIndexValue:Integer;
begin
  Result := ItemIndex;
end;

procedure TmzComboBoxClx.SetIndexValue(InValue:Integer);
begin
  ItemIndex := InValue;
end;



procedure Register;
begin
  RegisterComponents('Master', [TmzComboBoxClx]);
end;

end.
