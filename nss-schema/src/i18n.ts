import SchemaEntity from "./common/SchemaEntity";

export default new SchemaEntity('i18n', {
    description: 'Localization of texts to different languages',
    type: 'object',
    patternProperties: {
        '^(_default|[^_]).*': {                 // language key
            type: 'object',
            description: 'Language key to texts',
            patternProperties: {
                '.*': {         // text key
                    type: 'string',
                    description: 'Text key to actual text',
                }
            }
        }
    }
});