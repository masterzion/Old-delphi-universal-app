unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
    function GetSerialNumber:String;

        function DecToHex( aValue : LongInt ) : String;
            function HexByte( b : Byte ) : String;
              const
                Hex : Array[ $0..$F ] Of Char = '0123456789ABCDEF';
            begin
                HexByte := Hex[ b Shr 4 ] + Hex[ b And $F ];
            end;

            function HexWord( w : Word ) : String;
            begin
                HexWord := HexByte( Hi( w ) ) + HexByte( Lo( w ) );
            end;

        var
            w : Array[ 1..2 ] Of Word Absolute aValue;
        begin
            Result := HexWord( w[ 2 ] ) + HexWord( w[ 1 ] );
        end;


      var
        VolumeLabel, FileSystem : Array[ 0..$FF ] Of Char;
        SerialNumber, Comps, SysFlags : cardinal;
    begin
       GetVolumeInformation( PChar( 'C:\' ), VolumeLabel, SizeOf( VolumeLabel ), @SerialNumber, Comps, SysFlags, FileSystem, SizeOf( FileSystem ) );
       Result := DecToHex( SerialNumber );
    end;

begin
  Edit1.Text := GetSerialNumber;
end;

end.
