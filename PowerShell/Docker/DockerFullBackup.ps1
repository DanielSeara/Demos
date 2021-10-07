Import-Module -Name D:\Desarrollos\PowerShell\Docker\DockerLib.psm1
d:
cd D:\Desarrollos\Docker\Backup
# Look for Docker Desktop instance
$DockerProcesses=Get-Process|Where-Object {$_.ProcessName -eq 'Docker Desktop'}
if($DockerProcesses.count -eq 0) #If there is no instance, try to start it
{
    $command="C:\Program Files\Docker\Docker\Docker Desktop.exe"
    Invoke-Expression "& '$command'"
    while($DockerProcesses.count -eq 0) #Whait for an instance
    {
        Start-Sleep -Seconds 120
        $DockerProcesses=Get-Process|Where-Object {$_.ProcessName -eq 'Docker Desktop'}
    }
}
$Result=docker ps -a
for($i=1;$i -lt $result.count;$i++)
{

    Backup-Container $result[$i]
}
