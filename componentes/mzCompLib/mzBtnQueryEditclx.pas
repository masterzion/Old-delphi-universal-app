unit mzBtnQueryEditclx;

interface

uses
  SysUtils, Classes, QControls, QStdCtrls, QMask, mzCustomEdit,
  mzCustomBtnEditclx, frmQueryBtnQueryEdit, SqlExpr, QDialogs, mzCompLib, TypInfo;

type
  TarStr = array of string;
  TmzBtnQueryEditclx = class(TmzCustomBtnEditclx)
  private
    { Private declarations }
    InComponentList, InStrings : TStringList;
    InSQLConnection  : TSQLConnection;
    sFormCaption, sBtnFindCaption, sBtnCloseCaption, sParamName : string;
    procedure SetItems(const Value: TStringList);
    procedure SetComponentList(const Value: TStringList);
  protected
    { Protected declarations }
    procedure ExecuteClick; override;
  public
    { Public declarations }
    ReturnedData  : TArStr;
    constructor Create(AOwner : TComponent); override;
    procedure SetSQLConnection(Connection : TSQLConnection);
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  published
   property QueryList       : TStringList   read InStrings         write SetItems;
   property ComponentList   : TStringList   read InComponentList   write SetComponentList;
   property ParamName       : string        read sParamName        write sParamName;
   property FormCaption     : string        read sFormCaption      write sFormCaption;
   property BtnFindCaption  : string        read sBtnFindCaption   write sBtnFindCaption;
   property BtnCloseCaption : string        read sBtnCloseCaption  write sBtnCloseCaption;
   property SQLConnection  : TSQLConnection read InSQLConnection   write SetSQLConnection;
    { Published declarations }
  end;

procedure Register;

{$R mzbtnqueryeditclx.res}

implementation


procedure TmzBtnQueryEditclx.SetSqlConnection(Connection : TSQLConnection);
begin
  Connection.FreeNotification(self);
  InSQLConnection := Connection;
end;


procedure TmzBtnQueryEditclx.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = InSQLConnection) then InSQLConnection := nil;
end;


procedure TmzBtnQueryEditclx.SetComponentList(const Value: TStringList);
begin
  InComponentList.Assign(Value);
end;


procedure TmzBtnQueryEditclx.SetItems(const Value: TStringList);
begin
  InStrings.Assign(Value);
end;

constructor TmzBtnQueryEditclx.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  InStrings       := TStringList.Create;
  InComponentList := TStringList.Create;
  btnEdit.Glyph.LoadFromResourceName(HInstance,'BTNQUERYPROCURA');
  sFormCaption       := 'Localizar...';
  sBtnFindCaption    := 'Procurar';
  sBtnCloseCaption   := 'Fechar';
  sParamName         := ':Campo_Busca';
  InStrings.Add('Search1:select * from table where field1 = '+sParamName);
  InStrings.Add('Search2:select * from table where field2 like '+sParamName);
end;


procedure TmzBtnQueryEditclx.ExecuteClick;
  procedure SetaComponentes;
  var
   n : Integer;
   sTemp, sCompName, sCompValue : string;
   Componente : TComponent;
  begin
   if (Length(ReturnedData) = 0) then exit;
   for n := 0 to InComponentList.Count-1 do begin
      sTemp := InComponentList.Strings[n];
      sCompName := copy(sTemp, 0, pos('.', sTemp)-1);
      sCompValue := copy(sTemp, pos('.', sTemp)+1, Length(sTemp) );
      if (sCompName <> '') then begin
        Componente := Owner.FindComponent(sCompName);
        if (Componente <> nil) then SetPropValue(Componente, sCompValue, ReturnedData[n]);
      end;
   end;
  end;

var
  mzFormQueryEdit : TmzFormQueryEdit;
  n : Integer;
  sTemp : string;
begin

  //Verifica SQlConnection
  if (InSQLConnection = nil) then begin
    ShowMessage('SQLConnection is empty');
    exit;
  end;

  //Cria e prepara
  mzFormQueryEdit := TmzFormQueryEdit.Create(Self);
  mzFormQueryEdit.Caption := sFormCaption;
  mzFormQueryEdit.btnFind.Caption       := sBtnFindCaption;
  mzFormQueryEdit.btnClose.Caption      := sBtnCloseCaption;
  mzFormQueryEdit.sParamName            := sParamName;
  mzFormQueryEdit.QueryList.Text        := InStrings.Text;
  mzFormQueryEdit.Query.SQLConnection   := InSQLConnection;

  for n := 0 to InStrings.Count-1 do begin
    sTemp := InStrings.Strings[n];
    mzFormQueryEdit.cmbTipoBusca.Items.Add(copy(sTemp, 1, pos(':',sTemp)-1 ));
  end;

  mzFormQueryEdit.cmbTipoBusca.ItemIndex := 0;

  mzFormQueryEdit.Query.SQLConnection := InSQLConnection;
  mzFormQueryEdit.ShowModal;

  //RetornaDados
  Setlength(ReturnedData, Length(mzFormQueryEdit.RetDados) );
  for n := 0 to Length(mzFormQueryEdit.RetDados)-1 do ReturnedData[n] := mzFormQueryEdit.RetDados[n];

  mzFormQueryEdit.Free;
  if (InComponentList.Count > 0 ) then SetaComponentes;
end;


procedure Register;
begin
  RegisterComponents('Master', [TmzBtnQueryEditclx]);
end;

end.
