unit QueryEditor;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, QExtCtrls, QComCtrls, QButtons, QMenus, QCheckLst, mzlib,
  FMTBcd, DB, SqlExpr, mzComboBoxClx, QMask, mzCustomEdit, mzNumEditclx;

  const ErroSemTabela : string = 'É nescessário escolher uma ou mais tabelas.';


type
  TfrmQueryEditor = class(TForm)
    StatusBar1: TStatusBar;
    Image1: TImage;
    PopupMenuTabela: TPopupMenu;
    Delete1: TMenuItem;
    Query: TSQLQuery;
    Panel1: TPanel;
    btnAdd: TBitBtn;
    ComboBoxTabelas: TmzComboBoxClx;
    Panel3: TPanel;
    btnOk: TBitBtn;
    BitBtn2: TBitBtn;
    procedure ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListBox2DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ListBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure Panel5MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel5MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel5MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure btnAddClick(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure Panel1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure BitBtn2Click(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
     ListaTabelas : TStringList;
     ListArray    : TListArray;
     ConnectArray : TConnectArray;

    Panel                        : TPanel;
    pOrigem                      : TRect;
    DBFK                         : TConnectArray;
    sTabelaOrigem, sCampoOrigem  : String;
    bItemClicado, bTabelaClicada : boolean;
    procedure Relacionar(sNomeTabela:String);
    procedure GetDBConnetctions;
    procedure RepaintForm;
    procedure DrawShape(TopLeft, BottomRight: TPoint; AMode: TPenMode);
    procedure CriaMySQLFks;
    procedure RedesenharLinha(ConnectionItem:TConnectItem);
    { Private declarations }
  public
    { Public declarations }
     QueryObject  : TmzQueryObject;
  end;

var
  frmQueryEditor: TfrmQueryEditor;

implementation

uses Principal;

{$R *.xfm}

// ***************** Diversos *****************

procedure TfrmQueryEditor.FormCreate(Sender: TObject);
begin
  Setlength(ConnectArray,0);
  frmPrincipal.SQLConnection1.GetTableNames(ComboBoxTabelas.Items,False);
  ComboBoxTabelas.ItemIndex := 0;
  GetDBConnetctions;
end;

procedure TfrmQueryEditor.DrawShape(TopLeft, BottomRight: TPoint; AMode: TPenMode);
begin
  with Image1.Canvas do begin
    Pen.Width := 3;
    Pen.Mode := AMode;
    MoveTo(TopLeft.X,TopLeft.Y);
    LineTo(BottomRight.X,BottomRight.Y);
    Ellipse(TopLeft.X-6,TopLeft.Y-6, TopLeft.X+6,TopLeft.Y+6);
  end;


end;




// ***************** Carrega Referencias no BD *****************
procedure TfrmQueryEditor.CriaMySQLFks;
   procedure RetConnectFromText(const Destino, Texto : String);
     procedure AdicionaItems(const TabelaDestino, CampoDestino, TabelaOrigem, CampoOrigem : string);
     var
       sTemp, sCampoDestino, sCampoOrigem : string;
       Connection : TConnectItem;
       nTemp : Integer;
     begin
        if (pos(' ', CampoDestino) = 0) then begin // Verifica se tem mais de uma FK na mesma tabela
           Connection.sCampoDestino  := CampoDestino;
           Connection.sTabelaDestino := TabelaDestino;
           Connection.sTabelaOrigem  := TabelaOrigem;
           Connection.sCampoOrigem   := CampoOrigem;
           DBFK := AddConnectInArray(Connection, DBFK);
        end else begin
            sCampoDestino := CampoDestino;
            while (pos(' ', sCampoDestino) <> 0) do begin

              //Cria Origem
              nTemp  := pos(' ', sCampoDestino);
              sTemp  := copy(sCampoDestino, 0, nTemp-1);
              sCampoDestino := copy(sCampoDestino, nTemp+1, Length(sCampoDestino) );
              Connection.sCampoDestino  := sCampoDestino;

              //Cria Origem
              nTemp  := pos(' ', sCampoOrigem);
              sTemp  := copy(sCampoOrigem, 0, nTemp-1);
              sCampoOrigem := copy(sCampoOrigem, nTemp+1, Length(sCampoDestino) );
              Connection.sCampoOrigem  := sCampoOrigem;
              Connection.sTabelaDestino := TabelaDestino;
              Connection.sTabelaOrigem  := TabelaOrigem;
              DBFK := AddConnectInArray(Connection, DBFK);
            end;
        end;
     end;

   var
     TabelaDestino, CampoDestino, TabelaOrigem, CampoOrigem,
     sTexto, sTemp  : string;
     nTemp, nTemp2, nTemp3  : integer;
   begin
     TabelaDestino := Destino;

     sTexto := Texto;
     nTemp := pos(')', sTexto)-1;
     nTemp2 := pos('(', sTexto);
     CampoDestino  := copy(sTexto, nTemp2+1, nTemp-nTemp2);

     sTemp := copy(sTexto, nTemp+9, Length(sTexto) );
     nTemp := pos('/', sTemp)+1;
     nTemp2 := pos('(', sTemp);
     nTemp3 := nTemp2-nTemp;
     TabelaOrigem := copy(sTemp, nTemp, nTemp3 );

     sTemp := copy(sTemp, nTemp3, pos(')', sTemp) );
     nTemp := pos('(', sTemp);
     CampoOrigem   := copy(sTemp, nTemp+1, Length(sTemp)-nTemp-1);

     AdicionaItems(TabelaDestino, CampoDestino, TabelaOrigem, CampoOrigem);
   end;

var
 sTemp, sTexto : string;
 nTemp : Integer;
begin
    with Query do begin
      Close;
      SQL.Text := 'show table status';
      Open;
      while not EoF do begin
         if (pos('REFER', FieldByName('Comment').AsString) <> 0) then begin
           sTexto := FieldByName('Comment').CurValue;
           sTexto := copy(sTexto, pos(';', sTexto)+2, Length(sTexto) );

           if pos(';', sTexto) = 0 then // Verifica se tem FK de mais de uma tabela
              RetConnectFromText(FieldByName('Name').AsString, sTexto)
           else
              while (pos(';', sTexto) <> 0) do begin
                nTemp  := pos(';', sTexto);
                sTemp  := copy(sTexto, 0, nTemp-1);
                sTexto := copy(sTexto, nTemp+1, Length(sTexto) );
                RetConnectFromText(FieldByName('Name').AsString, sTemp);
              end;
         end;
         Next;
      end;
    end;
end;

procedure TfrmQueryEditor.GetDBConnetctions;
begin
  SetLength(DBFK, 0);
  if frmPrincipal.SQLConnection1.DriverName = 'MySQL' then CriaMySQLFks;
end;




// ***************** Cria Referencias *****************
procedure TfrmQueryEditor.Relacionar(sNomeTabela:String);
var
  n1, n2 : Integer;
  InListBox : TListBox;
begin
  for n1 := 0 to length(DBFK)-1 do
    if (DBFK[n1].sCampoOrigem <> '') then
     for n2 := 0 to Self.ComponentCount -1 do
       if (Self.Components[n2] is TListBox) then begin
          InListBox := (Self.Components[n2] as TListBox);
          if ( (DBFK[n1].sTabelaOrigem  = InListBox.Name)  and (DBFK[n1].sTabelaDestino = sNomeTabela)  )  then ConnectArray := AddConnectInArray(DBFK[n1], ConnectArray);
          if ( (DBFK[n1].sTabelaDestino = InListBox.Name)  and (DBFK[n1].sTabelaOrigem  = sNomeTabela)  )  then ConnectArray := AddConnectInArray(DBFK[n1], ConnectArray);
       end;
  RepaintForm;
end;


procedure TfrmQueryEditor.RedesenharLinha(ConnectionItem:TConnectItem);
  function ProcuraLista(Nome:String):TListBox;
  var
   n  : Integer;
  begin
  Result := nil;
    for n := 0 to Self.ComponentCount-1 do
      if (Self.Components[n].Name = Nome) then
        if (Self.Components[n] is TListBox) then begin
           Result := (Self.Components[n] as TListBox);
           Break;
        end;
  end;

var
 InListBoxO, InListBoxD         : TListBox;
 RecO, RecD                     : TRect;
 p1, p2                         : TPoint;
 nOri1, nOri2, nDest1, nDest2   : Integer;

begin
  InListBoxO := ProcuraLista(ConnectionItem.sTabelaOrigem);
  InListBoxD := ProcuraLista(ConnectionItem.sTabelaDestino);

  if (InListBoxO = nil) or (InListBoxD = nil) then exit;

  RecO    := InListBoxO.ItemRect(InListBoxO.Items.IndexOf(ConnectionItem.sCampoOrigem));
  RecD    := InListBoxD.ItemRect(InListBoxD.Items.IndexOf(ConnectionItem.sCampoDestino));

  nOri1 := (InListBoxO.Parent as TWinControl).Left;
  nOri2 := (InListBoxO.Parent as TWinControl).Top;

  nDest1 := (InListBoxD.Parent as TWinControl).Left;
  nDest2 := (InListBoxD.Parent as TWinControl).Top;


  RecO.Right := nOri1+RecO.Right+5;
  RecO.Left  := nOri1+RecO.Left;
  RecO.Top   := nOri2+RecO.Top+30+5;

  RecD.Right := nDest1+RecD.Right+5;
  RecD.Left  := nDest1+RecD.Left;
  RecD.Top   := nDest2+RecD.Top+30+5;

  p1.Y := RecO.Top;
  p2.Y := RecD.Top;

  // Verifica qual o item da direita
  if RecD.Left <= RecO.Left then begin
      p1.X := RecO.Left;
      p2.X := RecD.Right;
  end
  else begin
      p1.X := RecO.Right;
      p2.X := RecD.Left;
  end;

  DrawShape(P1, P2,pmCopy);
end;

procedure TfrmQueryEditor.RepaintForm;
var
 InBitmap     : TBitmap;
 n, nTamanho  : Integer;
begin

   // limpa a imagem
   InBitmap := TBitmap.Create;
   with InBitmap do begin
    Width := Image1.Width;
    Height := Image1.Height;
   end;
   Image1.Picture.Bitmap := InBitMap;

   nTamanho := Length(ConnectArray)-1;

   // Redesenha as linhas
    for n := 0 to nTamanho do RedesenharLinha(ConnectArray[n]);
end;


procedure TfrmQueryEditor.ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 nItem, n1, n2 : Integer;
 Rect : TRect;
 InListBox : TListBox;
begin
 InListBox := (Sender as TListBox);
 sTabelaOrigem := InListBox.Name;
 if (InListBox.ItemIndex = -1 ) then exit;
 n1 := (InListBox.Parent as TWinControl).Left;
 n2 := (InListBox.Parent as TWinControl).Top;
 nItem := InListBox.ItemAtPos(Point(X,Y),True);
 if nItem = -1 then exit;
 sCampoOrigem := InListBox.Items[nItem];

 Rect := InListBox.ItemRect(nItem);
 pOrigem.Right := N1+Rect.Right+5;
 pOrigem.Left  := N1+Rect.Left+5;
 pOrigem.Top   := N2+Rect.Top+30+5;

 bItemClicado := True;

 InListBox.BeginDrag(True);
end;

procedure TfrmQueryEditor.ListBox2DragDrop(Sender, Source: TObject; X, Y: Integer);
var
  nItem1, nItem2, nItem, n1, n2   : Integer;
  Rect, pDestino  : TRect;
  InListBox       : TListBox;
  p1,p2           : TPoint;
  ConnectItem     : TConnectItem;
  sTemp, sCampoDestino   : String;

begin
 InListBox := (Sender as TListBox);

 if (InListBox.ItemIndex = -1 ) then exit;
 n1 := (InListBox.Parent as TWinControl).Left;
 n2 := (InListBox.Parent as TWinControl).Top;
 nItem := InListBox.ItemAtPos(Point(X,Y),True);

 if (sTabelaOrigem = InListBox.Name) then begin
   nItem1 := InListBox.Items.IndexOf(sCampoOrigem);
   nItem2 := nItem;

   sTemp := InListBox.Items[nItem1];
   InListBox.Items[nItem1] := InListBox.Items[nItem2];
   InListBox.Items[nItem2] := sTemp;

   RepaintForm;

   Exit;
 end;


 if (nItem = -1) then exit;
 sCampoDestino := InListBox.Items[nItem];

 Rect := InListBox.ItemRect(nItem);
 pDestino.Right := N1+Rect.Right+5;
 pDestino.Left  := N1+Rect.Left+5;
 pDestino.Top   := N2+Rect.Top+30+5;

 p1.Y := pOrigem.Top;
 p2.Y := pDestino.Top;

 // Verifica qual o item da direita
 if pDestino.Left <= pOrigem.Left then begin
    p1.X := pOrigem.Left;
    p2.X := pDestino.Right;
 end
 else begin
    p1.X := pOrigem.Right;
    p2.X := pDestino.Left;
 end;

  DrawShape(P1,P2,pmCopy);

  bItemClicado := False;

  ConnectItem.sTabelaOrigem  := sTabelaOrigem;
  ConnectItem.sTabelaDestino := InListBox.Name;
  ConnectItem.sCampoOrigem   := sCampoOrigem;
  ConnectItem.sCampoDestino  := sCampoDestino;

  ConnectArray := AddConnectInArray(ConnectItem, ConnectArray);
end;



procedure TfrmQueryEditor.Image1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
 StatusBar1.SimpleText := IntToStr(X)+':'+IntToStr(Y);
end;

procedure TfrmQueryEditor.ListBox1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  N1, N2 : Integer;
  InListBox : TListBox;
begin
 InListBox := (Sender as TListBox);

 n1 := (InListBox.Parent as TWinControl).Left+X;
 n2 := (InListBox.Parent as TWinControl).Top+Y;
 StatusBar1.SimpleText := IntToStr(n1)+':'+IntToStr(n2);
end;

// ***************** Mover Tabela *****************
procedure TfrmQueryEditor.Panel5MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  bTabelaClicada := True;
end;

procedure TfrmQueryEditor.Panel5MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  bTabelaClicada := False;
  RepaintForm;
end;

procedure TfrmQueryEditor.Panel5MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  InPanel, InPanelParent : TPanel;
  nLeft, nTop : Integer;
begin
 if not bTabelaClicada then exit;
 InPanel := (Sender as TPanel);
 InPanelParent :=(InPanel.Parent as TPanel);

 nLeft := InPanelParent.Left - (InPanelParent.Width div 2) + X;
 nTop  := InPanelParent.Top  - 15 + y;


 //Move a Tabela

 // Verifica em cima
 if (nTop  > Image1.Top+1) then
    InPanelParent.Top  := nTop
 else
    InPanelParent.Top  := Image1.Top+1;

 // Verifica esquerda
 if (nLeft  > 0) then
   InPanelParent.Left := nLeft
 else
   InPanelParent.Left := 0;

end;

procedure TfrmQueryEditor.btnAddClick(Sender: TObject);
var
 PanelTabela, PanelCaption : TPanel;
 ListBoxItens : TListBox;
 sNomeTabela  : String;
 nTemp : Integer;
begin

  nTemp       := ComboBoxTabelas.ItemIndex;
  sNomeTabela := ComboBoxTabelas.Items[nTemp];
  ComboBoxTabelas.Items.Delete(nTemp);

  if (ComboBoxTabelas.Items.Count = 0) then begin
    ComboBoxTabelas.Enabled := False;
    btnAdd.Enabled          := False;
  end;

  if ComboBoxTabelas.Enabled then ComboBoxTabelas.ItemIndex := 0;

  // Panel Principal
  PanelTabela          := TPanel.Create(Self);
  PanelTabela.Parent   := Self;
  PanelTabela.BringToFront;
  PanelTabela.Top      := 100;
  PanelTabela.Left     := 242;
  PanelTabela.Caption  := '';
  PanelTabela.Width    := 150;
  PanelTabela.Height   := 180;

  // Panel Titulo
  PanelCaption                := TPanel.Create(Self);
  PanelCaption.Parent         := PanelTabela;
  PanelCaption.Height         := 25;
  PanelCaption.Align          := alTop;
  PanelCaption.Color          := clBlue;
  PanelCaption.Caption        := sNomeTabela;
  PanelCaption.OnMouseDown    := Panel5MouseDown;
  PanelCaption.OnMouseUp      := Panel5MouseUp;
  PanelCaption.OnMouseMove    := Panel5MouseMove;
  PanelCaption.PopupMenu      := PopupMenuTabela;
  PanelCaption.OnContextPopup := Panel1ContextPopup;


  // ListBoxItens
  ListBoxItens := TListBox.Create(Self);
  ListBoxItens.Align := alClient;
  frmPrincipal.SQLConnection1.GetFieldNames(sNomeTabela, ListBoxItens.Items);
  ListBoxItens.Name         := sNomeTabela;
  ListBoxItens.OnDragDrop   := ListBox2DragDrop;
  ListBoxItens.OnMouseDown  := ListBox1MouseDown;
  ListBoxItens.OnMouseMove  := ListBox1MouseMove;
  ListBoxItens.Parent       := PanelTabela;



  with Image1.Canvas do begin
    DrawPoint(-1,-1);
    Pen.Width := 3;
    Pen.Mode := pmCopy;
    MoveTo(0,0);
    LineTo(0,0);
  end;
  Relacionar(sNomeTabela);
end;

procedure TfrmQueryEditor.Delete1Click(Sender: TObject);
  procedure DeletaItens(Nome:String);
  var
     Lista : TConnectArray;
     n     : Integer;
  begin
     Lista := ConnectArray;
     SetLength(ConnectArray, 0);

     for n := 0 to Length(Lista)-1 do
       if (Lista[n].sTabelaDestino <> Nome) and (Lista[n].sTabelaOrigem <> Nome) then
         ConnectArray := AddConnectInArray(Lista[n], Lista);
  end;

var
  InPanelPrincipal : TPanel;
  sTemp : String;
begin
  sTemp := Panel.Caption;
  InPanelPrincipal := (Panel.Parent as TPanel);
  InPanelPrincipal.Destroy;
  ComboBoxTabelas.Items.Add(sTemp);

  if (ComboBoxTabelas.Items.Count <> 0) then begin
    ComboBoxTabelas.Enabled := True;
    btnAdd.Enabled          := True;
  end;

  DeletaItens(sTemp);
  RepaintForm;
end;

procedure TfrmQueryEditor.Panel1ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
  Panel := (Sender as TPanel)
end;

procedure TfrmQueryEditor.BitBtn2Click(Sender: TObject);
begin
 Close;
end;

procedure TfrmQueryEditor.btnOkClick(Sender: TObject);
var
  Lista : TStringList;
  n, nCamp : Integer;
  InListBox : TListBox;
begin
  SetLength(ListArray, 0);
  ListaTabelas := TStringList.Create;

  for n := 0 to Self.ComponentCount -1 do
     if (Self.Components[n] is TListBox) then begin
        InListBox := (Self.Components[n] as TListBox);
          ListaTabelas.Add(InListBox.Name);

        // Adiciona Campos
        Lista := TStringList.Create;
        for nCamp := 0 to InListBox.Items.Count-1 do
            Lista.Add(InListBox.Items[nCamp]);

        ListArray := AddListaInArray(Lista, ListArray);
     end;

  if (ListaTabelas.Count = 0) then begin
     ShowMessage(ErroSemTabela);
     exit;
  end;

  QueryObject.ListaTabelas  := ListaTabelas;
  QueryObject.ListArray     := ListArray;
  QueryObject.ConnectArray  := ConnectArray;
  frmPrincipal.ShowFormChave(QueryObject);
  Close;
end;

procedure TfrmQueryEditor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 AcTion := caFree;
end;

end.
