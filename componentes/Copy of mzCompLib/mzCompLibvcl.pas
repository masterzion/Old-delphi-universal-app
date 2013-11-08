unit mzCompLibvcl;

interface
uses
 Controls, Classes, StdCtrls, SysUtils;

const
   RETUNR_KEY = 4100;
   RETUNR_KEY2 = 4101;
   NUMEROS     = '0123456789';


type
  TArStr = array of string;
  TmzBoundLabel = class(TCustomLabel)
  private
    function GetTop: Integer;
    function GetLeft: Integer;
    function GetWidth: Integer;
    function GetHeight: Integer;
    procedure SetHeight(const Value: Integer);
    procedure SetWidth(const Value: Integer);
  protected
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Caption;
    property Color;
    property FocusControl;
    property AutoSize;
    property DragMode;
    property Font;
    property Height: Integer read GetHeight write SetHeight;
    property Left: Integer read GetLeft;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowAccelChar;
    property ShowHint;
    property Top: Integer read GetTop;
    property Transparent;
    property Layout;
    property WordWrap;
    property Width: Integer read GetWidth write SetWidth;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

function IsNumber(Texto:Char):Boolean;
function StrIsNumber(Texto:String; Decimal:Boolean):Boolean;


implementation


constructor TmzBoundLabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Name := 'SubLabel';  { do not localize }
  SetSubComponent(True);
  if Assigned(AOwner) then Caption := AOwner.Name;
end;

function TmzBoundLabel.GetHeight: Integer;
begin
  Result := inherited Height;
end;

function TmzBoundLabel.GetLeft: Integer;
begin
  Result := inherited Left;
end;

function TmzBoundLabel.GetTop: Integer;
begin
  Result := inherited Top;
end;

function TmzBoundLabel.GetWidth: Integer;
begin
  Result := inherited Width;
end;

procedure TmzBoundLabel.SetHeight(const Value: Integer);
begin
  SetBounds(Left, Top, Width, Value);
end;

procedure TmzBoundLabel.SetWidth(const Value: Integer);
begin
  SetBounds(Left, Top, Value, Height);
end;

function IsNumber(Texto:Char):Boolean;
begin
  Result := True;
  if pos(texto, NUMEROS) = 0 then Result := False;
end;

function StrIsNumber(Texto:String; Decimal:Boolean):Boolean;
var
  n : Integer;
  bDecimal : Boolean;
  InChar :Char;
begin
  Result := True;
  bDecimal := False;

  for n := 1 to Length(Texto) do begin
    InChar := texto[n];

    if (InChar = DecimalSeparator) and not Decimal then begin
       Result := False;
       Exit;
    end;

    if (InChar = '-') and (n > 1) then begin
       Result := False;
       Exit;
    end;

    if (InChar = DecimalSeparator) and bDecimal  then begin
       Result := False;
       Exit;
    end;
    if (InChar = DecimalSeparator) then bDecimal := True;

    if (InChar <> DecimalSeparator) and (InChar <> '-') then
      if not IsNumber(InChar) then begin
         Result := False;
         Exit;
      end;
  end;
end;


end.

