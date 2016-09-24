package dotenv;

import haxe.ds.StringMap;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using StringTools;

typedef EnvOptions = {
	?overload: Bool,
	?path: String
}

class Env implements Dynamic {
	
	static var initializedPos: Position = null;
		
	macro public static function init(?options: EnvOptions) {
		var local: ClassType = Context.getLocalClass().get();
		var assignments: Array<Expr> = [];
		
		for (field in local.statics.get())
			switch field.kind {
				case FVar(read, write):
					var name = field.name, 
						wrap: Expr -> Expr,
						nameStr = macro $v{name};
					var wrap: Expr -> Expr = switch field.type {
						case TAbstract(_.get() => abstr, []) if (abstr.name == 'Int'):
							function(e)
								return macro Std.parseInt($e);
						case TAbstract(_.get() => abstr, []) if (abstr.name == 'Float'):
							function(e)
								return macro Std.parseFloat($e);
						case TAbstract(_.get() => abstr, []) if (abstr.name == 'Bool'):
							function(e)
								return macro $e == 'true';
						default:
							function(e)
								return e;
					}
					assignments.push(macro @:pos(field.pos) {
						var t = Sys.getEnv($nameStr);
						if (t != null)
							$i{name} = ${wrap(macro t)};
						else if (parsed.exists($v{name}))
							$i{name} = ${wrap(macro parsed.get($nameStr))};
						else
							throw 'Undefined environment variable: '+$nameStr;
					});
				default:
			}
			
		if (options == null) 
			options = {};
		if (options.path == null)
			options.path = '.env';
		if (options.overload == null)
			options.overload = false;
		
		return macro {
			var options = $v{options},
				parsed = dotenv.Env.parse(options,
					#if nodejs 
					js.node.Fs.readFileSync(options.path, {encoding: 'utf-8'})
					#else
					sys.io.File.getContent(options.path)
					#end
				);
			$b{assignments};
		}
	}
	
	public static function parse(options: EnvOptions, content: String): Map<String, String> {
		var result = new StringMap();
		var matcher = ~/^\s*([\w\.\-]+)\s*=\s*(.*)?\s*$/;
		for (line in content.split('\n')) {
			if (matcher.match(line)) {
				var key = matcher.matched(1).trim(),
					value = matcher.matched(2);
				if (!options.overload && Sys.getEnv(key) != null) 
					continue;
				value = value == null ? '' : value;
				value = value.trim();
				if (value.length > 0 && value.charAt(0) == '"' && value.charAt(value.length - 1) == '"') {
					value = value.replace('\\n', '\n');
					value = value.substr(1, value.length - 2);
				}
				result.set(key, value);
			}
		}
		return result;
	}
	
}