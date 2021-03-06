// This is enabled by the make webx command
// to make the plugin, this is already done by makefile
// and the dpr also defines it
//{$DEFINE FORWEBAX}

// Enable this if you have teechart pro
//{$DEFINE TEECHARTPRO}


//{$DEFINE INDY10}

//{$DEFINE USETNTUNICODE}
{$DEFINE USEDESIGNEDITORS}
{$DEFINE USERPDATASET}
{$DEFINE USEREPORTFUNC}

// ZLIB Support by default enabled
{$DEFINE USEZLIB}
// Indy support , remote report execution for base components
{$DEFINE USEINDY}

// Kerning support
{$DEFINE USEKERNING}

// Database drivers to be used by default
{$DEFINE USESQLEXPRESS}
{$DEFINE USEIBX}
{$DEFINE USEADO}
{$DEFINE USEBDE}
//{$DEFINE USEZEOS}
//{$DEFINE USEIBO}


// Unsupported database drivers in Linux
// To enable IBX under Kylix remove the related UNDEF
// By default is not defined becuase Borland don't provide
// it in default installation
{$IFDEF LINUX}
 {$UNDEF USEIBX}
 {$UNDEF USEADO}
 {$UNDEF USEBDE}
 {$UNDEF USEIBO}
 // Fixes performance issues in Linux about TStringList
 {$DEFINE USEEVALHASH}
 // Active this if zoombie proceses are created when executing lpr (text output)
 //{$DEFINE ALTLINUXTEXTPRINT}
{$ENDIF}

// Database drivers to be used when performing a release
{$IFDEF REPMANRELEASE}
 {$DEFINE USETNTUNICODE}
 {$DEFINE USEZEOS}
 {$DEFINE LINUXTEECHART}
 {$DEFINE TEECHARTPRO}
 {$DEFINE USEIBX}
{$ENDIF}



{$DEFINE USEVARIANTS}
{$DEFINE USEBCD}

// Delphi 5  compiler defines
{$IFDEF VER130}
 {$UNDEF USEVARIANTS}
 {$UNDEF USEBCD}
 {$UNDEF USESQLEXPRESS}
 {$DEFINE MSWINDOWS}
// {$UNDEF USEINDY}
{$ENDIF}

// Delphi 4  compiler defines
{$IFDEF VER120}
 {$UNDEF USEVARIANTS}
 {$UNDEF USEBCD}
 {$UNDEF USESQLEXPRESS}
 {$DEFINE MSWINDOWS}
 {$DEFINE USEVCL}
 {$UNDEF USEIBX}
 {$UNDEF USEZEOS}
 {$DEFINE BUILDER4}
 {$DEFINE DEPHI4}
 {$UNDEF USEDESIGNEDITORS}
 {$UNDEF USEEXCEL}
 {$UNDEF USEADO}
 {$UNDEF USEINDY}
{$ENDIF}


//  Builder 4 compiler defines
{$IFDEF VER125}
 {$UNDEF USEVARIANTS}
 {$UNDEF USEBCD}
 {$UNDEF USESQLEXPRESS}
 {$DEFINE MSWINDOWS}
 {$UNDEF USEIBX}
 {$UNDEF USEADO}
 {$DEFINE BUILDER4}
 {$UNDEF USEEXCEL}
 {$UNDEF USEINDY}
{$ENDIF}

// May be you want to enable TEECHART under Kylix
// but take care it needs an X server running
{$IFDEF MSWINDOWS}
 {$DEFINE USETEECHART}
{$ENDIF}

{$IFDEF LINUXTEECHART}
 {$IFDEF LINUX}
  {$DEFINE USETEECHART}
 {$ENDIF}
{$ENDIF}

{$IFDEF LINUX}
 {$DEFINE LINUXPRINTBUG}
 {$DEFINE KYLIX2}
{$ENDIF}

{$IFDEF LINUX}
{$IFDEF VER140}
 {$UNDEF KYLIX2}
// Vcl File Filters is a missing feature of CLX Dialogs in kylix 2 and Delphi 6
 {$DEFINE VCLFILEFILTERS}
{$ENDIF}
{$ENDIF}

// Delphi 7
{$IFDEF VER150}
 {$DEFINE VCLFILEFILTERS}
 {$DEFINE EMPTYCOMBOBUG}
 {$DEFINE ISDELPHI7}
 {$IFDEF MSWINDOWS}
  {$DEFINE BLOBSTREAMBUG}
//  {$DEFINE QUERYLINKBUG}
 {$ENDIF}
{$ENDIF}
{$IFDEF CLR}
 {$DEFINE DOTNETD}
 {$DEFINE INDY10}
{$ENDIF}
// DOT NET PREVIEW
{$IFDEF DOTNETD}
 {$UNDEF USEEVALHASH}
 {$DEFINE DOTNETDBUGS}
 {$DEFINE VCLFILEFILTERS}
 {$DEFINE MSWINDOWS}
 {$UNDEF USEZLIB}
 {$UNDEF USEADO}
 {$UNDEF USEDESIGNEDITORS}
// {$UNDEF USESQLEXPRESS}
// {$UNDEF USEIBX}
 {$UNDEF USEZEOS}
// {$UNDEF USETEECHART}
// {$UNDEF USEBDE}
// {$DEFINE FORWEBAX}
//  {$DEFINE QUERYLINKBUG}
//  {$UNDEF USEINDY}
// {$UNDEF USERPDATASET}
// {$UNDEF USEREPORTFUNC}
{$ENDIF}


// Windows qtintf.dll has a bug about selecting horz paper
// If horz paper is set and print setup is called seems
// to work ok
{$IFDEF MSWINDOWS}
 {$DEFINE HORZPAPERBUG}
{$ENDIF}



{$DEFINE ISDELPHI}
{$IFDEF FPC}
 {$UNDEF ISDELPHI}
 {$MODE DELPHI}
// {$UNDEF USEVARIANTS}
 {$UNDEF USEBCD}
{$ENDIF}

// Disable databases if webaxcontrol
{$IFDEF FORWEBAX}
 {$UNDEF USESQLEXPRESS}
 {$UNDEF USEIBX}
 {$UNDEF USEADO}
 {$UNDEF USEBDE}
 {$UNDEF USEIBO}
 {$UNDEF USEZEOS}
 {$UNDEF USEBCD}
 {$UNDEF USEREPORTFUNC}
 {$UNDEF USERPDATASET}
{$ENDIF}



// VCL and CLX sharing compatibility
{$IFDEF MSWINDOWS}
 {$DEFINE VCLANDCLX}
 // C++ Builder 6 does not allow VCL and CLX
 {$IFDEF BCB}
  {$UNDEF VCLANDCLX}
  {$IFDEF VER140}
   {$DEFINE USEVARIANTS}
  {$ENDIF}
 {$ENDIF}
 {$IFNDEF BCB}
  {$IFNDEF FORWEBAX}
   {$DEFINE USECLXTEECHART}
  {$ENDIF}
 {$ENDIF}
{$ENDIF}

{$IFDEF USETEECHART}
 {$IFDEF LINUX}
  {$IFNDEF FORWEBAX}
   {$DEFINE USECLXTEECHART}
  {$ENDIF}
 {$ENDIF}
{$ENDIF}

{$IFDEF FORCECONSOLE}
 {$UNDEF USECLXTEECHART}
{$ENDIF}