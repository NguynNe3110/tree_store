$root = "D:\AppData\Code\Project\Android\tree_store\kotlin_backend"
Get-ChildItem -Path $root -Recurse -File -Include *.kt,*.conf,*.properties,*.kts | ForEach-Object {
    $lines = [System.IO.File]::ReadAllLines($_.FullName)
    $clean = $lines | Where-Object { $_ -notmatch '<(/?)parameter' }
    if ($lines.Count -ne $clean.Count) {
        [System.IO.File]::WriteAllText($_.FullName, ($clean -join "`r`n"), [System.Text.UTF8Encoding]::new($false))
        Write-Host "Stripped: $($_.FullName)"
    }
}
Write-Host "Done"
</parameter>
<parameter name="isBlocking">false