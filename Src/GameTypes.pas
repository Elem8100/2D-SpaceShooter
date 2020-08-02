unit GameTypes;

interface

uses
  Windows, SysUtils, StrUtils, PXT.Sprites, Generics.Collections, Classes, Math,
  System.Types, PXT.Types, PXT.Graphics, PXT.Canvas;


var
  FDevice: TDevice;
  DisplaySize: TPoint2i;


function LeftPad(Value: Integer; Length: integer = 8): string;


implementation


function LeftPad(Value: Integer; Length: integer = 8): string;
begin
  Result := RightStr(StringOfChar('0', Length) + Value.ToString, Length);
end;

initialization

finalization


end.

