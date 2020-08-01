unit MainFm;

interface

uses
  PXT.Types, Windows, System.Classes, System.SysUtils, Vcl.Forms, Vcl.Controls, Vcl.Graphics,
  Vcl.Dialogs, PXT.Graphics, PXT.Controls, PXT.Canvas, Vcl.StdCtrls, Generics.Collections,
  PXT.Sprites;

type
  TEnemyKind = (Ship, SquareShip, AnimShip, Mine);

  TMapRec = record
    X, Y, Z: Integer;
    ImageName: string[50];
  end;

  TBullet = class(TAnimatedSprite)
  private
    DestAngle: Single;
    FMoveSpeed: Integer;
    FCounter: Integer;
  public
    constructor Create(const AParent: TSprite); override;
    procedure DoMove(const MoveCount: Single); override;
    property MoveSpeed: Integer read FMoveSpeed write FMoveSpeed;
  end;

  TPlayerBullet = class(TAnimatedSprite)
  private
    FDestX, FDestY: Integer;
    FCounter: Integer;
    FMoveSpeed: Integer;
  public
    procedure DoMove(const MoveCount: Single); override;
    procedure DoCollision(const Sprite: TSprite); override;
    property DestX: Integer read FDestX write FDestX;
    property DestY: Integer read FDestY write FDestY;
    property MoveSpeed: Integer read FMoveSpeed write FMoveSpeed;
  end;

  TEnemy = class(TAnimatedSprite)
  private
    FMoveSpeed: Single;
    FTempMoveSpeed: Single;
    FRotateSpeed: Single;
    FDestX, FDestY: Integer;
    FDestAngle: Integer;
    FLookAt: Boolean;
    FKind: TEnemyKind;
    FLife: Integer;
    FBullet: TBullet;
  public
    function InOffScreen: Boolean;
    procedure DoMove(const MoveCount: Single); override;
    property Kind: TEnemyKind read FKind write FKind;
    property MoveSpeed: Single read FMoveSpeed write FMoveSpeed;
    property TempMoveSpeed: Single read FTempMoveSpeed write FTempMoveSpeed;
    property RotateSpeed: Single read FRotateSpeed write FRotateSpeed;
    property DestX: Integer read FDestX write FDestX;
    property DestY: Integer read FDestY write FDestY;
    property DestAngle: Integer read FDestAngle write FDestAngle;
    property LookAt: Boolean read FLookAt write FLookAt;
    property Life: Integer read FLife write FLife;
    property Bullet: TBullet read FBullet write FBullet;
  end;

  TAsteroids = class(TAnimatedSprite)
  private
    FStep: Single;
    FMoveSpeed: Single;
    FRange: Single;
    FSeed: Integer;
    FPosX: Integer;
    FPosY: Integer;
    FLife: Integer;
  public
    procedure DoMove(const MoveCount: Single); override;
    property MoveSpeed: Single read FMoveSpeed write FMoveSpeed;
    property Step: Single read FStep write FStep;
    property Seed: Integer read FSeed write FSeed;
    property Range: Single read FRange write FRange;
    property PosX: Integer read FPosX write FPosX;
    property PosY: Integer read FPosY write FPosY;
    property Life: Integer read FLife write FLife;
  end;

  TFort = class(TAnimatedSprite)
  private
    FLife: Integer;
    FBullet: TBullet;
  public
    procedure DoMove(const MoveCount: Single); override;
    property Bullet: TBullet read FBullet write FBullet;
    property Life: Integer read FLife write FLife;
  end;

  TPlayerShip = class(TPlayerSprite)
  private
    FDoAccelerate: Boolean;
    FDoDeccelerate: Boolean;
    FLife: Single;
    FBullet: TPlayerBullet;
    FReady: Boolean;
    FReadyTime: Integer;
  public
    procedure DoMove(const MoveCount: Single); override;
    procedure DoCollision(const Sprite: TSprite); override;
    property DoAccelerate: Boolean read FDoAccelerate write FDoAccelerate;
    property DoDeccelerate: Boolean read FDoDeccelerate write FDoDeccelerate;
    property Bullet: TPlayerBullet read FBullet write FBullet;
    property Life: Single read FLife write FLife;
  end;

  TTail = class(TPlayerSprite)
  private
    FCounter: Integer;
  public
    procedure DoMove(const MoveCount: Single); override;
    property Counter: Integer read FCounter write FCounter;
  end;

  TExplosion = class(TPlayerSprite)
  public
    procedure DoMove(const MoveCount: Single); override;
  end;

  TSpark = class(TPlayerSprite)
  public
    procedure DoMove(const MoveCount: Single); override;
  end;

  TBonus = class(TAnimatedSprite)
  private
    FPX, FPY: Single;
    FStep: Single;
    FMoveSpeed: Single;
  public
    procedure DoMove(const MoveCount: Single); override;
    property PX: Single read FPX write FPX;
    property PY: Single read FPY write FPY;
    property Step: Single read FStep write FStep;
    property MoveSpeed: Single read FMoveSpeed write FMoveSpeed;
  end;

  TMainForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    FDisplaySize: TPoint2i;
    FDisplayScale: Single;
    FDevice: TDevice;
    FCanvas: TCanvas;
    FTextRenderer: TTextRenderer;
    DrawableTexture: TTexture;
    SourceTexture: TTexture;
    CursorX, CursorY: Integer;
    SpaceLayer, MistLayer1, MistLayer2: TSpriteEngine;
    SpriteEngine: TSpriteEngine;
    PlayerShip: TPlayerShip;
    FileSize: Integer;
    MapData: array of TMapRec;
    Score: Integer;
    DisplaySize: TPoint2i;
    GameFont: TTextRenderer;
    GameCanvas: TGameCanvas;
    procedure LoadTexture(FileName: string);
    procedure TimerEvent(Sender: TObject);
    procedure RenderEvent;
    procedure LoadMap(FileName: string);
    procedure CreateMap(OffsetX, OffsetY: Integer);
    procedure CreateSpark(PosX, PosY: Single);
    procedure CreateBonus(BonusName: string; PosX, PosY: Single);
  public
  end;

var
  MainForm: TMainForm;

implementation

uses
  PXT.Headers, AsphyreTimer, System.Types, PXT.TypesEx, StrUtils, MMsystem, Bass;

{$R *.dfm}

var
  GameImages: TDictionary<string, TTexture>;
  hs: HSTREAM;

procedure PlaySound(FileName: AnsiString);
begin
  hs := BASS_StreamCreateFile(False, PAnsiChar('Sounds/' + FileName), 0, 0, 0);
  BASS_ChannelPlay(hs, False);
end;

procedure TMainForm.LoadTexture(FileName: string);
begin
  var Texture := TextureInit(MainForm.FDevice, FileName, PXT.Types.TPixelFormat.RGBA8);
  GameImages.Add(ChangeFileExt(ExtractFileName(FileName), ''), Texture);
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  LParameters: TTextureParameters;
const
  RandNumber: array[0..1] of string = ('-0.15', '0.15');
begin

  GameImages := TDictionary<string, TTexture>.Create;
  FDisplaySize := Point2i(ClientWidth, ClientHeight);
  FDevice := DeviceInit(TDeviceBackend.Default, Handle, Point2i(1024, 768), PXT.Types.TPixelFormat.BGRA8,
    PXT.Types.TPixelFormat.Unknown, 0, DeviceAttributes([TDeviceAttribute.VSync]));
  FDevice.Resize(Point2i(1024, 768));
  if not FDevice.Initialized then
  begin
    MessageDlg('Could not create rendering device.', mtError, [mbOK], 0);
    Application.Terminate;
    Exit;
  end;

  GameCanvas.Create(FDevice);

  FTextRenderer := TextRendererInit(GameCanvas, Point2i(512, 512));
  if not FTextRenderer.Initialized then
  begin
    MessageDlg('Could not create text renderer.', mtError, [mbOK], 0);
    Application.Terminate;
    Exit;
  end;

  SpriteEngine := TSpriteEngine.Create(nil);
  SpriteEngine.Canvas := GameCanvas;
  SpriteEngine.VisibleWidth := 1800;
  SpriteEngine.VisibleHeight := 1600;
  //
  SpaceLayer := TSpriteEngine.Create(nil);
  SpaceLayer.Canvas := GameCanvas;
  SpaceLayer.VisibleWidth := 1800;
  SpaceLayer.VisibleHeight := 1600;
  //
  MistLayer1 := TSpriteEngine.Create(nil);

  MistLayer1.Canvas := GameCanvas;
  MistLayer1.VisibleWidth := 1800;
  MistLayer1.VisibleHeight := 1600;
  //
  MistLayer2 := TSpriteEngine.Create(nil);
  MistLayer2.Canvas := GameCanvas;
  MistLayer2.VisibleWidth := 1800;
  MistLayer2.VisibleHeight := 1600;

  var FileSearchRec: TSearchRec;
  if FindFirst(ExtractFilePath(ParamStr(0)) + 'Gfx\' + '*.png', faAnyfile, FileSearchRec) = 0 then
    repeat
      LoadTexture('Gfx\' + FileSearchRec.Name);
    until FindNext(FileSearchRec) <> 0;
  LoadTexture('Gfx\Space.jpg');

  // create enemys
  for var I := 0 to 400 do
  begin
    with TEnemy.Create(SpriteEngine) do
    begin
      ImageLib := GameImages;
      Kind := TEnemyKind(Random(4));
      DrawMode := 1;
      X := Random(8000) - 2500;
      Y := Random(8000) - 2500;
      Z := 10000;
      Collisioned := True;
      MoveSpeed := 1 + (Random(4) * 0.5);
      RotateSpeed := 0.5 + (Random(4) * 0.4);
      Life := 4;
      case Kind of
        Ship:
          begin
            ImageName := 'Ship' + IntToStr(Random(2));
            SetPattern(128, 128);
            CollideRadius := 40;
            ScaleX := 0.7;
            ScaleY := 0.8;
          end;
        SquareShip:
          begin
            ImageName := 'SquareShip' + IntToStr(Random(2));
            CollideRadius := 30;
            LookAt := True;
            if ImageName = 'SquareShip0' then
              SetPattern(60, 62)
            else
              SetPattern(72, 62);

          end;
        AnimShip:
          begin
            ImageName := 'AnimShip' + IntToStr(Random(2));
            CollideRadius := 25;
            // ScaleX := 1.1;
            // ScaleY := 1.1;

            if ImageName = 'AnimShip1' then
            begin
              SetPattern(64, 64);
              SetAnim(ImageName, 0, 8, 0.2, True, False, True);
            end;
            if ImageName = 'AnimShip0' then
            begin
              SetPattern(48, 62);
              SetAnim(ImageName, 0, 4, 0.08, True, False, True);
            end;
          end;
        Mine:
          begin
            ImageName := 'Mine0';
            SetPattern(64, 64);
            CollideRadius := 16;
            RotateSpeed := 0.04;
          end;
      end;
      TempMoveSpeed := MoveSpeed;
      Width := PatternWidth;
      Height := PatternHeight;
    end;
  end;

  // create asteroids
  for var I := 0 to 500 do
    with TAsteroids.Create(SpriteEngine) do
    begin
      ImageLib := GameImages;
      ImageName := 'Roids' + IntToStr(Random(3));
      PosX := Random(8000) - 2500;
      PosY := Random(8000) - 2500;
      Z := 4800;

      DrawMode := 1;
      DoCenter := True;

      if ImageName = 'Roids0' then
      begin
        SetPattern(64, 64);
        AnimSpeed := 0.2;
      end;
      if ImageName = 'Roids1' then
      begin
        SetPattern(96, 96);
        AnimSpeed := 0.16;
      end;
      if ImageName = 'Roids2' then
      begin
        SetPattern(128, 128);
        AnimSpeed := 0.25;
      end;
      SetAnim(ImageName, 0, PatternCount, 0.15, True, False, True);
      MoveSpeed := RandomFrom(RandNumber).ToSingle;
      Range := 150 + Random(200);
      Step := (Random(1512));
      Seed := 50 + Random(100);
      Life := 6;
      ScaleX := 1;
      ScaleY := 1;
      Collisioned := True;
      if ImageName = 'Roids0' then
        CollideRadius := 32;
      if ImageName = 'Roids1' then
        CollideRadius := 48;
      if ImageName = 'Roids2' then
        CollideRadius := 50;
      Width := PatternWidth;
      Height := PatternHeight;
    end;

  // create player's ship
  PlayerShip := TPlayerShip.Create(SpriteEngine);
  with PlayerShip do
  begin
    ImageLib := GameImages;
    ImageName := 'PlayerShip';
    SetPattern(64, 64);
    Width := PatternWidth;
    Height := PatternHeight;

    ScaleX := 1.2;
    ScaleY := 1.2;
    DoCenter := True;
    DrawMode := 1;
    Acceleration := 0.02;
    Decceleration := 0.02;
    MinSpeed := 0;
    Maxspeed := 4.5;
    Z := 5000;
    Collisioned := True;
    CollideRadius := 25;
  end;

  LoadMap('Level1.map');
  CreateMap(500, 500);

  // create planet
  for var I := 0 to 100 do
  begin
    with TSpriteEx.Create(SpaceLayer) do
    begin
      ImageLib := GameImages;
      ImageName := 'planet' + IntToStr(Random(4));
      Width := ImageWidth;
      Height := ImageHeight;
      X := (Random(25) * 300) - 2500;
      Y := (Random(25) * 300) - 2500;
      Z := 100;
      Moved := False;
    end;
  end;

  // create a huge endless space
  with TBackgroundSprite.Create(SpaceLayer) do
  begin
    ImageLib := GameImages;
    ImageName := 'Space';
    SetPattern(512, 512);
    Width := PatternWidth;
    Height := PatternHeight;
    SetMapSize(1, 1);
    Tiled := True;
    TileMode := tmFull;
    Moved := False;
  end;

  // create mist layer1
  with TBackgroundSprite.Create(MistLayer1) do
  begin
    ImageLib := GameImages;
    ImageName := 'Mist';
    SetPattern(1024, 1024);
    Width := PatternWidth;
    Height := PatternHeight;
    BlendingEffect := TBlendingEffect.Add;
    SetMapSize(1, 1);
    Tiled := True;
    TileMode := tmFull;
    Moved := False;
  end;
  // create mist layer2
  with TBackgroundSprite.Create(MistLayer2) do
  begin
    ImageLib := GameImages;
    ImageName := 'Mist';
    SetPattern(1024, 1024);
    X := 200;
    Y := 200;
    Width := PatternWidth;
    Height := PatternHeight;
    BlendingEffect := TBlendingEffect.Add;
    SetMapSize(1, 1);
    Tiled := True;
    TileMode := tmFull;
    Moved := False;
  end;
  Screen.Cursor := crNone;
  Timer.OnTimer := TimerEvent;
  Timer.Speed := 60.0;
  Timer.MaxFPS := 4000;
  Timer.Enabled := True;
  if not BASS_Init(-1, 44100, 0, 0, nil) then
    ShowMessage('ªì©l¤Æ¿ù»~');
  MCISendString(PChar('play ' + 'Sounds\music1.mid'), nil, 0, 0);
end;

function Timex: Real;
{$J+}
const
  Start: Int64 = 0;
  frequency: Int64 = 0;
{$J-}
var
  Counter: Int64;
begin
  if Start = 0 then
  begin
    QueryPerformanceCounter(Start);
    QueryPerformanceFrequency(frequency);
    Result := 0;
  end;
  Counter := 0;
  QueryPerformanceCounter(Counter);
  Result := (Counter - Start) / frequency;
end;

var
  CurrentTime: Double;
  Accumulator: Double;
  NewTime, DeltaTime: Double;
  Counter: Integer;

procedure TMainForm.TimerEvent(Sender: TObject);
const
  dt = 1 / 60;
begin
  NewTime := Timex;
  DeltaTime := NewTime - CurrentTime;
  if DeltaTime > 0.016666 then
    DeltaTime := 0.016666;
  CurrentTime := NewTime;
  Accumulator := Accumulator + DeltaTime;

  while (Accumulator >= dt) do
  begin
    SpriteEngine.Dead;
    SpriteEngine.Move(1);
    SpaceLayer.WorldX := SpriteEngine.WorldX * 0.71;
    SpaceLayer.WorldY := SpriteEngine.WorldY * 0.71;
    MistLayer1.WorldX := SpriteEngine.WorldX * 1.1;
    MistLayer1.WorldY := SpriteEngine.WorldY * 1.1;
    MistLayer2.WorldX := SpriteEngine.WorldX * 1.3;
    MistLayer2.WorldY := SpriteEngine.WorldY * 1.3;
    Inc(Counter);
    if (Counter mod 4) = 0 then
      if PlayerShip.ImageName = 'PlayerShip' then
      begin
        with TTail.Create(SpriteEngine) do
        begin
          ImageLib := GameImages;
          ImageName := 'tail';
          SetPattern(64, 64);
          Width := PatternWidth;
          Height := PatternHeight;
          BlendingEffect := TBlendingEffect.Add;
          DrawMode := 1;
          ScaleX := 0.1;
          ScaleY := 0.1;
          X := 510 + Engine.WorldX;
          Y := 382 + Engine.WorldY;
          Z := 4000;
          Acceleration := 2.51;
          MinSpeed := 1;
          if PlayerShip.Speed < 1 then
            Maxspeed := 2
          else
            Maxspeed := 0.5;
          Direction := -128 + PlayerShip.Direction;
        end;
      end;
    Accumulator := Accumulator - dt;
  end;
  FDevice.BeginScene;
  FDevice.Clear([TClearLayer.Color], FloatColor($FFFFC800));
  GameCanvas.BeginScene;
  RenderEvent;
  GameCanvas.EndScene;
  FDevice.EndScene;
end;

procedure TMainForm.RenderEvent;
begin
  SpaceLayer.Draw;
  MistLayer1.Draw;
  MistLayer2.Draw;
  SpriteEngine.Draw;
  var Angle := Angle256(Trunc(CursorX) - 512, Trunc(CursorY) - 384) * 0.025;
  GameCanvas.DrawRotate(GameImages['cursor'], CursorX, CursorY, 15, 35, Angle, 1, $FFFFFFFF,
    TBlendingEffect.Add);
  GameCanvas.DrawPattern(GameImages['Shield'], 20, 640, -Trunc(PlayerShip.Life), 111, 105, False,
    $FFFFFFFF);
  var LFontSettings := TFontSettings.Create('Tahoma', 28.0, TFontWeight.Bold);
  LFontSettings.Effect.ShadowBrightness := 0.5;
  LFontSettings.Effect.ShadowOpacity := 1.0;
  LFontSettings.Effect.BorderType := TFontBorder.SemiHeavy;
  FTextRenderer.FontSettings := LFontSettings;
  FTextRenderer.DrawCentered(Point2f(500, 20), Score.ToString, ColorPair($FF0000FF, $FF00FFFF));
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  SpriteEngine.Free;
  SpaceLayer.Free;
  MistLayer1.Free;
  MistLayer2.Free;
  GameImages.Free;
  FTextRenderer.Free;
  FCanvas.Free;
  FDevice.Free;
end;

procedure TMainForm.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y:
  Integer);
begin
  if Button = mbRight then
  begin
    CursorX := X;
    CursorY := Y;
    PlayerShip.DoAccelerate := True;
    PlayerShip.DoDeccelerate := False;
  end;
  if (Button = mbLeft) and (PlayerShip.ImageName = 'PlayerShip') then
  begin
    PlaySound('Shoot.wav');
    PlayerShip.Bullet := TPlayerBullet.Create(SpriteEngine);
    with PlayerShip.Bullet do
    begin
      ImageLib := GameImages;
      ImageName := 'bb';
      SetPattern(24, 36);
      Width := PatternWidth;
      Height := PatternHeight;
      ScaleX := 1;
      ScaleY := 1;
      DrawMode := 1;
      BlendingEffect := TBlendingEffect.Add;
      DoCenter := True;
      MoveSpeed := 9;
      Angle := PlayerShip.Angle + 0.05;
      X := PlayerShip.X;
      Y := PlayerShip.Y;
      Z := 11000;
      Collisioned := True;
      CollideRadius := 10;
    end;
  end;
end;

procedure TMainForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  CursorX := X;
  CursorY := Y;
end;

procedure TMainForm.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y:
  Integer);
begin
  if Button = mbRight then
  begin
    PlayerShip.DoAccelerate := False;
    PlayerShip.DoDeccelerate := True;
  end;
end;

procedure TMainForm.LoadMap(FileName: string);
var
  Fs: TFileStream;
begin
  Fs := TFileStream.Create(ExtractFilePath(Application.ExeName) + FileName, fmOpenRead);
  Fs.ReadBuffer(FileSize, SizeOf(FileSize));
  SetLength(MapData, FileSize);
  Fs.ReadBuffer(MapData[0], SizeOf(TMapRec) * FileSize);
  Fs.Destroy;
end;

procedure TMainForm.CreateMap(OffsetX, OffsetY: Integer);
var
  I: Integer;
begin
  for I := 0 to FileSize - 1 do
  begin
    if LeftStr(MapData[I].ImageName, 4) = 'Tile' then
    begin
      with TSprite.Create(SpriteEngine) do
      begin
        ImageLib := GameImages;
        ImageName := LowerCase(MapData[I].ImageName);
        Width := ImageWidth;
        Height := ImageHeight;
        X := MapData[I].X + OffsetX - 2500;
        Y := MapData[I].Y + OffsetY - 2500;
        Z := MapData[I].Z;
        Moved := False;
      end;
    end;
    //
    if LeftStr(MapData[I].ImageName, 4) = 'Fort' then
    begin
      with TFort.Create(SpriteEngine) do
      begin
        ImageLib := GameImages;
        ImageName := LowerCase(MapData[I].ImageName);
        SetPattern(44, 77);
        DrawMode := 1;
        DoCenter := True;
        Width := PatternWidth;
        Height := PatternHeight;
        X := MapData[I].X + OffsetX - 2500 + 22;
        Y := MapData[I].Y + OffsetY - 2500 + 40;
        Z := MapData[I].Z;
        Collisioned := True;
        CollideRadius := 24;
        Life := 5;
      end;
    end;
  end;
end;

procedure TMainForm.CreateSpark(PosX, PosY: Single);
var
  I, Pattern: Integer;
const
  RandNumber: array[0..1] of string = ('5', '9');
begin
  Pattern := RandomFrom(RandNumber).ToInteger;
  for I := 0 to 128 do
  begin
    with TSpark.Create(SpriteEngine) do
    begin
      ImageLib := GameImages;
      ImageName := 'Particles';
      SetPattern(32, 32);
      Width := PatternWidth;
      Height := PatternHeight;
      BlendingEffect := TBlendingEffect.Add;
      X := PosX + -Random(30);
      Y := PosY + Random(30);
      Z := 12000;
      PatternIndex := Pattern;
      ScaleX := 1.2;
      ScaleY := 1.2;
      Red := Random(250);
      Green := Random(250);
      Blue := Random(250);
      Acceleration := 0.02;
      MinSpeed := 0.8;
      Maxspeed := -(0.4 + Random(2));
      Direction := I * 2;
    end;
  end;
end;

procedure TMainForm.CreateBonus(BonusName: string; PosX, PosY: Single);
begin
  if (Random(3) = 1) or (Random(3) = 2) then
  begin
    with TBonus.Create(SpriteEngine) do
    begin
      ImageLib := GameImages;
      ImageName := BonusName;
      SetPattern(32, 32);
      Width := PatternWidth;
      Height := PatternHeight;
      MoveSpeed := 0.251;
      PX := PosX - 50;
      PY := PosY - 100;
      Z := 12000;
      ScaleX := 1.5;
      ScaleY := 1.5;
      DoCenter := True;
      Collisioned := True;
      CollideRadius := 24;
      SetAnim(ImageName, 0, PatternCount, 0.25, True, False, True);
    end;
  end;
end;

procedure TEnemy.DoMove(const MoveCount: Single);
begin
  if (Life >= 1) and (ImageName <> 'Explosion2') then
    BlendingEffect := TBlendingEffect.Normal;
  if (InOffScreen) and (ImageName <> 'Explosion2') then
    MoveSpeed := TempMoveSpeed;
  if (Life <= 0) or (not InOffScreen) then
    MoveSpeed := 0;
  if Trunc(AnimPos) >= 15 then
    Dead;
  if (Trunc(AnimPos) >= 1) and (ImageName = 'Explosion2') then
    Collisioned := False;

  case Kind of
    Ship:
      begin
        CollidePos := Point(Round(X) + 64, Round(Y) + 64);
        case Random(100) of
          40..43:
            begin
              DestAngle := Random(255);
            end;
          51..52:
            begin
              DestAngle := Trunc(Angle256(Trunc(MainForm.PlayerShip.X) - Trunc(Self.X), Trunc(MainForm.PlayerShip.Y)
                - Trunc(Self.Y)));
            end;
        end;
        RotateToAngle(DestAngle, RotateSpeed, MoveSpeed);
      end;

    SquareShip:
      begin
        CollidePos := Point(Round(X) + 30, Round(Y) + 30);
        case Random(100) of
          40..45:
            begin
              DestX := Random(8000);
              DestY := Random(6000)
            end;
          51..52:
            begin
              DestX := Trunc(MainForm.PlayerShip.X);
              DestY := Trunc(MainForm.PlayerShip.Y);

            end;
        end;
        CircleToPos(DestX, DestY, Trunc(MainForm.PlayerShip.X), Trunc(MainForm.PlayerShip.Y),
          RotateSpeed, MoveSpeed, LookAt);
      end;

    AnimShip:
      begin
        CollidePos := Point(Round(X) + 20, Round(Y) + 20);
        case Random(100) of
          40..45:
            begin
              DestX := Random(8000);
              DestY := Random(6000)
            end;
          51..54:
            begin
              DestX := Trunc(MainForm.PlayerShip.X);
              DestY := Trunc(MainForm.PlayerShip.Y);
            end;
        end;
        RotateToPos(DestX, DestY, RotateSpeed, MoveSpeed);
      end;

    Mine:
      begin
        CollidePos := Point(Round(X) + 32, Round(Y) + 32);
        case Random(300) of
          150:
            begin
              DestX := Trunc(MainForm.PlayerShip.X);
              DestY := Trunc(MainForm.PlayerShip.Y);
            end;
          200..202:
            begin
              DestX := Random(8000);
              DestY := Random(8000);
            end;
        end;
        Angle := Angle + RotateSpeed;
        TowardToPos(DestX, DestY, MoveSpeed, False);
      end;

  end;

  // enemy shoot bullet
  if (Kind = Ship) or (Kind = SquareShip) then
  begin
    if InOffScreen then
    begin
      if Random(100) = 50 then
      begin
        Bullet := TBullet.Create(MainForm.SpriteEngine);
        Bullet.ImageName := 'bulletr';
        Bullet.MoveSpeed := 5;
        Bullet.X := Self.X + 1;
        Bullet.Y := Self.Y;
        Bullet.DestAngle := Angle * 40;
      end;
    end;
  end;
  inherited;
end;

function TEnemy.InOffScreen: Boolean;
begin
  if (X > Engine.WorldX - 50) and (Y > Engine.WorldY - 50) and (X < Engine.WorldX + 1124) and (Y <
    Engine.WorldY + 778) then
    Result := True
  else
    Result := False;
end;

constructor TBullet.Create(const AParent: TSprite);
begin
  inherited;
  ImageLib := GameImages;
  SetPattern(40, 40);
  BlendingEffect := TBlendingEffect.Add;
  Z := 4000;
  FCounter := 0;
  DrawMode := 1;
  Collisioned := True;
  if ImageName = 'bulletr' then
    CollideRadius := 15;
  if ImageName = 'BulletS' then
    CollideRadius := 12;
end;

procedure TBullet.DoMove;
begin
  inherited;
  CollidePos := Point(Round(X) + 20, Round(Y) + 20);
  TowardToAngle(Trunc(DestAngle), MoveSpeed, True);
  Inc(FCounter);
  if (Trunc(AnimPos) >= 15) and (ImageName = 'Explosion3') then
    Dead;
  if FCounter > 250 then
    Dead;
end;

procedure TPlayerBullet.DoMove;
begin
  inherited;
  TowardToAngle(Trunc(Angle * 40), MoveSpeed, True);
  CollidePos := Point(Round(X) + 24, Round(Y) + 38);
  Inc(FCounter);
  if FCounter > 180 then
    Dead;
  if Trunc(AnimPos) >= 11 then
    Dead;
  Collision;
end;

procedure TPlayerBullet.DoCollision(const Sprite: TSprite);
var
  I: Integer;
begin
  if Sprite is TAsteroids then
  begin
    PlaySound('Hit.wav');
    Collisioned := False;
    MoveSpeed := 0;
    SetPattern(64, 64);
    SetAnim('Explosions', 0, 12, 0.3, False, False, True);
    if Trunc(AnimPos) < 1 then
      TAsteroids(Sprite).BlendingEffect := TBlendingEffect.Shadow;
    TAsteroids(Sprite).Life := TAsteroids(Sprite).Life - 1;
    if (TAsteroids(Sprite).Life <= 0) then
    begin
      PlaySound('Explode.wav');
      TAsteroids(Sprite).MoveSpeed := 0;
      for I := 0 to 128 do
        with TExplosion.Create(MainForm.SpriteEngine) do
        begin
          ImageLib := GameImages;
          ImageName := 'Particles';
          SetPattern(32, 32);
          Width := PatternWidth;
          Height := PatternHeight;
          BlendingEffect := TBlendingEffect.Add;
          X := TAsteroids(Sprite).X + -Random(60);
          Y := TAsteroids(Sprite).Y - Random(60);
          Z := 4850;
          PatternIndex := 7;
          ScaleX := 3;
          ScaleY := 3;
          Red := 255;
          Green := 100;
          Blue := 101;
          Acceleration := 0.0252;
          MinSpeed := 1;
          Maxspeed := -(0.31 + Random(2));
          Direction := I * 2;
        end;
      MainForm.CreateBonus('Money', TAsteroids(Sprite).X, TAsteroids(Sprite).Y);
      TAsteroids(Sprite).Dead;
    end;
  end;
  //
  if Sprite is TEnemy then
  begin
    PlaySound('Hit.wav');
    Collisioned := False;
    MoveSpeed := 0;
    SetPattern(64, 64);
    SetAnim('Explosion3', 0, 12, 0.3, False, False, True);
    if Trunc(AnimPos) < 1 then
      TEnemy(Sprite).BlendingEffect := TBlendingEffect.Add;
    TEnemy(Sprite).Life := TEnemy(Sprite).Life - 1;
    if TEnemy(Sprite).Life <= 0 then
    begin
      TEnemy(Sprite).MoveSpeed := 0;
      TEnemy(Sprite).RotateSpeed := 0;
      TEnemy(Sprite).DestAngle := 0;
      TEnemy(Sprite).LookAt := False;
      TEnemy(Sprite).BlendingEffect := TBlendingEffect.Add;
      TEnemy(Sprite).ScaleX := 3;
      TEnemy(Sprite).ScaleY := 3;
      TEnemy(Sprite).SetPattern(64, 64);
      TEnemy(Sprite).SetAnim('Explosion2', 0, 16, 0.15, False, False, True);
      MainForm.CreateBonus('Bonus' + IntToStr(Random(3)), X, Y);
    end;
  end;
  //
  if Sprite is TFort then
  begin
    PlaySound('Hit.wav');
    Collisioned := False;
    MoveSpeed := 0;
    SetPattern(64, 64);
    SetAnim('Explosion3', 0, 12, 0.3, False, False, True);
    if Trunc(AnimPos) < 3 then
      TFort(Sprite).SetColor(255, 0, 0);
    TFort(Sprite).Life := TFort(Sprite).Life - 1;
    if TFort(Sprite).Life <= 0 then
    begin
      TFort(Sprite).BlendingEffect := TBlendingEffect.Add;
      TFort(Sprite).ScaleX := 3;
      TFort(Sprite).ScaleY := 3;
      TFort(Sprite).SetPattern(64, 64);
      TFort(Sprite).SetAnim('Explosion2', 0, 16, 0.15, False, False, True);
    end;
  end;
end;

procedure TAsteroids.DoMove(const MoveCount: Single);
begin
  inherited;
  X := PosX + Cos(Step / (30)) * Range - (Sin(Step / (20)) * Range);
  Y := PosY + Sin(Step / (30 + Seed)) * Range + (Cos(Step / (20)) * Range);
  Step := Step + MoveSpeed;
  if ImageName = 'Roids2' then
    Angle := Angle + 0.02;
  if ImageName = 'Roids0' then
    CollidePos := Point(Round(X) + 32, Round(Y) + 32);
  if ImageName = 'Roids1' then
    CollidePos := Point(Round(X) + 30, Round(Y) + 30);
  if ImageName = 'Roids2' then
    CollidePos := Point(Round(X) + 34, Round(Y) + 34);
  BlendingEffect := TBlendingEffect.Normal;
end;

procedure TFort.DoMove(const MoveCount: Single);
begin
  inherited;
  SetColor(255, 255, 255);
  if ImageName = 'fort' then
    LookAt(Trunc(MainForm.PlayerShip.X), Trunc(MainForm.PlayerShip.Y));
  CollidePos := Point(Round(X) + 22, Round(Y) + 36);
  if Trunc(AnimPos) >= 15 then
    Dead;
  if (Trunc(AnimPos) >= 1) and (ImageName = 'Explosion2') then
    Collisioned := False;

  if Random(150) = 50 then
  begin
    if (X > Engine.WorldX + 0) and (Y > Engine.WorldY + 0) and (X < Engine.WorldX + 800) and (Y <
      Engine.WorldY + 600) then
    begin
      Bullet := TBullet.Create(MainForm.SpriteEngine);
      Bullet.ImageName := 'BulletS';
      Bullet.Width := 40;
      Bullet.Height := 40;
      Bullet.BlendingEffect := TBlendingEffect.Add;
      Bullet.MoveSpeed := 4;
      Bullet.Z := 4000;
      Bullet.FCounter := 0;
      Bullet.X := Self.X + 5;
      Bullet.Y := Self.Y;
      Bullet.DrawMode := 1;
      Bullet.DestAngle := Angle * 40;
    end;
  end;
end;

procedure TPlayerShip.DoMove(const MoveCount: Single);
begin
  inherited;
  SetColor(255, 255, 255);
  CollidePos := Point(Round(X) + 20, Round(Y) + 20);
  Collision;
  if DoAccelerate then
    Accelerate;
  if DoDeccelerate then
    Deccelerate;
  if ImageName = 'PlayerShip' then
  begin
    UpdatePos(1);
    // LookAt(CursorX, CursorY);
    Angle := Angle256(Trunc(MainForm.CursorX) - 512, Trunc(MainForm.CursorY) - 384) * 0.025;
    Direction := Trunc(Angle256(MainForm.CursorX - 512, MainForm.CursorY - 384));
  end;
  if (Trunc(AnimPos) >= 32) and (ImageName = 'Explode') then
  begin
    ImageName := 'PlayerShip';
    BlendingEffect := TBlendingEffect.Normal;
    ScaleX := 1.2;
    ScaleY := 1.2;
  end;
  if FReady then
    Inc(FReadyTime);
  if FReadyTime = 350 then
  begin
    FReady := False;
    Collisioned := True;
  end;
  Engine.WorldX := X - 512;
  Engine.WorldY := Y - 384;
end;

procedure TPlayerShip.DoCollision(const Sprite: TSprite);
var
  I: Integer;
begin
  if Sprite is TBonus then
  begin
    PlaySound('GetBonus.wav');
    if TBonus(Sprite).ImageName = 'Bonus0' then
      Inc(MainForm.Score, 100);
    if TBonus(Sprite).ImageName = 'Bonus1' then
      Inc(MainForm.Score, 200);
    if TBonus(Sprite).ImageName = 'Bonus2' then
      Inc(MainForm.Score, 300);
    if TBonus(Sprite).ImageName = 'Money' then
      Inc(MainForm.Score, 500);
    MainForm.CreateSpark(TBonus(Sprite).X, TBonus(Sprite).Y);
    TBonus(Sprite).Dead;
  end;
  if Sprite is TBullet then
  begin
    PlaySound('Hit.wav');
    MainForm.PlayerShip.Life := MainForm.PlayerShip.Life - 0.25;
    Self.SetColor(255, 0, 0);
    TBullet(Sprite).Collisioned := False;
    TBullet(Sprite).MoveSpeed := 0;
    TBullet(Sprite).SetPattern(64, 64);
    TBullet(Sprite).SetAnim('Explosion3', 0, 12, 0.3, False, False, True);
    TBullet(Sprite).Z := 10000;
  end;

  if (Sprite is TAsteroids) or (Sprite is TEnemy) then
  begin
    PlaySound('Hit.wav');
    FReady := True;
    FReadyTime := 0;
    MainForm.PlayerShip.Life := MainForm.PlayerShip.Life - 0.25;
    AnimPos := 0;
    SetPattern(64, 64);
    SetAnim('Explode', 0, 40, 0.25, False, False, True);
    Collisioned := False;
    BlendingEffect := TBlendingEffect.Add;
    ScaleX := 1.5;
    ScaleY := 1.5;
  end;
end;

procedure TTail.DoMove(const MoveCount: Single);
begin
  inherited;
  Alpha := Alpha - 6;
  if MainForm.PlayerShip.Speed < 1.1 then
  begin
    ScaleX := ScaleX + 0.01;
    ScaleY := ScaleY + 0.01;
  end
  else
  begin
    ScaleX := ScaleX + 0.025;
    ScaleY := ScaleY + 0.025;
  end;
  Angle := Angle + 0.125;
  UpdatePos(1);
  Accelerate;
  Inc(FCounter);
  if FCounter > 25 then
    Dead;
end;

procedure TExplosion.DoMove(const MoveCount: Single);
begin
  inherited;
  Accelerate;
  UpdatePos(1);
  Alpha := Alpha - 1;
  if Alpha < 1 then
    Dead;
end;

procedure TSpark.DoMove(const MoveCount: Single);
begin
  inherited;
  Accelerate;
  UpdatePos(1);
  Alpha := Alpha - 1;
  if Alpha < 1 then
    Dead;
end;

procedure TBonus.DoMove(const MoveCount: Single);
begin
  inherited;
  CollidePos := Point(Round(X) + 24, Round(Y) + 24);
  X := PX + Cos(Step / (30)) * 60 - (Sin(Step / (20)) * 150);
  Y := PY + Sin(Step / (90)) * 130 + (Cos(Step / (20)) * 110);
  Step := Step + MoveSpeed;
end;

end.

