package org.phodifle.analyzer.model;

import java.util.Collection;
import java.util.LinkedHashMap;

import org.phodifle.analyzer.charts.PraatChart;
import org.phodifle.analyzer.model.mean.Entity;
import org.phodifle.analyzer.model.mean.SampleMean;
import org.phodifle.analyzer.model.mean.SampleMeans;
import org.phodifle.analyzer.util.Util;

public class Analyze {
	private LinkedHashMap<String, Locutor> locutors;
	
	public Analyze() {
		locutors = new LinkedHashMap<String, Locutor>(10);
	}
	
//	private Random rand = new Random(123457654);
	
	public Locutor getLocutor(String name) {
		Locutor locutor = locutors.get(name);
		if (locutor == null) {
			locutor = new Locutor(name);
//			locutor.setColor(new Color(rand.nextInt(256), rand.nextInt(256), rand.nextInt(256)));
			locutors.put(name, locutor);
		}
		return locutor;
	}
	
	public Collection<Locutor> getLocutors() {
		return locutors.values();
	}

	public String toXML() {
		StringBuffer sb = new StringBuffer();
		sb.append("<analyze>");
		for (Locutor locutor : locutors.values()) {
			sb.append("\n\t");
			sb.append(locutor.toXML());
		}
		sb.append("</analyze>\n");
		return sb.toString();
	}

	public String meansToXML() {
		StringBuffer sb = new StringBuffer();
		sb.append("<means>");
//		for (SampleMean mean : means.values()) {
//			if (mean.getTierName().equals(Tier.TIER_ORTHO)) {
//				sb.append("\n\t");
//				sb.append(mean.toXML());
//			}
//		}
		sb.append("</means>\n");
		return sb.toString();
	}
	
	private void normalize() {
		System.out.println(">>> NORMALIZATION");
		//normalize sample.duration for all tiers/locutors
		for (Locutor loc: getLocutors()) {
			for (Tier tier: loc.getTiers()) {
//				System.out.println("LOC :: "+loc.getName()+" TIER::"+tier.getName());
				tier.normalize();
			}
		}
	}
	
	SampleMean meanTotal;
	public void compute() {
		System.out.println(">>> COMPUTE");
		normalize();
		SampleMean temp = new SampleMean("All the T3 samples");
		for (Locutor loc: getLocutors()) {
			compute(temp, loc, loc.getTier(Tier.TIER_ORTHO));
		}
		// KEEP ONLY ORTHO WITH SYLLABLES
		meanTotal = new SampleMean("All the T3 samples");
		for (SampleMean child: temp.getChilds().values()) {
			if (child.getChilds().size()>0) {
				meanTotal.getChilds().put(child.getLabel(), child);
			}
		}
		
	}
	
	private void compute(SampleMean mean, Locutor loc, Tier tier) {
		compute(mean, loc, tier, null);
	}

	int cpt = 0;
	private void compute(SampleMean mean, Locutor loc, Tier tier, Sample sampleParent) {
		cpt++;
//		System.out.println(">>> COMPUTE");
		for (Sample sample: tier.getSamples()) {
			boolean isChild = true;
			if (sampleParent!=null) {
//				String plabel = "PARENT : "+sampleParent.getLabel(); 
				float pstart = sampleParent.getStart()-1f;
				float pend = sampleParent.getEnd()+1f;
//				if (tier.equals(Tier.TIER_SYLL)) pend += 1f;
//				String label = "CHILD : "+ sample.getLabel();
				float start = sample.getStart();
				float end = sample.getEnd();
				isChild = (start>=pstart && end<=pend) ;
//				if (plabel.startsWith("PARENT : A či je ")) {
//					int i=1;
//				}
			}
			if (isChild) {
				/* Find Unique Label :
				 * If phonem : Parent Syllale label + Phonem label
				 * If syllable : Syllable label
				 * If ortho : Ortho label + Syllable label
				 */
				String label = sample.getLabel();
				if (tier.getName().equals(Tier.TIER_PHONO)) {
//					Sample parent = Util.getContainer(sample, loc.getTier(Tier.TIER_SYLL).getSamples());
//					if (parent!=null) {
					label = sampleParent.getLabel()+":"+label;
//					}
				} else if (tier.getName().equals(Tier.TIER_ORTHO)) {
					Sample firstChild = Util.getFirstChild(sample, loc.getTier(Tier.TIER_SYLL).getSamples());
					if (firstChild!=null) {
						label = label + ":" + firstChild.getLabel();
					}
				}
				// End Unique Label
				SampleMeans childs = mean.getChilds(); 
				SampleMean smean = childs.get(label);
				if (smean==null) {
					smean = new SampleMean(label);
					childs.put(label, smean);
				}
//				System.out.println(cpt+":: L"+loc.getName()+" : T"+tier.getName()+" : "+mean.getLabel()+" <== "+smean.getLabel());
				Entity entity = new Entity(loc, tier, sample);
				smean.addEntity(entity);
				if (tier.getName().equals(Tier.TIER_ORTHO)) {
					compute(smean, loc, loc.getTier(Tier.TIER_SYLL), sample);
				} else if (tier.getName().equals(Tier.TIER_SYLL)) {
					compute(smean, loc, loc.getTier(Tier.TIER_PHONO), sample);
				}
			}
			
		}

	}
	
	public String printMeanTotal() {
		return meanTotal.toXML();
	}

	public void generatePNG(int scale, int factorF0) {
		System.out.println(">>> GENERATE PNG CHARTS");
		boolean debug = false;
		PraatChart chart = new PraatChart(scale, factorF0);
		if (debug) {
			SampleMean mean = (SampleMean)meanTotal.getChilds().values().toArray()[0];
			chart.generateChart(mean);
			chart.exportPNGImage("out/debug.png");
		} else {
			int i=0;
			for (SampleMean mean : meanTotal.getChilds().values()) {
				i++;
				String file = Util.cleanString(mean.getLabel());
				System.out.println(">>>>>> GENERATE CHART "+i+" : "+mean.getLabel()+" : "+file);
				chart.generateChart(mean);
				chart.exportPNGImage("out/"+file+"-"+i+".png");
			}
		}
		
	}


	
}
