Import-Module ActiveDirectory
 
Get-ADComputer -SearchBase 'OU=,dc=,dc=' -Filter '*'  | Select -Exp name | Add-Content <path_to_text_file> 


Get-ADComputer -SearchBase 'OU=,dc=,dc=' -Filter '*'   | Select -Exp name| Add-Content <path_to_text_file> 

$computername = Get-Content <path_to_text_file> 
$collection = @()
foreach ($computer in $computername)
{
    $status = @{ "ComputerName" = $computer}
    if (Test-Connection -Computername $computer -Count 2 -ea 0 -Quiet)

    {
        $status["Results"] = "Up"
    }
    else
    {
        $status["Results"] = "Down"
    }

    New-Object -TypeName PSObject -Property $status -OutVariable compStatus
    $collection += $compStatus

}
Get-Content <path_to_text_file>  \Comp_test_Status.csv | `
   Select-Object @{Name='ComputerName';Expression={$_}},@{Name='FolderExist';Expression={ Test-Path "<json_path>"}}

$ErrorLog = "<output_log>"
$ErrorActionPreference="stop"
$i=1
$path= Read-Host -Prompt 'Please provide complete path for your computer list'
Foreach ($computer in Get-Content $path){
    try{
        Copy-Item -Path \\$computer\c$\<test_path> -Force -Destination <output_path>\$i.json 
        }
    
    catch{
        $e = $_.Exception
$msg = $e.Message
while ($e.InnerException) {
  $e = $e.InnerException
  $msg += "`n" + $e.Message
}
$msg
    }
        
    finally {
        if (Test-path <output_path>\$i.json ){
        Write-Host 'Success Message:Json file found for' $computer -ForegroundColor DarkGreen
		Write-Output "Success Message:Json file found for $computer" >> $ErrorLog
		}
		else{ 
		    Write-Host 'ERROR message: Cannot find' $computer -ForegroundColor DarkRed 
			Write-Output "Error  reported for $computer : $msg" >> $ErrorLog

		}
        
    }
    $i++
}
$env:Path="$env:Path;C:\Python34"
Invoke-Command -ScriptBlock {python.exe '<parse_t_path>.py'}

	

