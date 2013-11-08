unit mzFileEditvcl;

interface

uses
  SysUtils, Classes, Controls, StdCtrls, Mask, mzCustomEditvcl,
  mzCustomBtnEditvcl, Dialogs;

type
  TmzFileEditVCL = class(TmzCustomBtnEditvcl)
  private
    { Private declarations }
    procedure SetDialog(Dialog:TOpenDialog);
  protected
    { Protected declarations }
    FOpenDialog : TOpenDialog;
    procedure ExecuteClick; override;
  public
    { Public declarations }
    constructor Create(AOwner : TComponent); override;
    destructor Destroy ; Override;
  published
    { Published declarations }
    property OpenDialog : TOpenDialog read FOpenDialog write FOpenDialog;
  end;

procedure Register;


implementation

constructor TmzFileEditVCL.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOpenDialog := TOpenDialog.Create(Self);
  FOpenDialog.Name := 'IntenalOpenDialog';
  btnEdit.Glyph.LoadFromResourceName(HInstance,'MZFOLDER');
end;

procedure TmzFileEditVCL.SetDialog(Dialog:TOpenDialog);
begin
 FOpenDialog := Dialog;
end;

procedure TmzFileEditVCL.ExecuteClick;
begin
  if FOpenDialog.Execute then Self.Text := FOpenDialog.FileName;
end;

destructor TmzFileEditVCL.Destroy;
begin
  FreeAndNil(FOpenDialog);
  inherited Destroy;
end;


{procedure TmzFileEditVCL.Notification(AComponent: TComponent; Operation: TOperation); override;
begin
  inherited Notification(AComponent, Operation);
  if (AComponent = FOpenDialog) and (Operation = opRemove) then
    FOpenDialog := nil;
end;
 }

procedure Register;
begin
  RegisterComponents('Master', [TmzFileEditVCL]);
end;

end.
