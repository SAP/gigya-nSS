import {exampleFile, examplesDir, exampleDevFile, outputDir} from "./env";
const {version} = require('./package.json');
const {argv} = require('yargs');



const fs = require('fs');

fs.readFile('version.txt', 'utf8', function (err,data) {
    if (err) {
        return console.log(err);
    }

    console.log(`~~~ copying example file of nSS ${data}...`);

    fs.copyFileSync(`./${examplesDir}/${data}.json`, `./${exampleFile}`);

});

