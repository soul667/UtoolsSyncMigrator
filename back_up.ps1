# 获取当前脚本路径
$currentScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$tempBackupPath = Join-Path $currentScriptPath 'Temp'

# 获取当前用户的主目录路径
$userHomePath = [System.Environment]::GetFolderPath('UserProfile')

# 定义目标路径并替换用户目录
$targetPaths = @(
    (Join-Path $userHomePath "AppData\Local\Temp\utools-icons"),
    (Join-Path $userHomePath "AppData\Roaming\uTools"),
    (Join-Path $userHomePath "AppData\Roaming\uTools\Partitions\%3Cutools%3E")
)

# 创建log文件夹和log文件路径
$logFolderPath = Join-Path $currentScriptPath 'log'
if (-Not (Test-Path -Path $logFolderPath)) {
    New-Item -ItemType Directory -Path $logFolderPath | Out-Null
}
$logFilePath = Join-Path $logFolderPath "backup_log_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"
# 创建$logFilePath文件
New-Item -ItemType File -Path $logFilePath | Out-Null

# Helper function to log messages with timestamp
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$timestamp - $message" | Tee-Object -FilePath $logFilePath -Append
}

# 如果utools进程在运行，关闭进程
$utoolsProcess = Get-Process -Name "utools" -ErrorAction SilentlyContinue
if ($utoolsProcess) {
    Stop-Process -Name "utools" -Force
    Log-Message "uTools process stopped."
}

# 遍历当前路径下的所有文件夹
$foldersToSync = Get-ChildItem -Path $currentScriptPath -Directory

$timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
$tempPath = Join-Path -Path $currentScriptPath -ChildPath "beifen_$timestamp"
if (-Not (Test-Path -Path $tempPath)) {
    New-Item -ItemType Directory -Path $tempPath | Out-Null
    Log-Message "Create a backup folder"
}
Log-Message "------------START BACKUP----------------"

foreach ($targetPath in $targetPaths) {
    $leafPath = Split-Path $targetPath -Leaf
    $folderPath = Join-Path -Path $currentScriptPath -ChildPath $leafPath

    if (Test-Path -Path $targetPath) {
        $backupZipPath = Join-Path -Path $tempPath -ChildPath "$($leafPath)"
        if (-Not (Test-Path -Path $backupZipPath)) {
            New-Item -ItemType Directory -Path $backupZipPath | Out-Null
        }
        Log-Message "Backing up $targetPath to $backupZipPath"
        Copy-Item -Path "$targetPath\*" -Destination $backupZipPath -Recurse
    }
}

$tempPath_zip = Join-Path -Path $currentScriptPath -ChildPath "beifen_$timestamp.zip"
Compress-Archive -Path "$tempPath\*" -DestinationPath $tempPath_zip
Remove-Item -Path $tempPath -Recurse -Force
Log-Message "Temporary backup folder and its contents have been deleted."
