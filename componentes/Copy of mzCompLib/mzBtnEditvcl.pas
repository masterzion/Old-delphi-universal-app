unit mzBtnEditvcl;

interface

uses  mzCustomBtnEditvcl, Classes, Buttons;

type
  TmzBtnEditvcl = class(TmzCustomBtnEditvcl)
  private
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner : TComponent); override;
  published
    { Published declarations }
  end;

procedure Register;


implementation

constructor TmzBtnEditvcl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  btnEdit.Glyph.LoadFromResourceName(HInstance,'BTNPROCURAVCL');
end;

procedure Register;
begin
  RegisterComponents('Master', [TmzBtnEditvcl]);
end;


end.
