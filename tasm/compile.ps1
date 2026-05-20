param (
    [string]$file = "",
    [string]$out = $null,
    [int]$keepLog = 0,
    [int]$timeout = 10
)

$RootDir = $PWD

. $PSScriptRoot/watchFile.ps1

$logPath = "out.txt"
$programName = (Get-Command -name dosbox-x).path

if ($programName -eq "") {
    Write-Host "Dosbox not found"
    exit(1)
}

$dosDir = [System.IO.Path]::GetDirectoryName($programName)

if ($file -eq "") {
    Write-Host "Invalid input"
    exit(1)
}

if($file[1] -ne ':'){
    $file = "$RootDir\$file"
}

$mountInDir = [System.IO.Path]::GetDirectoryName("$file")

if (($out -eq $null) -OR ($out -eq "")) {
    $out = $mountInDir
    Write-Host "I tried $out"
}
else{
    if($out[1] -ne ':'){
        $out = "$RootDir\$out"
    }
}


#$mountOutDir = [System.IO.Path]::GetDirectoryName("$out")
$mountOutDir = $out

$inFname = [System.IO.Path]::GetFileName("$file")
$outBase = [System.IO.Path]::GetFileNameWithoutExtension("$file")
$outFname =  $outBase + ".obj"

# Here you can add stuff that dos will execute on launch (keyb yu for example)
$prep = "mount C `"$dosDir\drivec`"
C:
SET PATH=%PATH%;C:\TASM\BIN
KEYB yu
mount E `"$mountInDir`"
mount F `"$mountOutDir`""

$argsA = "TASM `"E:\$inFname`" /zi -o `"F:\$outFname`""
$argsL = "TLINK /x /v F:\$outFname,F:\$outBase.exe"

#echo "Output:" > "$MountOutDir\$logPath"
"Output:" | Out-File -FilePath "$MountOutDir\$logPath" -Encoding utf8

$env:SDL_VIDEODRIVER = "dummy"
&$programName -noautoexec `
-c "$prep" `
-c "echo Assembling file E:\$inFname >> F:\$logPath" `
-c "$argsA >> F:\$logPath" `
-c "echo Linking file F:\$outFname >> F:\$logPath" `
-c "$argsL >> F:\$logPath" `
-c "echo Output: F:\$outBase.exe >> F:\$logPath" `
-c "del F:\$outFname >> F:\$logPath" `
-c "echo __END__ >> F:\$logPath" `
-c "exit"
Remove-Item Env:\SDL_VIDEODRIVER

#Get-Content -Path "$MountOutDir\$logPath" -Wait -Tail 10
Watch-File -Path "$MountOutDir\$logPath" -StopToken "__END__" -IdleTimeoutSeconds $timeout

if($keepLog -eq 0) {
    Remove-Item -Path "$MountOutDir\$logPath"
}