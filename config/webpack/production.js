process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')
const merge = require('webpack-merge')
const customConfig = require('./custom_webpack')

module.exports = merge(environment.toWebpackConfigForRailsEngine(), customConfig)
