unit DBGridEditor;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, QMask, QExtCtrls, QDBGrids, QButtons,
  mzComboBoxClx, mzDBgrid, mzlib, DB, kbmMemTable, FMTBcd, SqlExpr,
  mzCustomEdit, mzNumEditclx;

type
  TfrmDBGridEditor = class(TForm)
    Panel1: TPanel;
    Splitter1: TSplitter;
    Panel2: TPanel;
    btnOK: TBitBtn;
    Panel4: TPanel;
    sEditMask: TNumEditclx;
    Panel5: TPanel;
    Panel6: TPanel;
    ListBox: TListBox;
    btnUp: TBitBtn;
    Panel7: TPanel;
    chkVisible: TCheckBox;
    btnDown: TBitBtn;
    Panel8: TPanel;
    cmbTabela: TmzComboBoxClx;
    btnAltera: TBitBtn;
    Panel3: TPanel;
    EditCaption: TNumEditclx;
    Panel9: TPanel;
    edtName: TNumEditclx;
    chkAutoInc: TCheckBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListBoxClick(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure EditCaptionExit(Sender: TObject);
    procedure btnAlteraClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
    Adicionado : Boolean;
    procedure SalvarDados;
    procedure CarregaDados;
  public
    Grid        : TmzDbgrid;
    QueryAux    : TSQLQuery;
    ListaArray  : TListArray;
    procedure Prepara(Atual:Integer);
    { Public declarations }
  end;

var
  frmDBGridEditor: TfrmDBGridEditor;

implementation

uses FormEditor;

{$R *.xfm}

procedure TfrmDBGridEditor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 Action := caFree;
end;

procedure TfrmDBGridEditor.Prepara(Atual:Integer);
var
  N : Integer;
begin
  Adicionado := False;
  edtName.Text        := Grid.Name;
  ListBox.Clear;
  for n := 0 to Grid.Columns.Count-1 do
     ListBox.Items.Add(Grid.Columns[n].Title.Caption);
  Adicionado := True;
  if (Atual > -1) then  ListBox.ItemIndex := Atual;
end;

procedure TfrmDBGridEditor.SalvarDados;
var
  nTemp : Integer;
begin
 nTemp := ListBox.ItemIndex;

 if (edtName.Text <> '') then
   Grid.Name  := iif((edtName.Text <> Grid.Name), frmFormEditor.RetornaNomeComponente(edtName.Text), Grid.Name);

 if (nTemp = -1) then exit;
 Grid.Columns[nTemp].Title.Caption  := EditCaption.Text;
 Grid.Columns[nTemp].Visible        := chkVisible.Checked;
 Grid.Columns[nTemp].Field.EditMask := sEditMask.Text;

 with (Grid.DataSource.DataSet as TkbmMemTable) do begin
   if chkAutoInc.Checked then
     FieldDefs[nTemp].DataType := ftAutoInc
   else
     FieldDefs[nTemp].DataType := ftString;
   Active := True;
 end;

end;

procedure TfrmDBGridEditor.CarregaDados;
var
  nTemp : Integer;
begin
 nTemp := ListBox.ItemIndex;
 if (nTemp = -1) then exit;
 EditCaption.Text    := Grid.Columns[nTemp].Title.Caption;
 chkVisible.Checked  := Grid.Columns[nTemp].Visible;
 sEditMask.Text      := Grid.Columns[nTemp].Field.EditMask;
 chkAutoInc.Checked  := ( (Grid.DataSource.DataSet as TkbmMemTable).FieldDefs[nTemp].DataType = ftAutoInc );
end;

procedure TfrmDBGridEditor.ListBoxClick(Sender: TObject);
begin
  CarregaDados;
end;


procedure TfrmDBGridEditor.btnUpClick(Sender: TObject);
var
  nTemp : Integer;
begin
 nTemp := ListBox.ItemIndex;
 if (nTemp <= 0) then exit;
 Grid.Columns[nTemp].Index  := Grid.Columns[nTemp].Index-1;
 Prepara(nTemp-1);
end;

procedure TfrmDBGridEditor.btnDownClick(Sender: TObject);
var
  nTemp : Integer;
begin
 nTemp := ListBox.ItemIndex;
 if (nTemp = Grid.Columns.Count-1) then exit;
 Grid.Columns[nTemp].Index  := Grid.Columns[nTemp].Index+1;
 Prepara(nTemp+1);
end;

procedure TfrmDBGridEditor.btnOKClick(Sender: TObject);
begin
 SalvarDados;
 Close;
end;

procedure TfrmDBGridEditor.EditCaptionExit(Sender: TObject);
begin
 SalvarDados;
end;

procedure TfrmDBGridEditor.btnAlteraClick(Sender: TObject);
var
  sCampos, sTemp  : String;
  n
       : Integer;
  InkbmMemTable : TkbmMemTable;
begin
  sCampos := '';
  if (cmbTabela.ItemIndex = -1) then exit;

  for n := 0 to ListaArray[cmbTabela.ITemIndex].Count -1 do
     sCampos := sCampos+', '+ListaArray[cmbTabela.ITemIndex].Strings[n];

  if ( length(sCampos) > 0 ) then
     sCampos[1] := ' '
  else
     exit;

  sTemp := 'select '+sCampos+' from '+cmbTabela.Items[cmbTabela.ITemIndex]+' where ';
  with QueryAux do begin
    SQL.Text := sTemp +' 0 = 1';
    Open;
  end;

  InkbmMemTable := (Grid.DataSource.DataSet as TkbmMemTable);
  InkbmMemTable.LoadFromDataSet(QueryAux,[mtcpoStructure]);
  Grid.SQLDataSet.CommandText    := sTemp;
  InkbmMemTable.Active := True;

  Grid.TableName := cmbTabela.Items[cmbTabela.ITemIndex];
  Prepara(0);
end;

procedure TfrmDBGridEditor.BitBtn1Click(Sender: TObject);
var
  InkbmMemTable : TkbmMemTable;
  sTemp : string;
begin
   if not InputQuery(NomeCampo, Campo, sTemp) then exit;

   if (sTemp = '') then begin
      ShowMessage(NomeCampoBranco);
      exit;
   end;

  InkbmMemTable := (Grid.DataSource.DataSet as TkbmMemTable);
  InkbmMemTable.FieldDefs.Add(sTemp, ftString);
end;

end.
