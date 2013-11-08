unit frmQueryBtnQueryEdit;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, QButtons, QExtCtrls, FMTBcd, DB, SqlExpr, DBXpress,
  QGrids, QDBGrids, Provider, DBClient, mzCompLib;

type
  TmzFormQueryEdit = class(TForm)
    Panel1: TPanel;
    cmbTipoBusca: TComboBox;
    edtBusca: TEdit;
    btnFind: TSpeedButton;
    btnClose: TSpeedButton;
    Query: TSQLQuery;
    DBGrid: TDBGrid;
    DataSource1: TDataSource;
    ClientDataSet1: TClientDataSet;
    DataSetProvider1: TDataSetProvider;
    procedure btnCloseClick(Sender: TObject);
    procedure btnFindClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DBGridDblClick(Sender: TObject);
    procedure DBGridKeyPress(Sender: TObject; var Key: Char);
    procedure edtBuscaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    procedure RetornaDados;
  public
    { Public declarations }
    RetDados  : TArStr;
    QueryList : TStringList;
    sParamName : string;
  end;

var
  mzFormQueryEdit: TmzFormQueryEdit;

implementation

{$R *.xfm}


procedure TmzFormQueryEdit.btnCloseClick(Sender: TObject);
begin
 Close;
end;

procedure TmzFormQueryEdit.btnFindClick(Sender: TObject);
var
  sTemp : string;
begin
  sTemp := QueryList.Strings[cmbTipoBusca.itemindex];
  Query.SQL.Text := copy(sTemp, pos(':',sTemp)+1, Length(sTemp) );
  Query.Params.Clear;

  Query.Params.Add;
  Query.Params[0].Name     := sParamName;
  Query.Params[0].AsString := EdtBusca.Text;

  ClientDataSet1.Active := False;
  ClientDataSet1.Active := True;
  DBGrid.SetFocus;
end;

procedure TmzFormQueryEdit.FormCreate(Sender: TObject);
begin
    QueryList := TStringList.Create;
end;

procedure TmzFormQueryEdit.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  QueryList.Destroy
end;

procedure TmzFormQueryEdit.RetornaDados;
var
  nTamanho, N:Integer;
begin
  SetLength(RetDados, 0);
  nTamanho := ClientDataSet1.Fields.Count;
  if (nTamanho = 0) then exit;
  SetLength(RetDados, nTamanho);
  for n := 0 to nTamanho-1 do RetDados[n] := ClientDataSet1.Fields[n].AsString;
  Close;
end;

procedure TmzFormQueryEdit.DBGridDblClick(Sender: TObject);
begin
  RetornaDados;
end;

procedure TmzFormQueryEdit.DBGridKeyPress(Sender: TObject; var Key: Char);
begin
  if (key = #13) then RetornaDados;
end;

procedure TmzFormQueryEdit.edtBuscaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = RETUNR_KEY) or (Key = RETUNR_KEY2) then btnFind.Click;

end;

end.
