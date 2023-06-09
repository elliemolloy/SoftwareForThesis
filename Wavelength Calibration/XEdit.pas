unit XEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, StdCtrls, ComCtrls, ExtCtrls,
  Math, Dialogs, Graphics;

type
  { TXBoundLabel }

  TXBoundLabel = class(TCustomLabel)
  private
    function GetTop: Integer;
    function GetLeft: Integer;
    function GetWidth: Integer;
    function GetHeight: Integer;
    procedure SetHeight(const Value: Integer);
    procedure SetWidth(const Value: Integer);
  protected
    procedure AdjustBounds; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property BiDiMode;
    property Caption;
    property Color;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Font;
    property Height: Integer read GetHeight write SetHeight;
    property Left: Integer read GetLeft;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
		property ParentShowHint;
    property PopupMenu;
		property ShowAccelChar;
    property ShowHint;
    property Top: Integer read GetTop;
    property Transparent;
    property Layout;
    property WordWrap;
    property Width: Integer read GetWidth write SetWidth;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  { TXUpDown }

  TXUpDown = class(TCustomUpDown)
  private
		function GetTop: Integer;
    function GetLeft: Integer;
    function GetWidth: Integer;
    function GetHeight: Integer;
    procedure SetHeight(const Value: Integer);
		procedure SetWidth(const Value: Integer);
  protected
    procedure AdjustBounds;
	public
    constructor Create(AOwner: TComponent); override;
  published
    property AlignButton;
    property Anchors;
		property Associate;
    property ArrowKeys;
    property Enabled;
    property Hint;
    property Min;
    property Max;
    property Increment;
    property Constraints;
    property Orientation;
    property ParentShowHint;
    property PopupMenu;
    property Position;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Thousands;
    property Visible;
    property Wrap;
		property OnChanging;
    property OnChangingEx;
    property OnContextPopup;
    property OnClick;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
		property OnMouseMove;
		property OnMouseUp;
	end;

	TXPosition = (lpAbove, lpBelow, lpLeft, lpRight);
	TXUseAs = (lpString, lpInteger, lpFloat);

	{ TCustomXEdit }

	TCustomXEdit = class(TCustomEdit)
	private
		FLabel: TXBoundLabel;
		FCaption: String;
		FUpDown: TXUpDown;
		FTimer: TTimer;
		FEnabled: Boolean;
		FHide: Boolean;
		FHideDisable: Boolean;
		FLabelPosition: TXPosition;
		FUpDownPosition: TXPosition;
		FLabelSpacing: Integer;
		FUpDownSpacing: Integer;
		FUseAs: TXUseAs;
		FFloat: Double;
		FFloatDisplay: Double;
		FFloatMin: Double;
		FFloatMax: Double;
		FFMinChange: Double;
		FFMinChangeBase: Double;
		FDecimals: Byte;
		FMaskDecimals: String;
		FMaskInteger: String;
		FInteger: Integer;
		FIntDisplay: Integer;
		FIntMin: Integer;
		FIntMax: Integer;
		FIMinChange: Integer;
		FIMinChangeBase: Integer;
		FString: String;
		FUseThousands: Boolean;
		FMask: String;
		FKeyShift: Boolean;
		FKeyCtrl: Boolean;
		FKeyPage: Boolean;
		FApplyRangeOnExit: Boolean;

// Timer internal variables
		FStep: Integer;
		FAccBase: Double;
		FIncInterval: Integer;
		FUseStep5: Boolean;

		procedure SetApplyRangeOnExit(const Value: Boolean);
		procedure SetLabelPosition(const Value: TXPosition);
		procedure SetLabelSpacing(const Value: Integer);
		procedure SetUpDownPosition(const Value: TXPosition);
		procedure SetUpDownSpacing(const Value: Integer);
		procedure SetCaption(const Value: String);
		procedure SetString(const Value: String);
		procedure SetInteger(const Value: Integer);
		procedure SetFloat(const Value: Double);
		procedure SetUseAs(const Value: TXUseAs);
		procedure SetUseThousands(const Value: Boolean);
		procedure SetIncInterval(const Value: Integer);
		procedure SetDecimals(const Value: Byte);
		 function GetMinChange(): Double;
		procedure SetMinChange(const Value: Double);
		 function GetMinChangeBase(): Double;
		procedure SetMinChangeBase(const Value: Double);
		procedure SetMask;
		procedure UpdateEdit();
		procedure CheckRange();
		procedure EnsureDiscrete();
	protected
		procedure SetParent(AParent: TWinControl); override;
		procedure Notification(AComponent: TComponent; Operation: TOperation); override;
		procedure SetName(const Value: TComponentName); override;
		procedure CMVisiblechanged(var Message: TMessage); message CM_VISIBLECHANGED;
		procedure CMEnabledchanged(var Message: TMessage); message CM_ENABLEDCHANGED;
		procedure CMBidimodechanged(var Message: TMessage); message CM_BIDIMODECHANGED;

		procedure WMChar(var Message: TWMChar); message WM_CHAR;
		procedure CMChanged(var Message: TMessage); message CM_CHANGED;
		procedure CMExit(var Message: TCMExit); message CM_EXIT;

		procedure Timer(Sender: TObject);
		procedure UpDownClick(Sender: TObject; Button: TUDBtnType);
		procedure UpDownMouseUp(Sender: TObject; Button: TMouseButton;
														Shift: TShiftState; X, Y: Integer);
		procedure UpDownMouseDown(Sender: TObject; Button: TMouseButton;
															Shift: TShiftState; X, Y: Integer);
		procedure WMKeyDown(var Message: TMessage); message WM_KEYDOWN;
		procedure WMKeyUp(var Message: TMessage); message WM_KEYUP;

	public
		constructor Create(AOwner: TComponent); override;
		procedure SetBounds(ALeft: Integer; ATop: Integer; AWidth: Integer; AHeight: Integer); override;
		procedure SetupInternalLabel;
		procedure SetupInternalUpDown;
		procedure SetupInternalTimer;
		property ApplyRangeOnExit: Boolean read FApplyRangeOnExit write SetApplyRangeOnExit;
		property Caption: String read FCaption write SetCaption;
		property LabelPosition: TXPosition read FLabelPosition write SetLabelPosition;
		property UpDownPosition: TXPosition read FUpDownPosition write SetUpDownPosition;
		property LabelSpacing: Integer read FLabelSpacing write SetLabelSpacing;
		property UpDownSpacing: Integer read FUpDownSpacing write SetUpDownSpacing;
		property UseAs: TXUseAs read FUseAs write SetUseAs;
		property sValue: String read FString write SetString;
		property iValue: Integer read FInteger write SetInteger;
		property iMin: Integer read FIntMin write FIntMin;
		property iMax: Integer read FIntMax write FIntMax;
		property dValue: Double read FFloat write SetFloat;
		property dMin: Double read FFloatMin write FFloatMin;
		property dMax: Double read FFloatMax write FFloatMax;
		property MinChange: Double read GetMinChange write SetMinChange;
		property MinChangeBase: Double read GetMinChangeBase write SetMinChangeBase;
		property Decimals: Byte read FDecimals write SetDecimals;
		property UseThousands: Boolean read FUseThousands write SetUseThousands;
		property IncInterval: Integer read FIncInterval write SetIncInterval;
		property UseStep5: Boolean read FUseStep5 write FUseStep5;
		property HideDisable: Boolean read FHideDisable write FHideDisable;
	end;

	{ TXEdit }

	TXEdit = class(TCustomXEdit)
	published
		property Anchors;
		property ApplyRangeOnExit;
		property AutoSelect;
		property Caption Stored True;
		property Color;
		property Enabled;
		property Font;
		property HideSelection;
		property LabelPosition;
		property LabelSpacing;
		property UpDownPosition;
		property UpDownSpacing;
		property MaxLength;
		property ParentColor;
		property ParentFont;
		property ReadOnly;
		property TabOrder;
		property TabStop;
		property UseAs Stored True;
		property Visible;
		property sValue;
		property iValue Stored True;
		property iMin Stored True;
		property iMax Stored True;
		property dValue Stored True;
		property dMin Stored True;
		property dMax Stored True;
		property MinChange Stored True;
		property MinChangeBase Stored True;
		property Decimals Stored True;
		property UseThousands Stored True;
		property IncInterval Stored True;
		property UseStep5 Stored True;
		property HideDisable Stored True;
		property OnChange;
		property OnClick;
		property OnContextPopup;
		property OnDblClick;
		property OnEnter;
		property OnExit;
		property OnKeyDown;
		property OnKeyPress;
		property OnKeyUp;
		property OnMouseDown;
		property OnMouseMove;
		property OnMouseUp;
	end;

procedure Register;
function StrToIntGuaranteed(S: String): Integer;
function StrToFloatGuaranteed(S: String): Double;

implementation

{$R *.dcr}

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

{ TXBoundLabel }

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
constructor TXBoundLabel.Create(AOwner: TComponent);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		inherited Create(AOwner);
		Name := 'Label';
		SetSubComponent(True);
		if Assigned(AOwner) then Caption := AOwner.Name;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TXBoundLabel.AdjustBounds;
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		inherited AdjustBounds;
    if Owner is TCustomXEdit then
      with Owner as TCustomXEdit do SetLabelPosition(LabelPosition);
  end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
function TXBoundLabel.GetHeight: Integer;
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  begin
    Result := inherited Height;
  end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
function TXBoundLabel.GetLeft: Integer;
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		Result := inherited Left;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
function TXBoundLabel.GetTop: Integer;
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  begin
    Result := inherited Top;
  end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
function TXBoundLabel.GetWidth: Integer;
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  begin
    Result := inherited Width;
  end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TXBoundLabel.SetHeight(const Value: Integer);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  begin
    SetBounds(Left, Top, Width, Value);
  end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TXBoundLabel.SetWidth(const Value: Integer);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		SetBounds(Left, Top, Value, Height);
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

{ TXUpDown }

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
constructor TXUpDown.Create(AOwner: TComponent);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		inherited Create(AOwner);
		Name := 'UpDown';
		SetSubComponent(True);
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TXUpDown.AdjustBounds;
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
    if Owner is TCustomXEdit then
      with Owner as TCustomXEdit do SetUpDownPosition(UpDownPosition);
  end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
function TXUpDown.GetHeight: Integer;
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  begin
    Result := inherited Height;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
function TXUpDown.GetLeft: Integer;
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  begin
    Result := inherited Left;
  end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
function TXUpDown.GetTop: Integer;
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  begin
    Result := inherited Top;
  end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
function TXUpDown.GetWidth: Integer;
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  begin
    Result := inherited Width;
  end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TXUpDown.SetHeight(const Value: Integer);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		SetBounds(Left, Top, Width, Value);
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TXUpDown.SetWidth(const Value: Integer);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  begin
    SetBounds(Left, Top, Value, Height);
  end;

//______________________________________________________________________________

{ TCustomXEdit }

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
constructor TCustomXEdit.Create(AOwner: TComponent);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		FIntMin := Low(Integer);
		FIntMax := High(Integer) - 1;
		FIntDisplay := FIntMax + 1;

		FFloatMin := -10000.0;
		FFloatMax := 10000.0;
		FFloatDisplay := FFloatMax + 1;

		FDecimals := 6;
		FUseThousands := True;
		FIncInterval := 4000;

		FStep := 1;

		inherited Create(AOwner);

		FLabelPosition := lpAbove;
		FLabelSpacing := 3;
		SetupInternalLabel;

		FUpDownPosition := lpRight;
		FUpDownSpacing := 0;
		SetupInternalUpDown;

		SetupInternalTimer;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.CMBidimodechanged(var Message: TMessage);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  begin
    inherited;
    FLabel.BiDiMode := BiDiMode;
  end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.CMEnabledchanged(var Message: TMessage);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		FEnabled := Enabled;
		FHide := FHideDisable and not FEnabled;

		inherited;
		FLabel.Enabled := FEnabled;
		FUpDown.Enabled := FEnabled;
		if FEnabled then
			case FUseAs of
				lpString:		sValue := sValue;
				lpInteger:	iValue := iValue;
				lpFloat:		dValue := dValue;
			end
		else if FHide then Text := '';
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.CMVisiblechanged(var Message: TMessage);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  begin
    inherited;
    FLabel.Visible := Visible;
    FUpDown.Visible := Visible;
  end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.Notification(AComponent: TComponent; Operation: TOperation);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  begin
    inherited Notification(AComponent, Operation);

    if Operation = opRemove then
      begin
        if AComponent = FLabel then FLabel := nil;
        if AComponent = FUpDown then FUpDown := nil;
        if AComponent = FTimer then FTimer := nil;
      end;
  end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  begin
    inherited SetBounds(ALeft, ATop, AWidth, AHeight);
    SetLabelPosition(FLabelPosition);
    SetUpDownPosition(FUpDownPosition);
  end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.SetLabelPosition(const Value: TXPosition);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  var P: TPoint;
  begin
		if FLabel = nil then exit;
    FLabelPosition := Value;
    case Value of
      lpAbove: P := Point(Left, Top - FLabel.Height - FLabelSpacing);
      lpBelow: P := Point(Left, Top + Height + FLabelSpacing);
      lpLeft : P := Point(Left - FLabel.Width - FLabelSpacing,
                          Top + ((Height - FLabel.Height) div 2));
      lpRight: P := Point(Left + Width + FLabelSpacing,
                          Top + ((Height - FLabel.Height) div 2));
    end;
    FLabel.SetBounds(P.x, P.y, FLabel.Width, FLabel.Height);
  end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.SetUpDownPosition(const Value: TXPosition);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  var LT, WH: TPoint;
  begin
    if FUpDown = nil then exit;
    FUpDownPosition := Value;
    case Value of
      lpAbove, lpLeft:
               begin
                 LT := Point(Left - (Height * 3) div 4 - FUpDownSpacing, Top);
                 WH := Point((Height * 3) div 4,  // width
                             Height); // height
							 end;
      lpBelow, lpRight:
               begin
                 LT := Point(Left + Width + FUpDownSpacing, Top);
                 WH := Point((Height * 3) div 4,  // width
                             Height); // height
							 end;
    end;
    FUpDown.SetBounds(LT.X, LT.Y, WH.X, WH.Y);
  end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.SetLabelSpacing(const Value: Integer);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		FLabelSpacing := Value;
		SetLabelPosition(FLabelPosition);
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.SetUpDownSpacing(const Value: Integer);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		FUpDownSpacing := Value;
		SetUpDownPosition(FUpDownPosition);
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.SetName(const Value: TComponentName);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		if (csDesigning in ComponentState) and ((FLabel.GetTextLen = 0)
			 or (CompareText(FLabel.Caption, Name) = 0)) then
			FLabel.Caption := Value;

		inherited SetName(Value);
		if csDesigning in ComponentState then Text := '';
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.SetParent(AParent: TWinControl);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  label lbl, ud;
  begin
    inherited SetParent(AParent);
  lbl:
    if FLabel = nil then goto ud;
    FLabel.Parent := AParent;
    FLabel.Visible := (FCaption <> '');
  ud:
    if FUpDown = nil then exit;
    FUpDown.Parent := AParent;
		FUpDown.Visible := True;
  end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.SetupInternalLabel;
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		if Assigned(FLabel) then exit;
		FLabel := TXBoundLabel.Create(Self);
		FLabel.FreeNotification(Self);
		FLabel.FocusControl := Self;
		if Length(FCaption) > 0 then SetCaption(Name);
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.SetupInternalUpDown;
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  begin
    if Assigned(FUpDown) then exit;
    FUpDown := TXUpDown.Create(Self);
    FUpDown.FreeNotification(Self);
    FUpDown.Min := 0;
    FUpDown.Max := 10000;
    FUpDown.Position := 5000;
		FUpDown.OnClick := UpDownClick;
    FUpDown.OnMouseDown := UpDownMouseDown;
		FUpDown.OnMouseUp := UpDownMouseUp;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.SetupInternalTimer;
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  begin
    if Assigned(FTimer) then exit;
    FTimer := TTimer.Create(Self);
    FTimer.FreeNotification(Self);
    FTimer.Enabled := False;
    FTimer.Interval := 4000;
    FTimer.OnTimer := Timer;
  end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.WMChar(var Message: TWMChar);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  var FPos, i: Integer;
	begin
		if FHide then Exit;
		
		if FUseAs = lpString then inherited
		else
			case Chr(Message.CharCode) of
				'0':
						if SelStart = 0 then
							begin
								if (copy(Text, 1, 1) = DecimalSeparator) or
									 (SelLength = Length(Text)) then inherited;
							end
						else // SelStart > 0
							for i := 1 to SelStart do
								if copy(Text, i, 1) <> '0' then
									begin
										inherited;
										Break;
									end;

				'1'..'9': inherited;
				'-':  if (copy(Text, 1, 1) <> '-')
								 and (((FUseAs = lpInteger) and (iMin < 0))
										 or ((FUseAs = lpFloat) and (dMin < 0))) then
								begin
									FPos := SelStart;
									Inc(FPos);
									SelStart := 0;
									inherited;
									SelStart := FPos;
								end;
				'+':  if (copy(Text, 1, 1) = '-')
								 and (((FUseAs = lpInteger) and (iMax > 0))
										 or ((FUseAs = lpFloat) and (dMax > 0))) then
								begin
									FPos := SelStart;
									Dec(FPos);
									SelStart := 1;
									Message.CharCode := 8; // BackSpace
									inherited;
									SelStart := FPos;
								end;
				else if Message.CharCode = 8 then // BackSpace
								begin
									FPos := SelStart;
									Dec(FPos);
									inherited;
									SelStart := FPos;
								end
				else if (Chr(Message.CharCode) = DecimalSeparator)  // ","
								and (FUseAs = lpFloat)
								and (Pos(DecimalSeparator, Text) = 0) then
									begin
										FPos := SelStart;
										Inc(FPos);
										inherited;
										SelStart := FPos;
									end;
			end;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.CMChanged(var Message: TMessage);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	var FPos, FPosRel, i: Integer;
	begin
		FPosRel := 0;
		if FHide Then Exit;

		if FUseAs <> lpString then
			begin
				FPos := SelStart;
				FPosRel := 0;
				for i := 1 to FPos do
					if IsDelimiter('1234567890', Text, i) then Inc(FPosRel);
			end;

		case FUseAs of
			lpString:   FString := Text;
			lpInteger:
				begin
					FInteger := EnsureRange(StrToIntGuaranteed(Text), FIntMin, FIntMax);
					for i := 1 to FPosRel do
						if not IsDelimiter('1234567890', Text, i) then Inc(FPosRel);
				end;
			lpFloat:
				begin
					FFloat := EnsureRange(StrToFloatGuaranteed(Text), FFloatMin, FFloatMax);
					for i := 1 to FPosRel do
						if not IsDelimiter('1234567890', Text, i) then Inc(FPosRel);
				end;
		end;

		inherited;
		if FUseAs <> lpString then SelStart := FPosRel;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.CMExit(var Message: TCMExit);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		if FApplyRangeOnExit and (FUseAs <> lpString) then
			begin
				EnsureDiscrete;
				UpdateEdit;
			end;

		inherited;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.EnsureDiscrete();
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	var iDiscrete: Int64;
	begin
		case FUseAs of
			lpInteger:  if FIMinChange <> 0 then
										begin
											iDiscrete := Round((FInteger - FIMinChangeBase) / FIMinChange);
											FInteger := FIMinChangeBase + iDiscrete * FIMinChange;
										end;

			lpFloat:  	if FFMinChange <> 0 then
										begin
											iDiscrete := Round((FFloat - FFMinChangeBase) / FFMinChange);
											FFloat := FFMinChangeBase + iDiscrete * FFMinChange;
										end;
		end;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.Timer(Sender: TObject);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	{$IFNDEF DELPHI6UP}
		// inline scope
		// SimpleRoundTo is not available in Delphi 5
		function SimpleRoundTo(const AValue: Double; const ADigit: Integer = -2): Double;
			var LFactor: Double;
			begin
				LFactor := IntPower(10, ADigit);
				Result := Trunc((AValue / LFactor) + 0.5) * LFactor;
			end;
	{$ENDIF}

		// IntRoundTo is not available in any Delphi
		function IntRoundTo(const AValue: Integer; const ADigit: Integer = 0): Integer;
			var LFactor: Integer;
			begin
				LFactor := Floor(IntPower(10, ADigit));
				Result := (AValue div LFactor) * LFactor;
			end;

		// IntRoundTo is not available in any Delphi
		function FirstSign(const AValue: Integer): Integer;
			begin
				Result := AValue div Floor(IntPower(10, Floor(Log10(AValue))));
			end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	var iDiff: Integer;
			dDiff: Double;
	begin
		if FUseStep5 then
			begin
				if FirstSign(FStep) = 1
					then FStep := FStep * 5
					else FStep := FStep * 2;
			end
		else FStep := FStep * 10;


		case FUseAs of
			lpInteger:
				begin
					iDiff := FIntMax - FIntMin;
					if iDiff > 50 then
						begin
							if FStep > Floor(IntPower(10, Floor(Log10(iDiff div 10)))) then
								FStep := Floor(IntPower(10, Floor(Log10(iDiff div 10))));
						end
					else FStep := 1;
				end;
			lpFloat:
				begin
					dDiff := (FFloatMax - FFloatMin) / FAccBase;
					if dDiff > 50 then
						begin
							if FStep > Floor(IntPower(10, Floor(Log10(Trunc(dDiff) div 10)))) then
								FStep := Floor(IntPower(10, Floor(Log10(Trunc(dDiff) div 10))));
						end
					else FStep := 1;
				end;
		end;

		case FUseAs of
			lpInteger:  FInteger := IntRoundTo(FInteger, Round(Log10(FStep)));
			lpFloat:    FFloat := SimpleRoundTo(FFloat, Round(Log10(FStep * FAccBase)));
		end;

	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.UpDownClick(Sender: TObject; Button: TUDBtnType);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	var chgTmp: Integer;
	begin
		chgTmp := 0;
		case Button of
			btNext: chgTmp :=  1;
			btPrev: chgTmp := -1;
		end;

		case FUseAs of
			lpInteger:  FInteger := FInteger + FStep * chgTmp;
			lpFloat:    FFloat := 	FFloat	 + FStep * chgTmp * FAccBase;
		end;

		EnsureDiscrete;
		CheckRange;
		UpdateEdit;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.UpDownMouseUp(Sender: TObject; Button: TMouseButton;
																			Shift: TShiftState; X, Y: Integer);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		FStep := 1;
		FTimer.Enabled := False;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.UpDownMouseDown(Sender: TObject; Button: TMouseButton;
																				Shift: TShiftState; X, Y: Integer);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		if not FTimer.Enabled then
			begin
				FStep := 1;
				FTimer.Enabled := True;
			end;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.WMKeyDown(var Message: TMessage);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		if not FTimer.Enabled then
			begin
				FStep := 1;
				FTimer.Enabled := True;
			end;

		if FUseAs = lpString then
			begin
				inherited;
				Exit;
			end;

		case Message.WParam of
			16: begin
						if not FKeyShift then FStep := FStep * 10;
						FKeyShift := True;
					end;
			17: begin
						if not FKeyCtrl then FStep := FStep * 100;
						FKeyCtrl := True;
					end;
			33: begin
						if not FKeyPage then FStep := FStep * 10;
						FKeyPage := True;
						FUpDown.Click(btNext);
					end;
			34: begin
						if not FKeyPage then FStep := FStep * 10;
						FKeyPage := True;
						FUpDown.Click(btPrev);
					end;
			38: FUpDown.Click(btNext);
			40: FUpDown.Click(btPrev);
			else  inherited;
		end;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.WMKeyUp(var Message: TMessage);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		case Message.WParam of
			16: begin // Shift
						FKeyShift := False;
						FStep := FStep div 10;
					end;
			17: begin // Strg
						FKeyCtrl := False;
						FStep := FStep div 100;
					end;
			else
					begin
						FKeyPage := False;
						FStep := ( 1 + Integer(FKeyShift) * 9 ) * ( 1 + Integer(FKeyCtrl) * 99 );
						if FStep = 1 then FTimer.Enabled := False;
						inherited;
					end;
		end;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.UpdateEdit();
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		case FUseAs of
			lpString:   sValue := FString;
			lpInteger:  iValue := FInteger;
			lpFloat:    dValue := FFloat;
		end;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.CheckRange();
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		case FUseAs of
			lpInteger:  FInteger := EnsureRange(FInteger, FIntMin, FIntMax);
			lpFloat:    FFloat := EnsureRange(FFloat, FFloatMin, FFloatMax);
		end;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.SetCaption(const Value: String);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		FCaption := Value;
		FLabel.Caption := FCaption;
		if FCaption = ''
			then FLabel.Visible := False
			else FLabel.Visible := Visible;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.SetString(const Value: String);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		FString := Value;
		if not FHide then Text := Value;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.SetInteger(const Value: Integer);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		FInteger := EnsureRange(Value, FIntMin, FIntMax);
		if not FHide then Text := FormatFloat(FMask, FInteger);
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.SetFloat(const Value: Double);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		FFloat := EnsureRange(Value, FFloatMin, FFloatMax);
		if not FHide then	Text := FormatFloat(FMask, FFloat);
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.SetUseAs(const Value: TXUseAs);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		FUseAs := Value;
		FUpDown.Visible := not (FUseAs = lpString);
    SetMask;
    UpdateEdit;
  end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.SetUseThousands(const Value: Boolean);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  begin
    FUseThousands := Value;
    if FUseThousands then FMaskInteger := '#,##0' else FMaskInteger := '0';
		SetUseAs(FUseAs);
  end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.SetDecimals(const Value: Byte);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
  begin
    FDecimals := Value;
		FMaskDecimals := '.' + StringOfChar('0', FDecimals);
		FAccBase := IntPower(10, -FDecimals);
		case FUseAs of
			lpInteger:  if FIMinChange <> 0 then FAccBase := FIMinChange;
			lpFloat:    if FFMinChange <> 0 then FAccBase := FFMinChange;
		end;
		SetUseAs(FUseAs);
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
function TCustomXEdit.GetMinChange(): Double;
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		Result := 0;
		case FUseAs of
			lpInteger:  Result := FIMinChange;
			lpFloat:    Result := FFMinChange;
		end;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.SetMinChange(const Value: Double);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		case FUseAs of
			lpInteger:  FIMinChange := Floor(Value);
			lpFloat:    FFMinChange := Value;
		end;
		case FUseAs of
			lpInteger:  if FIMinChange <> 0 then FAccBase := FIMinChange;
			lpFloat:    if FFMinChange <> 0 then FAccBase := FFMinChange;
		end;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
function TCustomXEdit.GetMinChangeBase(): Double;
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		Result := 0;
		case FUseAs of
			lpInteger:  Result := FIMinChangeBase;
			lpFloat:    Result := FFMinChangeBase;
		end;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.SetMinChangeBase(const Value: Double);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		case FUseAs of
			lpInteger:  FIMinChangeBase := Floor(Value);
			lpFloat:    FFMinChangeBase := Value;
		end;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.SetMask;
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		case FUseAs of
			lpInteger:  FMask := FMaskInteger;
			lpFloat:    FMask := FMaskInteger + FMaskDecimals;
		end;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.SetIncInterval(const Value: Integer);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		FIncInterval := Value;
		FTimer.Interval := FIncInterval;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure TCustomXEdit.SetApplyRangeOnExit(const Value: Boolean);
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		FApplyRangeOnExit := Value;
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
procedure Register;
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		RegisterComponents('Samples', [TXEdit]);
	end;

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
function StrToIntGuaranteed(S: String): Integer;
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	begin
		Result := Floor(StrToFloatGuaranteed(S));
	end; // StrToIntGuaranteed

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
function StrToFloatGuaranteed(S: String): Double;
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	var p, nDecSeps, iSign: Integer;
	begin
		iSign := 1;
		nDecSeps := 0;
		For p := Length(S) downto 1 do
			begin
				if IsDelimiter('-', S, p) then iSign := -1;
				if not IsDelimiter('1234567890' + DecimalSeparator, S, p) then
					Delete(S, p, 1)
				else if IsDelimiter(DecimalSeparator, S, p) then
					begin
						Inc(nDecSeps);                        // only the last Decimal-
						if nDecSeps > 1 then Delete(S, p, 1); // separator will be used
					end;
			end;

		if Length(S) > 0
      then Result := iSign * StrToFloat(S)
      else Result := 0.0;
  end; // StrToFloatGuaranteed

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

end.
