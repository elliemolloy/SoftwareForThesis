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

//——————————————————————————————————————————————————————————————————————————————

{ TXBoundLabel }

//——————————————————————————————————————————————————————————————————————————————
constructor TXBoundLabel.Create(AOwner: TComponent);
//——————————————————————————————————————————————————————————————————————————————
	begin
		inherited Create(AOwner);
		Name := 'Label';
		SetSubComponent(True);
		if Assigned(AOwner) then Caption := AOwner.Name;
	end;

//——————————————————————————————————————————————————————————————————————————————
procedure TXBoundLabel.AdjustBounds;
//——————————————————————————————————————————————————————————————————————————————
	begin
		inherited AdjustBounds;
    if Owner is TCustomXEdit then
      with Owner as TCustomXEdit do SetLabelPosition(LabelPosition);
  end;

//——————————————————————————————————————————————————————————————————————————————
function TXBoundLabel.GetHeight: Integer;
//——————————————————————————————————————————————————————————————————————————————
  begin
    Result := inherited Height;
  end;

//——————————————————————————————————————————————————————————————————————————————
function TXBoundLabel.GetLeft: Integer;
//——————————————————————————————————————————————————————————————————————————————
	begin
		Result := inherited Left;
	end;

//——————————————————————————————————————————————————————————————————————————————
function TXBoundLabel.GetTop: Integer;
//——————————————————————————————————————————————————————————————————————————————
  begin
    Result := inherited Top;
  end;

//——————————————————————————————————————————————————————————————————————————————
function TXBoundLabel.GetWidth: Integer;
//——————————————————————————————————————————————————————————————————————————————
  begin
    Result := inherited Width;
  end;

//——————————————————————————————————————————————————————————————————————————————
procedure TXBoundLabel.SetHeight(const Value: Integer);
//——————————————————————————————————————————————————————————————————————————————
  begin
    SetBounds(Left, Top, Width, Value);
  end;

//——————————————————————————————————————————————————————————————————————————————
procedure TXBoundLabel.SetWidth(const Value: Integer);
//——————————————————————————————————————————————————————————————————————————————
	begin
		SetBounds(Left, Top, Value, Height);
	end;

//——————————————————————————————————————————————————————————————————————————————

{ TXUpDown }

//——————————————————————————————————————————————————————————————————————————————
constructor TXUpDown.Create(AOwner: TComponent);
//——————————————————————————————————————————————————————————————————————————————
	begin
		inherited Create(AOwner);
		Name := 'UpDown';
		SetSubComponent(True);
	end;

//——————————————————————————————————————————————————————————————————————————————
procedure TXUpDown.AdjustBounds;
//——————————————————————————————————————————————————————————————————————————————
	begin
    if Owner is TCustomXEdit then
      with Owner as TCustomXEdit do SetUpDownPosition(UpDownPosition);
  end;

//——————————————————————————————————————————————————————————————————————————————
function TXUpDown.GetHeight: Integer;
//——————————————————————————————————————————————————————————————————————————————
  begin
    Result := inherited Height;
	end;

//——————————————————————————————————————————————————————————————————————————————
function TXUpDown.GetLeft: Integer;
//——————————————————————————————————————————————————————————————————————————————
  begin
    Result := inherited Left;
  end;

//——————————————————————————————————————————————————————————————————————————————
function TXUpDown.GetTop: Integer;
//——————————————————————————————————————————————————————————————————————————————
  begin
    Result := inherited Top;
  end;

//——————————————————————————————————————————————————————————————————————————————
function TXUpDown.GetWidth: Integer;
//——————————————————————————————————————————————————————————————————————————————
  begin
    Result := inherited Width;
  end;

//——————————————————————————————————————————————————————————————————————————————
procedure TXUpDown.SetHeight(const Value: Integer);
//——————————————————————————————————————————————————————————————————————————————
	begin
		SetBounds(Left, Top, Width, Value);
	end;

//——————————————————————————————————————————————————————————————————————————————
procedure TXUpDown.SetWidth(const Value: Integer);
//——————————————————————————————————————————————————————————————————————————————
  begin
    SetBounds(Left, Top, Value, Height);
  end;

//______________________________________________________________________________

{ TCustomXEdit }

//——————————————————————————————————————————————————————————————————————————————
constructor TCustomXEdit.Create(AOwner: TComponent);
//——————————————————————————————————————————————————————————————————————————————
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

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.CMBidimodechanged(var Message: TMessage);
//——————————————————————————————————————————————————————————————————————————————
  begin
    inherited;
    FLabel.BiDiMode := BiDiMode;
  end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.CMEnabledchanged(var Message: TMessage);
//——————————————————————————————————————————————————————————————————————————————
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

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.CMVisiblechanged(var Message: TMessage);
//——————————————————————————————————————————————————————————————————————————————
  begin
    inherited;
    FLabel.Visible := Visible;
    FUpDown.Visible := Visible;
  end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.Notification(AComponent: TComponent; Operation: TOperation);
//——————————————————————————————————————————————————————————————————————————————
  begin
    inherited Notification(AComponent, Operation);

    if Operation = opRemove then
      begin
        if AComponent = FLabel then FLabel := nil;
        if AComponent = FUpDown then FUpDown := nil;
        if AComponent = FTimer then FTimer := nil;
      end;
  end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
//——————————————————————————————————————————————————————————————————————————————
  begin
    inherited SetBounds(ALeft, ATop, AWidth, AHeight);
    SetLabelPosition(FLabelPosition);
    SetUpDownPosition(FUpDownPosition);
  end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.SetLabelPosition(const Value: TXPosition);
//——————————————————————————————————————————————————————————————————————————————
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

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.SetUpDownPosition(const Value: TXPosition);
//——————————————————————————————————————————————————————————————————————————————
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

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.SetLabelSpacing(const Value: Integer);
//——————————————————————————————————————————————————————————————————————————————
	begin
		FLabelSpacing := Value;
		SetLabelPosition(FLabelPosition);
	end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.SetUpDownSpacing(const Value: Integer);
//——————————————————————————————————————————————————————————————————————————————
	begin
		FUpDownSpacing := Value;
		SetUpDownPosition(FUpDownPosition);
	end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.SetName(const Value: TComponentName);
//——————————————————————————————————————————————————————————————————————————————
	begin
		if (csDesigning in ComponentState) and ((FLabel.GetTextLen = 0)
			 or (CompareText(FLabel.Caption, Name) = 0)) then
			FLabel.Caption := Value;

		inherited SetName(Value);
		if csDesigning in ComponentState then Text := '';
	end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.SetParent(AParent: TWinControl);
//——————————————————————————————————————————————————————————————————————————————
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

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.SetupInternalLabel;
//——————————————————————————————————————————————————————————————————————————————
	begin
		if Assigned(FLabel) then exit;
		FLabel := TXBoundLabel.Create(Self);
		FLabel.FreeNotification(Self);
		FLabel.FocusControl := Self;
		if Length(FCaption) > 0 then SetCaption(Name);
	end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.SetupInternalUpDown;
//——————————————————————————————————————————————————————————————————————————————
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

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.SetupInternalTimer;
//——————————————————————————————————————————————————————————————————————————————
  begin
    if Assigned(FTimer) then exit;
    FTimer := TTimer.Create(Self);
    FTimer.FreeNotification(Self);
    FTimer.Enabled := False;
    FTimer.Interval := 4000;
    FTimer.OnTimer := Timer;
  end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.WMChar(var Message: TWMChar);
//——————————————————————————————————————————————————————————————————————————————
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

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.CMChanged(var Message: TMessage);
//——————————————————————————————————————————————————————————————————————————————
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

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.CMExit(var Message: TCMExit);
//——————————————————————————————————————————————————————————————————————————————
	begin
		if FApplyRangeOnExit and (FUseAs <> lpString) then
			begin
				EnsureDiscrete;
				UpdateEdit;
			end;

		inherited;
	end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.EnsureDiscrete();
//——————————————————————————————————————————————————————————————————————————————
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

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.Timer(Sender: TObject);
//——————————————————————————————————————————————————————————————————————————————
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

//——————————————————————————————————————————————————————————————————————————————
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

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.UpDownClick(Sender: TObject; Button: TUDBtnType);
//——————————————————————————————————————————————————————————————————————————————
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

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.UpDownMouseUp(Sender: TObject; Button: TMouseButton;
																			Shift: TShiftState; X, Y: Integer);
//——————————————————————————————————————————————————————————————————————————————
	begin
		FStep := 1;
		FTimer.Enabled := False;
	end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.UpDownMouseDown(Sender: TObject; Button: TMouseButton;
																				Shift: TShiftState; X, Y: Integer);
//——————————————————————————————————————————————————————————————————————————————
	begin
		if not FTimer.Enabled then
			begin
				FStep := 1;
				FTimer.Enabled := True;
			end;
	end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.WMKeyDown(var Message: TMessage);
//——————————————————————————————————————————————————————————————————————————————
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

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.WMKeyUp(var Message: TMessage);
//——————————————————————————————————————————————————————————————————————————————
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

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.UpdateEdit();
//——————————————————————————————————————————————————————————————————————————————
	begin
		case FUseAs of
			lpString:   sValue := FString;
			lpInteger:  iValue := FInteger;
			lpFloat:    dValue := FFloat;
		end;
	end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.CheckRange();
//——————————————————————————————————————————————————————————————————————————————
	begin
		case FUseAs of
			lpInteger:  FInteger := EnsureRange(FInteger, FIntMin, FIntMax);
			lpFloat:    FFloat := EnsureRange(FFloat, FFloatMin, FFloatMax);
		end;
	end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.SetCaption(const Value: String);
//——————————————————————————————————————————————————————————————————————————————
	begin
		FCaption := Value;
		FLabel.Caption := FCaption;
		if FCaption = ''
			then FLabel.Visible := False
			else FLabel.Visible := Visible;
	end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.SetString(const Value: String);
//——————————————————————————————————————————————————————————————————————————————
	begin
		FString := Value;
		if not FHide then Text := Value;
	end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.SetInteger(const Value: Integer);
//——————————————————————————————————————————————————————————————————————————————
	begin
		FInteger := EnsureRange(Value, FIntMin, FIntMax);
		if not FHide then Text := FormatFloat(FMask, FInteger);
	end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.SetFloat(const Value: Double);
//——————————————————————————————————————————————————————————————————————————————
	begin
		FFloat := EnsureRange(Value, FFloatMin, FFloatMax);
		if not FHide then	Text := FormatFloat(FMask, FFloat);
	end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.SetUseAs(const Value: TXUseAs);
//——————————————————————————————————————————————————————————————————————————————
	begin
		FUseAs := Value;
		FUpDown.Visible := not (FUseAs = lpString);
    SetMask;
    UpdateEdit;
  end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.SetUseThousands(const Value: Boolean);
//——————————————————————————————————————————————————————————————————————————————
  begin
    FUseThousands := Value;
    if FUseThousands then FMaskInteger := '#,##0' else FMaskInteger := '0';
		SetUseAs(FUseAs);
  end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.SetDecimals(const Value: Byte);
//——————————————————————————————————————————————————————————————————————————————
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

//——————————————————————————————————————————————————————————————————————————————
function TCustomXEdit.GetMinChange(): Double;
//——————————————————————————————————————————————————————————————————————————————
	begin
		Result := 0;
		case FUseAs of
			lpInteger:  Result := FIMinChange;
			lpFloat:    Result := FFMinChange;
		end;
	end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.SetMinChange(const Value: Double);
//——————————————————————————————————————————————————————————————————————————————
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

//——————————————————————————————————————————————————————————————————————————————
function TCustomXEdit.GetMinChangeBase(): Double;
//——————————————————————————————————————————————————————————————————————————————
	begin
		Result := 0;
		case FUseAs of
			lpInteger:  Result := FIMinChangeBase;
			lpFloat:    Result := FFMinChangeBase;
		end;
	end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.SetMinChangeBase(const Value: Double);
//——————————————————————————————————————————————————————————————————————————————
	begin
		case FUseAs of
			lpInteger:  FIMinChangeBase := Floor(Value);
			lpFloat:    FFMinChangeBase := Value;
		end;
	end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.SetMask;
//——————————————————————————————————————————————————————————————————————————————
	begin
		case FUseAs of
			lpInteger:  FMask := FMaskInteger;
			lpFloat:    FMask := FMaskInteger + FMaskDecimals;
		end;
	end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.SetIncInterval(const Value: Integer);
//——————————————————————————————————————————————————————————————————————————————
	begin
		FIncInterval := Value;
		FTimer.Interval := FIncInterval;
	end;

//——————————————————————————————————————————————————————————————————————————————
procedure TCustomXEdit.SetApplyRangeOnExit(const Value: Boolean);
//——————————————————————————————————————————————————————————————————————————————
	begin
		FApplyRangeOnExit := Value;
	end;

//——————————————————————————————————————————————————————————————————————————————

//——————————————————————————————————————————————————————————————————————————————
procedure Register;
//——————————————————————————————————————————————————————————————————————————————
	begin
		RegisterComponents('Samples', [TXEdit]);
	end;

//——————————————————————————————————————————————————————————————————————————————
function StrToIntGuaranteed(S: String): Integer;
//——————————————————————————————————————————————————————————————————————————————
	begin
		Result := Floor(StrToFloatGuaranteed(S));
	end; // StrToIntGuaranteed

//——————————————————————————————————————————————————————————————————————————————
function StrToFloatGuaranteed(S: String): Double;
//——————————————————————————————————————————————————————————————————————————————
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

//——————————————————————————————————————————————————————————————————————————————

end.
