var config = module.exports;

config["BuildTest"] = {
    //rootPath: ".",
    environment: "node", // or "node" or "browser"
    // Paths are relative to config file 
    tests: [
        "src/test/javascript/buster_test.js"
    ]
};