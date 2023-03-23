unit BenthamUnit;

interface

uses
	SysUtils, UtilUnit, Dialogs, Windows;

function InitialiseBentham : Boolean;
procedure SetBenthamWavelength (ThisW : Double);
function GetBenthamWavelength : Double;

var DialReading, FilterPos : Double;
    CurrentWavelength : Double;
    BenthamName,BenthamCFGFile,BenthamATRFile : String;

implementation

uses
	Main, bendll, DialReadingForm;

Function ParkTheMono : Integer;
var i : integer;
    v : double;
    s, items, itemname, mono_items, mono_item_name, fwheel_name : string;
    DialForm : TDialReadingFrm;
begin
	Try
    items := StringOfChar(' ',255);
    BI_get_component_list(PChar(items));
    itemname := copy(items,0,pos(',',items)-1);
    while itemname <> '' do
      begin
        BI_get_hardware_type(PChar(itemname),@i);
        if i = BenMono then
          begin
            BenthamName := itemname;
            BI_Get(PChar(itemname),MonochromatorSelfPark,0,v);

            if v = 0 then
              begin
                // Ask for dial reading etc
                DialForm := TDialReadingFrm.create(Nil);
                DialForm.ShowModal;
                DialForm.Free;
  //              DialForm := nil;

                mono_items := StringOfChar(' ',255);
                BI_get_mono_items(Pchar(itemname),PChar(mono_items));
                //showmessage(mono_items);

                mono_item_name := copy(mono_items,0,pos(',',mono_items)-1);
                while mono_item_name <> '' do
                  begin
                    BI_get_hardware_type(PChar(mono_item_name),@i);
                    if i = BenFilterWheel then
                      begin
                        fwheel_name := mono_item_name;
                      end;

                    mono_items := copy(mono_items,pos(',',mono_items)+1,length(mono_items));
                    mono_item_name := copy(mono_items,0,pos(',',mono_items)-1);
                  end;

                BI_Set(PChar(itemname),MonochromatorCurrentDialReading,0,DialReading);

                if fwheel_name <> '' then
                  BI_Set(PChar('fwheel'),FWheelCurrentPosition,0,FilterPos);
              end;
          end;

        items := copy(items,pos(',',items)+1,length(items));
        itemname := copy(items,0,pos(',',items)-1);
      end;

    setLength(s,100);
    Result := BI_park;
	Except
		Result := -1;
    Exit;
	End;
end;

Function InitialiseBentham : Boolean;
var bResult : Integer;
    FileStr, ErrorStr : String;
begin
	Result := False;
	BenthamCFGFile := 'system.cfg';
	BenthamATRFile := 'system.atr';
	Try
    if not FileExists (BenthamCFGFile) then
			begin
				ShowMessage ('ERROR : Bentham Config File not found');
        Exit;
			end;
		if not FileExists (BenthamATRFile) then
			begin
        ShowMessage ('ERROR : Bentham Attribute File not found');
        Exit;
      end;

    FileStr := BenthamCFGFile;
    bResult := BI_build_system_model (Addr (FileStr[1]), Addr(ErrorStr[1]));
    if bResult <> 0 then
			begin
        ShowMessage ('Error building system model');
        Exit;
			end;

    FileStr := BenthamATRFile;
    bResult := BI_load_setup (Addr (FileStr[1]));
    if bResult <> 0 then
			begin
        ShowMessage ('Error loading system attributes');
        Exit;
			end;

		bResult := BI_initialise;
    if bResult <> 0 then
			begin
        ShowMessage ('Error initialising system');
        Exit;
			end;

    bResult := ParkTheMono;
    if bResult <> 0 then
			begin
        ShowMessage ('Error parking monochromator');
        Exit;
      end;
	Except
    ShowMessage ('An unexpected error occurred while initialising the Bentham system');
    Exit;
	End;
  Result := True;
end;

Procedure SetBenthamWavelength (ThisW : Double);
var Settle_delay : integer;
begin
	CurrentWavelength := ThisW;
	BI_select_wavelength(ThisW,settle_delay);
end;

Function GetBenthamWavelength : Double;
var v : double;
begin
  Try
    BI_Get(PChar(BenthamName),MonochromatorCurrentWL,0,v);
    Result := v;
  Except
    Result := CurrentWavelength;
  End;
end;

end.
