import {exampleFile, examplesDir} from "./env";
const {version} = require('./package.json');
const {argv} = require('yargs');

const argvVersion = argv.x || version;

console.log(`~~~ copying example file of nSS v${argvVersion}...`);
require('fs').copyFileSync(`./${examplesDir}/${version}.json`, `./${exampleFile}`);