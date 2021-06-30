import {JSONSchema7} from "json-schema";
export * from "./SchemaEntity";

export const WithComment = {
    properties: {
        $comment: {
            type: 'string'
        }
    }
} as JSONSchema7;

export const TextKey = 'textKey';
export const WithText = {
    properties: {
        [TextKey]: {
            type: 'string'
        }
    }
} as JSONSchema7;

export const withAccessibility = {
    properties: {
        accessibility: {
            type: 'object',
            additionalProperties: false,
            properties: {
                label: {
                    type: 'string',
                },
                hint: {
                    type: 'string'
                }
            }
        },
    }
} as JSONSchema7;
