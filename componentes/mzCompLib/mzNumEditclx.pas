unit mzNumEditclx;
{
Name: Jairo M. de Barros Júnior
E-Mail: master@mortal.co.uk
http://www.centraljairo.hpg.com.br
}
interface


uses SysUtils, Classes, mzCustomEdit, mzCompLib;

const mskTipos : string = 'LlAaCc09#';

type
  TTipoNumero = (mzFloat, mzInteger, mzString);

  TNumEditclx = class(TmzCustomEditclx)
  private
    TipoNumero : TTipoNumero;
    FOldValue : string;
    bCriado : Boolean;
    MaxVal, MinVal : Integer;
 protected
    procedure Change; override;

    procedure SetTipoNumero(Numero:TTipoNumero);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property MaxValue : Integer         read MaxVal write MaxVal;
    property MinValue : Integer         read MinVal write MinVal;
    property NumberType : TTipoNumero   read TipoNumero write SetTipoNumero default mzString;
    property Align;
    property EchoMode;
    property FieldName: String          read sFieldName write sFieldName;
    property TextLabel : TmzBoundLabel  read InLabel write InLabel;
    property TextLabelSpacing : Integer read nDistancia write SetaDistancia;
    property NullData : Boolean         read Branco write SetNullData;
  end;

procedure Register;
{$R numeditclx.res}

implementation


// ***************** Edit x Label  *****************
constructor TNumEditclx.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  TipoNumero := mzString;
  bCriado := True;
end;

procedure TNumEditclx.SetTipoNumero(Numero:TTipoNumero);
begin
  TipoNumero := Numero;
  Clear;
  case TipoNumero of
    mzInteger, mzFloat : Text := '0';
  end;

  FOldValue := '0';
end;

procedure TNumEditclx.Change;
begin
  inherited;
  if not bCriado then exit;

  case TipoNumero of
    mzInteger : if StrIsNumber(Text, False) then begin
                    FOldValue := Text;
                  end
                  else
                    Text := FOldValue;

      mzFloat : if StrIsNumber(Text, True) then begin
                    FOldValue := Text;
                  end
                  else
                    Text := FOldValue;
  end;
end;

procedure Register;
begin
  RegisterComponents('Master', [TNumEditclx]);
end;

end.
