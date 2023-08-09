using {AuthorReadingManager} from './service-models';

// ----------------------------------------------------------------------------
// Required authorization roles
annotate AuthorReadingManager with @(requires : [
    'AuthorReadingManagerRole',
    'AuthorReadingAdminRole'
]);

// ----------------------------------------------------------------------------
// Restriction per authorization role:

// Managers can read all author readings, create new author readings and change their own author readings
// Administrators have no restrictions
annotate AuthorReadingManager.AuthorReadings with @(restrict : [
    {
        grant : [
            'READ',
            'CREATE'
        ],
        to    : 'AuthorReadingManagerRole'
    },
    {
        grant : ['*'],
        to    : 'AuthorReadingManagerRole',
        where : 'createdBy = $user'
    },
    {
        grant : ['*'],
        to    : 'AuthorReadingAdminRole'
    }
]);

// Managers can read all participants, add new participants, change participants they added themseves
// Administrators have no restrictions
annotate AuthorReadingManager.Participants with @(restrict : [
    {
        grant : [
            'READ',
            'CREATE'
        ],
        to    : 'AuthorReadingManagerRole'
    },
    {
        grant : ['*'],
        to    : 'AuthorReadingManagerRole',
        where : 'createdBy = $user'
    },
    {
        grant : ['*'],
        to    : 'AuthorReadingAdminRole'
    }
]);

// ByD projects: Managers and Administrators can read and create remote projects
annotate AuthorReadingManager.ByDProjects with @(restrict : [
    {
        grant : ['*'],
        to    : 'AuthorReadingManagerRole',
    },
    {
        grant : ['*'],
        to    : 'AuthorReadingAdminRole'
    }
]);
annotate AuthorReadingManager.ByDProjectSummaryTasks with @(restrict : [
    {
        grant : ['*'],
        to    : 'AuthorReadingManagerRole',
    },
    {
        grant : ['*'],
        to    : 'AuthorReadingAdminRole'
    }
]);
annotate AuthorReadingManager.ByDProjectTasks with @(restrict : [
    {
        grant : ['*'],
        to    : 'AuthorReadingManagerRole',
    },
    {
        grant : ['*'],
        to    : 'AuthorReadingAdminRole'
    }
]);
annotate AuthorReadingManager.ByDProjectsTechUser with @(restrict : [
    {
        grant : ['*'],
        to    : 'AuthorReadingManagerRole',
    },
    {
        grant : ['*'],
        to    : 'AuthorReadingAdminRole'
    }
]);
