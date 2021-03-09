import {getJsonFiles, schemaFile} from "../env";
import {JSONSchema7} from "json-schema";

const excludeFiles = [];

const validExamples = [
    ...getJsonFiles('spec/valid', excludeFiles),
    ...getJsonFiles('examples', excludeFiles)
];
const invalidExamples = getJsonFiles('spec/invalid', excludeFiles);
console.log(`~~~ test cases to run:\n${validExamples.length} valid.\n${invalidExamples.length} invalid.\n~~~`);

const validate = require('jsonschema').validate;
const schema = require(`../${schemaFile}`) as JSONSchema7;

describe('valid', () => {
    validExamples.map(file => {
        const shouldTest = file.replace(/\.json$/, '');

        return it(shouldTest, () => {
            const nSS = require(`../${file}`);
            const result = validate(nSS, schema);
            expect(result.valid).toBeTruthy();
            if (result.errors.length) {
                console.log(`errors on ${shouldTest}:`, result.errors[0]);
            }
        });
    });
});


describe('invalid', () => {
    invalidExamples.map(file => {
        const shouldTest = file.replace(/\.json$/, '');

        return it(shouldTest, () => {
            const nSS = require(`../${file}`);
            const result = validate(nSS, schema);
            expect(result.valid).toBeFalsy();
        });
    });
});