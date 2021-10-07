function Backup-Container
{
[CmdletBinding()]
param
(
	[Parameter(Mandatory=$true,Position=0,HelpMessage="Must define the docker container name" )]
	[string]$Line

)

	 $SpacePos=$Line.IndexOf(' ') # Find the first space to retrieve the ContainerID
	 $ContainerID=$Line.Substring(0,$SpacePos)
	 $SpacePos=$Line.LastIndexOf(' ') # Find the last space, where starts the container's name
	 $name=$Line.Substring($SpacePos)
	 Write-host "Backing up $name"
	 $Name=$Name.ToLower()+"bkp" # Add 'bkp' the the container's name as file name for the backup
	 $command="docker commit  $ContainerID $name" # First, create a commited version of the container
	 Invoke-Expression $command
	 $namebak="$name.tar"
	 $command="docker save -o $namebak $Name" # Then, save the commited one to disk
	 Invoke-Expression $command
}
