package org.phodifle.analyzer.model;

import java.awt.Color;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.Random;

public class Locutor {
	private String name;
	private LinkedHashMap<String, Tier> tiers;
//	private LinkedHashMap<String, Sample> sampleTree;
	private Color color;
	
	
	public Locutor(String name) {
		tiers = new LinkedHashMap<String, Tier>(3);
//		sampleTree = new LinkedHashMap<String, Sample>(20);
		this.name = name;
		Random rand = new Random();
		color = new Color(rand.nextInt(256), rand.nextInt(256), rand.nextInt(256), 255);
//		int c = rand.nextInt(256);
//		color = new Color(c, c, c, 255);
	}
	
//	public void setColor(Color c) {
//		color = c;
//	}
	
	public Tier getTier(String name) {
		Tier tier = tiers.get(name);
		if (tier == null) {
			tier = new Tier(name);
			tiers.put(name, tier);
		}
		return tier;
	}

	public Collection<Tier> getTiers() {
		return tiers.values();
	}

	public Color getColor() {
		return color;
	}

	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}

	public String toXML() {
		StringBuffer sb = new StringBuffer();
		sb.append("<locutor name=\""+name+"\">");
		for (Tier tier : tiers.values()) {
			sb.append("\n\t");
			sb.append(tier.toXML());
		}
		sb.append("</locutor>\n");
		return sb.toString();
	}

}
