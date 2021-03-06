program CriaForms;

uses
  QForms,
  Principal in 'Principal.pas' {frmPrincipal},
  mzlib in 'mzlib.pas',
  QueryEditor in 'QueryEditor.pas' {frmQueryEditor},
  FormEditor in 'FormEditor.pas' {frmFormEditor},
  DBGridEditor in 'DBGridEditor.pas' {frmDBGridEditor},
  NumEditEditor in 'NumEditEditor.pas' {frmNumEditEditor},
  ComboBoxEditor in 'ComboBoxEditor.pas' {frmComboBoxEditor},
  ChaveEditor in 'ChaveEditor.pas' {frmChaveEditor},
  btnNumEditEditor in 'btnNumEditEditor.pas' {frmBtnQueryEditProperties},
  formConfigura in 'formConfigura.pas' {frmConfigura},
  DBLabelEditor in 'DBLabelEditor.pas' {frmLabelEditor},
  TabEditor in 'TabEditor.pas' {frmTabEditor},
  formSplash in 'formSplash.pas' {frmSplash};

{$R *.res}

begin
  Application.Initialize;
  Application.HelpFile := 'CRIAFORMS.HLP';
  Application.Title := 'Universal Form Editor';
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TfrmTabEditor, frmTabEditor);
  Application.Run;
end.
