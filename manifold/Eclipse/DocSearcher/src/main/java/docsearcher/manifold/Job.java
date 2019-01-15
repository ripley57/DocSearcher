package docsearcher.manifold;

import java.util.ArrayList;
import java.util.List;

public class Job
{
	private String name = null;
	private String repositoryName = null;
	private String outputName = null;
	private List<String> subPaths = new ArrayList<String>();

	public 	Job(String name, String repositoryName, String outputName, List<String> subPaths)
	{
		this.name = name;
		this.repositoryName = repositoryName;
		this.outputName = outputName;
		this.subPaths = subPaths;
	}
	
	public String toString() 
	{
		StringBuilder sb = new StringBuilder(String.format("Job: %s\n", this.name));
		sb.append(String.format("  repository=%s\n", this.repositoryName));
		sb.append(String.format("  output=%s\n", this.outputName));
		sb.append("  Paths:\n");
		for (String p : subPaths) 
			sb.append("    " + p + "\n");
		return sb.toString();
	}
}
	