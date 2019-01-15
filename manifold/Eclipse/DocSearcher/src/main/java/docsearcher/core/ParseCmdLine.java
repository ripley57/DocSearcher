package docsearcher.core;

import gnu.getopt.LongOpt;
import gnu.getopt.Getopt;

public class ParseCmdLine
{
	private static void usage()
	{
		System.err.println(
			"																						\n" +
		    "Description:																			\n" +
			"   Automate the generation of Manifold-CF jobs for crawling filesytstem directories.	\n" + 
			"																						\n" +
			"Usage examples:																		\n" +
			"																						\n" +
			"   Create a Manifold filesystem repository connector:									\n" +
			"      java -jar docsearcher.jar --repository \"name=repo1|type=filesystem\"			\n" +
			"																						\n" +
			"   Create a Manifold Solr output connector:											\n" +
			"      java -jar docsearcher.jar --output \"name=output1|type=solr|core=core1\"			\n" +
			"																						\n" +
			"   Create a Manifold job specifying repository, output, and the filesystem paths:		\n" +
			"      java -jar docsearcher.jar --job 													\n" +
			"               \"repository=repo1|output=output1|path=d:/dir1|path=d:/dir2|depth=2\"	\n" +
			"																						\n"
		);
	}
	
	public static boolean parse(String progName, String[] argv, RunContext runCtx)
	{
		boolean invalidArgs = false; 
		
		LongOpt[] longopts = new LongOpt[4];
		longopts[0] = new LongOpt("help", 		LongOpt.NO_ARGUMENT,		null, 'h');	// This option will return 'h'.
		longopts[1] = new LongOpt("job", 		LongOpt.REQUIRED_ARGUMENT, 	null, 'j');	// This option will return 'j'.
		longopts[2] = new LongOpt("repository", LongOpt.REQUIRED_ARGUMENT, 	null, 'r');	// This option will return 'r'.
		longopts[3] = new LongOpt("output", 	LongOpt.REQUIRED_ARGUMENT, 	null, 'o');	// This option will return 'o'.
		
		Getopt g = new Getopt(progName, argv, "hj:", longopts, true);
		
		int c;
		String arg;
		while ((c = g.getopt()) != -1) {
			switch(c) {
			case 'h': 
				invalidArgs = true;	// Display help later.
				break;
				
			case 'j':
				arg = g.getOptarg();
				runCtx.addJob(arg);
				break;
				
			case 'r':
				arg = g.getOptarg();
				runCtx.addRepository(arg);
				break;
				
			case 'o':
				arg = g.getOptarg();
				runCtx.addOutput(arg);
				break;
				
			case '?': // An invalid option was encountered.
				invalidArgs = true;
				break;
				
			default:
			}
		}
		
		if (invalidArgs)
			usage();	
				
		return !invalidArgs;
	}
}
