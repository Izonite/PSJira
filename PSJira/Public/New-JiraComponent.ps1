function New-JiraComponent
{
    <#
    .Synopsis
       Creates a new component in a JIRA Project
    .DESCRIPTION
       Created by Izonite - based on New-JiraGroup.ps1
       creating a new component is done by : POST /rest/api/2/component with 1 component at a time

    {
        "name": "Component 1",
        "description": "This is a JIRA component",
        "leadUserName": "fred",
        "assigneeType": "PROJECT_LEAD",
        "isAssigneeTypeValid": false,
        "project": "PROJECTKEY",
        "projectId": 10000
    }

    .EXAMPLE
       New-JiraComponent -Project NEWPROJ -ComponentToAdd $PSJira.Component
       Adds the component $PSJira.Component to the project 'NEWPROJ'

    .INPUTS
       [Object] : the component to add. It can be a JSON file or a [PSJira.Component] object.
    .OUTPUTS
       [PSJira.Component]
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByInputObject')]
    param(
        [Parameter(ParameterSetName='ByInputObject',Mandatory = $true)]
        [String] $Project,

        [Parameter(ParameterSetName='ByInputObject',Mandatory = $true)]
        [Object] $ComponentToAdd,

        [Parameter(ParameterSetName='ByValues',Mandatory = $true)]
        [String] $ComponentName,

        [Parameter(ParameterSetName='ByValues',Mandatory = $false)]
        [String] $ComponentDescr,

        [Parameter(ParameterSetName='ByValues',Mandatory = $true)]
        [String] $ComponentAssigneeType,


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
            if ($result.errors)
            {
                Write-Debug "[New-JiraComponent] Jira returned an error result object."
            }
            else {
                # OK
                Write-Debug "[New-JiraComponent] Converting output object into a Jira component object and outputting"
                Write-Debug "--- TODO---"
                ConvertTo-JiraComponent -InputObject $result
            }
        } else {
            Write-Debug "[New-JiraComponent] Jira returned no results to output."
        }



    }
}
