
try {
    module.exports = require('./compiled');
} catch(error) {
    //require('./node_modules/coffee-script');
    var CoffeeScript = require('coffee-script');
    CoffeeScript.register();
    module.exports = require('./lib');
}
