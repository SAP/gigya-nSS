import SchemaEntity from "./common/SchemaEntity";

export default new SchemaEntity('SpecialField', {
    description: 'special fields',
    anyOf: [
        {
            enum: [ // for editor auto-completion
                '#loginID',
                '#email',
                '#password',
                'conflictingAccount.loginID'
            ]
        },
        {
            type: 'string',
            pattern: '^#'
        }
    ]
});