import dotenv.DotEnv;
import dotenv.DotEnv.*;
using buddy.Should;

@colorize
class RunTests extends buddy.SingleSuite {

	public function new() {
		load();
		var env = {
			SIMPLE: (env('SIMPLE'): String),
			INTVAL: (env('INTVAL'): Int),
			FLOATVAL: (env('FLOATVAL'): Float),
			BOOLVAL: (env('BOOLVAL'): Bool),
			INTERPOLATE: (env('INTERPOLATE'): String),
			MULTILINE: (env('MULTILINE'): String),
			OPTIONAL: (env('OPTIONAL'): Null<String>),
			DEFAULTVAL: (env('DEFAULTVAL', 3306): Int)
		}
		describe('dotenv', {
			it('should have parsed string values', {
				env.SIMPLE.should.be('VALUE');
			});
			
			it('should have parsed int values', {
				env.INTVAL.should.be(123);
			});
			
			it('should have parsed float values', {
				env.FLOATVAL.should.be(.5);
			});
			
			it('should have parsed boolean values', {
				env.BOOLVAL.should.be(true);
			});
			
			it('should have parsed multiline string values', {
				env.MULTILINE.should.be("multiline\nencoded");
			});
			
			it('should have parsed multiline string values', {
				env.MULTILINE.should.be("multiline\nencoded");
			});
			
			it('should have set the default value', {
				env.DEFAULTVAL.should.be(3306);
			});
		});
	}
  
}