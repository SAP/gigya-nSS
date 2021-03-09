import SchemaEntity from "./SchemaEntity";

export default new SchemaEntity('Asset', {
    anyOf: [
        {
            description: 'External url asset',
            type: 'string',
            format: 'uri'
        },
        {
            description: 'internal asset',
            type: 'string',
        },
    ]
});