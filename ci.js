kit = require('nokit');
which = require('which');
fs = require('nofs');

console.log("TEST START");
console.log("NPM PATH: " + fs.realpathSync(which.sync('npm')));
kit.spawn('npm-up', ['-a']).then(function(){
    kit.spawn('npm-up', ['-g'])
}).then(function(){
    console.log('done');
}, function(){
    console.error('fail');
    process.exit(1);
});
