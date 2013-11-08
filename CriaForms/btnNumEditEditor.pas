unit btnNumEditEditor;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, mzMemoCLX, QMask, mzCustomEdit, mzNumEditclx,
  QButtons, mzComboBoxClx, QExtCtrls, TypInfo, mzCustomBtnEditclx,
  mzBtnQueryEditclx, mzlib;

type
  TfrmBtnQueryEditProperties = class(TForm)
    PanelTable: TPanel;
    cmbTable: TmzComboBoxClx;
    Panel3: TPanel;
    cmbField: TmzComboBoxClx;
    Panel1: TPanel;
    btnOk: TBitBtn;
    Panel7: TPanel;
    Panel6: TPanel;
    edtCaption: TNumEditclx;
    mzMemoQuerys: TmzMemo;
    Panel4: TPanel;
    edtname: TNumEditclx;
    Panel2: TPanel;
    chkShowCaption: TCheckBox;
    ListBoxComps: TListBox;
    Panel5: TPanel;
    cmbComps: TComboBox;
    cmbProps: TComboBox;
    Button1: TButton;
    Button2: TButton;
    chkReadOnly: TCheckBox;
    chkNullData: TCheckBox;
    Panel8: TPanel;
    edtMask: TNumEditclx;
    procedure cmbCompsChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure edtnameExit(Sender: TObject);
    procedure cmbTableChange(Sender: TObject);
  private
    { Private declarations }
    procedure SetaQueryEdit;
  public
    { Public declarations }
    InmzBtnQueryEditclx: TmzBtnQueryEditclx;
    ListaArray : TListArray;
    procedure Prepara;
    procedure AtualizaLista;
  end;

var
  frmBtnQueryEditProperties: TfrmBtnQueryEditProperties;

implementation

uses FormEditor;

{$R *.xfm}

procedure TfrmBtnQueryEditProperties.AtualizaLista;
begin
  if (cmbTable.Itemindex = -1) then cmbTable.ItemIndex := 0;
  cmbField.Items     := ListaArray[cmbTable.ItemIndex];
  cmbField.ItemIndex := 0;
end;


procedure TfrmBtnQueryEditProperties.SetaQueryEdit;
begin
   with InmzBtnQueryEditclx do begin
     TextLabel.Caption := edtCaption.Text;
     EditMask          := edtMask.Text;
     ReadOnly          := chkReadOnly.Checked;
     NullData          := chkNullData.Checked;
     TextLabel.Visible := chkShowCaption.Checked;

     if (edtName.Text <> '') then
       Name              := iif((edtName.Text <> Name), frmFormEditor.RetornaNomeComponente(edtName.Text), Name);

     if ((cmbTable.Items.Count > 0) and (cmbField.Items.Count > 0)) then
        if (cmbTable.ItemIndex > -1) and (cmbField.ItemIndex > -1) then
          Fieldname := cmbTable.Items.Strings[cmbTable.ItemIndex]+'.'+cmbField.Items.Strings[cmbField.ItemIndex];
     QueryList.Text     := mzMemoQuerys.Text;
     ComponentList.Text := ListBoxComps.Items.Text;
   end;
end;


procedure TfrmBtnQueryEditProperties.Prepara;
var
 sCampoTabela : String;
 n : Integer;
begin
  with InmzBtnQueryEditclx do begin
    chkReadOnly.Checked      := ReadOnly;
    chkNullData.Checked      := NullData;
    chkShowCaption.Checked   := TextLabel.Visible;
    edtName.Text             := Name;
    edtCaption.Text          := TextLabel.Caption;
    edtMask.Text             := EditMask;
    sCampoTabela             := FieldName;
    mzMemoQuerys.Text        := QueryList.Text;
    ListBoxComps.Items.Text  := ComponentList.Text;
    cmbComps.Clear;
    for n := 0 to InmzBtnQueryEditclx.Owner.ComponentCount-1 do
       if (InmzBtnQueryEditclx.Owner.Components[n] is TControl) then
          if (  (InmzBtnQueryEditclx.Owner.Components[n] as TControl).Parent = InmzBtnQueryEditclx.Parent  ) then
            cmbComps.items.Add(InmzBtnQueryEditclx.Owner.Components[n].name);
  end;

  ObtemTabelaCampo(sCampoTabela, ListaArray,cmbField, cmbTable);
end;

procedure TfrmBtnQueryEditProperties.cmbCompsChange(Sender: TObject);
var
  TempList: PPropList;
  PropInfo: PPropInfo;
  InComponent: TObject;
  n, Contagem : Integer;
begin
   if (cmbComps.ItemIndex = -1) then exit;
  cmbProps.Clear;
  InComponent := InmzBtnQueryEditclx.Owner.FindComponent(cmbComps.Text);
  Contagem := GetPropList(InComponent, TempList);
  for n := 0 to Contagem - 1 do begin
     PropInfo := TempList^[n];
     if (PropInfo <> nil) and (PropInfo^.PropType^.Kind in [tkString, tkLString, tkWString]) then
     cmbProps.Items.Add(PropInfo^.Name);
  end;

end;

procedure TfrmBtnQueryEditProperties.Button1Click(Sender: TObject);
begin
   if (cmbComps.Itemindex = -1) or (cmbProps.Itemindex = -1) then exit;
   ListBoxComps.Items.Add(cmbComps.Text+'.'+cmbProps.Text);
end;

procedure TfrmBtnQueryEditProperties.Button2Click(Sender: TObject);
begin
  if (ListBoxComps.ItemIndex > -1) then ListBoxComps.Items.Delete(ListBoxComps.itemindex);
end;

procedure TfrmBtnQueryEditProperties.btnOkClick(Sender: TObject);
begin
  SetaQueryEdit;
  Close;
end;

procedure TfrmBtnQueryEditProperties.edtnameExit(Sender: TObject);
begin
  SetaQueryEdit;
  Prepara;
end;

procedure TfrmBtnQueryEditProperties.cmbTableChange(Sender: TObject);
begin
 AtualizaLista;
end;

end.
