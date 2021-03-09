import {examplesDir, getJsonFiles} from "./env";
const path = require('path');
const existingVersionsExamples = getJsonFiles(examplesDir).map(exm => path.basename(exm).replace(path.extname(exm), ''));
console.log(`exclude:`, existingVersionsExamples);

const request = require('request');
request({
    url: 'https://api.github.com/repos/SAP/gigya-nSS/git/refs/tags',
    headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.129 Safari/537.36',
    }
}, (error, response, body) => {
    if (!error && response.statusCode == 200) {
        const refs = JSON.parse(body) as Array<{ref: string}>;
        const versions =
            refs.map(ref => ref.ref.replace('refs/tags/v', ''))
                .filter(ver => !existingVersionsExamples.includes(ver));

        console.log(versions);

        const fs = require('fs');

        versions.forEach(ver => request({
            url: `https://raw.githubusercontent.com/SAP/gigya-nSS/v${ver}/assets/example.json`
        }, (error, response, body) => {
            fs.writeFile(`./examples/${ver}.json`, body, () => console.log(`~~ created: ${ver}.json`))
        }));
    }
});
