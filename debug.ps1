param (
    [string]$file = ""
)

if( $file -eq "" ) {
    Write-Host "Invalid input"
    exit(1)
}

$RootDir = $PWD
$programName = (Get-Command -name dosbox-x).path

if ($programName -eq "") {
    Write-Host "Dosbox not found"
    exit(1)
}

$dosDir = [System.IO.Path]::GetDirectoryName($programName)

$mountDir = [System.IO.Path]::GetDirectoryName("$RootDir\$file")
$fName = [System.IO.Path]::GetFileName("$file")
$fSrc = [System.IO.Path]::GetFileNameWithoutExtension("$file") + ".asm"

# Here you can add stuff that dos will execute on launch (keyb yu for example)
$prep = "mount C `"$dosDir\drivec`"
C:
SET PATH=%PATH%;C:\TASM\BIN
KEYB yu
mount F `"$mountDir`""

$dosDebugDir = "C:\DEBUGING"

$argsC = "mkdir `"$dosDebugDir`"
cd `"$dosDebugDir`"
copy `"F:\$fName $dosDebugDir\`"
copy `"F:\$fSrc $dosDebugDir`""

$argsR = "td C:\DEBUGING\$fName"

Remove-Item Env:\SDL_VIDEODRIVER 2> NUL > NUL
&$programName -noautoexec `
-c "$prep" `
-c "$argsC" `
-c "$argsR" `
-c "exit"