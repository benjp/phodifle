package org.phodifle.analyzer.model.mean;

import java.util.ArrayList;
import java.util.LinkedHashMap;

import org.phodifle.analyzer.model.Locutor;
import org.phodifle.analyzer.model.Sample;
import org.phodifle.analyzer.util.Util;


public class SampleMean {
	
	private String label;

	private Entities entities;
	
	private SampleMeans childs;
	
//	private float meanDuration; //Calculate from entities durations

	public SampleMean(String label) {
		this.label = label;
		this.childs = new SampleMeans();
		this.entities = new Entities();
	}
	
	public String getLabel() {
		return this.label;
	}
	
	public void addEntity(Entity entity) {
		this.entities.add(entity);
	}
	
	public SampleMeans getChilds() {
		return childs;
	}
	
	public Entities getEntities() {
		return entities;
	}
	
	public LinkedHashMap<String, Locutor> getChildLocutors() {
		LinkedHashMap<String, Locutor> locutors = new LinkedHashMap<String, Locutor>();
		for (SampleMean child: getChilds().values()) {
			for (Locutor loc: child.getEntities().getLocutors().values()) {
				if (!locutors.containsKey(loc.getName())) {
					locutors.put(loc.getName(), loc);
				}
			}
		}
		
		return locutors;
	}

	
	public float getMeanDuration() {
		ArrayList<Float> values = new ArrayList<Float>();
		for (Entity entity: entities) {
			Sample sample = entity.getSample();
			if (sample.getNormDuration()!=Sample.UNDEFINED) {
				values.add(sample.getNormDuration());
			}
		}
		return Util.getMean(values);
	}
	
	public float getTotalChildsMeanDuration() {
		float total = 0f;
		for (SampleMean child: getChilds().values()) {
			total += child.getMeanDuration();
		}
		return total;
	}

	public float getMeanF0(int i) {
		return getMeanF0(i, null);
	}
	
	public float getMeanF0(int i, Locutor locutor) {
		ArrayList<Float> values = new ArrayList<Float>();
		String locName = null;
		if (locutor!=null) locName = locutor.getName();
		for (Entity entity: entities) {
			Sample sample = entity.getSample();
			if (locName == null || entity.getLocutor().getName().equals(locName)) {
				if (sample.getNormF0()[i]!=Sample.UNDEFINED) {
					values.add(sample.getNormF0()[i]);
				}
			}
		}
		return Util.getMean(values);
	}
	
	/*
	
	public float getMeanDuration() {
		return totalDuration/iDuration;
	}
	
	public void addSamplesIfInside(Collection<SampleMean> samples) {
		for (SampleMean sample: samples) {
			int tier = new Integer(tierName).intValue();
			int subtier = new Integer(sample.getTierName()).intValue();
			if (tier>2 && tier==subtier+1) {
				float start = this.getStart();
				float substart = sample.getStart();
				float end = start+this.getDuration()/1000+0.001f;
				float subend = sample.getStart()+sample.getDuration()/1000;
				boolean inside = (substart>=start && subend<=end);
//				System.out.println(sample.getLabel() + "==>" + this.getLabel() + " : "+inside);
				if (inside) {
					subSamples.put(sample.getStart(), sample);
				}
			}
			
		}
		
	}
	*/
	
	public String toXML() {
		StringBuffer sb = new StringBuffer();
		sb.append("\n");
		boolean print = true;
//		if (!label.contains(":")) {
//			if (childs.size()<3) print = false;
//		}
		
		if (print) {
			sb.append("<samplemean label=\""+label+"\">");
			float md = getMeanDuration();
			if (md!=0.0f) sb.append("\n\t<duration>"+md+"</duration>");
			for (int i=0 ; i<3 ; i++) {
				float mf = getMeanF0(i);
				if (mf!=0.0f && !"NaN".equals(""+mf)) sb.append("\n\t<f0 i=\""+i+"\">"+mf+"</f0>");
			}
	
			if (entities.size()>0) {
				sb.append("\n\t<entities quantity=\""+entities.size()+"\">");
				if (label.equals("11")) {
					for (Entity entity : entities) {
						sb.append("\n\t");
						sb.append(entity.toXML());
					}
				}
				sb.append("\n\t</entities>");
			}

			if (childs.size()>0) {
				sb.append("\n\t<childs>");
				for (SampleMean child : childs.values()) {
					sb.append("\n\t");
					sb.append(child.toXML());
				}
				sb.append("\n\t</childs>");
			}
	
			sb.append("</samplemean>\n");
		}
		return sb.toString();
	}

}
