unit mzDBgrid;

interface

uses
  SysUtils, Classes, QControls, QGrids, QDBGrids, FMTBcd, DB, SqlExpr;

type
  TmzDbgrid = class(TDBGrid)
  private
   { Private declarations }
   InSQLDataSet : TSqlDataSet;
   InTableName     : string;
   procedure SetSQLDataSet(DataSet : TSqlDataSet);
  protected
    { Protected declarations }
  public
    { Public declarations }
   procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  published
   property SQLDataSet    : TSqlDataSet read InSQLDataSet write SetSQLDataSet;
   property TableName     : string read InTableName write InTableName;
    { Published declarations }
  end;

procedure Register;

implementation


procedure TmzDbgrid.SetSQLDataSet(DataSet : TSqlDataSet);
begin
  InSQLDataSet := DataSet;
  DataSet.FreeNotification(Self);
end;


procedure TmzDbgrid.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent = InSQLDataSet) and (Operation = opRemove) then
    InSQLDataSet := nil;
end;


procedure Register;
begin
  RegisterComponents('Master', [TmzDbgrid]);
end;

end.
