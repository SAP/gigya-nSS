import SchemaEntity from "../common/SchemaEntity";

export default new SchemaEntity('dynamic/AccountField', {
    type: 'string',
    pattern: '^(profile|data|subscriptions|preferences|conflictingAccount)\\.'
});