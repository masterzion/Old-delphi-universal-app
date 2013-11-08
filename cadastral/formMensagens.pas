unit formMensagens;

{$include configura.inc}

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, QGrids, QDBGrids, QComCtrls, FMTBcd, DB,
  SqlExpr, Provider, DBClient, QExtCtrls, mzlib;

type
  TfrmMensagens = class(TForm)
    Controle: TToolBar;
    btnNovo: TToolButton;
    ToolButton8: TToolButton;
    btnFechar: TToolButton;
    DBGridBusca: TDBGrid;
    ClientDataSet1: TClientDataSet;
    Query: TSQLQuery;
    QueryAux: TSQLQuery;
    DataSetProvider1: TDataSetProvider;
    SQLDataSet1: TSQLDataSet;
    DataSource1: TDataSource;
    btnAtualizar: TToolButton;
    btnExcluir: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAtualizarClick(Sender: TObject);
    procedure DBGridBuscaDblClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
  private
    { Private declarations }
     {$IFDEF corporate}
        sCodEmpresa : string;
     {$ENDIF}
     procedure AbreMensagem(CodMensagem :Integer);
     procedure AbreFormMensagem(Lembrete :Boolean);
  public
    sQuery : string;
    procedure AtualizaMensagens;
    { Public declarations }
  end;

var
  frmMensagens: TfrmMensagens;

implementation
uses principal, formMsg;

{$R *.xfm}


procedure TfrmMensagens.AbreFormMensagem(Lembrete :Boolean);
var
  frmMsg: TfrmMsg;
begin
  frmMsg := TfrmMsg.Create(self);
  with frmMsg do begin
    Enviar(True);
    if Lembrete then lstDestinos.Items.Add(frmPrincipal.sNomeUsuario);

    PanelEnviar.Visible := not Lembrete;
    PanelDataLembrete.Visible   := Lembrete;
    Show;
  end;
end;

procedure TfrmMensagens.AbreMensagem(CodMensagem :Integer);
var
  frmMsg: TfrmMsg;
begin
    with SQLDataSet1 do begin
      Close;
      CommandText :=  ' select '+
                      '     sOrigem, '+
                      '     dHora, '+
                      '     sOrigem, '+
                      '     sMensagem '+
                      ' from tbMensagem '+
                      ' where '+
                      {$IFDEF corporate}
                      CODIGO_EMPRESA+' = '+sCodEmpresa+' and '+
                      {$ENDIF}
                      ' nIDMensagem = '+IntToStr(CodMensagem)+
                      ' and nIDUsuario = '+IntToStr(frmPrincipal.nCodUsuario);
      Open;
      frmMsg := TfrmMsg.Create(self);
      with frmMsg do begin
        Enviar(False);
        edtUsuario.Text  := FieldByName('sOrigem').AsString;
        memoMsg.Text     := frmPrincipal.Descodificar(FieldByName('sMensagem').AsString);
        edtData.Text     := FieldByName('dHora').AsString;
        Show;
      end;
    end;

end;


procedure TfrmMensagens.AtualizaMensagens;
begin
  if frmPrincipal.SQLConnection1.Connected then begin
    frmPrincipal.StatusBar.Panels[2].Text := 'Atualizando mensagens...';
    ClientDataSet1.Active := False;
    with SQLDataSet1 do begin
      Close;
      CommandText := sQuery;
      Open;
    end;
    ClientDataSet1.Active := True;

  end;
  frmPrincipal.StatusBar.Panels[2].Text := '';

  //Desabilita alerta
  frmPrincipal.VerificaMensagem;
  frmPrincipal.TimerPiscaMensagem.Enabled := False;
  frmPrincipal.StatusBar.Panels[3].Text := '';
  DBGridBusca.SetFocus;
end;


procedure TfrmMensagens.FormCreate(Sender: TObject);
begin
 {$IFDEF corporate}
    sCodEmpresa := frmPrincipal.Codigo_Empresa;
 {$ENDIF}
end;

procedure TfrmMensagens.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMensagens.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin

  with frmPrincipal.ActMensagems do begin
    Visible := True;
    Enabled := True;
  end;

  with frmPrincipal.N4 do begin
    Visible := True;
    Enabled := True;
  end;

  Action := cafree;
end;

procedure TfrmMensagens.btnAtualizarClick(Sender: TObject);
begin
 AtualizaMensagens;
end;

procedure TfrmMensagens.DBGridBuscaDblClick(Sender: TObject);
begin
  if (DBGridBusca.Fields[0].AsString <> '') then
     AbreMensagem(DBGridBusca.Fields[0].AsInteger);
end;

procedure TfrmMensagens.btnNovoClick(Sender: TObject);
begin
  AbreFormMensagem(False);
end;

procedure TfrmMensagens.ToolButton2Click(Sender: TObject);
begin
  AbreFormMensagem(True);
end;

procedure TfrmMensagens.btnExcluirClick(Sender: TObject);
begin
 if (DBGridBusca.Fields[0].AsString <> '') then
   if MessageDlg(ExcluirDados,  mtConfirmation, [mbYes, mbNo], 0) = mrYes then 
      with SQLDataSet1 do begin
        Close;
        CommandText := ' delete '+
                       ' from tbMensagem '+
                       ' where '+
                       {$IFDEF corporate}
                       CODIGO_EMPRESA+' = '+sCodEmpresa+' and '+
                       {$ENDIF}
                       ' nIDMensagem = '+DBGridBusca.Fields[0].AsString+
                       ' and nIDUsuario = '+IntToStr(frmPrincipal.nCodUsuario);
        ExecSql;
        AtualizaMensagens;
      end;
end;

end.
