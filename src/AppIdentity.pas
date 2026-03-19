{
 BSD 3-Clause License
 ____________________
 
 Copyright © 2026, Jaisal E. K.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
 
 3. Neither the name of the copyright holder nor the names of its
    contributors may be used to endorse or promote products derived from
    this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
}

unit AppIdentity;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Windows, Graphics, Math, IntfGraphics, FPImage, LCLType, GraphType,
  fileinfo, winpeimagereader, elfreader, machoreader;

const
  APP_URL = 'https://pasted.jaisal.in';
  APP_REPOSITORY = 'https://github.com/ekjaisal/Pasted';
  DEV_URL = 'https://jaisal.in';
  DEV_SPONSOR = 'https://sponsor.jaisal.in';

  WM_PASTED_RESTORE = WM_USER + 8899;
  WM_PASTED_QUIT = WM_USER + 8900;

var
  APP_NAME: String;
  APP_VERSION: String;
  APP_TAGLINE: String;
  APP_ATTRIBUTION: String;
  DEV_AUTHOR: String;

procedure RenderAppLogo(Canvas: TCanvas; const AX, AY, ARequestedHeight: Double);

implementation

function ToLinear(V: Byte): Double; inline;
begin
  Result := Sqr(V / 255.0);
end;

function FromLinear(V: Double): Byte; inline;
begin
  Result := EnsureRange(Round(Sqrt(V) * 255.0), 0, 255);
end;

function InCapsule(x, y, cx1, cx2, cy, r: Double): Boolean;
var
  DistSq: Double;
begin
  Result := False;
  if (y >= cy - r) and (y <= cy + r) and (x >= cx1) and (x <= cx2) then
    Exit(True);

  if x < cx1 then
  begin
    DistSq := Sqr(x - cx1) + Sqr(y - cy);
    if DistSq <= Sqr(r) then Exit(True);
  end;

  if x > cx2 then
  begin
    DistSq := Sqr(x - cx2) + Sqr(y - cy);
    if DistSq <= Sqr(r) then Exit(True);
  end;
end;

procedure RenderAppLogo(Canvas: TCanvas; const AX, AY, ARequestedHeight: Double);
const
  SVG_W = 352.0;
  SVG_H = 320.0;
  SS_LEVEL = 20;

  C1_R = 102; C1_G = 2;  C1_B = 60;
  C2_R = 138; C2_G = 0;  C2_B = 75;
  C3_R = 212; C3_G = 20; C3_B = 90;

var
  RawImg: TLazIntfImage;
  ImgDesc: TRawImageDescription;
  Bmp: TBitmap;

  TargetW, TargetH: Integer;
  px, py, sx, sy: Integer;

  ScaleFactor: Double;
  SubPixelOffset: Double;
  SvgX, SvgY: Double;

  AccR, AccG, AccB, AccA: Double;

  IsHit: Boolean;
  P_Grad, T: Double;
  SampleR, SampleG, SampleB: Double;

  FinalColor: TFPColor;
begin
  if ARequestedHeight <= 0 then Exit;

  TargetH := Round(ARequestedHeight);
  TargetW := Round(ARequestedHeight * (SVG_W / SVG_H));

  ScaleFactor := SVG_H / TargetH;
  SubPixelOffset := ScaleFactor / (SS_LEVEL * 2);

  ImgDesc.Init_BPP32_B8G8R8A8_BIO_TTB(TargetW, TargetH);
  RawImg := TLazIntfImage.Create(0, 0);

  try
    RawImg.DataDescription := ImgDesc;

    for py := 0 to TargetH - 1 do
    begin
      for px := 0 to TargetW - 1 do
      begin
        AccR := 0; AccG := 0; AccB := 0; AccA := 0;

        for sy := 0 to SS_LEVEL - 1 do
        begin
          for sx := 0 to SS_LEVEL - 1 do
          begin
            SvgX := (px * ScaleFactor) + (sx * (ScaleFactor / SS_LEVEL)) + SubPixelOffset;
            SvgY := (py * ScaleFactor) + (sy * (ScaleFactor / SS_LEVEL)) + SubPixelOffset;

            IsHit := False;

            if (SvgY <= 80.0) then
              IsHit := InCapsule(SvgX, SvgY, 40, 170, 40, 40)
            else if (SvgY >= 120.0) and (SvgY <= 200.0) then
              IsHit := InCapsule(SvgX, SvgY, 40, 312, 160, 40)
            else if (SvgY >= 240.0) then
              IsHit := InCapsule(SvgX, SvgY, 40, 230, 280, 40);

            if IsHit then
            begin
              P_Grad := ((SvgX / SVG_W) + (SvgY / SVG_H)) / 2.0;
              P_Grad := EnsureRange(P_Grad, 0.0, 1.0);

              if P_Grad < 0.5 then
              begin
                T := P_Grad * 2.0;
                SampleR := C1_R + (C2_R - C1_R) * T;
                SampleG := C1_G + (C2_G - C1_G) * T;
                SampleB := C1_B + (C2_B - C1_B) * T;
              end
              else
              begin
                T := (P_Grad - 0.5) * 2.0;
                SampleR := C2_R + (C3_R - C2_R) * T;
                SampleG := C2_G + (C3_G - C2_G) * T;
                SampleB := C2_B + (C3_B - C2_B) * T;
              end;

              AccR := AccR + ToLinear(Round(SampleR));
              AccG := AccG + ToLinear(Round(SampleG));
              AccB := AccB + ToLinear(Round(SampleB));
              AccA := AccA + 1.0;
            end;
          end;
        end;

        if AccA > 0 then
        begin
          FinalColor.Red   := FromLinear(AccR / (SS_LEVEL * SS_LEVEL)) * 257;
          FinalColor.Green := FromLinear(AccG / (SS_LEVEL * SS_LEVEL)) * 257;
          FinalColor.Blue  := FromLinear(AccB / (SS_LEVEL * SS_LEVEL)) * 257;
          FinalColor.Alpha := Round((AccA / (SS_LEVEL * SS_LEVEL)) * 65535);

          RawImg.Colors[px, py] := FinalColor;
        end
        else
        begin
          RawImg.Colors[px, py] := colTransparent;
        end;
      end;
    end;

    Bmp := TBitmap.Create;
    try
      Bmp.LoadFromIntfImage(RawImg);
      Canvas.Draw(Round(AX), Round(AY), Bmp);
    finally
      Bmp.Free;
    end;

  finally
    RawImg.Free;
  end;
end;

initialization
  with TFileVersionInfo.Create(nil) do
  try
    ReadFileInfo;
    APP_NAME := VersionStrings.Values['ProductName'];
    APP_VERSION := VersionStrings.Values['FileVersion'];
    APP_TAGLINE := VersionStrings.Values['Comments'];
    DEV_AUTHOR := VersionStrings.Values['CompanyName'];
  finally
    Free;
  end;
  APP_ATTRIBUTION := APP_NAME + ' ' + APP_VERSION;

end.