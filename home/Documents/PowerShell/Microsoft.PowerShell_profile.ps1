# Minimal profile: UTF‑8 + Oh My Posh (if installed) + Fastfetch with explicit config path
# Force Fastfetch to use YOUR config every time (bypass path confusion)
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    fastfetch -c "C:/Users/user/.config/fastfetch/config.jsonc"
}
Invoke-Expression (& starship init powershell)

try {
    $ENV:Path += ";$ENV:UserProfile\bin"
    $ENV:EDITOR = "code-insiders"
    $ENV:XDG_CONFIG_HOME = "C:\Users\user\.config"
} catch {
    Write-Host "Error setting environment variables: $_"
}
try {
    Set-Alias -Name g -Value git -Force
} catch {
    Write-Host "Error setting alias g: $_"
}
try {
    Set-Alias -Name vim -Value nvim -Force
} catch {
    Write-Host "Error setting alias vim: $_"
}

# Use bash-like keybindings
Set-PSReadLineKeyHandler -Chord Ctrl-a -Function BeginningOfLine
Set-PSReadLineKeyHandler -Chord Ctrl-e -Function EndOfLine
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
