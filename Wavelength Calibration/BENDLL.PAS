{$F+}
(*------------------------------------------------------------------------------

		bendll.pas - import unit for use with the Bentham Instruments
                spectroradiometer control DLL.

		Copyright (c) 2004 - 06 by Bentham Instruments Ltd
		All Rights Reserved

------------------------------------------------------------------------------*)
unit bendll;

{------------------------------------------------------------------------------}
interface
{------------------------------------------------------------------------------}
{$I dlltoken.pas}
{$I dllerror.pas}

{------------------------------------------------------------------------------}
function	BI_build_system_model( config_file : PChar; error : PChar ) : integer;

function	BI_get(	id : PChar;
			token	: integer;
			index	: integer;
			var value : double ) : integer;

function	BI_set(	id : PChar;
			token	: integer;
			index	: integer;
			value	: double ) : integer;

function	BI_save_setup(	filename : PChar ) : integer;

function	BI_load_setup(	filename : PChar ) : integer;


function	BI_build_group : integer;

function	BI_group_add( id : PChar; n : integer ) : integer;

function	BI_group_remove( id : PChar; n 	: integer ) : integer;

function	BI_use_group( n	: integer ) : integer;

function	BI_get_group( n	: integer; s : PChar ) : integer;

function	BI_initialise : integer;

function	BI_close_shutter : integer;

function	BI_park : integer;

function	BI_zero_calibration( start_wavelength : double; stop_wavelength : double ) : integer;

function        BI_select_wavelength( wavelength : double; var settle_delay : longint ) : integer;

function	BI_autorange : integer;

function        BI_automeasure( var reading: double ): integer;

function	BI_measurement(	var reading: double ): integer;

function	BI_send( msg : Pchar; id: Pchar ): integer;

function        BI_read(buffer: Pchar;
		        buffer_size: word;
		        var chars_read: word;
		        id: Pchar ): integer;

function        BI_component_select_wl( id: PChar;
				        wl: double;
                                        var settle: longint ): integer;

function        BI_get_no_of_dark_currents(var NoOfValues : integer) : integer ;

function        BI_get_zero_calibration_info( Wavelength : pdouble ;
                                         DarkCurrent :pdouble ;
                                         ADCOffset : pdouble ) :integer ;

function        BI_get_mono_items( monoID  :Pchar; ItemIDs  :Pchar) : integer ;

function	BI_report_error : integer;

procedure	BI_version(s: Pchar );

function        BI_multi_initialise : integer;

function        BI_multi_zero_calibration(start_wavelength: double;
                                         stop_wavelength : double ) : integer;

function        BI_multi_autorange : integer;

function        BI_multi_select_wavelength( wavelength : double;
                                        var settle_delay: longint ) : integer;

function        BI_multi_measurement(reading : pdouble ) : integer;

function        BI_multi_get_no_of_dark_currents(Group : integer;
                                            var NoOfValues : integer) : integer ;

function        BI_multi_get_zero_calibration_info(Group : integer;
                                             Wavelength : pdouble ;
                                             DarkCurrent : pdouble ;
                                             ADCOffset : pdouble) : integer ;

function 	BI_get_hardware_type ( id : pchar ; hardware_type : pinteger ) : integer;

function        BI_Close : integer;

procedure       BI_trace(i: integer );

function	BI_get_c_group(var n: integer ) : integer;
function	BI_get_component_list(list:pchar):integer; 

{------------------------------------------------------------------------------}
implementation
{------------------------------------------------------------------------------}
const
	DLL_NAME	= 'benhw32_fastcall.dll';

function	BI_build_system_model;
external DLL_NAME name 'BI_build_system_model';

function	BI_get;
external DLL_NAME name 'BI_get';

function	BI_set;
external DLL_NAME name 'BI_set';

function	BI_initialise;
external DLL_NAME name 'BI_initialise';

function	BI_build_group;
external DLL_NAME name 'BI_build_group';

function	BI_group_add;
external DLL_NAME name 'BI_group_add';

function	BI_group_remove;
external DLL_NAME name 'BI_group_remove';

function	BI_use_group;
external DLL_NAME name 'BI_use_group';

function	BI_get_group;
external DLL_NAME name 'BI_get_group';

function	BI_save_setup;
external DLL_NAME name 'BI_save_setup';

function	BI_load_setup;
external DLL_NAME name 'BI_load_setup';

function  BI_close_shutter;
external DLL_NAME name 'BI_close_shutter';

function	BI_park;
external DLL_NAME name 'BI_park';

function	BI_zero_calibration;
external DLL_NAME name 'BI_zero_calibration';

function  BI_select_wavelength;
external DLL_NAME name 'BI_select_wavelength';

function	BI_autorange;
external DLL_NAME name 'BI_autorange';

function        BI_automeasure;
external DLL_NAME name 'BI_automeasure';

function	BI_measurement;
external DLL_NAME name 'BI_measurement';

function	BI_send;
external DLL_NAME name 'BI_send';

function	BI_component_select_wl;
external DLL_NAME name 'BI_component_select_wl';

function        BI_get_no_of_dark_currents;
external DLL_NAME name 'BI_get_no_of_dark_currents';

function        BI_get_zero_calibration_info;
external DLL_NAME name 'BI_get_zero_calibration_info';

function BI_get_mono_items;
external DLL_NAME name 'BI_get_mono_items';

function	BI_read;
external DLL_NAME name 'BI_read';

function	BI_report_error;
external DLL_NAME name 'BI_report_error';

procedure	BI_version;
external DLL_NAME name 'BI_version';

function        BI_multi_initialise;
external DLL_NAME name 'BI_multi_initialise';

function        BI_multi_zero_calibration;
external DLL_NAME name 'BI_multi_zero_calibration';

function	BI_multi_autorange;
external DLL_NAME name 'BI_multi_autorange';

function        BI_multi_select_wavelength;
external DLL_NAME name 'BI_multi_select_wavelength';

function	BI_multi_measurement;
external DLL_NAME name 'BI_multi_measurement';

function        BI_multi_get_no_of_dark_currents;
external DLL_NAME name 'BI_multi_get_no_of_dark_currents';

function        BI_multi_get_zero_calibration_info;
external DLL_NAME name 'BI_multi_get_zero_calibration_info';

function 	BI_get_hardware_type;
external DLL_NAME  name 'BI_get_hardware_type';

function	BI_Close;
external DLL_NAME name 'BI_close';

procedure	BI_trace;
external DLL_NAME name 'BI_trace';

function	BI_get_c_group;
external DLL_NAME name 'BI_get_c_group';

function	BI_get_component_list;
external DLL_NAME name 'BI_get_component_list';

{------------------------------------------------------------------------------}
end.
