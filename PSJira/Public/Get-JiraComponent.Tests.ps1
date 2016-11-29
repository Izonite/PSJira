$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"


InModuleScope PSJira {

    $showMockData = $false
#    $DebugPreference = "Continue"

    $jiraServer = 'http://jiraserver.example.com'
    $testComponentId = 10000
    $testComponentName = "Test Component1"
    $testComponentDescription = "This is a JIRA component"
    $testProjectKey = "PRJKEY"
    $testProjectId = 11111

    $testProjectKey2 = "PRJK2"
    $testProjectId2 = 22222
    $testComponentId2 = 20000
    $testComponentName2 = "Test Component2"
    $testComponentDescription2 = "This is another JIRA component"


#For testing the return of 1 component
#GET /rest/api/2/component/{id}
# and
#GET /rest/api/2/project/{$testProjectKey}/components
    $restResultOne = @"
{
    "self": "$jiraServer/rest/api/2/component/$testComponentId",
    "id": "$testComponentId",
    "name": "$testComponentName",
    "description": "$testComponentDescription",
    "lead": {
        "self": "$jiraServer/rest/api/2/user?username=fred",
        "name": "fred",
        "displayName": "Fred F. User",
        "active": false
    },
    "assigneeType": "PROJECT_LEAD",
    "assignee": {
        "self": "$jiraServer/rest/api/2/user?username=fred",
        "name": "fred",
        "displayName": "Fred F. User",
        "active": false
    },
    "realAssigneeType": "PROJECT_LEAD",
    "realAssignee": {
        "self": "$jiraServer/rest/api/2/user?username=fred",
        "name": "fred",
        "displayName": "Fred F. User",
        "active": false
    },
    "isAssigneeTypeValid": false,
    "project": "$testProjectKey",
    "projectId": "$testProjectId"
}
"@


#For testing the return of many components (
#GET /rest/api/2/project/{projectIdOrKey}/components
    $restResultAll = @"
[
    {
        "self": "$jiraServer/rest/api/2/component/$testComponentId",
        "id": "$testComponentId",
        "name": "$testComponentName",
        "description": "$testComponentDescription",
        "lead": {
            "self": "$jiraServer/rest/api/2/user?username=fred",
            "name": "fred",
             "displayName": "Fred F. User",
            "active": false
        },
        "assigneeType": "PROJECT_LEAD",
        "assignee": {
            "self": "$jiraServer/rest/api/2/user?username=fred",
            "name": "fred",
            "displayName": "Fred F. User",
            "active": false
        },
        "realAssigneeType": "PROJECT_LEAD",
        "realAssignee": {
            "self": "$jiraServer/rest/api/2/user?username=fred",
            "name": "fred",
            "displayName": "Fred F. User",
            "active": false
        },
        "isAssigneeTypeValid": false,
        "project": "$testProjectKey2",
        "projectId": "$testProjectId2"
    },
    {
        "self": "$jiraServer/rest/api/2/component/$testComponentId2",
        "id": "$testComponentId2",
        "name": "$testComponentName2",
        "description": "$testComponentDescription2",
        "lead": {
            "self": "$jiraServer/rest/api/2/user?username=fred",
            "name": "fred",
            "displayName": "Fred F. User",
            "active": false
        },
        "assigneeType": "PROJECT_LEAD",
        "assignee": {
            "self": "$jiraServer/rest/api/2/user?username=fred",
            "name": "fred",
            "displayName": "Fred F. User",
            "active": false
        },
        "realAssigneeType": "PROJECT_LEAD",
        "realAssignee": {
            "self": "$jiraServer/rest/api/2/user?username=fred",
            "name": "fred",
            "displayName": "Fred F. User",
            "active": false
        },
        "isAssigneeTypeValid": false,
        "project": "$testProjectKey2",
        "projectId": "$testProjectId2"
    }
]
"@


    Describe "Get-JiraComponent" {

        Mock Get-JiraConfigServer -ModuleName PSJira {
            Write-Output $jiraServer
        }

        # Searching for a component.
        Mock Invoke-JiraMethod -ModuleName PSJira -ParameterFilter {$Method -eq 'Get' -and $URI -eq "$jiraServer/rest/api/latest/component/$testComponentId"} {
            if ($ShowMockData)
            {
                Write-Host "       1 Mocked Invoke-JiraMethod with GET method" -ForegroundColor Cyan
                Write-Host "         [Method] $Method" -ForegroundColor Cyan
                Write-Host "         [URI]    $URI" -ForegroundColor Cyan
            }
            ConvertFrom-Json2 -InputObject $restResultOne
        }


        # Searching for the components of a project.
        #GET /rest/api/2/project/{projectIdOrKey}/components
        # ... on a project with 2 components
        Mock Invoke-JiraMethod -ModuleName PSJira -ParameterFilter {$Method -eq 'Get' -and $URI -eq "$jiraServer/rest/api/latest/project/$testProjectKey2/components"} {
            if ($ShowMockData)
            {
                Write-Host "       2 Mocked Invoke-JiraMethod with GET method" -ForegroundColor Cyan
                Write-Host "         [Method] $Method" -ForegroundColor Cyan
                Write-Host "         [URI]    $URI" -ForegroundColor Cyan
            }
            ConvertFrom-Json2 -InputObject $restResultAll
        }

        # ... by ID on a project with 2 components
        Mock Invoke-JiraMethod -ModuleName PSJira -ParameterFilter {$Method -eq 'Get' -and $URI -eq "$jiraServer/rest/api/latest/project/$testProjectId2/components"} {
            if ($ShowMockData)
            {
                Write-Host "       3 Mocked Invoke-JiraMethod with GET method" -ForegroundColor Cyan
                Write-Host "         [Method] $Method" -ForegroundColor Cyan
                Write-Host "         [URI]    $URI" -ForegroundColor Cyan
            }
            ConvertFrom-Json2 -InputObject $restResultAll
        }


        # ... on a project with 1 components
        Mock Invoke-JiraMethod -ModuleName PSJira -ParameterFilter {$Method -eq 'Get' -and $URI -eq "$jiraServer/rest/api/latest/project/$testProjectKey/components"} {
            if ($ShowMockData)
            {
                Write-Host "       4 Mocked Invoke-JiraMethod with GET method" -ForegroundColor Cyan
                Write-Host "         [Method] $Method" -ForegroundColor Cyan
                Write-Host "         [URI]    $URI" -ForegroundColor Cyan
            }
            ConvertFrom-Json2 -InputObject $restResultOne
        }


        # Generic catch-all. This will throw an exception if we forgot to mock something.
        Mock Invoke-JiraMethod -ModuleName PSJira {
            Write-Host "       Mocked Invoke-JiraMethod with no parameter filter." -ForegroundColor DarkRed
            Write-Host "         [Method]         $Method" -ForegroundColor DarkRed
            Write-Host "         [URI]            $URI" -ForegroundColor DarkRed
            throw "Unidentified call to Invoke-JiraMethod"
        }


        #############
        # Tests
        #############

        ########
        # Search by Component
        ########
        It "Gets information about a provided Jira component ID" {
            $getResult = Get-JiraComponent -ComponentId $testComponentId
            $getResult | Should Not BeNullOrEmpty
        }

        It "Converts the output object to PSJira.Component" {
            $getResult = Get-JiraComponent -ComponentId $testComponentId
            (Get-Member -InputObject $getResult).TypeName | Should Be 'PSJira.Component'
        }

        It "Returns all available properties about the returned component object" {
            $getResult = Get-JiraComponent -ComponentId $testComponentId
            $restObj = ConvertFrom-Json2 -InputObject $restResultOne

            $getResult.RestUrl | Should Be $restObj.self
            $getResult.Name | Should Be $testComponentName
            $getResult.description | Should Be $testComponentDescription
            $getResult.projectKey | Should Be $testProjectKey
            $getResult.projectID | Should Be $testProjectId

        }


        ########
        # Search by Project
        ########
		It "Returns components of specific projects if the project key is supplied - Project with only one component" {
            $getResult = Get-JiraComponent -ProjectKey $testProjectKey
            $getResult | Should Not BeNullOrEmpty
            @($getResult).Count | Should Be 1
        }


        It "Returns components of specific projects if the project key is supplied - Project with 2 components" {
            $getResult = Get-JiraComponent -ProjectKey $testProjectKey2
            $getResult | Should Not BeNullOrEmpty
            @($getResult).Count | Should Be 2
        }


        It "Returns components of specific projects if the project ID is supplied - Project with 2 components" {
            $getResult = Get-JiraComponent -ProjectKey $testProjectId2
            $getResult | Should Not BeNullOrEmpty
            @($getResult).Count | Should Be 2
        }

        It "Returns components properties of specific project - Project with 2 components" {
            $getResult = Get-JiraComponent -ProjectKey $testProjectKey2
            $restObj = ConvertFrom-Json2 -InputObject $restResultAll
            @($getResult)[0].ID | Should Be $testComponentId
            @($getResult)[1].ID | Should Be $testComponentId2
            @($getResult)[0].name | Should Be $testComponentName
            @($getResult)[1].name | Should Be $testComponentName2
            @($getResult)[0].Description | Should Be $testComponentDescription
            @($getResult)[1].Description | Should Be $testComponentDescription2
            @($getResult)[0].projectKey | Should Be $testProjectKey2
            @($getResult)[1].projectKey | Should Be $testProjectKey2
            @($getResult)[0].projectID | Should Be $testProjectId2
            @($getResult)[1].projectID | Should Be $testProjectId2

        }
    }
}


