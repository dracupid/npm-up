kit = require('nokit');
npm = require('./dist/npm')

console.log("TEST START");
console.log("NPM PATH: " + npm.GLOBAL_NPM_PATH);
kit.spawn('npm-up', ['-a']).then(function(){
    kit.spawn('npm-up', ['-g'])
}).then(function(){
    console.log('done');
}, function(){
    console.error('fail');
    process.exit(1);
});
