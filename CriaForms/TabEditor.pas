unit TabEditor;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, QExtCtrls, QButtons;

type
  TfrmTabEditor = class(TForm)
    Panel1: TPanel;
    ListBox: TListBox;
    SpeedUP: TSpeedButton;
    SpeedDown: TSpeedButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpeedUPClick(Sender: TObject);
    procedure SpeedDownClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTabEditor: TfrmTabEditor;

implementation
uses FormEditor;
{$R *.xfm}

procedure TfrmTabEditor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 frmFormEditor.ApplicaTabOrder(ListBox.Items);
 Action := caFree;
end;

procedure TfrmTabEditor.SpeedUPClick(Sender: TObject);
var
  sTemp : string;
begin
  if ListBox.ItemIndex = 0 then exit;
  sTemp := ListBox.Items[ListBox.ItemIndex-1];
  ListBox.Items[ListBox.ItemIndex-1] := ListBox.Items[ListBox.ItemIndex];
  ListBox.Items[ListBox.ItemIndex] := sTemp;
  ListBox.ItemIndex := ListBox.ItemIndex-1;
end;

procedure TfrmTabEditor.SpeedDownClick(Sender: TObject);
var
  sTemp : string;
begin
  if ListBox.ItemIndex = ListBox.Items.Count-1 then exit;
  sTemp := ListBox.Items[ListBox.ItemIndex+1];
  ListBox.Items[ListBox.ItemIndex+1] := ListBox.Items[ListBox.ItemIndex];
  ListBox.Items[ListBox.ItemIndex] := sTemp;
  ListBox.ItemIndex := ListBox.ItemIndex+1;
end;

end.
