var express = require('express');
var app = express();

app.get('/', function (req, res) {
   res.end("Hi, you're Super Awesome now!");
})

var server = app.listen(8080, function () {

  var port = server.address().port
  console.log("Simple Hello World app listening at port %s", port)

})