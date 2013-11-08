unit formMudaPasswd;
{$include configura.inc}
interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms, 
  QDialogs, QStdCtrls, QMask, QComCtrls, FMTBcd, DB, SqlExpr, mzlib,
  mzCustomEdit, mzNumEditclx;

type
  TfrmAlteraSenha = class(TForm)
    Controle: TToolBar;
    btnSalvar: TToolButton;
    ToolButton8: TToolButton;
    btnFechar: TToolButton;
    sSenha: TNumEditclx;
    sSenha2: TNumEditclx;
    Query: TSQLQuery;
    procedure btnSalvarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sSenha2KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAlteraSenha: TfrmAlteraSenha;

implementation

uses principal;

{$R *.xfm}

procedure TfrmAlteraSenha.btnSalvarClick(Sender: TObject);
begin
  if (length(sSenha.Text) < 4) then begin
    ShowMessage('A senha deve conter mais de 4 ou mais caracteres.'+#13+'Digite outra senha...');
    exit;
  end;

  if (sSenha.Text <> sSenha2.Text) then begin
    ShowMessage('As senhas não conferem.'+#13+'Digite novamente...');
    exit;
  end;

  with Query do begin
     SQl.Text := concat(' update tbUsuario set ',
                        ' sSenha = '+pwdsql+'("',sSenha2.Text,'") , ',
                        ' dPasswd = '+sNow+
                        ' where nIDUsuario = ',inttostr(frmPrincipal.nCodUsuario) );
//                        ' and '+CODIGO_EMPRESA+' = '+frmPrincipal.Codigo_Empresa);
    try
        ExecSQL;
    except
      on E : EDatabaseError do  begin
        ShowMessage('Erro ao atualizar senha!'#13+E.Message);
      end;
    end;
    ShowMessage('Senha alterada!');
  end;
  Close;
end;

procedure TfrmAlteraSenha.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmAlteraSenha.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   with frmPrincipal.ActAlteraSenha do begin
    Visible := True;
    Enabled  := True;
   end;
   Action := caFree;

end;

procedure TfrmAlteraSenha.sSenha2KeyPress(Sender: TObject; var Key: Char);
begin
  if (key = #13) then btnSalvar.Click;
end;

end.
