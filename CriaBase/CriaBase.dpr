program CriaBase;

uses
  QForms,
  formPrincipal in 'formPrincipal.pas' {frmPrincipal};

{$R *.res}

begin
  Application.Initialize;
  Application.HelpFile := 'CriaBase.Hlp';
  Application.Title := 'Cria Base';
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
