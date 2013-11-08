unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DBXpress, FMTBcd, DB, SqlExpr, DCPcrypt2, DCPrc4,
  DCPmd5, IniFiles, ComCtrls;

const
   AppName    : string = 'Cadastral';
   AppEdition : string = 'Corporate Edition';

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    DCP_rc4: TDCP_rc4;
    SQLConnection1: TSQLConnection;
    SQLDataSet: TSQLDataSet;
    ProgressBar1: TProgressBar;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    PalavraChave : String;
    procedure CarregaConfig;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


procedure TForm1.FormCreate(Sender: TObject);
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

    function RetornaHashString(InArray: array of byte):String;
    var
      n : Integer;
      s : string ;
    begin
      for n := 0 to Length(InArray) - 1 do s := s + IntToHex(InArray[n],2);
      Result := s;
    end;
{
var
  Buffer: array of byte;
  s: string;
  Digest: array[0..16] of byte;}
  //128 (MD5) bit div 8
begin
{  s:= GetSerialNumber;
  DCP_md5.Init;
  DCP_md5.Update(Buffer,Sizeof(Buffer));
  DCP_md5.UpdateStr(s);
  DCP_md5.Final(Digest);

  Edit1.Text := RetornaHashString(Digest);}
  PalavraChave :=    AppName    +AppEdition;

  Edit1.Text := GetSerialNumber;
end;


procedure TForm1.CarregaConfig;
var
 Ini       : TIniFile;
 strParams : TStringList;
 nIdioma   : Integer;
 sTemp     : string;
begin
  Ini := TIniFile.Create   ('mzconfig.ini');


  strParams := TStringList.Create;
  SQLConnection1.ConnectionName := Application.Name;
  sTemp := Ini.ReadString('db', 'DriverName', 'MySQL');
  with strParams do begin
    Add('DriverName'+'='+ sTemp );
    Add('HostName'+'='+   Ini.ReadString('db', 'HostName',   'localhost') );
    Add('Database'+'='+   Ini.ReadString('db', 'Database',   'cadastro') );
    Add('User_Name'+'='+  Ini.ReadString('db', 'User_Name',  'root') );
    Add('Password'+'='+'root');
    Add('BlobSize=-1');
    Add('ErrorResourceFile=./DbxMySqlErr.msg');
    Add('LocaleCode=0000');
  end;

  SQLConnection1.Params.Text :=  strParams.Text;
  strParams.Destroy;
  SQLConnection1.DriverName := Stemp;

  if uppercase(sTemp) = 'MYSQL'     then begin
        SQLConnection1.LibraryName   := 'dbexpmysql.dll';
        SQLConnection1.GetDriverFunc := 'getSQLDriverMYSQL';
        SQLConnection1.VendorLib     := 'libmysql.dll';
  end;


  nIdioma := Ini.ReadInteger('Aparencia', 'Idioma', 0);
  sTemp   := Ini.ReadString ('Aparencia', 'WallPaper', '');



  Ini.Free;
end;




procedure TForm1.Button1Click(Sender: TObject);

    function Codificar(const Texto:string; chave:string):string;
    begin
      DCP_RC4.InitStr(chave, TDCP_md5);
      Result := DCP_RC4.EncryptString(Texto);
      DCP_RC4.Burn;
    end;

    function DesCodificar(const Texto:string; chave:string):string;
    begin
      Result := '';
      DCP_RC4.InitStr(chave, TDCP_MD5);
      Result := DCP_RC4.DecryptString(Texto);
      DCP_RC4.Burn;
    end;


var
  n: Integer;
  sTemp, sResultado : String;
  Memo : TStringList;
  nMax : Integer;
begin
   Button1.Enabled := False;
   CarregaConfig;
   Memo := TStringList.Create;
   ProgressBar1.Max := 4;
   ProgressBar1.Position := 0;

   SQLDataSet.CommandText := 'select count(*) contagem from  tbForm';
   SQLDataSet.Open;
   nMax := SQLDataSet.FieldByName('contagem').AsInteger;
   SQLDataSet.Close;



   for n := 1 to nMax do begin

      if Memo <> nil then begin
         SQLDataSet.CommandText := 'select sCampos from  tbForm  where nIDForm = '+Inttostr(n);
         SQLDataSet.Open;
         sTemp := SQLDataSet.FieldByName('sCampos').AsString;
         SQLDataSet.Close;

         sResultado := Codificar(sTemp, Edit1.Text);
         Sleep(500);
         SQLDataSet.CommandText := 'update tbForm set sCampos = "'+sResultado+'" where nIDForm = '+Inttostr(n);
         SQLDataSet.ExecSQL;
         Memo.Text := sResultado;
         ProgressBar1.Position := n;
      end;

   end;
end;

end.
