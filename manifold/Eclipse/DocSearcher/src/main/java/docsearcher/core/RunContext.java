package docsearcher.core;

import java.util.List;
import java.util.ArrayList;

import docsearcher.manifold.*;

public class RunContext 
{
		private List<Job> jobs = new ArrayList<Job>();
		private List<RepositoryConnector> repositories = new ArrayList<RepositoryConnector>();
		private List<OutputConnector> outputs = new ArrayList<OutputConnector>();
				
		List<Job> getJobs() { return jobs; }
		List<RepositoryConnector> getRepositories()	{ return repositories; }
		List<OutputConnector> getOutputs() { return outputs; }
				
		public void addJob(String jobDesc) {
			jobs.add(JobFactory.getJob(jobDesc));
		}
		
		public void addRepository(String repositoryDesc) {
			repositories.add(RepositoryFactory.getRepository(repositoryDesc));
		}
		
		public void addOutput(String outputDesc) {
			outputs.add(OutputFactory.getOutput(outputDesc));
		}

		public void dumpJobs() 
		{
			for (Job j : jobs)
				System.err.println("" + j.toString());
		}

		public void dumpRepositories() 
		{
			for (RepositoryConnector r : repositories)
				System.err.println("" + r.toString());
		}
		
		public void dumpOutputs() 
		{
			for (OutputConnector o : outputs)
				System.err.println("" + o.toString());
		}
}