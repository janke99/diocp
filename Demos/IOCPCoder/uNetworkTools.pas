unit uNetworkTools;

interface

uses
  JwaWinsock2;



type
  //from indy
  TInt64Parts = packed record
    case Integer of
    0: (
       {$IFDEF ENDIAN_BIG}
      HighPart: LongWord;
      LowPart: LongWord);
       {$ELSE}
      LowPart: LongWord;
      HighPart: LongWord);
      {$ENDIF}
    1: (
      QuadPart: Int64);
  end;

  TBytes = array of Byte;

  TNetworkTools = class(TObject)
  public
    class function htonl(v: LongWord): LongWord; overload;

    class function htonl(v:Int64): Int64; overload;

    class function ntohl(v: LongWord): LongWord;overload;

    class function htonl(v: Integer): Integer; overload;

    class function ntohl(v: Integer): Integer; overload;

    class function ansiString2Utf8Bytes(v:string): TBytes;

    class function Utf8Bytes2AnsiString(pvData:TBytes): String;

  end;

implementation


class function TNetworkTools.ansiString2Utf8Bytes(v:string): TBytes;
var
  lvTemp:String;
begin
  lvTemp := AnsiToUtf8(v);
  SetLength(Result, Length(lvTemp));
  Move(lvTemp[1], Result[0],  Length(lvTemp));
end;

class function TNetworkTools.Utf8Bytes2AnsiString(pvData:TBytes): String;
var
  lvTemp:String;
begin
  SetLength(lvTemp, Length(pvData));
  Move(pvData[0], lvTemp[1],  Length(pvData));
  Result := Utf8ToAnsi(lvTemp);
end;

class function TNetworkTools.htonl(v:Int64): Int64;
var
  LParts: TInt64Parts;
  L: LongWord;
begin
  LParts.QuadPart := v;
  L := JwaWinsock2.htonl(LParts.HighPart);
  LParts.HighPart := JwaWinsock2.htonl(LParts.LowPart);
  LParts.LowPart := L;
  Result := LParts.QuadPart;
end;

class function TNetworkTools.htonl(v: LongWord): LongWord;
begin
  Result := JwaWinsock2.htonl(v);
end;

class function TNetworkTools.htonl(v: Integer): Integer;
begin
  Result := Integer(htonl(LongWord(v)));
end;

class function TNetworkTools.ntohl(v: LongWord): LongWord;
begin
  Result := JwaWinsock2.ntohl(v);
end;

class function TNetworkTools.ntohl(v: Integer): Integer;
begin
  Result := Integer(ntohl(LongWord(v)));
end;



end.