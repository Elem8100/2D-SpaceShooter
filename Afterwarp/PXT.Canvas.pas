unit PXT.Canvas;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, PXT.Types, PXT.Graphics, PXT.Controls, Vcl.StdCtrls;

type
  TGameCanvas = object(TCanvas)
    procedure Create(Device: TDevice);
    procedure Draw(ATexture: TTexture; X, Y: Single; AEffect: TBlendingEffect = TBlendingEffect.Normal);
      overload;
    procedure Draw(ATexture: TTexture; X, Y: Single; Mirror: Boolean; AEffect: TBlendingEffect =
      TBlendingEffect.Normal); overload;
    procedure DrawScale(ATexture: TTexture; X, Y: Single; ScaleX, ScaleY: Single; AEffect:
      TBlendingEffect = TBlendingEffect.Normal); overload;
    procedure DrawColor1(ATexture: TTexture; X, Y: Single; Mirror: Boolean; const AColors:
      TColorRect; AEffect: TBlendingEffect = TBlendingEffect.Normal); overload;
    procedure DrawColor1(ATexture: TTexture; X, Y, ScaleX, ScaleY: Single; Mirror: Boolean; const
      AColors: TColorRect; AEffect: TBlendingEffect = TBlendingEffect.Normal); overload;
    procedure DrawStretch(ATexture: TTexture; X, Y, Width, Height: Single; Mirror: Boolean; const
      AColors: TColorRect; AEffect: TBlendingEffect = TBlendingEffect.Normal); overload;
    procedure DrawStretch(ATexture: TTexture; X, Y, Width, Height: Single; AEffect: TBlendingEffect
      = TBlendingEffect.Normal); overload;
    procedure DrawPortion(ATexture: TTexture; X, Y, SrcX1, SrcY1, SrcX2, SrcY2: Integer; Mirror:
      Boolean; const AColor: TColorRect; AEffect: TBlendingEffect = TBlendingEffect.Normal);
      overload;
    procedure DrawPattern(ATexture: TTexture; X, Y: Single; PatternIndex, PatternWidth,
      PatternHeight: Integer; Mirror: Boolean; const AColor: TColorRect; AEffect: TBlendingEffect =
      TBlendingEffect.Normal); overload;
    procedure DrawPattern(ATexture: TTexture; X, Y, ScaleX, ScaleY: Single; PatternIndex,
      PatternWidth, PatternHeight: Integer; Mirror: Boolean; const AColor: TColorRect; AEffect:
      TBlendingEffect = TBlendingEffect.Normal); overload;
    procedure DrawPatternRotate(ATexture: TTexture; X, Y, Angle, Scale: Single; PatternIndex,
      PatternWidth, PatternHeight: Integer; Mirror: Boolean; const AColor: TColorRect; AEffect:
      TBlendingEffect = TBlendingEffect.Normal); overload;
    procedure DrawRotateC(ATexture: TTexture; X, Y: Single; const Angle, Scale: Single; const AColor:
      TColorRect; AEffect: TBlendingEffect = TBlendingEffect.Normal); overload;
    procedure DrawRotate(ATexture: TTexture; X, Y, CenterX, CenterY: Single; const Angle, Scale:
      Single; const AColor: TColorRect; AEffect: TBlendingEffect = TBlendingEffect.Normal);
    procedure DrawHue(ATexture: TTexture; Hue: Byte; X, Y: Single; Mirror: Boolean; AEffect:
      TBlendingEffect = TBlendingEffect.Normal);
    procedure DrawSaturation(ATexture: TTexture; Saturation: Byte; X, Y: Single; Mirror: Boolean;
      AEffect: TBlendingEffect = TBlendingEffect.Normal);
    procedure DrawTarget(var ATexture: TTexture; Width, Height: Integer; Proc: TProc);
    procedure DrawTargetStatic(var ATexture: TTexture; Width, Height: Integer; Proc: TProc);
  end;

function GetA(const Color: LongWord): Byte; inline;

function GetR(const Color: LongWord): Byte; inline;

function GetG(const Color: LongWord): Byte; inline;

function GetB(const Color: LongWord): Byte; inline;

function ARGB(const A, R, G, B: Byte): LongWord; inline;

implementation

uses
  GameTypes;

procedure TGameCanvas.Create;
begin
  TCanvas(Self) := CanvasInit(Device);
end;

procedure TGameCanvas.Draw(ATexture: TTexture; X, Y: Single; AEffect: TBlendingEffect =
  TBlendingEffect.Normal);
begin
  Draw(ATexture, X, Y, False, AEffect);
end;

procedure TGameCanvas.Draw(ATexture: TTexture; X, Y: Single; Mirror: Boolean; AEffect:
  TBlendingEffect = TBlendingEffect.Normal);
begin
  var TexCoord: TQuad;
  var Width := ATexture.Parameters.Width;
  var Height := ATexture.Parameters.Height;
  if Mirror then
    TexCoord := QuadUnity.Mirror
  else
    TexCoord := QuadUnity;
  Quad(ATexture, PXT.Types.Quad(X, Y, Width, Height), TexCoord, $FFFFFFFF, AEffect);
end;

procedure TGameCanvas.DrawScale(ATexture: TTexture; X, Y: Single; ScaleX, ScaleY: Single; AEffect:
  TBlendingEffect = TBlendingEffect.Normal);
begin
  var Width := ATexture.Parameters.Width;
  var Height := ATexture.Parameters.Height;
  Quad(ATexture, PXT.Types.Quad(X, Y, Width * ScaleX, Height * ScaleY), QuadUnity, $FFFFFFFF,
    AEffect);
end;

procedure TGameCanvas.DrawColor1(ATexture: TTexture; X, Y: Single; Mirror: Boolean; const AColors:
  TColorRect; AEffect: TBlendingEffect = TBlendingEffect.Normal);
begin
  var TexCoord: TQuad;
  var Width := ATexture.Parameters.Width;
  var Height := ATexture.Parameters.Height;
  if Mirror then
    TexCoord := QuadUnity.Mirror
  else
    TexCoord := QuadUnity;

  Quad(ATexture, PXT.Types.Quad(X, Y, Width, Height), TexCoord, AColors, AEffect);
end;

procedure TGameCanvas.DrawColor1(ATexture: TTexture; X, Y, ScaleX, ScaleY: Single; Mirror: Boolean;
  const AColors: TColorRect; AEffect: TBlendingEffect = TBlendingEffect.Normal);
begin
  var TexCoord: TQuad;
  var Width := ATexture.Parameters.Width;
  var Height := ATexture.Parameters.Height;
  if Mirror then
    TexCoord := QuadUnity.Mirror
  else
    TexCoord := QuadUnity;
  Quad(ATexture, PXT.Types.Quad(X, Y, Width * ScaleX, Height * ScaleY), TexCoord, AColors, AEffect);
end;

procedure TGameCanvas.DrawStretch(ATexture: TTexture; X, Y, Width, Height: Single; Mirror: Boolean;
  const AColors: TColorRect; AEffect: TBlendingEffect = TBlendingEffect.Normal);
begin
  var TexCoord: TQuad;
  if Mirror then
    TexCoord := QuadUnity.Mirror
  else
    TexCoord := QuadUnity;
  Quad(ATexture, PXT.Types.Quad(X, Y, Width, Height), TexCoord, AColors, AEffect);
end;

procedure TGameCanvas.DrawStretch(ATexture: TTexture; X, Y, Width, Height: Single; AEffect:
  TBlendingEffect = TBlendingEffect.Normal);
begin
  DrawStretch(ATexture, X, Y, Width, Height, False, $FFFFFFFF, AEffect);
end;

procedure TGameCanvas.DrawPortion(ATexture: TTexture; X, Y, SrcX1, SrcY1, SrcX2, SrcY2: Integer;
  Mirror: Boolean; const AColor: TColorRect; AEffect: TBlendingEffect = TBlendingEffect.Normal);
begin
  var TexCoord := PXT.Types.Quad(IntRectBDS(SrcX1, SrcY1, SrcX2, SrcY2));
  if Mirror then
    TexCoord := TexCoord.Mirror;
  QuadRegion(ATexture, PXT.Types.Quad(X, Y, SrcX2 - SrcX1, SrcY2 - SrcY1), TexCoord, AColor, AEffect);
end;

function SetPattern(ATexture: TTexture; PatternIndex, PatternWidth, PatternHeight: Integer): TQuad;
begin
  var FTexWidth := ATexture.Parameters.Width;
  var FTexHeight := ATexture.Parameters.Height;
  var ColCount := FTexWidth div PatternWidth;
  var RowCount := FTexHeight div PatternHeight;
  var FPatternIndex := PatternIndex;
  if FPatternIndex < 0 then
    FPatternIndex := 0;
  if FPatternIndex >= RowCount * ColCount then
    FPatternIndex := RowCount * ColCount - 1;
  var Left := (FPatternIndex mod ColCount) * PatternWidth;
  var Right := Left + PatternWidth;
  var Top := (FPatternIndex div ColCount) * PatternHeight;
  var Bottom := Top + PatternHeight;
  var FWidth := Right - Left;
  var FHeight := Bottom - Top;
  var X1 := Left;
  var Y1 := Top;
  var X2 := (Left + FWidth);
  var Y2 := (Top + FHeight);
  Result := PXT.Types.Quad(IntRectBDS(Round(X1), Round(Y1), Round(X2), Round(Y2)));
end;

procedure TGameCanvas.DrawPattern(ATexture: TTexture; X, Y: Single; PatternIndex, PatternWidth,
  PatternHeight: Integer; Mirror: Boolean; const AColor: TColorRect; AEffect: TBlendingEffect =
  TBlendingEffect.Normal);
begin
  var TexCoord := SetPattern(ATexture, PatternIndex, PatternWidth, PatternHeight);
  if Mirror then
    TexCoord := TexCoord.Mirror;
  QuadRegion(ATexture, PXT.Types.Quad(X, Y, PatternWidth, PatternHeight), TexCoord, AColor, AEffect);

end;

procedure TGameCanvas.DrawPattern(ATexture: TTexture; X, Y, ScaleX, ScaleY: Single; PatternIndex,
  PatternWidth, PatternHeight: Integer; Mirror: Boolean; const AColor: TColorRect; AEffect:
  TBlendingEffect = TBlendingEffect.Normal);
begin
  var TexCoord := SetPattern(ATexture, PatternIndex, PatternWidth, PatternHeight);
  if Mirror then
    TexCoord := TexCoord.Mirror;
  QuadRegion(ATexture, PXT.Types.Quad(X, Y, PatternWidth * ScaleX, PatternHeight * ScaleY), TexCoord,
    AColor, AEffect);
end;

procedure TGameCanvas.DrawPatternRotate(ATexture: TTexture; X, Y, Angle, Scale: Single; PatternIndex,
  PatternWidth, PatternHeight: Integer; Mirror: Boolean; const AColor: TColorRect; AEffect:
  TBlendingEffect = TBlendingEffect.Normal);
begin
  var TexCoord := SetPattern(ATexture, PatternIndex, PatternWidth, PatternHeight);
  if Mirror then
    TexCoord := TexCoord.Mirror;
  QuadRegion(ATexture, TQuad.Rotated(Point2f(X, Y), Point2f(PatternWidth, PatternHeight), Angle,
    Scale), TexCoord, AColor, AEffect);
end;

procedure TGameCanvas.DrawRotateC(ATexture: TTexture; X, Y: Single; const Angle, Scale: Single;
  const AColor: TColorRect; AEffect: TBlendingEffect = TBlendingEffect.Normal);
begin
  var Width := ATexture.Parameters.Width;
  var Height := ATexture.Parameters.Height;
  Quad(ATexture, TQuad.Rotated(Point2f(X, Y), Point2f(Width, Height), Angle, Scale), QuadUnity,
    AColor, AEffect);
end;

procedure TGameCanvas.DrawRotate(ATexture: TTexture; X, Y, CenterX, CenterY: Single; const Angle,
  Scale: Single; const AColor: TColorRect; AEffect: TBlendingEffect = TBlendingEffect.Normal);
begin
  var Width := ATexture.Parameters.Width;
  var Height := ATexture.Parameters.Height;
  Quad(ATexture, TQuad.Rotated(Point2f(X, Y), Point2f(Width, Height), Point2f(CenterX, CenterY),
    Angle, Scale), QuadUnity, AColor, AEffect);
end;

procedure TGameCanvas.DrawHue(ATexture: TTexture; Hue: Byte; X, Y: Single; Mirror: Boolean; AEffect:
  TBlendingEffect = TBlendingEffect.Normal);
begin
  Attributes := [TCanvasAttribute.ColorAdjust];
  DrawColor1(ATexture, X, Y, Mirror, ARGB(255, 128, 128, Hue), AEffect);
end;

procedure TGameCanvas.DrawSaturation(ATexture: TTexture; Saturation: Byte; X, Y: Single; Mirror:
  Boolean; AEffect: TBlendingEffect = TBlendingEffect.Normal);
begin
  Attributes := [TCanvasAttribute.ColorAdjust];
  DrawColor1(ATexture, X, Y, Mirror, ARGB(255, 128, Saturation, 128), AEffect);
end;

procedure TGameCanvas.DrawTarget(var ATexture: TTexture; Width, Height: Integer; Proc: TProc);
begin
  if ATexture.Initialized then
    ATexture.Free;
  var Parameters: TTextureParameters;
  FillChar(Parameters, SizeOf(TTextureParameters), 0);
  Parameters.Width := Width;
  Parameters.Height := Height;
  Parameters.Attributes := TextureDrawable or TexturePremultipliedAlpha;
  Parameters.Multisamples := 0;
  Parameters.Format := TPixelFormat.BGRA8;
  ATexture := TextureInit(FDevice, Parameters);
  ATexture.Clear;
  ATexture.BeginScene;
  BeginScene;
  Proc;
  var LRenderState := FDevice.RenderingState;
  LRenderState.BlendAlpha.Dest := TBlendFactor.InvSourceAlpha;
  FDevice.RenderingState := LRenderState;
  EndScene;
  ATexture.EndScene;
end;

procedure TGameCanvas.DrawTargetStatic(var ATexture: TTexture; Width, Height: Integer; Proc: TProc);
begin
  if not ATexture.Initialized then
  begin
    var Parameters: TTextureParameters;
    FillChar(Parameters, SizeOf(TTextureParameters), 0);
    Parameters.Width := Width;
    Parameters.Height := Height;
    Parameters.Attributes := TextureDrawable or TexturePremultipliedAlpha;
    Parameters.Format := TPixelFormat.BGRA8;
    ATexture := TextureInit(FDevice, Parameters);
  end;
  ATexture.Clear(FloatColor($0));
  ATexture.BeginScene;
  BeginScene;
  Proc;
  var LRenderState := FDevice.RenderingState;
  LRenderState.BlendAlpha.Dest := TBlendFactor.InvSourceAlpha;
  FDevice.RenderingState := LRenderState;
  EndScene;
  ATexture.EndScene;
end;

function GetA(const Color: LongWord): Byte; inline;
begin
  Result := Color shr 24;
end;

function GetR(const Color: LongWord): Byte; inline;
begin
  Result := (Color shr 16) and $FF;
end;

function GetG(const Color: LongWord): Byte; inline;
begin
  Result := (Color shr 8) and $FF;
end;

function GetB(const Color: LongWord): Byte; inline;
begin
  Result := Color and $FF;
end;

function ARGB(const A, R, G, B: Byte): LongWord; inline;
begin
  Result := (A shl 24) or (B shl 16) or (G shl 8) or R;
end;

end.

