package docsearcher.manifold;

public class FilesystemConnector implements RepositoryConnector
{
	private final String name;
	private final String repositoryType = "filesystem";
	
	protected FilesystemConnector(String name) {
		this.name = name;
	}
	
	public String getName() { return this.name; }
	public String getType() { return this.repositoryType; }
	
	public String toString() 
	{
		StringBuilder sb = new StringBuilder(String.format("Repository: %s\n", this.name));
		sb.append(String.format("  type=%s\n", this.repositoryType));
		return sb.toString();
	}
}