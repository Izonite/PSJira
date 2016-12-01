# Created by Izonite

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

InModuleScope PSJira {
    Describe "ConvertTo-JiraVersion" {
        function defProp($obj, $propName, $propValue)
        {
            It "Defines the '$propName' property" {
                $obj.$propName | Should Be $propValue
            }
        }

        $jiraServer = 'http://jiraserver.example.com'
    
        $versionID = 10000
        $versionName = "Test Name of version"
        $versionDescription = "Test Description of version"
        $projectIdOfversion = 20000
		
        $sampleJson = @"
{
    "self": "$jiraServer/rest/api/2/version/$versionID",
    "id": "$versionID",
    "description": "$versionDescription",
    "name": "$versionName",
    "archived": false,
    "released": true,
    "releaseDate": "2016-12-01",
    "overdue": false,
    "userReleaseDate": "1/Dec/2016",
    "projectId": $projectIdOfversion
}
"@


        $sampleObject = ConvertFrom-Json2 -InputObject $sampleJson

        It "Creates a PSObject out of JSON input" {
            $r = ConvertTo-JiraVersion -InputObject $sampleObject
            $r | Should Not BeNullOrEmpty
        }

        It "Sets the type name to PSJira.version" {
            $r = ConvertTo-JiraVersion -InputObject $sampleObject
            $r.PSObject.TypeNames[0] | Should Be 'PSJira.version'
        }

        $r = ConvertTo-JiraVersion -InputObject $sampleObject

        defProp $r 'ID' $versionID
        defProp $r 'RestUrl' "$jiraServer/rest/api/2/version/$versionID"
        defProp $r 'name' $versionName
        defProp $r 'description' $versionDescription
		defprop $r 'archived' $false
		defprop $r 'released' $true
		defprop $r 'releaseDate' (get-date '2016-12-01' -format "yyyy-MM-dd")
		defprop $r 'overdue' $false
        defprop $r 'projectID' $projectIdOfversion
    }
}


