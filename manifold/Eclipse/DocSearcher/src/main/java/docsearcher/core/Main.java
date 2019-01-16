package docsearcher.core;

import org.apache.log4j.*;

public class Main
{
	static Logger logger = Logger.getLogger(Main.class);

	private static String progName = "docsearcher";

	public static void main(String[] args) {
		logger.debug("DEBUG Main::main() Entering ...");
		
		RunContext ctx = new RunContext();
		ParseCmdLine.parse(progName, args, ctx);
		
		ctx.dumpRepositories();
		ctx.dumpOutputs();
		ctx.dumpJobs();
		
		logger.debug("DEBUG Main::main() Exiting ...");
     }
}
