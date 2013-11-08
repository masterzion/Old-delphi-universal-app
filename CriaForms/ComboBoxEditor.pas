unit ComboBoxEditor;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, QButtons, QMask, mzComboBoxClx,
  QExtCtrls, mzMemoCLX, mzDBComboBoxClx, mzlib, DB, mzCustomEdit,
  mzNumEditclx;

type
  TfrmComboBoxEditor = class(TForm)
    CampoTabela: TPanel;
    PanelTable: TPanel;
    cmbTable: TmzComboBoxClx;
    Panel3: TPanel;
    cmbField: TmzComboBoxClx;
    Panel7: TPanel;
    Panel5: TPanel;
    edtName: TNumEditclx;
    Panel2: TPanel;
    edtCaption: TNumEditclx;
    Panel6: TPanel;
    chkShowCaption: TCheckBox;
    Panel1: TPanel;
    btnOk: TBitBtn;
    mzMemoQuery: TmzMemo;
    Panel4: TPanel;
    btnCheck: TBitBtn;
    procedure btnCheckClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure cmbTableChange(Sender: TObject);
    procedure edtNameExit(Sender: TObject);
  private
    { Private declarations }
    procedure SetaCombo;
  public
    { Public declarations }
    DbComboBox : TmzDBComboBoxClx;
    ListaArray : TListArray;
    procedure Prepara;
    procedure AtualizaLista;
  end;

var
  frmComboBoxEditor: TfrmComboBoxEditor;

implementation

uses FormEditor;

{$R *.xfm}

procedure TfrmComboBoxEditor.AtualizaLista;
begin
  if (cmbTable.Itemindex = -1) then cmbTable.ItemIndex := 0;
  cmbField.Items     := ListaArray[cmbTable.ItemIndex];
  cmbField.ItemIndex := 0;
end;


procedure TfrmComboBoxEditor.SetaCombo;
begin
   with DbComboBox do begin
     TextLabel.Caption := edtCaption.Text;
     TextLabel.Visible := chkShowCaption.Checked;
     SQLQuery          := mzMemoQuery.Lines;

     if (edtName.Text <> '') then
       Name              := iif((edtName.Text <> Name), frmFormEditor.RetornaNomeComponente(edtName.Text), Name);
     
     if ((cmbTable.Items.Count > 0) and (cmbField.Items.Count > 0)) then
        if (cmbTable.ItemIndex > -1) and (cmbField.ItemIndex > -1) then
          Fieldname := cmbTable.Items.Strings[cmbTable.ItemIndex]+'.'+cmbField.Items.Strings[cmbField.ItemIndex];
   end;
end;


procedure TfrmComboBoxEditor.Prepara;
var
 sCampoTabela : String;
begin

  with DbComboBox do begin
    mzMemoQuery.Lines       := SQLQuery;
    chkShowCaption.Checked  := TextLabel.Visible;
    edtName.Text            := Name;
    edtCaption.Text         := TextLabel.Caption;
    sCampoTabela            := FieldName;
  end;

  ObtemTabelaCampo(sCampoTabela, ListaArray,cmbField, cmbTable);
end;

procedure TfrmComboBoxEditor.btnCheckClick(Sender: TObject);
begin
  with DbComboBox do begin
     SetaCombo;
     try
        Active   := True;
        ShowMessage(msgOK);        
     except
        on E : EDatabaseError do begin
          ShowMessage(E.Message);
        end;
     end;
  end;
end;

procedure TfrmComboBoxEditor.btnOkClick(Sender: TObject);
begin
  SetaCombo;
  Prepara;
  Close;
end;

procedure TfrmComboBoxEditor.cmbTableChange(Sender: TObject);
begin
  AtualizaLista;
end;

procedure TfrmComboBoxEditor.edtNameExit(Sender: TObject);
begin
  SetaCombo;
end;

end.
