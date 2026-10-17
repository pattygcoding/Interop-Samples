<#
.SYNOPSIS
    Interop sample: PowerShell driving a compiled V program.

.DESCRIPTION
    PowerShell passes the numbers as command-line arguments to the V helper and
    reads the average it prints back from stdout.

    See README.md for build and run instructions.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $Numbers
)

$ErrorActionPreference = 'Stop'

$invariant = [System.Globalization.CultureInfo]::InvariantCulture
$extension = if ($env:OS -eq 'Windows_NT') { '.exe' } else { '' }
$executable = Join-Path $PSScriptRoot "average_calculator$extension"

if (-not $Numbers -or $Numbers.Count -eq 0) {
    $Numbers = @('10', '20', '30', '40', '50')
}

$values = @()

foreach ($number in $Numbers) {
    $value = 0.0
    $styles = [System.Globalization.NumberStyles]::Float

    if ([double]::TryParse($number, $styles, $invariant, [ref] $value)) {
        $values += $value
    }
    else {
        Write-Warning "skipping non-numeric argument '$number'"
    }
}

if ($values.Count -eq 0) {
    [Console]::Error.WriteLine('error: no numbers to average')
    exit 1
}

$arguments = $values | ForEach-Object { $_.ToString($invariant) }
$output = & $executable $arguments

if ($LASTEXITCODE -ne 0) {
    [Console]::Error.WriteLine("error: the V helper exited with code $LASTEXITCODE")
    exit 1
}

$average = [double]::Parse(($output | Select-Object -First 1), $invariant)

'The average of {0} value(s) is: {1}' -f $values.Count, $average.ToString('F2', $invariant)
