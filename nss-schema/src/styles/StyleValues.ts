import {JSONSchema7} from "json-schema";
import SchemaEntity from "../common/SchemaEntity";
import Theme from "../dynEnums/Theme";

export const StyleSegment = 'styles';

export class StyleProperty extends SchemaEntity {
    public get segment() { return StyleSegment; }

    constructor(propertyName: string, schema: JSONSchema7) {
        super(propertyName, {
            properties: {
                [propertyName]: schema
            }
        });
    }
}

export function withStyle(...styleProps: StyleProperty[]) {
    return {
        properties: {
            theme: Theme.getRef(),
            style: {
                anyOf: styleProps.map(p => p.getRef())
            }
        }
    } as JSONSchema7;
}