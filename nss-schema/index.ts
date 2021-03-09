import nSSSchema from "./src/root";
import {schemaFile, outputDir} from "./env";
import {JSONSchema7} from "json-schema";

const fs = require('fs');

if (!fs.existsSync(outputDir)){
    fs.mkdirSync(outputDir);
}
fs.writeFileSync(`./${schemaFile}`, JSON.stringify(nSSSchema));
