kit = require('nokit');

kit.spawn('npm-up', ['-a']).then(function(){
    kit.spawn('npm-up', ['-g'])
}).then(function(){
    console.log('done');
}, function(){
    console.error('fail');
    process.exit(1);
});
