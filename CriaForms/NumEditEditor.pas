unit NumEditEditor;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, QExtCtrls, QButtons, mzComboBoxClx, QMask,
  mzlib, mzCustomEdit, mzNumEditclx, mzDBCheckBox, mzMemoCLX;

type
  TfrmNumEditEditor = class(TForm)
    Panel1: TPanel;
    Panel6: TPanel;
    chkShowCaption: TCheckBox;
    chkNullData: TCheckBox;
    chkReadOnly: TCheckBox;
    Panel7: TPanel;
    PanelMask: TPanel;
    edtMask: TNumEditclx;
    Panel5: TPanel;
    edtName: TNumEditclx;
    CampoTabela: TPanel;
    PanelTable: TPanel;
    cmbTable: TmzComboBoxClx;
    Panel3: TPanel;
    cmbField: TmzComboBoxClx;
    BitBtn1: TBitBtn;
    Panel2: TPanel;
    edtCaption: TNumEditclx;
    procedure cmbTableChange(Sender: TObject);
    procedure edtMaskExit(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure SetaEdit;
  public
    { Public declarations }
    CustomEdit, CheckBox, Memo : Boolean;

    EditCLX    : TmzCustomEditclx;
    mzCheckBox : TmzDbCheckBox;
    mzMemo     : TmzMemo;
    ListaArray : TListArray;
    procedure Prepara;
    procedure AtualizaLista;
  end;

var
  frmNumEditEditor: TmzCustomEditclx;

implementation

uses FormEditor;

{$R *.xfm}

procedure TfrmNumEditEditor.AtualizaLista;
begin
  chkShowCaption.Visible := CustomEdit or Memo;
  PanelMask.Visible      := CustomEdit;
  chkNullData.Visible    := CustomEdit;

  if (cmbTable.Itemindex = -1) then cmbTable.ItemIndex := 0;
  cmbField.Items     := ListaArray[cmbTable.ItemIndex];
  cmbField.ItemIndex := 0;
end;

procedure TfrmNumEditEditor.Prepara;
var
 sCampoTabela : String;
begin

  if CustomEdit then
    with EditCLX do begin
      chkReadOnly.Checked    := ReadOnly;
      chkNullData.Checked    := NullData;
      chkShowCaption.Checked := TextLabel.Visible;
      edtName.Text           := Name;
      edtCaption.Text        := TextLabel.Caption;
      edtMask.Text           := EditMask;
      sCampoTabela           := FieldName;
    end;

  if CheckBox then
    with mzCheckBox do begin
      chkReadOnly.Checked    := ReadOnly;
      edtName.Text           := Name;
      edtCaption.Text        := Caption;
      sCampoTabela           := FieldName;
    end;


  if Memo then
    with mzMemo do begin
      chkReadOnly.Checked    := ReadOnly;
      chkShowCaption.Checked := TextLabel.Visible;
      edtName.Text           := Name;
      edtCaption.Text        := TextLabel.Caption;
      sCampoTabela           := FieldName;
    end;


  ObtemTabelaCampo(sCampoTabela, ListaArray,cmbField, cmbTable);
end;


procedure TfrmNumEditEditor.SetaEdit;
var
 sTemp : string;
begin
 if CustomEdit then
   with EditCLX do begin
     TextLabel.Caption := edtCaption.Text;
     sTemp := edtMask.Text;
     if (sTemp <> '') then clear;
     EditMask          := sTemp;
     ReadOnly          := chkReadOnly.Checked;
     NullData          := chkNullData.Checked;
     TextLabel.Visible := chkShowCaption.Checked;

     if (edtName.Text <> '') then
       Name              := iif((edtName.Text <> Name), frmFormEditor.RetornaNomeComponente(edtName.Text), Name);

     if ((cmbTable.Items.Count > 0) and (cmbField.Items.Count > 0)) then
        if (cmbTable.ItemIndex > -1) and (cmbField.ItemIndex > -1) then
          Fieldname := cmbTable.Items.Strings[cmbTable.ItemIndex]+'.'+cmbField.Items.Strings[cmbField.ItemIndex];
   end;

 if CheckBox then
   with mzCheckBox do begin
     Caption  := edtCaption.Text;
     ReadOnly := chkReadOnly.Checked;

     if (edtName.Text <> '') then
       Name              := iif((edtName.Text <> Name), frmFormEditor.RetornaNomeComponente(edtName.Text), Name);

     if ((cmbTable.Items.Count > 0) and (cmbField.Items.Count > 0)) then
        if (cmbTable.ItemIndex > -1) and (cmbField.ItemIndex > -1) then
          Fieldname := cmbTable.Items.Strings[cmbTable.ItemIndex]+'.'+cmbField.Items.Strings[cmbField.ItemIndex];
   end;

 if Memo then
   with mzMemo do begin
     TextLabel.Caption := edtCaption.Text;
     sTemp := edtMask.Text;
     if (sTemp <> '') then clear;
     ReadOnly          := chkReadOnly.Checked;
     TextLabel.Visible := chkShowCaption.Checked;

     if (edtName.Text <> '') then
       Name              := iif((edtName.Text <> Name), frmFormEditor.RetornaNomeComponente(edtName.Text), Name);

     if ((cmbTable.Items.Count > 0) and (cmbField.Items.Count > 0)) then
        if (cmbTable.ItemIndex > -1) and (cmbField.ItemIndex > -1) then
          Fieldname := cmbTable.Items.Strings[cmbTable.ItemIndex]+'.'+cmbField.Items.Strings[cmbField.ItemIndex];
   end;

end;

procedure TfrmNumEditEditor.cmbTableChange(Sender: TObject);
begin
  AtualizaLista;
end;

procedure TfrmNumEditEditor.edtMaskExit(Sender: TObject);
begin
  SetaEdit;
  Prepara;
end;

procedure TfrmNumEditEditor.BitBtn1Click(Sender: TObject);
begin
  SetaEdit;
  Close;
end;

procedure TfrmNumEditEditor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 Action := caFree;
end;

end.
