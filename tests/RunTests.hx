import dotenv.Env;

import haxe.io.Bytes;

typedef EnvInfo = {
	A: String
}

@colorize
class RunTests extends buddy.SingleSuite {

	public function new() {
		describe('dotenv', {
			it('should parse .env file', {
				Env.init(EnvInfo);
				trace(Sys.getEnv('INTERPOLATE'));
			});
		});
	}
  
}