const path = require('path');

module.exports = {
  resolve: {
    alias: {
    'JS': path.resolve(__dirname, '../../app/javascript/application/javascripts'),
    'CSS': path.resolve(__dirname, '../../app/javascript/application/stylesheets'),
    'COMPONENTS': path.resolve(__dirname, '../../app/components'),
    'IMAGES': path.resolve(__dirname, '../../app/javascript/application/images'),
    'react': path.resolve(__dirname, '../../node_modules', 'react')
    }
  }
}
