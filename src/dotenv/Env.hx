package dotenv;

import haxe.ds.StringMap;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using StringTools;
using haxe.macro.Type.MetaAccess;

typedef EnvOptions = {
	?overloaded: Bool,
	?path: String,
	?throws: Bool
}

class Env {
	
	static function unwrapType(type: Type): {optional: Bool, wrap: Expr -> Expr}
		return switch type {
			case TType(_.get() => {name: 'Null', pack: []}, [underlying]):
				{optional: true, wrap: unwrapType(underlying).wrap}
			case TAbstract(_.get() => {name: 'Int', pack: []}, []):
				{optional: false, wrap: function(e) return macro Std.parseInt($e)}
			case TAbstract(_.get() => {name: 'Float', pack: []}, []):
				{optional: false, wrap: function(e) return macro Std.parseFloat($e)}
			case TAbstract(_.get() => {name: 'Bool', pack: []}, []):
				{optional: false, wrap: function(e) return macro $e == 'true'}
			default:
				{optional: false, wrap: function(e) return e}
		}
		
	macro public static function init(?options: EnvOptions) {
		var local: ClassType = Context.getLocalClass().get();
		var assignments: Array<Expr> = [];
			
		if (options == null) 
			options = {};
		if (options.path == null)
			options.path = '.env';
		if (options.overloaded == null)
			options.overloaded = false;
		if (options.throws == null)
			options.throws = true;
		
		for (field in local.statics.get())
			switch field.kind {
				case FVar(read, write):
					var name = field.name, 
						info = unwrapType(field.type),
						wrap = info.wrap,
						nameStr = macro $v{name},
						finale = 
							if (info.optional)
								null
							else if (field.meta.has(':default')) {
								var meta = field.meta.extract(':default')[0].params[0];
								macro @:pos(meta.pos) $i{name} = $meta;
							} else {
								options.throws
								? macro throw 'Undefined environment variable: '+$nameStr
								: null;
							}
						
					if (options.overloaded)
						assignments.push(macro @:pos(field.pos) {
							var t = Sys.getEnv($nameStr);
							if (parsed.exists($v{name}))
								$i{name} = ${wrap(macro parsed.get($nameStr))}
							else if (t != null)
								$i{name} = ${wrap(macro t)}
							else
								$finale;
						});
					else
						assignments.push(macro @:pos(field.pos) {
							var t = Sys.getEnv($nameStr);
							if (t != null)
								$i{name} = ${wrap(macro t)}
							else if (parsed.exists($v{name}))
								$i{name} = ${wrap(macro parsed.get($nameStr))}
							else
								$finale;
						});
				default:
			}
		
		return macro {
			var options = $v{options},
				parsed = 
				if (
					#if nodejs
					try {
						js.node.Fs.accessSync(options.path);
						true;
					} catch (e: Dynamic) {
						false;
					}
					#else
					sys.FileSystem.exists(options.path)
					#end
				)
					dotenv.Env.parse(options,
						#if nodejs 
						js.node.Fs.readFileSync(options.path, {encoding: 'utf-8'})
						#else
						sys.io.File.getContent(options.path)
						#end
					)
				else 
					new haxe.ds.StringMap<String>();
			$b{assignments};
		}
	}
	
	public static function parse(options: EnvOptions, content: String): haxe.ds.StringMap<String> {
		var result = new StringMap();
		var matcher = ~/^\s*([\w\.\-]+)\s*=\s*(.*)?\s*$/;
		for (line in content.split('\n')) {
			if (matcher.match(line)) {
				var key = matcher.matched(1).trim(),
					value = matcher.matched(2);
				if (!options.overloaded && Sys.getEnv(key) != null) 
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