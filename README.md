# dotenv

[![Build Status](https://travis-ci.org/benmerckx/dotenv.svg?branch=master)](https://travis-ci.org/benmerckx/dotenv)

````haxe
class DotEnv {
	// Find value via getEnv, else try any value parsed by load(),
	// else return byDefault
	static function env(name: String, ?byDefault: Stringly): tink.Stringly;
	// Load values from .env file
	static function load(path = '.', filename = '.env'): Void;
	// Parse .env file contents
	static function parse(contents: String): Map<String, String>;
}
````
