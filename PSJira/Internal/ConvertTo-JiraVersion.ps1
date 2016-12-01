function ConvertTo-JiraVersion
# Created by Izonite
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
            <# SAMPLE VERSION JSON
            {
                "self": "http://www.example.com/jira/rest/api/2/version/10000",
                "id": "10000",
                "description": "An excellent version",
                "name": "New Version 1",
                "archived": false,
                "released": true,
                "startDate": "2016-11-01"
                "releaseDate": "2016-12-01",
                "overdue": true,
                "projectId": 10000
            }
            #>

#            Write-Debug "[ConvertTo-JiraVersion] Processing object: '$i'"
#            Write-Debug "[ConvertTo-JiraVersion] Defining properties"
            $props = @{
                'ID' = $i.id; #id of version
                'RestUrl' = $i.self;
                'name' = $i.name;
                'description' = $i.description;
				'archived' = $i.archived;
				'released' = $i.released;
				'overdue' = $i.overdue;
                'projectID' = $i.projectId; #numeric key of project's version
            }

            # These fields should typically exist on an object returned from Jira,
            # but this provides a bit of extra error checking and safety

#            Write-Debug "[ConvertTo-JiraVersion] Checking for releaseDate"
            if ($i.releaseDate)
            {
                $props.releaseDate = (Get-Date ($i.releaseDate) -format "yyyy-MM-dd")
            }
#            Write-Debug "[ConvertTo-JiraVersion] Checking for startDate"
            if ($i.startDate)
            {
                $props.startDate = (Get-Date ($i.startDate))
            }


#            Write-Debug "[ConvertTo-JiraVersion] Creating PSObject out of properties"
            $result = New-Object -TypeName PSObject -Property $props

#            Write-Debug "[ConvertTo-JiraVersion] Inserting type name information"
            $result.PSObject.TypeNames.Insert(0, 'PSJira.Version')

#            Write-Debug "[ConvertTo-JiraVersion] Inserting custom toString() method that will output the desctiption of the Version"
            $result | Add-Member -MemberType ScriptMethod -Name "ToString" -Force -Value {
                Write-Output "$($this.description)"
            }

#            Write-Debug "[ConvertTo-JiraVersion] Outputting object"
            Write-Output $result
        }
    }

    end
    {
#        Write-Debug "[ConvertTo-JiraVersion] Complete"
    }
}


