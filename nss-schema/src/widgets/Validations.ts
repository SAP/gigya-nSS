import SchemaEntity from "../common/SchemaEntity";

export default new SchemaEntity('Validations', {
        type: 'object',
        additionalProperties: false,
        properties: {
            required: {
                type: 'object',
                additionalProperties: false,
                properties: {
                    enabled: {
                        type: 'boolean',
                        default: false
                    },
                    errorKey: {
                        type: 'string'
                    }
                }
            },
            regex: {
                type: 'object',
                additionalProperties: false,
                properties: {
                    enabled: {
                        type: 'boolean',
                        default: false
                    },
                    errorKey: {
                        type: 'string'
                    },
                    format: {
                        type: 'string',
                        format: 'regex'
                    }
                }
            }
        }
    }
);