const { environment } = require('@rails/webpacker')
const { resolve, basename, extname } = require('path')
const { safeLoad } = require('js-yaml')
const { readFileSync } = require('fs')

const filePath = resolve('config', 'slickr.yml')
const config = safeLoad(readFileSync(filePath), 'utf8')[process.env.NODE_ENV]
const { include_webpacks } = config

const fs = require('fs')

const erb =  require('./loaders/erb')

// Helper function - add item to array (nondescructive)
const insert = (arr, index, newItem) => [
  ...arr.slice(0, index),
  newItem,
  ...arr.slice(index)
]

// Add ERB Loader
environment.loaders.append('erb', erb)

const babelLoader = environment.loaders.get('babel')
babelLoader.exclude = /node_modules\/(?!(slickr_cms)\/).*/

environment.loaders.push({key: 'babelrc', value: { test: /\.babelrc$/, loader: 'ignore-loader' }})

// Add SVG Transform Loader
environment.loaders.push({key: 'svg-transform-loader', value: { test: /\.svg$/, loader: 'svg-transform-loader' }})


// Add SVG Transform Loader to SASS Loader
environment.loaders.get('sass')
  .use = insert(
    environment.loaders.get('sass').use,
    4,
    { loader: 'svg-transform-loader/encode-query' }
  )

// Add custom paths to SASS Loader
environment.loaders.get('sass')
  .use.find(item => item.loader === 'sass-loader').options
  .includePaths = [
    __dirname,
    resolve("app", "javascript", "application", "stylesheets"),
    resolve("app", "components")
  ]

// Add core SCSS to SASS Loader
environment.loaders.get('sass')
  .use.find(item => item.loader === 'sass-loader').options
  .data = `@import "core/index.scss";`


environment.toWebpackConfigForRailsEngine = function() {
  const config = environment.toWebpackConfig()

  Object.keys(include_webpacks).forEach(function(key) {
    const val = this[key]
    const enginePath = `${__dirname}/../../node_modules/${key}/`
    const filePath = `${enginePath}${val}`
    const files = fs.readdirSync(filePath)
    files.forEach(function(file){
      const fullPath = `${filePath}/${file}`
      config.entry[`${basename(fullPath, extname(fullPath))}`] = fullPath
    })
  }, include_webpacks)

  return config
}

module.exports = environment
