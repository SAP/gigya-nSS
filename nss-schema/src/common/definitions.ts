import {JSONSchema7} from "json-schema";

const definitionsName = 'definitions';
type JSONSchemaDefinitions = JSONSchema7['definitions'];

export const definitions = {} as JSONSchemaDefinitions;
export function addDefinition(refKey: string, schema: JSONSchema7) {
    const entityPath = refKey.split('/');
    const entityKey = entityPath.pop();
    const container = entityPath.reduce((container, segment) => {
        if (!container[segment]) {
            container[segment] = {};
        }
        return container[segment] as JSONSchemaDefinitions;
    }, definitions);

    container[entityKey] = schema;
}

export function getRefTo(entity: string) {
    return {
        $ref: `#/${definitionsName}/${entity}`
    } as JSONSchema7;
}

export function getEntity(entityPath: string) {
    return entityPath.split('/').reduce((container, path) => container?.[path] as JSONSchemaDefinitions, definitions);
}

export function getAllRefs(container = definitions, pathPrefix = '') {
    return Object.entries(container as object).map(([entityKey, schema]) => {
        if (isEntity(schema)) {
            return [getRefTo(`${pathPrefix}/${entityKey}`)];
        }
        else {
            return getAllRefs(schema, pathPrefix ? `${pathPrefix}/${entityKey}` : entityKey);
        }
    }).reduce((res: Array<{$ref: string}>, cur) => res.concat(cur), []);
}

function isEntity(schema: JSONSchema7|object) {
    const schemaProps = Object.keys(schema);
    return Boolean([
        'properties',
        'anyOf',
        'oneOf',
        'allOf'
    ].find(entityProp => schemaProps.includes(entityProp)));
}

export function getRefsOf(segmentPath: string) {
    return getAllRefs(
        getEntity(segmentPath),
        segmentPath
    );
}
