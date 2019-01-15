package docsearcher.manifold;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

public class JobFactory
{
	// Return a Job.
	//
	// Example job description:
	//		"repository=repo1|output=output1|path=d:/dir1|path=d:/dir2|depth=2"
	//
	public static Job getJob(String desc) {

		String[] arrOfStr = desc.split("\\|", 0); 
		if (arrOfStr.length < 1) 
			throw new IllegalArgumentException(String.format("bad description (%s)", desc));
		
		int depth = 0;	// Default to a top-level dir (i.e. don't consider sub-dirs).
		String jobName = null;
		String repositoryName = null;
		String outputName = null;
		
		/*
		** We walk the top-level dirs in "rootPaths", at a depth of "depth", 
		** in order to populate "subPaths" with the final filesystem paths.
		*/
		Set<String> rootPaths = new HashSet<String>(); // Use a Set to avoid duplicates.
		List<String> subPaths = Collections.synchronizedList(new ArrayList<String>());
		
		// Examine each name value pair.
		for (String a : arrOfStr) {
			
			String[] name_value = a.split("=", 2);
			if (name_value.length != 2)
				throw new IllegalArgumentException(String.format("bad name value pair (%s) in description (%s)", a, desc));
			String name  = name_value[0];
			String value = name_value[1];
			
			if ("name".equalsIgnoreCase(name)) {
				jobName = value.toLowerCase();
			}
			else
			if ("repository".equalsIgnoreCase(name)) {
				repositoryName = value.toLowerCase();
			}
			else
			if ("output".equalsIgnoreCase(name)) {
				outputName = value.toLowerCase();
			}
			else
			if ("path".equalsIgnoreCase(name)) {
				rootPaths.add(value);
			}
			else 
			if ("depth".equals(name)) {
				try {
					depth = Integer.parseInt(value);	
				}
				catch (NumberFormatException e) {
					throw new IllegalArgumentException(String.format("bad depth value (%s) in description (%s)", value, desc));
				}
			} 
		}
		
		if (jobName == null || repositoryName == null || outputName == null)
			throw new IllegalArgumentException(String.format("bad job description (%s)", desc));
		
		getSubPaths(rootPaths, subPaths, depth); 
				
		return new Job(jobName, repositoryName, outputName, subPaths);
	}
	
	private static void getSubPaths(Set<String> rootPaths, List<String> subPaths, int depth) 
	{
		for (String path : rootPaths) {
			int rootNameCount = new File(path).toPath().getNameCount();
			try {
				List<Path> dirsFiltered = 
					Files.walk(new File(path).toPath(), depth)
						.filter(p -> (Files.isDirectory(p)))
						.filter(p -> (p.getNameCount() - rootNameCount == depth))
						.collect(Collectors.toList());
						
				for (Path p : dirsFiltered)
					subPaths.add(p.toString());
			}
			catch (IOException e) {
				throw new IllegalArgumentException(String.format("unable to walk directory %s: %s", path, e));
			}
		}
	}
}