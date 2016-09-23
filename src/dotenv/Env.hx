package dotenv;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.ExprTools;

using StringTools;

typedef EnvOptions = {
	?overload: Bool,
	?path: String
}

@:forward
abstract EnvType(Map<String, Type>) from Map<String, Type> {
	
	inline function new()
		this = new Map();
		
	static inline function exprToType(expr: Expr): Type {
		var ident = ExprTools.toString(expr);
		return 
			try Context.follow(Context.getType(ident))
			catch (e: Dynamic) 
				throw Context.warning('Type not found: '+ident, expr.pos);
	}
	
	@:from inline static function fromExpr(expr: Expr): EnvType
		return switch expr.expr {
			case EObjectDecl(fields): [
				for (field in fields)
					field.field => exprToType(field.expr)
			];
			default:
				switch exprToType(expr) {
					case TAnonymous(_.get() => obj): [
						for (field in obj.fields)
							field.name => field.type
					];
					default: 
						throw Context.warning('Anonymous type expected', expr.pos);
				}
		}
	
}

class Env implements Dynamic {
	
	static var initializedPos: Position = null;
		
	macro public static function init(typeExpr: Expr, ?options: EnvOptions) {
		if (initializedPos != null)
			Context.warning('Env was already initialized here: '+initializedPos, typeExpr.pos);
		
		initializedPos = typeExpr.pos;
		
		var type: EnvType = typeExpr;
		
		if (options == null) 
			options = {};
		if (options.path == null)
			options.path = '.env';
		if (options.overload == null)
			options.overload = false;
		
		return macro @:pos(typeExpr.pos) {
			var options = $v{options};
			dotenv.Env.parse(options,
				#if nodejs 
				js.node.Fs.readFileSync(options.path, {encoding: 'utf-8'})
				#else
				sys.io.File.getContent(options.path)
				#end
			);
		}
	}
	
	public static function parse(options: EnvOptions, content: String) {
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
				Sys.putEnv(key, value);
			}
		}
	}
	
}