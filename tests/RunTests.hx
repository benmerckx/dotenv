import dotenv.Env;

using buddy.Should;

class EnvLoad {
	public static var SIMPLE: String;
	public static var INTVAL: Int;
	public static var FLOATVAL: Float;
	public static var BOOLVAL: Bool;
	public static var INTERPOLATE: String;
	public static var MULTILINE: String;
	public static var OPTIONAL: Null<String>;
	@:default(3306)
	public static var DEFAULTVAL: Int;
	
	static function __init__() Env.init({overload: true});
}

@colorize
class RunTests extends buddy.SingleSuite {

	public function new() {
		describe('dotenv', {
			it('should have parsed string values', {
				EnvLoad.SIMPLE.should.be('VALUE');
			});
			
			it('should have parsed int values', {
				EnvLoad.INTVAL.should.be(123);
			});
			
			it('should have parsed float values', {
				EnvLoad.FLOATVAL.should.be(.5);
			});
			
			it('should have parsed boolean values', {
				EnvLoad.BOOLVAL.should.be(true);
			});
			
			it('should have parsed multiline string values', {
				EnvLoad.MULTILINE.should.be("multiline\nencoded");
			});
			
			it('should have parsed multiline string values', {
				EnvLoad.MULTILINE.should.be("multiline\nencoded");
			});
			it('should have set the default value', {
				EnvLoad.DEFAULTVAL.should.be(3306);
			});
		});
	}
  
}