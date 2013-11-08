unit mzBtnEditclx;

interface

uses  mzCustomBtnEditclx, Classes, QButtons;

type
  TmzBtnEditclx = class(TmzCustomBtnEditclx)
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

{$R mzbtneditclx.res}

implementation

constructor TmzBtnEditclx.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  btnEdit.Glyph.LoadFromResourceName(HInstance,'BTNPROCURA');
end;

procedure Register;
begin
  RegisterComponents('Master', [TmzBtnEditclx]);
end;


end.
