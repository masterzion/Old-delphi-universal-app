unit mzDBComboBoxVCL;

interface

uses
  SysUtils, Classes, Controls, StdCtrls, mzComboBoxvcl,
  FMTBcd, DBXpress, DB, SqlExpr, Dialogs;

type
  TmzDBComboBoxVCL = class(TmzComboBoxvcl)
  private
    { Private declarations }
    InSQLQuery      : TSQLQuery;
    function  GetQueryActive:Boolean;
    procedure SetQueryActive(bActive :Boolean);

    procedure SetSqlConnection(Connection : TSQLConnection);
    function  GetSqlConnection: TSQLConnection;
  protected
    { Protected declarations }
    function GetIndexValue:Integer; override;
    procedure SetIndexValue(InValue:Integer); override;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetSQLQuery(SQL : TStrings);
    function GetSQLQuery:TStrings;
  published
    { Published declarations }
    property Active         : boolean         read GetQueryActive      write SetQueryActive;
    property SQLQuery       : TStrings        read GetSQLQuery      write SetSQLQuery;
    property SQLConnection  : TSQLConnection  read GetSQLConnection    write SetSqlConnection;
  end;

procedure Register;

implementation



function TmzDBComboBoxVCL.GetSQLQuery:TStrings;
begin
 Result := InSQLQuery.SQL;
end;



procedure TmzDBComboBoxVCL.SetSQLQuery(SQL : TStrings);
begin
 InSQLQuery.SQL := SQL;
end;

function TmzDBComboBoxVCL.GetSqlConnection: TSQLConnection;
begin
  Result := InSQLQuery.SQLConnection;
end;

procedure TmzDBComboBoxVCL.SetSqlConnection(Connection : TSQLConnection);
begin
  Connection.FreeNotification(self);
  InSQLQuery.SQLConnection := Connection;
end;

procedure TmzDBComboBoxVCL.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = InSQLQuery.SQLConnection) then InSQLQuery.SQLConnection := nil;
end;

constructor TmzDBComboBoxVCL.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  InSQLQuery := TSQLQuery.Create(self);
  Style := csOwnerDrawFixed;
end;

function TmzDBComboBoxVCL.GetIndexValue:Integer;
var
  N : Integer;
begin
  Result := -1;
  if (InSQLQuery.SQLConnection = nil) then exit;
  if not InSQLQuery.Active then begin
    Result := -1;
    exit;
  end;

  InSQLQuery.First;
  for n := 1 to ItemIndex do InSQLQuery.Next;
  Result := InSQLQuery.Fields[0].AsInteger;
end;

procedure TmzDBComboBoxVCL.SetIndexValue(InValue:Integer);
var
  N : Integer;
begin
  if (InSQLQuery.SQLConnection = nil) then exit;
  if (GetIndexValue = InValue) then exit;
  if not InSQLQuery.Active then exit;
  InSQLQuery.First;
  for n := 0 to InSQLQuery.RecordCount-1 do
     if (InSQLQuery.Fields[0].Value = InValue) then begin
        ItemIndex := N;
        break;
     end
     else
       InSQLQuery.Next;
end;


function TmzDBComboBoxVCL.GetQueryActive:Boolean;
begin
    Result := InSQLQuery.Active;
end;

procedure TmzDBComboBoxVCL.SetQueryActive(bActive :Boolean);
var
 n : Integer;
 sTemp : String;
 Lista : TStringList;
begin
  if (InSQLQuery.SQLConnection = nil) then exit;

  try
    InSQLQuery.Active := bActive;
  except
    exit;
  end;
  Items.Clear;

  if Active then begin
   Lista := TStringList.Create;
   for n := 0 to InSQLQuery.RecordCount-1 do begin
      sTemp := InSQLQuery.Fields[1].AsString;
      if (sTemp <> '') then Lista.Add(sTemp);
      InSQLQuery.Next;
   end;
   Items.Text := Lista.Text;
   Lista.Destroy;
  end;
   if (InSQLQuery.RecordCount > 0) then Self.ItemIndex := 0;
end;


procedure Register;
begin
  RegisterComponents('Master', [TmzDBComboBoxVCL]);
end;

end.
