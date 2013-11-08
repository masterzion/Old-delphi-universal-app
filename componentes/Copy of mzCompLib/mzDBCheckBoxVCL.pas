unit mzDBCheckBoxvcl;

interface

uses
  SysUtils, Classes, Controls, StdCtrls, Graphics;

type
  TmzDBcheckBoxVCL = class(TCheckBox)
  private
    { Private declarations }
    sFieldName, sFalseValue, sTrueValue, sValue : string;
    bReadOnly : Boolean;
  protected
    { Protected declarations }
  public
    { Public declarations }
    procedure SetValue(InValue:string);
    constructor Create(AOwner: TComponent); override;

  published
    { Published declarations }
    property FieldName  : string  read sFieldName  write sFieldName;
    property ValueTrue  : string  read sTrueValue  write sTrueValue;
    property ValueFalse : string  read sFalseValue write sFalseValue;
    property ReadOnly   : Boolean read bReadOnly   write bReadOnly;
    property Value      : string  read sValue      write SetValue;
  end;

procedure Register;

implementation


constructor TmzDBcheckBoxVCL.Create(AOwner: TComponent); 
begin
   inherited;
    sFieldName   := '';
    sFalseValue  := 'N';
    sTrueValue   := 'Y';
    sValue       := 'N';
    bReadOnly    := False;

    with Font do begin
       Color := clNavy;
       Name  := 'Helvetica';
       Style := [fsBold];
    end;

end;

procedure TmzDBcheckBoxVCL.SetValue(InValue:string);
begin
 Checked := (InValue = sTrueValue);
 sValue   := InValue;
end;


procedure Register;
begin
  RegisterComponents('Master', [TmzDBcheckBoxVCL]);
end;

end.
