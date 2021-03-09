# nSS Schema
## Available Scripts
```npm
npm run build
npm run test
npm run createExample
npm run release // runs build + test + createExample
npm run deploy --awsAccessKey=### --awsSecret=###  // deploys output to aws s3
```

## Releasing a new version
* Change the `package.json`'s `version` property according to the nSS release.
* Add to the `examples` directory a new file according to the version
    * e.g: `examples/1.0.0.json`
    * This will be used for:
        * Tests
        * Example file to be deployed
* Run `npm run release && npm run deploy` with the relevant credentials.

## Tests
Test cases are dynamically added by adding new json files to the `spec/` directory:
* Acceptance Tests (should pass schema validation):
    * Add valid nSS jsons to `spec/valid/` directory.
    * Alternatively add another example to the `examples/` directory.
* Negative Tests (should fail schema validation):
    * Add invalid nSS jsons to `spec/invalid/` directory.

## Development
### Important Concepts
TODO: `deepMerge` vs `allOf`

### Important Entities
#### `SchemaEntity`
`export const entity = new SchemaEntity('path/to/refKey', {} as JSONSchema);`
* When creating a new instance of this class, it'll automatically be added to the schema's `definitions`.
* You can get a schema referencing the entity's type by importing it and `entity.getRef()`.

#### `StyleProperty`
`export const styleProp = new StyleProperty('prop', {} as JSONSchema);`
* Extends `SchemaEntity` so creating a new instance also joins the schema's `definitions` - but always under the `styles` path.
* To assign the relevant style properties: `withStyle(margin, size, ...)`.