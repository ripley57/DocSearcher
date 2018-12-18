package docsearcher;

import org.apache.log4j.Logger;

public class DocSearcher
{
	static Logger logger = Logger.getLogger(DocSearcher.class);
	
	public static void main(String[] args)
	{
		System.err.println(DocSearcher.usage());
	}	
	
	protected static String usage()
	{
		logger.info("INFO: usage() called");
		
		return "usage: java -jar docsearcher";
	}
}