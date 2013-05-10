
try {
    module.exports = require('./compiled');
} catch(error) {
    //require('./node_modules/coffee-script');
    require('coffee-script');
    module.exports = require('./lib');
}
