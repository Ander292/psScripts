param (
    [string]$mode = "full"
)
# Possible modes: full, run, build

$ProjectName = "Program" # The name of the final exe file

# Directories

$RootDir            = Split-Path -Parent    $MyInvocation.MyCommand.Path

$SrcDir             = Join-Path $RootDir    "src"
$IncludeDir         = Join-Path $RootDir    "include"
#$AssetsDir          = Join-Path $RootDir    "assets"
# ResourcesDir contain the rc script and files to be embeded into the exe by the linker
$ResourceDir        = Join-Path $RootDir    "resources" 

$BuildDir           = Join-Path $RootDir    "build"
$BinDir             = Join-Path $BuildDir   "bin"
$ObjDir             = Join-Path $BuildDir   "obj"

$ResourcesObj       = Join-Path $ObjDir     "resource.obj"
$OutputExe          = Join-Path $BinDir     "$ProjectName.exe"

# Source arrays

[array]$Sources     = Get-ChildItem "$SrcDir\*.c"       | ForEach-Object { $_.FullName }

[array]$ObjC        = Get-ChildItem "$SrcDir\*.c"       | ForEach-Object { $_.BaseName + ".obj"}

[array]$Resources   = Get-ChildItem "$ResourceDir\*.rc" | ForEach-Object { $_.FullName }


#Making folders if they arent present:

New-Item -ItemType Directory -Force -Path $SrcDir       | Out-Null
New-Item -ItemType Directory -Force -Path $IncludeDir   | Out-Null
#New-Item -ItemType Directory -Force -Path $AssetsDir    | Out-Null
New-Item -ItemType Directory -Force -Path $ResourceDir  | Out-Null

New-Item -ItemType Directory -Force -Path $BuildDir     | Out-Null
New-Item -ItemType Directory -Force -Path $BinDir       | Out-Null
New-Item -ItemType Directory -Force -Path $ObjDir       | Out-Null

#Flags that are included based on which libraries are there
$IncludeFlags = @(
    "-I$IncludeDir"
)

#Flags for special libraries (if there are any)
$LibFlags = @(
)

# Flags given to the compiler
$CompilationFlags = @(
    #"-Wall"
    #"-pedantic"
    "-Wextra"
    #"-Wconversion"
    #"-Wundef"
    #"-Wstrict-overflow=5"
    "-fdiagnostics-show-option"
    #"-g"
    "-O2"
    #"-fsanitize=address"
)

# Extra flags for the linking stage
$ExtraFlags = @(
    "-pedantic"
    "-m64"
)

# Arguments given to the program on launch
$LaunchArgs = @(
    
)

if( ( $mode -eq "full" ) -OR ( $mode -eq "build" ) ){

    # Compiling c code into obj files
    Write-Host "Compiling c files..."
    $i = 0
    $Sources.ForEach({
        $CurrentObj     = Join-Path     $ObjDir  $ObjC[$i]

        gcc `
            $IncludeFlags `
            $_ `
            $CompilationFlags `
            -c `
            -o `
            $CurrentObj
        
        $i++
        if ($LASTEXITCODE -ne 0) {Write-Error "Error compiling $_"}
    })

    # Compiling resources into a windows resource file:

    Write-Host "Preparing resources..."
    windres `
        $Resources `
        -O `
        coff `
        -o `
        $ResourcesObj


    # Fetching every obj file that was produced as a result
    [array]$Objs        = Get-ChildItem "$ObjDir\*.obj"         | ForEach-Object { $_.FullName }


    # Linking stage
    Write-Host "Linking..."
    gcc `
        $Objs `
        $IncludeFlags `
        $LibFlags `
        $ExtraFlags `
        -o $OutputExe

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Compilation failed!"
        exit(1)
    }

    Write-Host "Compilation was sucessful!"

    
}

if ( ( $mode -eq "full" ) -OR ( $mode -eq "run" ) ) {
    Write-Host "Running program..."
    & $OutputExe $LaunchArgs
}