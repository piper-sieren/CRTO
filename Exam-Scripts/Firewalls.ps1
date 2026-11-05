# Function to enumerate blocked firewall rules
function Get-BlockedFirewallRules {
    # Get blocked inbound rules
    $blockedInboundRules = Get-NetFirewallRule -Direction Inbound -Action Block -Enabled True | 
                           Select-Object DisplayName, Name, Direction, Action, Enabled, Profile, @{Name='Ports';Expression={($_ | Get-NetFirewallPortFilter).LocalPort}}

    # Get blocked outbound rules
    $blockedOutboundRules = Get-NetFirewallRule -Direction Outbound -Action Block -Enabled True | 
                            Select-Object DisplayName, Name, Direction, Action, Enabled, Profile, @{Name='Ports';Expression={($_ | Get-NetFirewallPortFilter).LocalPort}}

    # Display blocked inbound rules
    if ($blockedInboundRules) {
        Write-Output "Blocked Inbound Firewall Rules:"
        $blockedInboundRules | Format-Table -AutoSize
    } else {
        Write-Output "No blocked inbound firewall rules found."
    }

    Write-Output ""

    # Display blocked outbound rules
    if ($blockedOutboundRules) {
        Write-Output "Blocked Outbound Firewall Rules:"
        $blockedOutboundRules | Format-Table -AutoSize
    } else {
        Write-Output "No blocked outbound firewall rules found."
    }
}

# Run the function
Get-BlockedFirewallRules