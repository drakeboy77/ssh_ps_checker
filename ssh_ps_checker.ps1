#requires Posh-SSH to be installed from PS Gallery

$User         = "admin"
$2User        = "root"
$1Password    = "password"
$2Password    = "password"
$3Password    = "password"
$4Password    = "password"
$5password    = "password"
$6password    = "password"
$1secpasswd    = ConvertTo-SecureString $1Password -AsPlainText -Force
$2secpasswd   = ConvertTo-SecureString $2Password -AsPlainText -Force

$IP=@("10.10.0.1", "10.10.200.50", "192.168.33.5")

foreach ($item in $IP) 
{
    try {
        # try the first credentials
        Write-Host $User, $1secpasswd
        $Credentials = New-Object System.Management.Automation.PSCredential($User, $1secpasswd)
        Write-Host $Credentials
        $SessionID = New-SSHSession -ComputerName $item -Credential $Credentials -AcceptKey:$true -Verbose -ErrorAction Stop
    } 
    catch [Renci.SshNet.Common.SshAuthenticationException]{
        # first one failed, try second credentials
        try {
            Write-Host "2nd try..."
            $sCredentials = New-Object System.Management.Automation.PSCredential($User, $2secpasswd)
            $SessionID = New-SSHSession -ComputerName $item  -Credential $sCredentials -AcceptKey:$true -Verbose -ErrorAction Stop
        }
        catch [Renci.SshNet.Common.SshAuthenticationException] {
            try {
                Write-Host "3rd try..."
                $sCredentials = New-Object System.Management.Automation.PSCredential($2User, $1secpasswd)
                $SessionID = New-SSHSession -ComputerName $item  -Credential $sCredentials -AcceptKey:$true -Verbose -ErrorAction Stop
            }
            catch [Renci.SshNet.Common.SshAuthenticationException] {
                try {
                    Write-Host "4th try..."
                    $sCredentials = New-Object System.Management.Automation.PSCredential($2User, $2secpasswd)
                    $SessionID = New-SSHSession -ComputerName $item  -Credential $sCredentials -AcceptKey:$true -Verbose -ErrorAction Stop
                } 
                catch [Renci.SshNet.Common.SshAuthenticationException] {
                        Write-Host "Out of username/pw combinations, attempt has failed for $item"
                }
            }
        }
    }
    catch [Renci.SshNet.Common.SshOperationTimeoutException] {
        Write-Host "Timeout catch in effect for IP $item , determining to be unreachable by standard SSH"
        Write-Host "An error occurred:"
        Write-Host $_
    }
    catch [System.Net.Sockets.SocketException] {
        Write-Host "Machine actively refused SSH for IP $item"
    }
    catch {
        Write-Host "Dang, Catch-all hit for IP $item"
        Write-Host "An error occurred:"
        Write-Host $_
    }
}