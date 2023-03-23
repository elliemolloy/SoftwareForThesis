object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 360
  ClientWidth = 643
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 13
  object Label1: TLabel
    Left = 188
    Top = 24
    Width = 58
    Height = 13
    Caption = 'Beam radius'
  end
  object Label2: TLabel
    Left = 176
    Top = 57
    Width = 74
    Height = 13
    Caption = 'Detector radius'
  end
  object Label3: TLabel
    Left = 36
    Top = 24
    Width = 8
    Height = 13
    Caption = #952'i'
  end
  object Label4: TLabel
    Left = 332
    Top = 24
    Width = 16
    Height = 13
    Caption = 'mm'
  end
  object Label5: TLabel
    Left = 332
    Top = 57
    Width = 16
    Height = 13
    Caption = 'mm'
  end
  object Label6: TLabel
    Left = 128
    Top = 20
    Width = 5
    Height = 13
    Caption = #176
  end
  object Label11: TLabel
    Left = 217
    Top = 90
    Width = 33
    Height = 13
    Caption = 'Length'
  end
  object Label12: TLabel
    Left = 332
    Top = 90
    Width = 16
    Height = 13
    Caption = 'mm'
  end
  object Label13: TLabel
    Left = 172
    Top = 123
    Width = 74
    Height = 13
    Caption = 'Number of rays'
  end
  object Label17: TLabel
    Left = 34
    Top = 57
    Width = 10
    Height = 13
    Caption = #1060'i'
  end
  object Label19: TLabel
    Left = 128
    Top = 53
    Width = 5
    Height = 13
    Caption = #176
  end
  object Label18: TLabel
    Left = 32
    Top = 90
    Width = 12
    Height = 13
    Caption = #952'd'
  end
  object Label20: TLabel
    Left = 128
    Top = 86
    Width = 5
    Height = 13
    Caption = #176
  end
  object Label21: TLabel
    Left = 30
    Top = 123
    Width = 14
    Height = 13
    Caption = #1060'd'
  end
  object Label16: TLabel
    Left = 128
    Top = 119
    Width = 5
    Height = 13
    Caption = #176
  end
  object BeamRadiusEdit: TEdit
    Left = 256
    Top = 20
    Width = 70
    Height = 21
    TabOrder = 4
    Text = '10'
  end
  object DetRadiusEdit: TEdit
    Left = 256
    Top = 53
    Width = 70
    Height = 21
    TabOrder = 5
    Text = '15'
  end
  object ThetaDEdit: TEdit
    Left = 52
    Top = 83
    Width = 70
    Height = 21
    TabOrder = 2
    Text = '45'
  end
  object CalculateButton: TButton
    Left = 384
    Top = 51
    Width = 75
    Height = 25
    Caption = 'Calculate'
    TabOrder = 8
    OnClick = CalculateButtonClick
  end
  object LengthEdit: TEdit
    Left = 256
    Top = 86
    Width = 70
    Height = 21
    TabOrder = 6
    Text = '500'
  end
  object NEdit: TEdit
    Left = 256
    Top = 119
    Width = 70
    Height = 21
    TabOrder = 7
    Text = '100000000'
  end
  object SaveFileCheckBox: TCheckBox
    Left = 384
    Top = 19
    Width = 80
    Height = 17
    Caption = 'Save results'
    Checked = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    State = cbChecked
    TabOrder = 9
  end
  object GroupBox1: TGroupBox
    Left = 15
    Top = 166
    Width = 236
    Height = 135
    Caption = 'Adjust '#952'd'
    TabOrder = 10
    object Label7: TLabel
      Left = 44
      Top = 51
      Width = 28
      Height = 13
      Caption = 'Start:'
    end
    object Label8: TLabel
      Left = 46
      Top = 76
      Width = 26
      Height = 13
      Caption = 'Stop:'
    end
    object Label9: TLabel
      Left = 46
      Top = 102
      Width = 26
      Height = 13
      Caption = 'Step:'
    end
    object Label10: TLabel
      Left = 162
      Top = 47
      Width = 5
      Height = 13
      Caption = #176
    end
    object Label14: TLabel
      Left = 162
      Top = 73
      Width = 5
      Height = 13
      Caption = #176
    end
    object Label15: TLabel
      Left = 162
      Top = 100
      Width = 5
      Height = 13
      Caption = #176
    end
    object IterateAnglesCheckbox: TCheckBox
      Left = 32
      Top = 22
      Width = 141
      Height = 17
      Caption = 'Iterate through '#952'd'
      TabOrder = 0
      OnClick = IterateAnglesCheckboxClick
    end
    object StartAngleEdit: TEdit
      Left = 86
      Top = 47
      Width = 70
      Height = 21
      TabOrder = 1
      Text = '5'
    end
    object StopAngleEdit: TEdit
      Left = 86
      Top = 72
      Width = 70
      Height = 21
      TabOrder = 2
      Text = '50'
    end
    object StepAngleEdit: TEdit
      Left = 86
      Top = 98
      Width = 70
      Height = 21
      TabOrder = 3
      Text = '5'
    end
  end
  object ThetaIEdit: TEdit
    Left = 52
    Top = 20
    Width = 70
    Height = 21
    TabOrder = 0
    Text = '0'
  end
  object PhiIEdit: TEdit
    Left = 52
    Top = 53
    Width = 70
    Height = 21
    TabOrder = 1
    Text = '0'
  end
  object PhiDEdit: TEdit
    Left = 52
    Top = 119
    Width = 70
    Height = 21
    TabOrder = 3
    Text = '0'
  end
  object StopButton: TButton
    Left = 384
    Top = 84
    Width = 75
    Height = 25
    Caption = 'Stop'
    TabOrder = 11
    OnClick = StopButtonClick
  end
  object SaveTdFileDialog: TSaveDialog
    DefaultExt = 'txt'
    Filter = '*.txt'
    InitialDir = 
      'G:\Shared drives\MSL - Photometry & Radiometry\STANDARDS\GonioSp' +
      'ectrometry\Throughput\Output data from Delphi'
    Left = 374
    Top = 211
  end
end
