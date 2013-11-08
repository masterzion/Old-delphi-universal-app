unit grupos;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QComCtrls, QStdCtrls, DBXpress, FMTBcd, DB, SqlExpr, QGrids;

type
  TtbGrupos = class(TForm)
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    Query: TSQLQuery;
    ListBox1: TListBox;
    procedure Atualiza;
    //------------
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
      LIB_DLL, DRV_DLL : String;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  tbGrupos: TtbGrupos;

implementation
uses principal;

{$R *.xfm}
procedure TtbGrupos.Atualiza;
begin
  ListBox1.Clear;
  with Query do begin
   SQL.Text := 'select * from tbGrupo';
   Open;
   First;
   while not (Eof) do begin
     ListBox1.Items.Add(FieldByName('sNomeGrupo').AsString);
     Next;
   end;
   Close;
  end;
end;

procedure TtbGrupos.ToolButton1Click(Sender: TObject);
var
  Grupo:String;
begin
  if not InputQuery('Nome do Grupo', 'Digite o nome do novo grupo', Grupo) then exit;
  with Query do begin
   SQL.Text := concat(' select count(*) as contagem from tbGrupo',#10,#13,
                      ' where sNomeGrupo like "',Grupo,'"');
   Open;
   First;
   if (FieldByName('contagem').AsInteger = 0) then begin
     SQL.Text := concat('insert into tbGrupo (sNomeGrupo) Values ("',uppercase(Grupo),'")');
     ExecSQL;
   end
   else
     ShowMessage('Já existe um grupo com esse nome!!')
  end;
  Atualiza;
end;

procedure TtbGrupos.ToolButton2Click(Sender: TObject);
var
 nCodGrupo : String;
begin
 if (MessageDlg('Você deseja apagar esse item? Atenção, as referencias com os usuarios também serão eliminadas!', mtConfirmation, [mbYes, mbNo], 0) = mrNo) then exit;
  if (ListBox1.ItemIndex = -1) then begin
    ShowMessage('Escolha um item para ser excluido!');
    exit;
  end;

  with Query do begin
   SQL.Text := concat(' select nCodGrupo from tbGrupo where sNomeGrupo like "', uppercase(ListBox1.Items.Strings[ListBox1.ItemIndex]),'"');
   Open;

   nCodGrupo := FieldByName('nCodGrupo').AsString;

   SQL.Text := concat(' delete from tbGrupo where nCodGrupo = ', nCodGrupo);
   ExecSQL;

   SQL.Text := concat(' delete from tbGrupoUsuario where nCodGrupo = ', nCodGrupo);
   ExecSQL;
  end;


  Atualiza;
end;

procedure TtbGrupos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  with frmPrincipal.Grupos do begin
    Visible := True;
    Enabled  := True;
  end;
  Action := caFree;
end;

procedure TtbGrupos.FormCreate(Sender: TObject);
begin
 Atualiza;
end;

end.
