unit DirectPrint;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ComCtrls, Menus, Printers, RichEdit, ExtCtrls;

const
	CrLf=#13+#10;
	to_PreNewPage=501;
	to_PostNewPage=502;

type

TJustification=(tjLeft,tjRight,tjCentre,tjJust);
TPitch=(D,F,V);

TPagesToPrintRec=record
	PrintRange:TPrintRange;
	FromPage:Integer;
	ToPage:Integer;
end;

TTextObject=class(TObject)
	Size:Integer;
	TextMessage:string;
	FontArray:array of HFont;
	OldAlign:Word;
	WindowHandle:HWnd;
	ParentPagesToPrint:TPagesToPrintRec;
	constructor Create(TheSize:Integer);
	procedure Free;
	procedure TextCopy(TheText:string;TheFont:HFont);
	procedure TextCat(TheText:string;TheFont:HFont);
	procedure AddCrLfs(Count:Integer;TheFont:HFont);
	function GetTextWidth:Integer;
	function GetTextHeight(TheFont:HFont):Integer;
	function GetCharHeight(TheFont:HFont):Integer;
	function GetALine(var TheLine,TheMessage:string;MaxLength:Integer;var NumSpaces:Integer;
												var NeedsJust:Boolean;var StartIndex,StartIncr:Integer;FirstLine:Boolean):Boolean;
	procedure PrintText(PageNum:Integer;TheOrigin,TheExtent:TPoint;var StartPos:TPoint;
													TheJustification:TJustification;LineSpacing:Extended);
	procedure PrintGenNumber(PageNum:Integer;TheOrigin,TheExtent:TPoint;var StartPos:TPoint;Number:Extended;
								Tab:Integer;NumberFont,SignFont:HFont;Plus:Boolean);
	procedure PrintDecNumber(PageNum:Integer;TheOrigin,TheExtent:TPoint;var StartPos:TPoint;Number:Extended;
								Digits,Tab:Integer;NumberFont,SignFont:HFont;Plus:Boolean);
	procedure PrintSciNumber(PageNum:Integer;TheOrigin,TheExtent:TPoint;var StartPos:TPoint;Number:Extended;
								Digits,Tab,SuperOffset:Integer;NumberFont,SignFont,ExponentFont,ExponentSignFont,XFont:HFont;Plus:Boolean);
	procedure PrintNumber(PageNum:Integer;TheOrigin,TheExtent:TPoint;var StartPos:TPoint;Number:Extended;Digits,
												Tab:Integer;NumberFont,SignFont:HFont);
	procedure PrintRichText(TheRichEdit:TRichEdit;PageNum:Integer;TheOrigin,TheExtent:TPoint;var StartPos:TPoint;
													TheJustification:TJustification;LineSpacing:Extended);
end;

function CreatePrinterFont(Height:Extended;Angle:Integer;Style:TFontStyles;Pitch:TPitch;FaceName:string):HFont;
function CreateScreenFont(Height:Extended;Angle:Integer;Style:TFontStyles;Pitch:TPitch;FaceName:string):HFont;
function SetUpPrinting(ThePrintDialog:TPrintDialog;LeftMargin,RightMargin,TopMargin,BottomMargin:Extended;var Origin,Extent:TPoint):Boolean;
function NeedToPrintPage(ThePagesToPrint:TPagesToPrintRec;PageNum:Integer):Boolean;

var
	PrinterResolution:Integer;

implementation

{.......................................................}

function Power(X:Extended;n:Extended):Extended;
begin
	if Int(n)=n then
  begin
		if n=0 then
			Power:=1
		else
			if n>0 then
				Power:=X*Power(X,n-1)
			else
				Power:=Power(X,n+1)/X;
	end
	else
		if X>0 then
    	Power:=Exp(n*Ln(X))
		else
			Power:=0;
end;

{.......................................................}

procedure GetNumAndExp(Value:Extended;var Num:Extended;var Exponent:Integer);
var
	approxExp:Extended;
begin
	if Value=0.0 then
	begin
		Exponent:=0;
		Num:=Value;
	end
	else
  begin
		approxExp:=ln(Abs(Value))/ln(10.0);
		if (Int(approxExp)=approxExp) or (approxExp>0.0) then
			Exponent:=Trunc(approxExp)
		else
			Exponent:=Trunc(approxExp)-1;
		Num:=Value/Power(10.0,Exponent);
  end;
end;

{____________________________________________________________________________________________
TTextObject Methods																																    			 }

constructor TTextObject.Create(TheSize: Integer);
begin
	inherited Create;
	WindowHandle:=0;
	Size:=TheSize;
	SetLength(FontArray,TheSize+1);
	with ParentPagesToPrint do
	begin
		PrintRange:=prAllPages;
		FromPage:=0;
		ToPage:=0;
	end;
	OldAlign:=SetTextAlign(Printer.Canvas.Handle,ta_Left or ta_BaseLine or ta_NoUpDateCP);
end;

{.......................................................}

procedure TTextObject.Free;
begin
	SetTextAlign(Printer.Canvas.Handle,OldAlign);
	SetLength(FontArray,0);
	inherited Free;
end;

{.......................................................}

procedure TTextObject.TextCopy(TheText:string;TheFont:HFont);
var
	i,L:Integer;
begin
	L:=Length(TheText);
	if L>0 then
		for i:=1 to Length(TheText) do
			FontArray[i]:=TheFont
	else
		FontArray[1]:=TheFont;
	TextMessage:=TheText;
end;

{.......................................................}

procedure TTextObject.TextCat(TheText:string;TheFont:HFont);
var
	i,L1,L2:Integer;
begin
	L1:=Length(TextMessage);
	L2:=Length(TheText);
	if L2>0 then
		for i:=L1+1 to L1+L2 do
			FontArray[i]:=TheFont
	else
		FontArray[L1+1]:=TheFont;
	TextMessage:=TextMessage+TheText;
end;

{.......................................................}

procedure TTextObject.AddCrLfs(Count:Integer;TheFont:HFont);
var
	i,L:Integer;
begin
	L:=Length(TextMessage);
	if Count>0 then
  begin
		for i:=L+1 to L+2*Count do
			FontArray[i]:=TheFont;
		for i:=1 to Count do
			TextMessage:=TextMessage+CrLf;
  end;
end;

{.......................................................}

function TTextObject.GetTextWidth:Integer;
var
	width,i:Integer;
	theChar:string;
	oldFont:HFont;
begin
	width:=0;
	if Length(TextMessage)>0 then
	begin
		oldFont:=SelectObject(Printer.Canvas.Handle,FontArray[1]);
		for i:=1 to Length(TextMessage) do
		begin
			theChar:=TextMessage[i];
			SelectObject(Printer.Canvas.Handle,FontArray[i]);
			width:=width+Printer.Canvas.TextWidth(theChar);
		end;
    SelectObject(Printer.Canvas.Handle,oldFont);
	end;
	GetTextWidth:=width;
end;

{.......................................................}

function TTextObject.GetTextHeight(TheFont: HFont): Integer;
var
	oldFont:HFont;
	theHeight:Integer;
begin
	oldFont:=SelectObject(Printer.Canvas.Handle,TheFont);
	theHeight:=Printer.Canvas.TextHeight('1');
	SelectObject(Printer.Canvas.Handle,oldFont);
	GetTextHeight:=theHeight;
end;

{.......................................................}

function TTextObject.GetCharHeight(TheFont: HFont): Integer;
var
	oldFont:HFont;
	theHeight:Integer;
	metrics:TTextMetric;
begin
	oldFont:=SelectObject(Printer.Canvas.Handle,TheFont);
	GetTextMetrics(Printer.Canvas.Handle,metrics);
	theHeight:=metrics.tmAscent;
	SelectObject(Printer.Canvas.Handle,oldFont);
	GetCharHeight:=theHeight;
end;

{.......................................................}

function TTextObject.GetALine(var TheLine,TheMessage:string;MaxLength:Integer;var NumSpaces:Integer;
												var NeedsJust:Boolean;var StartIndex,StartIncr:Integer;FirstLine:Boolean):Boolean;
const
	endCharSet=[' ',#10,#0];
var
	i,L,extraSpaces,theSize:Integer;
	theChar:string;
	ch:Char;
begin
	ch:=TheMessage[1];
	if not FirstLine then
		while ch=' ' do
		begin
			Inc(startIndex);
			TheMessage:=Copy(TheMessage,2,Length(TheMessage)-1);
			ch:=TheMessage[1];
		end;
	L:=Length(TheMessage);
	i:=0;
	NumSpaces:=0;
	theSize:=0;
	repeat
		Inc(i);
		ch:=TheMessage[i];
		if ch=' ' then
			Inc(NumSpaces);
		SelectObject(Printer.Canvas.Handle,FontArray[StartIndex+i-1]);
		theChar:=ch;
		if (ch<>#10) and (ch<>#13) then
			theSize:=theSize+Printer.Canvas.TextWidth(theChar);
	until (i=L) or (theSize>maxLength) or (ch=#10);
	if (i=L) and (ch<>#10) then
	begin
		Inc(i);
		ch:=#0;
		TheMessage:=TheMessage+#0;
	end;
	if (theSize>maxLength) and (i>1) then
	begin
		StartIncr:=i-1;
		repeat
			Dec(i);
			ch:=TheMessage[i];
		until (ch in endCharSet) or (i=1);
	end;
	if (i=1) and not (ch in endCharSet) then
	begin
		TheLine:=Copy(TheMessage,1,StartIncr);
		TheMessage:=Copy(TheMessage,StartIncr+1,Length(TheMessage)-StartIncr);
		NeedsJust:=False;
		GetALine:=True;
	end
	else
	case ch of
	' ':begin
  			extraSpaces:=0;
				repeat
					Inc(extraSpaces);
					Dec(NumSpaces);
					Dec(i);
					ch:=TheMessage[i];
				until ch<>' ';
				TheLine:=Copy(TheMessage,1,i);
				TheMessage:=Copy(TheMessage,i+1+extraSpaces,Length(TheMessage)-i-extraSpaces);
        StartIncr:=i+extraSpaces;
				NeedsJust:=True;
				GetALine:=True;
			end;
	#10:begin
				TheLine:=Copy(TheMessage,1,i-2);
				TheMessage:=Copy(TheMessage,i+1,Length(TheMessage)-i);
				StartIncr:=i;
				NeedsJust:=False;
				GetALine:=True;
			end;
	#0:	begin
				TheLine:=Copy(TheMessage,1,i-1);
				TheMessage:='';
				StartIncr:=i-1;
				NeedsJust:=False;
				GetALine:=False;
			end;
	end;
end;

{.......................................................}

procedure TTextObject.PrintText(PageNum:Integer;TheOrigin,TheExtent:TPoint;var StartPos:TPoint;
											TheJustification:TJustification;LineSpacing:Extended);
var
	i,L,numSpaces,maxLength,startIndex,startIncr,theSize,theHeight:Integer;
	theLine,theMessage:string;
	newLine,needsJust,sameFont,freshNewPage,firstLine:Boolean;
	lastFont,nextFont,oldFont:HFont;
	someText,theChar:string;
	wParam,lParam:Longint;
begin
	freshNewPage:=False;
	theMessage:=TextMessage;
	oldFont:=SelectObject(Printer.Canvas.Handle,FontArray[1]);
	theHeight:=Round(GetTextHeight(FontArray[1])*LineSpacing);
	startIndex:=1;
	L:=Length(theMessage);
	firstLine:=True;
	while theMessage<>'' do
	begin
		maxLength:=TheExtent.x-StartPos.x;
		if (maxLength=0) and (theMessage<>CrLf) then
		begin
			StartPos.x:=TheOrigin.x;
			StartPos.y:=StartPos.y+theHeight;
			maxLength:=theExtent.x-StartPos.x;
		end;
		newLine:=GetALine(theLine,theMessage,maxLength,numSpaces,needsJust,startIndex,startIncr,firstLine);
		firstLine:=False;
		theSize:=0;
		if Length(theLine)<>0 then
		begin
			for i:=1 to Length(theLine) do
			begin
				theChar:=theLine[i];
				SelectObject(Printer.Canvas.Handle,FontArray[startIndex+i-1]);
				theSize:=theSize+Printer.Canvas.TextWidth(theChar);
			end;
			case TheJustification of
				tjLeft:StartPos.x:=StartPos.x;
				tjRight:StartPos.x:=theExtent.x-theSize;
				tjCentre:StartPos.x:=(StartPos.x+TheExtent.x-theSize) div 2;
				tjJust:	begin
							if needsJust then
								SetTextJustification(Printer.Canvas.Handle,theExtent.x-theSize-StartPos.x,numSpaces);
								end;
			end;
		end;
		if (theLine<>'') or newLine then
		begin
			if StartPos.y>TheExtent.y then
			begin
				wParam:=MakeLong(TheOrigin.x,TheOrigin.y);
				lParam:=MakeLong(TheExtent.x,TheExtent.y);
				SendMessage(WindowHandle,to_PreNewPage,wParam,lParam);
				Inc(PageNum);
				if NeedToPrintPage(ParentPagesToPrint,PageNum) and
						((ParentPagesToPrint.PrintRange=prAllPages) or (ParentPagesToPrint.FromPage<PageNum)) then
					Printer.NewPage;
				SendMessage(WindowHandle,to_PostNewPage,wParam,lParam);
				StartPos:=theOrigin;
				freshNewPage:=True;
			end;
			if (theLine<>'') then
			begin
				L:=Length(theLine);
				i:=0;
				repeat
					sameFont:=True;
					lastFont:=FontArray[startIndex+i];
					someText:='';
					while sameFont and (i<L) do
					begin
						Inc(i);
						theChar:=theLine[i];
						someText:=someText+theChar;
						if i<L then
							nextFont:=FontArray[startIndex+i];
						if nextFont<>lastFont then
							sameFont:=False;
					end;
					if freshNewPage then
					begin
						StartPos.y:=StartPos.y+GetCharHeight(lastFont);
						freshNewPage:=False;
					end;
					SelectObject(Printer.Canvas.Handle,lastFont);
					if NeedToPrintPage(ParentPagesToPrint,PageNum) then
						Printer.Canvas.TextOut(StartPos.x,StartPos.y,someText);
					theSize:=Printer.Canvas.TextWidth(someText);
					StartPos.x:=StartPos.x+theSize;
				until (i=L);
			end;
		end;
		startIndex:=startIndex+startIncr;
		if newLine then
		begin
			StartPos.x:=theOrigin.x;
			StartPos.y:=StartPos.y+theHeight;
			SetTextJustification(Printer.Canvas.Handle,0,numSpaces);
		end;
	end;
	SelectObject(Printer.Canvas.Handle,oldFont);
end;

{.......................................................}

procedure TTextObject.PrintGenNumber(PageNum:Integer;TheOrigin,TheExtent:TPoint;var StartPos:TPoint;Number:Extended;
								Tab:Integer;NumberFont,SignFont:HFont;Plus:Boolean);
var
	S:array[0..30] of Char;
begin
	if Number<0 then
		TextCopy('-',SignFont)
	else
		if Plus then
			TextCopy('+',SignFont)
		else
			TextCopy('',NumberFont);
	Str(Abs(Number),S);
	TextCat(S,NumberFont);
	if GetTextWidth<Tab then
		StartPos.x:=TheOrigin.x+Tab-GetTextWidth;
	PrintText(PageNum,TheOrigin,TheExtent,StartPos,tjLeft,1.25);
end;

{.......................................................}

procedure TTextObject.PrintDecNumber(PageNum:Integer;TheOrigin,TheExtent:TPoint;var StartPos:TPoint;Number:Extended;
								Digits,Tab:Integer;NumberFont,SignFont:HFont;Plus:Boolean);
var
	S:array[0..30] of Char;
begin
	if Number<0 then
		TextCopy('-',SignFont)
	else
		if Plus then
			TextCopy('+',SignFont)
		else
			TextCopy('',NumberFont);
	Str(Abs(Number):1:Digits,S);
	TextCat(S,NumberFont);
	if GetTextWidth<Tab then
		StartPos.x:=TheOrigin.x+Tab-GetTextWidth;
	PrintText(PageNum,TheOrigin,TheExtent,StartPos,tjLeft,1.25);
end;

{.......................................................}

procedure TTextObject.PrintSciNumber(PageNum:Integer;TheOrigin,TheExtent:TPoint;var StartPos:TPoint;Number:Extended;
								Digits,Tab,SuperOffset:Integer;NumberFont,SignFont,ExponentFont,ExponentSignFont,XFont:HFont;Plus:Boolean);
var
	S:array[0..30] of Char;
	num:Extended;
	exponent:Integer;
begin
	GetNumAndExp(Number,num,exponent);
	if Number<0 then
		TextCopy('-',SignFont)
	else
		if Plus then
			TextCopy('+',SignFont)
		else
			TextCopy('',NumberFont);
	Str(Abs(num):1:Digits-1,S);
	TextCat(S,NumberFont);
	TextCat(' ',NumberFont);
	TextCat(#180,xFont);
	TextCat(' 10',NumberFont);
	if GetTextWidth<Tab then
		StartPos.x:=TheOrigin.x+Tab-GetTextWidth;
	PrintText(PageNum,TheOrigin,TheExtent,StartPos,tjLeft,1.05);
	if exponent<0 then
		TextCopy('-',ExponentSignFont)
	else
		if Plus then
			TextCopy('+',ExponentSignFont)
		else
			TextCopy('',ExponentFont);
	Str(Abs(exponent),S);
	TextCat(S,ExponentFont);
	StartPos.y:=StartPos.y-SuperOffset;
	PrintText(PageNum,TheOrigin,TheExtent,StartPos,tjLeft,1.05);
	StartPos.y:=StartPos.y+SuperOffset;
end;

{.......................................................}

procedure TTextObject.PrintNumber(PageNum:Integer;theOrigin,theExtent:TPoint;var StartPos:TPoint;Number:Extended;
								Digits,Tab:Integer;NumberFont,SignFont:HFont);
var
  S:array[0..30] of Char;
begin
	if Number<0 then
		TextCopy('-',SignFont)
	else
		TextCopy('+',SignFont);
	Str(Abs(Number):1:Digits,S);
	TextCat(S,NumberFont);
	StartPos.x:=TheOrigin.x+Tab-GetTextWidth;
	PrintText(PageNum,TheOrigin,TheExtent,StartPos,tjLeft,1.25);
end;

{.......................................................}

procedure TTextObject.PrintRichText(TheRichEdit:TRichEdit;PageNum:Integer;TheOrigin,TheExtent:TPoint;var StartPos:TPoint;
													TheJustification:TJustification;LineSpacing:Extended);
var
	format:TCharFormat2;
	theFont,bulletFont:HFont;
	theStyle:TFontStyles;
	i,j,theSize,offset,index,indent:Integer;
	theFontName:string;
	subScript,superScript,newWord,newPara,indented:Boolean;
	maxFontSize:array of Integer;
	oldAlign:Word;
	richEditFocused:Boolean;
	start,len:Integer;
begin
	newWord:=True;
	newPara:=True;
	indented:=False;
	indent:=0;
	if TheRichEdit.Focused then
	begin
		richEditFocused:=True;
		start:=TheRichEdit.SelStart;
		len:=TheRichEdit.SelLength;
		TheRichEdit.Parent.SetFocus;
	end
	else
		richEditFocused:=False;
	oldAlign:=SetTextAlign(Printer.Canvas.Handle,ta_Left or ta_BaseLine or ta_NoUpDateCP);
	for i:=1 to Length(TheRichEdit.Text) do
	begin
		index:=i;
		FillChar(format,SizeOf(TCharFormat2),0);
		format.cbSize:=SizeOf(TCharFormat2);
		TheRichEdit.SelStart:=index-1;
		TheRichEdit.SelLength:=1;
		SendMessage(TheRichEdit.Handle,em_GetCharFormat,1,lParam(@format));
		theStyle:=[];
		if ((format.dwMask and cfm_Bold)<>0) and ((format.dwEffects and cfe_Bold)<>0) then
			theStyle:=theStyle+[fsBold];
		if ((format.dwMask and cfm_Italic)<>0) and ((format.dwEffects and cfe_Italic)<>0) then
			theStyle:=theStyle+[fsItalic];
		if ((format.dwMask and cfm_Underline)<>0) and ((format.dwEffects and cfe_Underline)<>0) then
			theStyle:=theStyle+[fsUnderline];
		theSize:=TheRichEdit.SelAttributes.Size;
		theFontName:=TheRichEdit.SelAttributes.Name;
		subscript:=False;
		superScript:=False;
		if ((format.dwMask and cfe_Subscript)<>0) and ((format.dwEffects and cfe_Subscript)<>0) then
		begin
			subscript:=True;
			offset:=Round(6/5*theSize*PrinterResolution/300.0);
			theSize:=Round(theSize*0.7);
		end
		else
			if ((format.dwMask and cfe_Superscript)<>0) and ((format.dwEffects and cfe_Superscript)<>0) then
			begin
				superscript:=True;
				offset:=Round(6/5*theSize*PrinterResolution/300.0);
				theSize:=Round(theSize*0.7);
			end;
		theFont:=CreatePrinterFont(theSize,0,theStyle,V,theFontName);
		if superscript or subscript then
		begin
			if not newWord or newPara then
				PrintText(PageNum,TheOrigin,TheExtent,StartPos,TheJustification,LineSpacing);
			if newPara then
			begin
				newPara:=False;
				newWord:=True;
				TheOrigin.x:=TheOrigin.x-indent;
				StartPos.x:=TheOrigin.x;
				if TheRichEdit.Paragraph.Numbering=nsBullet then
				begin
					bulletFont:=CreatePrinterFont(TheRichEdit.SelAttributes.Size,0,theStyle,V,theFontName);
					TextCopy(#149+'  ',bulletFont);
					indent:=GetTextWidth;
					PrintText(PageNum,TheOrigin,TheExtent,StartPos,TheJustification,LineSpacing);
					TheOrigin.x:=TheOrigin.x+indent;
				end
				else
					indent:=0;
			end;
			if superscript then
				StartPos.y:=StartPos.y-offset
			else
				StartPos.y:=StartPos.y+offset;
			TextCopy(TheRichEdit.Text[index],theFont);
			PrintText(PageNum,TheOrigin,TheExtent,StartPos,TheJustification,LineSpacing);
			if superscript then
				StartPos.y:=StartPos.y+offset
			else
				StartPos.y:=StartPos.y-offset;
			TextCopy('',theFont);
			newWord:=True;
		end
		else
		begin
			if newPara then
			begin
				newPara:=False;
				PrintText(PageNum,TheOrigin,TheExtent,StartPos,TheJustification,LineSpacing);
				newWord:=True;
				TheOrigin.x:=TheOrigin.x-indent;
				StartPos.x:=TheOrigin.x;
				if TheRichEdit.Paragraph.Numbering=nsBullet then
				begin
					TextCopy(#149+'  ',theFont);
					indent:=GetTextWidth;
					PrintText(PageNum,TheOrigin,TheExtent,StartPos,TheJustification,LineSpacing);
					TheOrigin.x:=TheOrigin.x+indent;
				end
				else
					indent:=0;
			end;
			if newWord then
			begin
				TextCopy(TheRichEdit.Text[index],theFont);
				newWord:=False;
			end
			else
				TextCat(TheRichEdit.Text[index],theFont);
			if TheRichEdit.Text[index]=#10 then
				newPara:=True;
		end;
	end;
	if not newWord then
		PrintText(PageNum,TheOrigin,TheExtent,StartPos,TheJustification,LineSpacing);
	SetTextAlign(Printer.Canvas.Handle,oldAlign);
	if richEditFocused then
	begin
		TheRichEdit.SetFocus;
		TheRichEdit.SelStart:=start;
		TheRichEdit.SelLength:=len;
	end;
end;

{__________________________________________________________________________
Font Procedures																					         					 }

function CreatePrinterFont(Height:Extended;Angle:Integer;Style:TFontStyles;Pitch:TPitch;FaceName:string):HFont;
var
	theLogFont:TLogFont;
begin
	with theLogFont do
	begin
		lfHeight:=-Round(Height/72.0*PrinterResolution);
		lfWidth:=0;
		lfEscapement:=Angle;
		lfOrientation:=0;
		if fsBold in Style then
			lfWeight:=fw_Bold
		else
			lfWeight:=fw_Normal;
		if fsItalic in Style then
			lfItalic:=1
		else
			lfItalic:=0;
		if fsUnderline in Style then
			lfUnderline:=1
		else
			lfUnderline:=0;
		if fsStrikeOut in Style then
			lfStrikeOut:=1
		else
			lfStrikeOut:=0;
		lfCharSet:=ANSI_CharSet;
		lfOutPrecision:=Out_Default_Precis;
		lfClipPrecision:=Clip_Default_Precis;
		lfQuality:=Proof_Quality;
		case Pitch of
			D:lfPitchAndFamily:=Default_Pitch or ff_DontCare;
			F:lfPitchAndFamily:=Fixed_Pitch or ff_DontCare;
			V:lfPitchAndFamily:=Variable_Pitch or ff_DontCare;
		end;
		StrPCopy(lfFaceName,FaceName);
	end;
	CreatePrinterFont:=CreateFontIndirect(theLogFont);
end;

{.......................................................}

function CreateScreenFont(Height:Extended;Angle:Integer;Style:TFontStyles;Pitch:TPitch;FaceName:string):HFont;
var
	theLogFont:TLogFont;
	theDC:HDC;
	theRes:Integer;
begin
	theDC:=GetDC(0);
	theRes:=GetDeviceCaps(theDC,LogPixelsY);
	ReleaseDC(0,theDC);
	with theLogFont do
	begin
		lfHeight:=-Round(Height/72.0*theRes);
		lfWidth:=0;
		lfEscapement:=Angle;
		lfOrientation:=0;
		if fsBold in Style then
			lfWeight:=fw_Bold
		else
			lfWeight:=fw_Normal;
		if fsItalic in Style then
			lfItalic:=1
		else
			lfItalic:=0;
		if fsUnderline in Style then
			lfUnderline:=1
		else
			lfUnderline:=0;
		if fsStrikeOut in Style then
			lfStrikeOut:=1
		else
			lfStrikeOut:=0;
		lfCharSet:=ANSI_CharSet;
		lfOutPrecision:=Out_Default_Precis;
		lfClipPrecision:=Clip_Default_Precis;
		lfQuality:=Proof_Quality;
		case Pitch of
			D:lfPitchAndFamily:=Default_Pitch or ff_DontCare;
			F:lfPitchAndFamily:=Fixed_Pitch or ff_DontCare;
			V:lfPitchAndFamily:=Variable_Pitch or ff_DontCare;
		end;
		StrPCopy(lfFaceName,FaceName);
	end;
	CreateScreenFont:=CreateFontIndirect(theLogFont);
end;

{__________________________________________________________________________
Printing functions																												  }

function SetUpPrinting(ThePrintDialog:TPrintDialog;LeftMargin,RightMargin,TopMargin,BottomMargin:Extended;var Origin,Extent:TPoint):Boolean;
var
	returnValue:Boolean;
	res,pageSize,offset:TPoint;
	left,right,top,bottom:Extended;
	theHandle:HDC;
begin
	returnValue:=ThePrintDialog.Execute;
	if returnValue then
	begin
		theHandle:=Printer.Handle;
		res.x:=GetDeviceCaps(theHandle,LogPixelsX);
		res.y:=GetDeviceCaps(theHandle,LogPixelsY);
		pageSize.x:=GetDeviceCaps(theHandle,PhysicalWidth);
		pageSize.y:=GetDeviceCaps(theHandle,PhysicalHeight);
		offset.x:=GetDeviceCaps(theHandle,PhysicalOffsetX);
		offset.y:=GetDeviceCaps(theHandle,PhysicalOffsetY);
		PrinterResolution:=res.y;
		left:=res.x/25.4*LeftMargin;
		if left>pageSize.x-offset.x then
			left:=pageSize.x-2*offset.x;
		right:=res.x/25.4*RightMargin;
		if right>pageSize.x-offset.x-left then
			right:=pageSize.x-2*offset.x-left;
		top:=res.y/25.4*TopMargin;
		if top>pageSize.y-offset.y then
			top:=pageSize.y-2*offset.y;
		bottom:=res.y/25.4*BottomMargin;
		if bottom>pageSize.y-offset.y-top then
			bottom:=pageSize.y-2*offset.y-top;
		Origin.x:=Round(left)-offset.x;
		Origin.y:=Round(top)-offset.y;
		Extent.x:=Round(pageSize.x-right)-offSet.x;
		Extent.y:=Round(pageSize.y-bottom)-offset.y;
	end;
	SetUpPrinting:=returnValue;
end;

{.......................................................}

function NeedToPrintPage(ThePagesToPrint:TPagesToPrintRec;PageNum:Integer):Boolean;
begin
	with ThePagesToPrint do
		if PrintRange=prAllPages then
			NeedToPrintPage:=True
		else
			if (FromPage<=PageNum) and (ToPage>=PageNum) then
				NeedToPrintPage:=True
			else
				NeedToPrintPage:=False;
end;

{____________________________________________________________________________________________
End of Unit																		        														    			 }

end.
