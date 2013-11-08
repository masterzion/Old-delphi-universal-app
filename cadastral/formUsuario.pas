unit formUsuario;

{$include configura.inc}

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms, 
  QDialogs, QStdCtrls, mzComboBoxClx, mzDBComboBoxClx, QMask, 
  QGrids, QDBGrids, QExtCtrls, QComCtrls, principal, FMTBcd, DB, SqlExpr, mzlib,
  Provider, DBClient, mzCustomEdit, mzNumEditclx;

type
  TfrmUsuario = class(TForm)
    Controle: TToolBar;
    btnLocalizar: TToolButton;
    ToolButton5: TToolButton;
    btnNovo: TToolButton;
    btnSalvar: TToolButton;
    ToolButton8: TToolButton;
    btnExcluir: TToolButton;
    ToolButton10: TToolButton;
    btnFechar: TToolButton;
    PageControl1: TPageControl;
    TabSheetDetalhes: TTabSheet;
    TabSheetBrowser: TTabSheet;
    Splitter1: TSplitter;
    PanelBrowser: TPanel;
    DBGridBusca: TDBGrid;
    edtNome: TNumEditclx;
    edtSenha: TNumEditclx;
    cmbGrupo: TmzDBComboBoxClx;
    chkExibir: TCheckBox;
    Query: TSQLQuery;
    UsuarioBusca: TNumEditclx;
    SQLDataSet1: TSQLDataSet;
    DataSource1: TDataSource;
    ClientDataSet1: TClientDataSet;
    DataSetProvider1: TDataSetProvider;
    edtCodigo: TNumEditclx;
    QueryAux: TSQLQuery;
    edtValidade: TNumEditclx;
    procedure btnLocalizarClick(Sender: TObject);
    procedure DBGridBuscaDblClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnFecharClick(Sender: TObject);
    procedure DBGridBuscaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    CodigoAtual : Integer;
    Alterando   : Boolean;
    procedure ExecutaBusca(Codigo:Integer);
    function  AbreQueryErro(TipoAbrir:Integer):Boolean;
    procedure PreencheDados;
    procedure Cancelar;
    procedure AbreBusca(Where:String);
    { Private declarations }
  public
    { Public declarations }
    {$IFDEF corporate}
     sCodEmpresa : string;
    {$ENDIF}


  end;

var
  frmUsuario: TfrmUsuario;

implementation

{$R *.xfm}


procedure TfrmUsuario.Cancelar;
begin
  edtCodigo.Clear;
  edtNome.Clear;
  edtSenha.Clear;
  chkExibir.Checked   := False;

  Alterando:= False;
  CodigoAtual := 0;

  edtValidade.Text := '0';
  btnExcluir.Enabled := False;
  PageControl1.ActivePage := TabSheetDetalhes;
end;

procedure TfrmUsuario.PreencheDados;
begin
  edtCodigo.Text      := Query.FieldByName('nIDUsuario').AsString;
  edtNome.Text        := Query.FieldByName('sNomeUsuario').AsString;
  edtSenha.Text       := '[senha codificada]';
  chkExibir.Checked   := (Query.FieldByName('bExibir').AsString = 'Y');
  edtValidade.Text    := Query.FieldByName('nValidade').AsString;

  cmbGrupo.ValueIndex := Query.FieldByName('nIDGrupo').AsInteger;
  PageControl1.Activepage := TabSheetDetalhes;
end;

procedure TfrmUsuario.AbreBusca(Where:String);
begin
  ClientDataSet1.Active := False;
  with SQLDataSet1 do begin
    Close;
    CommandText := ' select nIDUsuario as Codigo,'+
                   ' sNomeUsuario as Usuario '+
                   ' from tbUsuario '+
                   ' where '+
                    {$IFDEF corporate}
                    CODIGO_EMPRESA+' = '+frmPrincipal.Codigo_Empresa+' and '+
                    {$ENDIF}
                    Where;
    Open;
  end;
  ClientDataSet1.Active := True;
end;


procedure TfrmUsuario.btnLocalizarClick(Sender: TObject);
var
 sTemp : string;
begin
  PageControl1.Activepage := TabSheetBrowser;
  sTemp := UsuarioBusca.Text;
  ApagaCaracteres(sTemp);
  AbreBusca(' sNomeUsuario like '+S_AP+sTemp+'%'+S_AP);
end;


procedure TfrmUsuario.DBGridBuscaDblClick(Sender: TObject);
begin
  if (DBGridBusca.Fields[0].AsString <> '') then ExecutaBusca(DBGridBusca.Fields[0].AsInteger);
end;


procedure TfrmUsuario.ExecutaBusca(Codigo:Integer);
begin
 Query.SQL.Text := ' select nIDUsuario, nIDGrupo, sNomeUsuario, sSenha, bExibir, nValidade '+
                   ' from tbUsuario '+
                    'where '+
                    {$IFDEF corporate}
                    CODIGO_EMPRESA+' = '+sCodEmpresa+' and '+
                    {$ENDIF}
                    'nIDUsuario = '+ inttostr(codigo);
 if AbreQueryErro(mzQueryLocalizar) then exit;
 CodigoAtual := codigo;
 Alterando := True;
 PreencheDados;
end;

function TfrmUsuario.AbreQueryErro(TipoAbrir:Integer):Boolean;
var
 msg : String;
begin
  try
    if (TipoAbrir = mzQueryLocalizar) or (TipoAbrir = mzQueryLoad) or (TipoAbrir = mzCarregaAcesso) then
      Query.Open
    else
      Query.ExecSQL;
    Result := False;
  except
      on E : EDatabaseError do begin
        Result := True;

        case TipoAbrir of
          0: msg := ErroSalvar;
          1: msg := ErroLocalizar;
          2: msg := ErroExecutar;
          3: msg := ErroExcluir;
          4: msg := concat(ErroTravar,Self.Name,'!');
          5: msg := concat(ErroDestravar,Self.Name,'!');
          6: msg := ErroLoad;
          7: msg := ErroCampoChave;
          8: msg := ErroSalvarFilhas;
          9: msg := CarregaAcesso;
        end;
        ShowMessage(msg+#13+E.Message);
      end;
  end;

end;


procedure TfrmUsuario.btnExcluirClick(Sender: TObject);
var
  sTemp : string;
begin
 if (CodigoAtual = 0) then exit;

 if MessageDlg(ExcluirDados,  mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
    with query do begin
        sTemp := ' delete from tbMensagem '+
                 ' where '+
                  {$IFDEF corporate}
                  CODIGO_EMPRESA+' = '+sCodEmpresa+' and '+
                  {$ENDIF}
                  'nIDUsuario = '+ inttostr(CodigoAtual);
        Query.SQL.Text := sTemp;
        if AbreQueryErro(mzQueryExcluir) then exit;

        sTemp := ' delete from tbUsuario '+
                 ' where '+
                  {$IFDEF corporate}
                  CODIGO_EMPRESA+' = '+sCodEmpresa+' and '+
                  {$ENDIF}
                  'nIDUsuario = '+ inttostr(CodigoAtual);
        Query.SQL.Text := sTemp;
        if AbreQueryErro(mzQueryExcluir) then exit;
      end;

      CodigoAtual := 0;
    end;
    Cancelar;
    Alterando:= False;
    ShowMessage('Excluido!!!');
    btnLocalizar.Click;
end;

procedure TfrmUsuario.btnNovoClick(Sender: TObject);
begin
  Cancelar;
end;

procedure TfrmUsuario.btnSalvarClick(Sender: TObject);
var
 NomeTemp, sTemp, SenhaTemp : string;
 bSenhaTemp : Boolean;
 InCodigo : Integer;
begin

  bSenhaTemp := (edtSenha.Text <> '[senha codificada]');
  if (edtValidade.Text = '') then edtValidade.Text := '-1'; 

  sTemp :=edtSenha.Text;
  ApagaCaracteres(sTemp);
  SenhaTemp := iif(bSenhaTemp, pwdsql+'('+S_AP+sTemp+S_AP+')', '' );

  NomeTemp := edtNome.Text;
  ApagaCaracteres(NomeTemp);


  if Alterando then begin
    sTemp := ' update tbUsuario set '+
             ' nIDGrupo = '+IntToStr(cmbGrupo.ValueIndex)+', '+
             ' sNomeUsuario = '+S_AP+NomeTemp+S_AP+', '+
             iif(bSenhaTemp, ' sSenha = '+SenhaTemp+', ', '')+
             ' bExibir = '+iif(chkExibir.Checked, S_AP+'Y'+S_AP,  S_AP+'N'+S_AP)+', '+
             ' dPasswd = '+sNow+','+
             ' nValidade = '+edtValidade.Text+
             ' where '+
             {$IFDEF corporate}
             CODIGO_EMPRESA+' = '+sCodEmpresa+' and '+
             {$ENDIF}
             'nIDUsuario = '+ inttostr(CodigoAtual);

    InCodigo := CodigoAtual;
  end
  else begin
    with QueryAux do begin
      Sql.Text := 'select max(nIDUsuario)+1 from tbUsuario';
      Open;
      InCodigo := Fields[0].AsInteger;
    end;

    sTemp := ' insert into tbUsuario '+
             ' (nValidade ,nIDUsuario, nIDGrupo, sNomeUsuario, '+iif(bSenhaTemp, ' sSenha ', ' ')+',  bExibir'+ ',  '+CODIGO_EMPRESA + ') '+
             ' values '+
             ' ('+EdtValidade.Text+', '+
             IntToStr(InCodigo)+', '+
             IntToStr(cmbGrupo.ValueIndex)+', '+
             S_AP+NomeTemp+S_AP+', '+
             iif(bSenhaTemp, SenhaTemp +' ,', ', ')+
             iif(chkExibir.Checked, S_AP+'Y'+S_AP, S_AP+'N'+S_AP)+
             {$IFDEF corporate} ', '+sCodEmpresa+ {$ENDIF}
             {$IFDEF personal} ', 1'+ {$ENDIF}
             ')';
    end;

  Query.SQL.Text := sTemp;
  if AbreQueryErro(mzQueryExcluir) then exit;
  ExecutaBusca(InCodigo);
end;

procedure TfrmUsuario.FormCreate(Sender: TObject);
begin
  PageControl1.Activepage := TabSheetBrowser;
  AbreBusca(' 0 = 1 ');
  cmbGrupo.Active := True;
end;

procedure TfrmUsuario.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  with frmPrincipal.ActUsuarios do begin
    Visible := True;
    Enabled  := True;
  end;
  Action := caFree;
end;

procedure TfrmUsuario.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmUsuario.DBGridBuscaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = RETUNR_KEY) or (Key = RETUNR_KEY2) then
     ExecutaBusca(DBGridBusca.Fields[0].AsInteger);
end;

end.
