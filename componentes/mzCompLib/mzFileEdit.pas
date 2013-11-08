unit mzFileEdit;

interface

uses
  SysUtils, Classes, QControls, QStdCtrls, QMask, mzCustomEdit,
  mzCustomBtnEditclx, QDialogs;

type
  TmzFileEdit = class(TmzCustomBtnEditclx)
  private
    { Private declarations }
    procedure SetDialog(Dialog:TOpenDialog);
  protected
    { Protected declarations }
    FOpenDialog : TOpenDialog;
    FFilter, FCaption : String;
    procedure ExecuteClick; override;
  public
    { Public declarations }
    constructor Create(AOwner : TComponent); override;
    destructor Destroy ; Override;
  published
    { Published declarations }
    property DialogTitle : String read FCaption write FCaption;
    property DialogFilter  : String read FFilter write FFilter;
  end;

procedure Register;

{$R mzfileedit.res}


implementation

constructor TmzFileEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOpenDialog := TOpenDialog.Create(Self);
  FOpenDialog.Name := 'IntenalOpenDialog';
  btnEdit.Glyph.LoadFromResourceName(HInstance,'MZFOLDER');
end;

procedure TmzFileEdit.SetDialog(Dialog:TOpenDialog);
begin
 FOpenDialog := Dialog;
end;

procedure TmzFileEdit.ExecuteClick;
begin
  if (FOpenDialog = nil) then
    ShowMessage('OpenDialog not assigned')
  else begin
    FOpenDialog.Filter := FFilter;
    FOpenDialog.Title := FCaption;
    if FOpenDialog.Execute then Self.Text := FOpenDialog.FileName;
  end;

end;

destructor TmzFileEdit.Destroy;
begin
  FreeAndNil(FOpenDialog);
  inherited Destroy;
end;


{procedure TmzFileEdit.Notification(AComponent: TComponent; Operation: TOperation); override;
begin
  inherited Notification(AComponent, Operation);
  if (AComponent = FOpenDialog) and (Operation = opRemove) then
    FOpenDialog := nil;
end;
 }

procedure Register;
begin
  RegisterComponents('Master', [TmzFileEdit]);
end;

end.
