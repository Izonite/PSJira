function Set-JiraComponent
{
    <#
    .Synopsis
       Modifies an existing component in JIRA

       Created by Izonite from Set-JiraIssue.ps1 existing script
    .DESCRIPTION
       This function modifies an existing component in JIRA.  This can include changing : leader

       ####### TODO  : change -Name -Description -Lead -DefaultAssignee

    .EXAMPLE

       ####### TODO

    .INPUTS
       [PSJira.Component[]] The JIRA component that should be modified
    .OUTPUTS
       If the -PassThru parameter is provided, this function will provide a reference
       to the JIRA Component  modified.  Otherwise, this function does not provide output.
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByInputObject')]
    param(
        # Component key or PSJira.Component object returned from Get-JiraComponents
        [Parameter(Mandatory = $true,
                   Position = 0,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [Alias('Key')]
        [Object[]] $Component,

        # New Name of che component
        [Parameter(Mandatory = $false)]
        [String] $Name,

        # New Description of che component
        [Parameter(Mandatory = $false)]
        [String] $Description,

        # New Lead of che component
        [Parameter(Mandatory = $false)]
        [String] $Lead,

        # New Default Assignee of che component
        [Parameter(Mandatory = $false)]
        [String] $DefaultAssignee,

        [ValidateScript({Test-Path $_})]
        [String] $ConfigFile,

        # Credentials to use to connect to Jira
        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential] $Credential,

        [Switch] $PassThru
    )

    begin
    {
        $DebugPreference = "Continue"

        Write-Debug "[Set-JiraComponent] Checking to see if we have any operations to perform"

        if (-not ($Name -or $Description -or $Lead -or $DefaultAssignee))
        {
            Write-Verbose "Nothing to do."
            return
        }

        Write-Debug "[Set-JiraComponent] Reading server from config file"
        $server = Get-JiraConfigServer -ConfigFile $ConfigFile -ErrorAction Stop


        $URL = "$server/rest/api/latest/component/"

        <#if ($DefaultAssignee)
        {
            Write-Debug "[Set-JiraComponent] Testing DefaultAssignee type"
            if ($DefaultAssignee -eq 'Unassigned')
            {
                Write-Debug "[Set-JiraComponent] 'Unassigned' String passed. Issue will be assigned to no one."
                $assigneeString = ""
                $validAssignee = $true
            } else {
                Write-Debug "[Set-JiraComponent] Attempting to obtain Jira user [$Assignee]"
                $assigneeObj = Get-JiraUser -InputObject $Assignee -Credential $Credential
                if ($assigneeObj)
                {
                    Write-Debug "[Set-JiraComponent] User found (name=[$($assigneeObj.Name)],RestUrl=[$($assigneeObj.RestUrl)])"
                    $assigneeString = $assigneeObj.Name
                    $validAssignee = $true
                } else {
                    Write-Debug "[Set-JiraComponent] Unable to obtain Assignee. Exception will be thrown."
                    throw "Unable to validate Jira user [$Assignee]. Use Get-JiraUser for more details."
                }
            }
        }
        #>

        Write-Debug "[Set-JiraComponent] Completed Begin block."
    }

    process
    {
        foreach ($c in $Component)
        {

            Write-Debug $c.ID

            $thisURL=$URL
            $thisURL+=$c.ID

            $props = @{
            }

              if ($Lead)
            {
                $props.leadUserName = $Lead
            }


            $json = ConvertTo-Json -InputObject $props

            Write-Debug "on va put ce json : "
            write-debug $json

            $Result = Invoke-JiraMethod -Method Put -URI $thisURL -Body $json -Credential $Credential

            <# SEB1


            $actOnIssueUri = $false
            $actOnAssigneeUri = $false

            Write-Debug "[Set-JiraComponent] Obtaining reference to component"
            $issueObj = Get-JiraComponent -InputObject $i -Credential $Credential

            if ($issueObj)
            {
                $issueProps = @{
                    'update' = @{}
                }

                if ($Summary)
                {
                    # Update properties need to be passed to JIRA as arrays
                    $issueProps.update.summary = @()
                    $issueProps.update.summary += @{
                        'set' = $Summary;
                    }
                    $actOnIssueUri = $true
                }

                if ($Description)
                {
                    $issueProps.update.description = @()
                    $issueProps.update.description += @{
                        'set' = $Description;
                    }
                    $actOnIssueUri = $true
                }


                if ($validAssignee)
                {

                    $assigneeProps =  @{
                        'name' = $assigneeString;
                    }

                    $actOnAssigneeUri = $true
                }

                if ($actOnIssueUri)
                {
                    Write-Debug "[Set-JiraComponent] IssueProps: [$issueProps]"

                    Write-Debug "[Set-JiraComponent] Converting results to JSON"
                    $json = ConvertTo-Json -InputObject $issueProps -Depth 5
                    $issueObjURL = $issueObj.RestUrl

                    Write-Debug "[Set-JiraComponent] Preparing for blastoff!"
                    $issueResult = Invoke-JiraMethod -Method Put -URI $issueObjURL -Body $json -Credential $Credential
                    Write-Debug "[Set-JiraComponent] Results are saved to issueResult variable"
                }

                if ($actOnAssigneeUri)
                {
                    # Jira handles assignee differently; you can't change it from the default "edit issues" screen unless
                    # you customize the "Edit Issue" screen.

                    $assigneeUrl = "{0}/assignee" -f $issueObj.RestUrl
                    $json = ConvertTo-Json -InputObject $assigneeProps

                    Write-Debug "[Set-JiraComponent] Preparing for blastoff!"
                    $assigneeResult = Invoke-JiraMethod -Method Put -URI $assigneeUrl -Body $json -Credential $Credential
                    Write-Debug "[Set-JiraComponent] Results are saved to assigneeResult variable"
                }


            }


            else {
                Write-Debug "[Set-JiraComponent] Unable to identify component [$c]. Writing error message."
                Write-Error "Unable to identify component [$c]"
            }


            SEB1 #>

        }
    }

    end
    {
        Write-Debug "[Set-JiraComponent] Complete"
    }
}


