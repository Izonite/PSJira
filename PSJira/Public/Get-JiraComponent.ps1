function Get-JiraComponent
{
    <#
    .Synopsis
       Returns component(s) of a JIRA Project
    .DESCRIPTION
       Created by Izonite - based on Get-JiraGroup.ps1
    .EXAMPLE
       Get-JiraComponent -ComponentId NNN -Credential $cred
       Returns the component with id NNN in the database
    .EXAMPLE
       Get-JiraComponent -ProjectKey PRJKEY -Credential $cred
       Returns the component(s) of the project PRJKEY (PRJKEY can be the numeric or text key of the project)
    .INPUTS
       This function does not accept pipeline input.
    .OUTPUTS
       [PSJira.Component]
    #>
    [CmdletBinding()]
    param(
        # ComponentId
        [Parameter(ParameterSetName = 'ByComponentId',
                   Mandatory = $true,
                   Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Long[]] $ComponentId,

        # ProjectKey
        [Parameter(ParameterSetName = 'ByProjectKey',
                   Mandatory = $true,
                   Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String[]] $ProjectKey,

        # Credentials to use to connect to Jira
        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential] $Credential
    )

    begin
    {
        Write-Debug "[Get-JiraComponent] Reading server from config file"
        $server = Get-JiraConfigServer -ConfigFile $ConfigFile -ErrorAction Stop

        Write-Debug "[Get-JiraComponent] ParameterSetName=$($PSCmdlet.ParameterSetName)"

        Write-Debug "[Get-JiraComponent] Building URI for REST call"
        $projectUrl = "$server/rest/api/latest/project/"
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq 'ByProjectKey')
        {
            foreach ($prj in $ProjectKey)
            {
                Write-Debug "[Get-JiraComponent] Escaping project name [$prj]"
                $escapedProjectName = [System.Web.HttpUtility]::UrlPathEncode($prj)

                Write-Debug "[Get-JiraComponent] Escaped project name: [$escapedProjectName]"
                $thisUrl = $projectUrl
                $thisUrl += $escapedProjectName
                $thisUrl += "/components"

                Write-Debug "[Get-JiraComponent] Preparing for blastoff!"
                Write-Debug "[Get-JiraComponent] URL : $thisUrl"
                $result = Invoke-JiraMethod -Method Get -URI $thisUrl -Credential $Credential

                if ($result)
                {
                    Write-Debug "[Get-JiraComponent] Converting REST result to Jira component"
                    $obj = ConvertTo-JiraComponent -InputObject $result

                    Write-Debug "[Get-JiraComponent] Outputting results"
                    Write-Output $obj

                } else {
                    Write-Debug "[Get-JiraComponent] No results were returned from JIRA"
                }
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'ByComponentId')
        {
            foreach ($i in $ComponentId)
                {
                Write-Debug "[Get-JiraComponent] Processing Component [$i]"
                $URL = "$($server)/rest/api/latest/component/${i}"
                Write-Debug "[Get-JiraComponent] URL : $URL"

                Write-Debug "[Get-JiraComponent] Preparing URL..."
                $result = Invoke-JiraMethod -Method Get -URI $URL -Credential $Credential

                if ($result)
                {
                    Write-Debug "[Get-JiraComponent] Converting REST result to Jira component"
                    $obj = ConvertTo-JiraComponent -InputObject $result

                    Write-Debug "[Get-JiraComponent] Outputting result"
                    Write-Output $obj
                } else {
                    Write-Debug "[Get-JiraComponent] Invoke-JiraMethod returned no results to output."
                }
            }
        }

    }

    end
    {
        Write-Debug "[Get-JiraComponent] Complete"
    }
}


