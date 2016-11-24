function ConvertTo-JiraComponent
# Created by Izonite from "ConvertTo-JiraComment.ps1"
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
                   Position = 0,
                   ValueFromPipeline = $true)]
        [PSObject[]] $InputObject
    )

    process
    {
        foreach ($i in $InputObject)
        {
#            Write-Debug "[ConvertTo-JiraComponent] Processing object: '$i'"

#            Write-Debug "[ConvertTo-JiraComponent] Defining properties"
            $props = @{
                'ID' = $i.id;
                'RestUrl' = $i.self;
                'name' = $i.name; #component name
                'description' = $i.description;
                'assigneeType' = $i.assigneeType; # (https://docs.atlassian.com/jira/server/com/atlassian/jira/pageobjects/project/components/Component.ComponentAssigneeType.html)
                    # COMPONENT_LEAD;PROJECT_DEFAULT;PROJECT_LEAD;UNASSIGNED;UNKNOWN 
                'realAssigneeType' = $i.realAssigneeType;
                'isAssigneeTypeValid' = $i.isAssigneeTypeValid;
                'projectKey' = $i.project; #text key of project's component
                'projectID' = $i.projectId; #numeric key of project's component
            }
#            Write-Debug "[ConvertTo-JiraComponent] getting the Component lead"
            if ($i.lead)
            {
                $props.lead = ConvertTo-JiraUser -InputObject $i.lead            
            }

#            Write-Debug "[ConvertTo-JiraComponent] Creating PSObject out of properties"
            $result = New-Object -TypeName PSObject -Property $props

#            Write-Debug "[ConvertTo-JiraComponent] Inserting type name information"
            $result.PSObject.TypeNames.Insert(0, 'PSJira.Component')

#            Write-Debug "[ConvertTo-JiraComponent] Inserting custom toString() method that will output the desctiption of the component"
            $result | Add-Member -MemberType ScriptMethod -Name "ToString" -Force -Value {
                Write-Output "$($this.description)"
            }

#            Write-Debug "[ConvertTo-JiraComponent] Outputting object"
            Write-Output $result
        }
    }

    end
    {
#        Write-Debug "[ConvertTo-JiraComponent] Complete"
    }
}


