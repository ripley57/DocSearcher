package docsearcher.manifold;

public class OutputFactory
{
	protected enum OutputType {
		SOLR,
		UNKNOWN
	}
	
	// Return a SolrConnector, or some other output connector.
	//
	// Example output description:
	//		"name=output1|type=solr|core=core1"
	//
	public static OutputConnector getOutput(String desc)
	{
		String[] arrOfStr = desc.split("\\|", 0); 
		if (arrOfStr.length < 1) 
			throw new IllegalArgumentException(String.format("bad description (%s)", desc));
  
		OutputType outputType = OutputType.UNKNOWN;
		String outputName = null;
		String outputCoreName = null;
		
		// Examine each name value pair.
		for (String a : arrOfStr) {
			
			String[] name_value = a.split("=", 2);
			if (name_value.length != 2)
				throw new IllegalArgumentException(String.format("bad name value pair (%s) in description (%s)", a, desc));
			String name  = name_value[0];
			String value = name_value[1];
			
			if ("name".equalsIgnoreCase(name)) {
				outputName = value.toLowerCase();
			}
			else
			if ("type".equalsIgnoreCase(name)) {
				if ("solr".equalsIgnoreCase(value))
					outputType = OutputType.SOLR;
				else
					throw new IllegalArgumentException(String.format("bad output type (%s) in description (%s)", value, desc));
			}
			else
			if ("core".equalsIgnoreCase(name)) {
				outputCoreName = value.toLowerCase();
			}
		}
		
		if (outputType != OutputType.SOLR || outputName == null || outputCoreName == null)
			throw new IllegalArgumentException(String.format("bad output description (%s)", desc));

		if (outputType == OutputType.SOLR) {
				return new SolrConnector(outputName, outputCoreName);
		}
		
		return null;
	}
	
	
}