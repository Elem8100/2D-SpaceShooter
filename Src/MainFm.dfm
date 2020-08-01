object MainForm: TMainForm
  Left = 289
  Top = 111
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'SpaceShooter'
  ClientHeight = 768
  ClientWidth = 1024
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Pitch = fpVariable
  Font.Style = []
  Font.Quality = fqDraft
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  PixelsPerInch = 120
  TextHeight = 21
end
