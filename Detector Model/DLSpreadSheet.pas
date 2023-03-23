unit DLSpreadSheet;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus, ToolWin, ComCtrls, ImgList,
	Tabnotbk, Grids, Clipbrd, DLColumnFormatDlg;

const
	NumSpreadsheets=5;
	MaxColumns=26;
	MaxPoints=100000;
	FileDataNumColumns=6;
	ResultsNumColumns=25;
	BeamScanNumColumns=12;
	WavelengthScanNumColumns=11;
	MonitorNumColumns=8;
			
type

TCellAlignment=(LeftAlign,RightAlign,CentreAlign,GeneralAlign);
TColFormat=(gen,deci,sci);

TMyEdit = class(TEdit)
	private
		ControlDown:Boolean;
		procedure WMChar(var Msg: TMessage); message wm_Char;
		procedure WMClear(var Msg:TMessage); message wm_Clear;
		procedure WMCut(var Msg:TMessage); message wm_Cut;
		procedure WMCopy(var Msg:TMessage); message wm_Copy;
		procedure WMPaste(var Msg:TMessage); message wm_Paste;
		procedure WMUndo(var Msg:TMessage); message wm_Undo;
		procedure MyExit(Sender: TObject);
    procedure WMKeyDown(var Msg: TMessage); message wm_KeyDown;
	end;

TDLDataSpreadSheet = class(TCustomControl)
	constructor Create(AOwner:TWinControl;NumColumns,NumFixedCols,NumFixedRows:Integer;
								IsEditable,HasFixedNumRows,IsAutoNumbered:Boolean;TheTag:Integer);
	destructor Destroy; override;
	procedure StringGridMouseDown(Sender: TObject; Button: TMouseButton;
			Shift: TShiftState; X, Y: Integer);
	procedure StringGridMouseUp(Sender: TObject; Button: TMouseButton;
			Shift: TShiftState; X, Y: Integer);
	procedure StringGridMouseMove(Sender: TObject; Shift: TShiftState;X, Y: Integer);
	procedure StringGridEditChange(Sender: TObject);
	procedure StringGridTopLeftChanged(Sender: TObject);
	procedure ScrollTimerTimer(Sender:TObject);
	procedure CutPopupClick(Sender:TObject);
	procedure CopyPopupClick(Sender:TObject);
	procedure PastePopupClick(Sender:TObject);
	procedure DeletePopupClick(Sender:TObject);
	procedure SelectAllPopupClick(Sender:TObject);
	procedure FormatColumnPopupClick(Sender:TObject);
	procedure StringGridPopupMenuPopup(Sender: TObject);
	procedure StringGridDrawCell(Sender: TObject; ACol, ARow: Longint; Rect: TRect; State: TGridDrawState);
	private
		SheetTag:Integer;
		ScrollTimer:TTimer;
		MouseIsDown,TimerAssigned:Boolean;
		AnchorX,AnchorY:Integer;
		TimerRow,TimerCol,TimerIncr:Integer;
		StringGridPopupMenu:TPopupMenu;
		CutPopup:TMenuItem;
		CopyPopup:TMenuItem;
		PastePopup:TMenuItem;
		Separator1Popup:TMenuItem;
		DeletePopup:TMenuItem;
		SelectAllPopup:TMenuItem;
		Separator2Popup:TMenuItem;
		FormatColumnPopup:TMenuItem;
		procedure KeyboardChange(Key:Word);
		procedure SetRowHeights;
	public
		StringGrid:TStringGrid;
		StringGridEdit:TMyEdit;
		TopPanel:TPanel;
		Editable,AutoNumber,FixedNumRows,IsDirty,SelectingRow,SelectingCol:Boolean;
		ColFormat:array[0..MaxColumns-1] of TColFormat;
		ColPlaces:array[0..MaxColumns-1] of Byte;
		DataFont:TFont;
		procedure PasteData;
		procedure CopyDataToClipboard;
		procedure SelectAll;
		procedure DeselectAll;
		procedure DeleteCells;
		procedure CutData;
		procedure ScrollIntoView(X,Y:Integer);
		procedure ResetSpreadSheet;
		procedure SelectRowsOrCols(TheRow,TheCol:Integer);
		procedure InsertData(X,Y:Integer;TheText:string);
		function FormatCell(X,Y:Integer):string;
		procedure SetFont;
		procedure SetColFormat;
		function CellsSelected:Boolean;
		procedure SelectCell(X,Y:Integer);
	end;

var
	DefColWidth:array[1..NumSpreadsheets,0..MaxColumns-1] of Integer;
	DefColFormat:array[1..NumSpreadsheets,0..MaxColumns-1] of TColFormat;
	DefColPlaces:array[1..NumSpreadsheets,0..MaxColumns-1] of Byte;
	DataDefaultFont:TFont;
		
implementation

uses
	NewTestDetailsTETE;

procedure Delay(DelayTime:LongWord);
var
	startTime:LongWord;
begin
	startTime:=GetTickCount;
	repeat
	until GetTickCount-startTime>DelayTime;
end;

{ TDLDataSpreadSheet }

procedure TDLDataSpreadSheet.CopyDataToClipboard;
const
	CrLf=#13+#10;
var
	i,j:Integer;
	theData:string;
begin
	Screen.Cursor:=crHourGlass;
	theData:='';
	for j:=StringGrid.Selection.Top to StringGrid.Selection.Bottom do
	begin
		for i:=StringGrid.Selection.Left to StringGrid.Selection.Right do
		begin
			theData:=theData+StringGrid.Cells[i,j];
			if i<>StringGrid.Selection.Right then
				theData:=theData+#9;
		end;
		theData:=theData+CrLf;
	end;
	Clipboard.AsText:=theData;
	Screen.Cursor:=crDefault;
end;

procedure TDLDataSpreadSheet.CopyPopupClick(Sender: TObject);
begin
	CopyDataToClipboard;
end;

constructor TDLDataSpreadSheet.Create(AOwner:TWinControl;NumColumns,NumFixedCols,NumFixedRows:Integer;
								IsEditable,HasFixedNumRows,IsAutoNumbered:Boolean;TheTag:Integer);
begin
	inherited Create(AOwner);
	SheetTag:=TheTag;
	Editable:=IsEditable;
	IsDirty:=False;
	FixedNumRows:=HasFixedNumRows;
	StringGrid:=TStringGrid.Create(Self);
	StringGrid.Parent:=AOwner;
	AutoNumber:=IsAutoNumbered;
	with StringGrid do
	begin
		DefaultDrawing:=True;
		ColCount:=NumColumns;
		FixedCols:=NumFixedCols;
		FixedRows:=NumFixedRows;
		AnchorX:=FixedCols;
		AnchorY:=FixedRows;
		DataFont:=TFont.Create;
		OnMouseDown:=StringGridMouseDown;
		OnMouseUp:=StringGridMouseUp;
		OnMouseMove:=StringGridMouseMove;
		OnTopLeftChanged:=StringGridTopLeftChanged;
		OnDrawCell:=StringGridDrawCell;
		Align:=alClient;
		Options:=[goFixedVertLine,goFixedHorzLine,goVertLine,goHorzLine,goRangeSelect,
							goDrawFocusSelected,goColSizing,goTabs,goThumbTracking];
		Height:=1200;
		TabStop:=False;
		StringGridPopupMenu:=TPopupMenu.Create(Self);
		CutPopup:=TMenuItem.Create(Self);
		CutPopup.Caption:='Cu&t';
		CutPopup.ShortCut:=ShortCut(Word('X'),[ssCtrl]);
		CutPopup.OnClick:=CutPopupClick;
		StringGridPopupMenu.Items.Add(CutPopup);
		CopyPopup:=TMenuItem.Create(Self);
		CopyPopup.Caption:='&Copy';
		CopyPopup.ShortCut:=ShortCut(Word('C'),[ssCtrl]);
		CopyPopup.OnClick:=CopyPopupClick;
		StringGridPopupMenu.Items.Add(CopyPopup);
		PastePopup:=TMenuItem.Create(Self);
		PastePopup.Caption:='&Paste';
		PastePopup.ShortCut:=ShortCut(Word('V'),[ssCtrl]);
		PastePopup.OnClick:=PastePopupClick;
		StringGridPopupMenu.Items.Add(PastePopup);
		Separator1Popup:=TMenuItem.Create(Self);
		Separator1Popup.Caption:='-';
		StringGridPopupMenu.Items.Add(Separator1Popup);
		DeletePopup:=TMenuItem.Create(Self);
		DeletePopup.Caption:='&Delete';
		DeletePopup.ShortCut:=ShortCut(vk_Delete,[]);
		DeletePopup.OnClick:=DeletePopupClick;
		StringGridPopupMenu.Items.Add(DeletePopup);
		SelectAllPopup:=TMenuItem.Create(Self);
		SelectAllPopup.Caption:='Se&lect All';
		SelectAllPopup.ShortCut:=ShortCut(Word('A'),[ssCtrl]);
		SelectAllPopup.OnClick:=SelectAllPopupClick;
		StringGridPopupMenu.Items.Add(SelectAllPopup);
		Separator2Popup:=TMenuItem.Create(Self);
		Separator2Popup.Caption:='-';
		StringGridPopupMenu.Items.Add(Separator2Popup);
		FormatColumnPopup:=TMenuItem.Create(Self);
		FormatColumnPopup.Caption:='&Format Column...';
		FormatColumnPopup.ShortCut:=ShortCut(Word('F'),[ssCtrl]);
		FormatColumnPopup.OnClick:=FormatColumnPopupClick;
		StringGridPopupMenu.Items.Add(FormatColumnPopup);
		StringGridPopupMenu.OnPopup:=StringGridPopupMenuPopup;
		PopupMenu:=StringGridPopupMenu;
	end;
	MouseIsDown:=False;
	TimerAssigned:=False;
	if Editable then
	begin
		TopPanel:=TPanel.Create(Self);
		with TopPanel do
		begin
			Parent:=AOwner;
			Height:=26;
			Align:=alTop;
			TabStop:=True;
		end;
		StringGridEdit:=TMyEdit.Create(Self);
		with StringGridEdit do
		begin
			ControlDown:=False;
			Parent:=AOwner;
			Left:=TopPanel.Left+1;
			Height:=24;
			Top:=TopPanel.Top+1;
			Width:=TopPanel.Width-2;
			with Font do
			begin
				Name:='Arial';
				Size:=8;
				Style:=[];
			end;
			OnChange:=StringGridEditChange;
			OnExit:=MyExit;
			TabStop:=True;
		end;
	end;
end;

procedure TDLDataSpreadSheet.CutData;
begin
	CopyDataToClipBoard;
	DeleteCells;
end;

procedure TDLDataSpreadSheet.CutPopupClick(Sender: TObject);
begin
	CutData;
end;

procedure TDLDataSpreadSheet.DeleteCells;
var
	i,j:Integer;
begin
	with StringGrid.Selection do
		for j:=Top to Bottom do
			for i:=Left to Right do
				StringGrid.Cells[i,j]:='';
	StringGridEdit.Text:='';
end;

procedure TDLDataSpreadSheet.DeletePopupClick(Sender: TObject);
begin
	DeleteCells;
end;

procedure TDLDataSpreadSheet.FormatColumnPopupClick(Sender: TObject);
begin
	SetColFormat;
end;

destructor TDLDataSpreadSheet.Destroy;
begin
	if Editable then
	begin
		StringGridEdit.Free;
		TopPanel.Free;
	end;
	DataFont.Free;
	inherited Destroy;
end;

function TDLDataSpreadSheet.FormatCell(X, Y: Integer): string;
var
	S:string;
	value:Double;
	code:Integer;
begin
	if StringGrid.Cells[X,Y]='' then
		S:=''
	else
	begin
		Val(StringGrid.Cells[X,Y],value,code);
		if code=0 then
		begin
			case ColFormat[X] of
				gen:	S:=FloatToStrF(value,ffGeneral,15,0);
				deci:	S:=FloatToStrF(value,ffFixed,15,ColPlaces[X]);
				sci:	S:=FloatToStrF(value,ffExponent,ColPlaces[X],0);
			end;
		end
		else
			S:=StringGrid.Cells[X,Y];
	end;
	FormatCell:=S;
end;

procedure TDLDataSpreadSheet.InsertData(X, Y: Integer; TheText: string);
var
	i,j,oldRowCount:Integer;
begin
	if (Y>=StringGrid.RowCount) and not FixedNumRows then
	begin
		oldRowCount:=StringGrid.RowCount;
		for i:=0 to StringGrid.ColCount-1 do
		begin
			StringGrid.RowCount:=Y+2;
			for j:=oldRowCount to Y+1 do
				if AutoNumber and (i=0) then
					StringGrid.Cells[i,j]:=IntToStr(j)
				else
					StringGrid.Cells[i,j]:='';
		end;
	end;
	if Y<StringGrid.RowCount then
		StringGrid.Cells[X,Y]:=TheText;
end;

procedure TDLDataSpreadSheet.KeyboardChange(Key: Word);
var
	hor,ver,aCol,aRow:Integer;
	theRect:TGridRect;
begin
	with StringGrid do
	begin
		aCol:=Selection.Left;
		aRow:=Selection.Top;
		hor:=0;
		ver:=0;
		case Key of
			vk_Return,vk_Down:if aRow<RowCount-1 then ver:=1;
			vk_Right:					if aCol<ColCount-1 then hor:=1;
			vk_Tab:						if aCol<ColCount-1 then
													hor:=1
												else
												begin
													if aRow=MaxPoints then
													begin
														hor:=0;
														ver:=0;
													end
													else
													begin
														hor:=-ColCount+FixedCols+1;
														ver:=1;
													end;
												end;
			vk_Left:					if aCol>FixedCols then hor:=-1;
			vk_Up:	 					if aRow>FixedRows then ver:=-1;
		end;
		theRect.Left:=aCol+hor;
		theRect.Top:=aRow+ver;
		theRect.Right:=aCol+hor;
		theRect.Bottom:=aRow+ver;
		ScrollIntoView(theRect.Left,theRect.Top);
		Selection:=theRect;
		if Editable then
			with StringGridEdit do
			begin
				Text:=StringGrid.Cells[theRect.Left,theRect.Top];
				SetFocus;
				SelectAll;
			end;
	end;
end;

procedure TDLDataSpreadSheet.PasteData;
var
	theData,theNum:string;
	numChars,numLines,numTabs,maxTabs,i,j,k,start,startIndex,colNum,oldRowCount,oldColCOunt:Integer;
	lineFinished:Boolean;
	theLeft,theTop:Integer;
begin
	if Editable and Clipboard.HasFormat(cf_Text) then
		with StringGrid do
		begin
			Screen.Cursor:=crHourGlass;
			theLeft:=Selection.Left;
			theTop:=Selection.Top;
			theData:=Clipboard.AsText;
			numChars:=Length(theData);
			numLines:=0;
			numTabs:=0;
			maxTabs:=0;
			for i:=1 to numChars do
			begin
				if theData[i]=#10 then
				begin
					Inc(numLines);
					if numTabs>maxTabs then
						maxTabs:=numTabs;
					numTabs:=0;
				end;
				if theData[i]=#9 then
					Inc(numTabs);
			end;
			if (numChars=0) or (theData[numChars]<>#10) then
			begin
				theData:=theData+#13+#10;
				Inc(numLines);
			end;
			if theTop+numLines>MaxPoints+1 then
				numLines:=MaxPoints-theTop+1;
			oldRowCount:=RowCount;
			if RowCount<theTop+numLines then
			begin
				if theTop+numLines<=MaxPoints+1 then
					RowCount:=theTop+numLines
				else
					RowCount:=MaxPoints+1;
				for j:=oldRowCount to RowCount-1 do
				begin
					RowHeights[j]:=Abs(Canvas.TextHeight('1'))+4;
					if AutoNumber then
						InsertData(0,j,IntToStr(j));
				end;
			end;
			{if not HasFixedNumCols then
			begin
				oldColCount:=ColCount;
				if ColCount<theLeft+maxTabs+1 then
				begin
					if theLeft+maxTabs+1<=MaxColumns then
						ColCount:=theLeft+maxTabs+1
					else
						ColCount:=MaxColumns;
					SetLength(CellFormat,ColCount);
					SetLength(CellPlaces,ColCount);
					SetLength(OldColWidths,ColCount);
					for i:=oldColCount to ColCount-1 do
					begin
						StringGrid.ColWidths[i]:=DefaultColWidth;
						SetLength(CellFormat[i],RowCount);
						SetLength(CellPlaces[i],RowCount);
						CellFormat[i,0]:=CellFormat[i-1,0];
						CellPlaces[i,0]:=CellPlaces[i-1,0];
						if AutoColNumber then
							InsertData(i,0,IntToStr(i));
						for j:=1 to RowCount-1 do
						begin
							CellFormat[i,j]:=CellFormat[i,j-1];
							CellPlaces[i,j]:=CellPlaces[i,j-1];
						end;
					end;
				end;
			end;}
			k:=0;
			start:=0;
			for i:=1 to numLines do
			begin
				lineFinished:=False;
				start:=start+k+1;
				k:=-1;
				colNum:=theLeft-1;
				startIndex:=start;
				repeat
					Inc(colNum);
					if colNum>ColCount-1 then
					begin
						repeat
							Inc(k);
						until theData[start+k]=#10;
						lineFinished:=True;
					end
					else
					begin
						repeat
							Inc(k);
						until (theData[start+k]=#9) or (theData[start+k]=#13) or (theData[start+k]=#10);
						theNum:=Copy(theData,startIndex,start+k-startIndex);
						InsertData(colNum,theTop+i-1,theNum);
						if theData[start+k]=#10 then
							lineFinished:=True
						else
							if theData[start+k]<>#9 then
								begin
									repeat
										Inc(k);
									until (theData[start+k]=#9) or (theData[start+k]=#10);
										if theData[start+k]=#10 then
											lineFinished:=True;
								end;
							startIndex:=start+k+1;
					end;
				until lineFinished;
			end;
			with StringGridEdit do
			begin
				Text:=Cells[theLeft,theTop];
				SetFocus;
				SelectAll;
			end;
			Screen.Cursor:=crDefault;
		end;
end;

procedure TDLDataSpreadSheet.PastePopupClick(Sender: TObject);
begin
	PasteData;
end;

procedure TDLDataSpreadSheet.ResetSpreadSheet;
var
	i,j:Integer;
	theRect:TGridRect;
	theHeight:Integer;
begin
	with StringGrid do
	begin
		StringGrid.Height:=1200;
		theHeight:=StringGrid.Height;
		{DataFont.Assign(DataDefaultFont);}
		RowCount:={theHeight}1200 div DefaultRowHeight;
		for i:=0 to ColCount-1 do
		begin
			ColWidths[i]:=DefColWidth[SheetTag,i];
			ColFormat[i]:=DefColFormat[SheetTag,i];
			ColPlaces[i]:=DefColPlaces[SheetTag,i];
			for j:=0 to RowCount-1 do
			begin
				if AutoNumber and (i=0) and (j>0) then
					Cells[i,j]:=IntToStr(j)
				else
					Cells[i,j]:='';
			end;
		end;
		SetRowHeights;
		theRect.Left:=FixedCols;
		theRect.Top:=FixedRows;
		theRect.Right:=FixedCols;
		theRect.Bottom:=FixedRows;
		Selection:=theRect;
		ScrollIntoView(theRect.Left,theRect.Top);
	end;
	if Editable then
		StringGridEdit.Text:='';
	IsDirty:=False;
end;

procedure TDLDataSpreadSheet.ScrollIntoView(X, Y: Integer);
var
	i,j,oldRowCount:Integer;
begin
	with StringGrid do
	begin
		if (Y>=RowCount-1) and (Y<MaxPoints) and not FixedNumRows then
		begin
			oldRowCount:=RowCount;
			RowCount:=Y+2;
			RowHeights[Y]:=Abs(Canvas.TextHeight('1'))+4;
			RowHeights[Y+1]:=Abs(Canvas.TextHeight('1'))+4;
			for i:=0 to ColCount-1 do
				for j:=oldRowCount to RowCount-1 do
					if AutoNumber and (i=0) then
						Cells[i,j]:=IntToStr(j)
					else
						Cells[i,j]:='';
		end;
		if Y>=TopRow+VisibleRowCount then
			TopRow:=Y-VisibleRowCount+1
		else
			if Y<TopRow then
				TopRow:=Y;
		if X>=LeftCol+VisibleColCount then
			LeftCol:=X-VisibleColCount+1
		else
			if X<LeftCol then
				LeftCol:=X;
	end;
end;

procedure TDLDataSpreadSheet.ScrollTimerTimer(Sender: TObject);
begin
	with StringGrid do
		if SelectingRow then
		begin
			if ((TimerIncr=-1) and (TopRow>FixedRows)) or ((TimerIncr=1) and (TimerRow<RowCount-1)) then
			begin
				TimerRow:=TimerRow+TimerIncr;
				TopRow:=TopRow+TimerIncr;
				SelectRowsOrCols(TimerRow,TimerCol);
			end;
		end
		else
		begin
			if ((TimerIncr=-1) and (LeftCol>FixedCols)) or ((TimerIncr=1) and (TimerCol<ColCount-1)) then
			begin
				TimerCol:=TimerCol+TimerIncr;
				LeftCol:=LeftCol+TimerIncr;
				SelectRowsOrCols(TimerRow,TimerCol);
			end;
		end;
end;


procedure TDLDataSpreadSheet.SelectAll;
var
	i,j,maxX,maxY:LongInt;
	theRect:TGridRect;
begin
	maxX:=StringGrid.FixedCols;
	maxY:=StringGrid.FixedRows;
	for i:=StringGrid.FixedCols to StringGrid.ColCount-1 do
		for j:=StringGrid.FixedRows to StringGrid.RowCount-1 do
		begin
			if (StringGrid.Cells[i,j]<>'') and (j>maxY) then
				maxY:=j;
			if (StringGrid.Cells[i,j]<>'') and (i>maxX) then
				maxX:=i;
		end;
	theRect.Left:=StringGrid.FixedCols;
	theRect.Top:=StringGrid.FixedRows;
	theRect.Right:=maxX;
	theRect.Bottom:=maxY;
	StringGrid.Selection:=theRect;
end;

procedure TDLDataSpreadSheet.SelectAllPopupClick(Sender: TObject);
begin
	SelectAll;
end;

procedure TDLDataSpreadSheet.SelectRowsOrCols(TheRow,TheCol:Integer);
var
	theRect:TGridRect;
begin
	with StringGrid do
	begin
		if SelectingCol then
		begin
			theRect.Top:=FixedRows;
			theRect.Bottom:=RowCount-1;
			if TheCol>AnchorX then
			begin
				theRect.Left:=AnchorX;
				theRect.Right:=TheCol;
			end
			else
			begin
				theRect.Left:=TheCol;
				theRect.Right:=AnchorX;
			end;
		end
		else
		begin
			theRect.Left:=FixedCols;
			theRect.Right:=ColCount-1;
			if TheRow>AnchorY then
			begin
				theRect.Top:=AnchorY;
				theRect.Bottom:=TheRow;
			end
			else
			begin
				theRect.Top:=TheRow;
				theRect.Bottom:=AnchorY;
			end;
		end;
		if theRect.Left<FixedCols then
			theRect.Left:=FixedCols;
		if theRect.Top<FixedRows then
			theRect.Top:=FixedRows;
		Selection:=theRect;
	end;
end;

procedure TDLDataSpreadSheet.StringGridDrawCell(Sender: TObject; ACol, ARow: Longint; Rect: TRect; State: TGridDrawState);
var
	theAlignment:TCellAlignment;
	value:Double;
	code:Integer;
	theText:string;
begin
	if ACol=0 then
		theAlignment:=RightAlign
	else
		if ARow=0 then
			theAlignment:=CentreAlign
		else
		begin
			Val(StringGrid.Cells[ACol,ARow],value,code);
			if code=0 then
				theAlignment:=RightAlign
			else
				theAlignment:=LeftAlign;
		end;
	with StringGrid.Canvas do
	begin
		Font.Assign(DataFont);
		if (Acol=0) or (ARow=0) then
			Font.Style:=Font.Style+[fsBold];
		if gdSelected in State then
			Font.Color:=clHighlightText;
		theText:=FormatCell(ACol,ARow);
		case theAlignment of
			LeftAlign:TextRect(Rect,Rect.Left+2,Rect.Top+2,theText);
			RightAlign:TextRect(Rect,Rect.Right-2-TextWidth(theText),Rect.Top+2,theText);
			CentreAlign:TextRect(Rect,(Rect.Left+Rect.Right-TextWidth(theText)) div 2,Rect.Top+2,theText);
		end;
	end;
end;

procedure TDLDataSpreadSheet.SetColFormat;
var
	sameFormat,samePlaces:Boolean;
	theFormat:TColFormat;
	thePlaces:Byte;
	i,returnValue:Integer;
begin
	sameFormat:=True;
	samePlaces:=True;
	theFormat:=ColFormat[StringGrid.Selection.Left];
	thePlaces:=ColPlaces[StringGrid.Selection.Left];
	for i:=StringGrid.Selection.Left to StringGrid.Selection.Right do
	begin
		sameFormat:=sameFormat and (theFormat=ColFormat[i]);
		samePlaces:=samePlaces and (thePlaces=ColPlaces[i]);
	end;
	with ColumnFormatDlg do
	begin
		FormShown:=False;
		GeneralRadio.Checked:=sameFormat and (theFormat=gen);
		DecimalRadio.Checked:=sameFormat and (theFormat=deci);
		ScientificRadio.Checked:=sameFormat and (theFormat=sci);
		if samePlaces then
		begin
			NumPlacesUpDown.Position:=thePlaces;
			NumPlacesEdit.Text:=IntToStr(thePlaces);
		end
		else
		begin
			NumPlacesUpDown.Position:=0;
			NumPlacesEdit.Text:='';
		end;
		FormatGroupBox.Caption:='Format';
		returnValue:=ShowModal;
		if returnValue=mrOk then
		begin
			if GeneralRadio.Checked then
			begin
				theFormat:=gen;
				thePlaces:=0;
			end
			else
			begin
				if DecimalRadio.Checked then
					theFormat:=deci
				else
					theFormat:=sci;
				thePlaces:=StrToInt(NumPlacesEdit.Text);
			end;
			for i:=StringGrid.Selection.Left to StringGrid.Selection.Right do
			begin
				ColFormat[i]:=theFormat;
				ColPlaces[i]:=thePlaces;
				DefColFormat[SheetTag,i]:=theFormat;
				DefColPlaces[SheetTag,i]:=thePlaces;
			end;
			StringGrid.Repaint;
		end;
	end;
end;

procedure TDLDataSpreadSheet.StringGridEditChange(Sender: TObject);
begin
	if not MouseIsDown then
		InsertData(StringGrid.Selection.Left,StringGrid.Selection.Top,StringGridEdit.Text);
end;

procedure TDLDataSpreadSheet.StringGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
	aCol,aRow:Integer;
	theRect:TGridRect;
begin
	if Button=mbLeft then
	begin
		MouseIsDown:=True;
		with StringGrid do
		begin
			MouseToCell(X,Y,aCol,aRow);
			SelectingRow:=(aCol=FixedCols-1) and (aRow<>FixedRows-1);
			SelectingCol:=(aRow=FixedRows-1) and (aCol<>FixedCols-1);
			if SelectingRow or SelectingCol then
			begin
				ScrollTimer:=TTimer.Create(Self);
				ScrollTimer.Enabled:=False;
				ScrollTimer.Interval:=75;
				ScrollTimer.OnTimer:=ScrollTimerTimer;
				TimerAssigned:=True;
			end;
			if (SelectingRow or SelectingCol) and (ssShift in Shift) then
				SelectRowsOrCols(aRow,aCol)
			else
			begin
				if not (ssShift in Shift) then
				begin
					if Editable and (aCol>=FixedCols) and (aCol<ColCount) and (aRow>=FixedRows) and (aRow<RowCount) then
						StringGridEdit.Text:=StringGrid.Cells[aCol,aRow]
					else
					begin
						if (aCol=FixedCols-1) and (aRow=FixedRows-1) then
						begin
							theRect.Left:=FixedCols;
							theRect.Right:=ColCount-1;
							theRect.Top:=FixedRows;
							theRect.Bottom:=RowCount-1;
							Selection:=theRect;
						end
						else
							if SelectingRow then
							begin
								theRect.Left:=FixedCols;
								theRect.Right:=ColCount-1;
								theRect.Top:=aRow;
								theRect.Bottom:=aRow;
								Selection:=theRect;
							end
							else
								if SelectingCol then
								begin
									theRect.Left:=aCol;
									theRect.Right:=aCol;
									theRect.Top:=FixedRows;
									theRect.Bottom:=RowCount-1;
									Selection:=theRect;
								end;
						AnchorX:=aCol;
						AnchorY:=aRow;
					end;
				end;
			end;
			if Editable then
				StringGridEdit.SetFocus;
		end;
	end;
end;

procedure TDLDataSpreadSheet.StringGridMouseMove(Sender: TObject;
	Shift: TShiftState; X, Y: Integer);
var
	aCol,aRow:Integer;
	canScroll:Boolean;
begin
	if MouseIsDown then
		with StringGrid do
		begin
			MouseToCell(X,Y,aCol,aRow);
			canScroll:=False;
			if SelectingRow or SelectingCol then
			begin
				if SelectingRow then
				begin
					if aRow>TopRow+VisibleRowCount-1 then
					begin
						aRow:=TopRow+VisibleRowCount;
						canScroll:=TopRow+VisibleRowCount<=RowCount;
						TimerIncr:=1;
					end
					else
						if ((aRow<TopRow) and (aRow>-1)) or (Y<=0) then
						begin
							aRow:=TopRow-1;
							canScroll:=TopRow>FixedRows;
							TimerIncr:=-1;
						end
						else
						begin
							canScroll:=False;
							if aRow>-1 then
								SelectRowsOrCols(aRow,aCol);
						end;
				end
				else
				begin
					if aCol>LeftCol+VisibleColCount-1 then
					begin
						aCol:=LeftCol+VisibleColCount;
						TimerIncr:=1;
						canScroll:=LeftCol+VisibleColCount<=ColCount;
					end
					else
						if ((aCol<LeftCol) and (aCol>-1)) or (X<=0) then
						begin
							aCol:=LeftCol-1;
							TimerIncr:=-1;
							canScroll:=LeftCol>FixedCols;
						end
						else
						begin
							canScroll:=False;
							if aCol>-1 then
								SelectRowsOrCols(aRow,aCol);
						end;
				end;
				if SelectingRow then
					TimerRow:=aRow-TimerIncr
				else
					TimerRow:=aRow;
				if SelectingCol then
					TimerCol:=aCol-TimerIncr
				else
					TimerCol:=aCol;
				if TimerAssigned then
					ScrollTimer.Enabled:=canScroll;
			end;
		end;
end;

procedure TDLDataSpreadSheet.StringGridMouseUp(Sender: TObject;
	Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
	i:Integer;
begin
	if TimerAssigned and (Button=mbLeft) and (SelectingRow or SelectingCol) then
	begin
		ScrollTimer.Free;
		TimerAssigned:=False;
	end;
	MouseIsDown:=False;
	for i:=1 to MaxColumns-1 do
		if DefColWidth[SheetTag,i]<>StringGrid.ColWidths[i] then
		begin
			Isdirty:=True;
			DefColWidth[SheetTag,i]:=StringGrid.ColWidths[i];
		end;
end;

procedure TDLDataSpreadSheet.StringGridPopupMenuPopup(Sender: TObject);
begin
	PastePopup.Enabled:=Editable and Clipboard.HasFormat(cf_Text) and CellsSelected;
	CopyPopup.Enabled:=CellsSelected;
	CutPopup.Enabled:=Editable and CellsSelected;
	DeletePopup.Enabled:=Editable and CellsSelected;
	FormatColumnPopup.Enabled:=CellsSelected;
	if Editable then
		StringGridEdit.SetFocus;
end;

procedure TDLDataSpreadSheet.StringGridTopLeftChanged(Sender: TObject);
var
	theRect:TGridRect;
	i,j,oldRowCount,theLeft,theTop:Integer;
begin
	if not FixedNumRows then
		with StringGrid do
			if (TopRow+VisibleRowCount=RowCount) and not FixedNumRows then
			begin
				oldRowCount:=RowCount;
				theLeft:=LeftCol;
				theTop:=TopRow;
				theRect:=Selection;
				RowCount:=RowCount+1;
				RowHeights[RowCount-1]:=Abs(Canvas.TextHeight('1'))+4;
				for i:=0 to ColCount-1 do
					for j:=oldRowCount to RowCount-1 do
						if AutoNumber and (i=0) then
							StringGrid.Cells[i,j]:=IntToStr(j)
						else
							StringGrid.Cells[i,j]:='';
				if not SelectingRow and not SelectingCol then
				begin
					if MouseIsDown then
						theRect.Bottom:=theRect.Bottom+1;
					Selection:=theRect;
					LeftCol:=theLeft;
					TopRow:=theTop;
				end
				else
					SelectRowsOrCols(Selection.Top,Selection.Left); 
			end;
end;
 
procedure TDLDataSpreadSheet.SetFont;
var
	FontDialog:TFontDialog;
begin
	FontDialog:=TFontDialog.Create(Self);
	FontDialog.Font.Assign(DataFont);
	if FontDialog.Execute then
		DataFont.Assign(FontDialog.Font);
	FontDialog.Free;
	SetRowHeights;
end;

procedure TDLDataSpreadSheet.SetRowHeights;
begin
	Canvas.Font.Assign(DataFont);
	StringGrid.DefaultRowHeight:=Abs(Canvas.TextHeight('1'))+4;
	Canvas.Font.Style:=Canvas.Font.Style+[fsBold];
	StringGrid.ColWidths[0]:=Round(Abs(Canvas.TextWidth('99999'))+4);
end;

procedure TDLDataSpreadSheet.DeselectAll;
var
	theRect:TGridRect;
begin
	theRect.Left:=-1;
	theRect.Top:=-1;
	theRect.Right:=-1;
	theRect.Bottom:=-1;
	StringGrid.Selection:=theRect;
end;

function TDLDataSpreadSheet.CellsSelected: Boolean;
var
	selected:Boolean;
begin
	selected:=True;
	if (StringGrid.Selection.Left<0) or (StringGrid.Selection.Left>=StringGrid.ColCount) then
		selected:=False;
	if (StringGrid.Selection.Top<0) or (StringGrid.Selection.Bottom>=StringGrid.RowCount) then
		selected:=False;
	CellsSelected:=selected;
end;

procedure TDLDataSpreadSheet.SelectCell(X, Y: Integer);
var
	theRect:TGridRect;
begin
	ScrollIntoView(X,Y);
	theRect.Left:=X;
	theRect.Right:=X;
	theRect.Top:=Y;
	theRect.Bottom:=Y;
	StringGrid.Selection:=theRect;
	if Editable then
	begin
		StringGridEdit.Text:=StringGrid.Cells[X,Y];
		StringGridEdit.SetFocus;
		StringGridEdit.SelectAll;
	end;
end;

{ TMyEdit }

procedure TMyEdit.MyExit(Sender: TObject);
begin
	if Screen.ActiveControl=TDLDataSpreadSheet(Owner).TopPanel then
		TDLDataSpreadSheet(Owner).KeyboardChange(vk_Tab);
end;

procedure TMyEdit.WMChar(var Msg: TMessage);
begin
	if Msg.wParam<>vk_Return then
		inherited;
end;

procedure TMyEdit.WMClear(var Msg: TMessage);
begin
	TDLDataSpreadSheet(Owner).IsDirty:=True;
	if not ControlDown then
		inherited;
	ControlDown:=False;
end;

procedure TMyEdit.WMCopy(var Msg: TMessage);
begin
	if not ControlDown then
		inherited;
	ControlDown:=False;
end;

procedure TMyEdit.WMCut(var Msg: TMessage);
begin
	TDLDataSpreadSheet(Owner).IsDirty:=True;
	if not ControlDown then
		inherited;
	ControlDown:=False;
end;

procedure TMyEdit.WMKeyDown(var Msg: TMessage);
const
	EnterSet=[vk_Return,vk_Left,vk_Right,vk_Up,vk_Down,vk_Tab];
	NonAlphaNumSet=[vk_Shift..vk_Escape,vk_Prior..vk_Home,vk_Snapshot,vk_Insert,vk_Help,vk_F1..vk_Scroll,vk_LWin..vk_Apps];
begin
	if Msg.WParam=vk_Control then
		ControlDown:=True
	else
		if (Msg.WParam=Ord('X')) and ControlDown then
			frmNewTestDetailsTETE.FileDataSpreadSheet.CutData
		else
			if (Msg.WParam=Ord('C')) and ControlDown then
				frmNewTestDetailsTETE.FileDataSpreadSheet.CopyDataToClipboard
			else
				if (Msg.WParam=Ord('V')) and ControlDown then
					frmNewTestDetailsTETE.FileDataSpreadSheet.PasteData
				else
					if Msg.WParam=vk_Delete then
						frmNewTestDetailsTETE.FileDataSpreadSheet.DeleteCells
					else
						if (Msg.WParam=Ord('A')) and ControlDown then
							frmNewTestDetailsTETE.FileDataSpreadSheet.SelectAll
						else
							if (Msg.WParam=Ord('F')) and ControlDown then
								frmNewTestDetailsTETE.FileDataSpreadSheet.SetColFormat
							else
							begin
								ControlDown:=False;
								if Msg.WParam in EnterSet then
									TDLDataSpreadSheet(Owner).KeyboardChange(Msg.WParam)
								else
								begin
									if not (Msg.WParam in NonAlphaNumSet) then
									begin
										TDLDataSpreadSheet(Owner).IsDirty:=True;
									end;
									inherited;
								end;
							end;
end;

procedure TMyEdit.WMPaste(var Msg: TMessage);
begin
	TDLDataSpreadSheet(Owner).IsDirty:=True;
	if not ControlDown then
		inherited;
	ControlDown:=False;
end;

procedure TMyEdit.WMUndo(var Msg: TMessage);
begin
	TDLDataSpreadSheet(Owner).IsDirty:=True;
	inherited;
end;

end.


 