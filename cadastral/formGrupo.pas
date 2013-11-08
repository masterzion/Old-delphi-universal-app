unit formGrupo;

{$include configura.inc}

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, QExtCtrls, QComCtrls, principal, FMTBcd, DB, SqlExpr, mzlib;

type
  TfrmGrupo = class(TForm)
    Controle: TToolBar;
    ToolButton5: TToolButton;
    btnNovo: TToolButton;
    ToolButton8: TToolButton;
    btnExcluir: TToolButton;
    btnFechar: TToolButton;
    Panel2: TPanel;
    Panel1: TPanel;
    bSalvar: TCheckBox;
    bLocalizar: TCheckBox;
    bExcluir: TCheckBox;
    ListBoxTabela: TListBox;
    ListBoxGrupo: TListBox;
    Splitter1: TSplitter;
    SQLDataSet: TSQLDataSet;
    SQLDataSet2: TSQLDataSet;
    procedure bSalvarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ListBoxGrupoClick(Sender: TObject);
    procedure ListBoxTabelaClick(Sender: TObject);
    procedure bLocalizarClick(Sender: TObject);
    procedure bExcluirClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
  private
    { Private declarations }
    {$IFDEF corporate}
      sCodEmpresa : string;
    {$ENDIF}
    Atualizando : Boolean;
    procedure AtualizaTabelas;
    procedure AtualizaGrupos;

    procedure CarregaAcesso;
    procedure SalvaAcesso;

    procedure AbilitaChecks(Abilitado:Boolean);
    procedure TentaAbrir(const NomeTabela:String;const Tipo:Boolean);
  public
    { Public declarations }
  end;

var
  frmGrupo: TfrmGrupo;

implementation

{$R *.xfm}

procedure TfrmGrupo.CarregaAcesso;
begin
  if (ListBoxGrupo.ItemIndex = -1) or (ListBoxTabela.ItemIndex = -1) then exit;
  with SQLDataSet2 do begin
   Close;
   CommandText :=  ' select bSalvar , '+
                            ' bLocalizar, '+
                            ' bExcluir '+
                   ' from '+
                      ' tbGrupo, '+
                      ' tbSeguranca,'+
                      ' tbForm '+
                   ' where sNomeGrupo  = '+S_AP+ListBoxGrupo.Items.Strings[ListBoxGrupo.ItemIndex]   +S_AP+
                   ' and   sTitulo     = '+S_AP+ListBoxTabela.Items.Strings[ListBoxTabela.ItemIndex] +S_AP+
                    {$IFDEF corporate}
                    ' and   tbSeguranca.'+CODIGO_EMPRESA+'  = '+sCodEmpresa+
                    ' and   tbGrupo.'+CODIGO_EMPRESA+'      = tbSeguranca.'+CODIGO_EMPRESA+
                    {$ENDIF}
                   ' and   tbGrupo.nIDGrupo    = tbSeguranca.nIDGrupo '+
                   ' and   tbSeguranca.nIDForm = tbForm.nIDForm';

    try
        Open;
    except
      on E : EDatabaseError do  begin
        ShowMessage('Erro ao abrir tabela "tbGrupo / tbSeguranca / tbForm"'+#13+E.Message);
        Close;
      end;
    end;
    First;
    Atualizando := True;
    bSalvar.Checked    := (SQLDataSet2.Fields[0].AsString = 'Y');
    bLocalizar.Checked := (SQLDataSet2.Fields[1].AsString = 'Y');
    bExcluir.Checked   := (SQLDataSet2.Fields[2].AsString = 'Y');
    Atualizando := False;
    close;
  end;
end;


procedure TfrmGrupo.SalvaAcesso;
  function iif(const Expressao:TCheckBox):string;
  begin
    if Expressao.Checked then
     result := '"Y"'
    else
     result := '"N"';
  end;

var
 sTemp : String;
 nIDForm, nCodGrupo : Integer;
begin
  if (ListBoxGrupo.ItemIndex = -1) or (ListBoxTabela.ItemIndex = -1) or   Atualizando  then exit;
  AbilitaChecks(False);
  with SQLDataSet do begin
    //Pega codigo da tabela
    sTemp := ListBoxTabela.Items.Strings[ListBoxTabela.ItemIndex];
    Close;
    CommandText := ' select nIDForm as codigo '+
                   ' from tbForm '+
                   ' where sTitulo = "'+sTemp+'" ';
    TentaAbrir(sTemp, True);
    nIDForm := FieldbyName('codigo').AsInteger;

    //Pega codigo do grupo
    sTemp := ListBoxGrupo.Items.Strings[ListBoxGrupo.ItemIndex];
    Close;
    CommandText := ' select nIDGrupo as codigo '+
                   ' from tbGrupo '+
                   ' where '+
                    {$IFDEF corporate}
                    CODIGO_EMPRESA+'  = '+sCodEmpresa+' and '+
                    {$ENDIF}
                   ' sNomeGrupo = "'+sTemp+'" ';
    TentaAbrir(sTemp, True);
    nCodGrupo := FieldbyName('codigo').AsInteger;


    //Apaga tudo
    sTemp := ListBoxGrupo.Items.Strings[ListBoxGrupo.ItemIndex];
    Close;
    commandText :=  ' delete '+
                    ' from  tbSeguranca '+
                    ' where nIDGrupo =  ' + inttostr(nCodGrupo)  +
                    {$IFDEF corporate}
                    ' and '+CODIGO_EMPRESA+' = '+sCodEmpresa+
                    {$ENDIF}
                    ' and   nIDForm = ' + inttostr(nIDForm) ;
    TentaAbrir(sTemp, False);

    //Insere novo
    Close;
    commandText :=  ' insert into tbSeguranca'+
                    ' (nIDGrupo , nIDForm , bSalvar , bLocalizar ,bExcluir , '+CODIGO_EMPRESA+') '+
                    ' values '+
                    ' ( '+ inttostr(nCodGrupo) +' , '+ inttostr(nIDForm)+' , '+iif(bSalvar)+' , '+iif(bLocalizar)+' , '+iif(bExcluir)+', '  {$IFDEF personal}+'1'+{$ENDIF}   {$IFDEF corporate}+sCodEmpresa+{$ENDIF}')';
    TentaAbrir(sTemp, False);
  end;  // with
  AbilitaChecks(True);
end;


procedure TfrmGrupo.AbilitaChecks(Abilitado:Boolean);
begin
  bSalvar.Enabled   := Abilitado;
  blocalizar.Enabled := Abilitado;
  bExcluir.Enabled   := Abilitado;
end;



procedure TfrmGrupo.btnExcluirClick(Sender: TObject);
var
 sTemp : string;
 nCodGrupo : integer;
begin
  if (ListBoxGrupo.ItemIndex = -1) then exit;
  sTemp := ListBoxGrupo.Items.Strings[ListBoxGrupo.ItemIndex];
  if not (MessageDlg('Você deseja excluir o grupo "'+sTemp+'"? ',  mtConfirmation, [mbYes, mbNo], 0) = mrYes) then exit;
  with SqlDataSet do begin
    sTemp := ListBoxGrupo.Items.Strings[ListBoxGrupo.ItemIndex];
    Close;
    CommandText := ' select nIDGrupo as codigo '+
                   ' from tbGrupo '+
                   ' where '+
                    {$IFDEF corporate}
                    ' '+CODIGO_EMPRESA+' = '+sCodEmpresa+' and '+
                    {$ENDIF}
                   'sNomeGrupo = "'+sTemp+'" ';


    TentaAbrir(sTemp, True);
    nCodGrupo := FieldbyName('codigo').AsInteger;

    Close;
    CommandText := ' delete from tbSeguranca where '+
                    {$IFDEF corporate}
                    ' '+CODIGO_EMPRESA+' = '+sCodEmpresa+' and '+
                    {$ENDIF}
                     'nIDGrupo = '+inttostr(nCodGrupo);
    TentaAbrir('tbSeguranca', False);

    Close;
    CommandText := ' delete from tbGrupo where '+
                   {$IFDEF corporate}
                   CODIGO_EMPRESA+' = '+sCodEmpresa+' and '+
                   {$ENDIF}
                   ' nIDGrupo = '+inttostr(nCodGrupo);
    TentaAbrir('tbGrupo', False);

    ShowMessage('O grupo "'+sTemp+'" foi excluido!');
    AtualizaGrupos;
  end;
end;

procedure TfrmGrupo.btnFecharClick(Sender: TObject);
begin
 Close;
end;

procedure TfrmGrupo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  with frmPrincipal.ActGrupo do begin
    Visible  := True;
    Enabled  := True;
  end;

 Action := caFree;
end;

procedure TfrmGrupo.TentaAbrir(const NomeTabela:String;const Tipo:Boolean);
begin
    try
      if Tipo then
        SQLDataSet.Open
      else
        SQLDataSet.ExecSQL;
    except
      on E : EDatabaseError do  begin
        ShowMessage('Erro ao abrir tabela "'+NomeTabela+'"'+#13+E.Message);
        Close;
      end;
    end;
end;


procedure TfrmGrupo.AtualizaGrupos;
var
  n : Integer;
begin
  btnExcluir.Enabled := False;
  with SQLDataSet do begin
    Close;
    CommandText := 'select sNomeGrupo as Grupo from tbGrupo'+
                   {$IFDEF corporate}
                   ' where '+CODIGO_EMPRESA+' = '+sCodEmpresa+
                   {$ENDIF}
                   '';

    TentaAbrir('tbGrupo', True);
    First;
    ListBoxGrupo.Items.Clear;

    for n := 0 to RecordCount-1 do begin
      ListBoxGrupo.Items.Add(FieldByName('Grupo').AsString);
      Next;
    end;
    close;
  end;
end;

procedure TfrmGrupo.AtualizaTabelas;
var
  n : Integer;
begin
  with SQLDataSet do begin
    Close;
    CommandText := 'select sTitulo as Tabela from tbForm';
    TentaAbrir('tbForm', True);
    First;
    ListBoxTabela.Items.Clear;
    for n := 0 to RecordCount-1 do begin
      ListBoxTabela.Items.Add(FieldByName('Tabela').AsString);
      Next;
    end;
    close;
  end;
end;


procedure TfrmGrupo.FormCreate(Sender: TObject);
begin
 {$IFDEF corporate}
   sCodEmpresa :=frmPrincipal.Codigo_Empresa;
 {$ENDIF}

  if (frmPrincipal.sNomeUsuario <> 'ROOT') then close;
  Atualizando := True;
  AtualizaGrupos;
  AtualizaTabelas;
  Atualizando := False;
end;

procedure TfrmGrupo.ListBoxGrupoClick(Sender: TObject);
begin
 AbilitaChecks( not  ((ListBoxGrupo.ItemIndex = -1) or (ListBoxTabela.ItemIndex = -1)) );
 btnExcluir.Enabled := (ListBoxGrupo.ItemIndex <> -1);
 CarregaAcesso;
end;

procedure TfrmGrupo.ListBoxTabelaClick(Sender: TObject);
begin
 AbilitaChecks( not  ((ListBoxGrupo.ItemIndex = -1) or (ListBoxTabela.ItemIndex = -1)) );
 CarregaAcesso;
end;

procedure TfrmGrupo.bSalvarClick(Sender: TObject);
begin
  SalvaAcesso;
end;


procedure TfrmGrupo.bLocalizarClick(Sender: TObject);
begin
  SalvaAcesso;
end;


procedure TfrmGrupo.bExcluirClick(Sender: TObject);
begin
  SalvaAcesso;
end;

procedure TfrmGrupo.btnNovoClick(Sender: TObject);
var
 sGrupo : string;
begin
  if not InputQuery('Nome do grupo...','Insira o nome do novo grupo:', sGrupo) then exit;
  sGrupo := uppercase(sGrupo);
  with SQLDataSet do begin
    Close;
    CommandText := 'select count(*) as contagem from  tbGrupo  where sNomeGrupo = "'+sGrupo+'"'+
                   {$IFDEF corporate}
                   ' and '+CODIGO_EMPRESA+' = '+sCodEmpresa+
                   {$ENDIF}
                   '';

    TentaAbrir('tbGrupos', true);

    if (FieldbyName('contagem').AsInteger <> 0) then begin
      ShowMessage('Já existe um grupo de usuarios com esse nome!');
      exit;
    end
    else begin
      Close;

      CommandText := 'Insert into tbGrupo (sNomeGrupo, '+CODIGO_EMPRESA+') values ("'+sGrupo+'"'+{$IFDEF corporate} ' , '+sCodEmpresa+ {$ENDIF}  {$IFDEF personal} ' , 1'+ {$ENDIF}')';
      TentaAbrir('tbGrupos', False);
      AtualizaGrupos;
    end;
  end;

end;

end.
