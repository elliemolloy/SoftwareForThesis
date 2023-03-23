unit DetGraph;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ComCtrls, Menus, Math, Printers,Clipbrd, ImgList, ActnList,
  StdCtrls, DetGlobal, DirectPrint;

const

	MaxCurves=6;
	MaxPoints=1001;

	InsideGraph:Byte=1;
	OutsideGraph:Byte=2;
	OnHandle:Byte=4;

type
	
	TDisplayValue=array[0..20] of Char;
	TNumPoints=array[1..MaxCurves] of Integer;
	TAxisSelected=(xAxis,yAxis);
	THandleHit=(TopLeft,TopRight,BottomLeft,BottomRight,BottomMid,MidLeft,MidRight,TopMid,NoHandle);
	TPlotType=(Small,Big,Line,BigLine,DashLine);
	TDataSource=(ClipB,TextF);

	TGraphFonts=record
		xTitleFont,yTitleFont,xNumberFont,yNumberFont:TFont;
	end;

	TGraphStyle=record
		xAxisScaleToWindow,yAxisScaleToWindow:Boolean;
		xAxisLength,yAxisLength:string[20];
		xMin,xMax,yMin,yMax,xInterval,yInterval:Extended;
		xNumPlaces,yNumPlaces,xNumMinorTicks,yNumMinorTicks:Integer;
		xMajorTickSize,xMinorTickSize,yMajorTickSize,yMinorTickSize:Integer;
		xMaxAuto,xMinAuto,xIncAuto,xTicksAuto,xDecAuto:Word;
		yMaxAuto,yMinAuto,yIncAuto,yTicksAuto,yDecAuto:Word;
		xTitleAuto,yTitleAuto:Boolean;
		xMajorGrid,xMinorGrid,yMajorGrid,yMinorGrid:Word;
		xMaxDispPlaces,xMinDispPlaces,xIncDispPlaces:Integer;
		yMaxDispPlaces,yMinDispPlaces,yIncDispPlaces:Integer;
		AxisMax,AxisMin:TPoint;
		PlotType:array[1..MaxCurves] of TPlotType;
		CurveColour:array[1..MaxCurves] of TColor;
	end;

	TGraphWindow = class(TForm)
    GraphPopupMenu: TPopupMenu;
    xAxisPopup: TMenuItem;
    yAxisPopup: TMenuItem;
    LineStylePopup: TMenuItem;
    N2: TMenuItem;
    CopyGraphPopup: TMenuItem;
    SaveFileDialog: TSaveDialog;
    OpenGraphStyleDlg: TOpenDialog;
		SaveGraphStyleDlg: TSaveDialog;
    N1: TMenuItem;
    PrintGraphPopup: TMenuItem;
    PrintGraphDialog: TPrintDialog;
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);
    procedure xAxisMenuClick(Sender: TObject);
    procedure yAxisMenuClick(Sender: TObject);
    procedure LineStyleMenuClick(Sender: TObject);
    procedure CopyMenuClick(Sender: TObject);
    procedure GraphPopupMenuPopup(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure SetGraphStyle;
		procedure SaveGraphStyleAs;
		procedure SetToDefaultStyle;
		procedure SetCurrentStyleAsDefault;
		procedure WMMove(var Msg:TMessage); message wm_Move;
    procedure PrintGraphPopupClick(Sender: TObject);
	private
		{ Private declarations }
		FirstClick:TPoint;
		OldxMin,OldxMax,OldyMin,OldyMax:Extended;
		GraphDeselected,ButtonDown,Moved,FirstMove,Copying:Boolean;
    DoubleClicked:Boolean;
		WhereClicked:Byte;
		HandleHit:THandleHit;
		NumRedraws:Integer;
		function GetWhereClicked(PointClicked:TPoint):Byte; virtual;
		procedure DrawHandles; virtual;
		procedure ChangeAxisSettings(AxisSelected:TAxisSelected); virtual;
	public
		{ Public declarations }
		Empty,RedrawAll,Extrapolate,GraphSelected,IsDirty:Boolean;
		NumCurves,SelectedCurve:Integer;
		xData:array[1..MaxCurves] of PGraphData;
		yData:array[1..MaxCurves] of PGraphData;
		GraphFonts:TGraphFonts;
		GraphStyle:TGraphStyle;
		NumPoints:TNumPoints;
		MinXValue,MaxXValue:Extended;
		xTitle,yTitle:string[255];
		gLeft,gRight,gTop,gBottom:Integer;
		procedure DrawAxes(TheCanvas:TCanvas;var Start,Finish:TNumPoints;
					var	DrawAxisMin,DrawAxisMax:TPoint;OnPrinter:Boolean;var StartPos:TPoint); virtual;
		procedure PlotPoints(TheCanvas:TCanvas;Start,Finish:TNumPoints;
					DrawAxisMin,DrawAxisMax:TPoint;OnPrinter:Boolean); virtual;
		procedure StoreFile(TheStream:TStream); virtual;
		procedure LoadFile(TheStream:TStream); virtual;
		procedure ResetGraph;
		function GetXAxisTitle:string;
		function GetYAxisTitle:string;
		procedure PrintGraph; virtual;
	end;

	procedure StoreGraphStyle(TheGraphStyle:TGraphStyle;TheGraphFonts:TGraphFonts;FileName:string);
	procedure LoadGraphStyle(var TheGraphStyle:TGraphStyle;var TheGraphFonts:TGraphFonts;FileName:string);
	procedure SetGraphStyleDefaults;
	
var
	GraphWindow:TGraphWindow;
	DefaultGraphFonts:TGraphFonts;
	DefaultGraphStyle:TGraphStyle;
	StyleDirectory:string;

implementation

uses
	DetGraphAxisDlg, DetLineStyleDlg, DetMainForm;

{$R *.DFM}

function GetDisplayPlaces(Value:string):Integer;
var
	L,i,numPlaces:Integer;
begin
	numPlaces:=0;
	L:=Length(Value);
	for i:=1 to L do
		if Value[i]='.' then
			numPlaces:=L-i;
	GetDisplayPlaces:=numPlaces;
end;

{.......................................................}

procedure TGraphWindow.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
	if not Empty and (Button=mbLeft) then
	begin
		SetCapture(Handle);
		ButtonDown:=True;
		Moved:=False;
		FirstMove:=True;
		FirstClick.x:=X;
		FirstClick.y:=Y;
		WhereClicked:=GetWhereClicked(FirstClick);
		if (HandleHit=NoHandle) and (WhereClicked=OutSideGraph) then
			GraphSelected:=False;
		if GraphSelected then
			case HandleHit of
				NoHandle:	with GraphStyle do
										if not xAxisScaleToWindow and not yAxisScaleToWindow then
											Screen.Cursor:=crSizeAll
										else
											if not xAxisScaleToWindow then
												Screen.Cursor:=crSizeWE
											else
												if not yAxisScaleToWindow then
													Screen.Cursor:=crSizeNS;
				TopLeft,BottomRight:Screen.Cursor:=crSizeNWSE;
				TopRight,BottomLeft:Screen.Cursor:=crSizeNESW;
				TopMid,BottomMid:		Screen.Cursor:=crSizeNS;
				MidLeft,MidRight:		Screen.Cursor:=crSizeWE;
			end;
	end;
end;

{.......................................................}

procedure TGraphWindow.FormMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
	x1,y1,x2,y2:Integer;
begin
	if DoubleClicked then
	begin
		FormMouseUp(Sender,mbLeft,Shift,X,Y);
		DoubleClicked:=False;
	end;
	if ButtonDown and GraphSelected  and not Empty then
		with GraphStyle do
		begin
			Moved:=True;
			IsDirty:=True;
			Canvas.Pen.Color:=clBlack;
			Canvas.Pen.Mode:=pmNot;
			Canvas.Pen.Style:=psDot;
			Canvas.Brush.Style:=bsClear;
			x1:=AxisMin.x;
			y1:=AxisMax.y;
			x2:=AxisMax.x+1;
			y2:=AxisMin.y+1;
			case HandleHit of
				TopLeft:
					begin
						AxisMin.x:=AxisMin.x+x-FirstClick.x;
						AxisMax.y:=AxisMax.y+y-FirstClick.y;
					end;
				TopRight:
					begin
						AxisMax.x:=AxisMax.x+x-FirstClick.x;
						AxisMax.y:=AxisMax.y+y-FirstClick.y;
					end;
				BottomLeft:
					begin
						AxisMin.x:=AxisMin.x+x-FirstClick.x;
						AxisMin.y:=AxisMin.y+y-FirstClick.y;
					end;
				BottomRight:
					begin
						AxisMax.x:=AxisMax.x+x-FirstClick.x;
						AxisMin.y:=AxisMin.y+y-FirstClick.y;
					end;
				BottomMid:
						AxisMin.y:=AxisMin.y+y-FirstClick.y;
				MidLeft:
						AxisMin.x:=AxisMin.x+x-FirstClick.x;
				MidRight:
						AxisMax.x:=AxisMax.x+x-FirstClick.x;
				TopMid:
						AxisMax.y:=AxisMax.y+y-FirstClick.y;
				NoHandle:
					if WhereClicked=InsideGraph then
					begin
						if not xAxisScaleToWindow then
							begin
								AxisMin.x:=AxisMin.x+x-FirstClick.x;
								AxisMax.x:=AxisMax.x+x-FirstClick.x;
							end;
							if not yAxisScaleToWindow then
							begin
								AxisMin.y:=AxisMin.y+y-FirstClick.y;
								AxisMax.y:=AxisMax.y+y-FirstClick.y;
							end;
					end;
			end;
			FirstClick.x:=x;
			FirstClick.y:=y;
			Canvas.Rectangle(AxisMin.x,AxisMax.y,AxisMax.x+1,AxisMin.y+1);
			if not FirstMove then
				Canvas.Rectangle(x1,y1,x2,y2);
			FirstMove:=False;
			Canvas.Pen.Mode:=pmCopy;
		end;
end;

{.......................................................}

procedure TGraphWindow.FormMouseUp(Sender: TObject; Button: TMouseButton;
	Shift: TShiftState; X, Y: Integer);
var
	whereReleased:Byte;
	thePoint:TPoint;
	temp:Integer;
	theLength:Extended;
begin
	if not Empty and (Button=mbLeft) then
		with GraphStyle do
		begin
			thePoint.x:=X;
			thePoint.y:=Y;
			ReleaseCapture;
			if AxisMin.x>AxisMax.x then
			begin
				temp:=AxisMax.x;
				AxisMax.x:=AxisMin.x;
				AxisMin.x:=temp;
			end;
			if AxisMax.y>AxisMin.y then
			begin
				temp:=AxisMax.y;
				AxisMax.y:=AxisMin.y;
				AxisMin.y:=temp;
			end;
			theLength:=(AxisMax.x-AxisMin.x)*25.4/Screen.PixelsPerInch;
			xAxisLength:=FloatToStrF(theLength,ffFixed,18,3);
			theLength:=(AxisMin.y-AxisMax.y)*25.4/Screen.PixelsPerInch;
			yAxisLength:=FloatToStrF(theLength,ffFixed,18,3);
			ButtonDown:=False;
			whereReleased:=GetWhereClicked(thePoint);
			if Moved then
				Repaint
			else
				if ((WhereClicked and whereReleased)<>0) then
					begin
						if (whereReleased and InsideGraph)<>0 then
						begin
							if not (xAxisScaleToWindow and yAxisScaleToWindow) then
								GraphSelected:=True
						end
						else
							GraphSelected:=False;
						if not (xAxisScaleToWindow and yAxisScaleToWindow) then
							Repaint;
					end;
		end;
	Screen.Cursor:=crDefault;
end;

{.......................................................}

procedure TGraphWindow.FormPaint(Sender: TObject);
var
	i:Integer;
	startPos:TPoint;
	startPoints:TNumPoints;
begin
	if Empty then
	begin
		Canvas.Brush.Color:=Color;
		Canvas.FillRect(ClientRect);
	end
	else
	begin
		if GraphStyle.xTitleAuto then
			xTitle:=GetXAxisTitle;
		if GraphStyle.yTitleAuto then
			yTitle:=GetYAxisTitle;
		for i:=1 to NumCurves do
			startPoints[i]:=1;
		RedrawAll:=True;
		with GraphStyle do
		begin
			NumRedraws:=0;
			DrawAxes(Canvas,startPoints,NumPoints,AxisMin,AxisMax,False,startPos);
			PlotPoints(Canvas,startPoints,NumPoints,AxisMin,AxisMax,False);
		end;
	end;
end;

{.......................................................}

procedure TGraphWindow.FormResize(Sender: TObject);
var
	theLength:Extended;
begin
	with GraphStyle do
	begin
		if xAxisScaleToWindow then
		begin
			AxisMax.x:=Width-30;
			theLength:=(AxisMax.x-AxisMin.x)*25.4/Screen.PixelsPerInch;
			xAxisLength:=FloatToStrF(theLength,ffFixed,18,3);
		end;
		if yAxisScaleToWindow then
		begin
			AxisMin.y:=ClientHeight-50;
			theLength:=(AxisMin.y-AxisMax.y)*25.4/Screen.PixelsPerInch;
			yAxisLength:=FloatToStrF(theLength,ffFixed,18,3);
		end;
	end;
	if not Empty then
		IsDirty:=True;
	Repaint;
end;

{.......................................................}

procedure TGraphWindow.FormDblClick(Sender: TObject);
var
	cursorPos:TPoint;
begin
	if not Empty then
	begin
		GetCursorPos(cursorPos);
		cursorPos:=ScreenToClient(cursorPos);
		with GraphStyle do
			with cursorPos do
				if (Abs(y-AxisMin.y)<3) and ((x>AxisMin.x) and (x<=AxisMax.x)) then
				begin
					ChangeAxisSettings(xAxis);
					DoubleClicked:=True;
					Repaint;
				end
				else
					if (Abs(x-AxisMin.x)<3) and ((y<AxisMin.y) and (y>=AxisMax.y)) then
					begin
						ChangeAxisSettings(yAxis);
						DoubleClicked:=True;
						Repaint;
					end;
	end;
end;

{.......................................................}

procedure TGraphWindow.DrawAxes(TheCanvas:TCanvas;var Start,Finish:TNumPoints;
									var DrawAxisMin,DrawAxisMax:TPoint;OnPrinter:Boolean;var StartPos:TPoint);
var
	xAxisDomain,yAxisRange,penSize:Integer;
	i,j,xPos,yPos,yAxisTitlePos,xMajTickSize,xMinTickSize,yMajTickSize,yMinTickSize:Integer;
	numMinorTicks,xNumMajorTicks,yNumMajorTicks,theOffset:Integer;
	xMajorTickDomain,xMinorTickDomain,numTicks,gridLength:Integer;
	yMajorTickRange,yMinorTickRange,code,firstValid,lastValid:Integer;
	theName,S:string;
	largest,domain,range,interval,k,min,max,majorTickDomain,minorTickDomain:Extended;
	majorTickRange,minorTickRange,value:Extended;
	theRegion:HRgn;
	theRect:TRect;
	theFont:HFont;
	thePen,blackPen:TPen;
	theWidth:Integer;
	theLength:Extended;
begin
	with GraphStyle do
	begin
		Screen.Cursor:=crHourGlass;
		thePen:=TPen.Create;
		thePen.Style:=psSolid;
		blackPen:=TPen.Create;
		blackPen.Color:=clBlack;
		blackPen.Style:=psSolid;
		blackPen.Width:=1;
		TheCanvas.Pen:=blackPen;
		xMajTickSize:=xMajorTickSize;
		xMinTickSize:=xMinorTickSize;
		yMajTickSize:=yMajorTickSize;
		yMinTickSize:=yMinorTickSize;
		xAxisDomain:=DrawAxisMax.x-DrawAxisMin.x;
		yAxisRange:=DrawAxisMin.y-DrawAxisMax.y;
		if xMinAuto=1 then
		begin
			xMin:=1e30;
			for j:=1 to NumCurves do
			begin
				for i:=Start[j] to Finish[j] do
					if (xData[j]^[i]<xMin) then
						xMin:=xData[j]^[i];
			end;
		end;
		if xMaxAuto=1 then
		begin
			xMax:=-1e30;
			for j:=1 to NumCurves do
			begin
				for i:=Start[j] to Finish[j] do
					if (xData[j]^[i]>xMax) then
						xMax:=xData[j]^[i];
			end;
		end;
		min:=xMin;
		max:=xMax;
		GetAxisExtremes(min,max,interval,xNumMajorTicks,numMinorTicks);
		if xTicksAuto=1 then
			xNumMinorTicks:=numMinorTicks;
		if xIncAuto=1 then
			xInterval:=interval;
		if xMinAuto=1 then
			xMin:=min;
		if xMaxAuto=1 then
			xMax:=max;
		domain:=xMax-xMin;
		if domain=0 then
			domain:=1;
		xNumMajorTicks:=Round(domain/xInterval);
		if xNumMajorTicks>StrToFloat(FloatToStr(domain/xInterval)) then
			Dec(xNumMajorTicks);
		majorTickDomain:=xInterval*xNumMajorTicks;
		xMajorTickDomain:=Round(xAxisDomain*1.0*majorTickDomain/domain);
		minorTickDomain:=majorTickDomain+Int((domain-majorTickDomain)/xInterval*(xNumMinorTicks+1))*xInterval/(xNumMinorTicks+1);
		xMinorTickDomain:=Round(xAxisDomain*1.0*minorTickDomain/domain);
		if xDecAuto=1 then
		begin
			if Int(xInterval)=xInterval then
				xNumPlaces:=0
			else
				xNumPlaces:=GetNumDecimalPlaces(xInterval);
			if xMinAuto=0 then
				if xMinDispPlaces>xNumPlaces then
					xNumPlaces:=xMinDispPlaces;
		end;
		if yMinAuto=1 then
		begin
			yMin:=1e30;
			for j:=1 to NumCurves do
				for i:=Start[j] to Finish[j] do
					if (yData[j]^[i]<yMin) then
						yMin:=yData[j]^[i];
		end;
		if yMaxAuto=1 then
		begin
			yMax:=-1e30;
			for j:=1 to NumCurves do
				for i:=Start[j] to Finish[j] do
					if (yData[j]^[i]>yMax) then
						yMax:=yData[j]^[i];
		end;
		min:=yMin;
		max:=yMax;
		GetAxisExtremes(min,max,interval,yNumMajorTicks,numMinorTicks);
		if yTicksAuto=1 then
			yNumMinorTicks:=numMinorTicks;
		if yIncAuto=1 then
			yInterval:=interval;
		if yMinAuto=1 then
			yMin:=min;
		if yMaxAuto=1 then
			yMax:=max;
		range:=yMax-yMin;
		if range=0 then
			range:=1;
		yNumMajorTicks:=Round(range/yInterval);
		if yNumMajorTicks>StrToFloat(FloatToStr(range/yInterval)) then
			Dec(yNumMajorTicks);
		majorTickRange:=yInterval*yNumMajorTicks;
		yMajorTickRange:=Round(yAxisRange*1.0*majorTickRange/range);
		minorTickRange:=majorTickRange+Int((range-majorTickRange)/yInterval*(yNumMinorTicks+1))*yInterval/(yNumMinorTicks+1);
		yMinorTickRange:=Round(yAxisRange*1.0*minorTickRange/range);
		if yDecAuto=1 then
		begin
			if Int(yInterval)=yInterval then
				yNumPlaces:=0
			else
				yNumPlaces:=GetNumDecimalPlaces(yInterval);
			if yMinAuto=0 then
				if yMinDispPlaces>yNumPlaces then
					yNumPlaces:=yMinDispPlaces;
		end;
		if OnPrinter then
			RedrawAll:=True;
		if RedrawAll or (OldxMin<>xMin) or (OldxMax<>xMax) or (OldyMin<>yMin) or (OldyMax<>yMax) then
		begin
			OldxMin:=xMin;
			OldxMax:=xMax;
			OldyMin:=yMin;
			OldyMax:=yMax;
			RedrawAll:=True;
			TheCanvas.Brush.Style:=bsSolid;
			TheCanvas.Brush.Color:=Color;
			if not OnPrinter then
				TheCanvas.FillRect(ClientRect);
			if not (OnPrinter or Copying) then
				DrawHandles;
			TheCanvas.Brush.Style:=bsClear;
			TheCanvas.Pen.Color:=clBlack;
			if OnPrinter then
			begin
				thePen.Color:=RGB(200,200,200);
				thePen.Width:=penSize;
			end
			else
			begin
				thePen.Color:=RGB(200,200,200);
				thePen.Width:=1;
			end;
			if xNumMinorTicks<>0 then
			begin
				numTicks:=Round(minorTickDomain*1.0/xInterval*(xNumMinorTicks+1));
				for i:=0 to numTicks do
					if i mod (xNumMinorTicks+1)>0 then
					begin
						xPos:=DrawAxisMin.x+Round(i*1.0*xMinorTickDomain/numTicks);
						TheCanvas.Pen:=blackPen;
						TheCanvas.MoveTo(xPos,DrawAxisMin.y+xMinTickSize);
						TheCanvas.LineTo(xPos,DrawAxisMin.y);
						if xMinorGrid=1 {and not ((i=0) or (i=numTicks))} then
						begin
							TheCanvas.Pen:=thePen;
							TheCanvas.LineTo(xPos,DrawAxisMin.y-yAxisRange);
						end;
					end;
			end;
			if yNumMinorTicks<>0 then
			begin
				numTicks:=Round(minorTickRange*1.0/yInterval*(yNumMinorTicks+1));
				for i:=0 to numTicks do
					if i mod (yNumMinorTicks+1)>0 then
					begin
						yPos:=DrawAxisMin.y-Round(i*1.0*yMinorTickRange/numTicks);
						TheCanvas.Pen:=blackPen;
						TheCanvas.MoveTo(DrawAxisMin.x-yMinTickSize,yPos);
						TheCanvas.LineTo(DrawAxisMin.x,yPos);
						if yMinorGrid=1 {and not ((i=0) or (i=numTicks))} then
						begin
							TheCanvas.Pen:=thePen;
							TheCanvas.LineTo(DrawAxisMin.x+xAxisDomain,yPos);
						end;
					end;
			end;
			if OnPrinter then
			begin
				thePen.Color:=RGB(80,80,80);
				thePen.Width:=penSize;
			end
			else
			begin
				thePen.Color:=RGB(120,120,120);
				thePen.Width:=1;
			end;
			if xNumMajorTicks>0 then
				for i:=0 to xNumMajorTicks do
				begin
					xPos:=DrawAxisMin.x+Round(i*1.0*xMajorTickDomain/xNumMajorTicks);
					TheCanvas.Pen:=blackPen;
					TheCanvas.MoveTo(xPos,DrawAxisMin.y+xMajTickSize);
					TheCanvas.LineTo(xPos,DrawAxisMin.y);
					if xMajorGrid=1 {and not ((i=0) or (i=xNumMajorTicks))} then
					begin
						TheCanvas.Pen:=thePen;
						TheCanvas.LineTo(xPos,DrawAxisMin.y-yAxisRange);
					end;
				end;
			if yNumMajorTicks>0 then
				for i:=0 to yNumMajorTicks do
				begin
					yPos:=DrawAxisMin.y-Round(i*1.0*yMajorTickRange/yNumMajorTicks);
					TheCanvas.Pen:=blackPen;
					TheCanvas.MoveTo(DrawAxisMin.x-yMajTickSize,yPos);
					TheCanvas.LineTo(DrawAxisMin.x,yPos);
					if yMajorGrid=1 {and not ((i=0) or (i=yNumMajorTicks))} then
					begin
						TheCanvas.Pen:=thePen;
						TheCanvas.LineTo(DrawAxisMin.x+xAxisDomain,yPos);
					end;
				end;
			thePen.Color:=RGB(0,0,0);
			thePen.Width:=1;
			TheCanvas.Pen:=thePen;
			TheCanvas.Rectangle(DrawAxisMin.x,DrawAxisMax.y,DrawAxisMax.x+1,DrawAxisMin.y+1);
			gLeft:=DrawAxisMin.x;
			gRight:=DrawAxisMax.x+1;
			gTop:=DrawAxisMax.y;
			gBottom:=DrawAxisMin.y+1;
			with GraphFonts.xNumberFont do
				theFont:=CreateScreenFont(Size,0,Style,V,Name);
			TheCanvas.Font.Handle:=theFont;
			theOffset:=2+xMajTickSize;
			if xNumMajorTicks>0 then
				for i:=0 to xNumMajorTicks do
				begin
					Str(xMin+i*majorTickDomain/xNumMajorTicks:1:xNumPlaces,theName);
					xPos:=DrawAxisMin.x+Round(i*1.0*xMajorTickDomain/xNumMajorTicks);
					if xPos<=DrawAxisMax.x then
					begin
						xPos:=xPos-TheCanvas.TextWidth(theName) div 2;
						TheCanvas.TextOut(xPos,DrawAxisMin.y+theOffset,theName);
					end;
					if not OnPrinter and (i=0) then
						if xPos<gLeft then
							gLeft:=xPos;
				end;
			if xPos+TheCanvas.TextWidth(theName)>gRight then
				gRight:=xPos+TheCanvas.TextWidth(theName);
			if DrawAxisMin.y+theOffset+TheCanvas.TextHeight(theName)>gBottom then
				gBottom:=DrawAxisMin.y+theOffset+TheCanvas.TextHeight(theName);
			theOffset:=theOffset+Round(1.25*TheCanvas.TextHeight(theName));
			TheCanvas.Font:=Font;
			DeleteObject(theFont);
			theName:=xTitle;
			with GraphFonts.xTitleFont do
				theFont:=CreateScreenFont(Size,0,Style,V,Name);
			TheCanvas.Font.Handle:=theFont;
			xPos:=(DrawAxisMax.x+DrawAxisMin.x-TheCanvas.TextWidth(theName)) div 2;
			TheCanvas.TextOut(xPos,DrawAxisMin.y+theOffset,theName);
			if (xPos<gLeft) and (TheCanvas.TextWidth(theName)<ClientWidth-20) then
				gLeft:=xPos;
			if (xPos+TheCanvas.TextWidth(theName)>gRight) and (TheCanvas.TextWidth(theName)<ClientWidth-20) then
				gRight:=xPos+TheCanvas.TextWidth(theName);
			if DrawAxisMin.y+theOffset+TheCanvas.TextHeight(theName)>gBottom then
				gBottom:=DrawAxisMin.y+theOffset+TheCanvas.TextHeight(theName);
			TheCanvas.Font:=Font;
			DeleteObject(theFont);
			StartPos.y:=DrawAxisMin.y+2*theOffset;
			yAxisTitlePos:=10000;
			with GraphFonts.yNumberFont do
				theFont:=CreateScreenFont(Size,0,Style,V,Name);
			TheCanvas.Font.Handle:=theFont;
			theOffset:=2+yMajTickSize;
			if yNumMajorTicks>0 then
				for i:=0 to yNumMajorTicks do
				begin
					Str(yMin+i*majorTickRange/yNumMajorTicks:1:yNumPlaces,theName);
					xPos:=DrawAxisMin.x-theOffset-TheCanvas.TextWidth(theName);
					if xPos<yAxisTitlePos then
						yAxisTitlePos:=xPos;
					yPos:=DrawAxisMin.y-i*yMajorTickRange div yNumMajorTicks;
					if yPos>=DrawAxisMax.y then
					begin
						yPos:=yPos-TheCanvas.TextHeight(theName) div 2;
						TheCanvas.TextOut(xPos,yPos,theName);
					end;
					if not OnPrinter and (i=0) then
						if yPos+TheCanvas.TextHeight(theName)>gBottom then
							gBottom:=yPos+TheCanvas.TextHeight(theName);
				end;
			if yPos<gTop then
				gTop:=yPos;
			if yAxisTitlePos<gLeft then
				gLeft:=yAxisTitlePos;
			TheCanvas.Font:=Font;
			DeleteObject(theFont);
			with GraphFonts.yTitleFont do
				theFont:=CreateScreenFont(Size,900,Style,V,Name);
			TheCanvas.Font.Handle:=theFont;
			theName:=yTitle;
			yAxisTitlePos:=yAxisTitlePos-Round(1.25*TheCanvas.TextHeight(theName));
			yPos:=(DrawAxisMax.y+DrawAxisMin.y+TheCanvas.TextWidth(theName)) div 2;
			TheCanvas.TextOut(yAxisTitlePos,yPos,theName);
			if yAxisTitlePos<gLeft then
				gLeft:=yAxisTitlePos;
			if (yPos>gBottom) and (TheCanvas.TextWidth(theName)<ClientHeight-20) then
				gBottom:=yPos;
			if (yPos-TheCanvas.TextWidth(theName)<gTop) and (TheCanvas.TextWidth(theName)<ClientHeight-20) then
				gTop:=yPos-TheCanvas.TextWidth(theName);
			if GraphStyle.xAxisScaleToWindow and ((gLeft<>10) or (gRight<>ClientWidth-10)) and (NumRedraws<2) and not OnPrinter and not Copying then
			begin
				Inc(NumRedraws);
				DrawAxisMin.x:=DrawAxisMin.x+10-gLeft;
				DrawAxisMax.x:=DrawAxisMax.x+ClientWidth-10-gRight;
				theLength:=(DrawAxisMax.x-DrawAxisMin.x)*25.4/Screen.PixelsPerInch;
				GraphStyle.xAxisLength:=FloatToStrF(theLength,ffFixed,18,3);
				DrawAxes(TheCanvas,Start,Finish,DrawAxisMin,DrawAxisMax,OnPrinter,StartPos);
			end;
			if GraphStyle.yAxisScaleToWindow and ((gTop<>10) or (gBottom<>ClientHeight-10)) and (NumRedraws<2) and not OnPrinter and not Copying then
			begin
				Inc(NumRedraws);
				DrawAxisMax.y:=DrawAxisMax.y+10-gTop;
				DrawAxisMin.y:=DrawAxisMin.y+ClientHeight-10-gBottom;
				theLength:=(DrawAxisMin.y-DrawAxisMax.y)*25.4/Screen.PixelsPerInch;
				GraphStyle.yAxisLength:=FloatToStrF(theLength,ffFixed,18,3);
				DrawAxes(TheCanvas,Start,Finish,DrawAxisMin,DrawAxisMax,OnPrinter,StartPos);
			end;
		end
		else
			RedrawAll:=False;
		thePen.Destroy;
		blackPen.Destroy;
		TheCanvas.Font:=Font;
		DeleteObject(theFont);
		Screen.Cursor:=crDefault;
	end;
end;

{.......................................................}

procedure TGraphWindow.PlotPoints(TheCanvas:TCanvas;Start,Finish:TNumPoints;
						DrawAxisMin,DrawAxisMax:TPoint;OnPrinter:Boolean);
var
	i,j,xPos,yPos,xAxisDomain,yAxisRange,bigSymSize,smallSymSize:Integer;
	domain,range,yPosValue:Real;
	theRegion:HRgn;
	lineGraph,bigSymbols,dashed:Boolean;
	gotStartIndex:array[1..MaxCurves] of Boolean;
	startIndex,finishIndex:array[1..MaxCurves] of Integer;
	posLimit,negLimit:Integer;
	oldBrush:TBrush;
begin
	with GraphStyle do
	begin
		Screen.Cursor:=crHourGlass;
		if RedrawAll then
			for i:=1 to NumCurves do
				Start[i]:=1;
		theRegion:=CreateRectRgn(DrawAxisMin.x,DrawAxisMax.y,DrawAxisMax.x,DrawAxisMin.y);
		SelectClipRgn(TheCanvas.Handle,theRegion);
		xAxisDomain:=DrawAxisMax.x-DrawAxisMin.x;
		yAxisRange:=DrawAxisMin.y-DrawAxisMax.y;
		domain:=GraphStyle.xMax-GraphStyle.xMin;
		if domain=0 then
			domain:=1;
		range:=yMax-yMin;
		if range=0 then
			range:=1;
		for j:=1 to NumCurves do
		begin
			if PlotType[j]=Line then
				if Start[j]<>1 then
					Dec(Start[j]);
			gotStartIndex[j]:=False;
			for i:=Start[j] to Finish[j] do
				if not gotStartIndex[j] then
				begin
					startIndex[j]:=i;
					gotStartIndex[j]:=True;
				end;
			if not gotStartIndex[j] then
				startIndex[j]:=Start[j];
			finishIndex[j]:=Finish[j];
			for i:=Start[j] to Finish[j] do
			begin
				if xData[j]^[i]<xMin then
					startIndex[j]:=i;
				if xData[j]^[i]<=xMax then
					finishIndex[j]:=i;
			end;
			if finishIndex[j]<Finish[j] then
				Inc(finishIndex[j]);
		end;
		bigSymSize:=2;
		smallSymSize:=1;
		posLimit:=32760-bigSymSize;
		negLimit:=-posLimit;
		for j:=1 to NumCurves do
		begin
			case PlotType[j] of
				Small:		begin
										bigSymbols:=False;
										lineGraph:=False;
										dashed:=False;
									end;
				Big:			begin
										bigSymbols:=True;
										lineGraph:=False;
										dashed:=False;
									end;
				Line:			begin
										bigSymbols:=False;
										lineGraph:=True;
										dashed:=False;
									end;
				BigLine:	begin
										bigSymbols:=True;
										lineGraph:=True;
										dashed:=False;
									end;
				DashLine:	begin
										bigSymbols:=False;
										lineGraph:=True;
										dashed:=True;
									end;
			end;
			TheCanvas.Pen.Width:=1;
			TheCanvas.Pen.Color:=CurveColour[j];
			if dashed then
			begin
				TheCanvas.Pen.Style:=psDash;
				TheCanvas.Brush.Color:=clBlack;
				TheCanvas.Brush.Style:=bsClear;
			end
			else
			begin
				TheCanvas.Pen.Style:=psSolid;
				TheCanvas.Brush.Color:=CurveColour[j];
				TheCanvas.Brush.Style:=bsSolid;
			end;
			for i:=startIndex[j] to finishIndex[j] do
				if i<=NumPoints[j] then
				begin
					if i<=Finish[j] then
					begin
						xPos:=Integer(DrawAxisMin.x+Round((xData[j]^[i]-xMin)*xAxisDomain/domain));
						yPosValue:=DrawAxisMin.y-Round((yData[j]^[i]-yMin)*yAxisRange/range);
						if yPosValue>posLimit then
							yPosValue:=posLimit
						else
							if yPosValue<negLimit then
								yPosValue:=negLimit;
						yPos:=Round(yPosValue);
					end;
					if lineGraph then
						if i=startIndex[j] then
							TheCanvas.MoveTo(xPos,yPos)
						else
							TheCanvas.LineTo(xPos,yPos)
					else
						TheCanvas.MoveTo(xPos,yPos);
					if bigSymbols then
						TheCanvas.Ellipse(xPos-bigSymSize,yPos-bigSymSize,xPos+bigSymSize+1,yPos+bigSymSize+1)
					else
						if not lineGraph then
							TheCanvas.Rectangle(xPos-smallSymSize,yPos-smallSymSize,xPos+smallSymSize,yPos+smallSymSize);
				end;
			TheCanvas.Pen.Color:=clBlack;
			TheCanvas.Pen.Style:=psSolid;
			TheCanvas.Brush.Style:=bsClear;
		end;
		DeleteObject(theRegion);
		SelectClipRgn(TheCanvas.Handle,0);
		Screen.Cursor:=crDefault;
	end;
end;

{.......................................................}

procedure TGraphWindow.FormCreate(Sender: TObject);
var
	i:Integer;
begin
	with GraphFonts do
	begin
		xTitleFont:=TFont.Create;
		xTitleFont.Assign(DefaultGraphFonts.xTitleFont);
		yTitleFont:=TFont.Create;
		yTitleFont.Assign(DefaultGraphFonts.yTitleFont);
		xNumberFont:=TFont.Create;
		xNumberFont.Assign(DefaultGraphFonts.xNumberFont);
		yNumberFont:=TFont.Create;
		yNumberFont.Assign(DefaultGraphFonts.yNumberFont);
	end;
	ResetGraph;
	NumCurves:=1;
	for i:=1 to MaxCurves do
	begin
		xData[i]:=New(PGraphData);
		yData[i]:=New(PGraphData);
		NumPoints[i]:=0;
	end;
end;

{.......................................................}

function TGraphWindow.GetWhereClicked(PointClicked:TPoint):Byte;
var
	where:Byte;
	theRect:TRect;
	xMid,yMid:Integer;
begin
	with GraphStyle do
	begin
		where:=0;
		HandleHit:=NoHandle;
		xMid:=(AxisMin.x+AxisMax.x) div 2;
		yMid:=(AxisMin.y+AxisMax.y) div 2;
		SetRect(theRect,AxisMin.x,AxisMax.y,AxisMax.x,AxisMin.y);
		if PtInRect(theRect,PointClicked) then
			where:=where or InsideGraph
		else
			where:=where or OutsideGraph;
		SetRect(theRect,AxisMin.x-4,AxisMin.y-4,AxisMin.x+5,AxisMin.y+5);
		if PtInRect(theRect,PointClicked) and not xAxisScaleToWindow and not yAxisScaleToWindow then
		begin
			where:=where or OnHandle;
			HandleHit:=BottomLeft;
		end;
		SetRect(theRect,AxisMin.x-4,AxisMax.y-4,AxisMin.x+5,AxisMax.y+5);
		if PtInRect(theRect,PointClicked) and not xAxisScaleToWindow and not yAxisScaleToWindow then
		begin
			where:=where or OnHandle;
			HandleHit:=TopLeft;
		end;
		SetRect(theRect,AxisMax.x-4,AxisMin.y-4,AxisMax.x+5,AxisMin.y+5);
		if PtInRect(theRect,PointClicked) and not xAxisScaleToWindow and not yAxisScaleToWindow then
		begin
			where:=where or OnHandle;
			HandleHit:=BottomRight;
		end;
		SetRect(theRect,AxisMax.x-4,AxisMax.y-4,AxisMax.x+5,AxisMax.y+5);
		if PtInRect(theRect,PointClicked) and not xAxisScaleToWindow and not yAxisScaleToWindow then
		begin
			where:=where or OnHandle;
			HandleHit:=TopRight;
		end;
		SetRect(theRect,xMid-4,AxisMin.y-4,xMid+5,AxisMin.y+5);
		if PtInRect(theRect,PointClicked) and not yAxisScaleToWindow then
		begin
			where:=where or OnHandle;
			HandleHit:=BottomMid;
		end;
		SetRect(theRect,AxisMin.x-4,yMid-4,AxisMin.x+5,yMid+5);
		if PtInRect(theRect,PointClicked) and not xAxisScaleToWindow then
		begin
			where:=where or OnHandle;
			HandleHit:=MidLeft;
		end;
		SetRect(theRect,AxisMax.x-4,yMid-4,AxisMax.x+5,yMid+5);
		if PtInRect(theRect,PointClicked) and not xAxisScaleToWindow then
		begin
			where:=where or OnHandle;
			HandleHit:=MidRight;
		end;
		SetRect(theRect,xMid-4,AxisMax.y-4,xMid+5,AxisMax.y+5);
		if PtInRect(theRect,PointClicked) and not yAxisScaleToWindow then
		begin
			where:=where or OnHandle;
			HandleHit:=TopMid;
		end;
		GetWhereClicked:=where;
	end;
end;

{.......................................................}

procedure TGraphWindow.DrawHandles;
var
	xMid,yMid:Integer;
begin
	if not Empty then
		with GraphStyle do
		begin
			if GraphSelected then
			begin
				Canvas.Brush.Color:=clBlack;
				Canvas.Pen.Color:=clBlack;
			end
			else
			begin
				Canvas.Brush.Color:=clWhite;
				Canvas.Pen.Color:=clWhite;
			end;
			xMid:=(AxisMin.x+AxisMax.x) div 2;
			yMid:=(AxisMin.y+AxisMax.y) div 2;
			with Canvas do
			begin
				if not xAxisScaleToWindow and not yAxisScaleToWindow then
				begin
					Rectangle(AxisMin.x-4,AxisMin.y-4,AxisMin.x+5,AxisMin.y+5);
					Rectangle(AxisMin.x-4,AxisMax.y-4,AxisMin.x+5,AxisMax.y+5);
					Rectangle(AxisMax.x-4,AxisMin.y-4,AxisMax.x+5,AxisMin.y+5);
					Rectangle(AxisMax.x-4,AxisMax.y-4,AxisMax.x+5,AxisMax.y+5);
				end;
				if not xAxisScaleToWindow then
				begin
					Rectangle(AxisMax.x-4,yMid-4,AxisMax.x+5,yMid+5);
					Rectangle(AxisMin.x-4,yMid-4,AxisMin.x+5,yMid+5);
				end;
				if not yAxisScaleToWindow then
				begin
					Rectangle(xMid-4,AxisMin.y-4,xMid+5,AxisMin.y+5);
					Rectangle(xMid-4,AxisMax.y-4,xMid+5,AxisMax.y+5);
				end;
			end;
		end;
end;

{.......................................................}

procedure TGraphWindow.ChangeAxisSettings(AxisSelected:TAxisSelected);
var
	returnValue:Integer;
	S:string;
	theLength:Extended;
begin
	if not Empty then
		with GraphStyle do
			with AxisSettingsDlg do
			begin
				TitleFont:=TFont.Create;
				NumberFont:=TFont.Create;
				if AxisSelected=xAxis then
				begin
					AutoTitle:=GetXAxisTitle;
					if xMaxAuto=1 then
						xMaxDispPlaces:=xNumPlaces;
					if xMinAuto=1 then
						xMinDispPlaces:=xNumPlaces;
					if xIncAuto=1 then
						xIncDispPlaces:=xNumPlaces;
					MaxAutoCheck.Checked:=xMaxAuto=1;
					MinAutoCheck.Checked:=xMinAuto=1;
					MajorIncAutoCheck.Checked:=xIncAuto=1;
					MinorTicksAutoCheck.Checked:=xTicksAuto=1;
					DecPlacesAutoCheck.Checked:=xDecAuto=1;
					MajorGridCheck.Checked:=xMajorGrid=1;
					MinorGridCheck.Checked:=xMinorGrid=1;
					Str(xMax:1:xMaxDispPlaces,S);
					MaximumEdit.Text:=S;
					Str(xMin:1:xMinDispPlaces,S);
					MinimumEdit.Text:=S;
					Str(xInterval:1:xIncDispPlaces,S);
					MajorIncEdit.Text:=S;
					MinorTicksUpDown.Position:=xNumMinorTicks;
					DecPlacesUpDown.Position:=xNumPlaces;
					AxisTitleEdit.Text:=xTitle;
					TitleAutoCheck.Checked:=xTitleAuto;
					TitleFont.Assign(GraphFonts.xTitleFont);
					NumberFont.Assign(GraphFonts.xNumberFont);
					MajorTickSizeUpDown.Position:=xMajorTickSize;
					MinorTickSizeUpDown.Position:=xMinorTickSize;
					ScaleToWindowCheckBox.Checked:=xAxisScaleToWindow;
					AxisLengthEdit.Text:=xAxisLength;
					Caption:='x-Axis Settings';
				end
				else
				begin
					AutoTitle:=GetYAxisTitle;
					if yMaxAuto=1 then
						yMaxDispPlaces:=yNumPlaces;
					if yMinAuto =1then
						yMinDispPlaces:=yNumPlaces;
					if yIncAuto=1 then
						yIncDispPlaces:=yNumPlaces;
					MaxAutoCheck.Checked:=yMaxAuto=1;
					MinAutoCheck.Checked:=yMinAuto=1;
					MajorIncAutoCheck.Checked:=yIncAuto=1;
					MinorTicksAutoCheck.Checked:=yTicksAuto=1;
					DecPlacesAutoCheck.Checked:=yDecAuto=1;
					MajorGridCheck.Checked:=yMajorGrid=1;
					MinorGridCheck.Checked:=yMinorGrid=1;
					Str(yMax:1:yMaxDispPlaces,S);
					MaximumEdit.Text:=S;
					Str(yMin:1:yMinDispPlaces,S);
					MinimumEdit.Text:=S;
					Str(yInterval:1:yIncDispPlaces,S);
					MajorIncEdit.Text:=S;
					MinorTicksUpDown.Position:=yNumMinorTicks;
					DecPlacesUpDown.Position:=yNumPlaces;
					AxisTitleEdit.Text:=yTitle;
					TitleAutoCheck.Checked:=yTitleAuto;
					TitleFont.Assign(GraphFonts.yTitleFont);
					NumberFont.Assign(GraphFonts.yNumberFont);
					MajorTickSizeUpDown.Position:=yMajorTickSize;
					MinorTickSizeUpDown.Position:=yMinorTickSize;
					ScaleToWindowCheckBox.Checked:=yAxisScaleToWindow;
					AxisLengthEdit.Text:=yAxisLength;
					Caption:='y-Axis Settings';
				end;
				returnValue:=AxisSettingsDlg.ShowModal;
				if returnValue=mrOk then
				begin
					IsDirty:=True;
					if AxisSelected=xAxis then
					begin
						xMaxAuto:=Ord(MaxAutoCheck.Checked);
						xMinAuto:=Ord(MinAutoCheck.Checked);
						xIncAuto:=Ord(MajorIncAutoCheck.Checked);
						xTicksAuto:=Ord(MinorTicksAutoCheck.Checked);
						xDecAuto:=Ord(DecPlacesAutoCheck.Checked);
						xMajorGrid:=Ord(MajorGridCheck.Checked);
						xMinorGrid:=Ord(MinorGridCheck.Checked);
						if xMaxAuto=0 then
						begin
							xMax:=StrToFloat(MaximumEdit.Text);
							xMaxDispPlaces:=GetDisplayPlaces(MaximumEdit.Text);
						end;
						if xMinAuto=0 then
						begin
							xMin:=StrToFloat(MinimumEdit.Text);
							xMinDispPlaces:=GetDisplayPlaces(MinimumEdit.Text);
						end;
						if xIncAuto=0 then
						begin
							xInterval:=StrToFloat(MajorIncEdit.Text);
							xIncDispPlaces:=GetDisplayPlaces(MajorIncEdit.Text);
						end;
						if xTicksAuto=0 then
							xNumMinorTicks:=MinorTicksUpDown.Position;
						if xDecAuto=0 then
							xNumPlaces:=DecPlacesUpDown.Position;
						xTitleAuto:=TitleAutoCheck.Checked;
						if xTitleAuto then
							xTitle:=GetXAxisTitle
						else
							xTitle:=AxisTitleEdit.Text;
						GraphFonts.xTitleFont.Assign(TitleFont);
						GraphFonts.xNumberFont.Assign(NumberFont);
						xMajorTickSize:=MajorTickSizeUpDown.Position;
						xMinorTickSize:=MinorTickSizeUpDown.Position;
						xAxisScaleToWindow:=ScaleToWindowCheckBox.Checked;
						if xAxisScaleToWindow then
						begin
							AxisMax.x:=Self.Width-30;
							theLength:=(AxisMax.x-AxisMin.x)*25.4/Screen.PixelsPerInch;
							xAxisLength:=FloatToStrF(theLength,ffFixed,18,3);
						end
						else
						begin
							xAxisLength:=AxisLengthEdit.Text;
							AxisMax.x:=AxisMin.x+Round(StrToFloat(xAxisLength)*Screen.PixelsPerInch/25.4);
						end;
					end
					else
					begin
						yMaxAuto:=Ord(MaxAutoCheck.Checked);
						yMinAuto:=Ord(MinAutoCheck.Checked);
						yIncAuto:=Ord(MajorIncAutoCheck.Checked);
						yTicksAuto:=Ord(MinorTicksAutoCheck.Checked);
						yDecAuto:=Ord(DecPlacesAutoCheck.Checked);
						yMajorGrid:=Ord(MajorGridCheck.Checked);
						yMinorGrid:=Ord(MinorGridCheck.Checked);
						if yMaxAuto=0 then
						begin
							yMax:=StrToFloat(MaximumEdit.Text);
							yMaxDispPlaces:=GetDisplayPlaces(MaximumEdit.Text);
						end;
						if yMinAuto=0 then
						begin
							yMin:=StrToFloat(MinimumEdit.Text);
							yMinDispPlaces:=GetDisplayPlaces(MinimumEdit.Text);
						end;
						if yIncAuto=0 then
						begin
							yInterval:=StrToFloat(MajorIncEdit.Text);
							yIncDispPlaces:=GetDisplayPlaces(MajorIncEdit.Text);
						end;
						if yTicksAuto=0 then
							yNumMinorTicks:=MinorTicksUpDown.Position;
						if yDecAuto=0 then
							yNumPlaces:=DecPlacesUpDown.Position;
						yTitleAuto:=TitleAutoCheck.Checked;
						if yTitleAuto then
							yTitle:=GetYAxisTitle
						else
							yTitle:=AxisTitleEdit.Text;
						GraphFonts.yTitleFont.Assign(TitleFont);
						GraphFonts.yNumberFont.Assign(NumberFont);
						yMajorTickSize:=MajorTickSizeUpDown.Position;
						yMinorTickSize:=MinorTickSizeUpDown.Position;
						yAxisScaleToWindow:=ScaleToWindowCheckBox.Checked;
						if yAxisScaleToWindow then
						begin
							AxisMin.y:=Self.ClientHeight-50;
							AxisMax.y:=20;
							theLength:=(AxisMax.y-AxisMin.y)*25.4/Screen.PixelsPerInch;
							yAxisLength:=FloatToStrF(theLength,ffFixed,18,3);
						end
						else
						begin
							yAxisLength:=AxisLengthEdit.Text;
							AxisMax.y:=AxisMin.y-Round(StrToFloat(yAxisLength)*Screen.PixelsPerInch/25.4);
						end;
					end;
				TitleFont.Free;
				NumberFont.Free;
				if xAxisScaleToWindow and yAxisScaleToWindow then
					GraphSelected:=False;
			end;
		end
		else
			MessageDlg('No data to plot yet.',mtWarning,[mbOk],0);
end;

procedure TGraphWindow.xAxisMenuClick(Sender: TObject);
begin
	ChangeAxisSettings(xAxis);
	Repaint;
end;

procedure TGraphWindow.yAxisMenuClick(Sender: TObject);
begin
	ChangeAxisSettings(yAxis);
	Repaint;
end;

procedure TGraphWindow.LineStyleMenuClick(Sender: TObject);
var
	returnValue,i:Integer;
	colourArray:array[1..MaxCurves] of TColor;
	plotTypeArray:array[1..MaxCurves] of TPlotType;
begin
	with GraphStyle do
	begin
		for i:=1 to NumCurves do
		begin
			colourArray[i]:=CurveColour[i];
			plotTypeArray[i]:=PlotType[i];
		end;
		with LineStyleDlg do
		begin
			SmallSymbolsRadio.Checked:=PlotType[SelectedCurve]=Small;
			BigSymbolsRadio.Checked:=PlotType[SelectedCurve]=Big;
			SolidLineRadio.Checked:=PlotType[SelectedCurve]=Line;
			DashedLineRadio.Checked:=PlotType[SelectedCurve]=DashLine;
			SolidLineBigRadio.Checked:=PlotType[SelectedCurve]=BigLine;
			CurveComboBox.Clear;
			for i:=1 to NumCurves do
				CurveComboBox.Items.Add(IntToStr(i));
			CurveComboBox.ItemIndex:=SelectedCurve-1;
			GraphWindow:=Self;
			returnValue:=ShowModal;
			if returnValue=mrOk then
			begin
				IsDirty:=True;
				SelectedCurve:=CurveComboBox.ItemIndex+1;
			end
			else
				for i:=1 to NumCurves do
				begin
					CurveColour[i]:=colourArray[i];
					PlotType[i]:=plotTypeArray[i];
				end;
		end;
	end;
	Repaint;
end;

procedure TGraphWindow.CopyMenuClick(Sender: TObject);
var
	startPoints:TNumPoints;
	theMetaFile:TMetaFile;
	theCanvas:TCanvas;
	i:Integer;
	startPos:TPoint;
begin
	theMetaFile:=TMetaFile.Create;
	theMetaFile.Width:=ClientWidth;
	theMetaFile.Height:=ClientHeight;
	theCanvas:=TMetaFileCanvas.Create(theMetaFile,Canvas.Handle);
	for i:=1 to NumCurves do
		startPoints[i]:=1;
	Copying:=True;
	with GraphStyle do
	begin
		DrawAxes(theCanvas,startPoints,NumPoints,AxisMin,AxisMax,False,startPos);
		PlotPoints(theCanvas,startPoints,NumPoints,AxisMin,AxisMax,False);
	end;
	theCanvas.Free;
	Clipboard.Assign(theMetaFile);
	theMetaFile.Free;
	Copying:=False;
end;

procedure TGraphWindow.GraphPopupMenuPopup(Sender: TObject);
begin
	XAxisPopup.Enabled:=not Empty;
	YAxisPopup.Enabled:=not Empty;
	LineStylePopup.Enabled:=not Empty;
	CopyGraphPopup.Enabled:=not Empty;
	PrintGraphPopup.Enabled:=not Empty;
end;

procedure TGraphWindow.FormClose(Sender: TObject;
	var Action: TCloseAction);
var
	i:Integer;
begin
	if Sender=MainForm then
	begin
		for i:=1 to MaxCurves do
		begin
			Dispose(xData[i]);
			Dispose(yData[i]);
		end;
		with GraphFonts do
		begin
			xTitleFont.Free;
			yTitleFont.Free;
			xNumberFont.Free;
			yNumberFont.Free;
		end;
	end;
end;

procedure TGraphWindow.StoreFile(TheStream:TStream);
var
	i,theSize:Integer;
	theStyle:TFontStyles;
	thePitch:TFontPitch;
	theName:string[255];
begin;
	with TheStream do
	begin
		with GraphStyle do
		begin
      {Write(GraphWindow.Left,SizeOf(GraphWindow.Left));
			Write(GraphWindow.Top,SizeOf(GraphWindow.Top));}
			Write(Width,SizeOf(Width));
			Write(Height,SizeOf(Height));
			Write(WindowState,SizeOf(WindowState));
			Write(NumCurves,SizeOf(NumCurves));
			Write(xAxisScaleToWindow,SizeOf(xAxisScaleToWindow));
			Write(yAxisScaleToWindow,SizeOf(yAxisScaleToWindow));
			Write(xAxisLength,SizeOf(xAxisLength));
			Write(yAxisLength,SizeOf(yAxisLength));
			Write(xMin,SizeOf(xMin));
			Write(xMax,SizeOf(xMax));
			Write(yMin,SizeOf(yMin));
			Write(yMax,SizeOf(yMax));
			Write(xInterval,SizeOf(xInterval));
			Write(yInterval,SizeOf(yInterval));
			Write(xNumPlaces,SizeOf(xNumPlaces));
			Write(yNumPlaces,SizeOf(yNumPlaces));
			Write(xNumMinorTicks,SizeOf(xNumMinorTicks));
			Write(yNumMinorTicks,SizeOf(yNumMinorTicks));
			Write(xMajorTickSize,SizeOf(xMajorTickSize));
			Write(xMinorTickSize,SizeOf(xMinorTickSize));
			Write(yMajorTickSize,SizeOf(yMajorTickSize));
			Write(yMinorTickSize,SizeOf(yMinorTickSize));
			Write(xMaxAuto,SizeOf(xMaxAuto));
			Write(xMinAuto,SizeOf(xMinAuto));
			Write(xIncAuto,SizeOf(xIncAuto));
			Write(xTicksAuto,SizeOf(xTicksAuto));
			Write(xDecAuto,SizeOf(xDecAuto));
			Write(yMaxAuto,SizeOf(yMaxAuto));
			Write(yMinAuto,SizeOf(yMinAuto));
			Write(yIncAuto,SizeOf(yIncAuto));
			Write(yTicksAuto,SizeOf(yTicksAuto));
			Write(yDecAuto,SizeOf(yDecAuto));
			Write(xMajorGrid,SizeOf(xMajorGrid));
			Write(xMinorGrid,SizeOf(xMinorGrid));
			Write(yMajorGrid,SizeOf(yMajorGrid));
			Write(yMinorGrid,SizeOf(yMinorGrid));
			Write(xMaxDispPlaces,SizeOf(xMaxDispPlaces));
			Write(xMinDispPlaces,SizeOf(xMinDispPlaces));
			Write(xIncDispPlaces,SizeOf(xIncDispPlaces));
			Write(yMaxDispPlaces,SizeOf(yMaxDispPlaces));
			Write(yMinDispPlaces,SizeOf(yMinDispPlaces));
			Write(yIncDispPlaces,SizeOf(yIncDispPlaces));
			Write(Empty,SizeOf(Empty));
			Write(AxisMax,SizeOf(AxisMax));
			Write(AxisMin,SizeOf(AxisMin));
			Write(xTitleAuto,SizeOf(xTitleAuto));
			Write(yTitleAuto,SizeOf(yTitleAuto));
			Write(xTitle,SizeOf(xTitle));
			Write(yTitle,SizeOf(yTitle));
			with GraphFonts.xTitleFont do
			begin
				theSize:=Size;
				Write(theSize,SizeOf(theSize));
				theStyle:=Style;
				Write(theStyle,SizeOf(theStyle));
				thePitch:=Pitch;
				Write(thePitch,SizeOf(thePitch));
				theName:=Name;
				Write(theName,SizeOf(theName));
			end;
			with GraphFonts.yTitleFont do
			begin
				theSize:=Size;
				Write(theSize,SizeOf(theSize));
				theStyle:=Style; 
				Write(theStyle,SizeOf(theStyle));
				thePitch:=Pitch;
				Write(thePitch,SizeOf(thePitch));
				theName:=Name;
				Write(theName,SizeOf(theName));
			end;
			with GraphFonts.xNumberFont do
			begin
				theSize:=Size;
				Write(theSize,SizeOf(theSize));
				theStyle:=Style; 
				Write(theStyle,SizeOf(theStyle));
				thePitch:=Pitch;
				Write(thePitch,SizeOf(thePitch));
				theName:=Name;
				Write(theName,SizeOf(theName));
			end;
			with GraphFonts.yNumberFont do
			begin
				theSize:=Size;
				Write(theSize,SizeOf(theSize));
				theStyle:=Style; 
				Write(theStyle,SizeOf(theStyle));
				thePitch:=Pitch;
				Write(thePitch,SizeOf(thePitch));
				theName:=Name;
				Write(theName,SizeOf(theName));
			end;
			for i:=1 to NumCurves do
			begin
				Write(PlotType[i],SizeOf(PlotType[i]));
				Write(CurveColour[i],SizeOf(CurveColour[i]));
				Write(NumPoints[i],SizeOf(NumPoints[i]));
				Write(xData[i]^,SizeOf(Extended)*NumPoints[i]);
				Write(yData[i]^,SizeOf(Extended)*NumPoints[i]);
			end;
			Write(MinXValue,SizeOf(MinXValue));
			Write(MaxXValue,SizeOf(MaxXValue));
		end;
	end;
end;

procedure TGraphWindow.LoadFile(TheStream:TStream);
var
	i,theSize:Integer;
	theStyle:TFontStyles;
	thePitch:TFontPitch;
	theName:string[255];
	theState:TWindowState;
begin
	try
		with TheStream do
		begin
			with GraphStyle do
			begin
				{TheStream.Read(theSize,SizeOf(theSize));
				Left:=theSize;
				TheStream.Read(theSize,SizeOf(theSize));
				Top:=theSize;}
				TheStream.Read(theSize,SizeOf(theSize));
				Width:=theSize;
				TheStream.Read(theSize,SizeOf(theSize));
				Height:=theSize;
				TheStream.Read(theState,SizeOf(theState));
				Read(NumCurves,SizeOf(NumCurves));
				Read(xAxisScaleToWindow,SizeOf(xAxisScaleToWindow));
				Read(yAxisScaleToWindow,SizeOf(yAxisScaleToWindow));
				Read(xAxisLength,SizeOf(xAxisLength));
				Read(yAxisLength,SizeOf(yAxisLength));
				Read(xMin,SizeOf(xMin));
				Read(xMax,SizeOf(xMax));
				Read(yMin,SizeOf(yMin));
				Read(yMax,SizeOf(yMax));
				Read(xInterval,SizeOf(xInterval));
				Read(yInterval,SizeOf(yInterval));
				Read(xNumPlaces,SizeOf(xNumPlaces));
				Read(yNumPlaces,SizeOf(yNumPlaces));
				Read(xNumMinorTicks,SizeOf(xNumMinorTicks));
				Read(yNumMinorTicks,SizeOf(yNumMinorTicks));
				Read(xMajorTickSize,SizeOf(xMajorTickSize));
				Read(xMinorTickSize,SizeOf(xMinorTickSize));
				Read(yMajorTickSize,SizeOf(yMajorTickSize));
				Read(yMinorTickSize,SizeOf(yMinorTickSize));
				Read(xMaxAuto,SizeOf(xMaxAuto));
				Read(xMinAuto,SizeOf(xMinAuto));
				Read(xIncAuto,SizeOf(xIncAuto));
				Read(xTicksAuto,SizeOf(xTicksAuto));
				Read(xDecAuto,SizeOf(xDecAuto));
				Read(yMaxAuto,SizeOf(yMaxAuto));
				Read(yMinAuto,SizeOf(yMinAuto));
				Read(yIncAuto,SizeOf(yIncAuto));
				Read(yTicksAuto,SizeOf(yTicksAuto));
				Read(yDecAuto,SizeOf(yDecAuto));
				Read(xMajorGrid,SizeOf(xMajorGrid));
				Read(xMinorGrid,SizeOf(xMinorGrid));
				Read(yMajorGrid,SizeOf(yMajorGrid));
				Read(yMinorGrid,SizeOf(yMinorGrid));
				Read(xMaxDispPlaces,SizeOf(xMaxDispPlaces));
				Read(xMinDispPlaces,SizeOf(xMinDispPlaces));
				Read(xIncDispPlaces,SizeOf(xIncDispPlaces));
				Read(yMaxDispPlaces,SizeOf(yMaxDispPlaces));
				Read(yMinDispPlaces,SizeOf(yMinDispPlaces));
				Read(yIncDispPlaces,SizeOf(yIncDispPlaces));
				Read(Empty,SizeOf(Empty));
				Read(AxisMax,SizeOf(AxisMax));
				Read(AxisMin,SizeOf(AxisMin));
				Read(xTitleAuto,SizeOf(xTitleAuto));
				Read(yTitleAuto,SizeOf(yTitleAuto));
				Read(xTitle,SizeOf(xTitle));
				Read(yTitle,SizeOf(yTitle));
				if xTitleAuto then
					xTitle:=GetXAxisTitle;
				if yTitleAuto then
					yTitle:=GetYAxisTitle;
				with GraphFonts.xTitleFont do
				begin
					Read(theSize,SizeOf(theSize));
					Size:=theSize;
					Read(theStyle,SizeOf(theStyle));
					Style:=theStyle;
					Read(thePitch,SizeOf(thePitch));
					Pitch:=thePitch;
					Read(theName,SizeOf(theName));
					Name:=theName;
				end;
				with GraphFonts.yTitleFont do
				begin
					Read(theSize,SizeOf(theSize));
					Size:=theSize;
					Read(theStyle,SizeOf(theStyle));
					Style:=theStyle;
					Read(thePitch,SizeOf(thePitch));
					Pitch:=thePitch;
					Read(theName,SizeOf(theName));
					Name:=theName;
				end;
				with GraphFonts.xNumberFont do
				begin
					Read(theSize,SizeOf(theSize));
					Size:=theSize;
					Read(theStyle,SizeOf(theStyle));
					Style:=theStyle;
					Read(thePitch,SizeOf(thePitch));
					Pitch:=thePitch;
					Read(theName,SizeOf(theName));
					Name:=theName;
				end;
				with GraphFonts.yNumberFont do
				begin
					Read(theSize,SizeOf(theSize));
					Size:=theSize;
					Read(theStyle,SizeOf(theStyle));
					Style:=theStyle;
					Read(thePitch,SizeOf(thePitch));
					Pitch:=thePitch;
					Read(theName,SizeOf(theName));
					Name:=theName;
				end;
				for i:=1 to NumCurves do
				begin
					Read(PlotType[i],SizeOf(PlotType[i]));
					Read(CurveColour[i],SizeOf(CurveColour[i]));
					Read(NumPoints[i],SizeOf(NumPoints[i]));
					Read(xData[i]^,SizeOf(Extended)*NumPoints[i]);
					Read(yData[i]^,SizeOf(Extended)*NumPoints[i]);
				end;
				Read(MinXValue,SizeOf(MinXValue));
				Read(MaxXValue,SizeOf(MaxXValue));
			end;
		end;
		WindowState:=theState;
		Repaint;
	except
	end;
end;

procedure StoreGraphStyle(TheGraphStyle:TGraphStyle;TheGraphFonts:TGraphFonts;FileName:string);
var
	theStream:TFileStream;
	i,theSize:Integer;
	theStyle:TFontStyles;
	thePitch:TFontPitch;
	theName:string[255];
begin
	Screen.Cursor:=crHourGlass;
	theStream:=TFileStream.Create(FileName,fmCreate);
	with theStream do
	begin
		with TheGraphStyle do
		begin
			Write(xAxisScaleToWindow,SizeOf(xAxisScaleToWindow));
			Write(yAxisScaleToWindow,SizeOf(yAxisScaleToWindow));
			Write(xAxisLength,SizeOf(xAxisLength));
			Write(yAxisLength,SizeOf(yAxisLength));
			Write(xMin,SizeOf(xMin));
			Write(xMax,SizeOf(xMax));
			Write(yMin,SizeOf(yMin));
			Write(yMax,SizeOf(yMax));
			Write(xInterval,SizeOf(xInterval));
			Write(yInterval,SizeOf(yInterval));
			Write(xNumPlaces,SizeOf(xNumPlaces));
			Write(yNumPlaces,SizeOf(yNumPlaces));
			Write(xNumMinorTicks,SizeOf(xNumMinorTicks));
			Write(yNumMinorTicks,SizeOf(yNumMinorTicks));
			Write(xMajorTickSize,SizeOf(xMajorTickSize));
			Write(xMinorTickSize,SizeOf(xMinorTickSize));
			Write(yMajorTickSize,SizeOf(yMajorTickSize));
			Write(yMinorTickSize,SizeOf(yMinorTickSize));
			Write(xMaxAuto,SizeOf(xMaxAuto));
			Write(xMinAuto,SizeOf(xMinAuto));
			Write(xIncAuto,SizeOf(xIncAuto));
			Write(xTicksAuto,SizeOf(xTicksAuto));
			Write(xDecAuto,SizeOf(xDecAuto));
			Write(yMaxAuto,SizeOf(yMaxAuto));
			Write(yMinAuto,SizeOf(yMinAuto));
			Write(yIncAuto,SizeOf(yIncAuto));
			Write(yTicksAuto,SizeOf(yTicksAuto));
			Write(yDecAuto,SizeOf(yDecAuto));
			Write(xMajorGrid,SizeOf(xMajorGrid));
			Write(xMinorGrid,SizeOf(xMinorGrid));
			Write(yMajorGrid,SizeOf(yMajorGrid));
			Write(yMinorGrid,SizeOf(yMinorGrid));
			Write(xMaxDispPlaces,SizeOf(xMaxDispPlaces));
			Write(xMinDispPlaces,SizeOf(xMinDispPlaces));
			Write(xIncDispPlaces,SizeOf(xIncDispPlaces));
			Write(yMaxDispPlaces,SizeOf(yMaxDispPlaces));
			Write(yMinDispPlaces,SizeOf(yMinDispPlaces));
			Write(yIncDispPlaces,SizeOf(yIncDispPlaces));
			Write(AxisMax,SizeOf(AxisMax));
			Write(AxisMin,SizeOf(AxisMin));
			Write(xTitleAuto,SizeOf(xTitleAuto));
			Write(yTitleAuto,SizeOf(yTitleAuto));
			with TheGraphFonts.xTitleFont do
			begin
				theSize:=Size;
				Write(theSize,SizeOf(theSize));
				theStyle:=Style;
				Write(theStyle,SizeOf(theStyle));
				thePitch:=Pitch;
				Write(thePitch,SizeOf(thePitch));
				theName:=Name;
				Write(theName,SizeOf(theName));
			end;
			with TheGraphFonts.yTitleFont do
			begin
				theSize:=Size;
				Write(theSize,SizeOf(theSize));
				theStyle:=Style; 
				Write(theStyle,SizeOf(theStyle));
				thePitch:=Pitch;
				Write(thePitch,SizeOf(thePitch));
				theName:=Name;
				Write(theName,SizeOf(theName));
			end;
			with TheGraphFonts.xNumberFont do
			begin
				theSize:=Size;
				Write(theSize,SizeOf(theSize));
				theStyle:=Style; 
				Write(theStyle,SizeOf(theStyle));
				thePitch:=Pitch;
				Write(thePitch,SizeOf(thePitch));
				theName:=Name;
				Write(theName,SizeOf(theName));
			end;
			with TheGraphFonts.yNumberFont do
			begin
				theSize:=Size;
				Write(theSize,SizeOf(theSize));
				theStyle:=Style; 
				Write(theStyle,SizeOf(theStyle));
				thePitch:=Pitch;
				Write(thePitch,SizeOf(thePitch));
				theName:=Name;
				Write(theName,SizeOf(theName));
			end;
			for i:=1 to MaxCurves do
			begin
				Write(PlotType[i],SizeOf(PlotType[i]));
				Write(CurveColour[i],SizeOf(CurveColour[i]));
			end;
		end;
		Free;
	end;
	Screen.Cursor:=crDefault;
end;

procedure LoadGraphStyle(var TheGraphStyle:TGraphStyle;var TheGraphFonts:TGraphFonts;FileName:string);
var
	theStream:TFileStream;
	i,theSize:Integer;
	theStyle:TFontStyles;
	thePitch:TFontPitch;
	theName:string[255];
begin
	Screen.Cursor:=crHourGlass;
	try
		theStream:=TFileStream.Create(FileName,fmOpenRead);
		with theStream do
		begin
			with TheGraphStyle do
			begin
				Read(xAxisScaleToWindow,SizeOf(xAxisScaleToWindow));
				Read(yAxisScaleToWindow,SizeOf(yAxisScaleToWindow));
				Read(xAxisLength,SizeOf(xAxisLength));
				Read(yAxisLength,SizeOf(yAxisLength));
				Read(xMin,SizeOf(xMin));
				Read(xMax,SizeOf(xMax));
				Read(yMin,SizeOf(yMin));
				Read(yMax,SizeOf(yMax));
				Read(xInterval,SizeOf(xInterval));
				Read(yInterval,SizeOf(yInterval));
				Read(xNumPlaces,SizeOf(xNumPlaces));
				Read(yNumPlaces,SizeOf(yNumPlaces));
				Read(xNumMinorTicks,SizeOf(xNumMinorTicks));
				Read(yNumMinorTicks,SizeOf(yNumMinorTicks));
				Read(xMajorTickSize,SizeOf(xMajorTickSize));
				Read(xMinorTickSize,SizeOf(xMinorTickSize));
				Read(yMajorTickSize,SizeOf(yMajorTickSize));
				Read(yMinorTickSize,SizeOf(yMinorTickSize));
				Read(xMaxAuto,SizeOf(xMaxAuto));
				Read(xMinAuto,SizeOf(xMinAuto));
				Read(xIncAuto,SizeOf(xIncAuto));
				Read(xTicksAuto,SizeOf(xTicksAuto));
				Read(xDecAuto,SizeOf(xDecAuto));
				Read(yMaxAuto,SizeOf(yMaxAuto));
				Read(yMinAuto,SizeOf(yMinAuto));
				Read(yIncAuto,SizeOf(yIncAuto));
				Read(yTicksAuto,SizeOf(yTicksAuto));
				Read(yDecAuto,SizeOf(yDecAuto));
				Read(xMajorGrid,SizeOf(xMajorGrid));
				Read(xMinorGrid,SizeOf(xMinorGrid));
				Read(yMajorGrid,SizeOf(yMajorGrid));
				Read(yMinorGrid,SizeOf(yMinorGrid));
				Read(xMaxDispPlaces,SizeOf(xMaxDispPlaces));
				Read(xMinDispPlaces,SizeOf(xMinDispPlaces));
				Read(xIncDispPlaces,SizeOf(xIncDispPlaces));
				Read(yMaxDispPlaces,SizeOf(yMaxDispPlaces));
				Read(yMinDispPlaces,SizeOf(yMinDispPlaces));
				Read(yIncDispPlaces,SizeOf(yIncDispPlaces));
				Read(AxisMax,SizeOf(AxisMax));
				Read(AxisMin,SizeOf(AxisMin));
				Read(xTitleAuto,SizeOf(xTitleAuto));
				Read(yTitleAuto,SizeOf(yTitleAuto));
				with TheGraphFonts.xTitleFont do
				begin
					Read(theSize,SizeOf(theSize));
					Size:=theSize;
					Read(theStyle,SizeOf(theStyle));
					Style:=theStyle;
					Read(thePitch,SizeOf(thePitch));
					Pitch:=thePitch;
					Read(theName,SizeOf(theName));
					Name:=theName;
				end;
				with TheGraphFonts.yTitleFont do
				begin
					Read(theSize,SizeOf(theSize));
					Size:=theSize;
					Read(theStyle,SizeOf(theStyle));
					Style:=theStyle;
					Read(thePitch,SizeOf(thePitch));
					Pitch:=thePitch;
					Read(theName,SizeOf(theName));
					Name:=theName;
				end;
				with TheGraphFonts.xNumberFont do
				begin
					Read(theSize,SizeOf(theSize));
					Size:=theSize;
					Read(theStyle,SizeOf(theStyle));
					Style:=theStyle;
					Read(thePitch,SizeOf(thePitch));
					Pitch:=thePitch;
					Read(theName,SizeOf(theName));
					Name:=theName;
				end;
				with TheGraphFonts.yNumberFont do
				begin
					Read(theSize,SizeOf(theSize));
					Size:=theSize;
					Read(theStyle,SizeOf(theStyle));
					Style:=theStyle;
					Read(thePitch,SizeOf(thePitch));
					Pitch:=thePitch;
					Read(theName,SizeOf(theName));
					Name:=theName;
				end;
				for i:=1 to MaxCurves do
				begin
					Read(PlotType[i],SizeOf(PlotType[i]));
					Read(CurveColour[i],SizeOf(CurveColour[i]));
				end;
			end;
		end;
	finally;
		theStream.Free;
		Screen.Cursor:=crDefault;
	end;
end;

procedure SetGraphStyleDefaults;
var
	i:Integer;
begin
	with DefaultGraphStyle do
	begin
		xAxisScaleToWindow:=True;
		yAxisScaleToWindow:=True;
		for i:=1 to MaxCurves do
		begin
			PlotType[i]:=BigLine;
			CurveColour[i]:=clBlue;
		end;
		CurveColour[2]:=clRed;
		xMajorTickSize:=6;
		xMinorTickSize:=3;
		yMajorTickSize:=6;
		yMinorTickSize:=3;
		xMaxAuto:=1;
		xMinAuto:=1;
		xIncAuto:=1;
		xTicksAuto:=1;
		xDecAuto:=1;
		xMajorGrid:=0;
		xMinorGrid:=0;
		xTitleAuto:=True;
		yMaxAuto:=1;
		yMinAuto:=1;
		yIncAuto:=1;
		yTicksAuto:=1;
		yDecAuto:=1;
		yMajorGrid:=0;
		yMinorGrid:=0;
		yTitleAuto:=True;
	end;
	with DefaultGraphFonts do
	begin
		xTitleFont.Assign(MainForm.Font);
		xTitleFont.Name:='Arial';
		xTitleFont.Style:=xTitleFont.Style+[fsBold];
		xTitleFont.Size:=xTitleFont.Size+2;
		yTitleFont.Assign(MainForm.Font);
		yTitleFont.Name:='Arial';
		yTitleFont.Style:=yTitleFont.Style+[fsBold];
		yTitleFont.Size:=yTitleFont.Size+2;
		xNumberFont.Assign(MainForm.Font);
		xNumberFont.Name:='Arial';
		yNumberFont.Assign(MainForm.Font);
		yNumberFont.Name:='Arial';
	end;
end;

procedure TGraphWindow.SetGraphStyle;
begin
	with OpenGraphStyleDlg do
	begin
		FileName:='';
		InitialDir:=StyleDirectory;
		if Execute then
		begin
			LoadGraphStyle(GraphStyle,GraphFonts,FileName);
			IsDirty:=True;
			StyleDirectory:=ExtractFileDir(FileName);
		end;
	end;
	Repaint;
end;

procedure TGraphWindow.SaveGraphStyleAs;
begin
	with SaveGraphStyleDlg do
	begin
		FileName:='';
		InitialDir:=StyleDirectory;
		if Execute then
		begin
			StoreGraphStyle(GraphStyle,GraphFonts,FileName);
			StyleDirectory:=ExtractFileDir(FileName);
		end;
	end;
end;

procedure TGraphWindow.SetToDefaultStyle;
begin
	GraphStyle:=DefaultGraphStyle;
 	with GraphFonts do
	begin
		xTitleFont.Assign(DefaultGraphFonts.xTitleFont);
		yTitleFont.Assign(DefaultGraphFonts.yTitleFont);
		xNumberFont.Assign(DefaultGraphFonts.xNumberFont);
		yNumberFont.Assign(DefaultGraphFonts.yNumberFont);
	end;
	IsDirty:=True;
	Repaint;
end;

procedure TGraphWindow.SetCurrentStyleAsDefault;
begin
	Beep;
	if MessageDlg('Are you sure you want to change the default graph style?',mtConfirmation,[mbYes,mbNo],0)= mrYes then
	begin
		DefaultGraphStyle:=GraphStyle;
		with DefaultGraphFonts do
		begin
			xTitleFont.Assign(GraphFonts.xTitleFont);
			yTitleFont.Assign(GraphFonts.yTitleFont);
			xNumberFont.Assign(GraphFonts.xNumberFont);
			yNumberFont.Assign(GraphFonts.yNumberFont);
		end;
		StoreGraphStyle(DefaultGraphStyle,DefaultGraphFonts,DefaultStyleFileName);
	end;
end;

procedure TGraphWindow.ResetGraph;
var
	theLength:Extended;
begin
	GraphStyle:=DefaultGraphStyle;
	with GraphStyle do
	begin
		if xAxisScaleToWindow then
		begin
			AxisMin.x:=60;
			AxisMax.x:=Width-30;
		end;
		if yAxisScaleToWindow then
		begin
			AxisMin.y:=ClientHeight-50;
			AxisMax.y:=20;
		end;
		theLength:=(AxisMax.x-AxisMin.x)*25.4/Screen.PixelsPerInch;
		xAxisLength:=FloatToStrF(theLength,ffFixed,18,3);
		theLength:=(AxisMin.y-AxisMax.y)*25.4/Screen.PixelsPerInch;
		yAxisLength:=FloatToStrF(theLength,ffFixed,18,3);
		GraphSelected:=False;
		GraphDeselected:=False;
		Empty:=True;
		RedrawAll:=True;
		OldxMin:=0;
		OldxMax:=0;
		OldyMin:=0;
		OldyMax:=0;
	end;
	xTitle:=GetXAxisTitle;
	yTitle:=GetYAxisTitle;
	SelectedCurve:=1;
	DoubleClicked:=False;
	Extrapolate:=False;
	Repaint;
end;

procedure TGraphWindow.WMMove(var Msg: TMessage);
begin
	if not Empty then
		IsDirty:=True;
end;

function TGraphWindow.GetXAxisTitle:string;
begin
	case Mode of
		CollimatedDetectorModel:
			begin
				case XVariable of
					DetAngle:GetXAxisTitle:='Detector Angle / °';
					XOffset:GetXAxisTitle:='x Offset / mm';
					YOffset:GetXAxisTitle:='y Offset / mm';
				end;
			end;
		DiffuseDetectorModel:
			begin
				case XVariable of
					DetAngle:GetXAxisTitle:='Detector Angle / °';
					XOffset:GetXAxisTitle:='x Offset / mm';
					YOffset:GetXAxisTitle:='y Offset / mm';
				end;
			end;
		ViewFactor:GetXAxisTitle:='Detector Angle / °';
	end;
end;

function TGraphWindow.GetYAxisTitle:string;
begin
	case Mode of
		CollimatedDetectorModel:GetYAxisTitle:='R Collimated / R Diffuse';
		DiffuseDetectorModel:GetYAxisTitle:='R Collimated / R Diffuse';
		ViewFactor:GetYAxisTitle:='View Factor / Cos (Theta)';
	end;
end;

procedure TGraphWindow.PrintGraphPopupClick(Sender: TObject);
begin
	PrintGraph;
end;

procedure TGraphWindow.PrintGraph;
var
	theOrigin,theExtent,startPos:TPoint;
	i:Integer;
	scaleFac:Extended;
	drawAxisMin,drawAxisMax:TPoint;
	startPoints:TNumPoints;
begin
	if SetUpPrinting(PrintGraphDialog,25,25,25,25,theOrigin,theExtent) then
		with GraphStyle do
		begin
			Screen.Cursor:=crHourGlass;
			with Printer do
			begin
				case Mode of
					CollimatedDetectorModel: Title:='Detector Model Graph';
					DiffuseDetectorModel: Title:='Detector Model Graph';
					ViewFactor: Title:='View Factors Graph';
				end;
				BeginDoc;
				for i:=1 to NumCurves do
					startPoints[i]:=1;
				for i:=1 to PrintGraphDialog.Copies do
				begin
					startPos:=theOrigin;
					scaleFac:=PrinterResolution*1.0/Screen.PixelsPerInch;
					drawAxisMin.x:=TheOrigin.x+Round(AxisMin.x*scaleFac);
					drawAxisMax.x:=TheOrigin.x+Round(AxisMax.x*scaleFac);
					drawAxisMin.y:=StartPos.y+Round(AxisMin.y*scaleFac);
					drawAxisMax.y:=StartPos.y+Round(AxisMax.y*scaleFac);
					DrawAxes(Canvas,startPoints,NumPoints,drawAxisMin,drawAxisMax,True,StartPos);
					PlotPoints(Canvas,startPoints,NumPoints,drawAxisMin,drawAxisMax,True);
				end;
				EndDoc;
			end;
			Screen.Cursor:=crDefault;
		end;
end;

end.

