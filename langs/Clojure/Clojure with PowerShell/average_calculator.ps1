<#
.SYNOPSIS
    Interop sample: prints the arithmetic mean of the numbers given on the
    command line.

.DESCRIPTION
    Invoked by main.clj; see README.md for build and run instructions.
#>
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $Numbers
)

$ErrorActionPreference = 'Stop'

if (-not $Numbers -or $Numbers.Count -eq 0) {
    [Console]::Error.WriteLine('error: no numbers supplied')
    exit 1
}

$invariant = [System.Globalization.CultureInfo]::InvariantCulture

try {
    $values = @($Numbers | ForEach-Object {
        [double]::Parse($_, [System.Globalization.NumberStyles]::Float, $invariant)
    })
}
catch {
    [Console]::Error.WriteLine('error: every argument must be a number')
    exit 1
}

$sum = ($values | Measure-Object -Sum).Sum
$average = $sum / $values.Count

# Format invariantly so the decimal separator does not depend on the host locale.
$average.ToString('F2', $invariant)
