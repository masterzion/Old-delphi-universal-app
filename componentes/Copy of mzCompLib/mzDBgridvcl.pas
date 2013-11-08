unit mzDBgridvcl;

interface

uses
  SysUtils, Classes, Controls, Grids, DBGrids, FMTBcd, DB, SqlExpr;

type
  TmzDbgridVCL = class(TDBGrid)
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


procedure TmzDbgridVCL.SetSQLDataSet(DataSet : TSqlDataSet);
begin
  InSQLDataSet := DataSet;
  DataSet.FreeNotification(Self);
end;


procedure TmzDbgridVCL.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent = InSQLDataSet) and (Operation = opRemove) then
    InSQLDataSet := nil;
end;


procedure Register;
begin
  RegisterComponents('Master', [TmzDbgridVCL]);
end;

end.
