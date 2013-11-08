unit mzDatePicker;

interface

uses
  SysUtils, Classes, QControls, QStdCtrls, QExtCtrls, QGraphics, DateUtils,
  QComCtrls, Math, QForms, QGrids, Types, QButtons, Qt, mzCustomBtnEditclx;

type
  TDateErrorEvent = procedure(Sender: TObject; ErrorText: string) of object;
  TDoW = (dowMonday,dowTuesday,dowWednesday,dowThursday,
          dowFriday,dowSaturday,dowSunday);
  TDoWSet = set of TDoW;
  TDType = (dtNormal,dtPrevMonth,dtNextMonth,dtCurrent);
  TMonthGridElement = record
                        Day: TDatetime;
                        DType: TDType;
                        Selected: Boolean;
                        DoW: TDoW;
                      end;

  TmzCalendar = class(TFrameControl)
  private
    Alterando : Boolean;
    { Private declarations }
    FFDoW: TDoW;
    FSpecialDays: TDoWSet;
    FSpecialDaysColor: TColor;
    FEnabled: boolean;
    FDate: TDateTime;
    FGraphicToday: boolean;
    FHeaderColor: TColor;
    FTodayLabel: TLabel;
    FHeaderPanel: TPanel;
    FBodyPanel: TPanel;
    FTodayBitmap: TBitmap;
    FGrid: TDrawGrid;
    FMonth: TSpeedButton;
    FYear: TSpinEdit;
    FTodayLabelCaption: String;
    FCreated: boolean;
    FoldMonthFontChangeProc: TNotifyEvent;
    FoldYearFontChangeProc: TNotifyEvent;
    FoldYearColor: TColor;
    FoldYear: Integer;
    FOnDateChanged: TNotifyEvent;
    FOnMouseMove: TMouseMoveEvent;
    FMonthGrid: array[1..7,1..6] of TMonthGridElement;
    FDayNamesFont: TFont;
    FTodayFont: TFont;
    FMonthDayFont: TFont;
    FOtherDayFont: TFont;
    FMinHeaderWidth: Integer;
    FMinBodyWidth: Integer;
    FMinHeaderHeight: Integer;
    FMinBodyHeight: Integer;
    FMinTodayLabelHeight: Integer;
    FOnClick: TNotifyEvent;
    FOnDblClick: TNotifyEvent;
    FCursor: TCursor;
    procedure MonthFontChange(Sender :TObject);
    procedure YearFontChange(Sender :TObject);
    procedure GridFontChange(Sender :TObject);
    procedure TodayLabelClick(Sender :TObject);
    function ReadLabelFont :TFont;
    function ReadLabelColor: TColor;
    procedure SetLabelColor(const Value: TColor);
    function ReadLabelCaption: String;
    procedure SetLabelCaption(const Value: String);
    function ReadHeaderColor: TColor;
    procedure SetHeaderColor(const Value: TColor);
    function TextWidth(Font :TFont; Text :String) :integer;
    function TextHeight(Font :TFont; Text :String) :integer;
    procedure HeaderAutoSizeAndPlace;
    function ReadMonthFont: TFont;
    function ReadYearFont: TFont;
    function ReadCalColor: TColor;
    procedure SetCalColor(const Value: TColor);
    procedure AutoSizeCalendar;
    procedure CalendarDrawCell(Sender: TObject; ACol, ARow: Integer;
                               Rect: TRect; State: TGridDrawState);
    procedure SetFDoW(const Value: TDoW);
    procedure YearOnExit(Sender: TObject);
    procedure YearOnEnter(Sender: TObject);
    procedure DoOnClick(Sender: TObject);
    procedure DoOnDblClick(Sender: TObject);
    procedure SetLabelFont(const Value: TFont);
    procedure SetYearFont(const Value: TFont);
    procedure SetMonthFont(const Value: TFont);
    function MonthName(Dt: TDateTime): String;
    function ReadLabelAlignment: TAlignment;
    procedure SetLabelAlignment(const Value: TAlignment);
    procedure DateChanged;
    procedure ShowMonthMenu(Sender: TObject);
    procedure MonthButtonClick(Sender: TObject);
    procedure YearOnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CloseMonthMenu(Sender: TObject);
    procedure FillMonthGrid;
    function ReadDayNamesFont: TFont;
    procedure SetDayNamesFont(const Value: TFont);
    function ReadTodayFont: TFont;
    procedure SetTodayFont(const Value: TFont);
    function ReadMonthDayFont: TFont;
    procedure SetMonthDayFont(const Value: TFont);
    function ReadOtherDayFont: TFont;
    procedure SetOtherDayFont(const Value: TFont);
    procedure CalendarClick(Sender: TObject);
    procedure SetDate(const Value: TDateTime);
    procedure YearOnMouseMove(Sender: TObject; Shift: TShiftState;
                              X, Y: Integer);
    procedure MonthOnMouseMove(Sender: TObject; Shift: TShiftState;
                               X, Y: Integer);
    procedure HeaderOnMouseMove(Sender: TObject; Shift: TShiftState;
                                X, Y: Integer);
    procedure BodyOnMouseMove(Sender: TObject; Shift: TShiftState;
                              X, Y: Integer);
    procedure GridOnMouseMove(Sender: TObject; Shift: TShiftState;
                              X, Y: Integer);
    procedure TodayLabelOnMouseMove(Sender: TObject; Shift: TShiftState;
                                    X, Y: Integer);
    procedure SetCursor(const Value: TCursor);
    procedure SetGraphicToday(const Value: Boolean);
    procedure SetSDColor(const Value: TColor);
    procedure SetSpecialDays(const Value: TDoWSet);

    procedure SpinEditChanged(Sender: TObject; NewValue: Integer);
    procedure ChangeYear;
  protected
    { Protected declarations }
    procedure Resize; override;
    procedure SetEnabled(const Value: Boolean); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Repaint; override;
    procedure AutoSizeAndPlace;
  published
    { Published declarations }
    property Align;
    property BorderStyle;
    property Date: TDateTime       read FDate write SetDate;
    property FirstDayOfWeek: TDoW  read FFDoW write SetFDoW default dowMonday;
    property DayNamesFont: TFont   read ReadDayNamesFont write SetDayNamesFont;
    property TodayFont: TFont      read ReadTodayFont write SetTodayFont;
    property MonthDayFont: TFont   read ReadMonthDayFont write SetMonthDayFont;
    property OtherDayFont: TFont   read ReadOtherDayFont write SetOtherDayFont;
    property CalendarColor: TColor read ReadCalColor  write SetCalColor;
    property HeaderColor: TColor   read ReadHeaderColor write SetHeaderColor;
    property MonthFont: TFont      read ReadMonthFont write SetMonthFont;
    property YearFont: TFont       read ReadYearFont write SetYearFont;
    property TodayLabelFont: TFont read ReadLabelFont write SetLabelFont;
    property TodayLabelColor: TColor read ReadLabelColor write SetLabelColor;
    property TodayLabelCaption: String read ReadLabelCaption
                                       write SetLabelCaption;
    property TodayLabelAlignment: TAlignment read ReadLabelAlignment
                                             write SetLabelAlignment;
    property Enabled: Boolean      read FEnabled write SetEnabled;
    property GraphicToday: Boolean read FGraphicToday write SetGraphicToday;
    property Cursor: TCursor       read FCursor write SetCursor;
    property OnResize;
    property OnDateChanged: TNotifyEvent read FOnDateChanged
                                         write FOnDateChanged;
    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property SpecialDaysColor: TColor read FSpecialDaysColor write SetSDColor;
    property SpecialDays: TDoWSet read FSpecialDays write SetSpecialDays;
    property TabStop;
    property TabOrder;
    property ShowHint;
    property ParentShowHint;
  end;

 TDropDownCalendar = class(TPersistent)
  private
    { Private declarations }
    FSpecialDays: TDoWSet;
    FSpecialDaysColor: TColor;
    FWidth: Integer;
    FHeight: Integer;
    FCalendarColor: TColor;
    FFDoW: TDoW;
    FHeaderColor: TColor;
    FHint: string;
    FTLC: TColor;
    FTLCaption: string;
    FTLAlign: TAlignment;
    FTodayLabelFont: TFont;
    FMonthFont: TFont;
    FYearFont: TFont;
    FDayNamesFont: TFont;
    FTodayFont: TFont;
    FMonthDayFont: TFont;
    FOtherDayFont: TFont;
    FCursor: TCursor;
    FGraphicToday: boolean;
    procedure SetWidth(const Value: Integer);
    procedure SetCalendarColor(const Value: TColor);
    procedure SetFDoW(const Value: TDoW);
    procedure SetHeaderColor(const Value: TColor);
    procedure SetHint(const Value: string);
    procedure SetTLC(const Value: TColor);
    procedure SetTLCaption(const Value: string);
    procedure SetTLAlign(const Value: TAlignment);
    function ReadLabelFont: TFont;
    function ReadMonthFont: TFont;
    function ReadYearFont: TFont;
    procedure SetLabelFont(const Value: TFont);
    procedure SetMonthFont(const Value: TFont);
    procedure SetYearFont(const Value: TFont);
    procedure SetHeight(const Value: Integer);
    function ReadDayNamesFont: TFont;
    procedure SetDayNamesFont(const Value: TFont);
    function ReadTodayFont: TFont;
    procedure SetTodayFont(const Value: TFont);
    function ReadMonthDayFont: TFont;
    procedure SetMonthDayFont(const Value: TFont);
    function ReadOtherDayFont: TFont;
    procedure SetOtherDayFont(const Value: TFont);
    procedure SetCursor(const Value: TCursor);
    procedure SetGraphicToday(const Value: Boolean);
    procedure SetSDColor(const Value: TColor);
    procedure SetSpecialDays(const Value: TDoWSet);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;
  published
    { Published declarations }
    property Width: Integer read FWidth write SetWidth;
    property Height: Integer read FHeight write SetHeight;
    property CalendarColor: TColor read FCalendarColor write SetCalendarColor;
    property TodayLabelColor: TColor read FTLC write SetTLC;
    property TodayLabelCaption: string read FTLCaption write SetTLCaption;
    property TodayLabelAlignment: TAlignment read FTLAlign write SetTLAlign;
    property FirstDayOfWeek: TDoW read FFDoW write SetFDoW;
    property HeaderColor: TColor read FHeaderColor write SetHeaderColor;
    property Hint: string read FHint write SetHint;
    property Cursor: TCursor read FCursor write SetCursor;
    property MonthFont: TFont read ReadMonthFont write SetMonthFont;
    property YearFont: TFont read ReadYearFont write SetYearFont;
    property TodayLabelFont: TFont read ReadLabelFont write SetLabelFont;
    property DayNamesFont: TFont read ReadDayNamesFont write SetDayNamesFont;
    property TodayFont: TFont read ReadTodayFont write SetTodayFont;
    property MonthDayFont: TFont read ReadMonthDayFont write SetMonthDayFont;
    property OtherDayFont: TFont read ReadOtherDayFont write SetOtherDayFont;
    property GraphicToday: Boolean read FGraphicToday write SetGraphicToday;
    property SpecialDaysColor: TColor read FSpecialDaysColor write SetSDColor;
    property SpecialDays: TDoWSet read FSpecialDays write SetSpecialDays;
 end;


  TmzDatePicker = class(TmzCustomBtnEditclx)
  private
    { Private declarations }
    FDate: TDateTime;
    FoldEditValue: String;
    FGlyphBitmap: TBitmap;
    FOnDateChanged: TNotifyEvent;
    FEnabled: boolean;
    FCreated: boolean;
    FDropDownCalendar: TDropDownCalendar;
    FOnDateError: TDateErrorEvent;
    FOnMouseMove: TMouseMoveEvent;
    FOnClick: TNotifyEvent;
    FOnDblClick: TNotifyEvent;
    FAlignment: TAlignment;
    FCursor: TCursor;
    FOnKeyUp: TKeyEvent;
    FOnKeyDown: TKeyEvent;
    FOnKeyPress: TKeyPressEvent;
    FOnEnter: TNotifyEvent;
    procedure CalendarDateChanged(Sender: TObject);
    procedure SetDate(const Value: TDateTime);
    procedure DateChanged;
    procedure CloseDropDownCalendar(Sender: TObject);
    function ReadDropDownCalendar: TDropDownCalendar;
    procedure SetDropDownCalendar(const Value: TDropDownCalendar);
  protected
    { Protected declarations }
    procedure EditOnEnter(Sender: TObject);
    procedure EditOnExit(Sender: TObject);
    procedure SetEnabled(const Value: Boolean); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure ExecuteClick; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property Date: TDateTime read FDate write SetDate;
    property Enabled: Boolean read FEnabled write SetEnabled;
    property BorderStyle;
    property TabStop;
    property TabOrder;
    property OnResize;
    property OnDateChanged: TNotifyEvent read FOnDateChanged
                                         write FOnDateChanged;
    property OnDateError: TDateErrorEvent read FOnDateError
                                          write FOnDateError;
    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnKeyDown: TKeyEvent read FOnKeyDown write FOnKeyDown;
    property OnKeyUp: TKeyEvent read FOnKeyUp write FOnKeyUp;
    property OnKeyPress: TKeyPressEvent read FOnKeyPress write FOnKeyPress;
    property OnEnter: TNotifyEvent read FOnEnter write FOnEnter;
    property OnExit;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property DropDownCalendar: TDropDownCalendar read ReadDropDownCalendar
                                                 write SetDropDownCalendar;
    property ShowHint;
    property ParentShowHint;
 end;


procedure Register;

implementation
{$R *.res}


// ************************ TmzCalendarario ************************

procedure TmzCalendar.AutoSizeAndPlace;
const
 MinSpaceX = 5;
 MinSpaceY = 5;
begin
  HeaderAutoSizeAndPlace;
  AutoSizeCalendar;
  FMinTodayLabelHeight := TextHeight(FTodayLabel.Font,FTodayLabel.Caption);
  Constraints.MinHeight := FMinBodyHeight+FMinHeaderHeight+
                           FMinTodayLabelHeight+MinSpaceY*2;
  if Height < Constraints.MinHeight then Height := Constraints.MinHeight;
  Constraints.MinWidth := max(FMinBodyWidth,FMinHeaderWidth)+MinSpaceX;
  if Width < Constraints.MinWidth then Width := Constraints.MinWidth;
end;

procedure TmzCalendar.AutoSizeCalendar;
var
  maxCellHeight, maxCellWidth: Integer;
  i: Byte;
  DayName: String;
const
  minSpaceX = 6;
  minSpaceY = 2;
begin
  maxCellHeight := 0;
  maxCellWidth := 0;
  //Find Max width and height of the text in the cells
  //DayNames
  for i := 1 to 7 do
   begin
    DayName := UpperCase(copy(ShortDayNames[i],1,1)) +
               copy(ShortDayNames[i],2,length(ShortDayNames[i])-1);
    maxCellHeight := max(TextHeight(FDayNamesFont,DayName),maxCellHeight);
    maxCellWidth := max(TextWidth(FDayNamesFont,DayName),maxCellWidth);
   end;
  //Today
  maxCellHeight := max(TextHeight(FTodayFont,'00'),maxCellHeight);
  maxCellWidth := max(TextWidth(FTodayFont,'00'),maxCellWidth);
  //MonthDays
  maxCellHeight := max(TextHeight(FMonthDayFont,'00'),maxCellHeight);
  maxCellWidth := max(TextWidth(FMonthDayFont,'00'),maxCellWidth);
  //OtherDays
  maxCellHeight := max(TextHeight(FOtherDayFont,'00'),maxCellHeight);
  maxCellWidth := max(TextWidth(FOtherDayFont,'00'),maxCellWidth);
  maxCellHeight := maxCellHeight+minSpaceY;
  maxCellWidth :=  maxCellWidth+minSpaceX;
  for i := 0 to 6 do FGrid.ColWidths[i] := maxCellWidth;
  for i := 0 to 6 do FGrid.RowHeights[i] := maxCellHeight;
  FGrid.Width := maxCellWidth*7;
  FGrid.Height := maxCellHeight*7;
  FGrid.Left := (FGrid.Parent.Width-FGrid.Width) div 2;
  FGrid.Top := (FGrid.Parent.Height-FGrid.Height) div 2;
  FMinBodyWidth := FGrid.Width;
  FMinBodyHeight := FGrid.Height;
  FGrid.Invalidate;
end;

procedure TmzCalendar.BodyOnMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  If Assigned(FOnMouseMove) then
    FOnMouseMove(Self,Shift,FBodyPanel.Left+X,FBodyPanel.Top+Y);
end;

procedure TmzCalendar.CalendarClick(Sender: TObject);
var
  MyRow,MyCol: Integer;
begin
  DoOnClick(Self);
  with FGrid.ScreenToClient(Mouse.CursorPos) do FGrid.MouseToCell(X,Y,MyCol,MyRow);
  if (MyCol<0) or (MyCol>6) or (MyRow<1) or (MyRow>6) then exit;
  if DateOf(FDate) <> DateOf(FMonthGrid[MyCol+1,MyRow].Day) then begin
    FDate := FMonthGrid[MyCol+1,MyRow].Day;
    DateChanged;
  end;
end;

procedure TmzCalendar.CalendarDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  DayName: string;
  WeekDay: Byte;
  isSelected: Boolean;
begin
  isSelected := False;
  if ARow = 0 then begin
    //First Row (DayNames Row)
    WeekDay := 1;
    case FFDow of
     dowSunday: WeekDay := 1;
     dowMonday: WeekDay := 2;
     dowTuesday: WeekDay := 3;
     dowWednesday: WeekDay := 4;
     dowThursday: WeekDay := 5;
     dowFriday: WeekDay := 6;
     dowSaturday: WeekDay := 7;
    end;
    DayName := ShortDayNames[((ACol+WeekDay-1) mod 7) + 1];
    DayName := UpperCase(copy(DayName,1,1)) + copy(DayName,2,length(DayName)-1);
    FGrid.Canvas.Font.Assign(FDayNamesFont);
  end
  else begin
    //Other Rows
    DayName := IntToStr(DayOf(FMonthGrid[ACol+1,ARow].Day));
    case FMonthGrid[ACol+1,ARow].DType of
     dtCurrent: FGrid.Canvas.Font.Assign(FTodayFont);
     dtPrevMonth,dtNextMonth: FGrid.Canvas.Font.Assign(FOtherDayFont);
     dtNormal: FGrid.Canvas.Font.Assign(FMonthDayFont);
    end;

    if ( (FMonthGrid[ACol+1,ARow].DoW in FSpecialDays) and (FMonthGrid[ACol+1,ARow].DType = dtNormal) ) then FGrid.Canvas.Font.Color := FSpecialDaysColor;
    if FMonthGrid[ACol+1,ARow].Selected then isSelected := True;
  end;

   with FGrid.Canvas do begin
     Brush.Color := FGrid.Color;
     Brush.Style := bsSolid;
     FillRect(Rect);
     if ARow = 0 then begin
       Pen.Style := psSolid;
       Pen.Width := 1;
       if ACol = 0 then
           MoveTo(Rect.Left+2,Rect.Bottom-1)
       else
           MoveTo(Rect.Left,Rect.Bottom-1);

       if ACol = 6 then
           LineTo(Rect.Right-2,Rect.Bottom-1)
       else
           LineTo(Rect.Right,Rect.Bottom-1);
     end;
     if isSelected then begin
       Pen.Style := psDot;
       Pen.Width := 1;
       Font.Style := Font.Style + [fsUnderline];
       Font.Weight := fwBold;
       Rectangle(Rect);
     end;
     if FGraphicToday AND (FMonthGrid[ACol+1,ARow].DType = dtCurrent) then begin
       StretchDraw(Rect,FTodayBitmap);
      end;
     TextRect(Rect,Rect.Left,Rect.Top,DayName,ord(AlignmentFlags_AlignCenter));
   end;
end;

procedure TmzCalendar.CloseMonthMenu(Sender: TObject);
begin
  (Sender as TForm).Close;
end;

constructor TmzCalendar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSpecialDaysColor := clRed;
  FSpecialDays := [];
  FTodayBitmap := TBitmap.Create;
  FTodayBitmap.LoadFromResourceName(HInstance,'MZTODAY');
  FTodayBitmap.Transparent := True;
  FGraphicToday := True;
  FCreated := false;
  FCursor := crDefault;
  TabStop := True;
  Constraints.MinWidth := 0;
  Constraints.MinHeight := 0;
  FMinHeaderWidth := 0;
  FMinBodyWidth := 0;
  FMinHeaderHeight := 0;
  FMinBodyHeight := 0;
  FMinTodayLabelHeight := 0;
  FEnabled := True;
  Self.BorderStyle := bsRaisedPanel;
  FDate := DateOf(Now);

  //Create & Setup Header
  FHeaderPanel := TPanel.Create(Self);
  with FHeaderPanel do
   begin
    Parent := Self;
    Align := alTop;
    BorderStyle := bsNone;
    BevelOuter := bvNone;
    BevelInner := bvNone;
    Color := $00A70000;
    Cursor := FCursor;
    FHeaderColor := Color;
    OnMouseMove := HeaderOnMouseMove;
    OnClick := DoOnClick;
    OnDblClick := DoOnDblClick;
  end;

  FMonth := TSpeedButton.Create(FHeaderPanel);
  with FMonth do begin
    Parent := FHeaderPanel;
    Flat := True;
    Caption := MonthName(FDate);
    Font.Color := clWhite;
    Font.Style := [fsBold];
    FoldMonthFontChangeProc := Font.OnChange;
    Font.OnChange := MonthFontChange;
    Cursor := FCursor;
    OnClick := ShowMonthMenu;
    OnDblClick := DoOnDblClick;
    OnMouseMove := MonthOnMouseMove;
  end;

  FYear := TSpinEdit.Create(FHeaderPanel);
  with FYear do begin
    Parent := FHeaderPanel;
    FoldYearFontChangeProc := Font.OnChange;
    Font.OnChange := YearFontChange;
    Font.Color := clWhite;
    Color := FHeaderPanel.Color;
    BorderStyle := bsNone;
    Font.Style := [fsBold];
    Cursor := FCursor;
    OnExit := YearOnExit;
    OnEnter := YearOnEnter;
    OnClick := YearOnEnter;
    OnKeyUp := YearOnKeyUp;
    OnMouseMove := YearOnMouseMove;
    TabStop := False;
    Value := YearOf(fDate);
    Min := 10;
    Max := 9999;
    Value := YearOf(fDate);
    FoldYear := Value;
    OnClick := DoOnClick;
//    OnDblClick := DoOnDblClick;
    OnChanged := SpinEditChanged;
  end;
  HeaderAutoSizeAndPlace;

  //Create & Setup Grid (Body)
  FBodyPanel := TPanel.Create(Self);
  with FBodyPanel do begin
    Parent := Self;
    Align := alClient;
    BorderStyle := bsNone;
    BevelOuter := bvNone;
    BevelInner := bvNone;
    Color := clWhite;
    Cursor := FCursor;
    OnMouseMove := BodyOnMouseMove;
    OnClick := DoOnClick;
    OnDblClick := DoOnDblClick;
  end;
  FillMonthGrid;

  FGrid := TDrawGrid.Create(FBodyPanel);
  with FGrid do begin
    Parent := FBodyPanel;
    Color := FBodyPanel.Color;
    Options := [];
    FixedCols := 0;
    FixedRows := 0;
    ScrollBars := ssNone;
    BorderStyle := bsNone;
    DefaultDrawing := False;
    //Cursor := FCursor; This does not work in Kylix 3... Kylix's Bug?
    OnDrawCell := CalendarDrawCell;
    OnClick := CalendarClick;
    OnDblClick := DoOnDblClick;
    OnMouseMove := GridOnMouseMove;
    RowCount := 7;
    ColCount := 7;
  end;

  //Set Grid's cursor... for some reason in Kylix3 the "Cursor" property
  //does not work.
  QWidget_unsetCursor(FGrid.Handle);
  QWidget_setCursor(FGrid.Handle,Screen.Cursors[FCursor]);

  FDayNamesFont := TFont.Create;
  with FDayNamesFont do begin
    Style := [fsBold];
    Color := clBlack;
    OnChange := GridFontChange;
  end;

  FTodayFont := TFont.Create;
  with FTodayFont do begin
    Style := [];
    Color := clBlue;
    OnChange := GridFontChange;
  end;

  FMonthDayFont := TFont.Create;
  with FMonthDayFont do begin
    Style := [];
    Color := clBlack;
    OnChange := GridFontChange;
  end;
  FOtherDayFont := TFont.Create;

  with FOtherDayFont do begin
    Size := FMonthDayFont.Size - 2;
    Style := [];
    Color := clSilver;
    OnChange := GridFontChange;
  end;
  AutoSizeCalendar;
  //Create & Setup Today Label (Footer)
  FTodayLabel := TLabel.Create(Self);
  with FTodayLabel do begin
    Parent := Self;
    fTodayLabelCaption := 'Today:';
    Caption := ' ' + FTodayLabelCaption + ' ' + DateToStr(fDate) + ' ';
    Align := alBottom;
    Alignment := taCenter;
    Font.Color := clBlack;
    Font.Style := [fsBold];
    Cursor := FCursor;
    OnMouseMove := TodayLabelOnMouseMove;
    OnClick := TodayLabelClick;
    OnDblClick := DoOnDblClick;
    Color := clWhite;
  end;
  FCreated := true;
end;

procedure TmzCalendar.DateChanged;
begin
  FYear.Value := YearOf(FDate);
  FMonth.Caption := MonthName(FDate);
  FillMonthGrid;
  FGrid.Invalidate;
  if Assigned(FOnDateChanged) then FOnDateChanged(Self);
end;

destructor TmzCalendar.Destroy;
begin
  FreeAndNil(FTodayLabel);
  FreeAndNil(FOtherDayFont);
  FreeAndNil(FMonthDayFont);
  FreeAndNil(FTodayFont);
  FreeAndNil(FDayNamesFont);
  FreeAndNil(FBodyPanel);
  FreeAndNil(FYear);
  FreeAndNil(FMonth);
  FreeAndNil(FHeaderPanel);
  FreeAndNil(FTodayBitmap);
  inherited;
end;

procedure TmzCalendar.DoOnDblClick(Sender: TObject);
begin
  if Assigned(FOnDblClick) then FOnDblClick(Self);
end;

procedure TmzCalendar.DoOnClick(Sender: TObject);
begin
  if Assigned(FOnClick) then FOnClick(Self);
end;

procedure TmzCalendar.FillMonthGrid;
var
  CurDate: TDateTime;
  i,j: Byte;
  FirstWeekDay: Byte;
begin
  CurDate := EncodeDate(YearOf(FDate),MonthOf(FDate),1);
  FirstWeekDay := 1;
  case FFDow of
   dowMonday: FirstWeekDay := 1;
   dowTuesday: FirstWeekDay := 2;
   dowWednesday: FirstWeekDay := 3;
   dowThursday: FirstWeekDay := 4;
   dowFriday: FirstWeekDay := 5;
   dowSaturday: FirstWeekDay := 6;
   dowSunday: FirstWeekDay := 7;
  end;

  while DayOfTheWeek(CurDate) <> FirstWeekDay do CurDate := IncDay(CurDate,-1);
  for j := 1 to 6 do
   for i := 1 to 7 do begin
     FMonthGrid[i,j].Day := CurDate;
     FMonthGrid[i,j].Selected := False;
     FMonthGrid[i,j].DType := dtNormal;
     if isSameDay(CurDate,Now) then FMonthGrid[i,j].DType := dtCurrent;
     if isSameDay(CurDate,FDate) then FMonthGrid[i,j].Selected := True;

     if MonthOf(CurDate) <> MonthOf(FDate) then begin
       if CurDate < FDate then
          FMonthGrid[i,j].DType := dtPrevMonth
       else
          FMonthGrid[i,j].DType := dtNextMonth;
     end;

     case DayOfTheWeek(CurDate) of
      1: FMonthGrid[i,j].DoW := dowMonday;
      2: FMonthGrid[i,j].DoW := dowTuesday;
      3: FMonthGrid[i,j].DoW := dowWednesday;
      4: FMonthGrid[i,j].DoW := dowThursday;
      5: FMonthGrid[i,j].DoW := dowFriday;
      6: FMonthGrid[i,j].DoW := dowSaturday;
      7: FMonthGrid[i,j].DoW := dowSunday;
     end;
     CurDate := IncDay(CurDate,1);
   end;
end;

procedure TmzCalendar.GridOnMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  If Assigned(FOnMouseMove) then FOnMouseMove(Self,Shift,FGrid.Left+X, FBodyPanel.Top+FGrid.Top+Y);
end;

procedure TmzCalendar.HeaderAutoSizeAndPlace;
const
  MinSpaceX = 10;
  TopPos = 7;
var
  i :byte;
  temp :integer;
begin
  //Fix vertical position and Header height
  FMonth.Top := TopPos;
  FYear.Top := TopPos;
  temp := Max(FMonth.Height,FYear.Height);
  FHeaderPanel.Height := temp+TopPos*2;

  //Fix horizontal positions and widths
  temp := 0;
  for i := 1 to 12 do
     temp := Max(temp,TextWidth(FMonth.Font,LongMonthNames[i]));
  FMonth.Width := temp+10;
  FYear.Width := TextWidth(fYear.Font,'0000')+40;
  FMinHeaderWidth := FMonth.Width + FYear.Width + MinSpaceX*3;
  temp := Width - (FMonth.Width + FYear.Width);
  temp := temp div 3;
  FMonth.Left := temp;
  FYear.Left := FMonth.Left + FMonth.Width + temp;
  FMonth.Height := max(FMonth.Height,FYear.Height);
  FYear.Height := FMonth.Height;
  FMinHeaderHeight := FHeaderPanel.Height;
end;

procedure TmzCalendar.HeaderOnMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  If Assigned(FOnMouseMove) then
   begin
    FOnMouseMove(Self,Shift,FHeaderPanel.Left+X,FHeaderPanel.Top+Y);
   end;
end;

procedure TmzCalendar.MonthButtonClick(Sender: TObject);
var
  MyObj: TObject;
  MyYear,MyMonth,MyDay: Word;
  MyIntMonth: Integer;
begin
  DecodeDate(FDate,MyYear,MyMonth,MyDay);
  MyIntMonth := StrToInt(Copy((Sender as TSpeedButton).Name,3,
                              length((Sender as TSpeedButton).Name)-2));
  MyObj := (Sender as TSpeedButton).Parent.Parent;
  (MyObj as TForm).Close;
  if DateOf(FDate) <> EncodeDate(MyYear,MyIntMonth,MyDay) then
   begin
    FDate := EncodeDate(MyYear,MyIntMonth,MyDay);
    DateChanged;
   end;
end;

procedure TmzCalendar.MonthFontChange(Sender: TObject);
begin
  FoldMonthFontChangeProc(Sender);
  AutoSizeAndPlace;
end;

function TmzCalendar.MonthName(Dt: TDateTime): String;
begin
  Result := LongMonthNames[MonthOf(Dt)];
  ReSult := UpperCase(Copy(Result,1,1))+Copy(Result,2,Length(Result)-1);
end;

procedure TmzCalendar.MonthOnMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  If Assigned(FOnMouseMove) then
   begin
    FOnMouseMove(Self,Shift,FMonth.Left+X,FMonth.Top+Y);
   end;
end;

function TmzCalendar.ReadCalColor: TColor;
begin
  Result := FBodyPanel.Color;
end;

function TmzCalendar.ReadDayNamesFont: TFont;
begin
  Result := FDayNamesFont;
end;

function TmzCalendar.ReadHeaderColor: TColor;
begin
  Result := FHeaderColor;
end;

function TmzCalendar.ReadLabelAlignment: TAlignment;
begin
  Result := FTodayLabel.Alignment;
end;

function TmzCalendar.ReadLabelCaption: string;
begin
  Result := FTodayLabelCaption;
end;

function TmzCalendar.ReadLabelColor: TColor;
begin
  Result := FTodayLabel.Color;
end;

function TmzCalendar.ReadLabelFont: TFont;
begin
  Result := FTodayLabel.Font;
end;

function TmzCalendar.ReadMonthDayFont: TFont;
begin
  Result := FMonthDayFont;
end;

function TmzCalendar.ReadMonthFont: TFont;
begin
  Result := FMonth.Font;
end;

function TmzCalendar.ReadOtherDayFont: TFont;
begin
  Result := FOtherDayFont;
end;

function TmzCalendar.ReadTodayFont: TFont;
begin
  Result := FTodayFont;
end;

function TmzCalendar.ReadYearFont: TFont;
begin
  Result := FYear.Font;
end;

procedure TmzCalendar.Repaint;
begin
  inherited;
  AutoSizeAndPlace;
  FHeaderPanel.Repaint;
  FBodyPanel.Repaint;
  FTodayLabel.Repaint;
  FYear.Repaint;
  FMonth.Repaint;
  FGrid.Repaint;
end;

procedure TmzCalendar.Resize;
begin
  inherited;
  if FCreated then AutoSizeAndPlace;
end;

procedure TmzCalendar.SetCalColor(const Value: TColor);
begin
  FBodyPanel.Color := Value;
  FGrid.Color := Value;
  FBodyPanel.Invalidate;
  FGrid.Invalidate;
end;

procedure TmzCalendar.SetDate(const Value: TDateTime);
begin
  if DateOf(FDate) <> DateOf(Value) then begin
    FDate := DateOf(Value);
    DateChanged;
    Self.Text := DateToStr(FDate);
   end;
end;

procedure TmzCalendar.SetDayNamesFont(const Value: TFont);
begin
  FDayNamesFont.Assign(Value);
  FGrid.Invalidate;
end;

procedure TmzCalendar.SetEnabled(const Value: Boolean);
begin
  inherited;
  if FEnabled <> Value then
   begin
    FEnabled := Value;
    FGrid.Enabled := Value;
    FYear.Enabled := Value;
    FMonth.Enabled := Value;
    FTodayLabel.Enabled := Value;
    FHeaderPanel.Enabled := Value;
    FBodyPanel.Enabled := Value;
    if FEnabled then
        FHeaderPanel.Color := FHeaderColor
     else
        FHeaderPanel.Color := clDisabledBackGround;
   end;
end;

procedure TmzCalendar.SetFDoW(const Value: TDoW);
begin
  FFDoW := Value;
  FillMonthGrid;
  FGrid.Invalidate;
end;

procedure TmzCalendar.SetHeaderColor(const Value: TColor);
begin
  FHeaderColor := Value;
  FHeaderPanel.Color := Value;
  FYear.Color := Value;
end;

procedure TmzCalendar.SetLabelAlignment(const Value: TAlignment);
begin
  FTodayLabel.Alignment := Value;
end;

procedure TmzCalendar.SetLabelCaption(const Value: string);
begin
  FTodayLabelCaption := Value;
  FTodayLabel.Caption := ' ' + FTodayLabelCaption + ' ' + DateToStr(Now) + ' ';
end;

procedure TmzCalendar.SetLabelColor(const Value: TColor);
begin
  FTodayLabel.Color := Value;
end;

procedure TmzCalendar.SetLabelFont(const Value: TFont);
begin
  FTodayLabel.Font.Assign(Value);
end;

procedure TmzCalendar.SetMonthDayFont(const Value: TFont);
begin
  FMonthDayFont.Assign(Value);
  FGrid.Invalidate;
end;

procedure TmzCalendar.SetMonthFont(const Value: TFont);
begin
  FMonth.Font.Assign(Value);
end;

procedure TmzCalendar.SetOtherDayFont(const Value: TFont);
begin
  FOtherDayFont.Assign(Value);
  FGrid.Invalidate;
end;

procedure TmzCalendar.SetTodayFont(const Value: TFont);
begin
  FTodayFont.Assign(Value);
  FGrid.Invalidate;
end;

procedure TmzCalendar.SetYearFont(const Value: TFont);
begin
  FYear.Font.Assign(Value);
end;

procedure TmzCalendar.ShowMonthMenu(Sender: TObject);
var
 MyTempForm: TForm;
 i: Byte;
 MyTop: Integer;
 MyPoint: TPoint;
 MyFrame: TPanel;
begin
  DoOnClick(Self);
  MyTempForm := TForm.Create(Application);
  try
   with MyTempForm do
    begin
     Parent := Self;
     BorderStyle := fbsNone;
     MyPoint.X := FMonth.Left;
     MyPoint.Y := FMonth.Top + FMonth.Height;
     Left := Parent.ClientToScreen(MyPoint).X;
     Top := Parent.ClientToScreen(MyPoint).Y+1;
     MyTop := 0;
     OnDeactivate := CloseMonthMenu;
     MyFrame := TPanel.Create(MyTempForm);
     with MyFrame do
      begin
       Parent := MyTempForm;
       Align := alClient;
       Color := clWhite;
       BorderStyle := bsNone;
       BevelOuter := bvLowered;
       BevelInner := bvNone;
      end;
     Width := FMonth.Width*2+2;
     for i := 1 to 12 do
      begin
       with TSpeedButton.Create(MyFrame) do
        begin
         Font.Assign(FMonth.Font);
         Caption := UpperCase(Copy(LongMonthNames[i],1,1))+
                    Copy(LongMonthNames[i],2,Length(LongMonthNames[i])-1);
         Font.Color := clBlack;
         Name := 'BT'+IntToStr(i);
         Parent := MyFrame;
         Flat := True;
         Height := FMonth.Height;
         Width := FMonth.Width;
         OnClick := MonthButtonClick;
         if Odd(i) then
          begin
           Left := 1;
           Top := MyTop;
          end else
          begin
           Left := Width+1;
           Top := MyTop;
           MyTop := MyTop+Height;
          end;
        end;
      end;
     Height := MyTop;
     QOpenWidget_setWFlags(QOpenWidgetH(MyTempForm.Handle),
                           Cardinal(WidgetFlags_WType_Popup));
     ShowModal;
    end;
  finally
   for i := 1 to 12 do MyTempForm.FindComponent('BT'+IntToStr(i)).Free;
   FreeAndNil(MyFrame);
   FreeAndNil(MyTempForm);
  end;
end;

function TmzCalendar.TextHeight(Font: TFont; Text: String): integer;
var
  MyBitmap :TBitmap;
begin
  MyBitmap := TBitmap.Create; //We need a temporary Canvas
                              //if you need speed you should create this once
                              //for all in the component's Create procedure
  MyBitmap.Width := 1;
  MyBitmap.Height := 1;
  MyBitmap.Canvas.Font := Font;
  Result := MyBitmap.Canvas.TextHeight(Text);
  FreeAndNil(MyBitmap);
end;

function TmzCalendar.TextWidth(Font: TFont; Text: String): integer;
var
  MyBitmap :TBitmap;
begin
  MyBitmap := TBitmap.Create; //We need a temporary Canvas
                              //if you need speed you should create this once
                              //for all in the component's Create procedure
  MyBitmap.Width := 1;
  MyBitmap.Height := 1;
  MyBitmap.Canvas.Font := Font;
  Result := MyBitmap.Canvas.TextWidth(Text);
  FreeAndNil(MyBitmap);
end;

procedure TmzCalendar.TodayLabelOnMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  If Assigned(FOnMouseMove) then
   begin
    FOnMouseMove(Self,Shift,FTodayLabel.Left+X,FTodayLabel.Top+Y);
   end;
end;

procedure TmzCalendar.YearFontChange(Sender: TObject);
begin
  FoldYearFontChangeProc(Sender);
  if FCreated then AutoSizeAndPlace;
end;

procedure TmzCalendar.YearOnEnter(Sender: TObject);
begin
  if not Alterando then begin
    FoldYear := FYear.Value;
    FYear.Color := clWhite;
    FoldYearColor := FYear.Font.Color;
    FYear.Font.Color := clBlack;
  end;
  Alterando := True;
end;

procedure TmzCalendar.ChangeYear;
var
  MyYear, MyMonth, MyDay: Word;
  MyIntYear: Integer;
begin
  if length(IntToStr(FYear.Value)) <> 4 then FYear.Value := FoldYear;
  if TryStrToInt(IntToStr(FYear.Value),MyIntYear) then begin
    if (MyIntYear >= 1000) AND (MyIntYear <= 9999) AND (FYear.Value <> FoldYear) then begin
      DecodeDate(FDate,MyYear,MyMonth,MyDay);
      FDate := EncodeDate(MyIntYear,MyMonth,MyDay);
      DateChanged;
     end
     else
       FYear.Value := FoldYear;
  end
  else
      FYear.Value := FoldYear;
end;


procedure TmzCalendar.SpinEditChanged(Sender: TObject; NewValue: Integer);
begin
{  FoldYear := FYear.Value;
  FYear.Color := clWhite;
  FoldYearColor := FYear.Font.Color;
  FYear.Font.Color := clBlack; }
  ChangeYear;
end;


procedure TmzCalendar.YearOnExit(Sender: TObject);
begin
  FYear.Color := FHeaderPanel.Color;
  FYear.Font.Color := FoldYearColor;
  ChangeYear;
  Alterando := False;
end;

procedure TmzCalendar.YearOnKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = Key_Return then FGrid.SetFocus;
  if Key = Key_Escape then FYear.Value := FoldYear;
end;

procedure TmzCalendar.YearOnMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  If Assigned(FOnMouseMove) then
   begin
    FOnMouseMove(Self,Shift,FYear.Left+X,FYear.Top+Y);
   end;
end;

procedure TmzCalendar.SetCursor(const Value: TCursor);
begin
  FCursor := Value;
  QWidget_unsetCursor(Handle);
  QWidget_setCursor(Handle,Screen.Cursors[FCursor]);
  //Set Grid's cursor... for some reason in Kylix3 the "Cursor" property
  //does not work.
  QWidget_unsetCursor(FGrid.Handle);
  QWidget_setCursor(FGrid.Handle,Screen.Cursors[FCursor]);
  FBodyPanel.Cursor := FCursor;
  FTodayLabel.Cursor := FCursor;
  FHeaderPanel.Cursor := FCursor;
  FMonth.Cursor := FCursor;
end;

procedure TmzCalendar.GridFontChange(Sender: TObject);
begin
  //We do not need to call the previous FontChange handler
  //because this is used only by us.
  AutoSizeAndPlace;
end;

procedure TmzCalendar.SetGraphicToday(const Value: Boolean);
begin
  FGraphicToday := Value;
  FGrid.Refresh;
end;

procedure TmzCalendar.TodayLabelClick(Sender: TObject);
begin
  DoOnClick(Self);
  FDate := DateOf(Now);
  DateChanged;
end;

procedure TmzCalendar.SetSDColor(const Value: TColor);
begin
  FSpecialDaysColor := Value;
  FGrid.Refresh;
end;

procedure TmzCalendar.SetSpecialDays(const Value: TDoWSet);
begin
  FSpecialDays := Value;
  FGrid.Refresh;
end;


// ************************ TDropDownCalendar ************************

constructor TDropDownCalendar.Create;
begin
  FGraphicToday := True;
  FSpecialDays := [];
  FSpecialDaysColor := clRed;
  FWidth := 0;
  FHeight := 0;
  FCursor := crDefault;
  FCalendarColor := clWhite;
  FHeaderColor := $00A70000;
  FTLC := clWhite;
  FTLCaption := 'Today:';
  FTLAlign := taCenter;

  FTodayLabelFont := TFont.Create;
  with FTodayLabelFont do begin
    Color := clBlack;
    Style := [fsBold];
  end;

  FMonthFont := TFont.Create;
  with FMonthFont do begin
    Color := clWhite;
    Style := [fsBold];
  end;

  FYearFont := TFont.Create;
  with FYearFont do begin
    Color := clWhite;
    Style := [fsBold];
  end;

  FDayNamesFont := TFont.Create;
  with FDayNamesFont do begin
    Style := [fsBold];
    Color := clBlack;
  end;

  FTodayFont := TFont.Create;
  with FTodayFont do begin
    Style := [];
    Color := clBlue;
  end;

  FMonthDayFont := TFont.Create;
  with FMonthDayFont do begin
    Style := [];
    Color := clBlack;
  end;

  FOtherDayFont := TFont.Create;
  with FOtherDayFont do begin
    Size := FMonthDayFont.Size - 2;
    Style := [];
    Color := clSilver;
  end;
end;

destructor TDropDownCalendar.Destroy;
begin
  FreeAndNil(FOtherDayFont);
  FreeAndNil(FMonthDayFont);
  FreeAndNil(FTodayFont);
  FreeAndNil(FDayNamesFont);
  FreeAndNil(FYearFont);
  FreeAndNil(FMonthFont);
  FreeAndNil(FTodayLabelFont);
  inherited;
end;

function TDropDownCalendar.ReadDayNamesFont: TFont;
begin
  Result := FDayNamesFont;
end;

function TDropDownCalendar.ReadLabelFont: TFont;
begin
  Result := FTodayLabelFont;
end;

function TDropDownCalendar.ReadMonthDayFont: TFont;
begin
  Result := FMonthDayFont;
end;

function TDropDownCalendar.ReadMonthFont: TFont;
begin
  Result := FMonthFont;
end;

function TDropDownCalendar.ReadOtherDayFont: TFont;
begin
  Result := FOtherDayFont;
end;

function TDropDownCalendar.ReadTodayFont: TFont;
begin
  Result := FTodayFont;
end;

function TDropDownCalendar.ReadYearFont: TFont;
begin
  Result := FYearFont;
end;

procedure TDropDownCalendar.SetCalendarColor(const Value: TColor);
begin
  FCalendarColor := Value;
end;

procedure TDropDownCalendar.SetCursor(const Value: TCursor);
begin
  FCursor := Value;
end;

procedure TDropDownCalendar.SetDayNamesFont(const Value: TFont);
begin
  FDayNamesFont.Assign(Value);
end;

procedure TDropDownCalendar.SetFDoW(const Value: TDoW);
begin
  FFDoW := Value;
end;

procedure TDropDownCalendar.SetGraphicToday(const Value: Boolean);
begin
  FGraphicToday := Value;
end;

procedure TDropDownCalendar.SetHeaderColor(const Value: TColor);
begin
  FHeaderColor := Value;
end;

procedure TDropDownCalendar.SetHeight(const Value: Integer);
begin
  FHeight := Value;
end;

procedure TDropDownCalendar.SetHint(const Value: string);
begin
  FHint := Value;
end;

procedure TDropDownCalendar.SetLabelFont(const Value: TFont);
begin
  FTodayLabelFont.Assign(Value);
end;

procedure TDropDownCalendar.SetMonthDayFont(const Value: TFont);
begin
  FMonthDayFont.Assign(Value);
end;

procedure TDropDownCalendar.SetMonthFont(const Value: TFont);
begin
  FMonthFont.Assign(Value);
end;

procedure TDropDownCalendar.SetOtherDayFont(const Value: TFont);
begin
  FOtherDayFont.Assign(Value);
end;

procedure TDropDownCalendar.SetSDColor(const Value: TColor);
begin
  FSpecialDaysColor := Value;
end;

procedure TDropDownCalendar.SetSpecialDays(const Value: TDoWSet);
begin
  FSpecialDays := Value;
end;

procedure TDropDownCalendar.SetTLAlign(const Value: TAlignment);
begin
  FTLAlign := Value;
end;

procedure TDropDownCalendar.SetTLC(const Value: TColor);
begin
  FTLC := Value;
end;

procedure TDropDownCalendar.SetTLCaption(const Value: string);
begin
  FTLCaption := Value;
end;

procedure TDropDownCalendar.SetTodayFont(const Value: TFont);
begin
  FTodayFont.Assign(Value);
end;

procedure TDropDownCalendar.SetWidth(const Value: Integer);
begin
  FWidth := Value;
end;

procedure TDropDownCalendar.SetYearFont(const Value: TFont);
begin
  FYearFont.Assign(Value);
end;


// ************************ TmzDatePicker ************************

constructor TmzDatePicker.Create(AOwner: TComponent);
var
  i,k,j: Byte;
begin
  inherited Create(AOwner);
  FDropDownCalendar := TDropDownCalendar.Create;
  btnEdit.Glyph.LoadFromResourceName(HInstance,'TMZCALENDAR');
  with FDropDownCalendar do
   begin
    Height := 0;
    Width := 0;
   end;
  FCreated := false;
  FEnabled := True;
  FCursor := crDefault;
  FDate := DateOf(Now);
  Self.Text:= DateTimeToStr(FDate);
  TabStop := True;
  Height := 25;
  Width := 100;
  FAlignment := taCenter;

  FGlyphBitmap := TBitmap.Create;
  with FGlyphBitmap do
   begin
    Width := 16;
    Height := 5;
    Canvas.Brush.Color := clButton;
    Canvas.Brush.Style := bsSolid;
    Canvas.FillRect(Rect(0,0,16,5));
    Canvas.Pen.Color := clBlack;
    k := 0;
    j := (Width div 2) - 1;
    for i := 0 to (Height-2) do
     begin
      Canvas.MoveTo(k,i);
      Canvas.LineTo(j,i);
      dec(j);
      inc(k);
     end;
    Canvas.Pen.Color := clDisabledLight;
    k := (Width div 2) + 1;
    j := Width;
    for i := 1 to (Height-1) do
     begin
      Canvas.MoveTo(k,i);
      Canvas.LineTo(j,i);
      dec(j);
      inc(k);
     end;
    Canvas.Pen.Color := clDisabledMid;
    k := (Width div 2);
    j := Width-1;
    for i := 0 to Height-2 do
     begin
      Canvas.MoveTo(k,i);
      Canvas.LineTo(j,i);
      dec(j);
      inc(k);
     end;
    Transparent := True;
   end;
  FCreated := true;
end;


procedure TmzDatePicker.ExecuteClick;
var
  MyTempForm: TForm;
  MyTempCalendar: TmzCalendar;
  MyPoint: TPoint;
begin
  MyTempForm := TForm.Create(Application);
  try
   with MyTempForm do
    begin
     Parent := Self;
     MyPoint.X := 0;
     MyPoint.Y := Parent.Height;
     VertScrollBar.Visible := False;
     HorzScrollBar.Visible := False;
     ShowHint := Parent.ShowHint;
     Left := Parent.ClientToScreen(MyPoint).X-2;
     Top := Parent.ClientToScreen(MyPoint).Y-2;
     BorderStyle := fbsNone;
     MyTempCalendar := TmzCalendar.Create(MyTempForm);
     with MyTempCalendar do
      begin
       Date := Self.Date;
       Parent := MyTempForm;
       ShowHint := Parent.ShowHint;
       Name := 'Calendar';
       Left := 0;
       with FDropDownCalendar do
        begin
         if Height <> 0 then MyTempCalendar.Height := Height;
         if Width <> 0 then MyTempCalendar.Width := Width;
         if CalendarColor <> MyTempCalendar.CalendarColor
          then MyTempCalendar.CalendarColor := CalendarColor;
         if FFDoW <> MyTempCalendar.FirstDayOfWeek
          then MyTempCalendar.FirstDayOfWeek := FFDoW;
         if FHeaderColor <> MyTempCalendar.HeaderColor
          then MyTempCalendar.HeaderColor := FHeaderColor;
         if FHint <> MyTempCalendar.Hint then MyTempCalendar.Hint := FHint;
         if FTLC <> MyTempCalendar.TodayLabelColor
          then MyTempCalendar.TodayLabelColor := FTLC;
         if FTLCaption <> MyTempCalendar.TodayLabelCaption
          then MyTempCalendar.TodayLabelCaption := FTLCaption;
         if FTLAlign <> MyTempCalendar.TodayLabelAlignment
          then MyTempCalendar.TodayLabelAlignment := FTLAlign;
         if Cursor <> MyTempCalendar.Cursor
          then MyTempCalendar.Cursor := Cursor;
         if FGraphicToday <> MyTempCalendar.GraphicToday
          then MyTempCalendar.GraphicToday := FGraphicToday;
         if FSpecialDays <> MyTempCalendar.SpecialDays
          then MyTempCalendar.SpecialDays := FSpecialDays;
         if FSpecialDaysColor <> MyTempCalendar.SpecialDaysColor
          then MyTempCalendar.SpecialDaysColor := FSpecialDaysColor;
         MyTempCalendar.MonthFont.Assign(FMonthFont);
         MyTempCalendar.YearFont.Assign(FYearFont);
         MyTempCalendar.TodayLabelFont.Assign(FTodayLabelFont);
         MyTempCalendar.DayNamesFont.Assign(FDayNamesFont);
         MyTempCalendar.TodayFont.Assign(FTodayFont);
         MyTempCalendar.MonthDayFont.Assign(FMonthDayFont);
         MyTempCalendar.OtherDayFont.Assign(FOtherDayFont);
        end;
       AutoSizeAndPlace;
       Width := Constraints.MinWidth;
       Height := Constraints.MinHeight;
       Parent.Width := Width;
       Parent.Height := Height;
       OnDateChanged := CalendarDateChanged;
       OnDblClick := CloseDropDownCalendar;
      end;
     QOpenWidget_setWFlags(QOpenWidgetH(MyTempForm.Handle),
                           Cardinal(WidgetFlags_WType_Popup));
     ShowModal;
     SetDate(StrToDate(Self.Text));
    end;
  finally
   FreeAndNil(MyTempForm);
  end;
end;


procedure TmzDatePicker.CalendarDateChanged(Sender: TObject);
begin
  Self.Text := DateToStr((Sender as TmzCalendar).Date);
end;

procedure TmzDatePicker.CloseDropDownCalendar(Sender: TObject);
begin
  ((Sender as TmzCalendar).Parent as TForm).Close;
end;

procedure TmzDatePicker.DateChanged;
begin
  if Assigned(FOnDateChanged) then FOnDateChanged(Self);
end;

destructor TmzDatePicker.Destroy;
begin
  FreeAndNil(FGlyphBitmap);
  FreeAndNil(FDropDownCalendar);
  inherited;
end;

procedure TmzDatePicker.EditOnEnter(Sender: TObject);
begin
  FoldEditValue := Self.Text;
end;

procedure TmzDatePicker.EditOnExit(Sender: TObject);
begin
  try
   SetDate(StrToDate(Self.Text));
  except
   If Assigned(FOnDateError) then FOnDateError(Self,Self.Text);
   Self.Text := FoldEditValue;
  end;
end;


procedure TmzDatePicker.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Assigned(FOnMouseMove) then
   begin
    FOnMouseMove(Self,Shift,X,Y);
   end;
end;


function TmzDatePicker.ReadDropDownCalendar: TDropDownCalendar;
begin
  Result := FDropDownCalendar;
end;

procedure TmzDatePicker.SetDate(const Value: TDateTime);
begin
  if DateOf(FDate) <> DateOf(Value) then begin
    FDate := DateOf(Value);
    FoldEditValue := DateToStr(FDate);
    Self.Text := FoldEditValue;
    DateChanged;
   end;
end;

procedure TmzDatePicker.SetDropDownCalendar(
  const Value: TDropDownCalendar);
begin
  FDropDownCalendar.Assign(Value);
end;

procedure TmzDatePicker.SetEnabled(const Value: Boolean);
begin
  FEnabled := Value;
end;


procedure Register;
begin
  RegisterComponents('Master', [TmzCalendar]);
  RegisterComponents('Master', [TmzDatePicker]);
end;

end.
