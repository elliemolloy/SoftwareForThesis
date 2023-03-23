unit DetSpreadsheet;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus, ToolWin, ComCtrls, ImgList,
	Tabnotbk, Grids, Clipbrd, DetColumnFormatDlg, DetGlobal;

const
	MaxDataForms=2;
	DataSpreadsheetColumns=7;
			
type

TCellAlignment=(LeftAlign,RightAlign,CentreAlign,GeneralAlign);

TMyEdit = class(TEdit)
	private
		procedure WMChar(var Msg: TMessage); message wm_Char;
		procedure WMClear(var Msg:TMessage); message wm_Clear;
		procedure WMCut(var Msg:TMessage); message wm_Cut;
		procedure WMPaste(var Msg:TMessage); message wm_Paste;
		procedure WMUndo(var Msg:TMessage); message wm_Undo;
		procedure MyExit(Sender: TObject);
		procedure WMKeyDown(var Msg: TMessage); message wm_KeyDown;
		procedure WMKeyUp(var Msg: TMessage); message wm_KeyUp;
	end;

TDataSpreadsheet = class(TCustomControl)
	constructor Create(AOwner:TWinControl;TheFormTag,NumColumns,NumFixedCols,NumFixedRows:Integer;
								IsEditable,HasFixedNumRows,IsAutoNumbered:Boolean);
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
		procedure SelectPartialRowOrColumn(ThisStart,ThisEnd,ThisTopOrLeft,ThisBottomOrRight:Integer;SelectAllCells,SelectRow:Boolean);
	public
		StringGrid:TStringGrid;
		StringGridEdit:TMyEdit;
		TopPanel:TPanel;
		Editable,AutoNumber,FixedNumRows,IsDirty,SelectingRow,SelectingCol:Boolean;
		ColFormat:array[0..MaxColumns-1] of TCellFormat;
		ColPlaces:array[0..MaxColumns-1] of Byte;
		DataFont:TFont;
		FormTag:Integer;
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
		procedure SelectCells(Left, Right, Top, Bottom: Integer);
		procedure SetCellSelection(X,Y:Integer);
	end;

var
	DataSpreadSheet:TDataSpreadSheet;
	DefColWidth,DataColWidth,DiffuseDefColWidth:array[1..MaxDataForms,0..MaxColumns-1] of Integer;
	DefColFormat,DataColFormat,DiffuseDefColFormat:array[1..MaxDataForms,0..MaxColumns-1] of TCellFormat;
	DefColPlaces,DataColPlaces,DiffuseDefColPlaces:array[1..MaxDataForms,0..MaxColumns-1] of Byte;
	DefDataFont:TFont;
	ControlDown,ShiftDown:Boolean;
		
implementation

uses
	DetMainForm;
		
procedure Delay(DelayTime:LongWord);
var
	startTime:LongWord;
begin
	startTime:=GetTickCount;
	repeat
	until GetTickCount-startTime>DelayTime;
end;

{ TDataSpreadSheet }

procedure TDataSpreadSheet.CopyDataToClipboard;
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

procedure TDataSpreadSheet.CopyPopupClick(Sender: TObject);
begin
	CopyDataToClipboard;
end;

constructor TDataSpreadSheet.Create(AOwner:TWinControl;theFormTag,NumColumns,NumFixedCols,NumFixedRows:Integer;
								IsEditable,HasFixedNumRows,IsAutoNumbered:Boolean);
begin
	ControlDown:=False;
	ShiftDown:=False;
	inherited Create(AOwner);
	Editable:=IsEditable;
	IsDirty:=False;
	FormTag:=TheFormTag;
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
		TabStop:=False;
		Height:=TPageControl(TTabSheet(AOwner).Parent).Height;
		StringGridPopupMenu:=TPopupMenu.Create(Self);
		CutPopup:=TMenuItem.Create(Self);
		CutPopup.Caption:='Cu&t';
		CutPopup.OnClick:=CutPopupClick;
		StringGridPopupMenu.Items.Add(CutPopup);
		CopyPopup:=TMenuItem.Create(Self);
		CopyPopup.Caption:='&Copy';
		CopyPopup.OnClick:=CopyPopupClick;
		StringGridPopupMenu.Items.Add(CopyPopup);
		PastePopup:=TMenuItem.Create(Self);
		PastePopup.Caption:='&Paste';
		PastePopup.OnClick:=PastePopupClick;
		StringGridPopupMenu.Items.Add(PastePopup);
		Separator1Popup:=TMenuItem.Create(Self);
		Separator1Popup.Caption:='-';
		StringGridPopupMenu.Items.Add(Separator1Popup);
		DeletePopup:=TMenuItem.Create(Self);
		DeletePopup.Caption:='&Delete';
		DeletePopup.OnClick:=DeletePopupClick;
		StringGridPopupMenu.Items.Add(DeletePopup);
		SelectAllPopup:=TMenuItem.Create(Self);
		SelectAllPopup.Caption:='Se&lect All';
		SelectAllPopup.OnClick:=SelectAllPopupClick;
		StringGridPopupMenu.Items.Add(SelectAllPopup);
		Separator2Popup:=TMenuItem.Create(Self);
		Separator2Popup.Caption:='-';
		StringGridPopupMenu.Items.Add(Separator2Popup);
		FormatColumnPopup:=TMenuItem.Create(Self);
		FormatColumnPopup.Caption:='&Format Column...';
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
		TopPanel.Parent:=AOwner;
		with TopPanel do
		begin
			TopPanel.Height:=26;
			Align:=alTop;
			TabStop:=True;
		end;
		StringGridEdit:=TMyEdit.Create(Self);
		StringGridEdit.Parent:=AOwner;
		with StringGridEdit do
		begin
			Left:=TopPanel.Left+1;
			Height:=24;
			Top:=TopPanel.Top+1;
			Width:=TopPanel.Width-2;
			OnChange:=StringGridEditChange;
			OnExit:=MyExit;
			TabStop:=True;
		end;
	end;
end;

procedure TDataSpreadSheet.CutData;
begin
	CopyDataToClipBoard;
	DeleteCells;
end;

procedure TDataSpreadSheet.CutPopupClick(Sender: TObject);
begin
	CutData;
end;

procedure TDataSpreadSheet.DeleteCells;
var
	i,j:Integer;
begin
	with StringGrid.Selection do
		for j:=Top to Bottom do
			for i:=Left to Right do
				StringGrid.Cells[i,j]:='';
	StringGridEdit.Text:='';
end;

procedure TDataSpreadSheet.DeletePopupClick(Sender: TObject);
begin
	DeleteCells;
end;

procedure TDataSpreadSheet.FormatColumnPopupClick(Sender: TObject);
begin
	SetColFormat;
end;

destructor TDataSpreadSheet.Destroy;
begin
	if Editable then
	begin
		StringGridEdit.Free;
		TopPanel.Free;
	end;
	DataFont.Free;
	inherited Destroy;
end;

function TDataSpreadSheet.FormatCell(X, Y: Integer): string;
var
	S:string;
	value:Extended;
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
				gen:	S:=FloatToStrF(value,ffGeneral,18,0);
				deci:	S:=FloatToStrF(value,ffFixed,18,ColPlaces[X]);
				sci:	S:=FloatToStrF(value,ffExponent,ColPlaces[X],0);
			end;
		end
		else
			S:=StringGrid.Cells[X,Y];
	end;
	FormatCell:=S;
end;

procedure TDataSpreadSheet.InsertData(X, Y: Integer; TheText: string);
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

procedure TDataSpreadsheet.KeyboardChange(Key: Word);
var
	hor,ver,aCol,aRow,rightCol,bottomRow:Integer;
	theRect:TGridRect;
begin
	if Editable then
	begin
		with StringGrid do
		begin
			aCol:=Selection.Left;
			aRow:=Selection.Top;
			rightCol:=Selection.Right;
			bottomRow:=Selection.Bottom;
			hor:=0;
			ver:=0;
			if ControlDown then
			begin
				case Key of
					vk_Down:	SelectPartialRowOrColumn(aRow,RowCount-1,aCol,rightCol,ShiftDown,False);
					vk_Right:	SelectPartialRowOrColumn(aCol,ColCount-1,aRow,bottomRow,ShiftDown,True);
					vk_Left:	SelectPartialRowOrColumn(aCol,1,aRow,bottomRow,ShiftDown,True);
					vk_Up:	 	SelectPartialRowOrColumn(aRow,1,aCol,rightCol,ShiftDown,False);
				end
			end
			else
			begin
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
				with StringGridEdit do
				begin
					Text:=Cells[theRect.Left,theRect.Top];
					SetFocus;
					SelectAll;
				end;
			end;
		end;
	end; 
end;

procedure TDataSpreadSheet.PasteData;
var
	theData,theNum:string;
	numChars,numLines,i,k,start,startIndex,colNum:Integer;
	lineFinished:Boolean;
	theLeft,theTop,oldRowCount:Integer;
begin
	if Editable and Clipboard.HasFormat(cf_Text) then
	begin
		Screen.Cursor:=crHourGlass;
		theLeft:=StringGrid.Selection.Left;
		theTop:=StringGrid.Selection.Top;
		theData:=Clipboard.AsText;
		numChars:=Length(theData);
		numLines:=0;
		for i:=1 to numChars do
			if theData[i]=#10 then
				Inc(numLines);
		if (numChars=0) or (theData[numChars]<>#10) then
		begin
			theData:=theData+#13+#10;
			Inc(numLines);
		end;
		if theTop+numLines>MaxPoints+1 then
			numLines:=MaxPoints-theTop+1;
		if (StringGrid.RowCount<theTop+numLines) and not FixedNumRows then
		begin
			oldRowCount:=StringGrid.RowCount;
			StringGrid.RowCount:=theTop+numLines;
			if AutoNumber then
				for i:=oldRowCount to StringGrid.RowCount do
        	StringGrid.Cells[0,i]:=IntToStr(i);
		end;
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
				if colNum>StringGrid.ColCount-1 then
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
			Text:=StringGrid.Cells[theLeft,theTop];
			SetFocus;
			SelectAll;
		end;
		Screen.Cursor:=crDefault;
	end;
end;

procedure TDataSpreadSheet.PastePopupClick(Sender: TObject);
begin
	PasteData;
end;

procedure TDataSpreadSheet.ResetSpreadSheet;
var
	i,j:Integer;
	theRect:TGridRect;
	theHeight:Integer;
begin
	with StringGrid do
	begin
		FixedRows:=1;
		theHeight:=StringGrid.Height;
		{DataFont.Assign(DataDefaultFont);}
		RowCount:=theHeight div DefaultRowHeight;
		for i:=0 to ColCount-1 do
		begin
			if Mode=DiffuseDetectorModel then
			begin
				ColWidths[i]:=DiffuseDefColWidth[FormTag,i];
				ColFormat[i]:=DiffuseDefColFormat[FormTag,i];
				ColPlaces[i]:=DiffuseDefColPlaces[FormTag,i];
			end
			else
			begin
				ColWidths[i]:=DefColWidth[FormTag,i];
				ColFormat[i]:=DefColFormat[FormTag,i];
				ColPlaces[i]:=DefColPlaces[FormTag,i];
			end;
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

procedure TDataSpreadSheet.ScrollIntoView(X, Y: Integer);
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

procedure TDataSpreadSheet.ScrollTimerTimer(Sender: TObject);
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


procedure TDataSpreadSheet.SelectAll;
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

procedure TDataSpreadSheet.SelectAllPopupClick(Sender: TObject);
begin
	SelectAll;
end;

procedure TDataSpreadSheet.SelectRowsOrCols(TheRow,TheCol:Integer);
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

procedure TDataSpreadSheet.StringGridDrawCell(Sender: TObject; ACol, ARow: Longint; Rect: TRect; State: TGridDrawState);
var
	theAlignment:TCellAlignment;
	value:Extended;
	code:Integer;
	theText:string;
begin
	{if ACol=0 then
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
	end;}
end;

procedure TDataSpreadSheet.SetColFormat;
var
	sameFormat,samePlaces:Boolean;
	theFormat:TCellFormat;
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
		if StringGrid.Selection.Left=StringGrid.Selection.Right then
			Caption:='Format Column'
		else
			Caption:='Format Columns';
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
		if StringGrid.Selection.Left=StringGrid.Selection.Right then
		begin
			SaveDefButton.Enabled:=True;
			LoadDefButton.Enabled:=True;
		end
		else
		begin
			SaveDefButton.Enabled:=False;
			LoadDefButton.Enabled:=False;
		end;
		ColumnNum:=StringGrid.Selection.Left;
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
			end;
			StringGrid.Repaint;
			IsDirty:=True;
		end;
	end;
end;

procedure TDataSpreadSheet.StringGridEditChange(Sender: TObject);
begin
	if not MouseIsDown then
		InsertData(StringGrid.Selection.Left,StringGrid.Selection.Top,StringGridEdit.Text);
end;

procedure TDataSpreadSheet.StringGridMouseDown(Sender: TObject;
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

procedure TDataSpreadSheet.StringGridMouseMove(Sender: TObject;
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

procedure TDataSpreadSheet.StringGridMouseUp(Sender: TObject;
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
		if DataColWidth[FormTag,i]<>StringGrid.ColWidths[i] then
		begin
			Isdirty:=True;
			DataColWidth[FormTag,i]:=StringGrid.ColWidths[i];
			if Mode=DiffuseDetectorModel then
       	DiffuseDefColWidth[FormTag,i]:=StringGrid.ColWidths[i]
			else
				DefColWidth[FormTag,i]:=StringGrid.ColWidths[i];
		end;
end;

procedure TDataSpreadSheet.StringGridPopupMenuPopup(Sender: TObject);
begin
	PastePopup.Enabled:=Editable and Clipboard.HasFormat(cf_Text) and CellsSelected;
	CopyPopup.Enabled:=CellsSelected;
	CutPopup.Enabled:=Editable and CellsSelected;
	DeletePopup.Enabled:=Editable and CellsSelected;
	FormatColumnPopup.Enabled:=CellsSelected;
	if StringGrid.Selection.Left=StringGrid.Selection.Right then
		FormatColumnPopup.Caption:='Format Column...'
	else
		FormatColumnPopup.Caption:='Format Columns...';
	if Editable then
		StringGridEdit.SetFocus;
end;

procedure TDataSpreadSheet.StringGridTopLeftChanged(Sender: TObject);
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
 
procedure TDataSpreadSheet.SetFont;
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

procedure TDataSpreadSheet.SetRowHeights;
begin
	Canvas.Font.Assign(DataFont);
	StringGrid.DefaultRowHeight:=Abs(Canvas.TextHeight('1'))+4;
	Canvas.Font.Style:=Canvas.Font.Style+[fsBold];
	StringGrid.ColWidths[0]:=Round(Abs(Canvas.TextWidth('99999'))+4);
end;

procedure TDataSpreadSheet.DeselectAll;
var
	theRect:TGridRect;
begin
	theRect.Left:=-1;
	theRect.Top:=-1;
	theRect.Right:=-1;
	theRect.Bottom:=-1;
	StringGrid.Selection:=theRect;
end;

function TDataSpreadSheet.CellsSelected: Boolean;
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

procedure TDataSpreadSheet.SetCellSelection(X, Y: Integer);
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

procedure TDataSpreadsheet.SelectCell(X, Y: Integer);
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

procedure TDataSpreadsheet.SelectCells(Left, Right, Top, Bottom: Integer);
var
	theRect:TGridRect;
begin
	ScrollIntoView(Left,Top);
	theRect.Left:=Left;
	theRect.Right:=Right;
	theRect.Top:=Top;
	theRect.Bottom:=Bottom;
	StringGrid.Selection:=theRect;
	if Editable then
	begin
		StringGridEdit.SetFocus;
		StringGridEdit.SelectAll;
	end;
end;

procedure TDataSpreadsheet.SelectPartialRowOrColumn(ThisStart, ThisEnd,
  ThisTopOrLeft, ThisBottomOrRight: Integer; SelectAllCells,
  SelectRow: Boolean);
var
	theRect:TGridRect;
	startCellEmpty,checkingCells:Boolean;
	i:Integer;
	thisCellText:string;
begin
	with StringGrid do
	begin
		with StringGridEdit do
		begin
			if SelectRow then
				startCellEmpty:=Cells[ThisStart,ThisTopOrLeft]=''
			else
				startCellEmpty:=Cells[ThisTopOrLeft,ThisStart]='';
			i:=ThisStart;
			checkingCells:=True;
			repeat
				if SelectRow then
					thisCellText:=Cells[i,ThisTopOrLeft]
				else
					thisCellText:=Cells[ThisTopOrLeft,i];
				if thisCellText='' then
					if startCellEmpty then
					begin
						if i<>ThisEnd then
							if ThisStart<ThisEnd then
								Inc(i)
							else
								Dec(i);
					end
					else
						checkingCells:=False
				else
					if startCellEmpty then
						checkingCells:=False
					else
					begin
						if i<>ThisEnd then
							if ThisStart<ThisEnd then
								Inc(i)
							else
								Dec(i);
					end;
			until (i=ThisEnd) or not checkingCells;
			if SelectRow then
				thisCellText:=Cells[i,ThisTopOrLeft]
			else
				thisCellText:=Cells[ThisTopOrLeft,i];
			if (i<>ThisEnd) or checkingCells then
				if (thisCellText='') and not startCellEmpty then
					if ThisStart<ThisEnd then
					Dec(i)
				else
					Inc(i);
			if SelectRow then
			begin
				theRect.Top:=ThisTopOrLeft;
				if SelectAllCells then
				begin
					theRect.Bottom:=ThisBottomOrRight;
					if ThisStart<ThisEnd then
					begin
						theRect.Left:=ThisStart;
						theRect.Right:=i;
					end
					else
					begin
						theRect.Left:=i;
						theRect.Right:=ThisStart;
					end;
				end
				else
				begin
					theRect.Bottom:=ThisTopOrLeft;
					theRect.Left:=i;
					theRect.Right:=i;
				end;
			end
			else
			begin
				theRect.Left:=ThisTopOrLeft;
				if SelectAllCells then
				begin
					theRect.Right:=ThisBottomOrRight;
					if ThisStart<ThisEnd then
					begin
						theRect.Top:=ThisStart;
						theRect.Bottom:=i;
					end
					else
					begin
						theRect.Top:=i;
						theRect.Bottom:=ThisStart;
					end;
				end
				else
				begin
					theRect.Right:=ThisTopOrLeft;
					theRect.Top:=i;
					theRect.Bottom:=i;
				end;
			end;
			ScrollIntoView(theRect.Left,theRect.Top);
			Selection:=theRect;
			Text:=Cells[theRect.Left,theRect.Top];
			SetFocus;
			SelectAll;
		end;
	end;
end;


{ TMyEdit }

procedure TMyEdit.MyExit(Sender: TObject);
begin
	if Screen.ActiveControl=TDataSpreadSheet(Owner).TopPanel then
		TDataSpreadSheet(Owner).KeyboardChange(vk_Tab);
end;

procedure TMyEdit.WMChar(var Msg: TMessage);
begin
	if Msg.wParam<>vk_Return then
		inherited;
end;

procedure TMyEdit.WMClear(var Msg: TMessage);
begin
	TDataSpreadSheet(Owner).IsDirty:=True;
	inherited;
end;

procedure TMyEdit.WMCut(var Msg: TMessage);
begin
	TDataSpreadSheet(Owner).IsDirty:=True;
	inherited;
end;

procedure TMyEdit.WMKeyDown(var Msg: TMessage);
const
	EnterSet=[vk_Return,vk_Left,vk_Right,vk_Up,vk_Down,vk_Tab];
	NonAlphaNumSet=[vk_Shift..vk_Escape,vk_Prior..vk_Home,vk_Snapshot,vk_Insert,vk_Help,vk_F1..vk_Scroll,vk_LWin..vk_Apps];
begin
	if Msg.WParam=vk_Shift then
		ShiftDown:=True;
	if Msg.WParam=vk_Control then
		ControlDown:=True
	else
		if (Msg.WParam=Ord('X')) and ControlDown then
			TDataSpreadSheet(Owner).CutData
		else
			if (Msg.WParam=Ord('C')) and ControlDown then
				TDataSpreadSheet(Owner).CopyDataToClipboard
			else
				if (Msg.WParam=Ord('V')) and ControlDown then
					TDataSpreadSheet(Owner).PasteData
				else
					if Msg.WParam=vk_Delete then
						TDataSpreadSheet(Owner).DeleteCells
					else
						if (Msg.WParam=Ord('A')) and ControlDown then
							TDataSpreadSheet(Owner).SelectAll
						else
							if (Msg.WParam=Ord('F')) and ControlDown then
							TDataSpreadSheet(Owner).SetColFormat
							else
							begin
								if Msg.WParam in EnterSet then
									TDataSpreadSheet(Owner).KeyboardChange(Msg.WParam)
								else
								begin
									if not (Msg.WParam in NonAlphaNumSet) then
									begin
										TDataSpreadSheet(Owner).IsDirty:=True;
									end;
									inherited;
								end;
							end;
end;

procedure TMyEdit.WMKeyUp(var Msg: TMessage);
begin
	if Msg.WParam=vk_Control then
		ControlDown:=False;
	if Msg.WParam=vk_Shift then
		ShiftDown:=False;
end;

procedure TMyEdit.WMPaste(var Msg: TMessage);
begin
	TDataSpreadSheet(Owner).IsDirty:=True;
	inherited;
end;

procedure TMyEdit.WMUndo(var Msg: TMessage);
begin
	TDataSpreadSheet(Owner).IsDirty:=True;
	inherited;
end;

end.



