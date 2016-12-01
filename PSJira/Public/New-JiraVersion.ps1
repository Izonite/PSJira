function New-JiraVersion
{
    <#
    .Synopsis
       Creates a new Version in JIRA
    .DESCRIPTION
       This function creates a new Version in a JIRA project.
       Created by Izonite
    .EXAMPLE
       New-JiraVersion -Project PRJKEY -VersionName "Name of version" -VersionDescription "Description of version"
       This example creates a new version in the project PRJKEY with the given properties...
    .INPUTS
       This function does not accept pipeline input.
    .OUTPUTS
       [PSJira.Version] The user object created
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String] $Project,

        [Parameter(Mandatory = $true)]
        [String] $VersionName,

        [Parameter(Mandatory = $false)]
        [String] $VersionDescription,

        [Parameter(Mandatory = $false)]
        [PSCredential] $Credential
    )

    begin
    {
        Write-Debug "[New-JiraVersion] Reading information from config file"
        try
        {
            Write-Debug "[New-JiraVersion] Reading Jira server from config file"
            $server = Get-JiraConfigServer -ConfigFile $ConfigFile -ErrorAction Stop
        } catch {
            $err = $_
            Write-Debug "[New-JiraVersion] Encountered an error reading configuration data."
            throw $err
        }

        $restUrl = "$server/rest/api/latest/version"

        Write-Debug "[New-JiraVersion] Obtaining a reference to Jira project [$Project]"
        $ProjectObj = Get-JiraProject -Project $Project -Credential $Credential
        if (-not ($ProjectObj))
        {
            throw "Unable to identify Jira project [$Project]. Use Get-JiraProject for more information."
        }

    }

    process
    {
        Write-Debug "[New-JiraVersion] Defining properties"
        $props = @{
            "name" = $VersionName;
            "description" = $VersionDescription;
            "projectId" = $ProjectObj.ID;
        }

        Write-Debug "[New-JiraVersion] Converting to JSON"
        $json = ConvertTo-Json -InputObject $props

        Write-Debug "[New-JiraVersion] Preparing for blastoff!"
        $result = Invoke-JiraMethod -Method Post -URI $restUrl -Body $json -Credential $Credential

        if ($result)
        {
            Write-Debug "[New-JiraVersion] Converting output object into a JiraVersion object and outputting"
            ConvertTo-JiraVersion -InputObject $result
        } else {
            Write-Debug "[New-JiraVersion] Jira returned no results to output."
        }
    }
}
