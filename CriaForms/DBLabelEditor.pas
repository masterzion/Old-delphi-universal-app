unit DBLabelEditor;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, mzMemoCLX, QMask, mzCustomEdit, mzNumEditclx,
  QButtons, QExtCtrls, mzlib, mzDBLabel, mzComboBoxClx;

type
  TfrmLabelEditor = class(TForm)
    Panel1: TPanel;
    btnOk: TBitBtn;
    Panel7: TPanel;
    mzMemoQuerys: TmzMemo;
    Panel4: TPanel;
    edtname: TNumEditclx;
    Panel5: TPanel;
    cmbComps: TmzComboBoxClx;
    procedure btnOkClick(Sender: TObject);
    procedure edtnameExit(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    mzdbLabel : TmzdbLabel;
    procedure Prepara;
    procedure SetaLabel;
  end;

var
  frmLabelEditor: TfrmLabelEditor;

implementation
uses FormEditor;

{$R *.xfm}


procedure TfrmLabelEditor.Prepara;
var
 n : Integer;
begin
  with mzdbLabel do begin
    edtName.Text             := Name;
    mzMemoQuerys.Text        := Query.Text;
    cmbComps.Clear;
    cmbComps.Items.Add(NONE_TEXT);
    for n := 0 to mzdbLabel.Owner.ComponentCount-1 do
       if (mzdbLabel.Owner.Components[n] is TControl) then
          if (  (mzdbLabel.Owner.Components[n] as TControl).Parent = mzdbLabel.Parent  ) then
            cmbComps.items.Add(mzdbLabel.Owner.Components[n].name);
    cmbComps.ItemIndex := cmbComps.Items.IndexOf(MasterComponent);
  end;

end;

procedure TfrmLabelEditor.SetaLabel;
begin
   with mzdbLabel do begin
     if (edtName.Text <> '') then
       Name              := iif((edtName.Text <> Name), frmFormEditor.RetornaNomeComponente(edtName.Text), Name);
     Query.Text         := mzMemoQuerys.Text;
     MasterComponent    := cmbComps.Text;
   end;
end;


procedure TfrmLabelEditor.btnOkClick(Sender: TObject);
begin
  SetaLabel;
  Close;
end;

procedure TfrmLabelEditor.edtnameExit(Sender: TObject);
begin
 SetaLabel;
end;

end.
