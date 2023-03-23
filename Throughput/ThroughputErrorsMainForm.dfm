object TEMainForm: TTEMainForm
  Left = 0
  Top = 0
  Caption = 'Throughput errors'
  ClientHeight = 534
  ClientWidth = 980
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Label1: TLabel
    Left = 52
    Top = 57
    Width = 10
    Height = 15
    Caption = #952'i'
  end
  object Label2: TLabel
    Left = 50
    Top = 88
    Width = 12
    Height = 15
    Caption = #1060'i'
  end
  object Label3: TLabel
    Left = 399
    Top = 57
    Width = 9
    Height = 15
    Caption = 'w'
  end
  object Label4: TLabel
    Left = 401
    Top = 88
    Width = 7
    Height = 15
    Caption = 'n'
  end
  object Label5: TLabel
    Left = 402
    Top = 120
    Width = 6
    Height = 15
    Caption = 'k'
  end
  object Label6: TLabel
    Left = 390
    Top = 152
    Width = 18
    Height = 15
    Caption = 'rho'
  end
  object Label7: TLabel
    Left = 48
    Top = 120
    Width = 14
    Height = 15
    Caption = #952'd'
  end
  object Label8: TLabel
    Left = 46
    Top = 152
    Width = 16
    Height = 15
    Caption = #1060'd'
  end
  object Label9: TLabel
    Left = 186
    Top = 57
    Width = 65
    Height = 15
    Caption = 'Beam radius'
  end
  object Label10: TLabel
    Left = 171
    Top = 88
    Width = 80
    Height = 15
    Caption = 'Detector radius'
  end
  object Label11: TLabel
    Left = 245
    Top = 120
    Width = 6
    Height = 15
    Caption = 'L'
  end
  object Label12: TLabel
    Left = 146
    Top = 53
    Width = 5
    Height = 15
    Caption = #176
  end
  object Label13: TLabel
    Left = 146
    Top = 84
    Width = 5
    Height = 15
    Caption = #176
  end
  object Label14: TLabel
    Left = 146
    Top = 116
    Width = 5
    Height = 15
    Caption = #176
  end
  object Label15: TLabel
    Left = 146
    Top = 148
    Width = 5
    Height = 15
    Caption = #176
  end
  object Label16: TLabel
    Left = 342
    Top = 57
    Width = 22
    Height = 15
    Caption = 'mm'
  end
  object Label17: TLabel
    Left = 342
    Top = 88
    Width = 22
    Height = 15
    Caption = 'mm'
  end
  object Label18: TLabel
    Left = 342
    Top = 120
    Width = 22
    Height = 15
    Caption = 'mm'
  end
  object ThetaIEdit: TEdit
    Left = 74
    Top = 53
    Width = 70
    Height = 23
    TabOrder = 0
    Text = '0'
  end
  object PhiIEdit: TEdit
    Left = 74
    Top = 84
    Width = 70
    Height = 23
    TabOrder = 1
    Text = '0'
  end
  object wEdit: TEdit
    Left = 422
    Top = 53
    Width = 70
    Height = 23
    TabOrder = 7
    Text = '0.0105'
  end
  object nEdit: TEdit
    Left = 422
    Top = 84
    Width = 70
    Height = 23
    TabOrder = 8
    Text = '1.5'
  end
  object kEdit: TEdit
    Left = 422
    Top = 116
    Width = 70
    Height = 23
    TabOrder = 9
    Text = '0'
  end
  object RhoEdit: TEdit
    Left = 422
    Top = 148
    Width = 70
    Height = 23
    TabOrder = 10
    Text = '0.85'
  end
  object CalculateButton: TButton
    Left = 422
    Top = 197
    Width = 70
    Height = 25
    Caption = 'Calculate'
    TabOrder = 11
    OnClick = CalculateButtonClick
  end
  object ThetaDEdit: TEdit
    Left = 74
    Top = 116
    Width = 70
    Height = 23
    TabOrder = 2
    Text = '45'
  end
  object PhiDEdit: TEdit
    Left = 74
    Top = 148
    Width = 70
    Height = 23
    TabOrder = 3
    Text = '0'
  end
  object BeamRadiusEdit: TEdit
    Left = 266
    Top = 53
    Width = 70
    Height = 23
    TabOrder = 4
    Text = '7.5'
  end
  object DetRadiusEdit: TEdit
    Left = 266
    Top = 84
    Width = 70
    Height = 23
    TabOrder = 5
    Text = '15'
  end
  object LEdit: TEdit
    Left = 266
    Top = 116
    Width = 70
    Height = 23
    TabOrder = 6
    Text = '500'
  end
  object GroupBox1: TGroupBox
    Left = 52
    Top = 206
    Width = 312
    Height = 117
    Caption = 'Results'
    TabOrder = 12
    object Label19: TLabel
      Left = 51
      Top = 26
      Width = 70
      Height = 15
      Caption = 'BRDF error, s:'
    end
    object Label20: TLabel
      Left = 49
      Top = 52
      Width = 72
      Height = 15
      Caption = 'BRDF error, p:'
    end
    object Label21: TLabel
      Left = 16
      Top = 78
      Width = 105
      Height = 15
      Caption = 'Average BRDF error:'
    end
    object sResultsLabel: TLabel
      Left = 162
      Top = 26
      Width = 3
      Height = 15
    end
    object pResultsLabel: TLabel
      Left = 162
      Top = 52
      Width = 3
      Height = 15
    end
    object avgResultsLabel: TLabel
      Left = 162
      Top = 78
      Width = 3
      Height = 15
    end
  end
  object brdfChart: TChart
    Left = 548
    Top = 53
    Width = 400
    Height = 388
    PrintProportional = False
    Title.Text.Strings = (
      'BRDF values')
    BottomAxis.Title.Caption = 'Theta d (degrees)'
    LeftAxis.Automatic = False
    LeftAxis.AutomaticMaximum = False
    LeftAxis.AutomaticMinimum = False
    LeftAxis.Maximum = 1.000000000000000000
    LeftAxis.Minimum = 0.400000000000000000
    LeftAxis.Title.Caption = 'BRDF'
    View3D = False
    BevelOuter = bvNone
    TabOrder = 13
    DefaultCanvas = 'TGDIPlusCanvas'
    PrintMargins = (
      13
      5
      12
      5)
    ColorPaletteIndex = 13
    object Series1: TLineSeries
      HoverElement = [heCurrent]
      Legend.Text = 's pol'
      LegendTitle = 's pol'
      Brush.BackColor = clDefault
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
      Data = {
        011F000000000000000000000083C0CAA1453A62409A9999999999E93F676666
        66464D64409A9999999999F93F67666666268663403433333333330340676666
        66268663409A999999999909409A999999197564400000000000001040676666
        66C656654033333333333313403433333393FF66406666666666661640010000
        0060A868409999999999991940CECCCCCCECD56A40CCCCCCCCCCCC1C40010000
        00C0106D40FFFFFFFFFFFF1F4001000000009F6E4099999999999921409B9999
        9979166F4033333333333323409B999999B9916E40CDCCCCCCCCCC24409B9999
        99D9456D4067666666666626406866666666606D4001000000000028409B9999
        9919D46E409B9999999999294035333333B3FF6D403533333333332B409B9999
        99D9586F40CFCCCCCCCCCC2C40CECCCCCC0CC36F406966666666662E40343333
        33F38D6F4001000000000030406766666666736F40CECCCCCCCCCC3040343333
        3313426E409B9999999999314067666666A6DB6C4068666666666632409A9999
        99B96B6A403533333333333340CDCCCCCCAC4769400200000000003440676666
        66663A6940CFCCCCCCCCCC34400100000040F469409C99999999993540343333
        33D38D68406966666666663640CECCCCCC0C8A69403633333333333740010000
        0040076C400300000000003840CECCCCCC2C646C40}
      Detail = {0000000000}
    end
    object Series2: TLineSeries
      HoverElement = [heCurrent]
      Legend.Text = 'p pol'
      LegendTitle = 'p pol'
      Brush.BackColor = clDefault
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
      Data = {
        0019000000CDCCCCCCCCAC22409A9999999979474000000000007C6140CDCCCC
        CCCCE8654034333333333F56400100000000AC5A409C99999999014D40D2CCCC
        CCCC9C3640CECCCCCCCC0854400100000000E85740CDCCCCCCCCE86540676666
        66669654403433333333B7504063666666663631406766666666D25140FEFFFF
        FFFF0F3A4002000000003032400000000000AC5A409A99999999B15540353333
        3333D33840000000000060524066666666663631403333333333CB4A40333333
        33333F56406666666666A65F40}
      Detail = {0000000000}
    end
  end
  object PlotBRDFButton: TButton
    Left = 422
    Top = 232
    Width = 70
    Height = 25
    Caption = 'Plot BRDF'
    TabOrder = 14
    OnClick = PlotBRDFButtonClick
  end
  object SaveResultsCheckBox: TCheckBox
    Left = 266
    Top = 151
    Width = 97
    Height = 17
    Caption = 'Save results'
    Checked = True
    State = cbChecked
    TabOrder = 15
  end
  object GroupBox2: TGroupBox
    Left = 50
    Top = 348
    Width = 155
    Height = 141
    Caption = 'Iterate '#952'd'
    TabOrder = 16
    object Label22: TLabel
      Left = 18
      Top = 51
      Width = 24
      Height = 15
      Caption = 'Start'
    end
    object Label23: TLabel
      Left = 18
      Top = 80
      Width = 24
      Height = 15
      Caption = 'Stop'
    end
    object Label24: TLabel
      Left = 18
      Top = 110
      Width = 23
      Height = 15
      Caption = 'Step'
    end
    object Label25: TLabel
      Left = 106
      Top = 45
      Width = 5
      Height = 15
      Caption = #176
    end
    object Label26: TLabel
      Left = 106
      Top = 73
      Width = 5
      Height = 15
      Caption = #176
    end
    object Label27: TLabel
      Left = 106
      Top = 101
      Width = 5
      Height = 15
      Caption = #176
    end
    object StartAngleEdit: TEdit
      Left = 53
      Top = 47
      Width = 50
      Height = 23
      TabOrder = 0
      Text = '5'
    end
    object StopAngleEdit: TEdit
      Left = 53
      Top = 76
      Width = 50
      Height = 23
      TabOrder = 1
      Text = '50'
    end
    object StepAngleEdit: TEdit
      Left = 53
      Top = 105
      Width = 50
      Height = 23
      TabOrder = 2
      Text = '5'
    end
    object IterateAnglesCheckBox: TCheckBox
      Left = 18
      Top = 22
      Width = 137
      Height = 17
      Caption = 'Iterate through '#952'd '
      TabOrder = 3
      OnClick = IterateAnglesCheckBoxClick
    end
  end
  object OpenDialog: TOpenDialog
    DefaultExt = '*.txt'
    InitialDir = 
      'G:\Shared drives\MSL - Photometry & Radiometry\STANDARDS\GonioSp' +
      'ectrometry\Throughput\Output data from Delphi'
    Left = 894
    Top = 369
  end
  object OpenResultFileDialog: TOpenDialog
    InitialDir = 
      'G:\Shared drives\MSL - Photometry & Radiometry\STANDARDS\GonioSp' +
      'ectrometry\Throughput\Output data from Delphi\Microfacet model'
    Left = 894
    Top = 410
  end
end
