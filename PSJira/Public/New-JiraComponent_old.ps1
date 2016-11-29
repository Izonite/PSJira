function New-JiraComponent
{
    <#
    .Synopsis
       Creates a new component in a JIRA Project
    .DESCRIPTION
       Created by Izonite - based on New-JiraGroup.ps1
    .EXAMPLE
       New-JiraComponent -ProjectDest NEWPROJ -ComponentToAdd $PSJira.Component

       ####### TODO


    .INPUTS
       [PSJira.Component]
    .OUTPUTS
       ####### TODO
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String] $ProjectDest,

        [Parameter(Mandatory = $true)]
        [Object] $ComponentToAdd,

        [Parameter(Mandatory = $false)]
        [PSCredential] $Credential
    )

    begin
    {

#        $DebugPreference="Continue"

        Write-Debug "[New-JiraComponent] Reading information from config file"
        try
        {
            Write-Debug "[New-JiraComponent] Reading Jira server from config file"
            $server = Get-JiraConfigServer -ConfigFile $ConfigFile -ErrorAction Stop
        } catch {
            $err = $_
            Write-Debug "[New-JiraComponent] Encountered an error reading configuration data."
            throw $err
        }

        Write-Debug "[New-JiraComponent] Building URI for REST call"
        $restUrl = "$server/rest/api/latest/component"

        #check if target project exists
        Write-Debug "[New-JiraComponent] Obtaining a reference to Jira project [$ProjectDest]"
        $ProjectObj = Get-JiraProject -Project $ProjectDest -Credential $Credential
        if (-not ($ProjectObj))
        {
            throw "Unable to identify Jira project [$ProjectDest]. Use Get-JiraProject for more information."
        }

    }

    process
    {
        Write-Debug "[New-JiraComponent] Defining properties"
        $props = @{
            'name' = $ComponentToAdd.name;
            'description' = $ComponentToAdd.description;
            'assigneeType' = $ComponentToAdd.assigneeType;
            'isAssigneeTypeValid' = $ComponentToAdd.isAssigneeTypeValid;
            'project' = $ProjectDest;
        }

        if ($ComponentToAdd.lead)
            {
                $props.leadUserName = ($ComponentToAdd.lead).Name
            }


        Write-Debug "[New-JiraComponent] Converting to JSON"
        $json = ConvertTo-Json -InputObject $props

        Write-Debug "[New-JiraComponent] view JSON"
        Write-Output $json

        Write-Debug "[New-JiraComponent] Preparing for blastoff!"
        $result = Invoke-JiraMethod -Method Post -URI $restUrl -Body $json -Credential $Credential

        if ($result)
        {
            Write-Debug "[New-JiraComponent] Converting output object into a Jira object and outputting"
            Write-Debug "--- TODO---"
            #ConvertTo-JiraGroup -InputObject $result
        } else {
            Write-Debug "[New-JiraComponent] Jira returned no results to output."
        }



    }
}
