# Created by Izonite from "ConvertTo-JiraComment.ps1"

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

InModuleScope PSJira {
    Describe "ConvertTo-JiraComponent" {
        function defProp($obj, $propName, $propValue)
        {
            It "Defines the '$propName' property" {
                $obj.$propName | Should Be $propValue
            }
        }

        $jiraServer = 'http://jiraserver.example.com'
        $jiraUsername = 'powershell-test'
        $jiraUserDisplayName = 'PowerShell Test User'
        

        $componentID = 10000
        $componentName = "Test Name of Component"
        $componentDescription = "Test Description of Component"
        $componentAssigneeType = "PROJECT_LEAD"
        $componentRealAssigneeType = "PROJECT_LEAD"
        $componentIsAssigneeTypeValid = "false"
        $projectKeyOfComponent = "KEYPRJ"
        $projectIdOfComponent = 20000


        $sampleJson = @"
{
    "self": "$jiraServer/rest/api/2/component/$componentID",
    "id": "$componentID",
    "name": "$componentName",
    "description": "$componentDescription",
    "lead": {
        "self": "$jiraServer/rest/api/2/user?username=fred",
        "name": "fred",
        "avatarUrls": {
            "48x48": "$jiraServer/secure/useravatar?size=large&ownerId=fred",
            "24x24": "$jiraServer/secure/useravatar?size=small&ownerId=fred",
            "16x16": "$jiraServer/secure/useravatar?size=xsmall&ownerId=fred",
            "32x32": "$jiraServer/secure/useravatar?size=medium&ownerId=fred"
        },
        "displayName": "Fred F. User",
        "active": false
    },
    "assigneeType": "$componentAssigneeType",
    "assignee": {
        "self": "$jiraServer/rest/api/2/user?username=fred",
        "name": "fred",
        "avatarUrls": {
            "48x48": "$jiraServer/secure/useravatar?size=large&ownerId=fred",
            "24x24": "$jiraServer/secure/useravatar?size=small&ownerId=fred",
            "16x16": "$jiraServer/secure/useravatar?size=xsmall&ownerId=fred",
            "32x32": "$jiraServer/secure/useravatar?size=medium&ownerId=fred"
        },
        "displayName": "Fred F. User",
        "active": false
    },
    "realAssigneeType": "$componentRealAssigneeType",
    "realAssignee": {
        "self": "$jiraServer/rest/api/2/user?username=fred",
        "name": "fred",
        "avatarUrls": {
            "48x48": "$jiraServer/secure/useravatar?size=large&ownerId=fred",
            "24x24": "$jiraServer/secure/useravatar?size=small&ownerId=fred",
            "16x16": "$jiraServer/secure/useravatar?size=xsmall&ownerId=fred",
            "32x32": "$jiraServer/secure/useravatar?size=medium&ownerId=fred"
        },
        "displayName": "Fred F. User",
        "active": false
    },
    "isAssigneeTypeValid": $componentIsAssigneeTypeValid,
    "project": "$projectKeyOfComponent",
    "projectId": "$projectIdOfComponent"
}
"@

        
        $sampleObject = ConvertFrom-Json2 -InputObject $sampleJson

        It "Creates a PSObject out of JSON input" {
            $r = ConvertTo-JiraComponent -InputObject $sampleObject
            $r | Should Not BeNullOrEmpty
        }

        It "Sets the type name to PSJira.Component" {
            $r = ConvertTo-JiraComponent -InputObject $sampleObject
            $r.PSObject.TypeNames[0] | Should Be 'PSJira.Component'
        }

        $r = ConvertTo-JiraComponent -InputObject $sampleObject

        defProp $r 'ID' $componentID
        defProp $r 'RestUrl' "$jiraServer/rest/api/2/component/$componentID"
        defProp $r 'name' $componentName
        defProp $r 'description' $componentDescription
        defProp $r 'assigneeType' $componentAssigneeType
        defProp $r 'realAssigneeType' $componentRealAssigneeType
        defProp $r 'isAssigneeTypeValid' $componentIsAssigneeTypeValid
        defprop $r 'projectKey' $projectKeyOfComponent
        defprop $r 'projectID' $projectIdOfComponent

        
    }
}


