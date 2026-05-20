#########################################################
##### Outputs the file contents to stdout until the #####
##### stopwatch reaches IdleTimeoutSeconds or until #####
##### it encounters __END__ token                   #####
#########################################################

function Watch-File {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [string]$StopToken = $null,
        [int]$IdleTimeoutSeconds = 10
    )

    $fullPath = Resolve-Path $Path -ErrorAction Stop | Select-Object -ExpandProperty Path
    $fs = [System.IO.File]::Open($fullPath, [System.IO.FileMode]::Open, 
        [System.IO.FileAccess]::Read,
        [System.IO.FileShare]::ReadWrite)

    try {
        $reader = New-Object System.IO.StreamReader($fs)
        $buffer = ""
        $idleStopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        $lastLength = $fs.Length

        while ($true) {
            $newData = $reader.ReadToEnd()
            if ($newData) {
                $idleStopwatch.Restart()
                $lastLength = $fs.Length
                $text = $buffer + $newData
                $buffer = ""

                if ($StopToken -and $text.Contains($StopToken)) {
                    $parts = $text.Split($StopToken, 2)
                    Write-Host $parts[0] -NoNewline
                    break
                }
                else {
                    if ($StopToken) {
                        $overlap = [Math]::Min($text.Length, $StopToken.Length)
                        $possibleTail = $text.Substring($text.Length - $overlap)
                        $keepLen = 0
                        for ($i = 1; $i -le $overlap; $i++) {
                            if ($StopToken.StartsWith($possibleTail.Substring($overlap - $i))) {
                                $keepLen = $i
                            }
                        }
                        if ($keepLen -gt 0) {
                            $buffer = $possibleTail.Substring($overlap - $keepLen)
                            $text = $text.Substring(0, $text.Length - $keepLen)
                        }
                    }
                    Write-Host $text -NoNewline
                }
            }

            if ($idleStopwatch.Elapsed.TotalSeconds -ge $IdleTimeoutSeconds) {
                break
            }

            Start-Sleep -Milliseconds 100 # I feel sleepy
        }
    }
    finally {
        $reader.Dispose()
        $fs.Dispose()
    }
}