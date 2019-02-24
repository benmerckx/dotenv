# dotenv

[![Build Status](https://travis-ci.org/benmerckx/dotenv.svg?branch=master)](https://travis-ci.org/benmerckx/dotenv)

Loads environment variables into class' statics. Variables will be loaded from a '.env' file, if one exists. Any existing environment variables will not be overwritten (unless specified by the `overloaded` option).

```haxe
class DatabaseConfig {
	public static var DB_NAME: String;
	public static var DB_USER: String;
	public static var DB_PASS: String;
	public static var DB_HOST: String;
	public static var DB_PORT: Int;
	
	static function __init__() dotenv.Env.init();
}
```

Can be initialized from the following '.env' file:

```
# Comments are allowed
DB_NAME=name
DB_USER=user
DB_PASS=pass
DB_HOST=host
DB_PORT=3306
```

Dotenv does not actually set these values as environment variables as some targets (java, lua) do not support this.

#### Types

A variable can be typed as String, Int, Float or Bool (you can use `true` and `false`).

#### Optional

Optional values can be denoted using `Null<T>`. Non-optional values will throw if not found in the environment.

```haxe
public static var DB_PORT: Null<Int>;
```

#### Defaults

Default values can be set using metadata:
	
```haxe
@:default(3306)
public static var DB_PORT: Int;
```

#### Multiline

Multiline strings can be encoded by using quotes:

```
MULTILINE="multiline\nencoded"
```

#### Options

Init takes these options:

```haxe
typedef EnvOptions = {
	?overloaded: Bool, // Overwrite existing environment variables by the .env file
	?path: String,   // Specify a different path for loading the file
	?throws: Bool    // Defaults to true, throws if a variable is missing
}
```