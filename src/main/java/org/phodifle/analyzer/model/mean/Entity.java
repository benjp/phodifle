package org.phodifle.analyzer.model.mean;

import org.phodifle.analyzer.model.Locutor;
import org.phodifle.analyzer.model.Sample;
import org.phodifle.analyzer.model.Tier;

public class Entity {

	private Locutor locutor;
	private Tier tier;
	private Sample sample;
	
	public Entity(Locutor loc, Tier tier, Sample sample) {
		this.locutor = loc;
		this.tier = tier;
		this.sample = sample;
	}
	
	public Locutor getLocutor() {
		return locutor;
	}
	public Tier getTier() {
		return tier;
	}
	public Sample getSample() {
		return sample;
	}
	
	public String toXML() {
		StringBuffer sb = new StringBuffer();
		sb.append("\n");
//		boolean print = true;
		sb.append("<entity loc=\""+locutor.getName()+"\" tier=\""+tier.getName()+"\" sample=\""+sample.getLabel()+"\">");
		sb.append(sample.toXML());
		sb.append("</entity>\n");
		
		return sb.toString();
	}
	
}
