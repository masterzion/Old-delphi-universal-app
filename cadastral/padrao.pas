unit padrao;

{$include configura.inc}

interface

uses
  SysUtils, Types, Classes, QGraphics, QControls, QForms, QDialogs,
  QStdCtrls, DBXpress, FMTBcd, DB, SqlExpr, QComCtrls, QMask, QImgList, QTypes, QMenus,
  QExtCtrls, principal, xmldom, XMLIntf, xercesxmldom, XMLDoc, oxmldom,
  Provider, DBClient, QButtons, mzDBgrid, QGrids, QDBGrids, mzDBComboBoxClx,
  mzComboBoxClx, mzlib, QDBCtrls, kbmMemTable, mzCustomEdit, windows,
  mzCustomBtnEditclx, mzBtnQueryEditclx, mzNumEditclx, mzDatePicker,
  mzCalcEdit, mzDBLabel, mzDBCheckBox, QActnList, rpcompobase, rpclxreport,
  rptranslator, mzMemoCLX, DCPcrypt2, DCPmd5, DCPrc4;


type
    TtbPadrao = class(TForm)
    Query: TSQLQuery;
    Controle: TToolBar;
    btnLocalizar: TToolButton;
    ToolButton5: TToolButton;
    btnNovo: TToolButton;
    btnSalvar: TToolButton;
    ToolButton8: TToolButton;
    btnExcluir: TToolButton;
    ToolButton10: TToolButton;
    btnFechar: TToolButton;
    btnImprimir: TToolButton;
    XMLDocument1: TXMLDocument;
    ClientDataSetBusca: TClientDataSet;
    DataSetProvider1: TDataSetProvider;
    DataSource1: TDataSource;
    PageControl1: TPageControl;
    TabSheetDetalhes: TTabSheet;
    TabSheetBrowser: TTabSheet;
    PanelBrowser: TPanel;
    QueryAux: TSQLQuery;
    DBGridBusca: TDBGrid;
    Splitter1: TSplitter;
    SQLQueryBusca: TSQLQuery;
    ActionList1: TActionList;
    ActNovo: TAction;
    ActSalvar: TAction;
    ActExcluir: TAction;
    ActImprimir: TAction;
    ActLocalizar: TAction;
    ActFechar: TAction;
    ToolButton1: TToolButton;
    actGraficos: TAction;
    CLXReport1: TCLXReport;
    PopupRel: TPopupMenu;
    RpTranslator1: TRpTranslator;
    DCP_md5: TDCP_md5;
    DCP_rc4: TDCP_rc4;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure DBGridBuscaDblClick(Sender: TObject);
    procedure DBGridBuscaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ActNovoExecute(Sender: TObject);
    procedure ActSalvarExecute(Sender: TObject);
    procedure ActExcluirExecute(Sender: TObject);
    procedure ActLocalizarExecute(Sender: TObject);
    procedure ActFecharExecute(Sender: TObject);
    procedure kbmMemTableAfterEdit(DataSet: TDataSet);
    procedure kbmMemTableBeforeDelete(DataSet: TDataSet);
    procedure ActImprimirExecute(Sender: TObject);
    procedure ExibeRelClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }

    {$IFDEF corporate}
       sCampoEmpresa : string;
    {$ENDIF}

    sCodLabels, sCamposForm,  sConsultaChave, sConsulta : String;
    AutoTexto, Alterando, CamposBusca    : Boolean;
    arIndexes    : TArStr;
    CodigoAtual, CampoChave, Tabelas      : TStringList;
    ConnectArray : TConnectArray;
    bSalvar, bLocalizar,  bExcluir : Boolean;
    ListaTab : TStringList;

    nMinHeight, nMinWidth : integer;

    function AddInArray(CamposPar: TArSTR; valor:String):TArSTR;
    procedure PreencheDados;
    procedure Cancelar;
    procedure ExecutaBusca(Codigo:TStringList);
    function RetornaCampoChave(Campo : TStringList; tabela : string) : string;
    function AbreQueryErro(TipoAbrir:Integer):Boolean;

    function NomesChavesValores(Valores:TStringList):string;
    function ChaveIndex(Nome:String; CamposPar: TArSTR):Integer;
    function InCampoChave(Campo:string):Boolean;

    procedure Excluir;
    procedure Salvar;
    procedure Localizar;
  public
    { Public declarations }
    {$IFDEF corporate}
       sCodEmpresa : string;
    {$ENDIF}
    MenuItem     : TMenuItem;
    procedure CarregaForm(CodTela:Integer);
  end;

var
  tbPadrao: TtbPadrao;

implementation

{$R *.xfm}

// ****************** Trata Campos Chaves  ******************

function TtbPadrao.ChaveIndex(Nome:String; CamposPar: TArSTR):Integer;
var
 n : Integer;
begin
  Result := -1;
  for n := 0 to Length(CamposPar)-1 do
     if (CamposPar[n] = Nome) then begin
       Result := N;
       exit;
     end;
end;


function TtbPadrao.NomesChavesValores(Valores:TStringList):string;
var
 n : Integer;
 sTemp : string;
begin
  sTemp := '';
  if (Valores.Count = 0) then
     for n := 0 to CodigoAtual.Count-1 do sTemp := sTemp+' and '+CodigoAtual.Strings[n]+' = '+CampoChave.Strings[n]
  else
     for n := 0 to Valores.Count-1 do sTemp := sTemp+ ' and '+CampoChave.Strings[n]+' = '+Valores[n];

  Result := sTemp;
end;

function TtbPadrao.InCampoChave(Campo:string):Boolean;
var
 n : Integer;
 sTemp : string;
begin
  sTemp := '';
  Result := False;
  for n := 0 to CampoChave.Count-1 do
    if CampoChave.Strings[n] = Campo then begin
      Result := True;
      exit;
    end;
end;


{
function TtbPadrao.NomesChaves:string;
var
 n : Integer;
begin

  if (Valores.Count = 0) then
     for n := 0 to CodigoAtual.Count-1 do Result := ' and '+CampoChave.Strings[n]
  else
     for n := 0 to CodigoAtual.Count-1 do Result := ' and '+CodigoAtual.Strings[n]+' = '+Valores[n];
end;

 }

// ****************** Procedimentos comuns ******************
function TtbPadrao.AbreQueryErro(TipoAbrir:Integer):Boolean;
var
 msg : String;
begin
  try
    if (TipoAbrir = mzQueryLocalizar) or (TipoAbrir = mzQueryLoad) or (TipoAbrir = mzCarregaAcesso) or (TipoAbrir = mzQueryCampoChave) then
      Query.Open
    else
      Query.ExecSQL;
    Result := False;
  except
      on E : EDatabaseError do begin
        Result := True;

        case TipoAbrir of
          0: msg := ErroSalvar;
          1: msg := ErroLocalizar;
          2: msg := ErroExecutar;
          3: msg := ErroExcluir;
          4: msg := concat(ErroTravar,Self.Name,'!');
          5: msg := concat(ErroDestravar,Self.Name,'!');
          6: msg := ErroLoad;
          7: msg := ErroCampoChave;
          8: msg := ErroSalvarFilhas;
          9: msg := CarregaAcesso;
        end;
        ShowMessage(msg+#13+E.Message);
      end;
  end;

end;





function TtbPadrao.RetornaCampoChave(Campo : TStringList; tabela : string) : string;
var
 sValor, sTemp, sCampo, sTabela:string;
 n1, n2 : Integer;
begin
  result := tabela + ' where ';
  {$IFDEF corporate}
  if (sCampoEmpresa <> '') then Result := result + sCampoEmpresa+' = '+sCodEmpresa+ ' and  ';
  {$ENDIF}

  for n1 := 0 to Campo.Count-1 do begin
    sTemp := Campo.Strings[n1];
    if CodigoAtual.Text = '' then
      sValor := '0'
    else
      sValor := CodigoAtual[n1];

    for n2 := 0 to Length(ConnectArray)-1 do begin
      // Verifica se é igual a origem
      sCampo   := ConnectArray[n2].sCampoOrigem;
      sTabela  := ConnectArray[n2].sTabelaOrigem;
      if (sTemp = sTabela+'.'+sCampo) then  Result := Result + ConnectArray[n2].sTabelaDestino+'.'+ConnectArray[n2].sCampoDestino + ' = ' + sValor +' and ';
    end; // For array
  end; // For Campo

//  for n1 := 0 to CodigoAtual.Count-1 do Result := Result + CampoChave.Strings[n1]+'  =  '+CodigoAtual.Strings[n1]+' and ';
  Result := Result + ' 1 = 1 ';
end;


function TtbPadrao.AddInArray(CamposPar: TArSTR; valor:String):TArSTR;
var
    temp:TArSTR;
    N: Integer;
begin
    temp := CamposPar;
    setlength(temp, length(temp) + 1);
    N := length(temp);
    while N < (Length(temp)-1) do temp[N] := CamposPar[N];
    temp[Length(temp)-1] := valor;
    Result := temp;
end;

procedure TtbPadrao.ExecutaBusca(Codigo:TStringList);
var
  sTemp : string;
  n : integer;
begin
 sTemp := 'select '+sCamposForm+
         ' from '+Tabelas.Strings[0]+
         ' where 1 = 1 '+
           NomesChavesValores(Codigo);
          {$IFDEF corporate}
          if (sCampoEmpresa <> '') then
            sTemp := sTemp+' and '+Tabelas.Strings[0]+'.'+sCampoEmpresa+' = '+sCodEmpresa;
          {$ENDIF}


 Query.SQL.Text := sTemp;
 if AbreQueryErro(mzQueryLocalizar) then exit;

 CodigoAtual.Clear;
 for n := 0 to Codigo.Count-1 do CodigoAtual.Add(Codigo[n]);

 Alterando := True;
 PreencheDados;
end;

procedure TtbPadrao.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Tabelas.Destroy;
  CodigoAtual.Destroy;
  CampoChave.Destroy;

  with MenuItem do begin
    Visible := True;
    Enabled  := True;
  end;

  Action := caFree;
end;

// ****************** Procedimentos de Salvar e Excluir ******************
procedure TtbPadrao.Salvar;
    function  GeraSintaxUpdate(var sQuery: String;var DadosPar, CamposPar, TabelasFilhas: TArSTR):String;
    var
      n, nTemp      : Integer;
      strtemp       : String;
      Dia, Mes, Ano : Word;
    begin
        // Inicia array de componentes de tabelas filhas
        SetLength(TabelasFilhas, 0);

        Result := '';
        sQuery := concat('update ', Tabelas.Strings[0] , ' set ');
        for n := 0 to Self.ComponentCount -1 do begin
            if (Self.Components[n] is TControl) then
              if (Self.Components[n] as TControl).Parent <> PanelBrowser then begin

                  // Num Edit
                  if (Self.Components[n] is TNumEditCLX) then
                     with (Self.Components[n] as TNumEditCLX) do
                         if ((not NullData) and IsEmpty) then
                            Result := Result + ', '+copy(TextLabel.Caption, 0, length(TextLabel.Caption)-1)
                         else begin
                                strtemp:= FieldName;
                                sQuery:= Concat(sQuery, strtemp,' =  ',SQL_PARM,strtemp, ' ,');

                                CamposPar := AddInArray(CamposPar, strtemp);
                                DadosPar :=  AddInArray(DadosPar, VirgulaPraPonto(Text) );
                          end; // Null Data


                  // Query Edit
                  if (Self.Components[n] is TmzBtnQueryEditclx) then
                     with (Self.Components[n] as TmzBtnQueryEditclx) do
                         if ((not NullData) and IsEmpty) then
                            Result := Result + ', '+copy(TextLabel.Caption, 0, length(TextLabel.Caption)-1)
                         else begin
                                strtemp:= FieldName;
                                sQuery:= Concat(sQuery, strtemp,' =  ',SQL_PARM,strtemp, ' ,');

                                CamposPar := AddInArray(CamposPar, strtemp);
                                DadosPar :=  AddInArray(DadosPar, VirgulaPraPonto(Text) );
                          end; // Null Data


                  // Combo Box
                  if (Self.Components[n] is TmzDBComboBoxClx) then
                     with (Self.Components[n] as TmzDBComboBoxClx) do begin
                        strtemp:= FieldName;
                        sQuery:= Concat(sQuery, strtemp,' =  ',SQL_PARM,strtemp, ' ,');

                        CamposPar := AddInArray(CamposPar, strtemp);
                        DadosPar :=  AddInArray(DadosPar, IntToStr(ValueIndex) );
                     end;


                  // CalcEdit
                  if (Self.Components[n] is TmzCalcEdit) then
                   with (Self.Components[n] as TmzCalcEdit) do
                      if ((not NullData) and IsEmpty) then
                         Result := Result + ', '+copy(TextLabel.Caption, 0, length(TextLabel.Caption)-1)
                      else begin
                         strtemp := FieldName;
                         sQuery  := Concat(sQuery, strtemp,' =  ',SQL_PARM,strtemp, ' ,');

                         CamposPar := AddInArray(CamposPar, strtemp);
                         DadosPar := AddInArray(DadosPar, VirgulaPraPonto(Text) );
                      end;


                  // CheckBox
                  if (Self.Components[n] is TmzDBCheckBox) then
                     with (Self.Components[n] as TmzDBCheckBox) do begin
                       strtemp := FieldName;
                       sQuery  := Concat(sQuery, strtemp,' =  ',SQL_PARM,strtemp, ' ,');

                       CamposPar := AddInArray(CamposPar, strtemp);
                       DadosPar := AddInArray(DadosPar, iif(Checked, 'T', 'F')  );
                     end;

                  // DatePicker
                  if (Self.Components[n] is TmzDatePicker) then
                     with (Self.Components[n] as TmzDatePicker) do
                        if ((not NullData) and IsEmpty) then
                           Result := Result + ', '+copy(TextLabel.Caption, 0, length(TextLabel.Caption)-1)
                        else begin
                         strtemp := FieldName;
                         sQuery  := Concat(sQuery, strtemp,' =  ',SQL_PARM,strtemp, ' ,');

                         CamposPar := AddInArray(CamposPar, strtemp);
                         DecodeDate(StrToDate(Text), Dia, Mes, Ano);
                         DadosPar := AddInArray(DadosPar, concat( inttostr(Dia),'/',inttostr(Mes),'/',inttostr(Ano) ));
                     end;

                  // Memo
                  if (Self.Components[n] is TmzMemo) then
                     with (Self.Components[n] as TmzMemo) do begin
                        strtemp:= FieldName;
                        sQuery:= Concat(sQuery, strtemp,' =  ',SQL_PARM,strtemp, ' ,');

                        CamposPar := AddInArray(CamposPar, strtemp);
                        DadosPar :=  AddInArray(DadosPar, VirgulaPraPonto(Lines.Text) );
                     end; // with

              end; //TControl).Parent <> PanelBrowser


              //Grava index das tabelas filhas (DBGrid tem outro Parent)
              if (Self.Components[n] is TmzDBGrid) then
                 if ( (Self.Components[n] as TmzDBGrid).Parent.Parent = TabSheetDetalhes ) then
                    TabelasFilhas := AddInArray(TabelasFilhas, IntToStr(n));

          end;  // For


       Query.SQL.Text := sConsultaChave;
       if AbreQueryErro(mzQueryCampoChave) then exit;
       sQuery[Length(sQuery)] := ' ';

       sQuery := sQuery + ' where 1 = 1 ';

       for n := 0 to CampoChave.Count-1 do begin
          strTemp := CampoChave.Strings[n];
          nTemp := ChaveIndex(strTemp, CamposPar);
          if (nTemp <> -1) then
             sQuery := sQuery + ' and '+CampoChave.Strings[n]+' =  '+SQL_PARM+strtemp;
       end;


       {$IFDEF corporate}
        if (sCampoEmpresa <> '') then begin
          //Preenche SQL
          sQuery:= Concat(sQuery, ' and ', sCampoEmpresa,' =  ',SQL_PARM,sCampoEmpresa);

          CamposPar := AddInArray(CamposPar, sCampoEmpresa);
          DadosPar :=  AddInArray(DadosPar, sCodEmpresa);
        end;
       {$ENDIF}

    end;


    function GeraSintaxInsert(var sQuery: String;var DadosPar, CamposPar, TabelasFilhas : TArSTR; var InCodigoAtual:TStringList):String;
    var
      n, nTemp                      : Integer;
      Campos, Dados, strtemp, sTemp : String;
      Dia, Mes, Ano                 : Word;
    begin
      // Inicia array de componentes de tabelas filhas
      SetLength(TabelasFilhas, 0);
      Result := '';
      InCodigoAtual.Clear;

      //Gera sintax de insert
      for n := 0 to Self.ComponentCount -1 do begin
         if (Self.Components[n] is TControl) then
            if (Self.Components[n] as TControl).Parent <> PanelBrowser then begin

              // NumEdit
              if (Self.Components[n] is TNumEditCLX) then
                 with (Self.Components[n] as TNumEditCLX) do
                     if ((not NullData) and IsEmpty) then
                        Result := Result + ', '+copy(TextLabel.Caption, 0, length(TextLabel.Caption))
                     else begin
                       //Preenche SQL
                       strtemp := FieldName;
                       if InCampoChave(StrTemp) then InCodigoAtual.Add(Text);
                       campos := concat(campos,  strtemp,  ' , ');
                       Dados := concat(Dados, SQL_PARM, strtemp, ' , ');

                       //Grava parametros em Arrays
                       CamposPar := AddInArray(CamposPar, strtemp);
                       DadosPar := AddInArray(DadosPar, VirgulaPraPonto(Text));
                     end;




              // Query Edit
              if (Self.Components[n] is TmzBtnQueryEditclx) then
                 with (Self.Components[n] as TmzBtnQueryEditclx) do
                     if ((not NullData) and IsEmpty) then
                        Result := Result + ', '+copy(TextLabel.Caption, 0, length(TextLabel.Caption))
                     else begin
                       //Preenche SQL
                       strtemp := FieldName;
                       if InCampoChave(StrTemp) then InCodigoAtual.Add(Text);
                       campos := concat(campos,  strtemp,  ' , ');
                       Dados := concat(Dados, SQL_PARM, strtemp, ' , ');

                       //Grava parametros em Arrays
                       CamposPar := AddInArray(CamposPar, strtemp);
                       DadosPar := AddInArray(DadosPar, VirgulaPraPonto(Text));
                     end;

              // ComboBox
              if (Self.Components[n] is TmzDBComboBoxClx) then
                 with (Self.Components[n] as TmzDBComboBoxClx) do begin
                     //Preenche SQL
                     strtemp := FieldName;
                     if InCampoChave(StrTemp) then InCodigoAtual.Add(IntToStr(ValueIndex));
                     campos := concat(campos,  strtemp,  ' , ');
                     Dados := concat(Dados, SQL_PARM, strtemp, ' , ');

                     //Grava parametros em Arrays
                     CamposPar := AddInArray(CamposPar, strtemp);
                     DadosPar := AddInArray(DadosPar, IntToStr(ValueIndex));
                 end;


              // CalcEdit
              if (Self.Components[n] is TmzCalcEdit) then
                 with (Self.Components[n] as TmzCalcEdit) do
                     if ((not NullData) and IsEmpty) then
                        Result := Result + ', '+copy(TextLabel.Caption, 0, length(TextLabel.Caption)-1)
                     else begin
                       strtemp := FieldName;
                       if InCampoChave(StrTemp) then InCodigoAtual.Add(Text);

                       //Preenche SQL
                       campos := concat(campos,  strtemp,  ' , ');
                       Dados := concat(Dados, SQL_PARM, strtemp,  ' , ');

                       //Grava parametros em Arrays
                       CamposPar := AddInArray(CamposPar, strtemp);
                       DadosPar := AddInArray(DadosPar, VirgulaPraPonto(Text) );
                     end;

              // CheckBox
              if (Self.Components[n] is TmzDBCheckBox) then
                 with (Self.Components[n] as TmzDBCheckBox) do begin
                     strtemp := FieldName;
                     if InCampoChave(StrTemp) then InCodigoAtual.Add(Value);

                     //Preenche SQL
                     campos := concat(campos,  strtemp,  ' , ');
                     Dados := concat(Dados, SQL_PARM, strtemp,  ' , ');

                     //Grava parametros em Arrays
                     CamposPar := AddInArray(CamposPar, strtemp);
                     DadosPar := AddInArray(DadosPar, Value );
                 end;


              // DatePicker
              if (Self.Components[n] is TmzDatePicker) then
                 with (Self.Components[n] as TmzDatePicker) do begin
                     strtemp := FieldName;
                     DecodeDate(StrToDate(Text), Dia, Mes, Ano);
                     sTemp := concat( inttostr(Dia),'/',inttostr(Mes),'/',inttostr(Ano) );

                     if InCampoChave(StrTemp) then InCodigoAtual.Add(sTemp);

                     //Preenche SQL
                     campos := concat(campos,  strtemp,  ' , ');
                     Dados := concat(Dados, SQL_PARM, strtemp,  ' , ');

                     //Grava parametros em Arrays
                     CamposPar := AddInArray(CamposPar, strtemp);
                     DadosPar := AddInArray(DadosPar, sTemp);
                 end;


              // Memo
              if (Self.Components[n] is TmzMemo) then
                 with (Self.Components[n] as TmzMemo) do begin
                       //Preenche SQL
                       strtemp := FieldName;
                       if InCampoChave(StrTemp) then InCodigoAtual.Add(Text);
                       campos := concat(campos,  strtemp,  ' , ');
                       Dados := concat(Dados, SQL_PARM, strtemp, ' , ');

                       //Grava parametros em Arrays
                       CamposPar := AddInArray(CamposPar, strtemp);
                       DadosPar := AddInArray(DadosPar, VirgulaPraPonto(Lines.Text));
                 end; 

           end; // Parent <> PanelBrowser


           //Grava index das tabelas filhas (DBGrid tem outro Parent)
           if (Self.Components[n] is TmzDBGrid) then
              if ( (Self.Components[n] as TmzDBGrid).Parent.Parent = TabSheetDetalhes ) then
                 TabelasFilhas := AddInArray(TabelasFilhas, IntToStr(n));

      end;    // For

       Query.SQL.Text := sConsultaChave;
       if AbreQueryErro(mzQueryCampoChave) then exit;



       for n := 0 to CampoChave.Count-1 do begin
          strtemp := CampoChave.Strings[n];
          nTemp := ChaveIndex(strTemp, CamposPar);

          if (nTemp = -1) then begin
            campos := concat(campos,  strtemp,  ' , ');
            Dados := concat(Dados, SQL_PARM, strtemp, ' , ');
            CamposPar := AddInArray(CamposPar, strtemp);
            DadosPar := AddInArray(DadosPar, Query.Fields[0].AsString);
          end
          else
            if (trim(DadosPar[nTemp]) = '') or (trim(DadosPar[nTemp]) = '0') then begin
               if (n >= Query.Fields.Count) then begin
                 ShowMessage(ErroCamposChave);
                 exit;
               end;
               strTemp := Query.Fields[n].AsString;
               InCodigoAtual.Clear;
               if (strTemp = '') or (strTemp = '') then strTemp := '1';
               DadosPar[nTemp] := strTemp;
               InCodigoAtual.Add(strTemp);
            end;
       end;





       {$IFDEF corporate}
        if (sCampoEmpresa <> '') then begin
          //Preenche SQL
          campos := concat(campos,  sCampoEmpresa,  ' , ');
          Dados := concat(Dados, SQL_PARM, sCampoEmpresa,  ' , ');

          CamposPar := AddInArray(CamposPar, sCampoEmpresa);
          DadosPar :=  AddInArray(DadosPar, sCodEmpresa);
        end;
       {$ENDIF}


      sQuery := concat('insert into ',  Tabelas.Strings[0] , ' (', copy(Campos, 1, length(Campos)-3),  ') values (', copy(Dados, 1, length(Dados)-3), ')');
    end;

    function PopulaFilhos(const Campo, Codigo:String):String;
    var
      n, n2:Integer;
      kbmMemTable : TkbmMemTable;
      Component : TComponent;
    begin
      Result := '';
      for n := 0 to Length(ConnectArray)-1 do begin
        if (ConnectArray[n].sTabelaOrigem+'.'+ConnectArray[n].sCampoOrigem = Campo) then begin
           Component :=  FindComponent(ConnectArray[n].sTabelaDestino);
           if (Component <> nil) then begin
             kbmMemTable := (Component as TkbmMemTable);
             with kbmMemTable do begin
                 First;
                 for n2 := 0 to RecordCount-1 do begin
                   Edit;
                   FieldByName(ConnectArray[n].sCampoDestino).AsString := Codigo;
                   Post;
                   Next;
                 end; // kbmMemTable.Next
             end; //with

           end; //if Component <> nil
           Result := ConnectArray[n].sTabelaDestino+'.'+ConnectArray[n].sCampoDestino;
        end; // if array
      end; // For
    end;


var
 n, n2, n3                   : Integer;
 TabelasFilhas, CamposPar, DadosPar         : TArSTR;
 sTemp, sCamposVasios, sQuery, sCampos, sParametros : String;
 kbmMemTable : TkbmMemTable;
 InDate      : TDateTime;
 Dia, Mes, Ano : Word;
 InCodigoAtual : TStringList;
begin
  if not bSalvar then begin
    ShowMessage(ErroAcesso);
    exit;
  end;


  setlength(CamposPar, 0);
  setlength(DadosPar, 0);
  InCodigoAtual := TStringList.Create;
  InCodigoAtual.Text := CodigoAtual.Text;


  if AutoTexto then begin

      if  Alterando then
          sCamposVasios := GeraSintaxUpdate(sQuery, DadosPar, CamposPar, TabelasFilhas)
      else
          sCamposVasios := GeraSintaxInsert(sQuery, DadosPar, CamposPar, TabelasFilhas, InCodigoAtual );

      //Verifica se existe campos obrigatórios não preenchidos
      if (sCamposVasios <> '') then begin
          sCamposVasios[1] := ' ';
          ShowMessage(ErroCampoObrigatorio+#10#13+sCamposVasios);
          exit;
      end;


      // Apaga os dados antigos das tabelas filhas
      for N := Tabelas.Count-1 downto 1 do begin // (ignora tabela pai)
        sTemp := 'delete from '+RetornaCampoChave(CampoChave, Tabelas.Strings[n]);
        Query.SQL.Text := sTemp;
        if AbreQueryErro(mzQueryExcluir) then exit;
      end;


      // Salva os dados
      with query do begin
         Params.Clear;
         SQL.Text := sQuery;
         for N := 0 to length(CamposPar)-1 do  ParamByName(CamposPar[N]).AsString := DadosPar[N];

{           with query.Params.Add do begin
              Param[N].Name     := CamposPar[N];
              Params[N].AsString := DadosPar[N];
           end;}
          if AbreQueryErro(mzQuerySave) then exit;
      end;

      //Popula Codigos Chaves nos Filhos
      for n := 0 to CampoChave.Count-1 do begin
        sTemp := CampoChave.Strings[n];
        while (sTemp <> '') do  sTemp := PopulaFilhos(sTemp, InCodigoAtual.Strings[n]);
      end;



      // Cria insert das tabelas filhas com os dados do Memmory Table
      for n := 0 to length(TabelasFilhas)-1 do begin
        kbmMemTable := ( (Self.Components[StrToInt(TabelasFilhas[n])] as TmzDbGrid).DataSource.DataSet as TkbmMemTable);
        kbmMemTable.First;
        for n2 := 0 to kbmMemTable.RecordCount-1 do begin
          // Zera dados
          SetLength(DadosPar, 0);
          SetLength(CamposPar, 0);
          sCampos     := '';
          sParametros := '';

          for n3 := 0 to kbmMemTable.Fields.Count-1 do begin
            if kbmMemTable.Fields[n3].DataType in [ftDate, ftDateTime, ftTimeStamp] then begin
               InDate := kbmMemTable.Fields[n3].AsDateTime;
               DecodeDate(InDate, Dia, Mes, Ano);
               DadosPar := AddInArray(DadosPar, concat( inttostr(Dia),'/',inttostr(Mes),'/',inttostr(Ano) ));
            end
            else
            {$IFDEF corporate}
               if (sCampoEmpresa <> kbmMemTable.Fields[n3].FieldName) then
            {$ENDIF}
                DadosPar   := AddInArray(DadosPar, kbmMemTable.Fields[n3].AsString);

            {$IFDEF corporate}
                if (sCampoEmpresa <> kbmMemTable.Fields[n3].FieldName) then begin
            {$ENDIF}
                 CamposPar  := AddInArray(CamposPar, kbmMemTable.Fields[n3].FieldName);
                 sCampos     := sCampos+', '+kbmMemTable.Fields[n3].FieldName;
                 sParametros := sParametros+', '+SQL_PARM+kbmMemTable.Fields[n3].FieldName;
             {$IFDEF corporate}
              end;
             {$ENDIF}
          end;  // for


         {$IFDEF corporate}
          if (sCampoEmpresa <> '') then begin
             CamposPar  := AddInArray(CamposPar, sCampoEmpresa);
             DadosPar   := AddInArray(DadosPar, sCodEmpresa);
             sCampos     := sCampos+', '+sCampoEmpresa;
             sParametros := sParametros+', '+SQL_PARM+sCampoEmpresa;
          end;
         {$ENDIF}

          Query.Params.Clear;
          sCampos[1]        := ' ';
          sParametros[1]    := ' ';

          sQuery := 'Insert Into '+kbmMemTable.Name+'('+sCampos+') values ('+sParametros+')';
          Query.SQL.Text := sQuery;

// MZ:: Erro de camada          

//          sTemp := copy(sCampoChave, pos('.', sCampoChave)+1, Length(sCampoChave));
          for N3 := 0 to length(CamposPar)-1 do begin
//              if (CamposPar[N3] <> sTemp) then begin
                Query.Params[N3].Name     := CamposPar[N3];
                Query.Params[N3].AsString := DadosPar[N3];
{              end
              else begin
                Query.Params[N3].Name     := sCampoChave;
                Query.Params[N3].AsInteger := CodigoAtual;
              end;}
          end;

          if AbreQueryErro(mzQuerySaveChild) then exit;
          kbmMemTable.Next;
        end; // Tabela Atual
      end;  // Tabelas filhas

    end
    else begin
      with query do begin
        Query.SQL.Text := sQuery;
        if AbreQueryErro(mzQuerySave) then exit;
      end;
    end;

    // Limpa os dados na tela
    Cancelar;

    // Carrega os dados atualizados
    ExecutaBusca(InCodigoAtual);
    InCodigoAtual.Destroy;
    ActExcluir.Enabled := True;
end;


procedure TtbPadrao.Excluir;
var
  n     : Integer;
  sTemp : string;
begin

 if not bExcluir then begin
    ShowMessage(ErroAcesso);
    exit;
 end;

  if MessageDlg(ExcluirDados,  mtConfirmation, [mbYes, mbNo], 0) = mrNo then exit;
  with query do begin
    for N := Tabelas.Count-1 downto 0 do begin
      sTemp := concat('delete from ', RetornaCampoChave(CampoChave, Tabelas.Strings[n]) );

      Query.SQL.Text := sTemp;
      if AbreQueryErro(mzQueryExcluir) then exit;
    end;
    CodigoAtual.Clear;
  end;


  Cancelar;
  Alterando:= False;
  ShowMessage(sExcluido);
  btnLocalizar.Click;
end;


procedure TtbPadrao.FormCreate(Sender: TObject);
begin
 CodigoAtual := TStringList.Create;
 CampoChave  := TStringList.Create;

 bSalvar   := False;
 bLocalizar := False;
 bExcluir   := False;

 Position := poScreenCenter;
 AutoTexto := true;
 Setlength(arIndexes, 0);
 AutoTexto := true;

end;

procedure TtbPadrao.DBGridBuscaDblClick(Sender: TObject);
var
  n1, n2 : Integer;
  ListaTemp : TStringlist;
  sTemp : string;
begin
  ListaTemp  := TStringlist.Create;
  for n1 := 0 to CampoChave.Count-1 do
    for n2 := 0 to DBGridBusca.FieldCount-1 do begin
     sTemp := CampoChave.Strings[n1];
     sTemp := copy(sTemp, pos('.', sTemp)+1, Length(sTemp) );
     if (DBGridBusca.Fields[n2].FullName = sTemp) then  ListaTemp.Add(DBGridBusca.Fields[n2].AsString);
    end;

   ExecutaBusca(ListaTemp);
   ListaTemp.Destroy;
end;


// ****************** Procedimentos dos componentes ******************

procedure TtbPadrao.kbmMemTableBeforeDelete(DataSet: TDataSet);
    procedure ProcuraCamposFilhos(Table : TDataset);
       procedure ApagaCamposFilhos(Tabela, Campo, Valor:String);
       var
         n, n2 : Integer;
         Component : TComponent;
         Table : TkbmMemTable;
       begin
         for n:= 0 to length(ConnectArray)-1 do begin
             //Procura por Tabela/Campo filho
             if (UpperCase(ConnectArray[n].sTabelaOrigem+'.'+ConnectArray[n].sCampoOrigem) = UpperCase(Tabela+'.'+Campo)) then begin
                 Component := FindComponent(ConnectArray[n].sTabelaDestino);  // Localiza o MemTable
                 if (Component <> nil) then // Verifica se achou
                   if (Component is TkbmMemTable) then begin // Verifica se é MemTable
                        Table := (Component as TkbmMemTable);
                        Table.Last;
                        for n2 := Table.RecordCount-1 downto 0 do begin
                          if (Table.FieldByName(ConnectArray[n].sCampoDestino).AsString = Valor) then
                            Table.Delete;
                     end; // if AsString <> ''
                    end; // (Component <> nil)
              end; // if ConnectArray.sTabelaOrigem
         end; // for

       end; // Begin


    var
      n : Integer;
    begin
      for n := Table.Fields.Count-1 downto 0 do
        ApagaCamposFilhos(DataSet.Name, Table.Fields[n].FieldName, Table.Fields[n].AsString);
    end;
begin
   ProcuraCamposFilhos(DataSet);
end;



procedure TtbPadrao.kbmMemTableAfterEdit(DataSet: TDataSet);
    procedure SetaCampoFilho(Table : TDataset);
       function RetornaCampoValor(Tabela, Campo:String):string;
       var
         n : Integer;
         Component : TComponent;
         Table : TkbmMemTable;
       begin
         Result := '';

         for n:= 0 to length(ConnectArray)-1 do begin
             // Procura por Origem
             if (UpperCase(ConnectArray[n].sTabelaDestino+'.'+ConnectArray[n].sCampoDestino) = UpperCase(Tabela+'.'+Campo)) then begin
                 Component := FindComponent(ConnectArray[n].sTabelaOrigem);  // Procura Componente
                 if (Component <> nil) then // Verifica se achou
                   if (Component is TkbmMemTable) then begin // Verifica se é MemTable
                     Table := (Component as TkbmMemTable);
                     if (Table.FieldByName(ConnectArray[n].sCampoOrigem).AsString <> '') and  (Table.FieldByName(ConnectArray[n].sCampoOrigem).AsString <> '0') then begin // Verifica se está em branco
                        Result := Table.FieldByName(ConnectArray[n].sCampoOrigem).AsString;
                        exit;
                     end; // if AsString <> ''
                    end; // (Component <> nil)
              end; // if ConnectArray.sTabelaOrigem
         end; // for

       end; // Begin


    var
      n : Integer;
      sTemp : String;
    begin
      for n := Table.Fields.Count-1 downto 0 do begin
        sTemp := RetornaCampoValor(DataSet.Name, Table.Fields[n].FieldName);
        if sTemp <> '' then Table.Fields[n].AsString := stemp;
      end;
    end;
begin
   SetaCampoFilho(DataSet);
end;



procedure TtbPadrao.CarregaForm(CodTela:Integer);
  procedure AjustaTamanho(InHeight, InWidth : integer);
  begin
    if nMinWidth  < InWidth   then nMinWidth  := InWidth +10;
    if nMinHeight < InHeight  then nMinHeight := InHeight +128;
  end;

{  procedure CriaDbGrid(NodeAtual:IXMLNode; DbParent:TWidgetControl);
  var
    InDbGrid                : TmzDbgrid;
    InDataSource            : TDataSource;
    kbmMemTable             : TkbmMemTable;
    InSQLDataSet            : TSQLDataSet;
    nTemp, n, n2   : Integer;
    PanelPai, PanelControle : TPanel;
  begin

      //Verifica Campos
      QueryAux.SQL.Text       :=  NodeAtual.ChildNodes['sqldataset'].Text+'0 = 1';
      QueryAux.Open;

      // Acesso memory Table
      kbmMemTable             := TkbmMemTable.Create(Self);
      kbmMemTable.LoadFromDataSet(QueryAux,[mtcpoStructure]);
      kbmMemTable.Name        := NodeAtual.ChildNodes['tablename'].Text;

      // Acesso DataSource
      InDataSource         := TDataSource.Create(Self);
      InDataSource.DataSet := kbmMemTable;

      // Panels
      PanelPai := TPanel.Create(Self);
      with PanelPai do begin
        Parent  := DbParent;
        Caption := '';
        Top               := NodeAtual.ChildNodes['top'].NodeValue;
        Left              := NodeAtual.ChildNodes['left'].NodeValue;
        Width             := NodeAtual.ChildNodes['width'].NodeValue;
        height            := NodeAtual.ChildNodes['height'].NodeValue;
      end;

      PanelControle := TPanel.Create(Self);
      with PanelControle do begin
       Parent  := PanelPai;
       Caption := '';
       Align   := alRight;
       Width   := 70;
      end;

      //DataSet
      InSQLDataSet := TSQLDataSet.Create(Self);
      InSQLDataSet.Name := RetornaNomeComponente('MemTableSQLConnection');
      InSQLDataSet.SQLConnection :=  frmPrincipal.SQLConnection1;
      InSQLDataSet.CommandText   := NodeAtual.ChildNodes['tablename'].Text;


      // Grid
      InDbGrid := TmzDbgrid.Create(Self);
      InDbGrid.Parent      := PanelPai;

      // Seta campos como auto-increment
      kbmMemTable.Active          := True;
      for n := 0 to kbmMemTable.FieldCount-1 do begin
        nTemp := kbmMemTable.Fields[n].Index;
        kbmMemTable.Active          := False;
        kbmMemTable.FieldDefs[nTemp].Required  := False;
         if NodeAtual.ChildNodes['columns'].ChildNodes[n].ChildNodes['auto_inc'].NodeValue then begin
            kbmMemTable.FieldDefs[nTemp].DataType := ftAutoInc;
            kbmMemTable.FieldDefs[nTemp].Required := False;
        end;
        kbmMemTable.Active          := True;
      end;

      // Seta campos chave
      for n := 0 to Length(ConnectArray)-1 do
        with kbmMemTable do begin
          Active := False;
          for n2 := 0 to Fields.Count-1 do begin
             if (ConnectArray[n].sTabelaOrigem  = kbmMemTable.Name) and (ConnectArray[n].sCampoOrigem  = Fields[n2].FieldName) then FieldDefs[n2].DataType := ftAutoInc;
             if (ConnectArray[n].sTabelaDestino = kbmMemTable.Name) and (ConnectArray[n].sCampoDestino = Fields[n2].FieldName) then FieldDefs[n2].DataType := ftAutoInc;
             FieldDefs[n2].Required    := False;
          end;
          Active := True;
        end;


      with InDbGrid do begin
        ReadOnly    := False;
        Align       := alClient;
        BorderStyle := bsNone;
        DataSource  := InDataSource;
        Name        := NodeAtual.ChildNodes['name'].Text;
        TableName   := NodeAtual.ChildNodes['tablename'].Text;
        Options     := [dgEditing,dgTitles,dgIndicator,dgColumnResize,dgRowLines,dgTabs,dgConfirmDelete,dgCancelOnExit];
        PopupMenu   := PopupMenuComum;
        OnMouseDown := Edit1MouseDown;
        OnCellClick := mzDbgrid1CellClick;
        SQLDataSet  := InSQLDataSet;
        OnMouseDown   := Edit1MouseDown;
        OnMouseUp     := Edit1MouseUp;
        OnMouseMove   := GridMouseMove;
        for n := 0 to Columns.Count-1 do begin
          Columns[n].Title.Font.Color := clBlue;
          with NodeAtual.ChildNodes['columns'] do begin
              Columns[n].Title.Caption  := ChildNodes[n].ChildNodes['caption'].Text;
              Columns[n].Field.EditMask := ChildNodes[n].ChildNodes['mask'].Text;
              Columns[n].Visible        := ChildNodes[n].ChildNodes['visible'].NodeValue;
              Columns[n].Width          := ChildNodes[n].ChildNodes['width'].NodeValue;
          end;
        end; // for
      end;
  end; }


  procedure CriaDbGrid(NodeAtual:IXMLNode; DbParent:TWidgetControl);
  var
    InDbGrid                : TmzDbgrid;
    InDataSource            : TDataSource;
    kbmMemTable             : TkbmMemTable;
    nTemp, n, n2            : Integer;
    PanelPai, PanelControle : TPanel;
    DBNav                   : TDBNavigator;
  begin

      //Verifica Campos
      QueryAux.SQL.Text       :=  NodeAtual.ChildNodes['sqldataset'].Text+' 0 = 1';
      QueryAux.Open;



      // Acesso memory Table
      kbmMemTable             := TkbmMemTable.Create(Self);
      with kbmMemTable do begin
        LoadFromDataSet(QueryAux,[mtcpoStructure]);
        Name            := NodeAtual.ChildNodes['tablename'].Text;
        AfterEdit       := kbmMemTableAfterEdit;
        AfterInsert     := kbmMemTableAfterEdit;
        BeforeDelete    := kbmMemTableBeforeDelete;
        AutoIncMinValue := 1;
        Active          := True;
      end;

      // Panels
      PanelPai := TPanel.Create(Self);
      with PanelPai do begin
       Parent  := DbParent;
       Caption := '';
        Top               := NodeAtual.ChildNodes['top'].NodeValue;
        Left              := NodeAtual.ChildNodes['left'].NodeValue;
        Width             := NodeAtual.ChildNodes['width'].NodeValue;
        height            := NodeAtual.ChildNodes['height'].NodeValue;
        AjustaTamanho(Top+height, Left+Width);
      end;

      PanelControle := TPanel.Create(Self);
      with PanelControle do begin
       Parent  := PanelPai;
       Caption := '';
       Align   := alRight;
       Width   := 70;
      end;

      // Seta campos como auto-increment
      kbmMemTable.Active := False;
      with kbmMemTable do
        for n := FieldDefs.Count-1 downto 0 do begin
          nTemp := FieldDefs[n].Index;
          FieldDefs[nTemp].Required  := False;
         if NodeAtual.ChildNodes['columns'].ChildNodes[n].ChildNodes['auto_inc'].NodeValue then begin
            kbmMemTable.FieldDefs[nTemp].DataType := ftAutoInc;
            kbmMemTable.FieldDefs[nTemp].Required := False;
        end;
        end;
      kbmMemTable.Active := True;

      // Seta campos chave
      for n := 0 to Length(ConnectArray)-1 do
        with kbmMemTable do begin
          Active := False;
          for n2 := 0 to Fields.Count-1 do begin
             if (ConnectArray[n].sTabelaOrigem  = kbmMemTable.Name) and (ConnectArray[n].sCampoOrigem  = Fields[n2].FieldName) then
                if not InCampoChave(kbmMemTable.Name+'.'+Fields[n2].FieldName) then FieldDefs[n2].DataType := ftAutoInc;

             if (ConnectArray[n].sTabelaDestino = kbmMemTable.Name) and (ConnectArray[n].sCampoDestino = Fields[n2].FieldName) then
                if not InCampoChave(kbmMemTable.Name+'.'+Fields[n2].FieldName) then FieldDefs[n2].DataType := ftAutoInc;

             FieldDefs[n2].Required    := False;
          end;
          Active := True;
        end;


      // Acesso DataSource
      InDataSource         := TDataSource.Create(Self);
      InDataSource.DataSet := kbmMemTable;

      // Grid
      InDbGrid := TmzDbgrid.Create(Self);
      InDbGrid.Parent      := PanelPai;
      with InDbGrid do begin
        ReadOnly    := False;
        Align       := alClient;
        BorderStyle := bsNone;
        DataSource  := InDataSource;
        Name        := NodeAtual.ChildNodes['name'].Text;
        TableName   := NodeAtual.ChildNodes['tablename'].Text;
        Options     := [dgEditing,dgTitles,dgIndicator,dgColumnResize,dgRowLines,dgTabs,dgConfirmDelete,dgCancelOnExit];
        for n := 0 to Columns.Count-1 do begin
          Columns[n].Title.Font.Color := clBlue;
          with NodeAtual.ChildNodes['columns'] do begin
              Columns[n].Title.Caption  := ChildNodes[n].ChildNodes['caption'].Text;
              Columns[n].Field.EditMask := ChildNodes[n].ChildNodes['mask'].Text;
              Columns[n].Visible        := ChildNodes[n].ChildNodes['visible'].NodeValue;
              Columns[n].Width          := ChildNodes[n].ChildNodes['width'].NodeValue;
          end;
        end; // for
      end;
      InDataSource.Enabled := True;

      // Acesso ao BD
      DBNav   := TDBNavigator.Create(Self);
      with DBNav do begin
         Parent         := PanelControle;
         VisibleButtons := [nbInsert, nbDelete];
         Width          := 50;
         Left           := 10;
         Top            := ((Parent as TPanel).Height div 2)-13;
         DataSource     := InDataSource;
      end;
  end;


  procedure CriaNumEdit(NodeComponent:IXMLNode; EditParent:TWidgetControl);
  var
    InEdit : TNumEditCLX;
    strTemp : string;
  begin
      InEdit := TNumEditCLX.Create(Self);
      InEdit.Parent := EditParent;
      with InEdit do begin
        Editmask          := nodecomponent.ChildNodes['editmask'].Text;
        strTemp           := nodecomponent.ChildNodes['fieldname'].Text;
        FieldName         := strTemp;
        Name              := nodecomponent.ChildNodes['name'].Text;
        ReadOnly          := (nodecomponent.ChildNodes['readonly'].Text = '1');
        NullData          := (nodecomponent.ChildNodes['nulldata'].Text = '1');
        Top               := nodecomponent.ChildNodes['top'].NodeValue;
        Left              := nodecomponent.ChildNodes['left'].NodeValue;
        Width             := strToInt(nodecomponent.ChildNodes['width'].Text);
        Text              := '';
        TextLabel.Visible := (nodecomponent.ChildNodes['showcaption'].Text = '1');
        TextLabel.Caption := nodecomponent.ChildNodes['caption'].Text;
        ListaTab.Add(nodecomponent.ChildNodes['width'].Text+'&'+nodecomponent.ChildNodes['name'].Text);
        if CamposBusca then  sCamposForm  := strTemp+', '+sCamposForm;
        AjustaTamanho(Top+height, Left+Width);
        case nodecomponent.ChildNodes['numbertype'].NodeValue of
            0 : NumberType := mzString;
            1 : NumberType := mzInteger;
            2 : NumberType := mzFloat;
        end;
      end;
  end;


  procedure CriaComboBox(NodeComponent:IXMLNode; ComboParent:TWidgetControl);
  var
    ComboBox : TmzDBComboBoxClx;
    strTemp : string;
  begin
      ComboBox := TmzDBComboBoxClx.Create(Self);
      ComboBox.Parent := ComboParent;
      with ComboBox do begin
        TextLabel.Caption := nodecomponent.ChildNodes['caption'].Text;
        strTemp           := nodecomponent.ChildNodes['fieldname'].Text;
        FieldName         := strTemp;
        Name              := nodecomponent.ChildNodes['name'].Text;
        TextLabel.Visible := (nodecomponent.ChildNodes['showcaption'].Text = '1');
        Top               := nodecomponent.ChildNodes['top'].NodeValue;
        Left              := nodecomponent.ChildNodes['left'].NodeValue;
        Width             := nodecomponent.ChildNodes['width'].NodeValue;
        SQLConnection          := frmPrincipal.SQLConnection1;
        ListaTab.Add(nodecomponent.ChildNodes['width'].Text+'&'+nodecomponent.ChildNodes['name'].Text);
        try
          SQLQuery.CommaText     := nodecomponent.ChildNodes['sqlquery'].NodeValue;
          while (ComboBox.Items.count = 0) do begin
            ComboBox.Active := False;
            ComboBox.Active := True;
          end;

        except end;
        if CamposBusca then  sCamposForm  := strTemp+', '+sCamposForm;
        AjustaTamanho(Top+height, Left+Width);
      end;

  end;


  procedure CriabtnQueryEdit(NodeComponent:IXMLNode; EditParent:TWidgetControl);
  var
    btnQueryEdit : TmzBtnQueryEditclx;
    strTemp : string;
  begin
      btnQueryEdit := TmzBtnQueryEditclx.Create(Self);
      btnQueryEdit.Parent := EditParent;
      with btnQueryEdit do begin
        Editmask                := nodecomponent.ChildNodes['editmask'].Text;
        strTemp                 := nodecomponent.ChildNodes['fieldname'].Text;
        FieldName               := strTemp;
        Name                    := nodecomponent.ChildNodes['name'].Text;
        ReadOnly                := (nodecomponent.ChildNodes['readonly'].Text = '1');
        NullData                := (nodecomponent.ChildNodes['nulldata'].Text = '1');
        Top                     := nodecomponent.ChildNodes['top'].NodeValue;
        Left                    := nodecomponent.ChildNodes['left'].NodeValue;
        Width                   := nodecomponent.ChildNodes['width'].NodeValue;
        Text                    := '';
        ParamName               := CAMPO_BUSCA;
        TextLabel.Visible       := (nodecomponent.ChildNodes['showcaption'].Text = '1');
        TextLabel.Caption       := nodecomponent.ChildNodes['caption'].Text;
        QueryList.CommaText     := nodecomponent.ChildNodes['querylist'].Text;
        ComponentList.CommaText := nodecomponent.ChildNodes['componentlist'].Text;
        SQLConnection           := frmPrincipal.SQLConnection1;
        ListaTab.Add(nodecomponent.ChildNodes['width'].Text+'&'+nodecomponent.ChildNodes['name'].Text);
        if CamposBusca then  sCamposForm  := strTemp+', '+sCamposForm;
        AjustaTamanho(Top+height, Left+Width);
      end;
  end;


  procedure CriaDatePicker(NodeComponent:IXMLNode; EditParent:TWidgetControl);
  var
    InmzDatePicker: TmzDatePicker;
    strTemp : string;
  begin
      InmzDatePicker := TmzDatePicker.Create(Self);
      InmzDatePicker.Parent := EditParent;
      with InmzDatePicker do begin
        Editmask           := nodecomponent.ChildNodes['editmask'].Text;
        strTemp            := nodecomponent.ChildNodes['fieldname'].Text;
        FieldName          := strTemp;
        Name               := nodecomponent.ChildNodes['name'].Text;
        ReadOnly           := (nodecomponent.ChildNodes['readonly'].Text = '1');
        NullData           := (nodecomponent.ChildNodes['nulldata'].Text = '1');
        Top                := nodecomponent.ChildNodes['top'].NodeValue;
        Left               := nodecomponent.ChildNodes['left'].NodeValue;
        Width              := nodecomponent.ChildNodes['width'].NodeValue;
        Text               := DateToStr(now);
        DropDownCalendar.TodayLabelCaption := sHOJE+':';
        TextLabel.Visible  := (nodecomponent.ChildNodes['showcaption'].Text = '1');
        TextLabel.Caption  := nodecomponent.ChildNodes['caption'].Text;
        ListaTab.Add(nodecomponent.ChildNodes['width'].Text+'&'+nodecomponent.ChildNodes['name'].Text);
        if CamposBusca then  sCamposForm  := strTemp+', '+sCamposForm;
        AjustaTamanho(Top+height, Left+Width);
      end;
  end;


  procedure CriaCalcEdit(NodeComponent:IXMLNode; EditParent:TWidgetControl);
  var
    InmzDatePicker: TmzCalcEdit;
    strTemp : string;
  begin
      InmzDatePicker := TmzCalcEdit.Create(Self);
      InmzDatePicker.Parent := EditParent;
      with InmzDatePicker do begin
        Editmask           := nodecomponent.ChildNodes['editmask'].Text;
        strTemp            := nodecomponent.ChildNodes['fieldname'].Text;
        FieldName          := strTemp;
        Name               := nodecomponent.ChildNodes['name'].Text;
        ReadOnly           := (nodecomponent.ChildNodes['readonly'].Text = '1');
        NullData           := (nodecomponent.ChildNodes['nulldata'].Text = '1');
        Top                := nodecomponent.ChildNodes['top'].NodeValue;
        Left               := nodecomponent.ChildNodes['left'].NodeValue;
        Width              := nodecomponent.ChildNodes['width'].NodeValue;
        Text               := DateToStr(now);
        TextLabel.Visible  := (nodecomponent.ChildNodes['showcaption'].Text = '1');
        TextLabel.Caption  := nodecomponent.ChildNodes['caption'].Text;
        ListaTab.Add(nodecomponent.ChildNodes['width'].Text+'&'+nodecomponent.ChildNodes['name'].Text);
        if CamposBusca then sCamposForm  := strTemp+', '+sCamposForm;
        AjustaTamanho(Top+height, Left+Width);
      end;
  end;


  procedure CriaCheckBox(NodeComponent:IXMLNode; EditParent:TWidgetControl);
  var
    mzDBcheckBox: TmzDBcheckBox;
    strTemp : string;
  begin
      mzDBcheckBox := TmzDBcheckBox.Create(Self);
      mzDBcheckBox.Parent := EditParent;
      with mzDBcheckBox do begin
        strTemp            := nodecomponent.ChildNodes['fieldname'].Text;
        FieldName          := strTemp;
        Name               := nodecomponent.ChildNodes['name'].Text;
        Enabled            := not (nodecomponent.ChildNodes['readonly'].Text = '1');
        Top                := nodecomponent.ChildNodes['top'].NodeValue;
        Left               := nodecomponent.ChildNodes['left'].NodeValue;
        Width              := nodecomponent.ChildNodes['width'].NodeValue;
        Caption            := nodecomponent.ChildNodes['caption'].Text;

        ListaTab.Add(nodecomponent.ChildNodes['width'].Text+'&'+nodecomponent.ChildNodes['name'].Text);
        if CamposBusca then sCamposForm  := strTemp+', '+sCamposForm;
        ValueFalse := BOOLEAN_FALSE;
        Value      := BOOLEAN_FALSE;
        ValueTrue  := BOOLEAN_TRUE;
        AjustaTamanho(Top+height, Left+Width);
      end;
  end;

  procedure CriaDBLabel(NodeComponent:IXMLNode; LabelParent:TWidgetControl);
  var
    mzdbLabel : TmzdbLabel;
    strTemp, sNome : string;
  begin
      mzdbLabel := TmzdbLabel.Create(Self);
      mzdbLabel.Parent := LabelParent;
      sCodLabels := sCodLabels+IntToStr(mzdbLabel.ComponentIndex)+',';
      with mzdbLabel do begin
        sNome              := nodecomponent.ChildNodes['name'].Text;
        strTemp            := nodecomponent.ChildNodes['fieldname'].Text;
        Name               := sNome;
        Top                := nodecomponent.ChildNodes['top'].NodeValue;
        Left               := nodecomponent.ChildNodes['left'].NodeValue;
        Width              := nodecomponent.ChildNodes['width'].NodeValue;
        Query.CommaText    := nodecomponent.ChildNodes['sqlquery'].Text;
        MasterComponent    := nodecomponent.ChildNodes['componentname'].Text;
        Visible            := (nodecomponent.ChildNodes['visible'].NodeValue = 1);
        ParamName          := CAMPO_BUSCA;
        Caption            := '';
        SQLConnection      := frmPrincipal.SQLConnection1;
        ListaTab.Add(nodecomponent.ChildNodes['width'].Text+'&'+nodecomponent.ChildNodes['name'].Text);
        AjustaTamanho(Top+height, Left+Width+50);
      end;
  end;


  procedure CriaMemo(NodeComponent:IXMLNode; EditParent:TWidgetControl);
  var
    InMemo : TmzMemo;
    strTemp : string;
  begin
      InMemo := TmzMemo.Create(Self);
      InMemo.Parent := EditParent;
      with InMemo do begin
        strTemp           := nodecomponent.ChildNodes['fieldname'].Text;
        FieldName         := strTemp;
        Name              := nodecomponent.ChildNodes['name'].Text;
        ReadOnly          := (nodecomponent.ChildNodes['readonly'].Text = '1');
        Top               := nodecomponent.ChildNodes['top'].NodeValue;
        Left              := nodecomponent.ChildNodes['left'].NodeValue;
        Width             := nodecomponent.ChildNodes['width'].NodeValue;
        height            := nodecomponent.ChildNodes['height'].NodeValue;
        Text              := '';
        TextLabel.Visible := (nodecomponent.ChildNodes['showcaption'].Text = '1');
        TextLabel.Caption := nodecomponent.ChildNodes['caption'].Text;
        TabOrder          := nodecomponent.ChildNodes['taborder'].NodeValue;
        ScrollBars := ssVertical;
        ListaTab.Add(nodecomponent.ChildNodes['width'].Text+'&'+nodecomponent.ChildNodes['name'].Text);
        if CamposBusca then sCamposForm  := strTemp+', '+sCamposForm;
        AjustaTamanho(Top+height+30, Left+Width+10);
      end;
  end;


  procedure CriaConnectArray(const sConnection: String);

    function ContaVirgulas(Texto:String):integer;
    var
      n:Integer;
    begin
      result := 0;
      for n := 1 to Length(Texto) do
        if (Texto[n] = ',') then Result := Result+1
    end;

  var
    nItemsCount, N, nTemp : Integer;
    sTemp : String;
    ConnectionItem : TConnectItem;
  begin
    sTemp := trim(sConnection);
    setlength(ConnectArray, 0);
    nItemsCount := (ContaVirgulas(sConnection) div 4);

    for n := 0 to nItemsCount-1 do begin

      // Tabela Origem

      nTemp := pos(',', sTemp);
      ConnectionItem.sTabelaOrigem := trim(copy(sTemp, 0, nTemp-1));
      sTemp := trim(copy(sTemp, nTemp+1, Length(sTemp)));


      // Tabela Destino
      nTemp := pos(',', sTemp);
      ConnectionItem.sTabelaDestino := trim(copy(sTemp, 0, nTemp-1));
      sTemp := copy(sTemp, nTemp+1, Length(sTemp));


      // Campo Origem
      nTemp := pos(',', sTemp);
      ConnectionItem.sCampoOrigem := trim(copy(sTemp, 0, nTemp-1));
      sTemp := copy(sTemp, nTemp+1, Length(sTemp));


      // Campo Origem
      nTemp := pos(',', sTemp);
      ConnectionItem.sCampoDestino := trim(copy(sTemp, 0, nTemp-1));
      sTemp := copy(sTemp, nTemp+1, Length(sTemp));


      ConnectArray := AddConnectInArray(ConnectionItem, ConnectArray);
    end;

  end;


  procedure SetaMasterLabels;
  var
    sTemp : string;
    nTemp, nComp : Integer;
  begin
   nTemp := pos(',',sCodLabels);
   while (nTemp <> 0) do begin
     sTemp := copy(sCodLabels, 0, nTemp-1);
     nComp := StrToInt(copy(sCodLabels, 0, nTemp-1) );
     (Self.Components[nComp] as TmzdbLabel).SetMasterComponent;
     sCodLabels := copy(sCodLabels, nTemp+1, Length(sCodLabels));
     nTemp := pos(',',sCodLabels);
   end;

  end;

  procedure ApplicaTabOrder(Lista:TStrings);
  var
    nTemp, nTabOrder, n: integer;
    Component : TComponent;
    sTemp, sComponent : string;
  begin
    for n := 0 to Lista.count-1 do begin
      sTemp := Lista.Strings[n];
      nTemp := pos('&', sTemp);

      nTabOrder := strtoint( copy(sTemp, 0,nTemp-1) );
      sComponent := copy(sTemp, nTemp+1, length(sTemp)  );

      Component := FindComponent(sComponent);
      if component <> nil then  (component as TWinControl).TabOrder := nTabOrder;
    end;
  end;



  procedure AtualizaMenuRels(ListaRels:TStrings);
  var
   n: integer;
   Item : TMenuItem;
   sTemp : String;
  begin

    for n:= 0 to ListaRels.Count-1 do begin
      sTemp := ListaRels.strings[n];

      if trim(stemp) <> '' then begin
        // SubItem Principal
        Item := TMenuItem.Create(PopupRel);
        Item.Tag     := strtoint( copy(sTemp, 0, 4) );
        Item.Caption := copy(sTemp, 5, length(sTemp) );
        Item.ImageIndex := 1;
        Item.OnClick := ExibeRelClick;
        PopupRel.Items.Add(item);
      end;

    end;
  end;





    {$IFDEF codificado}
    function GetSerialNumber:String;

        function DecToHex( aValue : LongInt ) : String;
            function HexByte( b : Byte ) : String;
              const
                Hex : Array[ $0..$F ] Of Char = '0123456789ABCDEF';
            begin
                HexByte := Hex[ b Shr 4 ] + Hex[ b And $F ];
            end;

            function HexWord( w : Word ) : String;
            begin
                HexWord := HexByte( Hi( w ) ) + HexByte( Lo( w ) );
            end;

        var
            w : Array[ 1..2 ] Of Word Absolute aValue;
        begin
            Result := HexWord( w[ 2 ] ) + HexWord( w[ 1 ] );
        end;

    var
        VolumeLabel, FileSystem : Array[ 0..$FF ] Of Char;
        SerialNumber, Comps, SysFlags : cardinal;
    begin
       GetVolumeInformation( PChar( 'C:\' ), VolumeLabel, SizeOf( VolumeLabel ), @SerialNumber, Comps, SysFlags, FileSystem, SizeOf( FileSystem ) );
       Result := DecToHex( SerialNumber );
    end;


    function RetornaHashString(InArray: array of byte):String;
    var
      n : Integer;
      s : string ;
    begin
      for n := 0 to Length(InArray) - 1 do s := s + IntToHex(InArray[n],2);
      Result := s;
    end;

    {$ENDIF}


var
  n : Integer;
  NodeModule, nodecomponent, nodeform : Ixmlnode;
  sConnection, sDescodificado : String;
  ListaRels : TStringList;

{$IFDEF codificado}
{  Buffer: array of byte;
  sSerial: string;
  Digest: array[0..16] of byte;
  }
  //128 (MD5) bit div 8
{$ENDIF}

begin

  {$IFDEF corporate}
    Query.SQL.Text := ' select '+
                      '    sCampoEmpresa '+
                      ' from tbForm'+
                      ' where nIDForm = '+IntToStr(CodTela);
    if AbreQueryErro(mzQueryLoad) then exit;
    sCampoEmpresa := Query.FieldbyName('sCampoEmpresa').AsString;
  {$ENDIF}


  if (frmPrincipal.sNomeUsuario = 'ROOT') then begin
    bSalvar := True;
    bLocalizar := True;
    bExcluir := True;
  end
  else begin
    Query.SQL.Text := ' select  bSalvar , '+
                      '         bLocalizar, '+
                      '         bExcluir'+
                      ' from tbSeguranca, tbUsuario '+
                      ' where nIDForm = '+IntToStr(CodTela)+
                      {$IFDEF corporate}
                      ' and   tbUsuario.'+sCampoEmpresa+' =  '+sCodEmpresa+
                      ' and   tbSeguranca.nIDEmpresa = tbUsuario.'+sCampoEmpresa+
                      {$ENDIF}
                      ' and   tbSeguranca.nIDGrupo   = tbUsuario.nIDGrupo'+
                      ' and   tbUsuario.nIDUsuario = '+inttostr(frmPrincipal.nCodUsuario);

    if AbreQueryErro(mzCarregaAcesso) then Close;
    Query.First;

    bSalvar   := (Query.FieldByName('bSalvar').AsString   = 'Y');
    bLocalizar := (Query.FieldByName('bLocalizar').AsString = 'Y');
    bExcluir   := (Query.FieldByName('bExcluir').AsString   = 'Y');
  end;

  Tabelas := TStringList.Create;
  with Query do begin
     SQL.Text := ' select '+
                      ' sTitulo, '+
                      ' sNomeTabelas, '+
                      ' sCampos, '+
                      ' sBusca , '+
                      ' sConnection, '+
                      ' sCampoChave, '+
                      ' sQueryChave'+

                 ' from tbForm'+
                 ' where nIDForm = '+IntToStr(CodTela);

     if AbreQueryErro(mzQueryLoad) then exit;

     Self.Caption          := FieldbyName('sTitulo').AsString;
     Tabelas.Text          := FieldbyName('sNomeTabelas').AsString;
     sConsulta             := FieldbyName('sBusca').AsString;
     {$IFDEF codificado}
{       sSerial:= GetSerialNumber;
       DCP_md5.Init;
       DCP_md5.Update(Buffer,Sizeof(Buffer));
       DCP_md5.UpdateStr(sSerial);
       DCP_md5.Final(Digest);
       sSerial := RetornaHashString(Digest); }
       sDescodificado := frmPrincipal.Descodificar2(FieldbyName('sCampos').AsString, GetSerialNumber);
       XMLDocument1.XML.Text := sDescodificado;
     {$ENDIF}

     {$IFDEF naocodificado}
       XMLDocument1.XML.Text := FieldbyName('sCampos').AsString;
     {$ENDIF}


     sConnection           := FieldbyName('sConnection').AsString;
     CampoChave.Text       := trim(FieldbyName('sCampoChave').AsString);
     sConsultaChave        := FieldbyName('sQueryChave').AsString;
     CriaConnectArray(sConnection+',');
  end;
  XMLDocument1.Active := True;
  NodeModule := XMLDocument1.ChildNodes['module'];

  ListaTab := TStringList.Create;

  CamposBusca := True;
  nodeform := NodeModule.ChildNodes['form'];
  for n := 0 to nodeform.ChildNodes.Count-1 do begin
    nodecomponent := nodeform.ChildNodes[n];
    if (nodecomponent.ChildNodes['type'].Text = 'TNumEditCLX')      then CriaNumEdit(nodecomponent, TabSheetDetalhes);
    if (nodecomponent.ChildNodes['type'].Text = 'TmzDBComboBoxClx') then CriaComboBox(nodecomponent, TabSheetDetalhes);
    if (nodecomponent.ChildNodes['type'].Text = 'TDbGrid')          then CriaDbGrid(nodecomponent, TabSheetDetalhes);
    if (nodecomponent.ChildNodes['type'].Text = 'TBtnQueryEdit')    then CriabtnQueryEdit(nodecomponent, TabSheetDetalhes);
    if (nodecomponent.ChildNodes['type'].Text = 'TmzDatePicker')    then CriaDatePicker(nodecomponent, TabSheetDetalhes);
    if (nodecomponent.ChildNodes['type'].Text = 'TmzCalcEdit')      then CriaCalcEdit(nodecomponent, TabSheetDetalhes);
    if (nodecomponent.ChildNodes['type'].Text = 'TmzDBcheckBox')    then CriaCheckBox(nodecomponent, TabSheetDetalhes);
    if (nodecomponent.ChildNodes['type'].Text = 'TmzdbLabel')       then CriaDBLabel(nodecomponent, TabSheetDetalhes);
    if (nodecomponent.ChildNodes['type'].Text = 'TmzdbMemo')        then CriaMemo(nodecomponent, TabSheetDetalhes);
  end;

  sCamposForm := trim(sCamposForm);
  sCamposForm[Length(sCamposForm)] := ' ';

  CamposBusca := False;
  nodeform := NodeModule.ChildNodes['query'];
  PageControl1.ActivePage := TabSheetBrowser;
  for n := 0 to nodeform.ChildNodes.Count-1 do begin
    nodecomponent := nodeform.ChildNodes[n];
    if (nodecomponent.ChildNodes['type'].Text = 'TNumEditCLX')      then CriaNumEdit(nodecomponent, PanelBrowser);
    if (nodecomponent.ChildNodes['type'].Text = 'TmzDBComboBoxClx') then CriaComboBox(nodecomponent, PanelBrowser);
    if (nodecomponent.ChildNodes['type'].Text = 'TBtnQueryEdit')    then CriabtnQueryEdit(nodecomponent, PanelBrowser);
    if (nodecomponent.ChildNodes['type'].Text = 'TmzDatePicker')    then CriaDatePicker(nodecomponent, PanelBrowser);
    if (nodecomponent.ChildNodes['type'].Text = 'TmzCalcEdit')      then CriaCalcEdit(nodecomponent, PanelBrowser);
    if (nodecomponent.ChildNodes['type'].Text = 'TmzDBcheckBox')    then CriaCheckBox(nodecomponent, PanelBrowser);
    if (nodecomponent.ChildNodes['type'].Text = 'TmzdbLabel')       then CriaDBLabel(nodecomponent, PanelBrowser);
  end;

  SetaMasterLabels;
  ApplicaTabOrder(ListaTab);
  ListaTab.Destroy;


  // Carrega Relatorios
  ListaRels := TStringList.Create;
  ListaRels.Text := NodeModule.ChildNodes['rels'].Text;
  AtualizaMenuRels(ListaRels);

  ActImprimir.Enabled := not ( trim(ListaRels.Text) = ''  );

  ListaRels.Destroy;


  Height := nMinHeight;
  Width := nMinWidth;

  if Constraints.MinHeight < nMinHeight then Constraints.MinHeight := nMinHeight;
  if Constraints.MinWidth  < nMinWidth then Constraints.MinWidth := nMinWidth;




{ with SQLDataSetBusca do begin

    ClientDataSetBusca.Active := False;
    ClientDataSetBusca.FieldDefs.Clear;
    Close;
    Params.Clear;
    CommandText := sConsulta+' 0 = 1 ';
    Open;
    ClientDataSetBusca.Active := True;
  end;
 }

 //Se o campo ID não for preenchido, ele pega a primeira coluna como ID
 // SQLDataSet1.CommandText := sBusca;
 //SQLDataSet1.Params['']


{ Query.SQL.Text := concat('select * from ', Tabelas.Strings[0], ' where 1 = 0');
 if AbreQueryErro(mzQueryLoad) then exit;
 CampoID := Query.Fields[0].FieldName;
 Query.Close; }
end;


procedure TtbPadrao.Cancelar;
var
  n, n2:Integer;
  InkbmMemTable : TkbmMemTable;
  strTemp : string;
begin
 with self do
   for n := 0 to ComponentCount -1 do begin
        if (Components[n] is TPanel)        then  (Components[n] as TPanel).Caption := '';
        if (Components[n] is TPageControl)  then  (Components[n] as TPageControl).ActivePageIndex := 0;

        if (Components[n] is TWidgetControl) then
           if ( (Components[n] as TWidgetControl).Parent = TabSheetDetalhes) then begin
              if (Components[n] is TCustomMaskEdit)   then (Components[n] as TCustomMaskEdit).Clear;
              if (Components[n] is TCustomComboBox)   then  (Components[n] as TCustomComboBox).ItemIndex := 0;
              if (Components[n] is TmzDatePicker)     then  (Components[n] as TmzDatePicker).Text := DateToStr(now);
              if (Components[n] is TmzMemo)           then  (Components[n] as TmzMemo).Clear;
              if (Components[n] is TmzDBCheckBox)     then  (Components[n] as TmzDBCheckBox).Checked := False;
              if (Components[n] is TmzDbLabel)        then
                 if (  (Components[n] as TmzDbLabel).MasterComponent <> '[none]' )  and  ( (Components[n] as TmzDbLabel).MasterComponent <> '')  then
                    (Components[n] as TmzDbLabel).Caption := ''
                 else
                    (Components[n] as TmzDbLabel).Caption := stringreplace( (Components[n] as TmzDbLabel).Query.CommaText, '"', '', [rfReplaceAll, rfIgnoreCase]);
           end;

        if (Components[n] is TkbmMemTable)  then begin
           InkbmMemTable := (Components[n] as TkbmMemTable);
           InkbmMemTable.Open;
           InkbmMemTable.Last;
           for n2 := InkbmMemTable.RecordCount-1 downto 0 do  InkbmMemTable.delete;
           InkbmMemTable.ResetAutoInc;
        end;

   end; // for componentes

  Alterando:= False;
  with QueryAux do begin
    Sql.Text := sConsultaChave;
    Open;
    CodigoAtual.Clear;
  end;

  strTemp := sConsulta+' 0 = 1 ';
  {$IFDEF corporate}
     if (sCampoEmpresa <> '') then
        strTemp := strTemp+' and '+Tabelas.Strings[0]+'.'+sCampoEmpresa+' = '+sCodEmpresa;
  {$ENDIF}

 with SQLQueryBusca do begin
    Close;
    FieldDefs.Clear;
    Params.Clear;
    SQL.Text := strTemp;
    Open;
  end;
  ClientDataSetBusca.Open;

  ActExcluir.Enabled := False;
end;

procedure TtbPadrao.PreencheDados;

  procedure CarregaGrid(Grid:TmzDBGrid);
   function RetornaJoin(Tabela:String):String;
   var
     n1, n2 : Integer;
   begin
     Result := '';
     for n1 := 0 to CampoChave.Count-1 do begin
         for n2 := 0 to length(ConnectArray)-1 do begin
           if (ConnectArray[n2].sTabelaOrigem+'.'+ConnectArray[n2].sCampoOrigem = trim(CampoChave.Strings[n1])) then begin
                 Result := Result + ConnectArray[n2].sCampoDestino + ' = ' + CodigoAtual.Strings[n1];
                 exit;
           end;

           if (ConnectArray[n2].sTabelaDestino+'.'+ConnectArray[n2].sCampoDestino = trim(CampoChave.Strings[n1])) then begin
               Result := Result + ConnectArray[n2].sCampoOrigem  + ' = ' + CodigoAtual.Strings[n1];
               exit;
           end;

         end;
     end;
   end;


  var
    n1, n2, n3 : Integer;
    InkbmMemTable : TkbmMemTable;
    sTemp : String;
  begin
      sTemp := ' select * '+
                ' from '+Grid.TableName+
                ' where '+RetornaJoin(Grid.TableName)+
                {$IFDEF corporate}
                ' and '+sCampoEmpresa+' = '+sCodEmpresa+
                {$ENDIF}
                ' ';
      with QueryAux do begin
        SQL.Text := sTemp;
        Open;
      end;

      InkbmMemTable := (Grid.DataSource.DataSet as TkbmMemTable);
      for n1 := QueryAux.RecordCount-1 downto 0 do begin
        InkbmMemTable.Insert;

        for n2 := 0 to QueryAux.Fields.Count-1 do
          for n3 := 0 to InkbmMemTable.Fields.Count-1 do
            if (QueryAux.Fields[n2].FieldName = InkbmMemTable.Fields[n3].FieldName) then
               if QueryAux.Fields[n2].DataType in [ftDate, ftDateTime] then
                InkbmMemTable.Fields[n3].AsDateTime := StrToDate(QueryAux.Fields[n2].Text)
               else
                InkbmMemTable.Fields[n3].Value := QueryAux.Fields[n2].Value;

        InkbmMemTable.Post;
        QueryAux.Next;
      end;

  end;

  function ObtemCampo(Campo:String):String;
  var
    strFieldName : string;
  begin
    strFieldName := copy(Campo, pos('.', Campo)+1, Length(Campo) );
    Result := Query.FieldByName(strFieldName).AsString;
  end;

var
 N :Integer;
 InCodigo : TStringList;
begin
  InCodigo := TStringList.Create;
  InCodigo.Text := CodigoAtual.Text;
  Cancelar;
  CodigoAtual.Text := InCodigo.Text;

  for N := 0 to Self.ComponentCount -1 do begin
    try
     if (Self.Components[N] is TNumEditCLX) then
       with (Self.Components[N] as TNumEditCLX) do
         if ( Parent <> PanelBrowser ) then Text := ObtemCampo(FieldName);

     if (Self.Components[N] is TmzDBComboBoxClx) then
       with (Self.Components[N] as TmzDBComboBoxClx) do
          if ( Parent <> PanelBrowser ) then ValueIndex := StrToInt( ObtemCampo(FieldName) );

     if (Self.Components[N] is TmzBtnQueryEditclx) then
       with (Self.Components[N] as TmzBtnQueryEditclx) do
         if ( Parent <> PanelBrowser ) then Text := ObtemCampo(FieldName);

     if (Self.Components[N] is TmzDatePicker) then
       with (Self.Components[N] as TmzDatePicker) do
         if ( Parent <> PanelBrowser ) then begin
            Date := StrToDate(    copy(ObtemCampo(FieldName), 0, 10)  );
            Text := ObtemCampo(FieldName);
         end;

     if (Self.Components[N] is TmzCalcEdit) then
       with (Self.Components[N] as TmzCalcEdit) do
         if ( Parent <> PanelBrowser ) then Text := ObtemCampo(FieldName);


     if (Self.Components[N] is TmzDBcheckBox) then
       with (Self.Components[N] as TmzDBcheckBox) do
         if ( Parent <> PanelBrowser ) then Checked := ( ObtemCampo(FieldName) = 'T');

     if (Self.Components[N] is TmzMemo) then
       with (Self.Components[N] as TmzMemo) do
         if ( Parent <> PanelBrowser ) then Lines.Text := ObtemCampo(FieldName);


     if (Self.Components[n] is TmzDBGrid) then
       if ( (Self.Components[n] as TmzDBGrid).Parent <> TabSheetBrowser) then CarregaGrid(Self.Components[N] as TmzDBGrid);

     except
     end;
  end;

  Alterando:= True;
  ActExcluir.Enabled := True;
end;

procedure TtbPadrao.Localizar;
var
  n : Integer;
  CamposPar, DadosPar: TArSTR;
  sCampo, strTemp, sConsultaCampos  : String;
begin

  if not bLocalizar then begin
    ShowMessage(ErroAcesso);
    exit;
  end;


  setlength(CamposPar, 0);
  setlength(DadosPar, 0);
  sConsultaCampos  := '';

  PageControl1.ActivePage := TabSheetBrowser;
  for n := 0 to Self.ComponentCount -1 do begin
      if (Self.Components[n] is TNumEditCLX) then
           with (Self.Components[n] as TNumEditCLX) do
              if ( Parent = PanelBrowser ) then
                 if not IsEmpty then begin
                    strTemp   := FieldName;
                    sCampo    := strTemp;
                    case NumberType of
                      mzString  : begin
                                    CamposPar := AddInArray(CamposPar, sCampo);
                                    DadosPar :=  AddInArray(DadosPar, VirgulaPraPonto(Text));
                                    sConsultaCampos  := concat( sConsultaCampos, strTemp, ' like ', SQL_PARM,sCampo+ '  and ' );
                                  end;

                      mzInteger : begin
                                    sConsultaCampos  := concat( sConsultaCampos, strTemp, ' = ', Text, '  and ' );
                                  end;

                      mzFloat   : begin
                                    CamposPar := AddInArray(CamposPar, sCampo);
                                    DadosPar :=  AddInArray(DadosPar, VirgulaPraPonto(Text));
                                    sConsultaCampos  := concat( sConsultaCampos, strTemp , ' = ', SQL_PARM,sCampo, '  and ' );
                                  end;
                    end;
                  end;

      if (Self.Components[n] is TmzDBComboBoxClx) then
           with (Self.Components[n] as TmzDBComboBoxClx) do
              if ( Parent = PanelBrowser ) then begin
                  strTemp   := FieldName;
                  sConsultaCampos  := concat( sConsultaCampos, strTemp , ' = ', IntToStr(ValueIndex), '  and ' );
              end;

     if (Self.Components[N] is TmzDatePicker) then
       with (Self.Components[N] as TmzDatePicker) do
              if ( Parent = PanelBrowser ) then begin
                  strTemp   := FieldName;
                  sConsultaCampos  := concat( sConsultaCampos, strTemp , ' = ', S_AP, Text, S_AP, '  and ' );
              end;



  end; // For

  ClientDataSetBusca.Active := False;
  ClientDataSetBusca.Params.Clear;
  ClientDataSetBusca.Close;

  strTemp := sConsulta+' '+sConsultaCampos+' 1 = 1 ';
  {$IFDEF corporate}
     if (sCampoEmpresa <> '') then strTemp := strTemp+' and '+Tabelas.Strings[0]+'.'+sCampoEmpresa+' = '+sCodEmpresa;
  {$ENDIF}

 with SQLQueryBusca do begin
    Close;
    FieldDefs.Clear;
    Params.Clear;
    SQL.Text := strTemp;
    for N := 0 to length(CamposPar)-1 do begin
        Params[N].Name     := CamposPar[N];
        Params[N].AsString := DadosPar[N];
    end;
    Open;
  end;
  ClientDataSetBusca.Open;
end;



procedure TtbPadrao.DBGridBuscaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  n1, n2 : Integer;
  ListaTemp : TStringlist;
begin
  if (Key <> RETUNR_KEY) and (Key <> RETUNR_KEY2) then exit;
  ListaTemp  := TStringlist.Create;
  for n1 := 0 to CampoChave.Count-1 do
    for n2 := 0 to DBGridBusca.FieldCount-1 do
     if (DBGridBusca.Fields[n2].FieldName = CampoChave.Strings[n1]) then  ListaTemp.Add(DBGridBusca.Fields[n2].AsString);

   ExecutaBusca(ListaTemp);
   ListaTemp.Destroy;
end;



procedure TtbPadrao.ActNovoExecute(Sender: TObject);
begin
  Cancelar;
  Alterando:= False;
end;

procedure TtbPadrao.ActSalvarExecute(Sender: TObject);
begin
 Salvar;
end;

procedure TtbPadrao.ActExcluirExecute(Sender: TObject);
begin
   Excluir;
end;

procedure TtbPadrao.ActLocalizarExecute(Sender: TObject);
begin
 Localizar;
end;

procedure TtbPadrao.ActFecharExecute(Sender: TObject);
begin
 Close;
end;


procedure TtbPadrao.ActImprimirExecute(Sender: TObject);
var
  MyPoint1, MyPoint2: TPoint;
begin
  MyPoint1.X := 0;
  MyPoint1.Y := btnImprimir.Height;
  MyPoint2 := btnImprimir.ClientToScreen(MyPoint1);
  PopupRel.Popup(MyPoint2.X,  MyPoint2.Y);
end;

procedure TtbPadrao.ExibeRelClick(Sender: TObject);
    function ComZero(num: integer):string;
    var
      s: string;
    begin
      s := IntToStr(Num);
      if Num < 10 then s := '0'+s;
      if Num < 100 then s := '0'+s;
      if Num < 1000 then s := '0'+s;

      Result := s;
    end;


var
  sTemp : String;
  n : integer;
begin
  sTemp := RemoveChar( (sender as TMenuItem).Caption, '&');

  CLXReport1.ReportName :=  sTemp;
  CLXReport1.Title := sTemp;

  sTemp := frmPrincipal.Caminho+CaminhoRel+ ComZero(  (sender as TMenuItem).Tag )  +'.rep';
  CLXReport1.Filename := sTemp;


  for n := 0 to CLXReport1.Report.Params.Count-1 do
    if n <= CodigoAtual.Count-1 then
      CLXReport1.Report.Params[n].AsString := CodigoAtual.Strings[n];

  CLXReport1.Execute;
end;


procedure TtbPadrao.FormResize(Sender: TObject);
begin
    if Width < nMinWidth    then Width  := nMinWidth;
    if Height < nMinHeight  then Height := nMinHeight;
end;

end.
