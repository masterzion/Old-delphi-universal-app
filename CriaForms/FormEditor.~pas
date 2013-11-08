unit FormEditor;

{$include configura.inc}

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, Principal, QComCtrls, QExtCtrls, QGrids, mzlib,
  QMask, FMTBcd, DB, SqlExpr, xmldom, XMLIntf, xercesxmldom,
  XMLDoc, QDBGrids, DBClient, Provider, oxmldom, mzDBgrid, mzDBComboBoxClx,
  mzComboBoxClx, QMenus, kbmMemTable, mzCustomEdit, mzCustomBtnEditclx,
  mzBtnQueryEditclx, mzNumEditclx, mzMemoCLX, mzDatePicker, mzCalcEdit,
  mzDBCheckBox, mzDBLabel, DBLabelEditor, rpmdesigner;


type
  TfrmFormEditor = class(TForm)
    ToolBar1: TToolBar;
    btnSalvar: TToolButton;
    PageControl1: TPageControl;
    TabSheetForm: TTabSheet;
    TabSheetBrowser: TTabSheet;
    MemoQuery: TMemo;
    PanelForm: TPanel;
    XMLDocument1: TXMLDocument;
    Splitter4: TSplitter;
    PanelQuery: TPanel;
    btnSair: TToolButton;
    ToolButton3: TToolButton;
    ToolBar2: TToolBar;
    btnNone: TToolButton;
    btnInt: TToolButton;
    btnText: TToolButton;
    btnCombo: TToolButton;
    btnFloat: TToolButton;
    btnGrid: TToolButton;
    PopupMenuComum: TPopupMenu;
    Properties1: TMenuItem;
    Delete1: TMenuItem;
    QueryAux: TSQLQuery;
    btnBtnQueryEdit: TToolButton;
    SQLDataSet1: TSQLDataSet;
    btnDatePicker: TToolButton;
    btnCalcEdit: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton1: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    btnLabel: TToolButton;
    btnCheck: TToolButton;
    btnRel: TToolButton;
    PopupRel: TPopupMenu;
    ToolButton8: TToolButton;
    N1: TMenuItem;
    Adicionar1: TMenuItem;
    PopupOpcoes: TPopupMenu;
    OrdemdeTab1: TMenuItem;
    RpDesigner1: TRpDesigner;
    btnMemo: TToolButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    // Eventos Edit
    procedure Edit1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
    procedure Edit1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
    procedure Edit1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);

    // Eventos Memo
  procedure MemoMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
  procedure MemoMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
  procedure MemoMouseUp(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);

    // Eventos Grid
    procedure GridMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);


    procedure btnSalvarClick(Sender: TObject);
    procedure btnNoneClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSairClick(Sender: TObject);
    procedure PanelFormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Properties1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure mzDbgrid1CellClick(Column: TColumn);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton7Click(Sender: TObject);
    procedure btnRelClick(Sender: TObject);
    procedure OrdemdeTab1Click(Sender: TObject);
    procedure Adicionar1Click(Sender: TObject);
    procedure EditaRelClick(Sender: TObject);
    procedure ApagaRelClick(Sender: TObject);
  private
   { Private declarations }
   ConnectArray                     : TConnectArray;
   ListaArray                       : TListArray;
   Objeto                           : TObject;
   ListaTabelas, ListaRels, ListaTab: TStringList;
   MouseCenterTop, MouseCenter, MouseDown           : Boolean;
   sCamposForm, CamposChave, sConsultaChave,  sComponentButton  : String;
   nCodTela                         : Integer;
   bNovo : Boolean;
   procedure ApagaForm;
   function ComZero(num: integer):string;
  public
    { Public declarations }
    CamposBusca    : Boolean;
{$IFDEF corporate}
   sCampoEmpresa                    : string;
{$ENDIF}
    procedure SetVars(InListaTabelas : TStringList; InListaArray: TListArray; InConnectArray : TConnectArray; InCampoChave, Consulta : String);
    function  RetornaNomeComponente(Nome:String):String;
    procedure CarregaForm(CodTela:Integer);
    procedure ApplicaTabOrder(Lista:TStrings);
    procedure AtualizaMenuRels;
    procedure ApagaRel(Arquivo:integer);
  end;

var
  frmFormEditor: TfrmFormEditor;

implementation
uses DBGridEditor, NumEditEditor, ComboBoxEditor, btnNumEditEditor, TabEditor;

{$R *.xfm}

procedure TfrmFormEditor.ApagaRel(Arquivo:integer);
var
  sArquivo, sNome : string;
  n : integer;
  f: file;
begin
  sNome := ComZero(  Arquivo ) ;
  sArquivo := frmPrincipal.AppPath+CaminhoRel+ sNome +'.rep';

  for n := ListaRels.Count-1 downto 0 do
   if copy(ListaRels.Strings[n], 0, 4) =  sNome then  ListaRels.Delete(n);

  AssignFile(f, sArquivo);
  Erase(f);
end;


procedure TfrmFormEditor.AtualizaMenuRels;
var
 n: integer;
 Item, SubItem, SubItemAbre : TMenuItem;
 sTemp : String;
begin
  // Remove items
  for n:= PopupRel.Items.Count-1 downto 0 do
    if PopupRel.Items[n].Tag <> 0 then PopupRel.Items.Delete(n);

  for n:= 0 to ListaRels.Count-1 do begin
    sTemp := ListaRels.strings[n];

    if trim(stemp) <> '' then begin
      // SubItem Principal
      Item := TMenuItem.Create(PopupRel);
      Item.Tag     := strtoint( copy(sTemp, 0, 4) );
      Item.Caption := copy(sTemp, 5, length(sTemp) );
      Item.ImageIndex := 32;


      // SubItem Editar
      SubItemAbre := TMenuItem.Create(Item);
      SubItemAbre.Caption := constEditar;
      SubItemAbre.ImageIndex := 16;
      SubItemAbre.OnClick := EditaRelClick;


      // SubItem Apagar
      SubItem := TMenuItem.Create(Item);
      SubItem.Caption := constExcluir;
      SubItem.ImageIndex := 7;
      SubItem.OnClick := ApagaRelClick;


      Item.Add(SubItemAbre);
      Item.Add(SubItem);

      PopupRel.Items.Add(item);
    end;
  end;
end;



function TfrmFormEditor.ComZero(num: integer):string;
var
  s: string;
begin
  s := IntToStr(Num);
  if Num < 10 then s := '0'+s;
  if Num < 100 then s := '0'+s;
  if Num < 1000 then s := '0'+s;

  Result := s;
end;




procedure TfrmFormEditor.ApplicaTabOrder(Lista:TStrings);
var
  n: integer;
  Component : TComponent;
begin
  for n := 0 to Lista.count-1 do begin
    Component := FindComponent(Lista.Strings[n]);
    if component <> nil then  (component as TWinControl).TabOrder := n;
  end;
end;



procedure TfrmFormEditor.ApagaForm;
begin
  with frmPrincipal.DataSet do begin
    Close;
    CommandText := ' delete from tbForm where nIDForm = '+IntToStr(nCodTela);
    ExecSql;
  end;
end;



// *************** Cria Componentes  ***************
procedure TfrmFormEditor.btnNoneClick(Sender: TObject);
var
 n : Integer;
 ToolBar    : TToolBar;
 ToolButton : TToolButton;
begin
 if not (Sender is TToolButton) then exit;
 ToolButton := (Sender as TToolButton);
 ToolBar    := ToolButton.Toolbar;

 for n := 0 to ToolBar.ControlCount-1 do
   if (ToolBar.Controls[n] is TToolButton) then
     (ToolBar.Controls[n] as TToolButton).Down := False;

 ToolButton.Down := True;
 sComponentButton := ToolButton.Name ;
end;


function TfrmFormEditor.RetornaNomeComponente(Nome:String):String;
  function RemoveInvalidChars(NomeCampo:String):String;
  var
   TempStr:String;
   n : Integer;
   ch : Char;
  begin
   TempStr := NomeCampo;
   for n := 1 to length(TempStr) do begin
     ch := TempStr[n];
     if (Ord(ch) < 65) or (Ord(ch) > 122) then ch := '_';
     if (Ord(ch) > 90) and (Ord(ch) < 97) then ch := '_';
     TempStr[n] := ch;
   end;
   Result := TempStr;
  end;

  function ProcuraNome(NomeComponent : String):string;
  var
    Contagem : Integer;
    NomeAtual : String;
    bExiste   : Boolean;
  begin
   Contagem := 0;

   bExiste := True;
   NomeAtual := NomeComponent;
   while bExiste do begin
     if Contagem > 0 then NomeAtual := NomeComponent+IntToStr(Contagem);
     Contagem := Contagem + 1;
     bExiste := (Self.FindComponent(NomeAtual) <> nil)
    end;
    Result := NomeAtual;
  end;
begin
   Result := ProcuraNome(RemoveInvalidChars(Nome));
end;

procedure TfrmFormEditor.PanelFormMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

    // *** Cria DBGrid ***
    procedure CriaDbGrid(ParentComponent : TWidgetControl; X, Y : Integer);
    var
      InDbGrid                : TmzDbgrid;
      InDataSource            : TDataSource;
      InSQLDataSet            : TSQLDataSet;
      InkbmMemTable           : TkbmMemTable;
      PanelPai, PanelControle : TPanel;
      n                       : Integer;
    begin

       // Acesso ao banco
       InkbmMemTable             := TkbmMemTable.Create(Self);
       InkbmMemTable.Name        := RetornaNomeComponente('kbmMemTable');

       InDataSource := TDataSource.Create(Self);
       InDataSource.DataSet := InkbmMemTable;


       // Panels
       PanelPai := TPanel.Create(Self);
       with PanelPai do begin
        Parent  := ParentComponent;
        Caption := '';
        Height  := 150;
        OnMouseDown   := MemoMouseDown;
        OnMouseUp     := MemoMouseUp;
        OnMouseMove   := MemoMouseMove;
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

       // DBGrid
       InDbGrid := TmzDbgrid.Create(Self);
       with InDbGrid do begin
        Parent        := PanelPai;
        ReadOnly      := True;
        Align         := alClient;
        BorderStyle   := bsNone;
        DataSource    := InDataSource;
        Name          := RetornaNomeComponente('Grid');
        Options       := [dgEditing,dgTitles,dgIndicator,dgColumnResize,dgRowLines,dgTabs,dgConfirmDelete,dgCancelOnExit];
        SQLDataSet    := InSQLDataSet;
        for n := 0 to InDbGrid.Columns.Count-1 do InDbGrid.Columns[n].Title.Font.Color := clBlue;
        PopupMenu     := PopupMenuComum;
        OnMouseDown   := Edit1MouseDown;
        OnMouseUp     := Edit1MouseUp;
        OnMouseMove   := GridMouseMove;
        OnCellClick  := mzDbgrid1CellClick;
       end;
    end;



    // *** Cria Combo ***
    procedure CriaDbCombo(ParentComponent : TWidgetControl; X, Y : Integer);
    var
      InComboBox : TmzDbComboBoxClx;
    begin
      InComboBox := TmzDbComboBoxClx.Create(Self);
      with InComboBox do begin
        Parent        := ParentComponent;
        SQLConnection := frmPrincipal.SQLConnection1;
        Style         := csOwnerDrawFixed;
        Name          := RetornaNomeComponente('cmb');
        Top           := Y-(height div 2);
        Left          := X-(Width div 2);
        if Top < 20   then Top := 20;
        if Left < 5   then Left := 5;
        PopupMenu     := PopupMenuComum;
        OnMouseDown   := Edit1MouseDown;
        OnMouseUp     := Edit1MouseUp;
        OnMouseMove   := Edit1MouseMove;
      end;
    end;


    // *** Cria Edit ***
    procedure CriaNumEdit(ParentComponent : TWidgetControl; Tipo : TTipoNumero; X, Y : Integer);
    var
      InEdit : TNumEditCLX;
    begin
      InEdit := TNumEditCLX.Create(Self);
      with InEdit do begin
        Parent := ParentComponent;
        ReadOnly := False;
        NullData := False;
        AutoSize     := True;
        ReadOnly     := False;
        PopupMenu    := PopupMenuComum;
        Name         := RetornaNomeComponente('edt');
        NumberType   := Tipo;
        Text         := Name;
        Top          := Y-(height div 2);
        Left         := X-(Width div 2);
        if Top < 20   then Top := 20;
        if Left < 5   then Left := 5;
        OnMouseDown  := Edit1MouseDown;
        OnMouseUp    := Edit1MouseUp;
        OnMouseMove  := Edit1MouseMove;
      end;
    end;

    // *** Query Edit ***
    procedure  CriaQueryEdit(ParentComponent : TWidgetControl; X, Y : Integer);
    var
     InmzBtnQueryEditclx: TmzBtnQueryEditclx;
    begin
      InmzBtnQueryEditclx := TmzBtnQueryEditclx.Create(Self);
      with InmzBtnQueryEditclx do begin
        Parent        := ParentComponent;
        SQLConnection := frmPrincipal.SQLConnection1;
        PopupMenu     := PopupMenuComum;
        Name          := RetornaNomeComponente('qedt');
        Top           := Y-(height div 2);
        Left          := X-(Width div 2);
        if Top < 20   then Top := 20;
        if Left < 5   then Left := 5;
        OnMouseDown   := Edit1MouseDown;
        OnMouseUp     := Edit1MouseUp;
        OnMouseMove   := Edit1MouseMove;
      end;
    end;

    // *** Date Picker ***
    procedure  CriaDatePicker(ParentComponent : TWidgetControl; X, Y : Integer);
    var
     InmzDatePicker: TmzDatePicker;
    begin
      InmzDatePicker := TmzDatePicker.Create(Self);
      with InmzDatePicker do begin
        Parent        := ParentComponent;
        PopupMenu     := PopupMenuComum;
        Name          := RetornaNomeComponente('dt');
        Top           := Y-(height div 2);
        Left          := X-(Width div 2);
        if Top < 20   then Top := 20;
        if Left < 5   then Left := 5;
        OnMouseDown   := Edit1MouseDown;
        OnMouseUp     := Edit1MouseUp;
        OnMouseMove   := Edit1MouseMove;
      end;
    end;

    // *** CalcEdit ***
    procedure  CriaCalcEdit(ParentComponent : TWidgetControl; X, Y : Integer);
    var
     InmzDatePicker: TmzCalcEdit;
    begin
      InmzDatePicker := TmzCalcEdit.Create(Self);
      with InmzDatePicker do begin
        Parent        := ParentComponent;
        PopupMenu     := PopupMenuComum;
        Name          := RetornaNomeComponente('edtcalc');
        Top           := Y-(height div 2);
        Left          := X-(Width div 2);
        if Top < 20   then Top := 20;
        if Left < 5   then Left := 5;
        OnMouseDown   := Edit1MouseDown;
        OnMouseUp     := Edit1MouseUp;
        OnMouseMove   := Edit1MouseMove;
      end;
    end;

    // *** CheckBox ***
    procedure  CriaCheck(ParentComponent : TWidgetControl; X, Y : Integer);
    var
     mzDBCheckBox : TmzDBCheckBox;
    begin
      mzDBCheckBox := TmzDBCheckBox.Create(Self);
      with mzDBCheckBox do begin
        Parent        := ParentComponent;
        PopupMenu     := PopupMenuComum;
        Name          := RetornaNomeComponente('chk');
        Top           := Y-(height div 2);
        Left          := X-(Width div 2);
        if Top < 20   then Top := 20;
        if Left < 5   then Left := 5;
        OnMouseDown   := Edit1MouseDown;
        OnMouseUp     := Edit1MouseUp;
        OnMouseMove   := Edit1MouseMove;
      end;
    end;


    // *** Label ***
    procedure  CriaLabel(ParentComponent : TWidgetControl; X, Y : Integer);
    var
     mzdbLabel: TmzdbLabel;
    begin
      mzdbLabel := TmzdbLabel.Create(Self);
      with mzdbLabel do begin
        Parent        := ParentComponent;
        PopupMenu     := PopupMenuComum;
        Name          := RetornaNomeComponente('Label');
        Top           := Y-(height div 2);
        Left          := X-(Width div 2);
        if Top < 20   then Top := 20;
        if Left < 5   then Left := 5;
        OnMouseDown   := Edit1MouseDown;
        OnMouseUp     := Edit1MouseUp;
        OnMouseMove   := Edit1MouseMove;
      end;
    end;

    // *** Memo ***
    procedure  CriaMemo(ParentComponent : TWidgetControl; X, Y : Integer);
    var
     mzMemo: TmzMemo;
    begin
      mzMemo := TmzMemo.Create(Self);
      with mzMemo do begin
        Parent        := ParentComponent;
        PopupMenu     := PopupMenuComum;
        Name          := RetornaNomeComponente('memo');
        Top           := Y-(height div 2);
        Left          := X-(Width div 2);
        if Top < 20   then Top := 20;
        if Left < 5   then Left := 5;
        ScrollBars := ssVertical;
        OnMouseDown   := MemoMouseDown;
        OnMouseUp     := MemoMouseUp;
        OnMouseMove   := MemoMouseMove;
      end;
    end;



var
  sTipo : String;
begin
  if (sComponentButton = 'btnNone') or (sComponentButton = '') then exit;
  sTipo := sComponentButton;
  btnNone.Click;

  // Simples
  if (sTipo = 'btnInt')          then CriaNumEdit   ((Sender as TPanel), mzInteger, X, Y);
  if (sTipo = 'btnFloat')        then CriaNumEdit   ((Sender as TPanel), mzFloat  , X, Y);
  if (sTipo = 'btnText')         then CriaNumEdit   ((Sender as TPanel), mzString , X, Y);
  if (sTipo = 'btnCheck')        then CriaCheck     ((Sender as TPanel),  X, Y);
  if (sTipo = 'btnDatePicker')   then CriaDatePicker((Sender as TPanel), X , Y);
  if (sTipo = 'btnCalcEdit')     then CriaCalcEdit  ((Sender as TPanel), X , Y);
  if (sTipo = 'btnMemo')         then CriaMemo      ((Sender as TPanel), X , Y);

  // Avançado
  if (sTipo = 'btnLabel')        then CriaLabel     ((Sender as TPanel),  X, Y);
  if (sTipo = 'btnBtnQueryEdit') then CriaQueryEdit ((Sender as TPanel), X , Y);
  if (sTipo = 'btnCombo')        then CriaDbCombo   ((Sender as TPanel), X , Y);
  if (sTipo = 'btnGrid')  and ((Sender as TPanel) = PanelForm) then CriaDbGrid ((Sender as TPanel), X , Y);
end;


// *************** Funcoes de Tamanho e posicao  ***************

procedure TfrmFormEditor.mzDbgrid1CellClick(Column: TColumn);
begin
 Objeto := Column.Grid;
end;

procedure TfrmFormEditor.Edit1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 Objeto := Sender;
 MouseDown := True;
 MouseCenter := ((Sender as TWidgetControl).Width-X > 2);
end;

procedure TfrmFormEditor.Edit1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 Cursor := crDefault;
 MouseDown := False;
end;

procedure TfrmFormEditor.Edit1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);

var
 nTop, nLeft : Integer;

begin
 //Muda o cursor

 with (Sender as TWidgetControl) do begin
   if (Width-X > 2) then
     Cursor := crDefault
   else
     Cursor := crSizeWE;

   if not MouseDown then exit;

   //Move o componente
   if MouseCenter then begin
     // Verifica Cima
     nTop := Top  - (Height div 2) + y;
     if nTop > 20 then
        Top := nTop
     else
        Top := 20;

     // Verifica Esquerda
     nLeft := Left - (Width div 2)  + X;
     if nLeft > 5 then
       Left := nLeft
     else
       Left := 5;
   end
   else begin
     //Redimensiona o componente
     if X > 15 then Width := X;
   end;
 end;
end;


procedure TfrmFormEditor.GridMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);

var
 nTop, nLeft : Integer;

begin
 //Muda o cursor

 with ( (Sender as TWidgetControl).Parent as  TWidgetControl ) do begin
   if (Width-X > 2) then
     Cursor := crDefault
   else
     Cursor := crSizeWE;

   if not MouseDown then exit;

   //Move o componente
   if MouseCenter then begin
     // Verifica Cima
     nTop := Top  - (Height div 2) + y;
     if nTop > 20 then
        Top := nTop
     else
        Top := 20;

     // Verifica Esquerda
     nLeft := Left - (Width div 2)  + X;
     if nLeft > 5 then
       Left := nLeft
     else
       Left := 5;
   end;
 end;
end;


procedure TfrmFormEditor.MemoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 Objeto := Sender;
 MouseDown := True;
 MouseCenter := ((Sender as TWidgetControl).Width-X > 2) ;
 MouseCenterTop := ((Sender as TWidgetControl).Height-Y > 2) ;
end;

procedure TfrmFormEditor.MemoMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 Cursor := crDefault;
 MouseDown := False;
end;



procedure TfrmFormEditor.MemoMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);

var
 nTop, nLeft : Integer;

begin
 //Muda o cursor

 with (Sender as TWidgetControl) do begin
   if (Width-X > 2) then
     Cursor := crDefault
   else
     Cursor := crSizeNWSE;

   if (height-y > 2) then
     Cursor := crDefault
   else
     Cursor := crSizeNWSE;



   if not MouseDown then exit;

   //Move o componente
   if MouseCenter and MouseCenterTop then begin
     // Verifica Cima
     nTop := Top  - (Height div 2) + y;
     if nTop > 20 then
        Top := nTop
     else
        Top := 20;

     // Verifica Esquerda
     nLeft := Left - (Width div 2)  + X;
     if nLeft > 5 then
       Left := nLeft
     else
       Left := 5;

   end
   else begin
     //Redimensiona o componente
     if X > 15 then Width  := X;
     if Y > 15 then Height := Y;
   end;
 end;
end;



// *************** Salvar  ***************
procedure TfrmFormEditor.btnSalvarClick(Sender: TObject);


   procedure AddDbGrid(Component:TmzDbgrid; XmlNode : Ixmlnode; N : Integer);
   var
    nColuna : Integer;
   begin
     with Component do begin
        with XmlNode.AddChild('component') do begin
          with AddChild('ID')          do NodeValue := N;
          with AddChild('type')        do NodeValue := 'TDbGrid';
          with AddChild('name')        do NodeValue := Name;
          with AddChild('tablename')   do NodeValue := TableName;
          with AddChild('sqldataset')  do NodeValue := SQLDataSet.CommandText;
          with AddChild('parent')      do NodeValue := (Component as TmzDbgrid).Parent.Parent.Name;

          with AddChild('top')         do NodeValue := (Component as TmzDbgrid).Parent.Top;
          with AddChild('left')        do NodeValue := (Component as TmzDbgrid).Parent.left;
          with AddChild('width')       do NodeValue := (Component as TmzDbgrid).Parent.Width;
          with AddChild('height')      do NodeValue := (Component as TmzDbgrid).Parent.height;

          with AddChild('taborder')    do NodeValue := Component.TabOrder;
          with AddChild('columns') do
             if Component.DataSource.DataSet.Active then
               for nColuna := 0 to Columns.Count-1 do
                 with AddChild('columns') do begin
                   with AddChild('caption')   do NodeValue := Columns[nColuna].Title.Caption;
                   with AddChild('mask')      do NodeValue := Columns[nColuna].Field.EditMask;
                   with AddChild('visible')   do NodeValue := iif(Columns[nColuna].Visible, '1','0');
                   with AddChild('width')     do NodeValue := Columns[nColuna].Width;

                   if  ( (Component.DataSource.DataSet as TkbmMemTable).FieldDefs[nColuna].DataType = ftAutoInc ) then
                     with AddChild('auto_inc')  do NodeValue := True
                   else
                     with AddChild('auto_inc')  do NodeValue := False;

               end; // Fim da coluna
        end; // Node
     end; // Grid
   end;



   procedure AddBtnQueryEditclx(Component:TmzBtnQueryEditclx; XmlNode : Ixmlnode; N : Integer);
   begin
      with Component do begin
        with XmlNode.AddChild('component') do begin
          with AddChild('ID')              do NodeValue := N;
          with AddChild('type')            do NodeValue := 'TBtnQueryEdit';
          with AddChild('caption')         do NodeValue := TextLabel.Caption;
          with AddChild('editmask')        do NodeValue := EditMask;
          with AddChild('fieldname')       do NodeValue := FieldName;
          with AddChild('parent')          do NodeValue := Component.Parent.Name;
          with AddChild('name')            do NodeValue := (Component as TmzBtnQueryEditclx).Name;
          with AddChild('readonly')        do NodeValue := iif((Component as TmzBtnQueryEditclx).ReadOnly, '1','0');
          with AddChild('nulldata')        do NodeValue := iif(NullData, '1','0');
          with AddChild('showcaption')     do NodeValue := iif(TextLabel.Visible, '1','0');
          with AddChild('top')             do NodeValue := Top;
          with AddChild('left')            do NodeValue := Left;
          with AddChild('width')           do NodeValue := Width;
          with AddChild('querylist')       do NodeValue := QueryList.CommaText;
          with AddChild('componentlist')   do NodeValue := ComponentList.CommaText;
          with AddChild('taborder')        do NodeValue := Component.TabOrder;
        end;
      end;
   end;

   procedure AddNumEdit(Component:TNumEditCLX; XmlNode : Ixmlnode; N : Integer);
   var
     nTemp : Integer;
   begin
      nTemp := 0;
      with Component do begin
        case NumberType of
            mzInteger : nTemp := 1;
            mzFloat   : nTemp := 2;
        end;

        with XmlNode.AddChild('component') do begin
          with AddChild('ID')          do NodeValue := N;
          with AddChild('type')        do NodeValue := 'TNumEditCLX';
          with AddChild('caption')     do NodeValue := TextLabel.Caption;
          with AddChild('editmask')    do NodeValue := EditMask;
          with AddChild('fieldname')   do NodeValue := FieldName;
          with AddChild('parent')      do NodeValue := Component.Parent.Name;
          with AddChild('name')        do NodeValue := (Component as TNumEditCLX).Name;
          with AddChild('readonly')    do NodeValue := iif((Component as TNumEditCLX).ReadOnly, '1','0');
          with AddChild('nulldata')    do NodeValue := iif(NullData, '1','0');
          with AddChild('showcaption') do NodeValue := iif(TextLabel.Visible, '1','0');
          with AddChild('top')         do NodeValue := Top;
          with AddChild('left')        do NodeValue := Left;
          with AddChild('width')       do NodeValue := Width;
          with AddChild('numbertype')  do NodeValue := nTemp;
          with AddChild('taborder')    do NodeValue := Component.TabOrder;
        end;
      end;
   end;

   procedure AddComboBox(Component:TmzDBComboBoxClx; XmlNode : Ixmlnode; N : Integer);
   begin
      with Component do begin
        with XmlNode.AddChild('component') do begin
          with AddChild('ID')          do NodeValue := N;
          with AddChild('type')        do NodeValue := 'TmzDBComboBoxClx';
          with AddChild('caption')     do NodeValue := TextLabel.Caption;
          with AddChild('fieldname')   do NodeValue := FieldName;
          with AddChild('name')        do NodeValue := (Component as TmzDBComboBoxClx).Name;
          with AddChild('parent')      do NodeValue := Component.Parent.Name;
          with AddChild('showcaption') do NodeValue := iif(TextLabel.Visible, '1','0');
          with AddChild('top')         do NodeValue := Top;
          with AddChild('left')        do NodeValue := Left;
          with AddChild('width')       do NodeValue := Width;
          with AddChild('sqlquery')    do NodeValue := SQLQuery.CommaText;
          with AddChild('taborder')    do NodeValue := Component.TabOrder;
        end;
      end;
   end;


   procedure AddCalcEdit(Component:TmzCalcEdit; XmlNode : Ixmlnode; N : Integer);
   begin
      with Component do begin
        with XmlNode.AddChild('component') do begin
          with AddChild('ID')              do NodeValue := N;
          with AddChild('type')            do NodeValue := 'TmzCalcEdit';
          with AddChild('caption')         do NodeValue := TextLabel.Caption;
          with AddChild('editmask')        do NodeValue := EditMask;
          with AddChild('fieldname')       do NodeValue := FieldName;
          with AddChild('parent')          do NodeValue := Component.Parent.Name;
          with AddChild('name')            do NodeValue := (Component as TmzCalcEdit).Name;
          with AddChild('readonly')        do NodeValue := iif((Component as TmzCalcEdit).ReadOnly, '1','0');
          with AddChild('nulldata')        do NodeValue := iif(NullData, '1','0');
          with AddChild('showcaption')     do NodeValue := iif(TextLabel.Visible, '1','0');
          with AddChild('top')             do NodeValue := Top;
          with AddChild('left')            do NodeValue := Left;
          with AddChild('width')           do NodeValue := Width;
          with AddChild('taborder')        do NodeValue := Component.TabOrder;
        end;
      end;
   end;

   procedure AddDatePicker(Component:TmzDatePicker; XmlNode : Ixmlnode; N : Integer);
   begin
      with Component do begin
        with XmlNode.AddChild('component') do begin
          with AddChild('ID')              do NodeValue := N;
          with AddChild('type')            do NodeValue := 'TmzDatePicker';
          with AddChild('caption')         do NodeValue := TextLabel.Caption;
          with AddChild('editmask')        do NodeValue := EditMask;
          with AddChild('fieldname')       do NodeValue := FieldName;
          with AddChild('name')            do NodeValue := (Component as TmzDatePicker).Name;
          with AddChild('parent')          do NodeValue := Parent.Name;
          with AddChild('readonly')        do NodeValue := iif((Component as TmzDatePicker).ReadOnly, '1','0');
          with AddChild('nulldata')        do NodeValue := iif(NullData, '1','0');
          with AddChild('showcaption')     do NodeValue := iif(TextLabel.Visible, '1','0');
          with AddChild('top')             do NodeValue := Top;
          with AddChild('left')            do NodeValue := Left;
          with AddChild('width')           do NodeValue := Width;
          with AddChild('taborder')        do NodeValue := Component.TabOrder;
        end;
      end;
   end;


   procedure AddCheckBox(Component:TmzDBcheckBox; XmlNode : Ixmlnode; N : Integer);
   begin
      with Component do begin
        with XmlNode.AddChild('component') do begin
          with AddChild('ID')              do NodeValue := N;
          with AddChild('type')            do NodeValue := 'TmzDBcheckBox';
          with AddChild('caption')         do NodeValue := Caption;
          with AddChild('fieldname')       do NodeValue := FieldName;
          with AddChild('name')            do NodeValue := (Component as TmzDBcheckBox).Name;
          with AddChild('readonly')        do NodeValue := iif((Component as TmzDBcheckBox).ReadOnly, '1','0');
          with AddChild('top')             do NodeValue := Top;
          with AddChild('parent')          do NodeValue := Component.Parent.Name;
          with AddChild('left')            do NodeValue := Left;
          with AddChild('width')           do NodeValue := Width;
          with AddChild('taborder')        do NodeValue := Component.TabOrder;
        end;
      end;
   end;

   procedure AddDbLabel(Component:TmzdbLabel; XmlNode : Ixmlnode; N : Integer);
   begin
      with Component do begin
        with XmlNode.AddChild('component') do begin
          with AddChild('ID')              do NodeValue := N;
          with AddChild('type')            do NodeValue := 'TmzdbLabel';
          with AddChild('sqlquery')        do NodeValue := Query.CommaText;
          with AddChild('componentname')   do NodeValue := MasterComponent;
          with AddChild('name')            do NodeValue := (Component as TmzdbLabel).Name;
          with AddChild('top')             do NodeValue := Top;
          with AddChild('parent')          do NodeValue := Component.Parent.Name;
          with AddChild('left')            do NodeValue := Left;
          with AddChild('width')           do NodeValue := Width;
          with AddChild('taborder')        do NodeValue := Component.TabOrder;
        end;
      end;
   end;

   procedure AddDbMemo(Component:TmzMemo; XmlNode : Ixmlnode; N : Integer);
   begin
      with Component do begin
        with XmlNode.AddChild('component') do begin
          with AddChild('ID')              do NodeValue := N;
          with AddChild('type')            do NodeValue := 'TmzdbMemo';
          with AddChild('name')            do NodeValue := (Component as TmzMemo).Name;
          with AddChild('showcaption')     do NodeValue := iif(TextLabel.Visible, '1','0');
          with AddChild('caption')         do NodeValue := TextLabel.Caption;
          with AddChild('parent')          do NodeValue := Component.Parent.Name;
          with AddChild('top')             do NodeValue := Top;
          with AddChild('left')            do NodeValue := Left;
          with AddChild('width')           do NodeValue := Width;
          with AddChild('height')          do NodeValue := height;
          with AddChild('taborder')        do NodeValue := Component.TabOrder;
          with AddChild('fieldname')       do NodeValue := FieldName;
        end;
      end;
   end;



   function RetornaConnectionText:String;
   var
     n : integer;
   begin
      for n := 0 to length(ConnectArray)-1 do
        Result := ','+ConnectArray[n].sTabelaOrigem+','+ConnectArray[n].sTabelaDestino+','+ConnectArray[n].sCampoOrigem+','+ConnectArray[n].sCampoDestino+Result;
    if (length(Result) > 0) then Result[1] := ' ';
   end;



var
 n: Integer;
 ModuleNode, xmlnode : IXmlNode;
begin
  XMLDocument1.Active := False;
  XMLDocument1.XML.Text := '';
  XMLDocument1.Active := True;
  ModuleNode := XMLDocument1.AddChild('module');

  xmlnode := ModuleNode.AddChild('form');

  // *** Adiciona Componentes do Form  ***
  for n := 0 to Self.ComponentCount-1 do begin

    if (Self.Components[n] is TNumEditCLX) then
      if ( (Self.Components[n] as TNumEditCLX).Parent <> PanelQuery ) then
         AddNumEdit((Self.Components[n] as TNumEditCLX), xmlnode, n );

    if (Self.Components[n] is TmzDBComboBoxClx) then
      if ( (Self.Components[n] as TmzDBComboBoxClx).Parent <> PanelQuery  ) then
         AddComboBox((Self.Components[n] as TmzDBComboBoxClx), xmlnode, n );

    if (Self.Components[n] is TmzDbgrid) then
      if ((Self.Components[n] as TmzDbgrid).Parent.Parent  <> PanelQuery) then
        AddDbGrid((Self.Components[n] as TmzDbgrid), xmlnode, n );

    if (Self.Components[n] is TmzBtnQueryEditclx) then
      if ((Self.Components[n] as TmzBtnQueryEditclx).Parent  <> PanelQuery) then
        AddBtnQueryEditclx((Self.Components[n] as TmzBtnQueryEditclx), xmlnode, n );

    if (Self.Components[n] is TmzDatePicker) then
      if ((Self.Components[n] as TmzDatePicker).Parent  <> PanelQuery) then
        AddDatePicker((Self.Components[n] as TmzDatePicker), xmlnode, n );

    if (Self.Components[n] is TmzCalcEdit) then
      if ((Self.Components[n] as TmzCalcEdit).Parent  <> PanelQuery) then
        AddCalcEdit((Self.Components[n] as TmzCalcEdit), xmlnode, n );

    if (Self.Components[n] is TmzDBcheckBox) then
      if ((Self.Components[n] as TmzDBcheckBox).Parent  <> PanelQuery) then
        AddCheckBox((Self.Components[n] as TmzDBcheckBox), xmlnode, n );


    if (Self.Components[n] is TmzdbLabel) then
      if ((Self.Components[n] as TmzdbLabel).Parent  <> PanelQuery) then
        AddDbLabel((Self.Components[n] as TmzdbLabel), xmlnode, n );

    if (Self.Components[n] is TmzMemo) then
      if ((Self.Components[n] as TmzMemo).Parent  <> PanelQuery) then
        AddDbMemo((Self.Components[n] as TmzMemo), xmlnode, n );

  end;

  //  *** Adiciona Componentes da Query  ***
  xmlnode := ModuleNode.AddChild('query');
  for n := 0 to Self.ComponentCount-1 do begin
    if (Self.Components[n] is TNumEditCLX) then
      if (Self.Components[n] as TNumEditCLX).Parent = PanelQuery then
         AddNumEdit((Self.Components[n] as TNumEditCLX), xmlnode, n );

     if (Self.Components[n] is TmzDBComboBoxClx) then
       if (Self.Components[n] as TmzDBComboBoxClx).Parent = PanelQuery then
          AddComboBox((Self.Components[n] as TmzDBComboBoxClx), xmlnode, n );

    if (Self.Components[n] is TmzBtnQueryEditclx) then
      if ((Self.Components[n] as TmzBtnQueryEditclx).Parent = PanelQuery) then
        AddBtnQueryEditclx((Self.Components[n] as TmzBtnQueryEditclx), xmlnode, n );

    if (Self.Components[n] is TmzDatePicker) then
      if ((Self.Components[n] as TmzDatePicker).Parent = PanelQuery) then
        AddDatePicker((Self.Components[n] as TmzDatePicker), xmlnode, n );

    if (Self.Components[n] is TmzCalcEdit) then
      if ((Self.Components[n] as TmzCalcEdit).Parent = PanelQuery) then
        AddCalcEdit((Self.Components[n] as TmzCalcEdit), xmlnode, n );


    if (Self.Components[n] is TmzDBcheckBox) then
      if ((Self.Components[n] as TmzDBcheckBox).Parent = PanelQuery) then
        AddCheckBox((Self.Components[n] as TmzDBcheckBox), xmlnode, n );

    if (Self.Components[n] is TmzdbLabel) then
      if ((Self.Components[n] as TmzdbLabel).Parent  = PanelQuery) then
        AddDbLabel((Self.Components[n] as TmzdbLabel), xmlnode, n );


  end;


 for n := ListaRels.Count-1  downto 0 do
   if trim(ListaRels.Strings[n]) = '' then ListaRels.Delete(n);

 ModuleNode.AddChild('rels').Text := ListaRels.Text;

 with frmPrincipal.DataSet do begin
   Close;
   if bNovo  then begin
     if (nCodTela = 0) then begin
       CommandText := ' select max(nIDForm)+1'+ASSQL+'nIDForm from tbForm ';
       Open;
       nCodTela := FieldByName('nIDForm').asInteger;
       if (nCodTela = 0) then nCodTela := 1;
       Close;
     end;



     CommandText := 'insert into tbForm '+
                    ' (nIDForm, sCampos, sNomeTabelas,sTitulo, sConnection, sBusca, sCampoChave, sQueryChave'+{$IFDEF corporate}',  sCampoEmpresa'+{$ENDIF}') '+
                    '  values '+
                    ' ('+SQL_PARM+'nIDForm, '+SQL_PARM+'sCampos, '+SQL_PARM+'sNomeTabelas, '+SQL_PARM+'sTitulo, '+SQL_PARM+'sConnection, '+SQL_PARM+'sBusca, '+SQL_PARM+'sCampoChave, '+SQL_PARM+'sQueryChave '+{$IFDEF corporate}', '+SQL_PARM+'sCampoEmpresa'+{$ENDIF}')';
   end
   else
     CommandText := ' update tbForm set'+
                    '   sCampos         = '+SQL_PARM+'sCampos ,'+
                    '   sNomeTabelas    = '+SQL_PARM+'sNomeTabelas ,'+
                    '   sTitulo         = '+SQL_PARM+'sTitulo ,'+
                    '   sConnection     = '+SQL_PARM+'sConnection ,'+
                    '   sBusca          = '+SQL_PARM+'sBusca ,'+
                    '   sCampoChave     = '+SQL_PARM+'sCampoChave ,'+
                    '   sQueryChave     = '+SQL_PARM+'sQueryChave ,'+
                    '   sQueryChave     = '+SQL_PARM+'sQueryChave '+
                    {$IFDEF corporate}
                    ',   sCampoEmpresa     = '+SQL_PARM+'sCampoEmpresa'+
                    {$ENDIF}

                    '   where nIDForm   = '+SQL_PARM+'nIDForm';

   ParamByName('nIDForm').AsInteger      := nCodTela;
   ParamByName('sCampos').AsBlob         := XMLDocument1.XML.Text;
   ParamByName('sNomeTabelas').AsString  := ListaTabelas.Text;
   ParamByName('sTitulo').AsString       := Caption;
   ParamByName('sConnection').AsBlob     := RetornaConnectionText;
   ParamByName('sBusca').AsBlob          := MemoQuery.Lines.Text;
   ParamByName('sCampoChave').AsString   := CamposChave;
   ParamByName('sQueryChave').AsBlob     := sConsultaChave;
   {$IFDEF corporate}
   ParamByName('sCampoEmpresa').AsBlob   := sCampoEmpresa;
   {$ENDIF}
   ExecSql;
 end;
 XMLDocument1.Active := False;
 frmPrincipal.CarregaMenu;
 bNovo := False;
end;



// *************** Funcoes da consulta  ***************
procedure TfrmFormEditor.FormCreate(Sender: TObject);
begin
  sComponentButton := 'btnNone' ;
  PageControl1.ActivePage := TabSheetForm;
end;


// *************** Funcoes diversas  ***************
procedure TfrmFormEditor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
   Action := caFree;

   ListaRels.Destroy;
   ListaTabelas.Destroy;
end;

procedure TfrmFormEditor.btnSairClick(Sender: TObject);
begin
 Close;
end;

procedure TfrmFormEditor.SetVars(InListaTabelas : TStringList; InListaArray: TListArray; InConnectArray : TConnectArray; InCampoChave, Consulta : String);
var
  sTabelas, sTempCampos: String;
  n2 : Integer;
begin
   //Copia Tabelas
   ListaTabelas := TStringList.Create;
   ListaTabelas.CommaText := InListaTabelas.CommaText;

   //      Copia campos
   ListaArray := InListaArray;

   // Copia Connections
   ConnectArray := InConnectArray;

 // ***** Prepara Query  *****
 CamposChave      := InCampoChave;
 sConsultaChave   := Consulta;

 // Cria o select
 sTabelas := ListaTabelas.Strings[0];
 nCodTela := 0;

 for n2 := 0 to ListaArray[0].Count-1 do
       sTempCampos := sTempCampos+', '+#10#13+'    '+sTabelas+'.'+ListaArray[0].Strings[n2];

 sTempCampos[1] := ' ';

 MemoQuery.Lines.Text   := ' select '+sTempCampos+#10#13+
                           ' from    '+
                           '    '+sTabelas+#10#13+
                           ' where ';
  ListaRels := TStringList.Create;
  bNovo := True;
end;



procedure TfrmFormEditor.Properties1Click(Sender: TObject);

    // *************** Funcoes Propriedades  ***************
    procedure DBGridProperties(Sender: TObject);
    var
      frmDBGridEditor: TfrmDBGridEditor;
    begin
      frmDBGridEditor := TfrmDBGridEditor.Create(Self);
      frmDBGridEditor.Grid                := (Sender as TmzDbgrid);
      frmDBGridEditor.QueryAux            := QueryAux;
      frmDBGridEditor.cmbTabela.Items     := ListaTabelas;
      frmDBGridEditor.cmbTabela.Itemindex := frmDBGridEditor.cmbTabela.Items.IndexOf(frmDBGridEditor.Grid.TableName);
      frmDBGridEditor.ListaArray          := ListaArray;
      frmDBGridEditor.Prepara(0);
      frmDBGridEditor.ShowModal;
    end;

    procedure BtnQueryEditProperties(Sender: TObject);
    var
      frmBtnQueryEditProperties: TfrmBtnQueryEditProperties;
    begin
      MouseDown := False;
      frmBtnQueryEditProperties := TfrmBtnQueryEditProperties.Create(Self);
      frmBtnQueryEditProperties.InmzBtnQueryEditclx   := (Sender as TmzBtnQueryEditclx);
      frmBtnQueryEditProperties.ListaArray        := ListaArray;
      frmBtnQueryEditProperties.cmbTable.Items    := ListaTabelas;
      frmBtnQueryEditProperties.AtualizaLista;
      frmBtnQueryEditProperties.Prepara;
      frmBtnQueryEditProperties.ShowModal;
    end;

    procedure ComboBoxProperties(Sender: TObject);
    var
      frmComboBoxEditor: TfrmComboBoxEditor;
    begin
      MouseDown := False;
      frmComboBoxEditor := TfrmComboBoxEditor.Create(Self);
      frmComboBoxEditor.DbComboBox    := (Sender as TmzDBComboBoxClx);
      frmComboBoxEditor.ListaArray     := ListaArray;
      frmComboBoxEditor.cmbTable.Items := ListaTabelas;
      frmComboBoxEditor.AtualizaLista;
      frmComboBoxEditor.Prepara;
      frmComboBoxEditor.ShowModal;
    end;



    procedure DBLabelProperties(Sender: TObject);
    var
      frmLabelEditor : TfrmLabelEditor;
    begin
      MouseDown := False;
      frmLabelEditor := TfrmLabelEditor.Create(Self);
      frmLabelEditor.mzdbLabel    := (Sender as TmzdbLabel);
      frmLabelEditor.Prepara;
      frmLabelEditor.ShowModal;
    end;

    procedure CustomEditProperties(Sender: TObject; CustomEdit, CheckBox, Memo :Boolean );
    var
      frmNumEditEditor: TfrmNumEditEditor;
    begin
      MouseDown := False;
      frmNumEditEditor := TfrmNumEditEditor.Create(Self);
      frmNumEditEditor.CustomEdit     := CustomEdit;
      frmNumEditEditor.CheckBox       := CheckBox;
      frmNumEditEditor.Memo           := Memo;

      if CustomEdit then frmNumEditEditor.EditCLX          := (Sender as TmzCustomEditclx);
      if CheckBox   then frmNumEditEditor.mzCheckBox       := (Sender as TmzDbCheckBox);
      if Memo       then frmNumEditEditor.mzMemo           := (Sender as TmzMemo);

      frmNumEditEditor.ListaArray     := ListaArray;
      frmNumEditEditor.cmbTable.Items := ListaTabelas;
      frmNumEditEditor.AtualizaLista;
      frmNumEditEditor.Prepara;
      frmNumEditEditor.ShowModal;
    end;


begin
  if (Objeto is TNumEditCLX)        then CustomEditProperties(Objeto, True, False, False);
  if (Objeto is TmzDatePicker)      then CustomEditProperties(Objeto, True, False, False);
  if (Objeto is TmzCalcEdit)        then CustomEditProperties(Objeto, True, False, False);
  if (Objeto is TmzDBCheckBox)      then CustomEditProperties(Objeto, False, True, False);
  if (Objeto is TmzMemo)            then CustomEditProperties(Objeto, False, False, True);

  if (Objeto is TmzDbComboBoxClx)   then ComboBoxProperties(Objeto);
  if (Objeto is TmzBtnQueryEditclx) then BtnQueryEditProperties(Objeto);


  if (Objeto is TmzdbLabel)         then DBLabelProperties(Objeto);
  if (Objeto is TmzDbgrid)          then DBGridProperties(Objeto);

  Objeto := nil;
end;

procedure TfrmFormEditor.Delete1Click(Sender: TObject);
begin
  if (Objeto <> nil) then
  if (Objeto is TmzDbgrid) then begin
     // SQlDataSet
    (Objeto as TmzDbgrid).SQLDataSet.Destroy;

     // MemoryTable
    (Objeto as TmzDbgrid).DataSource.DataSet.Destroy;

     // DataSource
    (Objeto as TmzDbgrid).DataSource.Destroy;

     // Panel Pai
    (Objeto as TmzDbgrid).Parent.Destroy;
  end
  else begin
   (Objeto as TObject).Destroy;
    Objeto := nil;
  end;
end;

procedure TfrmFormEditor.CarregaForm(CodTela:Integer);
  procedure CriaDbGrid(NodeAtual:IXMLNode; DbParent:TWidgetControl);
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
        OnMouseDown   := MemoMouseDown;
        OnMouseUp     := MemoMouseUp;
        OnMouseMove   := MemoMouseMove;
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
  end;



  procedure CriaComboBox(NodeComponent:IXMLNode; ComboParent:TWidgetControl);
  var
    ComboBox : TmzDBComboBoxClx;
    strTemp : string;
  begin
      ComboBox := TmzDBComboBoxClx.Create(Self);
      ComboBox.Parent := ComboParent;
      with ComboBox do begin
        TextLabel.Caption  := nodecomponent.ChildNodes['caption'].Text;
        strTemp            := nodecomponent.ChildNodes['fieldname'].Text;
        FieldName          := strTemp;
        Name               := nodecomponent.ChildNodes['name'].Text;
        TextLabel.Visible  := (nodecomponent.ChildNodes['showcaption'].Text = '1');
        Top                := nodecomponent.ChildNodes['top'].NodeValue;
        Left               := nodecomponent.ChildNodes['left'].NodeValue;
        Width              := nodecomponent.ChildNodes['width'].NodeValue;
        SQLConnection      := frmPrincipal.SQLConnection1;
        TabOrder           := nodecomponent.ChildNodes['taborder'].NodeValue;

        try
          SQLQuery.Commatext := nodecomponent.ChildNodes['sqlquery'].NodeValue;
          Active             := True;
        except end;

        ListaTab.Add(nodecomponent.ChildNodes['taborder'].Text+'&'+nodecomponent.ChildNodes['name'].Text);

        PopupMenu          := PopupMenuComum;
        OnMouseDown        := Edit1MouseDown;
        OnMouseUp          := Edit1MouseUp;
        OnMouseMove        := Edit1MouseMove;
        if CamposBusca then  sCamposForm  := strTemp+', '+sCamposForm;
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
        TextLabel.Visible       := (nodecomponent.ChildNodes['showcaption'].Text = '1');
        TextLabel.Caption       := nodecomponent.ChildNodes['caption'].Text;
        QueryList.CommaText     := nodecomponent.ChildNodes['querylist'].Text;
        ComponentList.CommaText := nodecomponent.ChildNodes['componentlist'].Text;
        TabOrder                := nodecomponent.ChildNodes['taborder'].NodeValue;
        SQLConnection           := frmPrincipal.SQLConnection1;

        PopupMenu               := PopupMenuComum;
        OnMouseDown             := Edit1MouseDown;
        OnMouseUp               := Edit1MouseUp;
        OnMouseMove             := Edit1MouseMove;
        ListaTab.Add(nodecomponent.ChildNodes['taborder'].Text+'&'+nodecomponent.ChildNodes['name'].Text);
        if CamposBusca then sCamposForm  := strTemp+', '+sCamposForm;
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
        Width             := nodecomponent.ChildNodes['width'].NodeValue;
        Text              := '';
        TextLabel.Visible := (nodecomponent.ChildNodes['showcaption'].Text = '1');
        TextLabel.Caption := nodecomponent.ChildNodes['caption'].Text;
        PopupMenu         := PopupMenuComum;
        TabOrder          := nodecomponent.ChildNodes['taborder'].NodeValue;
        OnMouseDown       := Edit1MouseDown;
        OnMouseUp         := Edit1MouseUp;
        OnMouseMove       := Edit1MouseMove;
        ListaTab.Add(nodecomponent.ChildNodes['taborder'].Text+'&'+nodecomponent.ChildNodes['name'].Text);
        if CamposBusca then sCamposForm  := strTemp+', '+sCamposForm;
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
        height             := nodecomponent.ChildNodes['height'].NodeValue;
        Text               := DateToStr(now);
        TextLabel.Visible  := (nodecomponent.ChildNodes['showcaption'].Text = '1');
        TextLabel.Caption  := nodecomponent.ChildNodes['caption'].Text;
        TabOrder           := nodecomponent.ChildNodes['taborder'].NodeValue;
        PopupMenu     := PopupMenuComum;
        OnMouseDown   := Edit1MouseDown;
        OnMouseUp     := Edit1MouseUp;
        OnMouseMove   := Edit1MouseMove;
        ListaTab.Add(nodecomponent.ChildNodes['taborder'].Text+'&'+nodecomponent.ChildNodes['name'].Text);
        if CamposBusca then sCamposForm  := strTemp+', '+sCamposForm;
      end;
  end;


  procedure CriaCalcEdit(NodeComponent:IXMLNode; EditParent:TWidgetControl);
  var
    mzCalcEdit: TmzCalcEdit;
    strTemp : string;
  begin
      mzCalcEdit := TmzCalcEdit.Create(Self);
      mzCalcEdit.Parent := EditParent;
      with mzCalcEdit do begin
        Editmask           := nodecomponent.ChildNodes['editmask'].Text;
        strTemp            := nodecomponent.ChildNodes['fieldname'].Text;
        FieldName          := strTemp;
        Name               := nodecomponent.ChildNodes['name'].Text;
        ReadOnly           := (nodecomponent.ChildNodes['readonly'].Text = '1');
        NullData           := (nodecomponent.ChildNodes['nulldata'].Text = '1');
        Top                := nodecomponent.ChildNodes['top'].NodeValue;
        Left               := nodecomponent.ChildNodes['left'].NodeValue;
        Width              := nodecomponent.ChildNodes['width'].NodeValue;
        TabOrder           := nodecomponent.ChildNodes['taborder'].NodeValue;
        Text               := '0';
        TextLabel.Visible  := (nodecomponent.ChildNodes['showcaption'].Text = '1');
        TextLabel.Caption  := nodecomponent.ChildNodes['caption'].Text;
        PopupMenu     := PopupMenuComum;
        OnMouseDown   := Edit1MouseDown;
        OnMouseUp     := Edit1MouseUp;
        OnMouseMove   := Edit1MouseMove;
        ListaTab.Add(nodecomponent.ChildNodes['taborder'].Text+'&'+nodecomponent.ChildNodes['name'].Text);
        if CamposBusca then sCamposForm  := strTemp+', '+sCamposForm;
      end;
  end;



  procedure CriaCheckBox(NodeComponent:IXMLNode; CheckBoxParent:TWidgetControl);
  var
    mzDBcheckBox: TmzDBcheckBox;
    strTemp : string;
  begin
      mzDBcheckBox := TmzDBcheckBox.Create(Self);
      mzDBcheckBox.Parent := CheckBoxParent;
      with mzDBcheckBox do begin
        strTemp            := nodecomponent.ChildNodes['fieldname'].Text;
        FieldName          := strTemp;
        Name               := nodecomponent.ChildNodes['name'].Text;
        ReadOnly           := (nodecomponent.ChildNodes['readonly'].Text = '1');
        Top                := nodecomponent.ChildNodes['top'].NodeValue;
        Left               := nodecomponent.ChildNodes['left'].NodeValue;
        Width              := nodecomponent.ChildNodes['width'].NodeValue;
        Caption            := nodecomponent.ChildNodes['caption'].Text;
        TabOrder           := nodecomponent.ChildNodes['taborder'].NodeValue;
        PopupMenu     := PopupMenuComum;
        OnMouseDown   := Edit1MouseDown;
        OnMouseUp     := Edit1MouseUp;
        OnMouseMove   := Edit1MouseMove;
        ListaTab.Add(nodecomponent.ChildNodes['taborder'].Text+'&'+nodecomponent.ChildNodes['name'].Text);
        if CamposBusca then sCamposForm  := strTemp+', '+sCamposForm;
      end;
  end;



  procedure CriaDBLabel(NodeComponent:IXMLNode; LabelParent:TWidgetControl);
  var
    mzdbLabel : TmzdbLabel;
    strTemp : string;
  begin
      mzdbLabel := TmzdbLabel.Create(Self);
      mzdbLabel.Parent := LabelParent;
      with mzdbLabel do begin
        strTemp            := nodecomponent.ChildNodes['fieldname'].Text;
        Name               := nodecomponent.ChildNodes['name'].Text;
        Top                := nodecomponent.ChildNodes['top'].NodeValue;
        Left               := nodecomponent.ChildNodes['left'].NodeValue;
        Width              := nodecomponent.ChildNodes['width'].NodeValue;
        Query.CommaText    := nodecomponent.ChildNodes['sqlquery'].Text;
        MasterComponent    := nodecomponent.ChildNodes['componentname'].Text;
        TabOrder           := nodecomponent.ChildNodes['taborder'].NodeValue;
        PopupMenu     := PopupMenuComum;
        OnMouseDown   := Edit1MouseDown;
        OnMouseUp     := Edit1MouseUp;
        OnMouseMove   := Edit1MouseMove;
        ListaTab.Add(nodecomponent.ChildNodes['taborder'].Text+'&'+nodecomponent.ChildNodes['name'].Text);
        if CamposBusca then sCamposForm  := strTemp+', '+sCamposForm;
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
        PopupMenu         := PopupMenuComum;
        TabOrder          := nodecomponent.ChildNodes['taborder'].NodeValue;
        OnMouseDown   := MemoMouseDown;
        OnMouseUp     := MemoMouseUp;
        OnMouseMove   := MemoMouseMove;
        ScrollBars := ssVertical;
        ListaTab.Add(nodecomponent.ChildNodes['taborder'].Text+'&'+nodecomponent.ChildNodes['name'].Text);
        if CamposBusca then sCamposForm  := strTemp+', '+sCamposForm;
      end;
  end;



  procedure ApplicaTabOrderInt(Lista:TStrings);
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


var
  n : Integer;
  NodeModule, nodecomponent, nodeform : Ixmlnode;
  sConnection : String;
  sListaTemp, Tabelas : TStringList;

begin
  Tabelas := TStringList.Create;
  nCodTela := CodTela;
  bNovo := False;
  with QueryAux do begin
     SQL.Text := ' select '+
                      ' sTitulo, '+
                      ' sNomeTabelas, '+
                      ' sCampos, '+
                      ' sBusca , '+
{$IFDEF corporate}
                      ' sCampoEmpresa, '+
{$ENDIF}
                      ' sConnection, '+
                      ' sCampoChave, '+
                      ' sQueryChave'+

                 ' from tbForm'+
                 ' where nIDForm = '+IntToStr(CodTela);
     QueryAux.Open;

     ListaTabelas := TStringList.Create;

     ListaTabelas.Text := FieldbyName('sNomeTabelas').AsString;
     sConsultaChave    := FieldbyName('sQueryChave').AsString;
     CamposChave       := FieldbyName('sCampoChave').AsString;
     MemoQuery.Text    := FieldbyName('sBusca').AsString;
     Self.Caption      := FieldbyName('sTitulo').AsString;

{$IFDEF corporate}
     sCampoEmpresa     := FieldbyName('sCampoEmpresa').AsString;
{$ENDIF}

     sConnection            := FieldbyName('sConnection').AsString;
     CriaConnectArray(sConnection+',', ConnectArray);

     XMLDocument1.XML.Text := FieldbyName('sCampos').AsString;

  end;
  XMLDocument1.Active := True;
  NodeModule := XMLDocument1.ChildNodes['module'];
  CamposBusca := True;

  // CarregaForm
  nodeform := NodeModule.ChildNodes['form'];
  ListaTab := TStringList.Create;


  for n := 0 to nodeform.ChildNodes.Count-1 do begin
    nodecomponent := nodeform.ChildNodes[n];
    if (nodecomponent.ChildNodes['type'].Text = 'TNumEditCLX')      then CriaNumEdit(nodecomponent, PanelForm);
    if (nodecomponent.ChildNodes['type'].Text = 'TmzDBComboBoxClx') then CriaComboBox(nodecomponent, PanelForm);
    if (nodecomponent.ChildNodes['type'].Text = 'TDbGrid')          then CriaDbGrid(nodecomponent, PanelForm);
    if (nodecomponent.ChildNodes['type'].Text = 'TBtnQueryEdit')    then CriabtnQueryEdit(nodecomponent, PanelForm);
    if (nodecomponent.ChildNodes['type'].Text = 'TmzDatePicker')    then CriaDatePicker(nodecomponent, PanelForm);
    if (nodecomponent.ChildNodes['type'].Text = 'TmzCalcEdit')      then CriaCalcEdit(nodecomponent, PanelForm);
    if (nodecomponent.ChildNodes['type'].Text = 'TmzDBcheckBox')    then CriaCheckBox(nodecomponent, PanelForm);
    if (nodecomponent.ChildNodes['type'].Text = 'TmzdbLabel')       then CriaDBLabel(nodecomponent, PanelForm);
    if (nodecomponent.ChildNodes['type'].Text = 'TmzdbMemo')        then CriaMemo(nodecomponent, PanelForm);
  end;

  sCamposForm := trim(sCamposForm);
  if (sCamposForm <> '') then sCamposForm[Length(sCamposForm)] := ' ';

  CamposBusca := False;

  for n := 0 to ListaTabelas.Count-1 do begin
    sListaTemp := TStringList.Create;
    frmPrincipal.SQLConnection1.GetFieldNames(ListaTabelas.Strings[n], sListaTemp);
    ListaArray      := AddListaInArray(sListaTemp, ListaArray);
  end;


  // CarregaBusca
  nodeform := NodeModule.ChildNodes['query'];
  PageControl1.ActivePage := TabSheetBrowser;
  for n := 0 to nodeform.ChildNodes.Count-1 do begin
    nodecomponent := nodeform.ChildNodes[n];
    if (nodecomponent.ChildNodes['type'].Text = 'TNumEditCLX')      then CriaNumEdit(nodecomponent, PanelQuery);
    if (nodecomponent.ChildNodes['type'].Text = 'TmzDBComboBoxClx') then CriaComboBox(nodecomponent, PanelQuery);
    if (nodecomponent.ChildNodes['type'].Text = 'TBtnQueryEdit')    then CriabtnQueryEdit(nodecomponent, PanelQuery);
    if (nodecomponent.ChildNodes['type'].Text = 'TmzDatePicker')    then CriaDatePicker(nodecomponent, PanelQuery);
    if (nodecomponent.ChildNodes['type'].Text = 'TmzCalcEdit')      then CriaCalcEdit(nodecomponent, PanelQuery);
    if (nodecomponent.ChildNodes['type'].Text = 'TmzDBcheckBox')    then CriaCheckBox(nodecomponent, PanelQuery);
    if (nodecomponent.ChildNodes['type'].Text = 'TmzdbLabel')       then CriaDBLabel(nodecomponent, PanelQuery);
  end;

  ApplicaTabOrderInt(ListaTab);


  // Carrega Relatorios
  ListaRels := TStringList.Create;
  ListaRels.Text := NodeModule.ChildNodes['rels'].Text;
  AtualizaMenuRels;

  ListaTab.Destroy;
  Tabelas.Destroy;
end;


procedure TfrmFormEditor.ToolButton1Click(Sender: TObject);
begin
 if msgSimNao(msgApagaForm) then exit;
 ApagaForm;
 Showmessage(msgExcluido);
 frmPrincipal.CarregaMenu;
 Close;
end;

procedure TfrmFormEditor.ToolButton7Click(Sender: TObject);
begin
  with frmPrincipal.DataSet do begin
    try
      Close;
      CommandText := MemoQuery.Text+' 0 = 1';
      Open;
      ShowMessage(msgOK);
    except
        on E : EDatabaseError do begin
          ShowMessage(ErrQuery+#13+E.Message);
        end;
    end;
  end;
end;

procedure TfrmFormEditor.btnRelClick(Sender: TObject);
var
  MyPoint1, MyPoint2: TPoint;
begin
  MyPoint1.X := 0;
  MyPoint1.Y := btnRel.Height;
  MyPoint2 := btnRel.ClientToScreen(MyPoint1);
  PopupRel.Popup(MyPoint2.X,  MyPoint2.Y);
end;

procedure TfrmFormEditor.OrdemdeTab1Click(Sender: TObject);
var
  n: integer;
  Lista1: TStringList;
  sTemp : string;

begin

  //Pega lista de componentes
  Lista1 := TStringList.Create;
  for n := 0 to Self.ComponentCount-1 do
    if (Self.Components[n] is TWinControl ) and ( (Self.Components[n] as TWinControl ).Parent = PanelForm) then Lista1.Add(  ComZero( (Self.Components[n] as TWinControl ).TabOrder ) +'&'+ (Self.Components[n] as TWinControl ).Name );

  // Ordena por taborder
  Lista1.Sort;

  frmTabEditor := TfrmTabEditor.Create(self);
  for n := 0 to Lista1.Count-1 do begin
     sTemp := Lista1.Strings[n];
     sTemp := copy (sTemp, 6, length(sTemp) );
     frmTabEditor.ListBox.Items.Add(stemp);
  end;
  Lista1.Destroy;
  frmTabEditor.ShowModal;
end;



procedure TfrmFormEditor.Adicionar1Click(Sender: TObject);
   function RetornaNomeArquivo:string;
   var
     n:Integer;
     sArquivo, sCaminho : string;
   begin
     n := 1;
     sCaminho := frmPrincipal.AppPath+CaminhoRel;
     sArquivo := ComZero(n);
     while FileExists(sCaminho+sArquivo+'.rep') do begin
       n:=n+1;
       sArquivo := ComZero(n);
     end;

     frmPrincipal.CopyFile(sCaminho+'template.rep', sCaminho+sArquivo+'.rep');
     Result := sArquivo;
   end;

var
  sArquivo, sNomeArquivo, sTitulo : string;
  bTemp : boolean;
begin
    bTemp := true;
    while bTemp and (sTitulo = '') do  bTemp := not InputQuery(NomeRelatorio,Nome, sTitulo);
    sArquivo := RetornaNomeArquivo;
    sNomeArquivo := frmPrincipal.AppPath+CaminhoRel+sArquivo+'.rep';
    RpDesigner1.Filename := sNomeArquivo;

    RpDesigner1.Execute;
    ListaRels.Add(sArquivo+'&'+sTitulo);
    AtualizaMenuRels;
end;

procedure TfrmFormEditor.EditaRelClick(Sender: TObject);
begin
  RpDesigner1.Filename := frmPrincipal.AppPath+CaminhoRel+ ComZero(  (sender as TMenuItem).parent.Tag )  +'.rep';
  RpDesigner1.Execute;
end;

procedure TfrmFormEditor.ApagaRelClick(Sender: TObject);
var
  MenuItem : TMenuItem;
begin
   if msgSimNao(msgApagaRel) then exit;
   MenuItem := (sender as TMenuItem).Parent;
   ApagaRel(MenuItem.Tag);
   AtualizaMenuRels;
end;



end.
