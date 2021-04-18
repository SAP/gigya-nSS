import {exampleFile, examplesDir, versionsDir, getVersionConfig, schemaFile} from "./env";
const {version} = require('./package.json');
const {argv} = require('yargs');

const fs = require('fs');

const config = getVersionConfig();

console.log(`~~~ copying example file of nSS ${config.latest}...`);

if (!fs.existsSync(versionsDir)){
    fs.mkdirSync(versionsDir);
}

if (!fs.existsSync(`${versionsDir}/${config.latest}`)){
    fs.mkdirSync(`${versionsDir}/${config.latest}`);
}

fs.copyFileSync(`./${examplesDir}/${config.latest}.json`, `./${exampleFile}`);

fs.copyFileSync(`./${examplesDir}/${config.latest}.json`, `./${versionsDir}/${config.latest}/example.json`);

fs.copyFileSync(`./${schemaFile}`, `./${versionsDir}/${config.latest}/schema.json`);