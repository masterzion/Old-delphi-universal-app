unit formLogin;

{$include configura.inc}

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, QMask, QComCtrls, QButtons, QExtCtrls, mzlib,
  FMTBcd, DB, SqlExpr, QImgList, mzCustomEdit, mzNumEditclx;

type
  TfrmLogin = class(TForm)
    PanelUsrPass: TPanel;
    btnOK: TSpeedButton;
    btnSair: TSpeedButton;
    LabelStatus: TLabel;
    sNomeUsuario: TNumEditclx;
    sSenha: TNumEditclx;
    SQLDataSet: TSQLDataSet;
    PanelTitulo: TPanel;
    Label1: TLabel;
    IconView: TIconView;
    ImageList1: TImageList;
    procedure btnOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnSairClick(Sender: TObject);
    procedure IconViewSelectItem(Sender: TObject; Item: TIconViewItem;
      Selected: Boolean);
    procedure sSenhaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sNomeUsuarioKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
     MudaLogin, Logado:Boolean;

    {$IFDEF corporate}
      sCodEmpresa : string;
    {$ENDIF}

    { Public declarations }
  end;

var
  frmLogin: TfrmLogin;

implementation

uses principal;

{$R *.xfm}

procedure TfrmLogin.btnOKClick(Sender: TObject);
   procedure DesabilitaControles(Mensagem:String);
   begin
     sNomeUsuario.Enabled := False;
     sSenha.Enabled       := False;
     LabelStatus.Caption := Mensagem;
     sleep(2000);
     sNomeUsuario.Enabled := True;
     sSenha.Clear;
     sSenha.Enabled := True;
     btnOK.Enabled := True;
     LabelStatus.Caption := '';
   end;

var
 sQuery, Senha, Usuario : string;
begin
  btnOK.Enabled := False;
  Usuario := uppercase(sNomeUsuario.text);
  Senha := sSenha.Text;

  ApagaCaracteres(Usuario, True);
  ApagaCaracteres(Senha, True);

  With SQLDataSet do begin
    close;

    sQuery := concat('select nIDUsuario , ',
                      ' count(*) '+ASSQL+' Contagem, ',
                      sDataExpirada,
                      ' from ',
                      ' tbUsuario ',
                      ' where  tbUsuario.sNomeUsuario = "',Usuario,'"',
                      {$IFDEF corporate}
                      ' and ',CODIGO_EMPRESA,' = ',sCodEmpresa,
                      {$ENDIF}
                      ' and    tbUsuario.sSenha       = ',PWDSQL,'("',Senha,'")',
                      ' group by tbUsuario.nIDUsuario');

    commandtext := sQuery;
    open;

    if (FieldByName('Contagem').asInteger <> -1) and (Usuario <> 'ROOT') then begin
       if (FieldByName('Validade').asString = sData_FALSE ) then begin
         ShowMessage(ErroSenhaExpirada);
         DesabilitaControles(ErroSenhaExpirada);
         Exit;
       end;
    end;

    if (FieldByName('Contagem').asInteger = 1) then begin
      Logado := True;
      frmPrincipal.nCodUsuario := FieldByName('nIDUsuario').AsInteger;
      frmPrincipal.sNomeUsuario := Usuario;
    end
    else begin
      DesabilitaControles(ErroSenhaInvalida);
    end;
    Close;
  end;
  if logado then close;
end;

procedure TfrmLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Logado then
    Action := caFree
  else
    if MudaLogin then
      Action := caFree
    else
      Application.Terminate;

end;

procedure TfrmLogin.FormCreate(Sender: TObject);
var
 sTemp : string;
 nTemp : integer;
begin
  logado := False;
  MudaLogin := False;
  With SQLDataSet do begin
    close;
    CommandText := ' select sNomeUsuario from tbUsuario '+
                   ' where '+
                   {$IFDEF corporate}
                   CODIGO_EMPRESA+' = '+frmPrincipal.Codigo_Empresa+' and '+
                   {$ENDIF}
                   ' bExibir = "Y"';
    Open;
    First;
    while not Eof do begin
       with IconView.Items.Add do begin
         sTemp := FieldbyName('sNomeUsuario').AsString;
         Caption := sTemp;
         if (sTemp = 'ROOT') then
           nTemp := 0
         else
           nTemp := 1;
         ImageIndex := nTemp;
       end;
    next;
    end;
  end;

  if IconView.Items.Count = 0 then begin
    IconView.Visible := False;
    PanelTitulo.Visible := False;
    Self.Height := 118;
    PanelUsrPass.Align := alClient;
  end;


  sNomeUsuario.Clear;
  sSenha.Clear;
end;

procedure TfrmLogin.btnSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmLogin.IconViewSelectItem(Sender: TObject;
  Item: TIconViewItem; Selected: Boolean);
begin
 if (IconView.Selected <> nil) then begin
   sNomeUsuario.Text := IconView.Selected.Caption;
   sSenha.Clear;
   sSenha.SetFocus;
   sNomeUsuario.Color := clWhite;
 end;

end;

procedure TfrmLogin.sSenhaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = RETUNR_KEY) or (Key = RETUNR_KEY2) then btnOk.Click;
end;

procedure TfrmLogin.sNomeUsuarioKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = RETUNR_KEY) or (Key = RETUNR_KEY2) then
    if sNomeUsuario.Text <> '' then sSenha.SetFocus;
end;

end.
