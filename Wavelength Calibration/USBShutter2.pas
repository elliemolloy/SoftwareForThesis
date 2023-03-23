unit USBShutter2;

interface

Uses Dialogs, UtilUnit, SysUtils, Controls, CPort;

type
	TShutterState=(Error,Open,Closed);

{function InitialiseBenthamShutter:Boolean;
procedure CloseBenthamShutterDriver;
function OpenBenthamShutter:Boolean;
function CloseBenthamShutter: Boolean;
function GetBenthamShutterState:TShutterState; }

var
	ShutterComPort:Integer;
	ShutterConnected,ShutterClosed:Boolean;

implementation

uses
	SplashScreen,MainForm,Banner;
	
var
	RS232Port:TComPort;

(*function InitialiseBenthamShutter:Boolean;
var
	S:string;
	successful:Boolean;
begin
	successful:=True;
	RS232Port:=TComPort.Create(frmMain);
	with RS232Port do
	begin
		Port:='COM'+IntToStr(ShutterComPort);
		try
			Open;
			BaudRate:=br57600;
			DataBits:=dbEight;
			Parity.Bits:=prNone;
			StopBits:=sbOneStopBit;
			CloseBenthamShutter;
		except
			on EComPort do
			begin
				successful:=False;
				S:='Unable to open '+Port+'. The port is either absent or in use.';
				ShowMessage('Error connecting to USB Shutter ('+S+'). Dark readings will need to be manual.');
			end;
		end;
	end;
	InitialiseBenthamShutter:=successful;
end;

procedure CloseBenthamShutterDriver;
begin
	RS232Port.Free;
end;

function OpenBenthamShutter:Boolean;
begin
	if ShutterConnected then
	begin
		if WriteToLogFile then
		try
			Writeln(LogFile,DateTimeToMyStr(Now),',Opening shutter')
		except
		end;
		RS232Port.WriteStr('1');
		WaitATic(200);
		ShutterClosed:=False;
	end;
end;

function CloseBenthamShutter: Boolean;
var
	S:string;
begin
	if ShutterConnected then
	begin
		if WriteToLogFile then
		try
			Writeln(LogFile,DateTimeToMyStr(Now),',Closing shutter')
		except
		end;
		RS232Port.WriteStr('0');
		WaitATic(200);
		ShutterClosed:=True;
	end;
end;

function GetBenthamShutterState:TShutterState;
var
	S:string;
	state:TShutterState;
begin
	if ShutterConnected then
	begin
		RS232Port.ClearBuffer(True,True);
		RS232Port.WriteStr('s');
		WaitATic(200);
		RS232Port.ClearBuffer(True,False);
		RS232Port.ReadStr(S,255);
		if Pos('Open',S)<>0 then
			state:=Open
		else
			if Pos('Closed',S)<>0 then
				state:=Closed
			else
				state:=Error;
		if WriteToLogFile then
		try
			case state of
				Open:Writeln(LogFile,DateTimeToMyStr(Now),',Shutter open');
				Closed:Writeln(LogFile,DateTimeToMyStr(Now),',Shutter closed');
				Error:Writeln(LogFile,DateTimeToMyStr(Now),',Shutter error');
			end;
		except
		end;
	end
	else
		state:=Error;
	GetBenthamShutterState:=state;
end;*)

end.
