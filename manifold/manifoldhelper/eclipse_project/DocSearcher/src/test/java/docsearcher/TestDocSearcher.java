package docsearcher;

import org.junit.*;
import static org.junit.Assert.*;

public class TestDocSearcher
{
	@Test
	public void testUsage()
	{
		assertSame("usage: java -jar docsearcher", DocSearcher.usage());
	}
}