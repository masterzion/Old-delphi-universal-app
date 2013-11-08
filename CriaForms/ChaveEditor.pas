unit ChaveEditor;

interface

{$include configura.inc}

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, QButtons, QExtCtrls, mzComboBoxClx, QMask,
  mzlib, Principal, FMTBcd, DB, SqlExpr, mzCustomEdit, mzNumEditclx;

type
  TfrmChaveEditor = class(TForm)
    Panel1: TPanel;
    ComboTabelaChave: TmzComboBoxClx;
    Panel2: TPanel;
    MemoChave: TMemo;
    Panel3: TPanel;
    Splitter1: TSplitter;
    Panel4: TPanel;
    btnCheckQuery: TBitBtn;
    Label1: TLabel;
    Panel5: TPanel;
    Panel6: TPanel;
    Label2: TLabel;
    ListBoxCamposChaves: TListBox;
    btnAdicionaCampo: TBitBtn;
    btnRemoveCampo: TBitBtn;
    btnOk: TBitBtn;
    Panel7: TPanel;
    EditNomeModulo: TNumEditclx;
    QueryChave: TSQLQuery;
    Query: TSQLQuery;
    btnCancelar: TBitBtn;
    ComboCampoChave: TComboBox;
    PanelFiltro: TPanel;
    chkFiltro: TCheckBox;
    procedure ComboTabelaChaveChange(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnCheckQueryClick(Sender: TObject);
    procedure btnAdicionaCampoClick(Sender: TObject);
    procedure btnRemoveCampoClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }

    InListArray  : TListArray;
  public
      QueryObject  : TmzQueryObject;
      procedure SetVars(ListaTabelas:TStringList; ListArray : TListArray);
    { Public declarations }
  end;

var
  frmChaveEditor: TfrmChaveEditor;

implementation

{$R *.xfm}

procedure TfrmChaveEditor.SetVars(ListaTabelas:TStringList; ListArray : TListArray);
begin
  ComboTabelaChave.Items     := ListaTabelas;
  InListArray                := ListArray;
  ComboTabelaChave.ItemIndex := 0;

  ComboCampoChave.Items      := InListArray[0];
  ComboCampoChave.ItemIndex  := 0;
  MemoChave.Lines.Text := 'select max('+ComboCampoChave.Items[0]+')+1 from '+ComboTabelaChave.Items[0];

  {$IFDEF personal}
      PanelFiltro.Destroy;
  {$ENDIF}

  btnAdicionaCampo.Click;
  EditNomeModulo.Text := ComboTabelaChave.Text;
end;

procedure TfrmChaveEditor.ComboTabelaChaveChange(Sender: TObject);
begin
     ComboCampoChave.Items     := InListArray[ComboTabelaChave.ItemIndex];
     ListBoxCamposChaves.Clear;
     ComboCampoChave.ItemIndex := 0;
     MemoChave.Lines.Text := 'select max('+ComboCampoChave.Items[ComboCampoChave.ItemIndex]+')+1 from '+ComboTabelaChave.Items[ComboTabelaChave.ItemIndex];
end;


procedure TfrmChaveEditor.btnCheckQueryClick(Sender: TObject);
var
 sTemp : string;
begin
  with QueryChave do begin
     SQL := MemoChave.Lines;
     try
        Open;
        First;
        sTemp := Fields[0].AsString;
        if (sTemp = '')  then sTemp := '0';
        ShowMessage(sTemp);
     except
        on E : EDatabaseError do begin
          ShowMessage(E.Message);
        end;
     end;
  end;

end;

procedure TfrmChaveEditor.btnAdicionaCampoClick(Sender: TObject);
var
  sTemp : String;
begin
  if (ComboCampoChave.Items.Count = 0) then exit;
  if (ComboTabelaChave.Items.Count = 0) then exit;
  sTemp := ComboTabelaChave.Text+'.'+ComboCampoChave.Items[ComboCampoChave.ItemIndex];
  ComboCampoChave.Items.Delete(ComboCampoChave.ItemIndex);
  ListBoxCamposChaves.Items.Add(sTemp);
  btnRemoveCampo.Enabled := True;
  ComboCampoChave.ItemIndex := 0;  
end;



procedure TfrmChaveEditor.btnRemoveCampoClick(Sender: TObject);
var
  sTemp : String;
begin

  if (ListBoxCamposChaves.Items.Count = -1) then exit;
  if (ListBoxCamposChaves.ItemIndex = -1) then exit;

  sTemp := ListBoxCamposChaves.Items[ListBoxCamposChaves.ItemIndex];
  ListBoxCamposChaves.Items.Delete(ListBoxCamposChaves.ItemIndex);
  sTemp := copy(sTemp, pos('.', sTemp)+1, Length(sTemp) );
  ComboCampoChave.Items.Add(sTemp);
  btnRemoveCampo.Enabled := (ListBoxCamposChaves.Items.Count > 0)
end;

procedure TfrmChaveEditor.btnOkClick(Sender: TObject);
begin

  if (ListBoxCamposChaves.Items.Count = 0) then begin
     ShowMessage(ErroSemCampos);
     exit;
  end;

  if (EditNomeModulo.Text = '') then begin
     ShowMessage(ErroSemNome);
     exit;
  end;

  if (MemoChave.Lines.Text = '') then begin
     ShowMessage(ErroSemConsulta);
     exit;
  end;
 QueryObject.ConsultaChave          := MemoChave.Lines.Text;
 QueryObject.NomeModulo             := EditNomeModulo.Text;
 QueryObject.CamposChaves.CommaText := ListBoxCamposChaves.Items.CommaText;
 {$IFDEF corporate}
 QueryObject.FiltraEmpresa      := chkFiltro.Checked;
 {$ENDIF}
 frmPrincipal.ShowFormEditor(QueryObject);
 Close;
end;


procedure TfrmChaveEditor.btnCancelarClick(Sender: TObject);
begin
 Close;
end;

procedure TfrmChaveEditor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 AcTion := caFree;
end;

end.
