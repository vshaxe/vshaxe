// this is needed for starting server.js with child_process directly
// and not blocking the server.js file for writing, so we can recompile it
// while it's running
require("./bin/server.js");