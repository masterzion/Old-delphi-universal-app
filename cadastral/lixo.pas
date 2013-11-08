unit formMsg;
{$include configura.inc}

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms, 
  QDialogs, QStdCtrls, principal, QButtons, mzComboBoxClx, mzDBComboBoxClx,
  QMask, mzCustomEdit, mzNumEditclx, QExtCtrls, QComCtrls, mzlib, FMTBcd,
  DB, SqlExpr;

type
  TfrmMsg = class(TForm)
    Controle: TToolBar;
    btnEnviar: TToolButton;
    ToolButton8: TToolButton;
    btnFechar: TToolButton;
    btnResponder: TToolButton;
    PanelUsuario: TPanel;
    edtUsuario: TNumEditclx;
    PanelEnviar: TPanel;
    edtData: TNumEditclx;
    lstDestinos: TListBox;
    Panel1: TPanel;
    cmbUsuarios: TmzDBComboBoxClx;
    cmbGrupo: TmzDBComboBoxClx;
    btnAddUser: TSpeedButton;
    btnAddGrupo: TSpeedButton;
    btnDelUsr: TSpeedButton;
    SQLDataSet: TSQLDataSet;
    memoMsg: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnResponderClick(Sender: TObject);
    procedure btnEnviarClick(Sender: TObject);
    procedure btnAddUserClick(Sender: TObject);
    procedure btnAddGrupoClick(Sender: TObject);
    procedure btnDelUsrClick(Sender: TObject);
  private
    { Private declarations }
  {$IFDEF corporate}
    sCodEmpresa : string;
  {$ENDIF}
    nCodUsuario : Integer;
  public
    procedure Enviar(bEnviar:Boolean);
    { Public declarations }
  end;

var
  frmMsg: TfrmMsg;

implementation

{$R *.xfm}

procedure TfrmMsg.Enviar(bEnviar:Boolean);
var
 InEnviar: Boolean;
begin
    InEnviar := not bEnviar;

    btnResponder.Enabled := InEnviar;
    btnResponder.Visible := InEnviar;

    PanelUsuario.Enabled := InEnviar;
    PanelUsuario.Visible := InEnviar;

    memoMsg.ReadOnly     := InEnviar;

    PanelEnviar.Enabled  := bEnviar;
    PanelEnviar.Visible  := bEnviar;

    btnEnviar.Enabled  := bEnviar;
    btnEnviar.Visible  := bEnviar;
end;

procedure TfrmMsg.FormCreate(Sender: TObject);
begin
  {$IFDEF corporate}
    sCodEmpresa := frmPrincipal.Codigo_Empresa;
  {$ENDIF}

   nCodUsuario := frmPrincipal.nCodUsuario;

   with cmbUsuarios do begin
       SQLQuery.Text :=  ' select nIDUsuario,sNomeUsuario from tbUsuario '+
                         {$IFDEF corporate}
                         ' where '+
                         ' nIDEmpresa = '+frmPrincipal.Codigo_Empresa+
                         {$ENDIF}
                         '';
       Active := True;
   end;


   with cmbGrupo do begin
       SQLQuery.Text :=  ' select nIDGrupo,sNomeGrupo from tbGrupo '+
                         {$IFDEF corporate}
                         ' where '+
                         ' nIDEmpresa = '+frmPrincipal.Codigo_Empresa+
                         {$ENDIF}
                         '';
       Active := True;
   end;

end;

procedure TfrmMsg.btnFecharClick(Sender: TObject);
begin
 Close;
end;

procedure TfrmMsg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 Action := caFree;
end;

procedure TfrmMsg.btnResponderClick(Sender: TObject);
begin
  Enviar(True);
  lstDestinos.Items.Add(edtUsuario.Text);
end;

procedure TfrmMsg.btnEnviarClick(Sender: TObject);
 function RetornaListaUsuario : string;
 var
   n : Integer;
   sTemp : String;
 begin
   for n := 0 to lstDestinos.Items.count-1 do
     sTemp := sTemp+ ' or sNomeUsuario = '+S_AP+lstDestinos.Items[n]+S_AP;
   Result := '('+copy(sTemp, 4, Length(sTemp))+')';
 end;

var
  slista : TStringList;
  sNomeUsuario : string;
  n : Integer;
begin
  if (lstDestinos.Items.Count = 0) then begin
    ShowMessage(msgErrSemDestino);
    exit;
  end;

  if (memoMsg.Text = '') then begin
    ShowMessage(msgErrEmBranco);
    exit;
  end;

   sNomeUsuario := frmPrincipal.sNomeUsuario;
   //Cria lista dos codigos dos usuarios
   slista := TStringList.Create;
   with SQLDataSet do begin
     Active := False;
     CommandText :=  ' select '+
                     '    nIDUsuario '+
                     ' from '+
                     '      tbUsuario  '+
                     ' where '+
                     {$IFDEF corporate}
                     '  nIDEmpresa  = '+frmPrincipal.Codigo_Empresa+' and '+
                     {$ENDIF}
                     RetornaListaUsuario;

     Active := True;
     First;
     while not eof do begin
       slista.Add(FieldByName('nIDUsuario').AsString);
       Next;
     end;

     // Insere dados
     for n := 0 to slista.count-1 do begin
         Active := False;
         CommandText :=  ' insert into tbMensagem ('+
                          {$IFDEF corporate}
                          ' nIDEmpresa, '+
                          {$ENDIF}
                          ' nIDUsuario, sOrigem, dHora, sMensagem )'+
                          ' values ( '+
                          {$IFDEF corporate}
                          sCodEmpresa+' , '+
                          {$ENDIF}
                          slista.strings[n]+', '+S_AP+sNomeUsuario+S_AP+', now(), '+S_AP+memoMsg.Text+S_AP+' )';
         ExecSql;
     end;
   end;
   slista.Destroy;
   ShowMessage(msgEnviada);
   Close;
end;

procedure TfrmMsg.btnAddUserClick(Sender: TObject);
begin
 lstDestinos.Items.Add(cmbUsuarios.Text);
end;

procedure TfrmMsg.btnAddGrupoClick(Sender: TObject);
begin
   with SQLDataSet do begin
       Active := False;
       CommandText :=  ' select '+
                       '    sNomeUsuario '+
                       ' from '+
                       '      tbUsuario , '+
                       '      tbGrupo '+
                       ' where tbGrupo.sNomeGrupo = '+S_AP+cmbGrupo.Text+S_AP+
                       {$IFDEF corporate}
                       ' and  tbGrupo.nIDEmpresa  = '+frmPrincipal.Codigo_Empresa+
                       ' and  tbUsuario.nIDEmpresa = tbGrupo.nIDEmpresa'+
                       {$ENDIF}
                       ' and  tbGrupo.nIDGrupo     = tbUsuario.nIDGrupo';
       Active := True;
       First;
       while not eof do begin
         lstDestinos.Items.Add(FieldByName('sNomeUsuario').AsString);
         Next;
       end;
   end;
end;

procedure TfrmMsg.btnDelUsrClick(Sender: TObject);
begin
 if (lstDestinos.Itemindex > -1) then lstDestinos.Items.delete(lstDestinos.Itemindex);
end;

end.
