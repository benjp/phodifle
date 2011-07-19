package org.phodifle.analyzer.model.mean;

import java.util.ArrayList;
import java.util.LinkedHashMap;

import org.phodifle.analyzer.model.Locutor;

public class Entities extends ArrayList<Entity>{

	/**
	 * 
	 */
	private static final long serialVersionUID = 8771329099237810127L;
	
	public LinkedHashMap<String, Locutor> getLocutors() {
		LinkedHashMap<String, Locutor> locutors = new LinkedHashMap<String, Locutor>();
		for (Entity entity: this) {
			Locutor loc = entity.getLocutor();
			if (!locutors.containsKey(loc.getName())) {
				locutors.put(loc.getName(), loc);
			}
		}
		
		return locutors;
	}

}
