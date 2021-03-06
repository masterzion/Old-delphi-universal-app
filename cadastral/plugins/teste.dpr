library teste;

{ Important note about exception handling across multiple
  binary modules (executables and shared objects):

  For exception handling to work across multiple binary
  modules, all binary modules need to use the same copy
  of the shared exception handling code.

  To accomplish this, the following must be done:

  1) All binary modules must be built with the same version
  of the rtl runtime package.

  2) All binary modules must include the ShareExcept unit
  as the very first unit in the main project file's uses
  clause.

  If this is not done, exceptions raised in one module may
  cause unintended side effects in other modules. }


uses
  SysUtils,
  Dialogs,
  Classes;

type
 TVariantArray = array of variant;

{$R *.res}


procedure PluginName(var Parametros: pchar);  stdcall;
begin
  if Parametros = '1.0' then   Parametros := 'Meu Teste';
end;

procedure PluginAbout(var Parametros: pchar);  stdcall;
begin
 Parametros := 'Plugin: Meu Teste'+#13+
           'Autor: Jairo'+#13+
           'Empresa: SuperNova LTDA.'+#13+
           'Fone: (11) 81667512';
end;


exports
  PluginName,
  PluginAbout;

begin

end.





