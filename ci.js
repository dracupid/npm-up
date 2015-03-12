kit = require('nokit');
npm = require('./dist/npm')
process.env.DEBUG = 'on'

console.log("TEST START");
console.log("NPM PATH: " + npm.GLOBAL_NPM_PATH);
kit.spawn('npm-up', ['-a']).then(function(){
    kit.spawn('npm-up', ['-g'])
}).then(function(){
    kit.spawn('npm-up', ['-A', '-c', 'node_modules', '--no-warning'])
}).then(function(){
    kit.spawn('npm-up', ['dump'])
}).then(function(){
    kit.spawn('npm-up', ['clean'])
}).then(function(){
    console.log('done');
}, function(){
    console.error('fail');
    process.exit(1);
});
