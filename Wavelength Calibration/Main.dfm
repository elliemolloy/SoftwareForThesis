object MainForm: TMainForm
  Left = 676
  Top = 368
  Width = 800
  Height = 559
  Caption = 'Wavelength Calibration'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 361
    Height = 479
    Align = alLeft
    TabOrder = 0
    object MonochromatorGroupBox: TGroupBox
      Left = 24
      Top = 20
      Width = 201
      Height = 117
      Caption = 'Bentham Monochromator'
      TabOrder = 0
      object Label1: TLabel
        Left = 10
        Top = 20
        Width = 118
        Height = 13
        Caption = 'Current wavelength (nm):'
      end
      object WavelengthLabel: TLabel
        Left = 136
        Top = 20
        Width = 5
        Height = 13
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label2: TLabel
        Left = 10
        Top = 40
        Width = 42
        Height = 13
        Caption = 'Move to:'
      end
      object UnitLabel2: TLabel
        Left = 142
        Top = 40
        Width = 14
        Height = 13
        Caption = 'nm'
      end
      object MonochromatorButton: TButton
        Left = 58
        Top = 66
        Width = 85
        Height = 25
        Caption = 'Set Wavelength'
        TabOrder = 0
        OnClick = MonochromatorButtonClick
      end
      object WavelengthEdit: TEdit
        Left = 74
        Top = 36
        Width = 60
        Height = 21
        TabOrder = 1
      end
    end
    object LSAGroupBox: TGroupBox
      Left = 24
      Top = 150
      Width = 229
      Height = 111
      Caption = 'Laser Spectrum Analyser'
      TabOrder = 1
      object Label3: TLabel
        Left = 20
        Top = 66
        Width = 95
        Height = 13
        Caption = 'Current wavelength:'
      end
      object LSAWavelengthLabel: TLabel
        Left = 122
        Top = 66
        Width = 5
        Height = 13
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object UnitLabel3: TLabel
        Left = 170
        Top = 66
        Width = 14
        Height = 13
        Caption = 'nm'
      end
      object GetWavelengthButton: TButton
        Left = 20
        Top = 28
        Width = 90
        Height = 25
        Caption = 'Get Wavelength'
        TabOrder = 0
        OnClick = GetWavelengthButtonClick
      end
    end
    object WavelengthGroupBox: TGroupBox
      Left = 24
      Top = 270
      Width = 321
      Height = 191
      Caption = 'Bentham Scan'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      object FromWavelengthLabel: TLabel
        Left = 8
        Top = 32
        Width = 27
        Height = 14
        Caption = 'From:'
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object Label4: TLabel
        Left = 107
        Top = 32
        Width = 14
        Height = 14
        Caption = 'nm'
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object ToWavelengthLabel: TLabel
        Left = 8
        Top = 58
        Width = 14
        Height = 14
        Caption = 'To:'
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object UnitLabel4: TLabel
        Left = 107
        Top = 58
        Width = 14
        Height = 14
        Caption = 'nm'
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object StepWavelengthLabel: TLabel
        Left = 8
        Top = 84
        Width = 25
        Height = 14
        Caption = 'Step:'
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object UnitLabel5: TLabel
        Left = 107
        Top = 84
        Width = 14
        Height = 14
        Caption = 'nm'
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object Label5: TLabel
        Left = 170
        Top = 58
        Width = 43
        Height = 14
        Caption = 'Repeats:'
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object Label6: TLabel
        Left = 170
        Top = 84
        Width = 51
        Height = 14
        Caption = 'Threshold:'
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object UnitLabel7: TLabel
        Left = 283
        Top = 84
        Width = 10
        Height = 14
        Caption = '%'
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object Label8: TLabel
        Left = 170
        Top = 32
        Width = 30
        Height = 14
        Caption = 'Delay:'
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object UnitLabel8: TLabel
        Left = 283
        Top = 32
        Width = 14
        Height = 14
        Caption = 'ms'
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object Label7: TLabel
        Left = 124
        Top = 166
        Width = 53
        Height = 14
        Caption = 'Correction:'
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object Label9: TLabel
        Left = 240
        Top = 166
        Width = 18
        Height = 14
        Caption = 'x + '
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object WavelengthFromEdit: TEdit
        Left = 49
        Top = 28
        Width = 50
        Height = 22
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        Text = '200'
      end
      object DoWavelengthScanButton: TBitBtn
        Left = 8
        Top = 108
        Width = 193
        Height = 33
        Caption = 'Do Wavelength Scan'
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        TabOrder = 5
        OnClick = DoWavelengthScanButtonClick
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000120B0000120B00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00337333733373
          3373337F3F7F3F7F3F7F33737373737373733F7F7F7F7F7F7F7F770000000000
          00007777777777777777330333333C333333337FFF3337F3333F370993333C33
          3399377773F337F33377330339333C3339333F7FF7FFF7FFF7FF770777977C77
          97777777777777777777330333933C339333337F3373F7F37333370333393C39
          3333377F333737F7333333033333999333333F7FFFFF777FFFFF770777777C77
          77777777777777777777330333333C333333337F333337F33333370333333C33
          3333377F333337F33333330333333C3333333F7FFFFFF7FFFFFF770777777777
          7777777777777777777733333333333333333333333333333333}
        NumGlyphs = 2
      end
      object WavelengthToEdit: TEdit
        Left = 49
        Top = 54
        Width = 50
        Height = 22
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        Text = '900'
      end
      object WavelengthStepEdit: TEdit
        Left = 49
        Top = 80
        Width = 50
        Height = 22
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        Text = '5'
      end
      object PauseButton: TBitBtn
        Left = 8
        Top = 149
        Width = 90
        Height = 33
        Caption = 'Pause'
        Enabled = False
        TabOrder = 6
        OnClick = PauseButtonClick
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000120B0000120B00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
          3333333333FFFFF3333333333000003333333333F77777FFF333333009999900
          3333333777777777FF33330998FFF899033333777333F3777FF33099FFFCFFF9
          903337773337333777F3309FFFFFFFCF9033377333F3337377FF098FF0FFFFFF
          890377F3373F3333377F09FFFF0FFFFFF90377F3F373FFFFF77F09FCFFF90000
          F90377F733377777377F09FFFFFFFFFFF90377F333333333377F098FFFFFFFFF
          890377FF3F33333F3773309FCFFFFFCF9033377F7333F37377F33099FFFCFFF9
          90333777FF37F3377733330998FCF899033333777FF7FF777333333009999900
          3333333777777777333333333000003333333333377777333333}
        NumGlyphs = 2
      end
      object NumRepeatsEdit: TEdit
        Left = 230
        Top = 55
        Width = 50
        Height = 21
        TabOrder = 3
        Text = '5'
      end
      object ThresholdEdit: TEdit
        Left = 230
        Top = 81
        Width = 50
        Height = 21
        TabOrder = 4
        Text = '10'
      end
      object DelayEdit: TEdit
        Left = 230
        Top = 29
        Width = 50
        Height = 21
        TabOrder = 7
        Text = '5'
      end
      object WavelengthCorrectionEditA: TEdit
        Left = 182
        Top = 163
        Width = 50
        Height = 21
        TabOrder = 8
        Text = '0'
      end
      object WavelengthCorrectionEditB: TEdit
        Left = 264
        Top = 163
        Width = 50
        Height = 21
        TabOrder = 9
        Text = '0'
      end
    end
    object GroupBox1: TGroupBox
      Left = 238
      Top = 20
      Width = 107
      Height = 117
      Caption = 'Monochromator'
      TabOrder = 3
      object BenthamRadioButton: TRadioButton
        Left = 13
        Top = 18
        Width = 80
        Height = 17
        Caption = 'Bentham'
        TabOrder = 0
        OnClick = BenthamRadioButtonClick
      end
      object SpectraProRadioButton: TRadioButton
        Left = 13
        Top = 44
        Width = 80
        Height = 17
        Caption = 'SpectraPro'
        TabOrder = 1
        OnClick = SpectraProRadioButtonClick
      end
    end
    object GroupBox2: TGroupBox
      Left = 265
      Top = 150
      Width = 83
      Height = 99
      Caption = 'Slit Widths'
      TabOrder = 4
      object Label10: TLabel
        Left = 53
        Top = 27
        Width = 14
        Height = 14
        Caption = 'um'
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object SlitWidthEdit: TEdit
        Left = 10
        Top = 24
        Width = 35
        Height = 21
        TabOrder = 0
        Text = 'SlitWidthEdit'
      end
      object SlitWidthButton: TButton
        Left = 18
        Top = 56
        Width = 47
        Height = 25
        Caption = 'Set'
        TabOrder = 1
        OnClick = SlitWidthButtonClick
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 479
    Width = 784
    Height = 41
    Align = alBottom
    TabOrder = 1
    object StatusLabel: TLabel
      Left = 8
      Top = 10
      Width = 287
      Height = 22
      AutoSize = False
      Caption = 'Wavelength Scan'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlue
      Font.Height = -16
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object ProgressBar: TProgressBar
      Left = 324
      Top = 6
      Width = 385
      Height = 29
      Smooth = True
      Step = 1
      TabOrder = 0
    end
  end
  object SpectraProClientSocket: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 0
    OnConnect = SpectraProClientSocketConnect
    OnDisconnect = SpectraProClientSocketDisconnect
    OnRead = SpectraProClientSocketRead
    OnError = SpectraProClientSocketError
    Left = 220
    Top = 228
  end
end
