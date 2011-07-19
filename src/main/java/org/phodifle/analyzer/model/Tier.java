package org.phodifle.analyzer.model;

import java.util.ArrayList;
import java.util.Collection;

import org.phodifle.analyzer.util.Util;

public class Tier {
	private String name;
	private ArrayList<Sample> samples;
	public static final String TIER_PHONO = "1";
	public static final String TIER_SYLL = "2";
	public static final String TIER_ORTHO = "3";
	private static final String IGNORED_SAMPLE_REGEXP = "^x+$";

	
	public Tier (String name) {
		samples = new ArrayList<Sample>(30);
		this.name = name;
	}

	public void addSample(Sample sample) {
		if (!sample.getLabel().matches(IGNORED_SAMPLE_REGEXP)) {
			this.samples.add(sample);
		}
	}
	
	public Collection<Sample> getSamples() {
		return samples;
	}	

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
	
	public void normalize() {
		if (!name.equals(Tier.TIER_ORTHO))
			normalizeDuration();
		
		if (name.equals(Tier.TIER_SYLL))
			normalizeF0();
	}
	
	public void normalizeDuration() {
		ArrayList<Float> values = new ArrayList<Float>();
		for (Sample sample: samples) {
			if (sample.getDuration()!=Sample.UNDEFINED) {
				values.add(sample.getDuration());
			}
		}
		float M = Util.getMean(values);
		for (Sample sample: samples) {
			if (sample.getDuration()!=Sample.UNDEFINED) {
				sample.setNormDuration(Util.getStandardizeValue(sample.getDuration(), M));
			}
		}
	}
	
	public void normalizeF0() {
		ArrayList<Float> values = new ArrayList<Float>();
		for (int i=0 ; i<3 ; i++) {
			for (Sample sample: samples) {
				if (sample.getF0()[i]!=Sample.UNDEFINED) {
					values.add(sample.getF0()[i]);
				} else {
					sample.setF0Beg(Sample.UNDEFINED);
					sample.setF0Mid(Sample.UNDEFINED);
					sample.setF0End(Sample.UNDEFINED);
				}
			}
		}
		float M = Util.getMean(values);
		float dev = Util.getStandardDeviation(values);
		for (int i=0 ; i<3 ; i++) {
//			ArrayList<Float> values = new ArrayList<Float>();
//			for (Sample sample: samples) {
//				if (sample.getF0()[i]!=Sample.UNDEFINED) {
//					values.add(sample.getF0()[i]);
//				}
//			}
//			float M = Util.getMean(values);
//			float dev = Util.getStandardDeviation(values);
			for (Sample sample: samples) {
				if (sample.getF0()[i]!=Sample.UNDEFINED) {
					sample.setNormF0(Util.getStandardizeValue(sample.getF0()[i], M, dev), i);
				}
			}
		}
	}
	
	public String toXML() {
		StringBuffer sb = new StringBuffer();
		sb.append("<tier name=\""+name+"\">");
		for (Sample sample : samples) {
			sb.append("\n\t");
			sb.append(sample.toXML());
		}
		sb.append("</tier>\n");
		return sb.toString();
	}
}
