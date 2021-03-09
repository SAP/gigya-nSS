import SchemaEntity from "../common/SchemaEntity";

export default new SchemaEntity('Color', {
    oneOf: [
        {
            description: 'color name',
            type: 'string',
            enum: ['blue', 'red', 'green', 'gray', 'yellow', 'orange', 'white', 'black', 'transparent', 'grey']
        },
        {
            description: 'color hex',
            type: 'string',
            pattern: '^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$'
        }
    ]
});