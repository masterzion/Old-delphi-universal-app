unit formMsg;

interface
{$include configura.inc}

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, principal, FMTBcd, DB, SqlExpr, QButtons,
  mzComboBoxClx, mzDBComboBoxClx, QMask, mzCustomEdit, mzNumEditclx,
  QExtCtrls, mzlib,QComCtrls, mzCustomBtnEditclx, mzDatePicker;

type
  TfrmMsg = class(TForm)
    Controle: TToolBar;
    btnEnviar: TToolButton;
    btnResponder: TToolButton;
    ToolButton8: TToolButton;
    btnFechar: TToolButton;
    PanelUsuario: TPanel;
    edtUsuario: TNumEditclx;
    edtData: TNumEditclx;
    PanelEnviar: TPanel;
    Panel2: TPanel;
    lstDestinos: TListBox;
    AddUsr: TSpeedButton;
    AddGrupo: TSpeedButton;
    btnDelUser: TSpeedButton;
    memoMsg: TMemo;
    SQLDataSet: TSQLDataSet;
    cmbUsuarios: TmzDBComboBoxClx;
    cmbGrupo: TmzDBComboBoxClx;
    PanelDataLembrete: TPanel;
    DTLembrete: TmzDatePicker;
    procedure FormCreate(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnResponderClick(Sender: TObject);
    procedure btnEnviarClick(Sender: TObject);
    procedure AddUsrClick(Sender: TObject);
    procedure AddGrupoClick(Sender: TObject);
    procedure btnDelUserClick(Sender: TObject);
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

procedure TfrmMsg.btnDelUserClick(Sender: TObject);
begin
 if (lstDestinos.Itemindex > -1) then lstDestinos.Items.delete(lstDestinos.Itemindex);
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
                         CODIGO_EMPRESA+' = '+frmPrincipal.Codigo_Empresa+
                         {$ENDIF}
                         '';
       SQLConnection := frmPrincipal.SQLConnection1;
       Active := True;
   end;


   with cmbGrupo do begin
       SQLQuery.Text :=  ' select nIDGrupo,sNomeGrupo from tbGrupo '+
                         {$IFDEF corporate}
                         ' where '+
                         CODIGO_EMPRESA+' = '+frmPrincipal.Codigo_Empresa+
                         {$ENDIF}
                         '';
       SQLConnection := frmPrincipal.SQLConnection1;
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
var
 Lista: TStringList;
 n:Integer;
begin
  Enviar(True);
  lstDestinos.Items.Add(edtUsuario.Text);
  Lista := TStringList.Create;
  Lista.Add('');
  for n := 0 to memoMsg.Lines.Count-1 do  Lista.Add('>'+memoMsg.Lines.Strings[n]);
  memoMsg.Text := Lista.Text;
  Lista.Destroy;

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
  sData, sNomeUsuario : string;
  n : Integer;
  InDate      : TDateTime;
  Dia, Mes, Ano : Word;
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
                     CODIGO_EMPRESA+' = '+
                       {$IFDEF corporate}frmPrincipal.Codigo_Empresa{$ENDIF}
                       {$IFDEF personal}'1'{$ENDIF}
                       +' and '+
                     RetornaListaUsuario;

     Active := True;
     First;
     while not eof do begin
       slista.Add(FieldByName('nIDUsuario').AsString);
       Next;
     end;


     if PanelDataLembrete.Visible then begin
       InDate := StrToDate(DTLembrete.Text);
       DecodeDate(InDate, Dia, Mes, Ano);
       sData := ', '+S_AP+concat( inttostr(Dia),'/',inttostr(Mes),'/',inttostr(Ano) )+S_AP+' , ';
     end
     else
       sData := ', '+sNow+', ';


     // Insere dados
     for n := 0 to slista.count-1 do begin
         Active := False;
         CommandText :=  ' insert into tbMensagem ('+
                          CODIGO_EMPRESA+' , '+
                          ' nIDUsuario, sOrigem, dHora, sMensagem )'+
                          ' values ( '+
                          {$IFDEF corporate}sCodEmpresa{$ENDIF}
                          {$IFDEF personal}'1'{$ENDIF}
                          +' , '+slista.strings[n]+', '+S_AP+sNomeUsuario+S_AP+sData+SQL_PARM +'sMensagem )';

         Params[0].Name  := 'sMensagem';
         Params[0].Value := frmPrincipal.Codificar(memoMsg.Text);

         ExecSql;
     end;
   end;
   slista.Destroy;
   ShowMessage(msgEnviada);
   Close;
end;

procedure TfrmMsg.AddUsrClick(Sender: TObject);
begin
 lstDestinos.Items.Add(cmbUsuarios.Text);
end;

procedure TfrmMsg.AddGrupoClick(Sender: TObject);
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
                       ' and  tbGrupo.'+CODIGO_EMPRESA+'  = '+frmPrincipal.Codigo_Empresa+
                       ' and  tbUsuario.'+CODIGO_EMPRESA+' = tbGrupo.'+CODIGO_EMPRESA+
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

end.
