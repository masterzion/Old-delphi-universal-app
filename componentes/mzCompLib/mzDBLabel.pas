unit mzDBLabel;

interface

uses
  SysUtils, Classes, QControls, QStdCtrls, QMask, mzComboBoxClx,
  SqlExpr, QDialogs, mzCompLib, TypInfo, QGraphics;


type
  TmzDBLabel = class(TLabel)
  private
    { Private declarations }
    FMasterComponent     : TComponent;
    InQuery              : TSQLQuery;
    FEvent, InEvent      : TNotifyEvent;
    Lista                : TStringList;
    sParam, sCompName    : string;

    procedure ExecutaConsulta;
  protected
    { Protected declarations }
     function  GetSqlConnection:TSQLConnection;
     procedure SetSqlConnection(Connection : TSQLConnection);

     procedure ProcPadrao(Sender: TObject);
     procedure SetLista(const Value: TStringList);

     procedure SetQuery (Query : TStringList);
  public
    { Public declarations }
     constructor Create(AOwner : TComponent); override;

     procedure SetMasterComponent;
     procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  published
    { Published declarations }
   property ParamName        : string          read sParam                write sParam;
   property SQLConnection    : TSQLConnection  read GetSQLConnection      write SetSqlConnection;
   property MasterComponent  : string          read sCompName             write sCompName;
   property Query            : TStringList     read Lista                 write SetLista;
   property _ProcPadrao      : TNotifyEvent    read InEvent;
  end;

procedure Register;

implementation
uses mzCustomEdit;


constructor TmzDBLabel.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  InQuery := TSQLQuery.Create(Self);
  Lista   := TStringList.Create;
  InEvent := Procpadrao;

  with Font do begin
     Color := clNavy;
     Name  := 'Helvetica';
     Style := [fsBold];
  end;
  Caption := '';

end;


procedure TmzDBLabel.SetLista(const Value: TStringList);
begin
  Lista.Assign(Value);
end;


procedure TmzDBLabel.SetQuery (Query : TStringList);
begin
  Lista.Assign(Query);
end;

function  TmzDBLabel.GetSqlConnection:TSQLConnection;
begin
  Result := InQuery.SQLConnection;
end;


procedure TmzDBLabel.SetSqlConnection(Connection : TSQLConnection);
begin
  Connection.FreeNotification(self);
  InQuery.SQLConnection := Connection;
end;


procedure TmzDBLabel.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = InQuery.SQLConnection) then InQuery.SQLConnection := nil;
end;


procedure TmzDBLabel.SetMasterComponent;
var
  Component : TComponent;
begin
  if (sCompName <> '') then
    Component := Owner.FindComponent(sCompName)
  else
    exit;

  if not (Component is TControl) then exit;

  if (Component = nil) then begin
     if (FMasterComponent is TmzCustomEditclx) then (Component as TmzCustomEditclx).OnChange := FEvent;
     if (FMasterComponent is TmzComboBoxClx)   then (Component as TmzComboBoxClx).OnChange   := FEvent;
     FMasterComponent := nil;
     FEvent := nil;
     Exit;
  end;


  FMasterComponent := Component;

  if (FMasterComponent is TmzCustomEditclx) then begin
      FEvent := (FMasterComponent as TmzCustomEditclx).OnChange;
      (FMasterComponent as TmzCustomEditclx).OnChange := nil;
      (FMasterComponent as TmzCustomEditclx).OnChange := Self._ProcPadrao;
      FocusControl := (FMasterComponent as TWidgetControl);
      exit;
  end;

  if (FMasterComponent is TmzComboBoxClx) then begin
       FEvent := (FMasterComponent as TmzComboBoxClx).OnChange;
      (FMasterComponent as TmzCustomEditclx).OnChange := Self._ProcPadrao;
      FocusControl := (FMasterComponent as TWidgetControl);
      exit;
  end;

  FMasterComponent := nil;
  FEvent := nil;
end;

procedure TmzDBLabel.ExecutaConsulta;
var
 sTemp : string;
begin
  InQuery.Close;
  Caption := '';
  if (Lista.Text = '') or (sParam = '') or (InQuery.SQLConnection = nil) then exit;

  if (FMasterComponent is TmzCustomEditclx) then begin
   sTemp   := (FMasterComponent as TmzCustomEditclx).Text;
   if (sTemp = '') or (sTemp = '0') then exit; //Verifica dados em branco
  end;

  if (FMasterComponent is TmzComboBoxClx) then begin
    sTemp   := IntToStr( (FMasterComponent as TmzComboBoxClx).ValueIndex );
    if (sTemp = '-1') then exit; //Verifica dados em branco
  end;

  InQuery.Params.Clear;
  InQuery.SQL.Text := Lista.Text;

  InQuery.Params[0].Name := sParam;
  InQuery.Params[0].AsString := sTemp;

  InQuery.Open;
  Caption := InQuery.Fields[0].AsString;
end;

procedure TmzDBLabel.ProcPadrao(Sender : TObject);
begin
  ExecutaConsulta;
  if Assigned(FEvent) then FEvent(Sender);
end;



procedure Register;
begin
  RegisterComponents('Master', [TmzDBLabel]);
end;

end.
