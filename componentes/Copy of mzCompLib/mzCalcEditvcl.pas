unit mzCalcEditVCL;

interface

uses
  SysUtils, Classes, Controls, StdCtrls, ExtCtrls, Graphics,
  ComCtrls, Math, Forms, Grids, Types, Buttons,
  mzCustomBtnEditvcl, mzCompLibvcl;


type
  TEndCalcvcl = procedure(Calc : string) of object;

  TOperatorvcl = (opNull, opMais, opMenos, opDividir, opVezes);

  TmzCalcVCL = class(TPanel)
  private
    { Private declarations }
    // Edit
    PanelEdit: TPanel;
    Edit: TEdit;
    PanelGeral: TPanel;

    //Operadores
    PanelOpera: TPanel;
    btnMais: TSpeedButton;
    btnMenos: TSpeedButton;
    btnVezes: TSpeedButton;
    btnDividir: TSpeedButton;
    btnPerc: TSpeedButton;

    //Numeros
    PanelNum: TPanel;
    btn1: TSpeedButton;
    btn2: TSpeedButton;
    btn3: TSpeedButton;
    btn4: TSpeedButton;
    btn5: TSpeedButton;
    btn6: TSpeedButton;
    btn7: TSpeedButton;
    btn8: TSpeedButton;
    btn9: TSpeedButton;
    btn0: TSpeedButton;
    btnPonto: TSpeedButton;
    btnigual: TSpeedButton;
    btnC: TSpeedButton;
    btnCE: TSpeedButton;


    //Variaveis
    Operador : TOperatorvcl;
    Operando : Extended;
    bBranco, bDecimal : Boolean;
    FEndCalc : TEndCalcvcl;

    //Eventos
    procedure btnNumClick(Sender: TObject);
    procedure btnLimpaClick(Sender: TObject);
    procedure btnOperaClick(Sender: TObject);
    procedure btnIgualClick(Sender: TObject);
    procedure btnPontoClick(Sender: TObject);
    procedure btnPercClick(Sender: TObject);
    procedure btnCClick(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);

    function GetValue: string;
    procedure SetValue(Valor:String);
  protected
    { Protected declarations }
  public
    { Public declarations }
    procedure Clear;
    constructor Create(AOwner: TComponent); override;
    procedure SetFocus; override;
  published
    { Published declarations }
    property Value : string        read GetValue write SetValue;
    property OnEndCalc :  TEndCalcvcl read FEndCalc  write FEndCalc;
  end;



 TDropDownCalcVCL = class(TPersistent)
  private
    { Private declarations }
    FWidth: Integer;
    FHeight: Integer;
    procedure SetWidth(const Value: Integer);
    procedure SetHeight(const Value: Integer);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create;
  published
    { Published declarations }
    property Width: Integer read FWidth write SetWidth;
    property Height: Integer read FHeight write SetHeight;
 end;

  TmzCalcEditVCL = class(TmzCustomBtnEditvcl)
  private
    { Private declarations }
    FOldValue : string;
    FDropDownCalc : TDropDownCalcVCL;
    bCriado : Boolean;
    function ReadDropDownCalc: TDropDownCalcVCL;
    procedure SeTDropDownCalcVCL(const Value: TDropDownCalcVCL);
  protected
    { Protected declarations }
    procedure ExecuteClick; override;
    procedure Change; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property BorderStyle;
    property TabStop;
    property TabOrder;
    property OnResize;
    property OnExit;
    property DropDownCacl: TDropDownCalcVCL read ReadDropDownCalc write SeTDropDownCalcVCL;
    property ShowHint;
    property ParentShowHint;
 end;




procedure Register;

implementation
{$R mzCalcEditvcl.res}

uses mzNumEditvcl;

// ************************ TmzCalcVCL ************************
constructor TmzCalcVCL.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Height := 210;
  Width := 137;

  PanelEdit := TPanel.Create(Self);
  with PanelEdit do begin
    Left := 0;
    Top := 0;
    Width := 137;
    Height := 41;
    Align := alTop;
    BevelInner := bvLowered;
    TabOrder := 0;
    Parent := Self;
  end;

  Edit := TEdit.Create(Self);
  with Edit do begin
    Left := 8;
    Top := 8;
    Width := 121;
    Height := 25;
    Alignment := taRightJustify;
    ReadOnly := True;
    TabOrder := 0;
    Text := '0';
    ReadOnly := True;
    Parent := PanelEdit;
    OnKeyPress := EditKeyPress;
  end;


  PanelGeral := TPanel.Create(Self);
  with PanelGeral do begin
    Align := alClient;
    BevelOuter := bvNone;
    TabOrder := 1;
    Parent := Self;
  end;

  PanelOpera := TPanel.Create(Self);;
  with PanelOpera do begin;
      Align := alRight;
      BevelInner := bvLowered;
      TabOrder := 1;
      Width := 40;
      Parent := PanelGeral;
  end;

  btnMais := TSpeedButton.Create(Self);
  with btnMais do begin
        Left := 8;
        Top := 8;
        Width := 23;
        Height := 22;
        Caption := '+';
        Flat := True;
        Parent := PanelOpera;
        OnClick := btnOperaClick;
        Font.Color := clRed;
   end;

   btnMenos := TSpeedButton.Create(Self);
   with btnMenos do begin
        Left := 8;
        Top := 40;
        Width := 23;
        Height := 22;
        Caption := '-';
        Flat := True;
        Parent := PanelOpera;
        OnClick := btnOperaClick;
        Font.Color := clRed;
   end;

   btnVezes := TSpeedButton.Create(Self);
   with btnVezes do begin
        Left := 8;
        Top := 72;
        Width := 23;
        Height := 22;
        Caption := '*';
        Flat := True;
        Parent := PanelOpera;
        OnClick := btnOperaClick;
        Font.Color := clRed;
   end;

   btnDividir := TSpeedButton.Create(Self);
   with btnDividir do begin
        Left := 8;
        Top := 104;
        Width := 23;
        Height := 22;
        Caption := '/';
        Flat := True;
        Parent := PanelOpera;
        OnClick := btnOperaClick;
        Font.Color := clRed;
   end;

   btnPerc := TSpeedButton.Create(Self);
   with btnPerc do begin
        Left := 8;
        Top := 136;
        Width := 23;
        Height := 22;
        Caption := '%';
        Flat := True;
        Parent := PanelOpera;
        OnClick := btnPercClick;
        Font.Color := clRed;
   end;

   PanelNum := TPanel.Create(Self);
   with PanelNum do begin
      Left := 0;
      Top := 0;
      Width := 99;
      Height := 176;
      Align := alClient;
      BevelInner := bvLowered;
      TabOrder := 0;
      Parent := PanelGeral;
   end;


  btn1 := TSpeedButton.Create(Self);
  with btn1 do begin
        Left := 8;
        Top := 8;
        Width := 23;
        Height := 22;
        Caption := '1';
        Flat := True;
        Name    := 'btn1';
        OnClick := btnNumClick;
        Parent  := PanelNum;
        Font.Color := clBlue;
  end;

  btn2 := TSpeedButton.Create(Self);
  with btn2 do begin
        Left := 36;
        Top := 8;
        Width := 23;
        Height := 22;
        Caption := '2';
        Flat := True;
        Name    := 'btn2';
        OnClick := btnNumClick;
        Parent := PanelNum;
        Font.Color := clBlue;
  end;

  btn3 := TSpeedButton.Create(Self);
  with btn3 do begin
        Left := 65;
        Top := 8;
        Width := 23;
        Height := 22;
        Caption := '3';
        Flat := True;
        Name    := 'btn3';
        OnClick := btnNumClick;
        Parent := PanelNum;
        Font.Color := clBlue;
  end;

  btn4 := TSpeedButton.Create(Self);
  with btn4 do begin
        Left := 8;
        Top := 40;
        Width := 23;
        Height := 22;
        Caption := '4';
        Flat := True;
        Name    := 'btn4';
        OnClick := btnNumClick;
        Parent := PanelNum;
        Font.Color := clBlue;
  end;

  btn5:= TSpeedButton.Create(Self);
  with btn5 do begin
        Left := 36;
        Top := 40;
        Width := 23;
        Height := 22;
        Caption := '5';
        Flat := True;
        Name    := 'btn5';
        OnClick := btnNumClick;
        Parent := PanelNum;
        Font.Color := clBlue;
   end;

   btn6 := TSpeedButton.Create(Self);
   with btn6 do begin
        Left := 64;
        Top := 40;
        Width := 23;
        Height := 22;
        Caption := '6';
        Flat := True;
        Name    := 'btn6';
        OnClick := btnNumClick;
        Parent := PanelNum;
        Font.Color := clBlue;
   end;

   btn7 := TSpeedButton.Create(Self);
   with btn7 do begin
        Left := 8;
        Top := 72;
        Width := 23;
        Height := 22;
        Caption := '7';
        Flat := True;
        Name    := 'btn7';
        OnClick := btnNumClick;
        Parent := PanelNum;
        Font.Color := clBlue;
   end;

  btn8 := TSpeedButton.Create(Self);
  with btn8 do begin
        Left := 36;
        Top := 72;
        Width := 23;
        Height := 22;
        Caption := '8';
        Flat := True;
        Name    := 'btn8';
        OnClick := btnNumClick;
        Parent := PanelNum;
        Font.Color := clBlue;
  end;

  btn9 := TSpeedButton.Create(Self);
  with btn9 do begin
        Left := 64;
        Top := 72;
        Width := 23;
        Height := 22;
        Caption := '9';
        Flat := True;
        Name    := 'btn9';
        OnClick := btnNumClick;
        Parent := PanelNum;
        Font.Color := clBlue;
  end;

  btn0 := TSpeedButton.Create(Self);
  with btn0 do begin
        Left := 36;
        Top := 104;
        Width := 23;
        Height := 22;
        Caption := '0';
        Flat := True;
        Name    := 'btn0';
        OnClick := btnNumClick;
        Parent := PanelNum;
        Font.Color := clBlue;
  end;

  btnPonto := TSpeedButton.Create(Self);
  with btnPonto do begin
        Left := 8;
        Top := 104;
        Width := 23;
        Height := 22;
        Caption := '.';
        Flat    := True;
        Parent := PanelNum;
        OnClick :=  btnPontoClick;
        Font.Color := clBlue;
  end;

  btnIgual := TSpeedButton.Create(Self);
  with btnIgual do begin
        Left := 64;
        Top := 104;
        Width := 23;
        Height := 22;
        Caption := '=';
        Flat := True;
        Parent := PanelNum;
        OnClick := btnIgualClick;
        Font.Color := clBlue;
  end;

  btnC := TSpeedButton.Create(Self);
  with btnC do begin
        Left := 8;
        Top := 136;
        Width := 23;
        Height := 22;
        Caption := 'C';
        Flat := True;
        Parent := PanelNum;
        onClick := btnCClick;
        Font.Color := clGreen;
  end;

  btnCE := TSpeedButton.Create(Self);
  with btnCE do begin
        Left := 37;
        Top := 136;
        Width := 51;
        Height := 22;
        Caption := 'C/E';
        Flat := True;
        Parent := PanelNum;
        OnClick := btnLimpaClick;
        Font.Color := clGreen;
  end;
end;


procedure TmzCalcVCL.SetFocus;
begin
  inherited SetFocus;
  Edit.SetFocus;
end;


procedure TmzCalcVCL.Clear;
begin
   btnCE.Click;
end;

procedure TmzCalcVCL.btnNumClick(Sender: TObject);
var
  S: String;
  Value: Extended;
begin
  if bBranco then begin
    bBranco := False;
    Edit.Text := (Sender as TSpeedButton).Caption;
  end
  else if Length(Edit.Text) < 11 then begin  // max 99999999999
    S := Edit.Text;
    if bDecimal and (Pos(DecimalSeparator, S) = 0) then S := S + DecimalSeparator;
    S :=  S + (Sender as TSpeedButton).Caption;
    Value := StrToFloat(S);
    Edit.Text := FloatToStr(Value);
  end;
  Edit.SetFocus;
end;

procedure TmzCalcVCL.btnLimpaClick(Sender: TObject);
begin
  Edit.Text := '0';
  bDecimal := False;
  Operador := opNull;
  Edit.SetFocus;
end;


procedure TmzCalcVCL.btnIgualClick(Sender: TObject);
var
  Op2, Result: Extended;
  sOpera : string;
begin
  if (Operador = opNull) then Exit;
  Op2 := StrToFloat(Edit.Text);
  Result := 0;
  try
    case Operador of
      opDividir: begin
                   Result := Operando / Op2;
                   sOpera := '/';
                 end;
      opVezes  : begin
                    Result := Operando * Op2;
                    sOpera := '*';
                 end;
      opMais   : begin
                   Result := Operando + Op2;
                   sOpera := '+';
                 end;
      opMenos  : begin
                    Result := Operando - Op2;
                    sOpera := '-';
                 end;
    end;

  except
    // do nothing, just catch the exception
  end;

  if Assigned(FEndCalc) then begin
    sOpera := FloatToStr(Operando)+' '+sOpera+' '+FloatToStr(Op2)+' = '+FloatToStr(Result);
    FEndCalc(sOpera);
  end;

  Operador := opNull;
  Operando := 0;
  bDecimal := False;
  bBranco := True;
  Edit.Text := FloatToStr(Result);
  Edit.SetFocus;
end;

procedure TmzCalcVCL.btnPercClick(Sender: TObject);
var
  Op2, Result, nTemp: Extended;
  sOpera : string;
begin
  if (Operador = opNull) then Exit;
  Op2 := StrToFloat(Edit.Text);
  nTemp := (Operando * 0.01) * Op2;
  Result := 0;
  try
    case Operador of
      opDividir: begin
                   Result := Operando / nTemp;
                   sOpera := '/';
                 end;
      opVezes  : begin
                    Result := Operando * nTemp;
                    sOpera := '*';
                 end;
      opMais   : begin
                   Result := Operando + nTemp;
                   sOpera := '+';
                 end;
      opMenos  : begin
                    Result := Operando - nTemp;
                    sOpera := '-';
                 end;
    end;
  except
    // do nothing, just catch the exception
  end;
  if Assigned(FEndCalc) then begin
    sOpera := FloatToStr(Operando)+' '+sOpera+' '+FloatToStr(Op2)+'% ('+FloatToStr(nTemp)+') = '+FloatToStr(Result);
    FEndCalc(sOpera);
  end;

  Operador := opNull;
  Operando := 0;
  bDecimal := False;
  bBranco := True;
  Edit.Text := FloatToStr(Result);
  Edit.SetFocus;
end;



procedure TmzCalcVCL.btnOperaClick(Sender: TObject);
begin
  btnIgual.Click;
  case (Sender as TSpeedButton).Caption[1] of
    '/': Operador := opDividir;
    '*': Operador := opVezes;
    '+': Operador := opMais;
    '-': Operador := opMenos;
    else
      Operador := opNull;
  end;
  Operando := StrToFloat(Edit.Text);
  bBranco := True;
  bDecimal := False;
  Edit.SetFocus;
end;

procedure TmzCalcVCL.btnPontoClick(Sender: TObject);
begin
  bDecimal := True;
end;

procedure TmzCalcVCL.EditKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  case Key of
   '0'..'9': TSpeedButton(FindComponent('btn'+Key)).Click;
         #8: btnC.Click;
#27,'c','C': btnCE.Click;
        '+': btnMais.Click;
        '/': btnDividir.Click;
'p','P','%': btnPerc.Click;
        '-': btnMenos.Click;
        '*': btnVezes.Click;
   '.', ',': btnPonto.Click;
   #13, '=': btnIgual.Click;
  end;
  //Caption := IntToStr(Ord(key));
end;

function TmzCalcVCL.GetValue: string;
begin
  Result := Edit.Text;
end;


procedure TmzCalcVCL.SetValue(Valor:String);
begin
  try
    if (Valor <> '') and (StrToFloat(Valor) < 99999999999) then
      Edit.Text := Valor
    else
      Edit.Text := '0';
  except
      Edit.Text := '0';
  end;
end;

procedure TmzCalcVCL.btnCClick(Sender: TObject);
var
  S: String;
begin
  S := Copy(Edit.Text, 1, Length(Edit.Text) - 1);
  if S = '' then S := '0';
   if ( Frac(StrToFloat(S)) = 0  ) then bDecimal := False;
  Edit.Text := S;
end;

// ************************ TDropDownCalcVCL ************************
constructor TDropDownCalcVCL.Create;
begin
  FWidth := 0;
  FHeight := 0;
end;

procedure TDropDownCalcVCL.SetWidth(const Value: Integer);
begin
  FWidth := Value;
end;

procedure TDropDownCalcVCL.SetHeight(const Value: Integer);
begin
  FHeight := Value;
end;


// ************************ TDropDownCalcVCL ************************
constructor TmzCalcEditVCL.Create(AOwner: TComponent);
begin
  FOldValue := '0';
  inherited Create(AOwner);
  FDropDownCalc := TDropDownCalcVCL.Create;
  btnEdit.Glyph.LoadFromResourceName(HInstance,'TmzCalcVCLMINIVCL');
  with FDropDownCalc do  begin
    Height := 0;
    Width := 0;
   end;
   bCriado := True;
end;


procedure TmzCalcEditVCL.ExecuteClick;
var
  MyTempForm: TForm;
  MyTempCalc: TmzCalcVCL;
  MyPoint: TPoint;
begin
  MyTempForm := TForm.Create(Application);
  try
   with MyTempForm do begin
     Parent := Self;
     VertScrollBar.Visible := False;
     HorzScrollBar.Visible := False;
     ShowHint := Parent.ShowHint;
     BorderStyle := bsNone;
     MyPoint.X := 0;
     MyPoint.Y := Self.Height;
     Left := Self.ClientToScreen(MyPoint).X-2;
     Top :=  Self.ClientToScreen(MyPoint).Y-2;

     MyTempCalc := TmzCalcVCL.Create(MyTempForm);
     with MyTempCalc do  begin
       Name := 'Calc';
       Value := Self.Text;
       Parent := MyTempForm;
       ShowHint := Parent.ShowHint;
       MyTempForm.Width := Width;
       MyTempForm.Height := Height;
     end;
//     QOpenWidget_setWFlags(QOpenWidgetH(MyTempForm.Handle), Cardinal(WidgetFlags_WType_Popup));
     ShowModal;
     Self.Text := MyTempCalc.Value;
    end;
  finally
   FreeAndNil(MyTempForm);
  end;
end;

destructor TmzCalcEditVCL.Destroy;
begin
  FreeAndNil(FDropDownCalc);
  inherited;
end;


function TmzCalcEditVCL.ReadDropDownCalc: TDropDownCalcVCL;
begin
  Result := FDropDownCalc;
end;


procedure TmzCalcEditVCL.SeTDropDownCalcVCL(const Value: TDropDownCalcVCL);
begin
  FDropDownCalc.Assign(Value);
end;

procedure TmzCalcEditVCL.Change;
begin
  inherited;
  if not bCriado then exit;
  if StrIsNumber(Text, True) then begin
    FOldValue := Text;
  end
  else
    Text := FOldValue;
end;

procedure Register;
begin
  RegisterComponents('Master', [TmzCalcVCL]);
  RegisterComponents('Master', [TmzCalcEditVCL]);
end;

end.
