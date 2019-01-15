package docsearcher.manifold;

public class SolrConnector implements OutputConnector
{
	private final String name;
	private final String outputType = "solr";
	private final String coreName;
	
	protected SolrConnector(String name, String coreName) {
		this.name = name;
		this.coreName = coreName;
	}
	
	public String getName() { return this.name; }
	public String getType() { return this.outputType; }
	public String getCoreName() { return this.coreName; }
	
	public String toString() 
	{
		StringBuilder sb = new StringBuilder(String.format("Output: %s\n", this.name));
		sb.append(String.format("  type=%s\n", this.outputType));
		sb.append(String.format("  core=%s\n", this.coreName));
		return sb.toString();
	}
}