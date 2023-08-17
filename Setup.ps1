<# 	
	Install Canon Print driver for Canon Color ImageCLASS MF644Cdw for use in main office
	Installer le pilote d'impression Canon pour l'imprimante Canon Color ImageCLASS MF644Cdw pour utilisation dans le bureau principal
	
	Vous pouvez reutiliser ce script en modifiant le corps principal pour invoquer et installer un autre fichier INF
	You can reuse this script by modifying the main body to invoke and install another INF file
	
	2023-08-16
#>

function Install-Driver {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)][String] $InfName,
		[Parameter(Mandatory)][String] $InfPath,
		[Parameter(Mandatory)][String] $DriverName,
		[Parameter(Mandatory)][String] $IpAddress,
		[Parameter(Mandatory)][String] $PortName,
		[Parameter(Mandatory)][String] $PrinterName
	)
	process {
		Set-Location $PSScriptRoot
		
		C:\Windows\SysNative\pnputil.exe /add-driver "$PSScriptRoot\$InfName"
		Add-PrinterDriver -Name $DriverName -InfPath $InfPath
		Add-PrinterPort -Name $PortName -PrinterHostAddress $IpAddress
		Add-Printer -Name $PrinterName -DriverName $DriverName -PortName $PortName
		# Create registry key for detection of installation
		if (!(Test-Path "HKLM:\SOFTWARE\CompanyName")) {
			New-Item -Path "HKLM:\SOFTWARE\CompanyName"
		}
		if (!(Test-Path "HKLM:\SOFTWARE\CompanyName\CanonPrinterCvd")) {
			New-Item -Path "HKLM:\SOFTWARE\CompanyName\CanonPrinterCvd"
		}
		Write-Host "Installed!"
	}
}
function Uninstall-Driver {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)][String] $InfName,
		[Parameter(Mandatory)][String] $PrinterName,
		[Parameter(Mandatory)][String] $PortName,
		[Parameter(Mandatory)][String] $DriverName
	)
	process {
		Set-Location $PSScriptRoot
		
		Remove-Printer -Name $PrinterName
		Remove-PrinterPort -Name $PortName
		Remove-PrinterDriver -Name $DriverName
		C:\Windows\SysNative\pnputil.exe /delete-driver "$InfName"
		# Remove registry key used for detection of installation
		# Supprimer cle de registre utilise pour la detection de l'installation
		if (Test-Path "HKLM:\SOFTWARE\CompanyName\CanonPrinterCvd") {
			Remove-Item -Path "HKLM:\SOFTWARE\CompanyName\CanonPrinterCvd" -Force
		}
		
		Write-Host "Uninstalled!"
	}
}

# Main body / corps principal

if ($args[0] -eq "/i") {
	Install-Driver -InfName "CNLB0MA64.INF" -InfPath "$Env:SystemRoot\System32\DriverStore\FileRepository\cnlb0ma64.inf_amd64_d4f4062dad259878\CNLB0MA64.INF" -DriverName "Canon Generic Plus UFR II V250" -IpAddress "192.168.1.102" -PortName "CAN_PP" -PrinterName "Canon Printer PP"
} elseif ($args[0] -eq "/x") {
	# Uninstall-Driver -InfName "CNLB0MA64.INF" -PrinterName "Canon Printer PP" -PortName "CAN_PP" -DriverName "Canon Generic Plus UFR II V250"
 # Does not work for this driver, it creates a separate OEM INF system-specific that need to track - todo
}