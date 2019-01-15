package docsearcher.manifold;

public class RepositoryFactory
{
	protected enum RepositoryType {
		FILESYSTEM,
		UNKNOWN
	}
		
	// Return a FilesystemConnector, or some other repository connector.
	//
	// Example repository description:
	//		"name=repo1|type=filesystem"
	//
	public static RepositoryConnector getRepository(String desc)
	{
		String[] arrOfStr = desc.split("\\|", 0); 
		if (arrOfStr.length < 1) 
			throw new IllegalArgumentException(String.format("bad description (%s)", desc));
  
		RepositoryType repositoryType = RepositoryType.UNKNOWN;
		String repositoryName = null;
		
		// Examine each name value pair.
		for (String a : arrOfStr) {
			
			String[] name_value = a.split("=", 2);
			if (name_value.length != 2)
				throw new IllegalArgumentException(String.format("bad name value pair (%s) in description (%s)", a, desc));
			String name  = name_value[0];
			String value = name_value[1];
			
			if ("name".equalsIgnoreCase(name)) {
				repositoryName = value.toLowerCase();
			}
			else
			if ("type".equalsIgnoreCase(name)) {
				if ("filesystem".equalsIgnoreCase(value))
					repositoryType = RepositoryType.FILESYSTEM;
				else
					throw new IllegalArgumentException(String.format("bad repository type (%s) in description (%s)", value, desc));
			}
		}
		
		if (repositoryType != RepositoryType.FILESYSTEM || repositoryName == null)
			throw new IllegalArgumentException(String.format("bad repository description (%s)", desc));

		if (repositoryType == RepositoryType.FILESYSTEM) {
			return new FilesystemConnector(repositoryName);
		}
		
		return null;
	}
}