unit mzMemoCLX;

interface

uses
  SysUtils, Classes, QControls, QStdCtrls, QGraphics, mzCompLib;

type
  TmzMemo = class(TMemo)
  private
    { Private declarations }
    InLabel    : TmzBoundLabel;
    nDistancia : Integer;
    sFieldName : string;
    procedure SetaDistancia(Valor:integer);
  protected
    { Protected declarations }
    procedure SetParent(const Value: TWidgetControl); override;
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

procedure TmzMemo.SetaDistancia(Valor:integer);
begin
  nDistancia := Valor;
  _AdjustLabel;
end;


procedure TmzMemo._AdjustLabel;
begin
   InLabel.SetBounds(Self.Left, Self.Top - InLabel.Height-nDistancia, InLabel.Width, InLabel.Height);
end;

procedure TmzMemo.SetParent(const Value: TWidgetControl);
begin
  inherited SetParent(Value);
  if InLabel = nil then exit;
  InLabel.Parent := Value;
  InLabel.Visible := True;
end;

constructor TmzMemo.Create(AOwner : TComponent);
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

procedure TmzMemo.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  _AdjustLabel;
end;

procedure TmzMemo.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent = InLabel) and (Operation = opRemove) then
    InLabel := nil;
end;


procedure Register;
begin
  RegisterComponents('Master', [TmzMemo]);
end;

end.
