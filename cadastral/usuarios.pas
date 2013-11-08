unit usuarios;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QCheckLst, QStdCtrls, QComCtrls, DBXpress, FMTBcd, DB, SqlExpr, QExtCtrls;

type
  TArSTR = array of string;
  TtbUsuarios = class(TForm)
    ToolBar1: TToolBar;
    btnAdicionar: TToolButton;
    btnRemove: TToolButton;
    ListBox1: TListBox;
    Query: TSQLQuery;
    CheckListBox1: TCheckListBox;
    procedure Verifica;
    procedure AtualizaCheck;
    procedure Atualiza;
    procedure AtualizaGrupos;
    function AddInArray(CamposPar: TArSTR; valor:String):TArSTR;
    //--------
    procedure btnAdicionarClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListBox1Click(Sender: TObject);
    procedure CheckListBox1ClickCheck(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
  private
      LIB_DLL, DRV_DLL, Usuario:String;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  tbUsuarios: TtbUsuarios;

implementation

uses principal;

{$R *.xfm}


function TtbUsuarios.AddInArray(CamposPar: TArSTR; valor:String):TArSTR;
var
    temp:TArSTR;
    N: Integer;
begin
    temp := CamposPar;
    setlength(temp, length(temp) + 1);
    N := length(temp);
    while N < (Length(temp)-1) do temp[N] := CamposPar[N];
    temp[Length(temp)-1] := valor;
    Result := temp;
end;

procedure TtbUsuarios.Verifica;
begin
 Atualiza;
 CheckListBox1.Enabled := not (ListBox1.Items.Count = 0);
 ListBox1.Enabled := CheckListBox1.Enabled;
 btnRemove.Enabled := CheckListBox1.Enabled;
 if ListBox1.Enabled then begin
   ListBox1.ItemIndex := 0;
   ListBox1.Selected[0] := true;
 end;

end;


procedure TtbUsuarios.Atualiza;
begin
  ListBox1.Clear;
  with Query do begin
   SQL.Text := 'select * from tbUsuario order by sNomeUsuario';
   Open;
   First;
   while not (Eof) do begin
     ListBox1.Items.Add(FieldByName('sNomeUsuario').AsString);
     Next;
   end;
   Close;
  end;
end;

procedure TtbUsuarios.AtualizaGrupos;
begin
  CheckListBox1.Clear;
  with Query do begin
   SQL.Text := ' select * from tbGrupo sNomeGrupo';
   Open;
   First;
   while not (Eof) do begin
     CheckListBox1.Items.Add(FieldByName('sNomeGrupo').AsString);
     Next;
   end;
   Close;
  end;
end;

procedure TtbUsuarios.AtualizaCheck;
var
 CodUsuario:String;
 ListaGrupos: TArSTR;
 n, n2 : Integer;
 Pertence : Boolean;
begin
  CheckListBox1.Clear;
  AtualizaGrupos;

  with Query do begin
   SQL.Text := ' select nCodUsuario from tbUsuario '+
               ' where sNomeUsuario = "'+uppercase(ListBox1.Items.Strings[ListBox1.ItemIndex])+'"';

   Open;
   First;

   CodUsuario := Fieldbyname('nCodUsuario').AsString;
   SQL.Text := ' select tbGrupo.sNomeGrupo as Nome from tbGrupoUsuario, tbGrupo '+
               ' where nCodUsuario = '+CodUsuario+
               ' and tbGrupoUsuario.nCodGrupo = tbGrupo.nCodGrupo';
   Open;
   First;

   while not (Eof) do begin
     ListaGrupos := AddInArray(ListaGrupos, FieldByName('Nome').AsString);
     Next;
   end;

   for n := 0 to CheckListBox1.Items.Count-1 do begin
       Pertence := False;
       for n2 := 0 to length(ListaGrupos)-1 do
         if CheckListBox1.Items.Strings[N] = ListaGrupos[n2] then Pertence := True;
       CheckListBox1.Checked[n] := Pertence;
   end;
  end;
end;


procedure TtbUsuarios.btnAdicionarClick(Sender: TObject);
var
Nome:String;
begin
  if not InputQuery('Nome do Grupo', 'Digite o nome do novo grupo', Nome) then exit;
  with Query do begin
   SQL.Text := concat(' select count(*) as contagem from tbUsuario',#10,#13,
                      ' where sNomeUsuario like "',Nome,'"');
   Open;
   First;
   if (FieldByName('contagem').AsInteger = 0) then begin
     SQL.Text := concat('insert into tbUsuario (sNomeUsuario) Values ("',uppercase(Nome),'")');
     ExecSQL;
   end
   else
     ShowMessage('Já existe um Usuario com esse nome!!')
  end;
  Atualiza;
  Verifica;
end;

procedure TtbUsuarios.btnRemoveClick(Sender: TObject);
begin
 if (MessageDlg('Você deseja apagar esse item?', mtConfirmation, [mbYes, mbNo], 0) = mrNo) then exit;
  if (ListBox1.ItemIndex = -1) then begin
    ShowMessage('Escolha um item para ser excluido!');
    exit;
  end;

  with Query do begin
   SQL.Text := concat(' delete from tbUsuario where sNomeUsuario like "', uppercase(ListBox1.Items.Strings[ListBox1.ItemIndex]),'"');
   ExecSQL;
  end;
  Atualiza;
  Verifica;
end;

procedure TtbUsuarios.FormCreate(Sender: TObject);
begin
  Atualiza;
  Verifica;
end;

procedure TtbUsuarios.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  with frmPrincipal.Usuarios do begin
    Visible := True;
    Enabled  := True;
  end;
  Action := caFree;
end;

procedure TtbUsuarios.ListBox1Click(Sender: TObject);
begin
  with Query do begin
   SQL.Text := ' select nCodUsuario from tbUsuario '+
               ' where sNomeUsuario = "'+ListBox1.Items.Strings[ListBox1.ItemIndex]+'"';
   Open;
   Usuario := Fieldbyname('nCodUsuario').AsString;
  end;
  AtualizaCheck;
end;

procedure TtbUsuarios.CheckListBox1ClickCheck(Sender: TObject);
var
 CodGrupo : String;
begin
  with Query do begin
   SQL.Text := ' select nCodGrupo from tbGrupo '+
               ' where sNomeGrupo = "'+CheckListBox1.Items.Strings[CheckListBox1.ItemIndex]+'"';
   Open;
   First;
   CodGrupo := Fieldbyname('nCodGrupo').AsString;

   SQL.Text := concat(' select count(*) as contagem from tbGrupoUsuario, tbGrupo ',
                      ' where tbGrupo.nCodGrupo = ',CodGrupo,
                      ' and tbGrupoUsuario.nCodUsuario = ',Usuario,
                      ' and tbGrupoUsuario.nCodGrupo = tbGrupo.nCodGrupo');
   Open;
   First;

   if (Fieldbyname('contagem').AsInteger = 0) then
     SQL.Text := concat(' insert tbGrupoUsuario ',
                        ' (nCodUsuario, nCodGrupo)',
                        ' values ',
                        '(', Usuario ,' , ',CodGrupo,')')
   else
     SQL.Text := concat(' delete from tbGrupoUsuario ',
                        ' where nCodUsuario = ',Usuario,
                        ' and nCodGrupo = ',CodGrupo);
   ExecSQL;

  end;
  CheckListBox1.Clear;
  AtualizaGrupos;
  AtualizaCheck;
end;

procedure TtbUsuarios.ListBox1DblClick(Sender: TObject);
var
 sTemp, Senha:String;

begin
  sTemp := ListBox1.Items.Strings[ListBox1.ItemIndex];
  with Query do begin
     if not InputQuery(sTemp, 'Digite uma senha para o:', Senha) then exit;
     SQL.Text := concat(' update tbUsuario set',
                        ' sSenha = MD5(',Senha,')');
     ExecSQL;
  end;

end;

end.

