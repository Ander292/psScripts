param (
    [string]$file = "",
    [int]$keepLog = 0,
    [int]$timeout = 10
)
$RootDir = $PWD

. watchFile.ps1

$logPath = "out.txt"
$programName = (Get-Command -name dosbox-x).path
$dosDir = [System.IO.Path]::GetDirectoryName($programName)

if ($file -eq "") {
    Write-Host "Invalid input"
    exit(1)
}

$mountDir = [System.IO.Path]::GetDirectoryName("$RootDir\$file")
$fName = [System.IO.Path]::GetFileName("$file")

# Here you can add stuff that dos will execute on launch (keyb yu for example)
$prep = "mount C `"$dosDir\drivec`"
C:
SET PATH=%PATH%;C:\TASM\BIN
KEYB yu
mount F `"$mountDir`""

$argsR = "F:\$fName"

#echo "Output:" > "$mountDir\$logPath"
"Output:" | Out-File -FilePath "$mountDir\$logPath" -Encoding utf8

$env:SDL_VIDEODRIVER = "dummy"
&$programName -noautoexec `
-c "$prep" `
-c "$argsR >> `"F:\$logPath`"" `
-c "echo __END__ >> `"F:\$logPath`"" `
-c "exit"
Remove-Item Env:\SDL_VIDEODRIVER

Watch-File -Path "$mountDir\$logPath" -StopToken "__END__" -IdleTimeoutSeconds $timeout

if($keepLog -eq 0) {
    Remove-Item -Path "$mountDir\$logPath"
}