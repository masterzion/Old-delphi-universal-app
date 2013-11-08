unit mzCustomBtnEditvcl;

interface

uses
  SysUtils, Classes, Controls, StdCtrls, mzCustomEditvcl, Buttons, Graphics, ExtCtrls, mzCompLibvcl;

Const
  nTamanhoDoBotao  = 21;

type
  TmzCustomBtnEditvcl = class(TmzCustomEditvcl)
  private
    { Private declarations }
    PanelEdit: TPanel;
    FOnButtonClick: TNotifyEvent;
    procedure EditButtonClick(Sender: TObject);
    procedure PosicionaBotao;
    function ReadbtnImg:TBitmap;
    procedure SetbtnImg(Imagem:TBitmap);
  protected
    { Protected declarations }
    btnEdit: TSpeedButton;
    procedure ExecuteClick; virtual;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure ButtonClick; dynamic;
  public
    { Public declarations }
    constructor Create(AOwner : TComponent); override;
    destructor Destroy ; Override;
    procedure ReSize; override;
  published
    { Published declarations }
    property OnButtonClick: TNotifyEvent read FOnButtonClick write FOnButtonClick;
    property ButtonImage: TBitmap read ReadbtnImg write SetbtnImg;
    property Align;
//    property EchoMode;
    property FieldName: String          read sFieldName write sFieldName;
    property TextLabel : TmzBoundLabel  read InLabel write InLabel;
    property TextLabelSpacing : Integer read nDistancia write SetaDistancia;
    property NullData : Boolean         read Branco write SetNullData;
  end;

implementation

function TmzCustomBtnEditvcl.ReadbtnImg:TBitmap;
begin
  Result := btnEdit.Glyph;
end;

procedure TmzCustomBtnEditvcl.SetbtnImg(Imagem:TBitmap);
begin
  btnEdit.Glyph := Imagem;
end;

constructor TmzCustomBtnEditvcl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  // Cria panel
  PanelEdit := TPanel.Create(Self);
  PanelEdit.ControlStyle := PanelEdit.ControlStyle + [csReplicatable];
  PanelEdit.Visible := True;

  // Cria Botão
  btnEdit := TSpeedButton.Create(Self);
  btnEdit.Flat    := True;
  btnEdit.Visible := True;
  btnEdit.Parent := PanelEdit;
  btnEdit.NumGlyphs := 1;
  TSpeedButton(btnEdit).OnClick := EditButtonClick;
  PosicionaBotao;
end;

procedure TmzCustomBtnEditvcl.PosicionaBotao;
begin
  PanelEdit.Width   := nTamanhoDoBotao;
  PanelEdit.Height  := Self.Height - 4;
  PanelEdit.Top     := 2;
  PanelEdit.Left    := Self.Width - nTamanhoDoBotao - 2;
  PanelEdit.Parent  := Self;
  btnEdit.SetBounds(0, 0, PanelEdit.Width, PanelEdit.Height);
  Repaint;
end;


destructor TmzCustomBtnEditvcl.Destroy;
begin
  FreeAndNil(btnEdit);
  FreeAndNil(PanelEdit);
  inherited Destroy;
end;

procedure TmzCustomBtnEditvcl.EditButtonClick(Sender: TObject);
begin
  if Self.CanFocus then Self.SetFocus;
  ExecuteClick;
  ButtonClick;
end;

procedure TmzCustomBtnEditvcl.ButtonClick;
begin
  if Assigned(FOnButtonClick) then FOnButtonClick(Self);
end;

procedure TmzCustomBtnEditvcl.ExecuteClick;
begin
  sleep(0);
end;

procedure TmzCustomBtnEditvcl.ReSize;
begin
  inherited;
  PosicionaBotao;
end;

procedure TmzCustomBtnEditvcl.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if (Key = RETUNR_KEY) or (Key = RETUNR_KEY2) then ExecuteClick;
end;



end.
