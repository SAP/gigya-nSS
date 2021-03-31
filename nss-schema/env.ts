const path = require('path');
export const outputDir = 'output';
export const examplesDir = 'examples';
export const schemaFile = path.join(outputDir, 'nSS-schema.json');
export const exampleFile = path.join(outputDir, 'example.json');
export const exampleDevFile = path.join(outputDir, 'develop/example.json');
export const versionsDir = path.join(outputDir, 'versions/');

const fs = require('fs');
export function getJsonFiles(dir: string, excludeFiles: string[] = []) {
    console.log('~~~', path.join(__dirname, dir));

    if (!fs.existsSync(examplesDir)){
        fs.mkdirSync(examplesDir);
    }

    return fs.readdirSync(path.join(__dirname, dir))
        .filter(file => file.match(/.*\.json$/) && !excludeFiles.find(ex => file.startsWith(ex)))
        .map(file => path.join(dir,file));
}

export function getVersionConfig() {
    return JSON.parse(fs.readFileSync(`${outputDir}/versions/ver.json`, 'utf8'));
}