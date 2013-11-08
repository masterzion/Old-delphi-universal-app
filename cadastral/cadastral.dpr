program cadastral;

{%ToDo 'cadastral.todo'}

uses
  QForms,
  principal in 'principal.pas' {frmPrincipal},
  padrao in 'padrao.pas' {tbPadrao},
  formLogin in 'formLogin.pas' {frmLogin},
  formGrupo in 'formGrupo.pas' {frmGrupo},
  formUsuario in 'formUsuario.pas' {frmUsuario},
  formMudaPasswd in 'formMudaPasswd.pas' {frmAlteraSenha},
  formSplash in 'formSplash.pas' {frmSplash},
  formCalendario in 'formCalendario.pas' {frmCalendario},
  formConfigura in 'formConfigura.pas' {frmConfigura},
  formMensagens in 'formMensagens.pas' {frmMensagens},
  formMsg in 'formMsg.pas' {frmMsg},
  formCalculadora in 'formCalculadora.pas' {frmCalculadora},
  mzlib in 'mzlib.pas',
  formPluginsAbout in 'formPluginsAbout.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.HelpFile := 'UNIVERSAL.HLP';
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
