function Get-JiraVersion
{
    <#
    .Synopsis
       Returns version(s) of a JIRA Project
    .DESCRIPTION
       Created by Izonite
    .EXAMPLE
       Get-JiraVersion -VersionID NNN -Credential $cred
       Returns the version with id NNN in the database
    .EXAMPLE
       Get-JiraVersion -ProjectKey PRJKEY -Credential $cred
       Returns the Version(s) of the project PRJKEY (PRJKEY can be the numeric or text key of the project)
    .INPUTS
       This function does not accept pipeline input.
    .OUTPUTS
       [PSJira.Version]
    #>
    [CmdletBinding()]
    param(
        # VersionID
        [Parameter(ParameterSetName = 'ByVersionID',
                   Mandatory = $true,
                   Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Long[]] $VersionID,

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
        Write-Debug "[Get-JiraVersion] Reading server from config file"
        $server = Get-JiraConfigServer -ConfigFile $ConfigFile -ErrorAction Stop

        Write-Debug "[Get-JiraVersion] ParameterSetName=$($PSCmdlet.ParameterSetName)"

        Write-Debug "[Get-JiraVersion] Building URI for REST call"
        $projectUrl = "$server/rest/api/latest/project/"
    }

    process
    {
        if ($PSCmdlet.ParameterSetName -eq 'ByProjectKey')
        {
            foreach ($prj in $ProjectKey)
            {
                Write-Debug "[Get-JiraVersion] Escaping project name [$prj]"
                $escapedProjectName = [System.Web.HttpUtility]::UrlPathEncode($prj)

                Write-Debug "[Get-JiraVersion] Escaped project name: [$escapedProjectName]"
                $thisUrl = $projectUrl
                $thisUrl += $escapedProjectName
                $thisUrl += "/versions"

                Write-Debug "[Get-JiraVersion] Preparing for blastoff!"
                Write-Debug "[Get-JiraVersion] URL : $thisUrl"
                $result = Invoke-JiraMethod -Method Get -URI $thisUrl -Credential $Credential

                if ($result)
                {
                    Write-Debug "[Get-JiraVersion] Converting REST result to Jira version"
                    $obj = ConvertTo-JiraVersion -InputObject $result

                    Write-Debug "[Get-JiraVersion] Outputting results"
                    Write-Output $obj

                } else {
                    Write-Debug "[Get-JiraVersion] No results were returned from JIRA"
                }
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'ByVersionID')
        {
            foreach ($i in $VersionID)
                {
                Write-Debug "[Get-JiraVersion] Processing Version [$i]"
                $URL = "$($server)/rest/api/latest/version/${i}"
                Write-Debug "[Get-JiraVersion] URL : $URL"

                Write-Debug "[Get-JiraVersion] Preparing URL..."
                $result = Invoke-JiraMethod -Method Get -URI $URL -Credential $Credential

                if ($result)
                {
                    Write-Debug "[Get-JiraVersion] Converting REST result to Jira version"
                    $obj = ConvertTo-JiraVersion -InputObject $result

                    Write-Debug "[Get-JiraVersion] Outputting result"
                    Write-Output $obj
                } else {
                    Write-Debug "[Get-JiraVersion] Invoke-JiraMethod returned no results to output."
                }
            }
        }

    }

    end
    {
        Write-Debug "[Get-JiraVersion] Complete"
    }
}


