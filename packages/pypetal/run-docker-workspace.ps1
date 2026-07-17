param (
    # Accept the path as the first argument
    [Parameter(Mandatory=$true, HelpMessage="Specify the path to the working directory")]
    [string]$TargetDir
)

# Convert to an absolute path (in case a relative path like "." or "..\folder" is provided)
$AbsolutePath = (Resolve-Path $TargetDir).Path

# Important: Remove the trailing backslash if present.
# Otherwise, Docker might escape the closing quote and break the volume mount.
$CleanPath = $AbsolutePath.TrimEnd('\')

# Format the volume mount string
$VolumeMount = "${CleanPath}:/workspace"

Write-Host "Starting container. Working directory: $CleanPath" -ForegroundColor Green

# Run Docker (headless — no X11 DISPLAY needed; pyPETaL writes plots/results to files)
docker run -it --rm -v $VolumeMount -w /workspace py310-ptl:latest
