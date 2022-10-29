unit PlgTypes;

Interface

Type
    TPluginInfo = record
      Version: PChar;
      FType: PChar;
    end;

    string80 = string[80];
    LongWord = Cardinal;
(*    LongWord = Comp; {Cardinal;}
    TDateTime = double;*)

    PUniFile = ^TUniFile;
    TUniFile = packed record
      isText: boolean;
      F: File;
      T: Text;
    end;

    PCallRec = ^TCallRec;
    TCallRec = record
      Date: TDateTime;
      TelNo: LongWord;
      Time: word;
    end;

    TplugInfoProc = procedure (var Info: TPluginInfo); stdcall;

Implementation

end.
