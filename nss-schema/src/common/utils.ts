import {JSONSchema7} from "json-schema";

function isObject(item: any): item is object {
    return (item && typeof item === 'object' && !Array.isArray(item));
}

export function mergeDeep(target: JSONSchema7, ...sources: JSONSchema7[]): JSONSchema7 {
    if (!sources.length) return target;
    const source = sources.pop(); // start from last for better schemaFile

    if (isObject(target) && isObject(source)) {
        for (const key in source) {
            if (isObject(source[key])) {
                if (!target[key]) {
                    Object.assign(target, {[key]: {}});
                } else {
                    target[key] = Object.assign({}, target[key])
                }
                mergeDeep(target[key], source[key]);
            } else {
                Object.assign(target, {[key]: source[key]});
            }
        }
    }

    return mergeDeep(target, ...sources);
}
