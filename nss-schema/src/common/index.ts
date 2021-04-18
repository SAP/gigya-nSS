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
